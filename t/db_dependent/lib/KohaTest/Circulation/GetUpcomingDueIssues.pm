package KohaTest::Circulation::GetUpcomingDueIssues;
use base qw(KohaTest::Circulation);

use strict;
use warnings;

use Test::More;

=head2 basic_usage

basic usage of C4::Circulation::GetUpcomingDueIssues()

=cut

sub basic_usage : Test(2) {
    my $self = shift;

    my $upcoming = C4::Circulation::GetUpcomingDueIssues();
    isa_ok( $upcoming, 'ARRAY' );

    is( scalar @$upcoming, 0, 'no issues yet' )
      or diag( Data::Dumper->Dump( [$upcoming], ['upcoming'] ) );
}


1;
