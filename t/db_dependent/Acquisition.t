#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;
use POSIX qw(strftime);

use C4::Bookseller qw( GetBookSellerFromId );

use Test::More tests => 40;

BEGIN {
    use_ok('C4::Acquisition');
    use_ok('C4::Bookseller');
    use_ok('C4::Biblio');
    use_ok('C4::Budgets');
    use_ok('C4::Bookseller');
}

my $booksellerid = C4::Bookseller::AddBookseller(
    {
        name => "my vendor",
        address1 => "bookseller's address",
        phone => "0123456",
        active => 1
    }
);

my $booksellerinfo = C4::Bookseller::GetBookSellerFromId( $booksellerid );

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

my $grouped    = 0;
my $orders = GetPendingOrders( $booksellerid, $grouped );
isa_ok( $orders, 'ARRAY' );

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

END {
    C4::Acquisition::DelOrder( $biblionumber1, $ordernumber1 );
    C4::Acquisition::DelOrder( $biblionumber2, $ordernumber2 );
    C4::Acquisition::DelOrder( $biblionumber2, $ordernumber3 );
    C4::Budgets::DelBudget( $budgetid );
    C4::Acquisition::DelBasket( $basketno );
    C4::Bookseller::DelBookseller( $booksellerid );
    C4::Biblio::DelBiblio($biblionumber1);
    C4::Biblio::DelBiblio($biblionumber2);
};
