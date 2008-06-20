package KohaTest::Letters;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Members;
sub testing_class { 'C4::Letters' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( getletter
                      addalert
                      delalert
                      getalert
                      findrelatedto
                      SendAlerts
                      parseletter
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

