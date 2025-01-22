use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 4;

use C4::Acquisition qw( NewBasket AddInvoice ModOrder ModOrderUsers GetOrder GetOrderUsers ModReceiveOrder );
use C4::Biblio      qw( AddBiblio );
use C4::Letters     qw( GetQueuedMessages );
use Koha::Database;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;
use Koha::Patrons;

use t::lib::TestBuilder;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build(
    {
        source => "Branch",
    }
);
my $patron_category = $builder->build( { source => 'Category' } );
my $currency        = $builder->build( { source => 'Currency' } );

# Creating some orders
my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name     => "my vendor",
        address1 => "bookseller's address",
        phone    => "0123456",
        active   => 1,
    }
)->store;

my $basketno = NewBasket( $bookseller->id, 1 );

my $budget_period_id = C4::Budgets::AddBudgetPeriod(
    {
        budget_period_startdate   => '2024-01-01',
        budget_period_enddate     => '2049-01-01',
        budget_period_active      => 1,
        budget_period_description => "TEST PERIOD"
    }
);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code      => "budget_code_test",
        budget_name      => "budget_name_test",
        budget_period_id => $budget_period_id,
    }
);
my $budget = C4::Budgets::GetBudget($budgetid);

my ( $biblionumber, $biblioitemnumber ) = C4::Biblio::AddBiblio( MARC::Record->new, '' );

my $order = Koha::Acquisition::Order->new(
    {
        basketno         => $basketno,
        quantity         => 2,
        biblionumber     => $biblionumber,
        budget_id        => $budgetid,
        entrydate        => '2014-01-01',
        currency         => $currency->{currency},
        orderstatus      => 1,
        quantityreceived => 0,
        rrp              => 10,
        ecost            => 10,
    }
)->store;
my $ordernumber = $order->ordernumber;

my $invoiceid = AddInvoice(
    invoicenumber => 'invoice',
    booksellerid  => $bookseller->id,
    unknown       => "unknown"
);

my $borrowernumber = Koha::Patron->new(
    {
        cardnumber   => 'TESTCARD',
        firstname    => 'TESTFN',
        surname      => 'TESTSN',
        categorycode => $patron_category->{categorycode},
        branchcode   => $library->{branchcode},
        dateofbirth  => '',
        dateexpiry   => '9999-12-31',
        userid       => 'TESTUSERID'
    }
)->store->borrowernumber;

C4::Acquisition::ModOrderUsers( $ordernumber, $borrowernumber );

my $is_added = grep { /^$borrowernumber$/ } C4::Acquisition::GetOrderUsers($ordernumber);
is( $is_added, 1, 'ModOrderUsers should link patrons to an order' );

$order = Koha::Acquisition::Orders->find($ordernumber);
ModReceiveOrder(
    {
        biblionumber     => $biblionumber,
        order            => $order->unblessed,
        quantityreceived => 1,
        cost             => 10,
        ecost            => 10,
        invoiceid        => $invoiceid,
        rrp              => 10,
        budget_id        => $budgetid,
    }
);

my $messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber } );
is(
    scalar(@$messages), 0,
    'The letter has not been sent to message queue on receiving the order, the order is not entire received'
);

$order = Koha::Acquisition::Orders->find($ordernumber);
ModReceiveOrder(
    {
        biblionumber     => $biblionumber,
        order            => $order->unblessed,
        quantityreceived => 1,
        cost             => 10,
        ecost            => 10,
        invoiceid        => $invoiceid,
        rrp              => 10,
        budget_id        => $budgetid,
    }
);

$messages = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber } );
is( scalar(@$messages), 1, 'The letter has been sent to message queue on receiving the order' );
