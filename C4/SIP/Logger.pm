#!/usr/bin/perl
package C4::SIP::Logger;

use Modern::Perl;

our $activeSIPServer;
our $activeLogger;

=head2 get_SIPServer

    my $sipServer = C4::SIP::SIPServer::get_SIPServer()

@RETURNS C4::SIP::SIPServer, the current server's child-process used to handle this SIP-transaction

=cut

sub get_SIPServer {
    return $activeSIPServer;
}

sub _set_SIPServer {
    my ($sipServer) = @_;
    $activeSIPServer = $sipServer;
    return $activeSIPServer;
}

=head2 get_logger

    my $logger = C4::SIP::SIPServer::get_logger()

@RETURNS Koha::Logger, the logger used to log this SIP-transaction

=cut

sub get_logger {
    return $activeLogger;
}

sub set_logger {
    my ($logger) = @_;
    $activeLogger = $logger;
    return $activeLogger;
}

1;

__END__
