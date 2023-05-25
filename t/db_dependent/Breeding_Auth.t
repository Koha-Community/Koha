#!/usr/bin/perl

# Copyright 2023 Rijksmuseum, Koha development team
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

# Main object of this unit test is Z3950SearchAuth in C4::Breeding.

use Modern::Perl;
use utf8;

use Test::More tests => 2;
use Test::MockModule;
use Test::MockObject;
use Test::Warn;
use ZOOM;

use t::lib::TestBuilder;

use C4::Breeding;
use Koha::Database;
use Koha::Import::Records;

my $schema    = Koha::Database->new->schema;
my $builder   = t::lib::TestBuilder->new;
my $mocks     = {};
my $mock_data = {};

sub init_mock_data {
    my $params = shift;
    $mock_data->{connection_count}  = 1;                         # for event loop
    $mock_data->{record_number}     = 0;                         # record pointer in result loop
    $mock_data->{result_connection} = 0;                         # current connection in result loop
    $mock_data->{result_counts}     = $params->{result_counts}
        // [];    # result count per connection, sum should match with results array
    $mock_data->{results}         = $params->{results} // [];    # arrayref of MARC blobs (or even records)
    $mock_data->{template_params} = {};                          # will catch results from param calls
}

sub mock_objects {
    $mocks->{record_object} = Test::MockObject->new;
    $mocks->{record_object}->mock(
        'raw',
        sub {
            return $mock_data->{results}->[ $mock_data->{record_number}++ ];
        }
    );

    $mocks->{result_object} = Test::MockObject->new;
    $mocks->{result_object}->mock(
        'size',
        sub {
            # Each size call means that we look at new connection results
            return $mock_data->{result_counts}->[ $mock_data->{result_connection}++ ];
        }
    );
    $mocks->{result_object}->mock( 'record',  sub { $mocks->{record_object} } );
    $mocks->{result_object}->mock( 'destroy', sub { } );

    $mocks->{connection_object} = Test::MockObject->new;
    $mocks->{connection_object}->mock( 'search',     sub { $mocks->{result_object}; } );
    $mocks->{connection_object}->mock( 'search_pqf', sub { $mocks->{result_object}; } );
    $mocks->{connection_object}->mock( 'error_x',    sub { } );
    $mocks->{connection_object}->mock( 'last_event', sub { return ZOOM::Event::ZEND; } );
    $mocks->{connection_object}->mock( 'destroy',    sub { } );

    $mocks->{Breeding} = Test::MockModule->new('C4::Breeding');
    $mocks->{Breeding}->mock( '_create_connection', sub { return $mocks->{connection_object}; } );

    $mocks->{ZOOM} = Test::MockModule->new('ZOOM');
    $mocks->{ZOOM}->mock( 'event', sub { return $mock_data->{connection_count}++; } );

    $mocks->{template_object} = Test::MockObject->new;
    $mocks->{template_object}
        ->mock( 'param', sub { shift; $mock_data->{template_params} = { %{ $mock_data->{template_params} }, @_ }; } );
}

$schema->storage->txn_begin;

subtest ImportBreedingAuth => sub {
    plan tests => 4;

    my $record = MARC::Record->new();
    $record->append_fields(
        MARC::Field->new( '001', '4815162342' ),
        MARC::Field->new( '100', ' ', ' ', a => 'Jansson, Tove' ),
    );

    my $breedingid = C4::Breeding::ImportBreedingAuth( $record, "kidclamp", "UTF-8", 'Jansson, Tove' );
    ok( $breedingid, "We got a breeding id back" );
    my $breedingid_1 = C4::Breeding::ImportBreedingAuth( $record, "kidclamp", "UTF-8", 'Jansson, Tove' );
    is( $breedingid, $breedingid_1, "For the same record, we get the same id" );
    $breedingid_1 = C4::Breeding::ImportBreedingAuth( $record, "marcelr", "UTF-8", 'Jansson, Tove' );
    is( $breedingid, $breedingid_1, "For the same record in a different file, we get a new id" );
    my $record_1 = MARC::Record->new();
    $record_1->append_fields(
        MARC::Field->new( '001', '8675309' ),
        MARC::Field->new( '100', ' ', ' ', a => 'Cooper, Susan' ),
    );
    my $breedingid_2 = C4::Breeding::ImportBreedingAuth( $record_1, "kidclamp", "UTF-8", 'Cooper, Susan' );
    isnt( $breedingid, $breedingid_2, "For a new record, we get a new id" );
};

subtest 'Z3950SearchAuth' => sub {
    plan tests => 15;

    init_mock_data();
    mock_objects();
    my $marc8_server = $builder->build(
        {
            source => 'Z3950server',
            value  => {
                recordtype => 'authority', servertype => 'zed', host => 'marc8test', servername => 'MARC8 server',
                syntax => 'USMARC', encoding => 'MARC-8', attributes => undef
            },
        }
    );
    my $utf8_server = $builder->build(
        {
            source => 'Z3950server',
            value  => {
                recordtype => 'authority', servertype => 'zed',  host       => 'utf8test', servername => 'UTF8 server',
                syntax     => 'USMARC',    encoding   => 'utf8', attributes => undef
            },
        }
    );
    my $template = $mocks->{template_object};

    # First test without any server
    C4::Breeding::Z3950SearchAuth( { srchany => 'a', id => [] }, $template );
    my $output = $mock_data->{template_params};
    is_deeply( $output->{servers},       [], 'No servers' );
    is_deeply( $output->{breeding_loop}, [], 'No data in breedingloop' );

    # One auth server, but no results
    init_mock_data( { result_counts => [0] } );
    C4::Breeding::Z3950SearchAuth( { srchany => 'a', id => [ $marc8_server->{id} ] }, $template );
    $output = $mock_data->{template_params};
    is( $output->{servers}->[0]->{id}, $marc8_server->{id}, 'Server found' );
    is_deeply( $output->{breeding_loop}, [], 'No data in breedingloop yet' );

    # One auth server, one MARC8 record
    my $marc8_record = MARC::Record->new;
    $marc8_record->append_fields(
        MARC::Field->new( '001', '1234' ),
        MARC::Field->new( '100', ' ', ' ', a => 'Cooper, Susan' )
    );
    init_mock_data( { result_counts => [1], results => [ $marc8_record->as_usmarc ] } );
    C4::Breeding::Z3950SearchAuth( { srchany => 'a', id => [ $marc8_server->{id} ] }, $template );
    $output = $mock_data->{template_params};
    is( @{ $output->{breeding_loop} }, 1, 'One result in breedingloop' );
    is( $output->{breeding_loop}->[0]->{heading}, 'Cooper, Susan', 'Check heading' );
    my $import_record = Koha::Import::Records->find( $output->{breeding_loop}->[0]->{breedingid} );
    ok( $import_record, 'import record found' );
    is( $import_record->_result->import_batch->file_name, 'marc8test', 'check file_name (read: host name)' );

    # Two auth servers, one MARC8 and one UTF8 record per connection
    my $utf8_record = MARC::Record->new;
    $utf8_record->append_fields(
        MARC::Field->new( '001', '2345' ),
        MARC::Field->new( '110', ' ', ' ', a => '中国人 Company' )
    );
    $utf8_record->encoding('UTF-8');
    init_mock_data( { result_counts => [ 1, 1 ], results => [ $marc8_record->as_usmarc, $utf8_record->as_usmarc ] } );
    C4::Breeding::Z3950SearchAuth( { srchany => 'a', id => [ $marc8_server->{id}, $utf8_server->{id} ] }, $template );
    $output = $mock_data->{template_params};
    is( @{ $output->{servers} },                  2,               'Two servers' );
    is( @{ $output->{breeding_loop} },            2,               'Two results in breedingloop' );
    is( $output->{breeding_loop}->[0]->{heading}, 'Cooper, Susan', 'Check heading result 1' );
    ok( Koha::Import::Records->find( $output->{breeding_loop}->[0]->{breedingid} ), 'import record 1 found' );
    is( $output->{breeding_loop}->[1]->{heading}, '中国人 Company', 'Check heading result 2' );
    ok( Koha::Import::Records->find( $output->{breeding_loop}->[1]->{breedingid} ), 'import record 2 found' );

    # One auth server, wrong encoding (utf8 from marc8 source)
    init_mock_data( { result_counts => [1], results => [ $utf8_record->as_usmarc ] } );
    warning_like { C4::Breeding::Z3950SearchAuth( { srchany => 'a', id => [ $marc8_server->{id} ] }, $template ); }
    qr/Z3950SearchAuth conversion error.*MARC8 server.*\d+.*failed.*no mapping found for \[0x4E2D\]/,
        'Dumped conversion error found';
};

$schema->storage->txn_rollback;
