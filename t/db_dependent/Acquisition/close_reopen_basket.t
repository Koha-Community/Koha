#!/usr/bin/env perl

use Modern::Perl;

use Test::More tests => 14;
use C4::Acquisition;
use C4::Biblio qw( AddBiblio DelBiblio );
use C4::Bookseller;
use C4::Budgets;
use C4::Context;
use Koha::Database;
use Koha::Acquisition::Order;

# Start transaction
my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do(q{
    DELETE FROM aqorders;
});

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my $basketno = C4::Acquisition::NewBasket(
    $booksellerid
);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_close_reopen",
        budget_name => "budget_name_test_close_reopen",
    }
);

my $budget = C4::Budgets::GetBudget( $budgetid );

my ($biblionumber1, $biblioitemnumber1) = AddBiblio(MARC::Record->new, '');
my ($biblionumber2, $biblioitemnumber2) = AddBiblio(MARC::Record->new, '');

my $order1 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 24,
        biblionumber => $biblionumber1,
        budget_id => $budget->{budget_id},
    }
)->insert;
my $ordernumber1 = $order1->{ordernumber};

my $order2 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 42,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
    }
)->insert;
my $ordernumber2 = $order2->{ordernumber};

my $nb_biblio = C4::Acquisition::GetBiblioCountByBasketno( $basketno );
is ( $nb_biblio, 2, "There are 2 biblio for this basket" );
my @orders = C4::Acquisition::GetOrders( $basketno );
is( scalar(@orders), 2, "2 orders are created" );
is ( scalar( map { $_->{orderstatus} eq 'new' ? 1 : () } @orders ), 2, "2 orders are new before closing the basket" );

C4::Acquisition::CloseBasket( $basketno );
@orders = C4::Acquisition::GetOrders( $basketno );
is ( scalar( map { $_->{orderstatus} eq 'ordered' ? 1 : () } @orders ), 2, "2 orders are ordered, the basket is closed" );

C4::Acquisition::ReopenBasket( $basketno );
@orders = C4::Acquisition::GetOrders( $basketno );
is ( scalar( map { $_->{orderstatus} eq 'ordered' ? 1 : () } @orders ), 0, "No order is ordered, the basket is reopened" );
is ( scalar( map { $_->{orderstatus} eq 'new' ? 1 : () } @orders ), 2, "2 orders are new, the basket is reopened" );

C4::Acquisition::DelOrder( $biblionumber1, $ordernumber1 );
my ( $order ) = C4::Acquisition::GetOrders( $basketno, {cancelled => 1} );
is( $order->{ordernumber}, $ordernumber1, 'The order returned by GetOrders should have been the right one' );
is( $order->{orderstatus}, 'cancelled', 'DelOrder should have set status to cancelled' );

C4::Acquisition::CloseBasket( $basketno );
( $order ) = C4::Acquisition::GetOrders( $basketno, {cancelled => 1} );
is( $order->{ordernumber}, $ordernumber1, 'The order returned by GetOrders should have been the right one' );
is( $order->{orderstatus}, 'cancelled', 'CloseBasket should not reset the status to ordered for cancelled orders' );

C4::Acquisition::ReopenBasket( $basketno );
( $order ) = C4::Acquisition::GetOrders( $basketno, {cancelled => 1} );
is( $order->{ordernumber}, $ordernumber1, 'The expected order is cancelled, the basket is reopened' );
is( $order->{orderstatus}, 'cancelled', 'ReopenBasket should not reset the status for cancelled orders' );

( $order ) = C4::Acquisition::GetOrders( $basketno, { cancelled => 0 } );
is ( $order->{ordernumber}, $ordernumber2, "The expect order is not cancelled, the basket is reopened" );
is ( $order->{orderstatus}, 'new', 'The expected order is new, the basket is reopened' );

$schema->storage->txn_rollback();
