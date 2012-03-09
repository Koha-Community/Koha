package KohaTest::Letters;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Members;
sub testing_class { 'C4::Letters' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( addalert
                      delalert
                      getalert
                      findrelatedto
                      SendAlerts
                      GetPreparedLetter
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

