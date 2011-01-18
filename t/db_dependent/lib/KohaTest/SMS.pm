package KohaTest::SMS;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::SMS;
sub testing_class { 'C4::SMS' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw( send_sms
                      driver
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

