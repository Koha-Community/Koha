package KohaTest::Scripts::longoverdue;
use base qw( KohaTest::Scripts );

use strict;
use warnings;

use Test::More;
use Time::localtime;


=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=head3 create_overdue_item

=cut

sub create_overdue_item : Test( startup => 12 ) {
    my $self = shift;
    
    $self->add_biblios( add_items => 1 );
    
    my $biblionumber = $self->{'biblios'}[0];
    ok( $biblionumber, 'biblionumber' );
    my @biblioitems = C4::Biblio::GetBiblioItemByBiblioNumber( $biblionumber );
    ok( scalar @biblioitems > 0, 'there is at least one biblioitem' );
    my $biblioitemnumber = $biblioitems[0]->{'biblioitemnumber'};
    ok( $biblioitemnumber, 'got a biblioitemnumber' );

    my $items = C4::Items::GetItemsByBiblioitemnumber( $biblioitemnumber);
                           
    my $itemnumber = $items->[0]->{'itemnumber'};
    ok( $items->[0]->{'itemnumber'}, 'item number' );

    $self->{'overdueitemnumber'} = $itemnumber;
    
}

sub set_overdue_item_lost : Test( 12 ) {
    my $self = shift;

    my $item = C4::Items::GetItem( $self->{'overdueitemnumber'} );
    is( $item->{'itemnumber'}, $self->{'overdueitemnumber'}, 'itemnumber' );

    ok( exists $item->{'itemlost'}, 'itemlost exists' );
    ok( ! $item->{'itemlost'}, 'item is not lost' );

    # This is a US date, but that's how C4::Dates likes it, apparently.
    my $duedatestring = sprintf( '%02d/%02d/%04d',
                                 localtime->mon() + 1,
                                 localtime->mday(),
                                 localtime->year() + 1900 - 1, # it was due a year ago.
                            );
    my $duedate = C4::Dates->new( $duedatestring );
    # diag( Data::Dumper->Dump( [ $duedate ], [ 'duedate' ] ) );
    
    ok( $item->{'barcode'}, 'barcode' )
      or diag( Data::Dumper->Dump( [ $item ], [ 'item' ] ) );
    # my $item_from_barcode = C4::Items::GetItem( undef, $item->{'barcode'} );
    # diag( Data::Dumper->Dump( [ $item_from_barcode ], [ 'item_from_barcode' ] ) );

    my $borrower = C4::Members::GetMember( $self->{'memberid'} );
    ok( $borrower->{'borrowernumber'}, 'borrowernumber' );
    
    my ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $borrower, $item->{'barcode'}, $duedate, 0 );
    # diag( Data::Dumper->Dump( [ $issuingimpossible, $needsconfirmation ], [ qw( issuingimpossible needsconfirmation ) ] ) );
    is( keys %$issuingimpossible, 0, 'issuing is not impossible' );
    is( keys %$needsconfirmation, 0, 'issuing needs no confirmation' );

    my $issue_due_date = C4::Circulation::AddIssue( $borrower, $item->{'barcode'}, $duedate );
    TODO: {
        local $TODO = 'C4::Circulation::AddIssue returns undef insead of the due date';
        ok( $issue_due_date, 'due date' );
    }
    
    # I have to make this in a different format since that's how the database holds it.
    my $duedateyyyymmdd = sprintf( '%04d-%02d-%02d',
                                   localtime->year() + 1900 - 1, # it was due a year ago.
                                   localtime->mon() + 1,
                                   localtime->mday(),
                              );

    my $issued_item = C4::Items::GetItem( $self->{'overdueitemnumber'} );
    is( $issued_item->{'onloan'}, $duedateyyyymmdd, "the item is checked out and due $duedatestring" );
    is( $issued_item->{'itemlost'}, 0, 'the item is not lost' );
    # diag( Data::Dumper->Dump( [ $issued_item ], [ 'issued_item' ] ) );

    qx( ../misc/cronjobs/longoverdue.pl --lost 90=2 --confirm );

    my $lost_item = C4::Items::GetItem( $self->{'overdueitemnumber'} );
    is( $lost_item->{'onloan'}, $duedateyyyymmdd, "the item is checked out and due $duedatestring" );
    is( $lost_item->{'itemlost'}, 2, 'the item is lost' );
    # diag( Data::Dumper->Dump( [ $lost_item ], [ 'lost_item' ] ) );

}


1;
