#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;
use POSIX qw(strftime);

use C4::Bookseller qw( GetBookSellerFromId );

use Test::More tests => 63;

BEGIN {
    use_ok('C4::Acquisition');
    use_ok('C4::Bookseller');
    use_ok('C4::Biblio');
    use_ok('C4::Budgets');
    use_ok('C4::Bookseller');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1,
        deliverytime => 5,
    }
);

my $booksellerinfo = C4::Bookseller::GetBookSellerFromId( $booksellerid );

is($booksellerinfo->{deliverytime}, 5, 'set deliverytime when creating vendor (Bug 10556)');

my ($basket, $basketno);
ok($basketno = NewBasket($booksellerid, 1), "NewBasket(  $booksellerid , 1  ) returns $basketno");
ok($basket   = GetBasket($basketno), "GetBasket($basketno) returns $basket");

my $budgetid = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_getordersbybib",
        budget_name => "budget_name_test_getordersbybib",
    }
);
my $budget = C4::Budgets::GetBudget( $budgetid );

my ($ordernumber1, $ordernumber2, $ordernumber3);
my ($biblionumber1, $biblioitemnumber1) = AddBiblio(MARC::Record->new, '');
my ($biblionumber2, $biblioitemnumber2) = AddBiblio(MARC::Record->new, '');
( undef, $ordernumber1 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 24,
        biblionumber => $biblionumber1,
        budget_id => $budget->{budget_id},
    }
);

( undef, $ordernumber2 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 42,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
    }
);

( undef, $ordernumber3 ) = C4::Acquisition::NewOrder(
    {
        basketno => $basketno,
        quantity => 4,
        biblionumber => $biblionumber2,
        budget_id => $budget->{budget_id},
        ecost => 42,
        rrp => 42,
    }
);

my $orders = SearchOrders({
    booksellerid => $booksellerid,
    pending => 1
});
isa_ok( $orders, 'ARRAY' );
is(scalar(@$orders), 3, 'retrieved 3 pending orders');

ok( exists( @$orders[0]->{basketgroupid} ), "SearchOrder: The basketgroupid key exists" );
ok( exists( @$orders[0]->{basketgroupname} ), "SearchOrder: The basketgroupname key exists" );
ok( exists( @$orders[0]->{authorisedby} ), "SearchOrders: The authorised key exists (bug 11777)" );

ok( GetBudgetByOrderNumber($ordernumber1)->{'budget_id'} eq $budgetid, "GetBudgetByOrderNumber returns expected budget" );

C4::Acquisition::CloseBasket( $basketno );
my @lateorders = GetLateOrders(0);
my $order = $lateorders[0];
AddClaim( $order->{ordernumber} );
my $neworder = GetOrder( $order->{ordernumber} );
is( $neworder->{claimed_date}, strftime( "%Y-%m-%d", localtime(time) ), "AddClaim : Check claimed_date" );

my @expectedfields = qw( basketno
                         biblionumber
                         invoiceid
                         budgetdate
                         cancelledby
                         closedate
                         creationdate
                         currency
                         datecancellationprinted
                         datereceived
                         ecost
                         entrydate
                         firstname
                         freight
                         gstrate
                         listprice
                         notes
                         ordernumber
                         purchaseordernumber
                         quantity
                         quantityreceived
                         rrp
                         sort1
                         sort2
                         subscriptionid
                         supplierreference
                         surname
                         timestamp
                         title
                         totalamount
                         unitprice );
my $firstorder = $orders->[0];
for my $field ( @expectedfields ) {
    ok( exists( $firstorder->{ $field } ), "This order has a $field field" );
}

# fake receiving the order
ModOrder({
    ordernumber      => $firstorder->{ordernumber},
    biblionumber     => $firstorder->{biblionumber},
    quantityreceived => $firstorder->{quantity},
});
my $pendingorders = SearchOrders({
    booksellerid => $booksellerid,
    pending => 1
});
is(scalar(@$pendingorders), 2, 'retrieved 2 pending orders after receiving on one (bug 10723)');
my $allorders = SearchOrders({
    booksellerid => $booksellerid,
});
is(scalar(@$allorders), 3, 'retrieved all 3 orders even after after receiving on one (bug 10723)');

my $invoiceid = AddInvoice(
    invoicenumber => 'invoice',
    booksellerid => $booksellerid,
    unknown => "unknown"
);

my ($datereceived, $new_ordernumber) = ModReceiveOrder(
    $biblionumber2,
    $ordernumber2,
    2,
    undef,
    12,
    12,
    $invoiceid,
    42,
    );
my $order2 = GetOrder( $ordernumber2 );
is($order2->{'quantityreceived'}, 0, 'Splitting up order did not receive any on original order');
is($order2->{'quantity'}, 40, '40 items on original order');
is($order2->{'budget_id'}, $budgetid, 'Budget on original order is unchanged');

$neworder = GetOrder( $new_ordernumber );
is($neworder->{'quantity'}, 2, '2 items on new order');
is($neworder->{'quantityreceived'}, 2, 'Splitting up order received items on new order');
is($neworder->{'budget_id'}, $budgetid, 'Budget on new order is unchanged');

my $budgetid2 = C4::Budgets::AddBudget(
    {
        budget_code => "budget_code_test_modrecv",
        budget_name => "budget_name_test_modrecv",
    }
);

($datereceived, $new_ordernumber) = ModReceiveOrder(
    $biblionumber2,
    $ordernumber3,
    2,
    undef,
    12,
    12,
    $invoiceid,
    42,
    $budgetid2
    );

my $order3 = GetOrder( $ordernumber3 );
is($order3->{'quantityreceived'}, 0, 'Splitting up order did not receive any on original order');
is($order3->{'quantity'}, 2, '2 items on original order');
is($order3->{'budget_id'}, $budgetid, 'Budget on original order is unchanged');

$neworder = GetOrder( $new_ordernumber );
is($neworder->{'quantity'}, 2, '2 items on new order');
is($neworder->{'quantityreceived'}, 2, 'Splitting up order received items on new order');
is($neworder->{'budget_id'}, $budgetid2, 'Budget on new order is changed');

($datereceived, $new_ordernumber) = ModReceiveOrder(
    $biblionumber2,
    $ordernumber3,
    2,
    undef,
    12,
    12,
    $invoiceid,
    42,
    $budgetid2
    );

$order3 = GetOrder( $ordernumber3 );
is($order3->{'quantityreceived'}, 2, 'Order not split up');
is($order3->{'quantity'}, 2, '2 items on order');
is($order3->{'budget_id'}, $budgetid2, 'Budget has changed');

$dbh->rollback;
