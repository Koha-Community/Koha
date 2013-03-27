#!/usr/bin/perl
use Modern::Perl;

use Test::More tests => 4;

use_ok('C4::Serials');
use_ok('C4::Budgets');

my $supplierlist=eval{GetSuppliersWithLateIssues()};
ok(length($@)==0,"No SQL problem in GetSuppliersWithLateIssues");

my $biblionumber = 1;
my $budgetid;
my $bpid = AddBudgetPeriod({
    budget_period_startdate => '01-01-2015',
    budget_period_enddate   => '31-12-2015',
    budget_description      => "budget desc"
});

my $budget_id = AddBudget({
    budget_code        => "ABCD",
    budget_amount      => "123.132",
    budget_name        => "Périodiques",
    budget_notes       => "This is a note",
    budget_description => "Serials",
    budget_active      => 1,
    budget_period_id   => $bpid
});

my $subscriptionid = NewSubscription(
    undef,      "",     undef, undef, $budget_id, $biblionumber, '01-01-2013',undef,
    undef,      undef,  undef, undef, undef,      undef,         undef,  undef,
    undef,      undef,  undef, undef, undef,      undef,         undef,  undef,
    undef,      undef,  undef, undef, undef,      undef,         undef,  1,
    "notes",    undef,  undef, undef, undef,      undef,         undef,  0,
    "intnotes", 0,      undef, undef, 0,          undef,         '31-12-2013',
);
die unless $subscriptionid;

# Can edit a subscription
my @USERENV = (
    1,
    'test',
    'MASTERTEST',
    'Test',
    'Test',
    't',
    0,
    0,
);

C4::Context->_new_userenv ('DUMMY_SESSION_ID');
C4::Context->set_userenv ( @USERENV );
my $userenv = C4::Context->userenv;

my $subscription = GetSubscription( $subscriptionid );

is( C4::Serials::can_edit_subscription($subscription), 1, "User can edit a subscription with an empty branchcode");
#TODO add UT when C4::Auth->set_permissions (or setuserflags) will exist.


# cleaning
DelSubscription( $subscription->{subscriptionid} );
DelBudgetPeriod($bpid);
DelBudget($budget_id);
