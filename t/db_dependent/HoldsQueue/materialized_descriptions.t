#!/usr/bin/env perl

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

use Test::More tests => 2;
use Test::NoWarnings;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::HoldsQueue;
use Koha::Database;
use Koha::ItemTypes;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'CreatePicklistFromItemMap materializes description columns' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $itemtype = $builder->build_object(
        {
            class => 'Koha::ItemTypes',
            value => { description => 'Test Item Type' },
        }
    );

    my $ccode_av = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => 'CCODE',
                authorised_value => 'TCODE',
                lib              => 'Test Collection',
            },
        }
    );

    my $loc_av = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                category         => 'LOC',
                authorised_value => 'TLOC',
                lib              => 'Test Location',
            },
        }
    );

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            itype        => $itemtype->itemtype,
            ccode        => 'TCODE',
            location     => 'TLOC',
        }
    );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $item_map = {
        $item->itemnumber => {
            biblionumber   => $biblio->biblionumber,
            borrowernumber => $patron->borrowernumber,
            holdingbranch  => $library->branchcode,
            pickup_branch  => $library->branchcode,
            reservedate    => '2026-01-01',
            reservenotes   => undef,
            item_level     => 0,
        },
    };

    my $dbh = C4::Context->dbh;
    $dbh->do("DELETE FROM tmp_holdsqueue");

    C4::HoldsQueue::CreatePicklistFromItemMap($item_map);

    my $row = $dbh->selectrow_hashref( "SELECT * FROM tmp_holdsqueue WHERE itemnumber = ?", undef, $item->itemnumber );

    ok( $row, 'Row inserted into tmp_holdsqueue' );
    is( $row->{itype_description},    'Test Item Type',  'itype_description materialized' );
    is( $row->{ccode_description},    'Test Collection', 'ccode_description materialized' );
    is( $row->{location_description}, 'Test Location',   'location_description materialized' );

    # Test with NULL values
    my $item_no_av = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->branchcode,
            itype        => $itemtype->itemtype,
            ccode        => undef,
            location     => undef,
        }
    );

    my $item_map_no_av = {
        $item_no_av->itemnumber => {
            biblionumber   => $biblio->biblionumber,
            borrowernumber => $patron->borrowernumber,
            holdingbranch  => $library->branchcode,
            pickup_branch  => $library->branchcode,
            reservedate    => '2026-01-01',
            reservenotes   => undef,
            item_level     => 0,
        },
    };

    C4::HoldsQueue::CreatePicklistFromItemMap($item_map_no_av);

    my $row2 =
        $dbh->selectrow_hashref( "SELECT * FROM tmp_holdsqueue WHERE itemnumber = ?", undef, $item_no_av->itemnumber );

    is( $row2->{ccode_description},    undef, 'ccode_description is NULL when item has no ccode' );
    is( $row2->{location_description}, undef, 'location_description is NULL when item has no location' );

    $schema->storage->txn_rollback;
};
