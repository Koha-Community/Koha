package KohaTest::SMS::send_sms;
use base qw( KohaTest::SMS );

use strict;
use warnings;

use Test::More;

use C4::SMS;
sub testing_class { 'C4::SMS' };


sub send_a_message : Test( 2 ) {
    my $self = shift;

    my $success = C4::SMS->send_sms( { destination => '+1 212-555-1111',
                                       message     => 'This is the message',
                                       driver      => 'Test' } );

    ok( $success, "send_sms returned a true: $success" );
    
}


1;
