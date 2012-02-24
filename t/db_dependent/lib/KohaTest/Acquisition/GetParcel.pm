package KohaTest::Acquisition::GetParcel;
use base qw( KohaTest::Acquisition );

use strict;
use warnings;

use Test::More;
use Time::localtime;

use C4::Acquisition;

=head3 no_parcel

at first, there should be no parcels for our bookseller.

=cut

sub no_parcel : Test( 1 ) {
    my $self = shift;

    my @parcel = GetParcel( $self->{'booksellerid'}, undef, undef );
    is( scalar @parcel, 0, 'our new bookseller has no parcels' )
      or diag( Data::Dumper->Dump( [ \@parcel ], [ 'parcel' ] ) );
}

=head3 one_parcel

we create an order, mark it as received, and then see if we can find
it with GetParcel.

=cut

sub one_parcel : Test( 17 ) {
    my $self = shift;

    my $invoice = 123;    # XXX what should this be?

    my $today = sprintf( '%04d-%02d-%02d',
                         localtime->year() + 1900,
                         localtime->mon() + 1,
                         localtime->mday() );
    my ( $basketno, $ordernumber ) = $self->create_new_basket();
    
    ok( $basketno, "my basket number is $basketno" );
    ok( $ordernumber,   "my order number is $ordernumber" );
    my $datereceived = ModReceiveOrder( $self->{'biblios'}[0],             # biblionumber
                                        $ordernumber,       # $ordernumber,
                                        undef,         # $quantrec,
                                        undef,         # $user,
                                        undef,         # $cost,
                                        undef,         # $ecost,
                                        $invoice,         # $invoiceno,
                                        undef,         # $freight,
                                        undef,         # $rrp,
                                        $self->{'bookfundid'},         # $bookfund,
                                        $today,         # $datereceived
                                   );
    is( $datereceived, $today, "the parcel was received on $datereceived" );

    my @parcel = GetParcel( $self->{'booksellerid'}, $invoice, $today );
    is( scalar @parcel, 1, 'we found one (1) parcel.' )
      or diag( Data::Dumper->Dump( [ \@parcel ], [ 'parcel' ] ) );

}

1;
