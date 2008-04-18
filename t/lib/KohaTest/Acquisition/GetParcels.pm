package KohaTest::Acquisition::GetParcels;
use base qw( KohaTest::Acquisition );

use strict;
use warnings;

use Test::More;
use Time::localtime;

use C4::Acquisition;

=head2 NOTE

Please do not confuse this with the test suite for C4::Acquisition::GetParcel.

=head3 no_parcels

at first, there should be no parcels for our bookseller.

=cut

sub no_parcels : Test( 1 ) {
    my $self = shift;

    my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                             # order
                             # code ( aqorders.booksellerinvoicenumber )
                             # datefrom
                             # date to
                        );
                            
    is( scalar @parcels, 0, 'our new bookseller has no parcels' )
      or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );
}

=head3 one_parcel

we create an order, mark it as received, and then see if we can find
it with GetParcels.

=cut

sub one_parcel : Test( 19 ) {
    my $self = shift;

    my $invoice = 123;    # XXX what should this be?
    my $today = sprintf( '%04d-%02d-%02d',
                         localtime->year() + 1900,
                         localtime->mon() + 1,
                         localtime->mday() );

    $self->create_order( authorizedby => 1,   # XXX what should this be?
                         invoice      => $invoice,
                         date         => $today );
    
    my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                             # order
                             # code ( aqorders.booksellerinvoicenumber )
                             # datefrom
                             # date to
                        );
    is( scalar @parcels, 1, 'we found one (1) parcel.' )
      or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );

    my $thisparcel = shift( @parcels );
    is( scalar ( keys( %$thisparcel ) ), 6, 'my parcel hashref has 6 keys' )
      or diag( Data::Dumper->Dump( [ $thisparcel ], [ 'thisparcel' ] ) );
      
    is( $thisparcel->{'datereceived'},             $today,   'datereceived' );
    is( $thisparcel->{'biblio'},                   1,        'biblio' );
    is( $thisparcel->{'booksellerinvoicenumber'}, $invoice, 'booksellerinvoicenumber' );

    # diag( Data::Dumper->Dump( [ $thisparcel ], [ 'thisparcel' ] ) );

}

=head3 two_parcels

we create another order, mark it as received, and then see if we can find
them all with GetParcels.

=cut

sub two_parcels : Test( 31 ) {
    my $self = shift;

    my $invoice = 1234;    # XXX what should this be?
    my $today = sprintf( '%04d-%02d-%02d',
                         localtime->year() + 1900,
                         localtime->mon() + 1,
                         localtime->mday() );
    $self->create_order( authorizedby => 1,   # XXX what should this be?
                         invoice      => $invoice,
                         date         => $today );

    {
        # fetch them all and check that this one is last
        my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                                  # order
                                  # code ( aqorders.booksellerinvoicenumber )
                                  # datefrom
                                  # date to
                             );
        is( scalar @parcels, 2, 'we found two (2) parcels.' )
          or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );
        
        my $thisparcel = pop( @parcels );
        is( scalar ( keys( %$thisparcel ) ), 6, 'my parcel hashref has 6 keys' )
          or diag( Data::Dumper->Dump( [ $thisparcel ], [ 'thisparcel' ] ) );
        
        is( $thisparcel->{'datereceived'},             $today,   'datereceived' );
        is( $thisparcel->{'biblio'},                   1,        'biblio' );
        is( $thisparcel->{'booksellerinvoicenumber'}, $invoice, 'booksellerinvoicenumber' );
    }

    {
        # fetch just one, by using the exact code
        my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                                  undef,    # order
                                  $invoice, # code ( aqorders.booksellerinvoicenumber )
                                  undef,    # datefrom
                                  undef,    # date to
                             );
        is( scalar @parcels, 1, 'we found one (1) parcels.' )
          or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );
        
        my $thisparcel = pop( @parcels );
        is( scalar ( keys( %$thisparcel ) ), 6, 'my parcel hashref has 6 keys' )
          or diag( Data::Dumper->Dump( [ $thisparcel ], [ 'thisparcel' ] ) );
        
        is( $thisparcel->{'datereceived'},             $today,   'datereceived' );
        is( $thisparcel->{'biblio'},                   1,        'biblio' );
        is( $thisparcel->{'booksellerinvoicenumber'}, $invoice, 'booksellerinvoicenumber' );
    }
    
    {
        # fetch them both by using code 123, which gets 123 and 1234
        my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                                  undef,    # order
                                  '123', # code ( aqorders.booksellerinvoicenumber )
                                  undef,    # datefrom
                                  undef,    # date to
                             );
        is( scalar @parcels, 2, 'we found 2 parcels.' )
          or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );
        
    }
    
    {
        # fetch them both, and try to order them
        my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                                  'aqorders.booksellerinvoicenumber',    # order
                                  undef, # code ( aqorders.booksellerinvoicenumber )
                                  undef,    # datefrom
                                  undef,    # date to
                             );
        is( scalar @parcels, 2, 'we found 2 parcels.' )
          or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );
        is( $parcels[0]->{'booksellerinvoicenumber'}, 123 );
        is( $parcels[1]->{'booksellerinvoicenumber'}, 1234 );
        
    }
    
    {
        # fetch them both, and try to order them, descending
        my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                                  'aqorders.booksellerinvoicenumber desc',    # order
                                  undef, # code ( aqorders.booksellerinvoicenumber )
                                  undef,    # datefrom
                                  undef,    # date to
                             );
        is( scalar @parcels, 2, 'we found 2 parcels.' )
          or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );
        is( $parcels[0]->{'booksellerinvoicenumber'}, 1234 );
        is( $parcels[1]->{'booksellerinvoicenumber'}, 123 );
        
    }
    
    
    

    # diag( Data::Dumper->Dump( [ $thisparcel ], [ 'thisparcel' ] ) );

}


=head3 z_several_parcels_with_different_dates

we create an order, mark it as received, and then see if we can find
it with GetParcels.

=cut

sub z_several_parcels_with_different_dates : Test( 44 ) {
    my $self = shift;

    my $authorizedby = 1; # XXX what should this be?

    my @inputs = ( { invoice => 10,
                      date     => sprintf( '%04d-%02d-%02d',
                                           1950,
                                           localtime->mon() + 1,
                                           10 ), # I'm using the invoice number as the day.
                 },
                    { invoice => 15,
                      date     => sprintf( '%04d-%02d-%02d',
                                           1950,
                                           localtime->mon() + 1,
                                           15 ), # I'm using the invoice number as the day.
                 },
                    { invoice => 20,
                      date     => sprintf( '%04d-%02d-%02d',
                                           1950,
                                           localtime->mon() + 1,
                                           20 ), # I'm using the invoice number as the day.
                 },
               );

    foreach my $input ( @inputs ) {
        $self->create_order( authorizedby => $authorizedby,
                             invoice      => $input->{'invoice'},
                             date         => $input->{'date'},
                        );
    }
                         
    my @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                              undef, # order
                              undef, # code ( aqorders.booksellerinvoicenumber )
                              sprintf( '%04d-%02d-%02d',
                                       1950,
                                       localtime->mon() + 1,
                                       10 ), # datefrom
                              sprintf( '%04d-%02d-%02d',
                                       1950,
                                       localtime->mon() + 1,
                                       20 ), # dateto
                        );
    is( scalar @parcels, scalar @inputs, 'we found all of the parcels.' )
      or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );

    @parcels = GetParcels( $self->{'booksellerid'},  # bookseller
                           undef, # order
                           undef, # code ( aqorders.booksellerinvoicenumber )
                           sprintf( '%04d-%02d-%02d',
                                    1950,
                                    localtime->mon() + 1,
                                    10 ), # datefrom
                           sprintf( '%04d-%02d-%02d',
                                    1950,
                                    localtime->mon() + 1,
                                    16 ), # dateto
                        );
    is( scalar @parcels, scalar @inputs - 1, 'we found all of the parcels except one' )
      or diag( Data::Dumper->Dump( [ \@parcels ], [ 'parcels' ] ) );



    # diag( Data::Dumper->Dump( [ $thisparcel ], [ 'thisparcel' ] ) );

}

sub create_order {
    my $self = shift;
    my %param = @_;
    $param{'authorizedby'} = 1 unless exists $param{'authorizedby'};
    $param{'invoice'}      = 1 unless exists $param{'invoice'};
    $param{'date'} = sprintf( '%04d-%02d-%02d',
                              localtime->year() + 1900,
                              localtime->mon() + 1,
                              localtime->mday() ) unless exists $param{'date'};

    my ( $basketno, $ordnum ) = $self->create_new_basket( %param );

    my $datereceived = ModReceiveOrder( $self->{'biblios'}[0],             # biblionumber
                                        $ordnum,       # $ordnum,
                                        undef,         # $quantrec,
                                        undef,         # $user,
                                        undef,         # $cost,
                                        $param{'invoice'},         # $invoiceno,
                                        undef,         # $freight,
                                        undef,         # $rrp,
                                        $self->{'bookfundid'},         # $bookfund,
                                        $param{'date'},         # $datereceived
                                   );
    is( $datereceived, $param{'date'}, "the parcel was received on $datereceived" );

}

1;
