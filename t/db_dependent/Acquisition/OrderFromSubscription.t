use Modern::Perl;

use Test::More tests => 12;

use t::lib::TestBuilder;

use_ok('C4::Acquisition');
use_ok('C4::Biblio');
use_ok('C4::Budgets');
use_ok('C4::Serials');

use Koha::Acquisition::Orders;
use Koha::Database;

# Start transaction
my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $curcode = $builder->build({ source => 'Currency' })->{currencycode};

my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
)->store;

my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');
my $budgetid;
my $bpid = AddBudgetPeriod({
    budget_period_startdate   => '2015-01-01',
    budget_period_enddate     => '2015-12-31',
    budget_period_description => "budget desc"
});

my $budget_id = AddBudget({
    budget_code        => "ABCD",
    budget_amount      => "123.132",
    budget_name        => "Périodiques",
    budget_notes       => "This is a note",
    budget_period_id   => $bpid
});

my $subscriptionid = NewSubscription(
    undef,      "",     undef, undef, $budget_id, $biblionumber,
    '2013-01-01',undef, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "notes",undef, '2013-01-01', undef, undef,
    undef,       undef,  0,    "intnotes",  0,
    undef, undef, 0,          undef,         '2013-12-31', 0
);
die unless $subscriptionid;

my ($basket, $basketno);
ok($basketno = NewBasket($bookseller->id, 1), "NewBasket(  " . $bookseller->id . ", 1  ) returns $basketno");

my $cost = 42.00;
my $subscription = GetSubscription( $subscriptionid );

my $order = Koha::Acquisition::Order->new({
    biblionumber => $subscription->{biblionumber},
    entrydate => '2013-01-01',
    quantity => 1,
    currency => $curcode,
    listprice => $cost,
    basketno => $basketno,
    rrp => $cost,
    ecost => $cost,
    orderstatus => 'new',
    subscriptionid => $subscription->{subscriptionid},
    budget_id => $budget_id,
})->store;
my $ordernumber = $order->ordernumber;

my $is_currently_on_order = subscriptionCurrentlyOnOrder( $subscription->{subscriptionid} );
is ( $is_currently_on_order, 1, "The subscription is currently on order");

$order = GetLastOrderNotReceivedFromSubscriptionid( $subscription->{subscriptionid} );
is ( $order->{subscriptionid}, $subscription->{subscriptionid}, "test subscriptionid for the last order not received");
ok( $order->{ecost} == $cost, "test cost for the last order not received");

$dbh->do(q{DELETE FROM aqinvoices});
my $invoiceid = AddInvoice(invoicenumber => 'invoice1', booksellerid => $bookseller->id, unknown => "unknown");

my $invoice = GetInvoice( $invoiceid );
$invoice->{datereceived} = '2013-01-02';

my ( $datereceived, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber,
        order            => $order,
        quantityreceived => 1,
        budget_id        => $budget_id,
        invoice          => $invoice,
    }
);

$order = GetLastOrderReceivedFromSubscriptionid( $subscription->{subscriptionid} );
is ( $order->{subscriptionid}, $subscription->{subscriptionid}, "test subscriptionid for the last order received");
ok( $order->{ecost} == $cost, "test cost for the last order received");

$order = GetLastOrderNotReceivedFromSubscriptionid( $subscription->{subscriptionid} );
is ( $order, undef, "test no not received order for a received order");

my @invoices = GetInvoices();
my @invoices_linked_to_subscriptions = grep { $_->{is_linked_to_subscriptions} } @invoices;
is(scalar(@invoices_linked_to_subscriptions), 1, 'GetInvoices() can identify invoices that are linked to a subscription');

# Cleanup
$schema->storage->txn_rollback();
