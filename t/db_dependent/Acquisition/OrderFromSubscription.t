use Modern::Perl;

use Test::More tests => 12;
use Data::Dumper;

use_ok('C4::Acquisition');
use_ok('C4::Biblio');
use_ok('C4::Budgets');
use_ok('C4::Serials');

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $supplierlist=eval{GetSuppliersWithLateIssues()};
ok(length($@)==0,"No SQL problem in GetSuppliersWithLateIssues");

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');
my $budgetid;
my $bpid = AddBudgetPeriod({
    budget_period_startdate => '01-01-2015',
    budget_period_enddate   => '12-31-2015',
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

my ($basket, $basketno);
ok($basketno = NewBasket($booksellerid, 1), "NewBasket(  $booksellerid , 1  ) returns $basketno");

my $cost = 42.00;
my $subscription = GetSubscription( $subscriptionid );
my $ordernumber;
( $basketno, $ordernumber ) = NewOrder({
    biblionumber => $subscription->{biblionumber},
    entrydate => '01-01-2013',
    quantity => 1,
    currency => 'USD',
    listprice => $cost,
    notes => "This is a note",
    basketno => $basketno,
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

# Cleanup
$dbh->rollback;
