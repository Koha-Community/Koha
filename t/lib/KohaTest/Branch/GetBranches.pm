package KohaTest::Branch::GetBranches;
use base qw( KohaTest::Branch );

use strict;
use warnings;

use Test::More;

use C4::Branch;

=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut

=head2 TEST METHODS

standard test methods

=head3 onlymine

    When you pass in something true to GetBranches, it limits the
    response to only your branch.

=cut

sub onlymine : Test( 4 ) {
    my $self = shift;

    # C4::Branch::GetBranches uses this variable, so make sure it exists.
    ok( C4::Context->userenv->{'branch'}, 'we have a branch' );
    my $branches = C4::Branch::GetBranches( 'onlymine' );
    # diag( Data::Dumper->Dump( [ $branches ], [ 'branches' ] ) );
    is( scalar( keys %$branches ), 1, 'one key for our branch only' );
    ok( exists $branches->{ C4::Context->userenv->{'branch'} }, 'my branch was returned' );
    is( $branches->{ C4::Context->userenv->{'branch'} }->{'branchcode'}, C4::Context->userenv->{'branch'}, 'branchcode' );
    
}

1;
