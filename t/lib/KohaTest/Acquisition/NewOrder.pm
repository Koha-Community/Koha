package KohaTest::Acquisition::NewOrder;
use base qw( KohaTest::Acquisition );

use strict;
use warnings;

use Test::More;
use Time::localtime;

use C4::Acquisition;

=head3 new_order_no_budget

If we make a new order and don't pass in a budget date, it defaults to
today.

=cut

sub new_order_no_budget : Test( 4 ) {
    my $self = shift;

    my $authorizedby = 1; # XXX what should this be?
    my $invoice = 123;    # XXX what should this be?
    my $today = sprintf( '%04d-%02d-%02d',
                         localtime->year() + 1900,
                         localtime->mon() + 1,
                         localtime->mday() );
    my ( $basketno, $ordnum ) = NewOrder( undef, # $basketno,
                                          1, # $bibnum,
                                          undef, # $title,
                                          undef, # $quantity,
                                          undef, # $listprice,
                                          $self->{'booksellerid'}, # $booksellerid,
                                          $authorizedby, # $authorisedby,
                                          undef, # $notes,
                                          $self->{'bookfundid'},     # $bookfund,
                                          undef, # $bibitemnum,
                                          undef, # $rrp,
                                          undef, # $ecost,
                                          undef, # $gst,
                                          undef, # $budget,
                                          undef, # $cost,
                                          undef, # $sub,
                                          $invoice, # $invoice,
                                          undef, # $sort1,
                                          undef, # $sort2,
                                          undef, # $purchaseorder
                                     );
    ok( $basketno, "my basket number is $basketno" );
    ok( $ordnum,   "my order number is $ordnum" );

    my $order = GetOrder( $ordnum );
    is( $order->{'ordernumber'}, $ordnum, 'got the right order' )
      or diag( Data::Dumper->Dump( [ $order ], [ 'order' ] ) );
    
    is( $order->{'budgetdate'}, $today, "the budget date is $today" );
}

=head3 new_order_set_budget

Let's set the budget date of this new order. It actually pretty much
only pays attention to the current month and year.

=cut

sub new_order_set_budget : Test( 4 ) {
    my $self = shift;

    my $authorizedby = 1; # XXX what should this be?
    my $invoice = 123;    # XXX what should this be?
    my $today = sprintf( '%04d-%02d-%02d',
                         localtime->year() + 1900,
                         localtime->mon() + 1,
                         localtime->mday() );
    my ( $basketno, $ordnum ) = NewOrder( undef, # $basketno,
                                          1, # $bibnum,
                                          undef, # $title,
                                          undef, # $quantity,
                                          undef, # $listprice,
                                          $self->{'booksellerid'}, # $booksellerid,
                                          $authorizedby, # $authorisedby,
                                          undef, # $notes,
                                          $self->{'bookfundid'},     # $bookfund,
                                          undef, # $bibitemnum,
                                          undef, # $rrp,
                                          undef, # $ecost,
                                          undef, # $gst,
                                          'does not matter, just not undef', # $budget,
                                          undef, # $cost,
                                          undef, # $sub,
                                          $invoice, # $invoice,
                                          undef, # $sort1,
                                          undef, # $sort2,
                                          undef, # $purchaseorder
                                     );
    ok( $basketno, "my basket number is $basketno" );
    ok( $ordnum,   "my order number is $ordnum" );

    my $order = GetOrder( $ordnum );
    is( $order->{'ordernumber'}, $ordnum, 'got the right order' )
      or diag( Data::Dumper->Dump( [ $order ], [ 'order' ] ) );
    
    like( $order->{'budgetdate'}, qr(^2\d\d\d-07-01$), "the budget date ($order->{'budgetdate'}) is a July 1st." );
}

1;
