package KohaTest::Acquisition::GetPendingOrders;
use base qw( KohaTest::Acquisition );

use strict;
use warnings;

use Test::More;

use C4::Acquisition;

=head3 no_orders

at first, there should be no orders for our bookseller.

=cut

sub no_orders : Test( 1 ) {
    my $self = shift;

    my $orders = GetPendingOrders( $self->{'booksellerid'} );
    is( scalar @$orders, 0, 'our new bookseller has no pending orders' )
      or diag( Data::Dumper->Dump( [ $orders ], [ 'orders' ] ) );
}

=head3 new_order

we make an order, then see if it shows up in the pending orders

=cut

sub one_new_order : Test( 49 ) {
    my $self = shift;

    my ( $basketno, $ordnum ) = $self->create_new_basket();

    ok( $basketno, "basketno is $basketno" );
    ok( $ordnum, "ordnum is $ordnum" );
    
    my $orders = GetPendingOrders( $self->{'booksellerid'} );
    is( scalar @$orders, 1, 'we successfully entered one order.' );

    my @expectedfields = qw( basketno
                             biblioitemnumber
                             biblionumber
                             booksellerinvoicenumber
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

1;
