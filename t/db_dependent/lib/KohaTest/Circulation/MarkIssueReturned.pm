package KohaTest::Circulation::MarkIssueReturned;
use base qw(KohaTest::Circulation);

use strict;
use warnings;

use Test::More;

=head2 basic_usage

basic usage of C4::Circulation::MarkIssueReturned

=cut

sub basic_usage : Test( 4 ) {
    my $self = shift;

    my $before_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    ok( ! defined $before_issues->{'borrowernumber'}, 'our item is not checked out' )
      or diag( Data::Dumper->Dump( [ $before_issues ], [ 'before_issues' ] ) );

    my $datedue = $self->checkout_first_item();
    ok( $datedue, "Now it is checked out and due on $datedue" );

    my $after_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    is( $after_issues->{'borrowernumber'}, $self->{'memberid'}, 'Our item is checked out to our borrower' )
      or diag( Data::Dumper->Dump( [ $after_issues ], [ 'after_issues' ] ) );

    C4::Circulation::MarkIssueReturned( $self->{'memberid'}, $self->{'items'}[0]{'itemnumber'} );

    my $after_return = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    ok( ! defined $after_return->{'borrowernumber'}, 'The item is no longer checked out' )
      or diag( Data::Dumper->Dump( [ $after_return ], [ 'after_return' ] ) );

}

=head2 set_returndate

check an item out, then, check it back in, specifying the returndate.

verify that it's checked back in and the returndate is correct.

=cut

sub set_retundate : Test( 7 ) {
    my $self = shift;

    # It's not checked out to start with
    my $before_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    ok( ! defined $before_issues->{'borrowernumber'}, 'our item is not checked out' )
      or diag( Data::Dumper->Dump( [ $before_issues ], [ 'before_issues' ] ) );

    # check it out
    my $datedue = $self->checkout_first_item();
    ok( $datedue, "Now it is checked out and due on $datedue" );

    # verify that it has been checked out
    my $after_issues = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    is( $after_issues->{'borrowernumber'}, $self->{'memberid'}, 'Our item is checked out to our borrower' )
      or diag( Data::Dumper->Dump( [ $after_issues ], [ 'after_issues' ] ) );

    # mark it as returned on some date
    my $returndate = $self->random_date();
    ok( $returndate, "return this item on $returndate" );

    C4::Circulation::MarkIssueReturned( $self->{'memberid'},
                                        $self->{'items'}[0]{'itemnumber'},
                                        undef,
                                        $returndate );

    # validate that it is no longer checked out.
    my $after_return = C4::Circulation::GetItemIssue( $self->{'items'}[0]{'itemnumber'} );
    ok( ! defined $after_return->{'borrowernumber'}, 'The item is no longer checked out' )
      or diag( Data::Dumper->Dump( [ $after_return ], [ 'after_return' ] ) );

    # grab the history for this item and make sure it looks right
    my $history = C4::Circulation::GetItemIssues( $self->{'items'}[0]{'itemnumber'}, 1 );
    is( scalar @$history, 1, 'this item has been checked out one time.' )
      or diag( Data::Dumper->Dump( [ $history ], [ 'history' ] ) );
    is( $history->[0]{'returndate'}, $returndate, "...and it was returned on $returndate" );
    
}


1;
