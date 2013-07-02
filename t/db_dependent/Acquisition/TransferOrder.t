#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 6;
use C4::Context;
use C4::Acquisition;
use C4::Biblio;
use C4::Items;
use C4::Bookseller;
use C4::Budgets;
use MARC::Record;

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $booksellerid1 = C4::Bookseller::AddBookseller(
    {
        name => "my vendor 1",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my $basketno1 = C4::Acquisition::NewBasket(
    $booksellerid1
);

my $booksellerid2 = C4::Bookseller::AddBookseller(
    {
        name => "my vendor 2",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my $basketno2 = C4::Acquisition::NewBasket(
    $booksellerid2
);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_transferorder",
        budget_name => "budget_name_test_transferorder",
    }
);

my $budget = C4::Budgets::GetBudget( $budgetid );

my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');
my $itemnumber = AddItem({}, $biblionumber);

my ( undef, $ordernumber ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno1,
        quantity => 24,
        biblionumber => $biblionumber,
        budget_id => $budget->{budget_id},
    }
);
NewOrderItem($itemnumber, $ordernumber);

# Begin tests
my $order;
is(scalar GetOrders($basketno1), 1, "1 order in basket1");
($order) = GetOrders($basketno1);
is(scalar GetItemnumbersFromOrder($order->{ordernumber}), 1, "1 item in basket1's order");
is(scalar GetOrders($basketno2), 0, "0 order in basket2");

diag("Transfering order to basket2");
my $newordernumber = TransferOrder($ordernumber, $basketno2);
is(scalar GetOrders($basketno1), 0, "0 order in basket1");
is(scalar GetOrders($basketno2), 1, "1 order in basket2");
($order) = GetOrders($basketno2);
is(scalar GetItemnumbersFromOrder($order->{ordernumber}), 1, "1 item in basket2's order");

$dbh->rollback;
