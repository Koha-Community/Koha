use Modern::Perl;
use Test::More tests => 3;

use C4::Acquisition;
use C4::Biblio;
use C4::Letters;
use Koha::Database;
use Koha::Acquisition::Order;
use Koha::Acquisition::Booksellers;

use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({
    source => "Branch",
});
my $patron_category = $builder->build({ source => 'Category' });
my $currency = $builder->build({ source => 'Currency' });

# Creating some orders
my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name         => "my vendor",
        address1     => "bookseller's address",
        phone        => "0123456",
        active       => 1,
    }
)->store;

my $basketno = NewBasket( $bookseller->id, 1 );

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_getordersbybib",
        budget_name => "budget_name_test_getordersbybib",
    }
);
my $budget = C4::Budgets::GetBudget($budgetid);

my @ordernumbers;
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( MARC::Record->new, '' );

my $order = Koha::Acquisition::Order->new(
    {
        basketno         => $basketno,
        quantity         => 2,
        biblionumber     => $biblionumber,
        budget_id        => $budgetid,
        entrydate        => '01-01-2014',
        currency         => $currency->{currency},
        notes            => "This is a note1",
        orderstatus      => 1,
        quantityreceived => 0,
        rrp              => 10,
        ecost            => 10,
    }
)->insert;
my $ordernumber = $order->{ordernumber};

my $invoiceid = AddInvoice(
    invoicenumber => 'invoice',
    booksellerid  => $bookseller->id,
    unknown       => "unknown"
);

my $borrowernumber = C4::Members::AddMember(
    cardnumber => 'TESTCARD',
    firstname =>  'TESTFN',
    surname => 'TESTSN',
    categorycode => $patron_category->{categorycode},
    branchcode => $library->{branchcode},
    dateofbirth => '',
    dateexpiry => '9999-12-31',
    userid => 'TESTUSERID'
);

C4::Acquisition::ModOrderUsers( $ordernumber, $borrowernumber );

my $is_added = grep { /^$borrowernumber$/ } C4::Acquisition::GetOrderUsers( $ordernumber );
is( $is_added, 1, 'ModOrderUsers should link patrons to an order' );

$order = Koha::Acquisition::Order->fetch({ ordernumber => $ordernumber });
ModReceiveOrder(
    {
        biblionumber      => $biblionumber,
        order             => $order,
        quantityreceived  => 1,
        cost              => 10,
        ecost             => 10,
        invoiceid         => $invoiceid,
        rrp               => 10,
        budget_id         => $budgetid,
    }
);

my $messages = C4::Letters::GetQueuedMessages({ borrowernumber => $borrowernumber });
is( scalar( @$messages ), 0, 'The letter has not been sent to message queue on receiving the order, the order is not entire received');

$order = Koha::Acquisition::Order->fetch({ ordernumber => $ordernumber });
ModReceiveOrder(
    {
        biblionumber      => $biblionumber,
        order             => $order,
        quantityreceived  => 1,
        cost              => 10,
        ecost             => 10,
        invoiceid         => $invoiceid,
        rrp               => 10,
        budget_id         => $budgetid,
    }
);

$messages = C4::Letters::GetQueuedMessages({ borrowernumber => $borrowernumber });
is( scalar( @$messages ), 1, 'The letter has been sent to message queue on receiving the order');
