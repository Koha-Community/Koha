#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 6;
use C4::Context;

use C4::Biblio;
use C4::Members;
use C4::Branch;
use C4::Circulation;
use C4::Items;
use C4::Context;

use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;

our $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

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

my $builder = t::lib::TestBuilder->new();

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
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ),
        undef,
        'CO should be allowed, in any cases'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed, in any cases'
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
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 0, 0 ],
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 0, 0 ],
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 0, 0 ],
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 0, 0 ],
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
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 1, 1 ],
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 1, 1 ],
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 1, 1 ],
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
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 1, 1 ],
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 1, 1 ],
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 1, 1 ],
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
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 1, 1 ],
        'CO should be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );
    is(
        C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ),
        undef,
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 1, 1 ],
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 1, 1 ],
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
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 1, 1 ],
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 0'
    );

    t::lib::Mocks::mock_preference('ConsiderOnSiteCheckoutsAsNormalCheckouts', 1);
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item ) ],
        [ 1, 1 ],
        'CO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );
    is_deeply(
        [ C4::Circulation::TooMany( $patron, $biblio->{biblionumber}, $item, { onsite_checkout => 1 } ) ],
        [ 1, 1 ],
        'OSCO should not be allowed if ConsiderOnSiteCheckoutsAsNormalCheckouts == 1'
    );

    teardown();
};

sub teardown {
    $dbh->do(q|DELETE FROM issues|);
    $dbh->do(q|DELETE FROM issuingrules|);
}
