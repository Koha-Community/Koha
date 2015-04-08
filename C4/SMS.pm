package C4::SMS;

# Copyright 2007 Liblime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

C4::SMS - send SMS messages

=head1 SYNOPSIS

my $success = C4::SMS->send_sms( message     => 'This is my text message',
                                 destination => '212-555-1212' );

=head1 DESCRIPTION



=cut

use strict;
use warnings;

use C4::Context;

use vars qw( $VERSION );

BEGIN {
    $VERSION = 3.07.00.049;
}

=head1 METHODS

=cut

# The previous implmentation used username and password.
# our $user = C4::Context->config('smsuser');
# our $pwd  = C4::Context->config('smspass');

=head2 send_sms

=cut

sub send_sms {
    my $self = shift;
    my $params= shift;

    foreach my $required_parameter ( qw( message destination ) ) {
        # Should I warn in some way?
        return unless defined $params->{ $required_parameter };
    }

    eval { require SMS::Send; };
    if ( $@ ) {
        # we apparently don't have SMS::Send. Return a failure.
        return;
    }

    # This allows the user to override the driver. See SMS::Send::Test
    my $driver = exists $params->{'driver'} ? $params->{'driver'} : $self->driver();
    return unless $driver;

    # warn "using driver: $driver to send message to $params->{'destination'}";

    my ($sent, $sender);
    eval {
        # Create a sender
        $sender = SMS::Send->new( $driver,
                                 _login    => C4::Context->preference('SMSSendUsername'),
                                 _password => C4::Context->preference('SMSSendPassword'),
                            );
    
        # Send a message
        $sent = $sender->send_sms( to   => $params->{'destination'},
                                  text => $params->{'message'},
                             );
    };
    #We might die because SMS::Send $driver is not defined or the sms-number has a bad format
    #Catch those errors and fail the sms-sending gracefully.
    if ($@) {
        warn $@;
        return;
    }
    # warn 'failure' unless $sent;
    return $sent;
}

=head2 driver

=cut

sub driver {
    my $self = shift;

    # return 'US::SprintPCS';
    return C4::Context->preference('SMSSendDriver');

}

1;

__END__

