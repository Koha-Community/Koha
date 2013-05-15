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

my $INVOICE = "1234-56 AB";
sub one_order : Test( 55 ) {
    my $self = shift;
    
    my ( $basketno, $ordernumber ) = $self->create_new_basket(invoice => $INVOICE);
    ok( $basketno, "basketno is $basketno" );
    ok( $ordernumber, "ordernumber is $ordernumber" );

    # No arguments fetches no history.
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = eval { GetHistory() };
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
        
        is( $order_loop, undef, 'order_loop is empty' );
    }

    my $bibliodata = GetBiblioData( $self->{'biblios'}[0] );
    ok( $bibliodata->{'title'}, 'the biblio has a title' )
      or diag( Data::Dumper->Dump( [ $bibliodata ], [ 'bibliodata' ] ) );
    
    # searching by title should find it.
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( title => $bibliodata->{'title'} );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by title' );
        is( $total_qty,          1, 'total_qty searched by title' );
        is( $total_price,        1, 'total_price searched by title' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by title' );

        # diag( Data::Dumper->Dump( [ $order_loop ], [ 'order_loop' ] ) );
    }

    # searching by isbn
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( isbn => $bibliodata->{'isbn'} );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );

        is( scalar @$order_loop, 1, 'order_loop searched by isbn' );
        is( $total_qty,          1, 'total_qty searched by isbn' );
        is( $total_price,        1, 'total_price searched by isbn' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by isbn' );

        # diag( Data::Dumper->Dump( [ $order_loop ], [ 'order_loop' ] ) );
    }

    # searching by ean
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( ean => $bibliodata->{'ean'} );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );

        is( scalar @$order_loop, 1, 'order_loop searched by ean' );
        is( $total_qty,          1, 'total_qty searched by ean' );
        is( $total_price,        1, 'total_price searched by ean' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by ean' );

        # diag( Data::Dumper->Dump( [ $order_loop ], [ 'order_loop' ] ) );
    }


    # searching by basket number
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( basket => $basketno );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by basket no' );
        is( $total_qty,          1, 'total_qty searched by basket no' );
        is( $total_price,        1, 'total_price searched by basket no' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by basket no' );

        # diag( Data::Dumper->Dump( [ $order_loop ], [ 'order_loop' ] ) );
    }

    # searching by invoice number
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( booksellerinvoicenumber  => $INVOICE );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by invoice no' );
        is( $total_qty,          1, 'total_qty searched by invoice no' );
        is( $total_price,        1, 'total_price searched by invoice no' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by invoice no' );

        # diag( Data::Dumper->Dump( [ $order_loop ], [ 'order_loop' ] ) );
    }

    # searching by author
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( author => $bibliodata->{'author'} );
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
        
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( name => $bookseller->{'name'} );
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

        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( to_placed_on =>  $tomorrow );
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
    
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( from_placed_on =>  $yesterday );
        # diag( Data::Dumper->Dump( [ $order_loop, $total_qty, $total_price, $total_qtyreceived ], [ qw( order_loop total_qty total_price total_qtyreceived ) ] ) );
    
        is( scalar @$order_loop, 1, 'order_loop searched by from_date' );
        is( $total_qty,          1, 'total_qty searched by from_date' );
        is( $total_price,        1, 'total_price searched by from_date' );
        is( $total_qtyreceived,  0, 'total_qtyreceived searched by from_date' );
    }

    # set up some things necessary to make GetHistory use the IndependentBranches
    $self->enable_independant_branches();    

    # just search by title here, we need to search by something.
    {
        my ( $order_loop, $total_qty, $total_price, $total_qtyreceived) = GetHistory( title => $bibliodata->{'title'} );
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
