package KohaTest::Acquisition;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Acquisition;
use C4::Context;
use C4::Members;
use Time::localtime;

sub testing_class { 'C4::Acquisition' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw(  GetBasket 
                       NewBasket 
                       CloseBasket 
                       GetPendingOrders 
                       GetOrders 
                       GetOrderNumber 
                       GetOrder 
                       NewOrder 
                       ModOrder 
                       ModOrderBiblioNumber 
                       ModReceiveOrder 
                       SearchOrder 
                       DelOrder 
                       GetParcel 
                       GetParcels 
                       GetLateOrders 
                       GetHistory 
                       GetRecentAcqui 
                );
    
    can_ok( $self->testing_class, @methods );    
}

=head3 create_new_basket

  creates a baseket by creating an order with no baseket number.

  named parameters:
    authorizedby
    invoice
    date

  returns: baseket number, order number

  runs 4 tests

=cut

sub create_new_basket {
    my $self = shift;
    my %param = @_;
    $param{'authorizedby'} = $self->{'memberid'} unless exists $param{'authorizedby'};
    $param{'invoice'}      = 123                 unless exists $param{'invoice'};
    
    my $today = sprintf( '%04d-%02d-%02d',
                         localtime->year() + 1900,
                         localtime->mon() + 1,
                         localtime->mday() );
    
    # I actually think that this parameter is unused.
    $param{'date'}         = $today              unless exists $param{'date'};

    $self->add_biblios( add_items => 1 );
    ok( scalar @{$self->{'biblios'}} > 0, 'we have added at least one biblio' );

    my ( $basketno, $ordnum ) = NewOrder( undef, # $basketno,
                                          $self->{'biblios'}[0], # $bibnum,
                                          undef, # $title,
                                          1, # $quantity,
                                          undef, # $listprice,
                                          $self->{'booksellerid'}, # $booksellerid,
                                          $param{'authorizedby'}, # $authorisedby,
                                          undef, # $notes,
                                          $self->{'bookfundid'},     # $bookfund,
                                          undef, # $bibitemnum,
                                          1, # $rrp,
                                          1, # $ecost,
                                          undef, # $gst,
                                          undef, # $budget,
                                          undef, # $cost,
                                          undef, # $sub,
                                          $param{'invoice'}, # $invoice,
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

    # XXX should I stuff these in $self?
    return ( $basketno, $ordnum );
    
}


sub enable_independant_branches {
    my $self = shift;
    
    my $member = GetMember( $self->{'memberid'} );
    
    C4::Context::set_userenv( 0, # usernum
                              $self->{'memberid'}, # userid
                              undef, # usercnum
                              undef, # userfirstname
                              undef, # usersurname
                              $member->{'branchcode'}, # userbranch
                              undef, # branchname
                              0, # userflags
                              undef, # emailaddress
                              undef, # branchprinter
                         );

    # set a preference. There's surely a method for this, but I can't find it.
    my $retval = C4::Context->dbh->do( q(update systempreferences set value = '1' where variable = 'IndependantBranches') );
    ok( $retval, 'set the preference' );
    
    ok( C4::Context->userenv, 'usernev' );
    isnt( C4::Context->userenv->{flags}, 1, 'flag != 1' )
      or diag( Data::Dumper->Dump( [ C4::Context->userenv ], [ 'userenv' ] ) );

    is( C4::Context->userenv->{branch}, $member->{'branchcode'}, 'we have set the right branch in C4::Context: ' . $member->{'branchcode'} );
    
}

sub disable_independant_branches {
    my $self = shift;

    my $retval = C4::Context->dbh->do( q(update systempreferences set value = '0' where variable = 'IndependantBranches') );
    ok( $retval, 'set the preference back' );

    
}
1;
