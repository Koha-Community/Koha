package KohaTest::Acquisition::GetHistory;
use base qw( KohaTest::Acquisition );

use strict;
use warnings;

use Test::More;

use C4::Acquisition;
use C4::Context;
use C4::Members;
use C4::Biblio;
use C4::Bookseller;

=head3 no_history



=cut

sub no_history : Test( 4 ) {
    my $self = shift;

    # my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( $title, $author, $name, $from_placed_on, $to_placed_on )

    my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory();
    # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );

    is( scalar @$order_loop, 0, 'order_loop is empty' );
    is( $total_qty,          0, 'total_qty' );
    is( $total_price,        0, 'total_price' );
    is( $total_qtyreceived,  0, 'total_qtyreceived' );

    
}

=head3 one_order

=cut

sub one_order : Test( 50 ) {
    my $self = shift;
    
    my ( $basketno, $ordnum ) = $self->create_new_basket();
    ok( $basketno, "basketno is $basketno" );
    ok( $ordnum, "ordnum is $ordnum" );

    # No arguments fetches no history.
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory();
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
        
        is( scalar @$order_loop, 0, 'order_loop is empty' );
        is( $total_qty,          0, 'total_qty' );
        is( $total_price,        0, 'total_price' );
        is( $total_qtyreceived,  0, 'total_qtyreceived' );
    }

    my $bibliodata = GetBiblioData( $self->{'biblios'}[0] );
    ok( $bibliodata->{'title'}, 'the biblio has a title' )
      or diag( Data::Dumper->Dump( [ $bibliodata ], [ 'bibliodata' ] ) );
    
    # searching by title should find it.
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( $bibliodata->{'title'} );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by title' );
        is( $total_qty,          1, 'total_qty searched by title' );
        is( $total_price,        1, 'total_price searched by title' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by title' );

        # diag( Data::Dumper->Dump( [ $order_loop ], [ 'order_loop' ] ) );
    }

    # searching by author
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( undef, $bibliodata->{'author'} );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by author' );
        is( $total_qty,          1, 'total_qty searched by author' );
        is( $total_price,        1, 'total_price searched by author' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by author' );
    }

    # searching by name
    {
        # diag( Data::Dumper->Dump( [ $bibliodata ], [ 'bibliodata' ] ) );

        my $bookseller = GetBookSellerFromId( $self->{'booksellerid'} );
        ok( $bookseller->{'name'}, 'bookseller name' )
          or diag( Data::Dumper->Dump( [ $bookseller ], [ 'bookseller' ] ) );
        
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( undef, undef, $bookseller->{'name'} );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by name' );
        is( $total_qty,          1, 'total_qty searched by name' );
        is( $total_price,        1, 'total_price searched by name' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by name' );
    }

    # searching by from_date
    {
        my $tomorrow = $self->tomorrow();
        # diag( "tomorrow is $tomorrow" );

        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( undef, undef, undef, undef, $tomorrow );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by to_date' );
        is( $total_qty,          1, 'total_qty searched by to_date' );
        is( $total_price,        1, 'total_price searched by to_date' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by to_date' );
    }

    # searching by from_date
    {
        my $yesterday = $self->yesterday();
        # diag( "yesterday was $yesterday" );
    
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( undef, undef, undef, $yesterday );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by from_date' );
        is( $total_qty,          1, 'total_qty searched by from_date' );
        is( $total_price,        1, 'total_price searched by from_date' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by from_date' );
    }

    # set up some things necessary to make GetHistory use the IndependantBranches
    $self->enable_independant_branches();    

    # just search by title here, we need to search by something.
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( $bibliodata->{'title'} );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by title' );
        is( $total_qty,          1, 'total_qty searched by title' );
        is( $total_price,        1, 'total_price searched by title' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by title' );

        # diag( Data::Dumper->Dump( [ $order_loop ], [ 'order_loop' ] ) );
    }
    
    # reset that.
    $self->disable_independant_branches();    

    

    
}


1;
