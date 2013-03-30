use Modern::Perl;

use Test::More tests => 10;
use Data::Dumper;

use_ok('C4::Serials');
use_ok('C4::Budgets');
use_ok('C4::Acquisition');
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
my $cost = 42.00;
my $subscription = GetSubscription( $subscriptionid );
my ( $basketno, $ordernumber ) = NewOrder({
    biblionumber => $subscription->{biblionumber},
    entrydate => '01-01-2013',
    quantity => 1,
    currency => 'USD',
    listprice => $cost,
    notes => "This is a note",
    basketno => 1,
    rrp => $cost,
    ecost => $cost,
    gstrate => 0.0500,
    orderstatus => 0,
    subscriptionid => $subscription->{subscriptionid},
    budget_id => $budget_id,
});

my $is_currently_on_order = subscriptionCurrentlyOnOrder( $subscription->{subscriptionid} );
is ( $is_currently_on_order, 1, "The subscription is currently on order");

my $order = GetLastOrderNotReceivedFromSubscriptionid( $subscription->{subscriptionid} );
is ( $order->{subscriptionid}, $subscription->{subscriptionid}, "test subscriptionid for the last order not received");
ok( $order->{ecost} == $cost, "test cost for the last order not received");

my ( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    $biblionumber, $ordernumber, 1, undef, $cost, $cost,
    undef, $cost, $budget_id, '02-01-2013', undef);

$order = GetLastOrderReceivedFromSubscriptionid( $subscription->{subscriptionid} );
is ( $order->{subscriptionid}, $subscription->{subscriptionid}, "test subscriptionid for the last order received");
ok( $order->{ecost} == $cost, "test cost for the last order received");

$order = GetLastOrderNotReceivedFromSubscriptionid( $subscription->{subscriptionid} );
is ( $order, undef, "test no not received order for a received order");

# cleaning
DelSubscription( $subscription->{subscriptionid} );
DelOrder( $subscription->{biblionumber}, $ordernumber );
DelBudgetPeriod($bpid);
DelBudget($budget_id);
