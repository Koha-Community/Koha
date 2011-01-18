package KohaTest::Print;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Print;
sub testing_class { 'C4::Print' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( remoteprint
                      printreserve 
                      printslip
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

