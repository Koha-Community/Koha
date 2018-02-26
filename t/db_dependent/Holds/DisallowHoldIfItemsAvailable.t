#!/usr/bin/perl

use Modern::Perl;

use C4::Context;
use C4::Circulation;
use C4::Items;
use Koha::Items;
use Koha::CirculationRules;

use Test::More tests => 6;

use t::lib::TestBuilder;
use t::lib::Mocks;

BEGIN {
    use_ok('C4::Reserves');
}

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

my $library1 = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});
my $itemtype = $builder->build({
    source => 'Itemtype',
    value  => { notforloan => 0 }
})->{itemtype};

t::lib::Mocks::mock_userenv({ branchcode => $library1->{branchcode} });


my $patron1 = $builder->build_object({
    class => 'Koha::Patrons',
    value => {
        branchcode => $library1->{branchcode},
        dateexpiry => '3000-01-01',
    }
});
my $borrower1 = $patron1->unblessed;

my $patron2 = $builder->build_object({
    class => 'Koha::Patrons',
    value => {
        branchcode => $library1->{branchcode},
        dateexpiry => '3000-01-01',
    }
});

my $patron3 = $builder->build_object({
    class => 'Koha::Patrons',
    value => {
        branchcode => $library2->{branchcode},
        dateexpiry => '3000-01-01',
    }
});

my $library_A = $library1->{branchcode};
my $library_B = $library2->{branchcode};

my $biblio = $builder->build_sample_biblio({itemtype=>$itemtype});
my $biblionumber = $biblio->biblionumber;
my $item1  = $builder->build_sample_item({
    biblionumber=>$biblionumber,
    itype=>$itemtype,
    homebranch => $library_A,
    holdingbranch => $library_A
});
my $item2  = $builder->build_sample_item({
    biblionumber=>$biblionumber,
    itype=>$itemtype,
    homebranch => $library_A,
    holdingbranch => $library_A
});

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

my $is = IsAvailableForItemLevelRequest( $item1, $patron1);
is( $is, 0, "Item cannot be held, 2 items available" );

my $issue1 = AddIssue( $patron2->unblessed, $item1->barcode );

$is = IsAvailableForItemLevelRequest( $item1, $patron1);
is( $is, 0, "Item cannot be held, 1 item available" );

AddIssue( $patron2->unblessed, $item2->barcode );

$is = IsAvailableForItemLevelRequest( $item1, $patron1);
is( $is, 1, "Item can be held, no items available" );

AddReturn( $item1->barcode );

{ # Remove the issue for the first patron, and modify the branch for item1
    subtest 'IsAvailableForItemLevelRequest behaviours depending on ReservesControlBranch + holdallowed' => sub {
        plan tests => 2;

        my $hold_allowed_from_home_library = 1;
        my $hold_allowed_from_any_libraries = 2;

        subtest 'Item is available at a different library' => sub {
            plan tests => 7;

            $item1->set({homebranch => $library_B, holdingbranch => $library_B })->store;
            #Scenario is:
            #One shelf holds is 'If all unavailable'/2
            #Item 1 homebranch library B is available
            #Item 2 homebranch library A is checked out
            #Borrower1 is from library A

            {
                set_holdallowed_rule( $hold_allowed_from_home_library );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 1, "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, One item is available at different library, not holdable = none available => the hold is allowed at item level" );
                $is = IsAvailableForItemLevelRequest( $item1, $patron2);
                is( $is, 1, "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, One item is available at home library, holdable = one available => the hold is not allowed at item level" );
                set_holdallowed_rule( $hold_allowed_from_any_libraries, $library_B );
                #Adding a rule for the item's home library affects the availability for a borrower from another library because ReservesControlBranch is set to ItemHomeLibrary
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, One item is available at different library, holdable = one available => the hold is not allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 1, "Hold allowed from home library + ReservesControlBranch=PatronLibrary, One item is available at different library, not holdable = none available => the hold is allowed at item level" );
                #Adding a rule for the patron's home library affects the availability for an item from another library because ReservesControlBranch is set to PatronLibrary
                set_holdallowed_rule( $hold_allowed_from_any_libraries, $library_A );
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from home library + ReservesControlBranch=PatronLibrary, One item is available at different library, holdable = one available => the hold is not allowed at item level" );
            }

            {
                set_holdallowed_rule( $hold_allowed_from_any_libraries );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=ItemHomeLibrary, One item is available at the diff library, holdable = 1 available => the hold is not allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=PatronLibrary, One item is available at the diff library, holdable = 1 available => the hold is not allowed at item level" );
            }
        };

        subtest 'Item is available at the same library' => sub {
            plan tests => 4;

            $item1->set({homebranch => $library_A, holdingbranch => $library_A })->store;
            #Scenario is:
            #One shelf holds is 'If all unavailable'/2
            #Item 1 homebranch library A is available
            #Item 2 homebranch library A is checked out
            #Borrower1 is from library A
            #CircControl has no effect - same rule for all branches as set at line 96
            #ReservesControlBranch is not checked in these subs we are testing?

            {
                set_holdallowed_rule( $hold_allowed_from_home_library );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from home library + ReservesControlBranch=ItemHomeLibrary, One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from home library + ReservesControlBranch=PatronLibrary, One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level" );
            }

            {
                set_holdallowed_rule( $hold_allowed_from_any_libraries );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=ItemHomeLibrary, One item is available at the same library, holdable = 1 available => the hold is not allowed at item level" );

                t::lib::Mocks::mock_preference('ReservesControlBranch', 'PatronLibrary');
                $is = IsAvailableForItemLevelRequest( $item1, $patron1);
                is( $is, 0, "Hold allowed from any library + ReservesControlBranch=PatronLibrary, One item is available at the same library, holdable = 1 available  => the hold is not allowed at item level" );
            }
        };
    };
}

my $itemtype2 = $builder->build({
    source => 'Itemtype',
    value  => { notforloan => 0 }
})->{itemtype};
my $item3 = $builder->build_sample_item({ itype => $itemtype2 });

my $hold = $builder->build({
    source => 'Reserve',
    value =>{
        itemnumber => $item3->itemnumber,
        found => 'T'
    }
});

Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => $itemtype2,
        branchcode   => undef,
        rules        => {
            maxissueqty     => 99,
            onshelfholds    => 2,
        }
    }
);

$is = IsAvailableForItemLevelRequest( $item3, $patron1);
is( $is, 1, "Item can be held, items in transit are not available" );

# Cleanup
$schema->storage->txn_rollback;

sub set_holdallowed_rule {
    my ( $holdallowed, $branchcode ) = @_;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branchcode || undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                holdallowed              => $holdallowed,
                hold_fulfillment_policy  => 'any',
                returnbranch             => 'homebranch',
            }
        }
    );
}
