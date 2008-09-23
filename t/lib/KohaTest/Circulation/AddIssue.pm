package KohaTest::Circulation::AddIssue;
use base qw(KohaTest::Circulation);

use strict;
use warnings;

use Test::More;

=head2 basic_usage

basic usage of C4::Circulation::AddIssue

Note: This logic is repeated in
KohaTest::Circulation::checkout_first_item, but without tests. This
includes tests at each step to make it easier to track down what's
broken as we go along.

=cut

sub basic_usage : Test( 11 ) {
    my $self = shift;

    my $borrowernumber = $self->{'memberid'};
    ok( $borrowernumber, "we're going to work with borrower: $borrowernumber" );

    my $borrower = C4::Members::GetMemberDetails( $borrowernumber );
    ok( $borrower, '...and we were able to look up that borrower' );
    is( $borrower->{'borrowernumber'}, $borrowernumber, '...and they have the right borrowernumber' );

    my $itemnumber = $self->{'items'}[0]{'itemnumber'};
    ok( $itemnumber, "We're going to checkout itemnumber $itemnumber" );
    my $barcode = $self->get_barcode_from_itemnumber($itemnumber);
    ok( $barcode, "...which has barcode $barcode" );

    my $before_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    # Note that we can't check for $before_issues as undef because GetItemIssue always returns a populated hashref
    ok( ! defined $before_issues->{'borrowernumber'}, '...and is not currently checked out' )
      or diag( Data::Dumper->Dump( [ $before_issues ], [ 'before_issues' ] ) );

    my ( $issuingimpossible, $needsconfirmation ) = C4::Circulation::CanBookBeIssued( $borrower, $barcode );
    is( scalar keys %$issuingimpossible, 0, 'the item CanBookBeIssued' )
      or diag( Data::Dumper->Dump( [ $issuingimpossible, $needsconfirmation ], [ qw( issuingimpossible needsconfirmation ) ] ) );
    is( scalar keys %$needsconfirmation, 0, '...and the transaction does not needsconfirmation' )
      or diag( Data::Dumper->Dump( [ $issuingimpossible, $needsconfirmation ], [ qw( issuingimpossible needsconfirmation ) ] ) );

    my $datedue = C4::Circulation::AddIssue( $borrower, $barcode );
    ok( $datedue, "the item has been issued and it is due: $datedue" );
    
    my $after_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    is( $after_issues->{'borrowernumber'}, $borrowernumber, '...and now it is checked out to our borrower' )
      or diag( Data::Dumper->Dump( [ $after_issues ], [ 'after_issues' ] ) );

    my $loanlength = Date::Calc::Delta_Days( split( /-/, $after_issues->{'issuedate'} ), split( /-/, $after_issues->{'date_due'} ) );
    ok( $loanlength, "the loanlength is $loanlength days" );

    # save this here since we refer to it in set_issuedate.
    $self->{'loanlength'} = $loanlength;

}

=head2 set_issuedate

Make sure that we can set the issuedate of an issue.

Also, since we are specifying an issuedate and not a due date, the due
date should be calculated from the issuedate, not today.

=cut

sub set_issuedate : Test( 7 ) {
    my $self = shift;

    my $before_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    ok( ! defined $before_issues->{'borrowernumber'}, 'At this beginning, this item was not checked out.' )
      or diag( Data::Dumper->Dump( [ $before_issues ], [ 'before_issues' ] ) );

    my $issuedate = $self->random_date();
    ok( $issuedate, "Check out an item on $issuedate" );
    my $datedue = $self->checkout_first_item( { issuedate => $issuedate } );
    ok( $datedue, "...and it's due on $datedue" );

    my $after_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    is( $after_issues->{'borrowernumber'}, $self->{'memberid'}, 'We found this item checked out to our member.' )
      or diag( Data::Dumper->Dump( [ $after_issues ], [ 'issues' ] ) );
    is( $after_issues->{'issuedate'}, $issuedate, "...and it was issued on $issuedate" )
      or diag( Data::Dumper->Dump( [ $after_issues ], [ 'after_issues' ] ) );
    
    my $loanlength = Date::Calc::Delta_Days( split( /-/, $after_issues->{'issuedate'} ), split( /-/, $after_issues->{'date_due'} ) );
    ok( $loanlength, "the loanlength is $loanlength days" );
    is( $loanlength, $self->{'loanlength'} );
}

sub set_lastreneweddate_on_renewal : Test( 6 ) {
    my $self = shift;

    my $before_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    ok( ! defined $before_issues->{'borrowernumber'}, 'At this beginning, this item was not checked out.' )
      or diag( Data::Dumper->Dump( [ $before_issues ], [ 'before_issues' ] ) );

    my $datedue = $self->checkout_first_item( { issuedate => $self->yesterday() } );
    ok( $datedue, "The item is checked out and it's due on $datedue" );

    my $issuedate = $self->random_date();
    ok( $issuedate, "Check out an item again on $issuedate" );
    # This will actually be a renewal
    $datedue = $self->checkout_first_item( { issuedate => $issuedate } );
    ok( $datedue, "...and it's due on $datedue" );

    my $after_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    is( $after_issues->{'borrowernumber'}, $self->{'memberid'}, 'We found this item checked out to our member.' )
      or diag( Data::Dumper->Dump( [ $after_issues ], [ 'issues' ] ) );
    is( $after_issues->{'lastreneweddate'}, $issuedate, "...and it was renewed on $issuedate" )
      or diag( Data::Dumper->Dump( [ $after_issues ], [ 'after_issues' ] ) );
    
}

1;
