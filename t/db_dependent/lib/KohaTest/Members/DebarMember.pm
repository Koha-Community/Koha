package KohaTest::Members::DebarMember;
use base qw( KohaTest::Members );

use strict;
use warnings;

use Test::More;

use C4::Members;
sub testing_class { 'C4::Members' };


sub simple_usage : Test( 6 ) {
    my $self = shift;

    ok( $self->{'memberid'}, 'we have a valid memberid to test with' );

    my $details = C4::Members::GetMemberDetails( $self->{'memberid'} );
    ok(     exists $details->{'flags'},                  'member details has a "flags" attribute');
    isa_ok( $details->{'flags'},                 'HASH', 'the "flags" attribute is a hashref');
    ok(     ! $details->{'flags'}->{'DBARRED'},          'this member is NOT debarred' );

    # Now, let's debar this member and see what happens
    my $success = C4::Members::DebarMember( $self->{'memberid'} );

    ok( $success, 'we were able to debar the member' );
    
    $details = C4::Members::GetMemberDetails( $self->{'memberid'} );
    ok( $details->{'flags'}->{'DBARRED'},         'this member is debarred now' )
      or diag( Data::Dumper->Dump( [ $details->{'flags'} ], [ 'flags' ] ) );
}

sub incorrect_usage : Test( 2 ) {
    my $self = shift;

    my $result = C4::Members::DebarMember();
    ok( ! defined $result, 'DebarMember returns undef when passed no parameters' );

    $result = C4::Members::DebarMember( 'this is not a borrowernumber' );
    ok( ! defined $result, 'DebarMember returns undef when not passed a numeric argument' );

}

1;
