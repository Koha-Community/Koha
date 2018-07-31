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
use Test::More tests => 7;
use C4::Context;

use C4::Members;
use C4::Items;
use C4::Biblio;
use C4::Circulation;
use C4::Context;

use Koha::DateUtils qw( dt_from_string );
use Koha::Database;

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
$dbh->do(q|DELETE FROM branch_item_rules|);
$dbh->do(q|DELETE FROM branch_borrower_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_circ_rules|);
$dbh->do(q|DELETE FROM default_circ_rules|);
$dbh->do(q|DELETE FROM default_branch_item_rules|);
$dbh->do(q|DELETE FROM issuingrules|);

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

C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv($patron->{borrowernumber}, $patron->{userid}, 'usercnum', 'First name', 'Surname', $branch->{branchcode}, 'My Library', 0);

# TooMany return ($current_loan_count, $max_loans_allowed) or undef
# CO = Checkout
# OSCO: On-site checkout

subtest 'no rules exist' => sub {
    plan tests => 2;
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        { reason => 'NO_RULE_DEFINED', max_allowed => 0 },
        'CO should not be allowed, in any cases'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        { reason => 'NO_RULE_DEFINED', max_allowed => 0 },
        'OSCO should not be allowed, in any cases'
    );
};

subtest '1 Issuingrule exist 0 0: no issue allowed' => sub {
    plan tests => 4;
    my $issuingrule = $builder->build({
        source => 'Issuingrule',
        value => {
            branchcode         => $branch->{branchcode},
            categorycode       => $category->{categorycode},
            itemtype           => '*',
            maxissueqty        => 0,
            maxonsiteissueqty  => 0,
        },
    });
    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 0,
            max_allowed => 0,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 0,
            max_allowed => 0,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 0,
            max_allowed => 0,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
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
    my $issuingrule = $builder->build({
        source => 'Issuingrule',
        value => {
            branchcode         => $branch->{branchcode},
            categorycode       => $category->{categorycode},
            itemtype           => '*',
            maxissueqty        => 1,
            maxonsiteissueqty  => undef,
        },
    });
    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string() );
    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
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
    my $issuingrule = $builder->build({
        source => 'Issuingrule',
        value => {
            branchcode         => $branch->{branchcode},
            categorycode       => $category->{categorycode},
            itemtype           => '*',
            maxissueqty        => 1,
            maxonsiteissueqty  => 1,
        },
    });
    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        undef,
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        undef,
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

subtest '1 Issuingrule exist: 1 CO allowed, 1 OSCO allowed. Do a CO' => sub {
    plan tests => 5;
    my $issuingrule = $builder->build({
        source => 'Issuingrule',
        value => {
            branchcode         => $branch->{branchcode},
            categorycode       => $category->{categorycode},
            itemtype           => '*',
            maxissueqty        => 1,
            maxonsiteissueqty  => 1,
        },
    });

    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string() );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
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
    my $issuingrule = $builder->build({
        source => 'Issuingrule',
        value => {
            branchcode         => $branch->{branchcode},
            categorycode       => $category->{categorycode},
            itemtype           => '*',
            maxissueqty        => 1,
            maxonsiteissueqty  => 1,
        },
    });

    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string(), undef, undef, undef, { onsite_checkout => 1 } );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        undef,
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
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
    my $issuingrule = $builder->build({
        source => 'BranchBorrowerCircRule',
        value => {
            branchcode         => $branch->{branchcode},
            categorycode       => $category->{categorycode},
            maxissueqty        => 1,
            maxonsiteissueqty  => 1,
        },
    });

    my $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string(), undef, undef, undef );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();

    $issue = C4::Circulation::AddIssue( $patron, $item->{barcode}, dt_from_string(), undef, undef, undef, { onsite_checkout => 1 } );
    like( $issue->issue_id, qr|^\d+$|, 'The issue should have been inserted' );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 0);
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        undef,
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        {
            reason => 'TOO_MANY_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        {
            reason => 'TOO_MANY_ONSITE_CHECKOUTS',
            count => 1,
            max_allowed => 1,
        },
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

$schema->storage->txn_rollback;

sub teardown {
    $dbh->do(q|DELETE FROM issues|);
    $dbh->do(q|DELETE FROM issuingrules|);
}

