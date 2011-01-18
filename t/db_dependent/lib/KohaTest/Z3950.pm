package KohaTest::Z3950;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Z3950;
sub testing_class { 'C4::Z3950' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( getz3950servers
                      z3950servername
                      addz3950queue
                      checkz3950searchdone
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

