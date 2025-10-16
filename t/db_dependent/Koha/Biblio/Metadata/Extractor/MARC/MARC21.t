#!/usr/bin/perl

# Copyright 2023 Koha Development team
#
# This file is part of Koha
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Biblio qw(ModBiblio);
use Koha::Biblio::Metadata::Extractor;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

subtest 'new() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    throws_ok { Koha::Biblio::Metadata::Extractor->new; }
    'Koha::Exceptions::MissingParameter',
        'Exception if no parameter';

    my $biblio = $builder->build_sample_biblio;

    my $extractor = Koha::Biblio::Metadata::Extractor->new( { biblio => $biblio } );
    is( ref($extractor), 'Koha::Biblio::Metadata::Extractor::MARC::MARC21' );

    my $record = $biblio->metadata->record;
    $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );
    is( ref($extractor), 'Koha::Biblio::Metadata::Extractor::MARC::MARC21' );
};

subtest 'get_normalized_upc() tests' => sub {

    plan tests => 2;

    my $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new( '024', '1', ' ', a => "9-123345345X" ) );

    my $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );
    is( $extractor->get_normalized_upc, '9123345345X' );

    $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new( '024', ' ', ' ', a => "9-123345345X" ) );

    $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );
    is( $extractor->get_normalized_upc, "" );

};

subtest 'get_normalized_oclc() tests' => sub {

    plan tests => 2;

    my $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new( '035', ' ', ' ', a => "(OCoLC)902632762" ) );

    my $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );
    is( $extractor->get_normalized_oclc, '902632762' );

    $record    = MARC::Record->new();
    $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );

    is( $extractor->get_normalized_oclc, "" );

};

subtest 'check_fixed_length' => sub {

    plan tests => 8;
    $schema->storage->txn_begin;

    # Check empty object
    my $record    = MARC::Record->new;
    my $extractor = Koha::Biblio::Metadata::Extractor::MARC->new( { metadata => $record } );
    my $result    = $extractor->check_fixed_length;
    is( scalar @{ $result->{passed} }, 0, 'No passed fields' );
    is( scalar @{ $result->{failed} }, 0, 'No failed fields' );

    $record->append_fields(
        MARC::Field->new( '005', '0123456789012345' ),
    );
    my $biblio = $builder->build_sample_biblio;
    ModBiblio( $record, $biblio->biblionumber );

    $extractor = Koha::Biblio::Metadata::Extractor::MARC->new( { biblio => $biblio } );
    $result    = $extractor->check_fixed_length;
    is( $result->{passed}->[0],        '005', 'Check first passed field' );
    is( scalar @{ $result->{failed} }, 0,     'Check failed count' );

    $record->append_fields(
        MARC::Field->new( '006', '01234567890123456789' ),      # too long
        MARC::Field->new( '007', 'a1234567' ),
        MARC::Field->new( '007', 'm12345678' ),                 # should be 8 or 23
        MARC::Field->new( '007', 'm1234567890123456789012' ),
    );

    # Passing latest record changes via metadata now
    $extractor = Koha::Biblio::Metadata::Extractor::MARC->new( { metadata => $record } );
    $result    = $extractor->check_fixed_length;
    is( $result->{passed}->[1], '007', 'Check second passed field' );
    is( $result->{passed}->[2], '007', 'Check third passed field' );
    is( $result->{failed}->[0], '006', 'Check first failed field' );
    is( $result->{failed}->[1], '007', 'Check second failed field' );

    $schema->storage->txn_rollback;
};
