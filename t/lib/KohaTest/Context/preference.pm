package KohaTest::Context::preference;
use base qw( KohaTest::Context );

use strict;
use warnings;

use Test::More;

use C4::Context;
sub testing_class { 'C4::Context' };


=head2 STARTUP METHODS

These get run once, before the main test methods in this module

=cut

=head2 TEST METHODS

standard test methods

=head3 preference_does_not_exist

=cut

sub preference_does_not_exist : Test( 1 ) {
    my $self = shift;

    my $missing = C4::Context->preference( 'doesnotexist' );

    is( $missing, undef, 'a query for a missing syspref returns undef' )
      or diag( Data::Dumper->Dump( [ $missing ], [ 'missing' ] ) );
    
}


=head3 version_preference

=cut

sub version_preference : Test( 1 ) {
    my $self = shift;

    my $version = C4::Context->preference( 'version' );

    ok( $version, 'C4::Context->preference returns a good version number' )
      or diag( Data::Dumper->Dump( [ $version ], [ 'version' ] ) );
    
}



1;
