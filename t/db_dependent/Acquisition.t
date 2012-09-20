#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use Data::Dumper;
use POSIX qw(strftime);

use C4::Bookseller qw( GetBookSellerFromId );

use Test::More tests => 38;

BEGIN {
    use_ok('C4::Acquisition');
}

my $booksellerid = 1;
my $booksellerinfo = GetBookSellerFromId( $booksellerid );
# diag( Data::Dumper->Dump( [ $booksellerinfo ], [ 'booksellerinfo' ] ) );
SKIP: {
    skip 'No booksellers in database, cannot test baskets', 2 unless $booksellerinfo;
    my ($basket, $basketno);
    ok($basketno = NewBasket(1,1),			"NewBasket(  1 , 1  ) returns $basketno");
    ok($basket   = GetBasket($basketno),	"GetBasket($basketno) returns $basket");
}


my $supplierid = 1;
my $grouped    = 0;
my $orders = GetPendingOrders( $supplierid, $grouped );
isa_ok( $orders, 'ARRAY' );

my @lateorders = GetLateOrders(0);
SKIP: {
   skip 'No Late Orders, cannot test AddClaim', 1 unless @lateorders;
   my $order = $lateorders[0];
   AddClaim( $order->{ordernumber} );
   my $neworder = GetOrder( $order->{ordernumber} );
   is( $neworder->{claimed_date}, strftime( "%Y-%m-%d", localtime(time) ), "AddClaim : Check claimed_date" );
}

SKIP: {
    skip 'No relevant orders in database, cannot test baskets', 33 unless( scalar @$orders );
    # diag( Data::Dumper->Dump( [ $orders ], [ 'orders' ] ) );
    my @expectedfields = qw( basketno
                             biblioitemnumber
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
                             gst
                             listprice
                             notes
                             ordernumber
                             purchaseordernumber
                             quantity
                             quantityreceived
                             rrp
                             serialid
                             sort1
                             sort2
                             subscription
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
}
