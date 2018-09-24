#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 40;
use Data::Dumper;

use C4::Acquisition qw( NewBasket GetBasketsInfosByBookseller );
use C4::Biblio qw( AddBiblio );
use C4::Budgets qw( AddBudget );
use C4::Context;
use Koha::Database;
use Koha::Acquisition::Orders;

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $supplier = Koha::Acquisition::Bookseller->new(
    {
        name => 'my vendor',
        address1 => 'bookseller\'s address',
        phone => '0123456',
        active => 1,
        deliverytime => 5,
    }
)->store;
my $supplierid = $supplier->id;

my $basketno;
ok($basketno = NewBasket($supplierid, 1), 'NewBasket(  $supplierid , 1  ) returns $basketno');

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => 'budget_code_test_1',
        budget_name => 'budget_name_test_1',
    }
);
my $budget = C4::Budgets::GetBudget( $budgetid );

my ($biblionumber1, $biblioitemnumber1) = AddBiblio(MARC::Record->new, '');
my ($biblionumber2, $biblioitemnumber2) = AddBiblio(MARC::Record->new, '');
my ($biblionumber3, $biblioitemnumber3) = AddBiblio(MARC::Record->new, '');

my $order1 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 2,
        biblionumber => $biblionumber1,
        budget_id => $budget->{budget_id},
    }
)->store;
my $ordernumber1 = $order1->ordernumber;

my $order2 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 4,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
    }
)->store;
my $ordernumber2 = $order2->ordernumber;

my $baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid );
is( scalar(@$baskets), 1, 'Start: 1 basket' );
my $basket = $baskets->[0];
is( $basket->{total_items}, 6, 'Start with 6 items' );
is( $basket->{total_biblios}, 2, 'Start with 2 biblios' );
is( $basket->{total_items_cancelled}, 0, 'Start with 0 item cancelled' );
is( $basket->{expected_items}, 6, 'Start with 6 items expected' );
is( $basket->{total_biblios_cancelled}, 0, 'Start with 0 biblio cancelled' );

C4::Acquisition::DelOrder( $biblionumber2, $ordernumber2 );
$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid );
is( scalar(@$baskets), 1, 'Order2 deleted, still 1 basket' );
$basket = $baskets->[0];
is( $basket->{total_items}, 6, 'Order2 deleted, still 6 items' );
is( $basket->{total_biblios}, 2, 'Order2 deleted, still 2 biblios' );
is( $basket->{total_items_cancelled}, 4, 'Order2 deleted, 4 items cancelled' );
is( $basket->{expected_items}, 2, 'Order2 deleted, now 2 items are expected' );
is( $basket->{total_biblios_cancelled}, 1, 'Order2 deleted, 1 biblios cancelled' );

C4::Acquisition::DelOrder( $biblionumber1, $ordernumber1 );
$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid );
is( scalar(@$baskets), 1, 'Both orders deleted, still 1 basket' );
$basket = $baskets->[0];
is( $basket->{total_items}, 6, 'Both orders deleted, still 6 items' );
is( $basket->{total_biblios}, 2, 'Both orders deleted, still 2 biblios' );
is( $basket->{total_items_cancelled}, 6, 'Both orders deleted, 6 items cancelled' );
is( $basket->{expected_items}, 0, 'Both orders delete, now 0 items are expected' );
is( $basket->{total_biblios_cancelled}, 2, 'Both orders deleted, 2 biblios cancelled' );

C4::Acquisition::CloseBasket( $basketno );
$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid );
is( scalar(@$baskets), 0, 'Basket is closed, 0 basket opened' );
$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid, 1 );
is( scalar(@$baskets), 1, 'Basket is closed, test allbasket parameter');

C4::Acquisition::ReopenBasket( $basketno );
my $order3 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 4,
        biblionumber => $biblionumber3,
        budget_id => $budget->{budget_id},
    }
)->store;
my $ordernumber3 = $order3->ordernumber;

C4::Acquisition::CloseBasket( $basketno );
$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid );
is( scalar(@$baskets), 1, 'Basket is closed and has items to receive' );
$basket = $baskets->[0];
is( $basket->{total_items}, 10, '2 orders deleted, 1 order pending, 10 items total' );
is( $basket->{total_biblios}, 3, '2 orders deleted, 1 order pending, 3 biblios total' );
is( $basket->{total_items_cancelled}, 6, '2 orders deleted, 1 order pending, still 6 items cancelled' );
is( $basket->{expected_items}, 4, '2 orders delete, 1 order pending, 4 items are expected' );
is( $basket->{total_biblios_cancelled}, 2, '2 orders deleted, 1 order pending, still 2 biblios cancelled' );

my $invoiceid1 = C4::Acquisition::AddInvoice(invoicenumber => 'invoice1', booksellerid => $supplierid, unknown => "unknown");
my $invoice1 = C4::Acquisition::GetInvoice( $invoiceid1 );
my ( $date_received, $ordernumber4 ) = C4::Acquisition::ModReceiveOrder(
    {
        biblionumber         => $biblionumber3,
        order                => $order3->unblessed,
        quantityreceived     => 2,
        budget_id            => $budget->{budget_id},
        invoice              => $invoice1,
    }
);
$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid );
is( scalar(@$baskets), 1, 'Basket is closed and still has items to receive' );
$basket = $baskets->[0];
is( $basket->{total_items}, 10, '2 orders deleted, 1 order pending, 10 items total' );
is( $basket->{total_biblios}, 3, '2 orders deleted, 1 order pending, 3 biblios total' );
is( $basket->{total_items_cancelled}, 6, '2 orders deleted, 1 order pending, still 6 items cancelled' );
is( $basket->{expected_items}, 2, '2 orders delete, 1 order pending, 2 items are expected' );
is( $basket->{total_biblios_cancelled}, 2, '2 orders deleted, 1 order pending, still 2 biblios cancelled' );

my $invoiceid2 = C4::Acquisition::AddInvoice(invoicenumber => 'invoice1', booksellerid => $supplierid, unknown => "unknown");
my $invoice2 = C4::Acquisition::GetInvoice( $invoiceid2 );
my ( $date_received2, $ordernumber5 ) = C4::Acquisition::ModReceiveOrder(
    {
        biblionumber         => $biblionumber3,
        order                => $order3->get_from_storage->unblessed,
        quantityreceived     => 2,
        budget_id            => $budget->{budget_id},
        invoice              => $invoice2,
    }
);
$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid, 1 );
is( scalar(@$baskets), 1, 'Basket is closed and has no items to receive, test allbasket parameter');
$basket = $baskets->[0];
is( $basket->{total_items}, 10, 'Basket is closed and has no items to receive, still 10 items total' );
is( $basket->{total_biblios}, 3, 'Basket is closed and has no items to receive, still 3 biblios total' );
is( $basket->{total_items_cancelled}, 6, 'Basket is closed and has no items to receive, still 6 items cancelled' );
is( $basket->{expected_items}, 0, 'Basket is closed and has no items to receive, 0 items are expected' );
is( $basket->{total_biblios_cancelled}, 2, 'Basket is closed and has no items to receive, still 2 biblios cancelled' );

$baskets = C4::Acquisition::GetBasketsInfosByBookseller( $supplierid );
is( scalar(@$baskets), 0, 'Basket is closed and has no items to receive' );

$schema->storage->txn_rollback();
