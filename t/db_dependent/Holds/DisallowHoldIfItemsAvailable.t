#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Circulation qw( AddIssue AddReturn );
use C4::Items;
use Koha::Items;
use Koha::Cache::Memory::Lite;
use Koha::CirculationRules;

use Test::More tests => 13;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok( 'C4::Reserves', qw( ItemsAnyAvailableAndNotRestricted IsAvailableForItemLevelRequest ) );
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh   = C4::Context->dbh;
my $cache = Koha::Cache::Memory::Lite->get_instance();

my $builder = t::lib::TestBuilder->new;

my $library1 = $builder->build( { source => 'Branch', } );
my $library2 = $builder->build( { source => 'Branch', } );
my $itemtype = $builder->build(
    {
        source => 'Itemtype',
        value  => { notforloan => 0 }
    }
)->{itemtype};

t::lib::Mocks::mock_userenv( { branchcode => $library1->{branchcode} } );

my $patron1 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            branchcode => $library1->{branchcode},
            dateexpiry => '3000-01-01',
        }
    }
);
my $borrower1 = $patron1->unblessed;

my $patron2 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            branchcode => $library1->{branchcode},
            dateexpiry => '3000-01-01',
        }
    }
);

my $patron3 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            branchcode => $library2->{branchcode},
            dateexpiry => '3000-01-01',
        }
    }
);

my $library_A = $library1->{branchcode};
my $library_B = $library2->{branchcode};

my $biblio       = $builder->build_sample_biblio( { itemtype => $itemtype } );
my $biblionumber = $biblio->biblionumber;
my $item1        = $builder->build_sample_item(
    {
        biblionumber  => $biblionumber,
        itype         => $itemtype,
        homebranch    => $library_A,
        holdingbranch => $library_A
    }
);
my $item2 = $builder->build_sample_item(
    {
        biblionumber  => $biblionumber,
        itype         => $itemtype,
        homebranch    => $library_A,
        holdingbranch => $library_A
    }
);

# Test hold_fulfillment_policy
$dbh->do("DELETE FROM circulation_rules");
Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => $itemtype,
        branchcode   => undef,
        rules        => {
            issuelength     => 7,
            lengthunit      => 8,
            reservesallowed => 99,
            onshelfholds    => 2,
        }
    }
);

my $is;

$is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } );
is( $is, 1, "Items availability: both of 2 items are available" );

$is = IsAvailableForItemLevelRequest( $item1, $patron1 );
is( $is, 0, "Item cannot be held, 2 items available" );

my $issue1 = AddIssue( $patron2->unblessed, $item1->barcode );

$is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } );
is( $is, 1, "Items availability: one item is available" );

$is = IsAvailableForItemLevelRequest( $item1, $patron1 );
is( $is, 0, "Item cannot be held, 1 item available" );

AddIssue( $patron2->unblessed, $item2->barcode );
$cache->flush();

$is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } );
is( $is, 0, "Items availability: none of items are available" );

$is = IsAvailableForItemLevelRequest( $item1, $patron1 );
is( $is, 1, "Item can be held, no items available" );

AddReturn( $item1->barcode );

{    # Remove the issue for the first patron, and modify the branch for item1
    subtest 'IsAvailableForItemLevelRequest behaviours depending on ReservesControlBranch + holdallowed' => sub {
        plan tests => 2;

        my $hold_allowed_from_home_library  = 'from_home_library';
        my $hold_allowed_from_any_libraries = 'from_any_library';

        subtest 'Item is available at a different library' => sub {
            plan tests => 13;

            $item1->set( { homebranch => $library_B, holdingbranch => $library_B } )->store;

            #Scenario is:
            #One shelf holds is 'If all unavailable'/2
            #Item 1 homebranch library B is available
            #Item 2 homebranch library A is checked out
            #Borrower1 is from library A

            {
                set_holdallowed_rule($hold_allowed_from_home_library);

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 0 items, library B 1 item
                is(
                    $is, 0,
                    "Items availability: hold allowed from home + ReservesControlBranch=ItemHomeLibrary + one item is available at different library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 1,
                    "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, "
                        . "One item is available at different library, not holdable = none available => the hold is allowed at item level"
                );
                $is = IsAvailableForItemLevelRequest( $item1, $patron2 );
                is(
                    $is, 1,
                    "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, "
                        . "One item is available at home library, holdable = one available => the hold is not allowed at item level"
                );
                set_holdallowed_rule( $hold_allowed_from_any_libraries, $library_B );

                #Adding a rule for the item's home library affects the availability for a borrower from another library because ReservesControlBranch is set to ItemHomeLibrary
                $cache->flush();

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 0 items, library B 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from any library for library B + ReservesControlBranch=ItemHomeLibrary + one item is available at different library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, "
                        . "One item is available at different library, holdable = one available => the hold is not allowed at item level"
                );

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );
                $cache->flush();

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 0 items, library B 1 item
                is(
                    $is, 0,
                    "Items availability: hold allowed from any library for library B + ReservesControlBranch=PatronLibrary + one item is available at different library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 1,
                    "Hold allowed from home library + ReservesControlBranch=PatronLibrary, "
                        . "One item is available at different library, not holdable = none available => the hold is allowed at item level"
                );

                #Adding a rule for the patron's home library affects the availability for an item from another library because ReservesControlBranch is set to PatronLibrary
                set_holdallowed_rule( $hold_allowed_from_any_libraries, $library_A );
                $cache->flush();

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 0 items, library B 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from any library for library A + ReservesControlBranch=PatronLibrary + one item is available at different library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from home library + ReservesControlBranch=PatronLibrary, "
                        . "One item is available at different library, holdable = one available => the hold is not allowed at item level"
                );
            }

            {
                set_holdallowed_rule($hold_allowed_from_any_libraries);

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );
                $cache->flush();

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 0 items, library B 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from any library + ReservesControlBranch=ItemHomeLibrary + one item is available at different library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from any library + ReservesControlBranch=ItemHomeLibrary, "
                        . "One item is available at the diff library, holdable = 1 available => the hold is not allowed at item level"
                );

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );
                $cache->flush();

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 0 items, library B 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from any library + ReservesControlBranch=PatronLibrary + one item is available at different library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from any library + ReservesControlBranch=PatronLibrary, "
                        . "One item is available at the diff library, holdable = 1 available => the hold is not allowed at item level"
                );
            }
        };

        subtest 'Item is available at the same library' => sub {
            plan tests => 8;

            $item1->set( { homebranch => $library_A, holdingbranch => $library_A } )->store;

            #Scenario is:
            #One shelf holds is 'If all unavailable'/2
            #Item 1 homebranch library A is available
            #Item 2 homebranch library A is checked out
            #Borrower1 is from library A
            #CircControl has no effect - same rule for all branches as set at line 96
            #ReservesControlBranch is not checked in these subs we are testing?

            {
                set_holdallowed_rule($hold_allowed_from_home_library);

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from home library + ReservesControlBranch=ItemHomeLibrary + one item is available at home library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, "
                        . "One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level"
                );

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from home library + ReservesControlBranch=PatronLibrary + one item is available at home library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from home library + ReservesControlBranch=PatronLibrary, "
                        . "One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level"
                );
            }

            {
                set_holdallowed_rule($hold_allowed_from_any_libraries);

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from any library + ReservesControlBranch=ItemHomeLibrary + one item is available at home library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from any library + ReservesControlBranch=ItemHomeLibrary, "
                        . "One item is available at the same library, holdable = 1 available => the hold is not allowed at item level"
                );

                t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );

                $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
                    ;    # patron1 in library A, library A 1 item
                is(
                    $is, 1,
                    "Items availability: hold allowed from any library + ReservesControlBranch=PatronLibrary + one item is available at home library"
                );

                $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
                is(
                    $is, 0,
                    "Hold allowed from any library + ReservesControlBranch=PatronLibrary, "
                        . "One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level"
                );
            }
        };
    };
}

my $itemtype2 = $builder->build(
    {
        source => 'Itemtype',
        value  => { notforloan => 0 }
    }
)->{itemtype};
my $item3 = $builder->build_sample_item( { itype => $itemtype2 } );

my $hold = $builder->build(
    {
        source => 'Reserve',
        value  => {
            itemnumber => $item3->itemnumber,
            found      => 'T'
        }
    }
);

Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => $itemtype2,
        branchcode   => undef,
        rules        => {
            maxissueqty  => 99,
            onshelfholds => 0,
        }
    }
);

$is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblionumber, patron => $patron1 } )
    ;    # patron1 in library A, library A 1 item
is( $is, 1, "Items availability: 1 item is available, 1 item held in T" );

$is = IsAvailableForItemLevelRequest( $item3, $patron1 );
is( $is, 1, "Item can be held, items in transit are not available" );

subtest 'Check holds availability with different item types' => sub {
    plan tests => 6;

    # Check for holds availability when different item types have different
    # smart rules assigned both with "if all unavailable" set,
    # and $itemtype rule allows holds, $itemtype2 rule disallows holds.
    # So, $item should be available for hold when checked out even if $item2
    # is not checked out, because anyway $item2 unavailable for holds by rule
    # (Bug 24683):

    my $biblio2 = $builder->build_sample_biblio( { itemtype => $itemtype } );
    my $item4   = $builder->build_sample_item(
        {
            biblionumber  => $biblio2->biblionumber,
            itype         => $itemtype,
            homebranch    => $library_A,
            holdingbranch => $library_A
        }
    );
    my $item5 = $builder->build_sample_item(
        {
            biblionumber  => $biblio2->biblionumber,
            itype         => $itemtype2,
            homebranch    => $library_A,
            holdingbranch => $library_A
        }
    );

    # Test hold_fulfillment_policy
    $dbh->do("DELETE FROM circulation_rules");
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $itemtype,
            branchcode   => undef,
            rules        => {
                issuelength      => 7,
                lengthunit       => 8,
                reservesallowed  => 99,
                holds_per_record => 99,
                onshelfholds     => 2,
            }
        }
    );
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $itemtype2,
            branchcode   => undef,
            rules        => {
                issuelength      => 7,
                lengthunit       => 8,
                reservesallowed  => 0,
                holds_per_record => 0,
                onshelfholds     => 2,
            }
        }
    );

    $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblio2->biblionumber, patron => $patron1 } );
    is(
        $is, 1,
        "Items availability: 2 items, one allowed by smart rule but not checked out, another one not allowed to be held by smart rule"
    );

    $is = IsAvailableForItemLevelRequest( $item4, $patron1 );
    is( $is, 0, "Item4 cannot be requested to hold: 2 items, Item4 available, Item5 restricted" );

    $is = IsAvailableForItemLevelRequest( $item5, $patron1 );
    is( $is, 0, "Item5 cannot be requested to hold: 2 items, Item4 available, Item5 restricted" );

    AddIssue( $patron2->unblessed, $item4->barcode );
    $cache->flush();

    $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblio2->biblionumber, patron => $patron1 } );
    is(
        $is, 0,
        "Items availability: 2 items, one allowed by smart rule and checked out, another one not allowed to be held by smart rule"
    );

    $is = IsAvailableForItemLevelRequest( $item4, $patron1 );
    is( $is, 1, "Item4 can be requested to hold, 2 items, Item4 checked out, Item5 restricted" );

    $is = IsAvailableForItemLevelRequest( $item5, $patron1 );

    # Note: read IsAvailableForItemLevelRequest sub description about CanItemBeReserved/CanBookBeReserved:
    is( $is, 1, "Item5 can be requested to hold, 2 items, Item4 checked out, Item5 restricted" );
};

subtest 'Check item checkout availability with ordered item' => sub {
    plan tests => 1;

    my $biblio2 = $builder->build_sample_biblio( { itemtype => $itemtype } );
    my $item1   = $builder->build_sample_item(
        {
            biblionumber  => $biblio2->biblionumber,
            itype         => $itemtype2,
            homebranch    => $library_A,
            holdingbranch => $library_A,
            notforloan    => -1
        }
    );

    $dbh->do("DELETE FROM circulation_rules");
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $itemtype2,
            branchcode   => undef,
            rules        => {
                issuelength      => 7,
                lengthunit       => 8,
                reservesallowed  => 99,
                holds_per_record => 99,
                onshelfholds     => 2,
            }
        }
    );
    $cache->flush();

    $is = ItemsAnyAvailableAndNotRestricted( { biblionumber => $biblio2->biblionumber, patron => $patron1 } );
    is( $is, 0, "Ordered item cannot be checked out" );
};

subtest 'Check item availability for hold with ordered item' => sub {
    plan tests => 1;

    my $biblio2 = $builder->build_sample_biblio( { itemtype => $itemtype } );
    my $item1   = $builder->build_sample_item(
        {
            biblionumber  => $biblio2->biblionumber,
            itype         => $itemtype2,
            homebranch    => $library_A,
            holdingbranch => $library_A,
            notforloan    => -1
        }
    );

    $dbh->do("DELETE FROM circulation_rules");
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $itemtype2,
            branchcode   => undef,
            rules        => {
                issuelength      => 7,
                lengthunit       => 8,
                reservesallowed  => 99,
                holds_per_record => 99,
                onshelfholds     => 2,
            }
        }
    );

    $cache->flush();
    $is = IsAvailableForItemLevelRequest( $item1, $patron1 );
    is( $is, 1, "Ordered items are available for hold" );
};

# Cleanup
$schema->storage->txn_rollback;

sub set_holdallowed_rule {
    my ( $holdallowed, $branchcode ) = @_;
    Koha::CirculationRules->set_rules(
        {
            branchcode => $branchcode || undef,
            itemtype   => undef,
            rules      => {
                holdallowed             => $holdallowed,
                hold_fulfillment_policy => 'any',
                returnbranch            => 'homebranch',
            }
        }
    );
}
