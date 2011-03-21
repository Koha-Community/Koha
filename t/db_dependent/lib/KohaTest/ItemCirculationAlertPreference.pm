package KohaTest::ItemCirculationAlertPreference;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::ItemCirculationAlertPreference;
sub testing_class { 'C4::ItemCirculationAlertPreference' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( 
                    new
                    create
                    delete
                    is_enabled_for
                    find
                    grid
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;
