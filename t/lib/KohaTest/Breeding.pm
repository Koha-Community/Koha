package KohaTest::Breeding;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Breeding;
sub testing_class { 'C4::Breeding' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( ImportBreeding 
                      BreedingSearch 
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

