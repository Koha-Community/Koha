#!/usr/bin/perl

# Copyright 2022 Koha Development Team, Marcel de Rooy
# Copyright 2012 C & P Bibliography Services
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 4;

use MARC::File::XML;

use t::lib::TestBuilder;

use Koha::Database;
use Koha::Authorities;

BEGIN {
    use_ok('Koha::MetadataRecord::Authority');
}

our $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $builder = t::lib::TestBuilder->new;

our $record1 = MARC::Record->new;
$record1->add_fields(
    [ '001', '1234' ],
    [ '150', ' ', ' ', a => 'Cooking' ],
    [ '450', ' ', ' ', a => 'Cookery' ],
);
our $record2 = MARC::Record->new;
$record2->add_fields(
    [ '001', '2345' ],
    [ '150', ' ', ' ', a => 'Baking' ],
    [ '450', ' ', ' ', a => 'Bakery' ],
);

subtest 'Test new, authorized_heading, authid, get_from_authid' => sub {
    plan tests => 7;

    my $auth1 = $builder->build_object(
        {
            class => 'Koha::Authorities',
            value => { marcxml => $record1->as_xml },
        }
    );
    my $auth2 = $builder->build_object(
        {
            class => 'Koha::Authorities',
            value => { marcxml => $record2->as_xml },
        }
    );

    my $authority = Koha::MetadataRecord::Authority->new($record1);
    is( ref($authority), 'Koha::MetadataRecord::Authority', 'Created valid Koha::MetadataRecord::Authority object' );
    is( $authority->authorized_heading(), 'Cooking',        'Authorized heading was correct' );
    is_deeply( $authority->record, $record1, 'Saved record' );

    $authority = Koha::MetadataRecord::Authority->get_from_authid( $auth2->id );
    is( ref($authority), 'Koha::MetadataRecord::Authority', 'Retrieved valid Koha::MetadataRecord::Authority object' );
    is( $authority->authid,                       $auth2->id, 'Object authid is correct' );
    is( $authority->record->field('001')->data(), '2345',     'Retrieved original 001' )
        ;    # Note: not created via AddAuthority

    $authority = Koha::MetadataRecord::Authority->get_from_authid('alphabetsoup');
    is( $authority, undef, 'No invalid record is retrieved' );
};

subtest 'Test get_from_breeding' => sub {
    plan tests => 4;

    my $import = $builder->build(
        {
            source => 'ImportRecord',
            value  => { marcxml => $record1->as_xml, record_type => 'auth' },
        }
    );
    my $import_record_id = $import->{import_record_id};

    my $authority = Koha::MetadataRecord::Authority->get_from_breeding($import_record_id);
    is( ref($authority), 'Koha::MetadataRecord::Authority', 'Retrieved valid Koha::MetadataRecord::Authority object' );
    is( $authority->authid,        undef,                   'Records in reservoir do not have an authid' );
    is( ref( $authority->record ), 'MARC::Record',          'MARC record attached to authority' );

    $authority = Koha::MetadataRecord::Authority->get_from_breeding('alphabetsoup');
    is( $authority, undef, 'No invalid record is retrieved from reservoir' );
};

$schema->storage->txn_rollback;
