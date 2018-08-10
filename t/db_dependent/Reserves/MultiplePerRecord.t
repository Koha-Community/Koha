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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 38;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Reserves qw( GetMaxPatronHoldsForRecord AddReserve CanBookBeReserved );
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

my $itemtype1 = $builder->build(
    {
        source => 'Itemtype'
    }
);

my $itemtype2 = $builder->build(
    {
        source => 'Itemtype'
    }
);

my $biblio = $builder->build(
    {
        source => 'Biblio',
        value  => {
            title => 'Title 1',
        },
    }
);
my $biblioitem = $builder->build(
    {
        source => 'Biblioitem',
        value  => { biblionumber => $biblio->{biblionumber} }
    }
);
my $item1 = $builder->build(
    {
        source => 'Item',
        value  => {
            biblionumber  => $biblio->{biblionumber},
            itype         => $itemtype1->{itemtype},
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
            damaged       => 0,
        },
    }
);
my $item2 = $builder->build(
    {
        source => 'Item',
        value  => {
            biblionumber  => $biblio->{biblionumber},
            itype         => $itemtype2->{itemtype},
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
            damaged       => 0,
        },
    }
);
my $item3 = $builder->build(
    {
        source => 'Item',
        value  => {
            biblionumber  => $biblio->{biblionumber},
            itype         => $itemtype2->{itemtype},
            homebranch    => $library->{branchcode},
            holdingbranch => $library->{branchcode},
            damaged       => 0,
        },
    }
);

my $rules_rs = Koha::Database->new()->schema()->resultset('Issuingrule');
$rules_rs->delete();

# Test GetMaxPatronHoldsForRecord and GetHoldRule
my $rule1 = $rules_rs->new(
    {
        categorycode     => '*',
        itemtype         => '*',
        branchcode       => '*',
        reservesallowed  => 1,
        holds_per_record => 1,
    }
)->insert();

t::lib::Mocks::mock_preference('item-level_itypes', 1); # Assuming the item type is defined at item level

my $max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->{biblionumber} );
is( $max, 1, 'GetMaxPatronHoldsForRecord returns max of 1' );
my $rule = C4::Reserves::GetHoldRule(
    $category->{categorycode},
    $itemtype1->{itemtype},
    $library->{branchcode}
);
is( $rule->{categorycode},     '*', 'Got rule with universal categorycode' );
is( $rule->{itemtype},         '*', 'Got rule with universal itemtype' );
is( $rule->{branchcode},       '*', 'Got rule with universal branchcode' );
is( $rule->{reservesallowed},  1,   'Got reservesallowed of 1' );
is( $rule->{holds_per_record}, 1,   'Got holds_per_record of 1' );

my $rule2 = $rules_rs->new(
    {
        categorycode     => $category->{categorycode},
        itemtype         => '*',
        branchcode       => '*',
        reservesallowed  => 2,
        holds_per_record => 2,
    }
)->insert();

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->{biblionumber} );
is( $max, 2, 'GetMaxPatronHoldsForRecord returns max of 2' );
$rule = C4::Reserves::GetHoldRule(
    $category->{categorycode},
    $itemtype1->{itemtype},
    $library->{branchcode}
);
is( $rule->{categorycode},     $category->{categorycode}, 'Got rule with specific categorycode' );
is( $rule->{itemtype},         '*',                       'Got rule with universal itemtype' );
is( $rule->{branchcode},       '*',                       'Got rule with universal branchcode' );
is( $rule->{reservesallowed},  2,                         'Got reservesallowed of 2' );
is( $rule->{holds_per_record}, 2,                         'Got holds_per_record of 2' );

my $rule3 = $rules_rs->new(
    {
        categorycode     => $category->{categorycode},
        itemtype         => $itemtype1->{itemtype},
        branchcode       => '*',
        reservesallowed  => 3,
        holds_per_record => 3,
    }
)->insert();

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->{biblionumber} );
is( $max, 3, 'GetMaxPatronHoldsForRecord returns max of 3' );
$rule = C4::Reserves::GetHoldRule(
    $category->{categorycode},
    $itemtype1->{itemtype},
    $library->{branchcode}
);
is( $rule->{categorycode},     $category->{categorycode}, 'Got rule with specific categorycode' );
is( $rule->{itemtype},         $itemtype1->{itemtype},    'Got rule with universal itemtype' );
is( $rule->{branchcode},       '*',                       'Got rule with universal branchcode' );
is( $rule->{reservesallowed},  3,                         'Got reservesallowed of 3' );
is( $rule->{holds_per_record}, 3,                         'Got holds_per_record of 3' );

my $rule4 = $rules_rs->new(
    {
        categorycode     => $category->{categorycode},
        itemtype         => $itemtype2->{itemtype},
        branchcode       => '*',
        reservesallowed  => 4,
        holds_per_record => 4,
    }
)->insert();

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->{biblionumber} );
is( $max, 4, 'GetMaxPatronHoldsForRecord returns max of 4' );
$rule = C4::Reserves::GetHoldRule(
    $category->{categorycode},
    $itemtype2->{itemtype},
    $library->{branchcode}
);
is( $rule->{categorycode},     $category->{categorycode}, 'Got rule with specific categorycode' );
is( $rule->{itemtype},         $itemtype2->{itemtype},    'Got rule with universal itemtype' );
is( $rule->{branchcode},       '*',                       'Got rule with universal branchcode' );
is( $rule->{reservesallowed},  4,                         'Got reservesallowed of 4' );
is( $rule->{holds_per_record}, 4,                         'Got holds_per_record of 4' );

my $rule5 = $rules_rs->new(
    {
        categorycode     => $category->{categorycode},
        itemtype         => $itemtype2->{itemtype},
        branchcode       => $library->{branchcode},
        reservesallowed  => 5,
        holds_per_record => 5,
    }
)->insert();

$max = GetMaxPatronHoldsForRecord( $patron->{borrowernumber}, $biblio->{biblionumber} );
is( $max, 5, 'GetMaxPatronHoldsForRecord returns max of 1' );
$rule = C4::Reserves::GetHoldRule(
    $category->{categorycode},
    $itemtype2->{itemtype},
    $library->{branchcode}
);
is( $rule->{categorycode},     $category->{categorycode}, 'Got rule with specific categorycode' );
is( $rule->{itemtype},         $itemtype2->{itemtype},    'Got rule with universal itemtype' );
is( $rule->{branchcode},       $library->{branchcode},    'Got rule with specific branchcode' );
is( $rule->{reservesallowed},  5,                         'Got reservesallowed of 5' );
is( $rule->{holds_per_record}, 5,                         'Got holds_per_record of 5' );

$rule1->delete();
$rule2->delete();
$rule3->delete();
$rule4->delete();
$rule5->delete();

my $holds = Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } );
is( $holds->forced_hold_level, undef, "No holds does not force an item or record level hold" );

# Test Koha::Holds::forced_hold_level
my $hold = Koha::Hold->new({
    borrowernumber => $patron->{borrowernumber},
    reservedate => '1981-06-10',
    biblionumber => $biblio->{biblionumber},
    branchcode => $library->{branchcode},
    priority => 1,
})->store();

$holds = Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } );
is( $holds->forced_hold_level, 'record', "Record level hold forces record level holds" );

$hold->itemnumber( $item1->{itemnumber} );
$hold->store();

$holds = Koha::Holds->search( { borrowernumber => $patron->{borrowernumber} } );
is( $holds->forced_hold_level, 'item', "Item level hold forces item level holds" );

$hold->delete();

# Test multi-hold via AddReserve
$rule = $rules_rs->new(
    {
        categorycode     => '*',
        itemtype         => '*',
        branchcode       => '*',
        reservesallowed  => 2,
        holds_per_record => 2,
    }
)->insert();

my $can = CanBookBeReserved($patron->{borrowernumber}, $biblio->{biblionumber});
is( $can->{status}, 'OK', 'Hold can be placed with 0 holds' );
my $hold_id = AddReserve( $library->{branchcode}, $patron->{borrowernumber}, $biblio->{biblionumber}, '', 1 );
ok( $hold_id, 'First hold was placed' );

$can = CanBookBeReserved($patron->{borrowernumber}, $biblio->{biblionumber});
is( $can->{status}, 'OK', 'Hold can be placed with 1 hold' );
$hold_id = AddReserve( $library->{branchcode}, $patron->{borrowernumber}, $biblio->{biblionumber}, '', 1 );
ok( $hold_id, 'Second hold was placed' );

$can = CanBookBeReserved($patron->{borrowernumber}, $biblio->{biblionumber});
is( $can->{status}, 'tooManyHoldsForThisRecord', 'Third hold exceeds limit of holds per record' );

$schema->storage->txn_rollback;

