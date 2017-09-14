#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 9;
use C4::Context;

use C4::Members;
use C4::Items;
use C4::Biblio;
use C4::Circulation;
use C4::Context;

use Koha::DateUtils qw( dt_from_string );
use Koha::Database;
use Koha::CirculationRules;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

our $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM items|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM branches|);
$dbh->do(q|DELETE FROM categories|);
$dbh->do(q|DELETE FROM accountlines|);
$dbh->do(q|DELETE FROM itemtypes|);
Koha::CirculationRules->search()->delete();

my $builder = t::lib::TestBuilder->new();
t::lib::Mocks::mock_preference('item-level_itypes', 1); # Assuming the item type is defined at item level

my $branch = $builder->build({
    source => 'Branch',
});

my $category = $builder->build({
    source => 'Category',
});

my $patron = $builder->build({
    source => 'Borrower',
    value => {
        categorycode => $category->{categorycode},
        branchcode => $branch->{branchcode},
    },
});

my $biblio = $builder->build({
    source => 'Biblio',
    value => {
        branchcode => $branch->{branchcode},
    },
});
my $item = $builder->build({
    source => 'Item',
    value => {
        biblionumber => $biblio->{biblionumber},
        homebranch => $branch->{branchcode},
        holdingbranch => $branch->{branchcode},
    },
});

my $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );
my $item_object = Koha::Items->find( $item->{itemnumber} );
t::lib::Mocks::mock_userenv( { patron => $patron_object });

# TooMany return ($current_loan_count, $max_loans_allowed) or undef
# CO = Checkout
# OSCO: On-site checkout

subtest 'no rules exist' => sub {
    plan tests => 2;
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        { reason => 'NO_RULE_DEFINED', max_allowed => 0 },
        'CO should not be allowed, in any cases'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        { reason => 'NO_RULE_DEFINED', max_allowed => 0 },
        'OSCO should not be allowed, in any cases'
    );
};

subtest '1 Issuingrule exist 0 0: no issue allowed' => sub {
    plan tests => 4;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => undef,
            rules        => {
                maxissueqty       => 0,
                maxonsiteissueqty => 0,
            }
        },
    );
    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 0,
            max_allowed => 0,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 0,
            max_allowed => 0,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 0,
            max_allowed => 0,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 0,
            max_allowed => 0,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

subtest '1 Issuingrule exist with onsiteissueqty=unlimited' => sub {
    plan tests => 4;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => '*',
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => undef,
            }
        },
    );

    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string() );
    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};


subtest '1 Issuingrule exist 1 1: issue is allowed' => sub {
    plan tests => 4;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => undef,
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );
    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is(
        C4::Circulation::TooMany( $patron, $item_object ),
        undef,
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is(
        C4::Circulation::TooMany( $patron, $item_object ),
        undef,
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        undef,
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

subtest '1 Issuingrule exist: 1 CO allowed, 1 OSCO allowed. Do a CO' => sub {
    plan tests => 5;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => undef,
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );

    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string() );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

subtest '1 Issuingrule exist: 1 CO allowed, 1 OSCO allowed, Do a OSCO' => sub {
    plan tests => 5;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => undef,
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );

    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string(), undef, undef, undef, { onsite_checkout => 1 } );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is(
        C4::Circulation::TooMany( $patron, $item_object ),
        undef,
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

subtest '1 BranchBorrowerCircRule exist: 1 CO allowed, 1 OSCO allowed' => sub {
    # Note: the same test coul be done for
    # DefaultBorrowerCircRule, DefaultBranchCircRule, DefaultBranchItemRule ans DefaultCircRule.pm

    plan tests => 10;
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => undef,
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );

    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string(), undef, undef, undef );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        undef,
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => undef,
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );

    $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string(), undef, undef, undef, { onsite_checkout => 1 } );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is(
        C4::Circulation::TooMany( $patron, $item_object ),
        undef,
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

subtest 'General vs specific rules limit quantity correctly' => sub {
    plan tests => 10;

    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');
    my $branch   = $builder->build({source => 'Branch',});
    my $category = $builder->build({source => 'Category',});
    my $itemtype = $builder->build({
        source => 'Itemtype',
        value => {
            rentalcharge => 0,
            rentalcharge_daily => 0,
            rentalcharge_hourly => 0,
            notforloan => 0,
        }
    });
    my $patron = $builder->build({
        source => 'Borrower',
        value => {
            categorycode => $category->{categorycode},
            branchcode => $branch->{branchcode},
        }
    });

    # Set up an issuing rule
    my $rule = $builder->build({
        source => 'Issuingrule',
        value => {
            categorycode => '*',
            itemtype     => $itemtype->{itemtype},
            branchcode   => '*',
            issuelength  => 1,
            firstremind  => 1,        # 1 day of grace
            finedays     => 2,        # 2 days of fine per day of overdue
            lengthunit   => 'days',
        }
    });

    # Set an All->All for an itemtype
    Koha::CirculationRules->set_rules(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => $itemtype->{itemtype},
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );

    # Create an item
    my $issue_item = $builder->build_sample_item({
        itype => $itemtype->{itemtype}
    });
    my $branch_item = $builder->build_sample_item({
        itype => $itemtype->{itemtype},
        homebranch => $branch->{branchcode},
        holdingbranch => $branch->{branchcode}
    });


    t::lib::Mocks::mock_userenv({ branchcode => $branch->{branchcode} });
    my $issue = C4::Circulation::AddIssue( $patron, $issue_item->barcode, dt_from_string() );
    # We checkout one item
    is_deeply(
        C4::Circulation::TooMany( $patron, $branch_item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'We are only allowed one, and we have one (itemtype on item)'
    );

    # Check itemtype on biblio level
    t::lib::Mocks::mock_preference('item-level_itypes', 0);
    $issue_item->biblio->biblioitem->itemtype($itemtype->{itemtype})->store;
    $branch_item->biblio->biblioitem->itemtype($itemtype->{itemtype})->store;
    # We checkout one item
    is_deeply(
        C4::Circulation::TooMany( $patron, $branch_item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'We are only allowed one, and we have one (itemtype on biblioitem)'
    );
    t::lib::Mocks::mock_preference('item-level_itypes', 1);

    # Set a branch specific rule
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => $itemtype->{itemtype},
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );

    is(
        C4::Circulation::TooMany( $patron, $branch_item ),
        undef,
        'We are allowed one from the branch specifically now'
    );

    # If circcontrol is PatronLibrary we count all the patron's loan, regardless of branch
    t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');
    is_deeply(
        C4::Circulation::TooMany( $patron, $branch_item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'We are allowed one from the branch specifically, but have one'
    );
    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');

    $issue = C4::Circulation::AddIssue( $patron, $branch_item->barcode, dt_from_string() );
    # We issue that one
    # And make another
    my $branch_item_2 = $builder->build_sample_item({
        itype => $itemtype->{itemtype},
        homebranch => $branch->{branchcode},
        holdingbranch => $branch->{branchcode}
    });
    is_deeply(
        C4::Circulation::TooMany( $patron, $branch_item_2 ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'We are only allowed one from that branch, and have one'
    );

    # Now we make anothe from a different branch
    my $item_2 = $builder->build_sample_item({
        itype => $itemtype->{itemtype},
    });
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_2 ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 2,
            max_allowed => 1,
        },
        'We are only allowed one for general rule, and have two'
    );
    t::lib::Mocks::mock_preference('CircControl', 'PatronLibrary');
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_2 ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 2,
            max_allowed => 1,
        },
        'We are only allowed one for general rule, and have two'
    );

    t::lib::Mocks::mock_preference('CircControl', 'PickupLibrary');
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_2 ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 2,
            max_allowed => 1,
        },
        'We are only allowed one for general rule, and have checked out two at this branch'
    );

    my $branch2   = $builder->build({source => 'Branch',});
    t::lib::Mocks::mock_userenv({ branchcode => $branch2->{branchcode} });
    is_deeply(
        C4::Circulation::TooMany( $patron, $item_2 ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 2,
            max_allowed => 1,
        },
        'We are only allowed one for general rule, and have two total (no rule for specific branch)'
    );
    # Set a branch specific rule for new branch
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branch2->{branchcode},
            categorycode => $category->{categorycode},
            itemtype     => $itemtype->{itemtype},
            rules        => {
                maxissueqty       => 1,
                maxonsiteissueqty => 1,
            }
        }
    );

    is(
        C4::Circulation::TooMany( $patron, $branch_item ),
        undef,
        'We are allowed one from the branch specifically now'
    );
};

subtest 'empty string means unlimited' => sub {
    plan tests => 2;

    Koha::CirculationRules->set_rules(
        {
            branchcode   => '*',
            categorycode => '*',
            itemtype     => '*',
            rules        => {
                maxissueqty       => '',
                maxonsiteissueqty => '',
            }
        },
    );
    is(
        C4::Circulation::TooMany( $patron, $item_object ),
        undef,
        'maxissueqty="" should mean unlimited'
    );

    is(
        C4::Circulation::TooMany( $patron, $item_object, { onsite_checkout => 1 } ),
        undef,
        'maxonsiteissueqty="" should mean unlimited'
    );

    teardown();
};

$schema->storage->txn_rollback;

sub teardown {
    $dbh->do(q|DELETE FROM issues|);
    $dbh->do(q|DELETE FROM circulation_rules|);
}

