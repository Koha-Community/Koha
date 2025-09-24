#!/usr/bin/perl

# Copyright 2016 ByWater Solutions
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
use Test::More tests => 17;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Reserves qw( GetMaxPatronHoldsForRecord CanBookBeReserved AddReserve );
use Koha::Database;
use Koha::Holds;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new();
my $library = $builder->build(
    {
        source => 'Branch',
    }
);

my $category = $builder->build(
    {
        source => 'Category',
    }
);
my $patron = $builder->build(
    {
        source => 'Borrower',
        value  => {
            categorycode => $category->{categorycode},
            branchcode   => $library->{branchcode},
        },
    }
);

my $itemtype1 = $builder->build( { source => 'Itemtype' } );

my $itemtype2 = $builder->build( { source => 'Itemtype' } );

my $biblio = $builder->build_sample_biblio;
my $item1  = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        itype        => $itemtype1->{itemtype},
        library      => $library->{branchcode},
    },
);
my $item2 = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        itype        => $itemtype2->{itemtype},
        library      => $library->{branchcode},
    }
);
my $item3 = $builder->build_sample_item(
    {
        biblionumber => $biblio->biblionumber,
        itype        => $itemtype2->{itemtype},
        library      => $library->{branchcode},
    }
);

Koha::CirculationRules->delete();

# Test GetMaxPatronHoldsForRecord
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            reservesallowed  => 1,
            holds_per_record => 1,
        }
    }
);

t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );    # Assuming the item type is defined at item level

my $max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->biblionumber );
is( $max, 1, 'GetMaxPatronHoldsForRecord returns max of 1' );

Koha::CirculationRules->set_rules(
    {
        categorycode => $category->{categorycode},
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            reservesallowed  => 2,
            holds_per_record => 2,
        }
    }
);

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->biblionumber );
is( $max, 2, 'GetMaxPatronHoldsForRecord returns max of 2' );

Koha::CirculationRules->set_rules(
    {
        categorycode => $category->{categorycode},
        itemtype     => $itemtype1->{itemtype},
        branchcode   => undef,
        rules        => {
            reservesallowed  => 3,
            holds_per_record => 3,
        }
    }
);

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->biblionumber );
is( $max, 3, 'GetMaxPatronHoldsForRecord returns max of 3' );

Koha::CirculationRules->set_rules(
    {
        categorycode => $category->{categorycode},
        itemtype     => $itemtype2->{itemtype},
        branchcode   => undef,
        rules        => {
            reservesallowed  => 4,
            holds_per_record => 4,
        }
    }
);

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->biblionumber );
is( $max, 4, 'GetMaxPatronHoldsForRecord returns max of 4' );

Koha::CirculationRules->set_rules(
    {
        categorycode => $category->{categorycode},
        itemtype     => $itemtype2->{itemtype},
        branchcode   => $library->{branchcode},
        rules        => {
            reservesallowed  => 5,
            holds_per_record => 5,
        }
    }
);

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->biblionumber );
is( $max, 5, 'GetMaxPatronHoldsForRecord returns max of 5' );

Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => $library->{branchcode},
        rules        => {
            reservesallowed  => 9,
            holds_per_record => 9,
        }
    }
);

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->biblionumber );
is(
    $max, 9,
    'GetMaxPatronHoldsForRecord returns max of 9 because Library specific all itemtypes all categories rule comes before All libraries specific type and specific category'
);

Koha::CirculationRules->delete();

my $holds = Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } );
is( $holds->forced_hold_level, undef, "No holds does not force an item or record level hold" );

# Test Koha::Holds::forced_hold_level
my $hold = Koha::Hold->new(
    {
        borrowernumber => $patron->{borrowernumber},
        reservedate    => '1981-06-10',
        biblionumber   => $biblio->biblionumber,
        branchcode     => $library->{branchcode},
        priority       => 1,
    }
)->store();

$holds = Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } );
is( $holds->forced_hold_level, 'record', "Record level hold forces record level holds" );

$hold->itemnumber( $item1->itemnumber );
$hold->store();

$holds = Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } );
is( $holds->forced_hold_level, 'item', "Item level hold forces item level holds" );

my $item_group = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();
$hold->itemnumber(undef);
$hold->item_group_id( $item_group->id );
$hold->store();

$holds = Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } );
is( $holds->forced_hold_level, 'item_group', "Item group level hold forces item group level holds" );

$hold->delete();

# Test multi-hold via AddReserve
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            reservesallowed  => 3,
            holds_per_record => 2,
        }
    }
);

my $can = CanBookBeReserved( $patron->{borrowernumber}, $biblio->biblionumber );
is( $can->{status}, 'OK', 'Hold can be placed with 0 holds' );
my $hold_id = AddReserve(
    {
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->biblionumber,
        priority       => 1
    }
);
ok( $hold_id, 'First hold was placed' );

$can = CanBookBeReserved( $patron->{borrowernumber}, $biblio->biblionumber );
is( $can->{status}, 'OK', 'Hold can be placed with 1 hold' );
$hold_id = AddReserve(
    {
        branchcode     => $library->{branchcode},
        borrowernumber => $patron->{borrowernumber},
        biblionumber   => $biblio->biblionumber,
        priority       => 1
    }
);
ok( $hold_id, 'Second hold was placed' );

$can = CanBookBeReserved( $patron->{borrowernumber}, $biblio->biblionumber );
is( $can->{status}, 'tooManyHoldsForThisRecord', 'Third hold exceeds limit of holds per record' );

Koha::Holds->find($hold_id)->found("W")->store;
$can = CanBookBeReserved( $patron->{borrowernumber}, $biblio->biblionumber );
is( $can->{status}, 'tooManyHoldsForThisRecord', 'Third hold exceeds limit of holds per record' );

$schema->storage->txn_rollback;
