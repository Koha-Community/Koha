package KohaTest::ItemType;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::ItemType;
sub testing_class { 'C4::ItemType' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( 
                    new
                    all
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;
