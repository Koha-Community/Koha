#!/usr/bin/perl

use Modern::Perl;

use Test::More;
use C4::Acquisition;
use C4::Biblio;
use C4::Bookseller;
use C4::Budgets;
use Koha::Database;
use Koha::Acquisition::Order;

use MARC::Record;

#Start transaction
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

my $basketno = C4::Acquisition::NewBasket(
    $booksellerid
);

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_getordersbybib",
        budget_name => "budget_name_test_getordersbybib",
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
my $ordernumber2 = $order1->{ordernumber};

my $order3 = Koha::Acquisition::Order->new(
    {
        basketno => $basketno,
        quantity => 4,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
    }
)->insert;
my $ordernumber3 = $order1->{ordernumber};

my @orders = GetOrdersByBiblionumber();
is(scalar(@orders), 0, 'GetOrdersByBiblionumber : no argument, return undef');

@orders = GetOrdersByBiblionumber( $biblionumber1 );
is(scalar(@orders), 1, '1 order on biblionumber 1');

@orders = GetOrdersByBiblionumber( $biblionumber2 );
is(scalar(@orders), 2, '2 orders on biblionumber 2');

#End transaction
$schema->storage->txn_rollback();

done_testing;
