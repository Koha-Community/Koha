use Modern::Perl;
use Test::More tests => 3;

use C4::Acquisition;
use C4::Biblio;
use C4::Bookseller;
use C4::Letters;
use Koha::Database;
use Koha::Acquisition::Order;

use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({
    source => "Branch",
});

# Creating some orders
my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name         => "my vendor",
        address1     => "bookseller's address",
        phone        => "0123456",
        active       => 1,
    }
);

my $basketno = NewBasket( $booksellerid, 1 );

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_getordersbybib",
        budget_name => "budget_name_test_getordersbybib",
    }
);
my $budget = C4::Budgets::GetBudget($budgetid);

my @ordernumbers;
my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( MARC::Record->new, '' );

my $ordernumber;
$ordernumber = Koha::Acquisition::Order->new(
    {
        basketno         => $basketno,
        quantity         => 2,
        biblionumber     => $biblionumber,
        budget_id        => $budgetid,
        entrydate        => '01-01-2014',
        currency         => 'EUR',
        notes            => "This is a note1",
        gstrate          => 0.0500,
        orderstatus      => 1,
        quantityreceived => 0,
        rrp              => 10,
        ecost            => 10,
    }
)->insert->{ordernumber};

my $invoiceid = AddInvoice(
    invoicenumber => 'invoice',
    booksellerid  => $booksellerid,
    unknown       => "unknown"
);

my $borrowernumber = C4::Members::AddMember(
    cardnumber => 'TESTCARD',
    firstname =>  'TESTFN',
    surname => 'TESTSN',
    categorycode => 'S',
    branchcode => $library->{branchcode},
    dateofbirth => '',
    dateexpiry => '9999-12-31',
    userid => 'TESTUSERID'
);

my $borrower = C4::Members::GetMemberDetails( $borrowernumber );

C4::Acquisition::ModOrderUsers( $ordernumber, $borrowernumber );

my $is_added = grep { /^$borrowernumber$/ } C4::Acquisition::GetOrderUsers( $ordernumber );
is( $is_added, 1, 'ModOrderUsers should link patrons to an order' );

ModReceiveOrder(
    {
        biblionumber      => $biblionumber,
        ordernumber       => $ordernumber,
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

ModReceiveOrder(
    {
        biblionumber      => $biblionumber,
        ordernumber       => $ordernumber,
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
