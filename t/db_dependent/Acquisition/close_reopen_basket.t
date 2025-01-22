#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 15;
use C4::Acquisition qw( NewBasket GetBiblioCountByBasketno GetOrders GetOrder ReopenBasket );
use C4::Biblio      qw( AddBiblio );
use C4::Budgets     qw( AddBudget GetBudget );
use C4::Context;
use Koha::Database;
use Koha::Acquisition::Booksellers;
use Koha::Acquisition::Orders;

# Start transaction
my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $dbh = C4::Context->dbh;

$dbh->do(
    q{
    DELETE FROM aqorders;
}
);

my $bookseller = Koha::Acquisition::Bookseller->new(
    {
        name     => "my vendor",
        address1 => "bookseller's address",
        phone    => "0123456",
        active   => 1
    }
)->store;

my $basketno = C4::Acquisition::NewBasket( $bookseller->id );

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
        budget_code      => "budget_code_test_close_reopen",
        budget_name      => "budget_name_test_close_reopen",
        budget_period_id => $budget_period_id,
    }
);

my $budget = C4::Budgets::GetBudget($budgetid);

my ( $biblionumber1, $biblioitemnumber1 ) = AddBiblio( MARC::Record->new, '' );
my ( $biblionumber2, $biblioitemnumber2 ) = AddBiblio( MARC::Record->new, '' );

my $order1 = Koha::Acquisition::Order->new(
    {
        basketno     => $basketno,
        quantity     => 24,
        biblionumber => $biblionumber1,
        budget_id    => $budget->{budget_id},
    }
)->store;
my $ordernumber1 = $order1->ordernumber;

my $order2 = Koha::Acquisition::Order->new(
    {
        basketno     => $basketno,
        quantity     => 42,
        biblionumber => $biblionumber2,
        budget_id    => $budget->{budget_id},
    }
)->store;
my $ordernumber2 = $order2->ordernumber;

my $nb_biblio = C4::Acquisition::GetBiblioCountByBasketno($basketno);
is( $nb_biblio, 2, "There are 2 biblio for this basket" );
my @orders = C4::Acquisition::GetOrders($basketno);
is( scalar(@orders),                                               2, "2 orders are created" );
is( scalar( map { $_->{orderstatus} eq 'new' ? 1 : () } @orders ), 2, "2 orders are new before closing the basket" );

Koha::Acquisition::Baskets->find($basketno)->close;
@orders = C4::Acquisition::GetOrders($basketno);
is(
    scalar( map { $_->{orderstatus} eq 'ordered' ? 1 : () } @orders ), 2,
    "2 orders are ordered, the basket is closed"
);

C4::Acquisition::ReopenBasket($basketno);
@orders = C4::Acquisition::GetOrders($basketno);
is(
    scalar( map { $_->{orderstatus} eq 'ordered' ? 1 : () } @orders ), 0,
    "No order is ordered, the basket is reopened"
);
is( scalar( map { $_->{orderstatus} eq 'new' ? 1 : () } @orders ), 2, "2 orders are new, the basket is reopened" );

Koha::Acquisition::Orders->find($ordernumber1)->cancel;
my ($order) = C4::Acquisition::GetOrders( $basketno, { cancelled => 1 } );
is( $order->{ordernumber}, $ordernumber1, 'The order returned by GetOrders should have been the right one' );
is( $order->{orderstatus}, 'cancelled',   'cancelling the order should have set status to cancelled' );

Koha::Acquisition::Baskets->find($basketno)->close;
($order) = C4::Acquisition::GetOrders( $basketno, { cancelled => 1 } );
is( $order->{ordernumber}, $ordernumber1, 'The order returned by GetOrders should have been the right one' );
is( $order->{orderstatus}, 'cancelled', '$basket->close should not reset the status to ordered for cancelled orders' );

C4::Acquisition::ReopenBasket($basketno);
($order) = C4::Acquisition::GetOrders( $basketno, { cancelled => 1 } );
is( $order->{ordernumber}, $ordernumber1, 'The expected order is cancelled, the basket is reopened' );
is( $order->{orderstatus}, 'cancelled',   'ReopenBasket should not reset the status for cancelled orders' );

($order) = C4::Acquisition::GetOrders( $basketno, { cancelled => 0 } );
is( $order->{ordernumber}, $ordernumber2, "The expect order is not cancelled, the basket is reopened" );
is( $order->{orderstatus}, 'new',         'The expected order is new, the basket is reopened' );

$schema->storage->txn_rollback();
