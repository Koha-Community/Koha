use Modern::Perl;

use Test::More tests => 13;

use_ok('C4::Acquisition');
use_ok('C4::Biblio');
use_ok('C4::Bookseller');
use_ok('C4::Budgets');
use_ok('C4::Serials');

use Koha::Acquisition::Order;
use Koha::Database;

# Start transaction
my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

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
    budget_period_startdate   => '01-01-2015',
    budget_period_enddate     => '12-31-2015',
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
    '01-01-2013',undef, undef, undef,  undef,
    undef,      undef,  undef, undef, undef, undef,
    1,          "notes",undef, '01-01-2013', undef, undef,
    undef,       undef,  0,    "intnotes",  0,
    undef, undef, 0,          undef,         '31-12-2013', 0
);
die unless $subscriptionid;

my ($basket, $basketno);
ok($basketno = NewBasket($booksellerid, 1), "NewBasket(  $booksellerid , 1  ) returns $basketno");

my $cost = 42.00;
my $subscription = GetSubscription( $subscriptionid );

my $order = Koha::Acquisition::Order->new({
    biblionumber => $subscription->{biblionumber},
    entrydate => '01-01-2013',
    quantity => 1,
    currency => 'USD',
    listprice => $cost,
    notes => "This is a note",
    basketno => $basketno,
    rrp => $cost,
    ecost => $cost,
    tax_rate => 0.0500,
    orderstatus => 'new',
    subscriptionid => $subscription->{subscriptionid},
    budget_id => $budget_id,
})->insert;
my $ordernumber = $order->{ordernumber};

my $is_currently_on_order = subscriptionCurrentlyOnOrder( $subscription->{subscriptionid} );
is ( $is_currently_on_order, 1, "The subscription is currently on order");

$order = GetLastOrderNotReceivedFromSubscriptionid( $subscription->{subscriptionid} );
is ( $order->{subscriptionid}, $subscription->{subscriptionid}, "test subscriptionid for the last order not received");
ok( $order->{ecost} == $cost, "test cost for the last order not received");

$dbh->do(q{DELETE FROM aqinvoices});
my $invoiceid = AddInvoice(invoicenumber => 'invoice1', booksellerid => $booksellerid, unknown => "unknown");

my $invoice = GetInvoice( $invoiceid );
$invoice->{datereceived} = '02-01-2013';

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
