#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 4;
use C4::Context;
use C4::Acquisition;
use C4::Biblio;
use C4::Items;
use C4::Bookseller;
use C4::Budgets;
use t::lib::Mocks;

use Koha::DateUtils;
use Koha::Acquisition::Order;
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

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_transferorder",
        budget_name => "budget_name_test_transferorder",
    }
);

my $budget = C4::Budgets::GetBudget( $budgetid );

my ($biblionumber, $biblioitemnumber) = AddBiblio(MARC::Record->new, '');
my $itemnumber = AddItem({}, $biblionumber);

t::lib::Mocks::mock_preference('AcqCreateItem', 'receiving');
my $order = Koha::Acquisition::Order->new(
    {
        basketno => $basketno1,
        quantity => 2,
        biblionumber => $biblionumber,
        budget_id => $budget->{budget_id},
    }
)->insert;
my $ordernumber = $order->{ordernumber};

ModReceiveOrder(
    {
        biblionumber     => $biblionumber,
        ordernumber      => $ordernumber,
        quantityreceived => 2,
        datereceived     => dt_from_string
    }
);

$order->add_item( $itemnumber );

CancelReceipt($ordernumber);

$order = GetOrder( $ordernumber );
is(scalar GetItemnumbersFromOrder($order->{ordernumber}), 0, "Create items on receiving: 0 item exist after cancelling a receipt");

my $itemnumber1 = AddItem({}, $biblionumber);
my $itemnumber2 = AddItem({}, $biblionumber);
t::lib::Mocks::mock_preference('AcqCreateItem', 'ordering');
t::lib::Mocks::mock_preference('AcqItemSetSubfieldsWhenReceiptIsCancelled', '7=9'); # notforloan is mapped with 952$7
$order = Koha::Acquisition::Order->new(
    {
        basketno => $basketno1,
        quantity => 2,
        biblionumber => $biblionumber,
        budget_id => $budget->{budget_id},
    }
)->insert;
$ordernumber = $order->{ordernumber};

$order->add_item( $itemnumber1 );
$order->add_item( $itemnumber2 );

my ( undef, $new_ordernumber ) = ModReceiveOrder(
    {
        biblionumber     => $biblionumber,
        ordernumber      => $ordernumber,
        quantityreceived => 1,
        datereceived     => dt_from_string,
        received_items   => [ $itemnumber1 ],
    }
);

CancelReceipt($new_ordernumber);

is(scalar( GetItemnumbersFromOrder($ordernumber) ), 2, "Create items on ordering: items are not deleted after cancelling a receipt");

my $item1 = C4::Items::GetItem( $itemnumber1 );
is( $item1->{notforloan}, 9, "The notforloan value has been updated with '9'" );

my $item2 = C4::Items::GetItem( $itemnumber2 );
is( $item2->{notforloan}, 0, "The notforloan value has been updated with '9'" );

$dbh->rollback;
