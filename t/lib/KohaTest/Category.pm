package KohaTest::Category;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Category;
sub testing_class { 'C4::Category' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( 
                    new
                    all
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;
