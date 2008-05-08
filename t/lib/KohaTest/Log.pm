package KohaTest::Log;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Log;
sub testing_class { 'C4::Log' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( logaction 
                       GetLogStatus 
                       displaylog 
                       GetLogs 
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

