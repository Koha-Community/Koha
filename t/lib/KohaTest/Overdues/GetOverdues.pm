package KohaTest::Overdues::GetOverdues;
use base qw( KohaTest::Overdues );

use strict;
use warnings;

use C4::Overdues;
use Test::More;

=head3 create_overdue_item

=cut

sub startup_60_create_overdue_item : Test( startup => 17 ) {
    my $self = shift;
    
    $self->add_biblios( add_items => 1 );
    
    my $biblionumber = $self->{'biblios'}[0];
    ok( $biblionumber, 'biblionumber' );
    my @biblioitems = C4::Biblio::GetBiblioItemByBiblioNumber( $biblionumber );
    ok( scalar @biblioitems > 0, 'there is at least one biblioitem' );
    my $biblioitemnumber = $biblioitems[0]->{'biblioitemnumber'};
    ok( $biblioitemnumber, 'got a biblioitemnumber' );

    my $items = C4::Items::GetItemsByBiblioitemnumber( $biblioitemnumber);
                           
    my $item = $items->[0];
    ok( $item->{'itemnumber'}, 'item number' );
    $self->{'overdueitemnumber'} = $item->{'itemnumber'};
    
    # let's use the database to do date math for us.
    # This is a US date, but that's how C4::Dates likes it, apparently.
    my $dbh = C4::Context->dbh();
    my $date_list = $dbh->selectcol_arrayref( q( select DATE_FORMAT( FROM_DAYS( TO_DAYS( NOW() ) - 6 ), '%m/%d/%Y' ) ) );
    my $six_days_ago = shift( @$date_list );
    
    my $duedate = C4::Dates->new( $six_days_ago );
    # diag( Data::Dumper->Dump( [ $duedate ], [ 'duedate' ] ) );
    
    ok( $item->{'barcode'}, 'barcode' )
      or diag( Data::Dumper->Dump( [ $item ], [ 'item' ] ) );
    # my $item_from_barcode = C4::Items::GetItem( undef, $item->{'barcode'} );
    # diag( Data::Dumper->Dump( [ $item_from_barcode ], [ 'item_from_barcode' ] ) );

    ok( $self->{'memberid'}, 'memberid' );
    my $borrower = C4::Members::GetMember( $self->{'memberid'} );
    ok( $borrower->{'borrowernumber'}, 'borrowernumber' );
    
    my ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $borrower, $item->{'barcode'}, $duedate, 0 );
    # diag( Data::Dumper->Dump( [ $issuingimpossible, $needsconfirmation ], [ qw( issuingimpossible needsconfirmation ) ] ) );
    is( keys %$issuingimpossible, 0, 'issuing is not impossible' );
    is( keys %$needsconfirmation, 0, 'issuing needs no confirmation' );

    C4::Circulation::AddIssue( $borrower, $item->{'barcode'}, $duedate );
}

sub basic_usage : Test( 2 ) {
    my $self = shift;

    my $overdues = C4::Overdues::Getoverdues();
    isa_ok( $overdues, 'ARRAY' );
    is( scalar @$overdues, 1, 'found our one overdue book' );
}

sub limit_minimum_and_maximum : Test( 2 ) {
    my $self = shift;

    my $overdues = C4::Overdues::Getoverdues( { minimumdays => 1, maximumdays => 100 } );
    isa_ok( $overdues, 'ARRAY' );
    is( scalar @$overdues, 1, 'found our one overdue book' );
}

sub limit_and_do_not_find_it : Test( 2 ) {
    my $self = shift;

    my $overdues = C4::Overdues::Getoverdues( { minimumdays => 1, maximumdays => 2 } );
    isa_ok( $overdues, 'ARRAY' );
    is( scalar @$overdues, 0, 'there are no overdue books in that range.' );
}

=pod

sub run_overduenotices_script : Test( 1 ) {
    my $self = shift;

    # make sure member wants alerts
    C4::Members::Attributes::UpdateBorrowerAttribute($self->{'memberid'},
                                                     { code  => 'PREDEmail',
                                                       value => '1' } );
    
    # we're screwing with C4::Circulation::GetUpcomingIssues by passing in a negative number.
    C4::Members::Attributes::UpdateBorrowerAttribute($self->{'memberid'},
                                                     { code  => 'PREDDAYS',
                                                       value => '-6' } );
    
    
    my $before_count = $self->count_message_queue();

    my $output = qx( ../misc/cronjobs/advance_notices.pl -c );
    
    my $after_count = $self->count_message_queue();
    is( $after_count, $before_count + 1, 'there is one more message in the queue than there used to be.' )
      or diag $output;
    
}


=cut

sub count_message_queue {
    my $self = shift;

    my $dbh = C4::Context->dbh();
    my $statement = q( select count(0) from message_queue where status = 'pending' );
    my $countlist = $dbh->selectcol_arrayref( $statement );
    return $countlist->[0];
}

1;






