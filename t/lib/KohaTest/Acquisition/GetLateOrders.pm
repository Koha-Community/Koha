package KohaTest::Acquisition::GetLateOrders;
use base qw( KohaTest::Acquisition );

use strict;
use warnings;

use Test::More;

use C4::Acquisition;
use C4::Context;
use C4::Members;

=head3 no_orders

=cut

sub no_orders : Test( 1 ) {
    my $self = shift;

    my @orders = GetLateOrders( 1 );
    is( scalar @orders, 0, 'There are no orders, so we found 0.' ) 
      or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );

}

=head3 one_order

=cut

sub one_order : Test( 29 ) {
    my $self = shift;

    my ( $basketid, $ordernumber ) = $self->create_new_basket();
    ok( $basketid, 'a new basket was created' );
    ok( $ordernumber, 'the basket has an order in it.' );
    # we need this basket to be closed.
    CloseBasket( $basketid );
    
    my @orders = GetLateOrders( 0 );

    {
        my @orders = GetLateOrders( 0 );
        is( scalar @orders, 1, 'An order closed today is 0 days late.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }
    {
        my @orders = GetLateOrders( 1 );
        is( scalar @orders, 0, 'An order closed today is not 1 day late.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }
    {
        my @orders = GetLateOrders( -1 );
        is( scalar @orders, 1, 'an order closed today is -1 day late.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }

    # provide some vendor information
    {
        my @orders = GetLateOrders( 0, $self->{'booksellerid'} );
        is( scalar @orders, 1, 'We found this late order with the right supplierid.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }
    {
        my @orders = GetLateOrders( 0, $self->{'booksellerid'} + 1 );
        is( scalar @orders, 0, 'We found no late orders with the wrong supplierid.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }

    # provide some branch information
    my $member = GetMember( $self->{'memberid'} );
    # diag( Data::Dumper->Dump( [ $member ], [ 'member' ] ) );
    {
        my @orders = GetLateOrders( 0, $self->{'booksellerid'}, $member->{'branchcode'} );
        is( scalar @orders, 1, 'We found this late order with the right branchcode.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }
    {
        my @orders = GetLateOrders( 0, $self->{'booksellerid'}, 'This is not the branch' );
        is( scalar @orders, 0, 'We found no late orders with the wrong branchcode.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }

    # set up some things necessary to make GetLateOrders use the IndependantBranches
    $self->enable_independant_branches();    

    {
        my @orders = GetLateOrders( 0, $self->{'booksellerid'}, $member->{'branchcode'} );
        is( scalar @orders, 1, 'We found this late order with the right branchcode.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }
    {
        my @orders = GetLateOrders( 0, $self->{'booksellerid'}, 'This is not the branch' );
        is( scalar @orders, 0, 'We found no late orders with the wrong branchcode.' ) 
          or diag( Data::Dumper->Dump( [ \@orders ], [ 'orders' ] ) );
    }

    # reset that.
    $self->disable_independant_branches();    

}





1;
