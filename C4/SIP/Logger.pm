package C4::SIP::Logger;

use Modern::Perl;

use base 'Exporter';
our @EXPORT_OK = qw ( get_logger set_logger );

our $activeSIPServer;
our $activeLogger;

=head1 NAME

C4::SIP::Logger - Module for handling SIP server logging

=head2 get_SIPServer

    my $sipServer = C4::SIP::SIPServer::get_SIPServer()

    @RETURNS C4::SIP::SIPServer, the current server's child-process used to handle this SIP-transaction

=cut

sub get_SIPServer {
    return $activeSIPServer;
}

=head2 _set_SIPServer

    my $sipServer = C4::SIP::SIPServer::_set_SIPServer($sipServer)

    Sets the passed in SIP server as the active SIP server and returns it as well

    @RETURNS C4::SIP::SIPServer, the current server's child-process used to handle this SIP-transaction

=cut

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

=head2 set_logger

    my $logger = C4::SIP::SIPServer::set_logger($logger)

=cut

sub set_logger {
    my ($logger) = @_;
    $activeLogger = $logger;
    return $activeLogger;
}

1;

__END__
