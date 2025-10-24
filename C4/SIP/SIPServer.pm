#!/usr/bin/perl

=head1 NAME
    C4::SIP::SIPServer
=cut

package C4::SIP::SIPServer;

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin";
use Net::Server::PreFork;
use IO::Socket::INET;
use Socket       qw(:DEFAULT :crlf TCP_KEEPIDLE TCP_KEEPINTVL IPPROTO_TCP);
use Scalar::Util qw(blessed);
require UNIVERSAL::require;

use C4::Context;
use C4::SIP::Sip            qw(siplog);
use C4::SIP::Sip::Constants qw(:all);
use C4::SIP::Sip::Configuration;
use C4::SIP::Sip::Checksum qw(checksum verify_cksum);
use C4::SIP::Sip::MsgType  qw( handle login_core );
use C4::SIP::Logger        qw(set_logger);

use Koha::Caches;
use Koha::Logger;

use C4::SIP::Trapper;
tie *STDERR, "C4::SIP::Trapper";

use base qw(Net::Server::PreFork);

use constant LOG_SIP => "local6";    # Local alias for the logging facility

set_logger( Koha::Logger->get( { interface => 'sip' } ) );

#
# Main  # not really, since package SIPServer
#
# FIXME: Is this a module or a script?
# A script with no MAIN namespace?
# A module that takes command line args?

# Set interface to 'sip'
C4::Context->interface('sip');

my %transports = (
    RAW    => \&raw_transport,
    telnet => \&telnet_transport,
);

#
# Read configuration
#
my $config = C4::SIP::Sip::Configuration->new( $ARGV[0] );
my @params;

#
# Ports to bind
#
foreach my $svc ( keys %{ $config->{listeners} } ) {
    push @params, "port=" . $svc;
}

#
# Logging
#
# Log lines look like this:
# Jun 16 21:21:31 server08 steve_sip[19305]: ILS::Transaction::Checkout performing checkout...
# [  TIMESTAMP  ] [ HOST ] [ IDENT ]  PID  : Message...
#
# The IDENT is determined by config file 'server-params' arguments

#
# Server Management: set parameters for the Net::Server::PreFork
# module.  The module silently ignores parameters that it doesn't
# recognize, and complains about invalid values for parameters
# that it does.
#
if ( defined( $config->{'server-params'} ) ) {
    while ( my ( $key, $val ) = each %{ $config->{'server-params'} } ) {
        push @params, $key . '=' . $val;
    }
}

# Add user and group to prevent warn from Net::Server.
push @params, 'user=' . $>;
push @params, 'group=' . $>;

#
# This is the main event.
__PACKAGE__->run(@params);

#
# Server
#

=head2 options

As per Net::Server documentation, override "options" to provide your own
custom options to the Net::Server* object. This allows us to use the Net::Server
infrastructure for configuration rather than hacking our own configuration into the
object.

=cut

sub options {
    my $self     = shift;
    my $prop     = $self->{'server'};
    my $template = shift;

    # setup options in the parent classes
    $self->SUPER::options($template);

    $prop->{'custom_tcp_keepalive'} ||= undef;
    $template->{'custom_tcp_keepalive'} = \$prop->{'custom_tcp_keepalive'};

    $prop->{'custom_tcp_keepalive_time'} ||= undef;
    $template->{'custom_tcp_keepalive_time'} = \$prop->{'custom_tcp_keepalive_time'};

    $prop->{'custom_tcp_keepalive_intvl'} ||= undef;
    $template->{'custom_tcp_keepalive_intvl'} = \$prop->{'custom_tcp_keepalive_intvl'};
}

=head2 post_configure_hook

As per Net::Server documentation, this method validates our custom configuration.

=cut

sub post_configure_hook {
    my $self = shift;
    my $prop = $self->{'server'};
    if ( defined $prop->{'custom_tcp_keepalive'} && $prop->{'custom_tcp_keepalive'} ) {

        #NOTE: Any true value defined is forced to 1 just for the sake of predictability
        $prop->{'custom_tcp_keepalive'} = 1;
    }

    foreach my $key ( 'custom_tcp_keepalive_time', 'custom_tcp_keepalive_intvl' ) {
        my $value = $prop->{$key};

        #NOTE: A regex is used here to detect a positive integer, as int() returns integers but does not validate them
        #NOTE: We do not allow zero as it can lead to problematic behaviour
        if ( $value && $value =~ /^\d+$/ ) {

            #NOTE: Strictly, you must convert into an integer as a string will cause setsockopt to fail
            $prop->{$key} = int($value);
        }
    }
}

=head2 post_accept_hook

This hook occurs after the client connection socket is created, which gives
us an opportunity to enable support for TCP keepalives using the SO_KEEPALIVE
socket option.

By default, the kernel-level defaults (in seconds) are used. You can view these in the output of "sysctl -a":
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_time = 7200

Alternatively, you can use "custom_tcp_keepalive_time" and "custom_tcp_keepalive_intvl" to define
your own custom values for the socket. Note that these parameters are defined at the top server-level
and not on the listener-level.

If you lower "custom_tcp_keepalive_time" below 75, you will also need to set "custom_tcp_keepalive_intvl".
The "tcp_keepalive_time" is the initial time used for the keepalive timer, and the "tcp_keepalive_intvl"
is the time used for subsequent keepalive timers. However, timers only send keepalive ACKs if the idle time
elapsed is greater than "tcp_keepalive_time".

Thus, if "tcp_keepalive_time = 10" and "tcp_keepalive_intvl = 5", a keepalive ACK will be sent every 10 seconds
of idle time. If "tcp_keepalive_intvl = 10" and "tcp_keepalive_time = 5", a keepalive ACK will be sent after 5
seconds of idle time, and the next keepalive ACK will be sent after 10 seconds of idle time. Generally speaking,
it's best to set "tcp_keepalive_time" to be higher than "tcp_keepalive_intvl".

Reminder: once these settings are set on the socket, they are handled by the operating system kernel, and not
by the SIP server application. If you are having trouble with your settings, monitor your TCP traffic using
a tool such as "tcpdump" to review and refine how they work.

=cut

sub post_accept_hook {
    my $self   = shift;
    my $prop   = $self->{'server'};
    my $client = shift || $prop->{'client'};

    my $tcp_keepalive       = $prop->{custom_tcp_keepalive};
    my $tcp_keepalive_time  = $prop->{custom_tcp_keepalive_time};
    my $tcp_keepalive_intvl = $prop->{custom_tcp_keepalive_intvl};

    if ($tcp_keepalive) {

        #NOTE: set the SO_KEEPALIVE option to enable TCP keepalives
        setsockopt( $client, SOL_SOCKET, SO_KEEPALIVE, 1 )
            or die "Unable to set SO_KEEPALIVE: $!";

        if ($tcp_keepalive_time) {

            #NOTE: override "net.ipv4.tcp_keepalive_time" kernel parameter for this socket
            setsockopt( $client, IPPROTO_TCP, TCP_KEEPIDLE, $tcp_keepalive_time )
                or die "Unable to set TCP_KEEPIDLE: $!";
        }

        if ($tcp_keepalive_intvl) {

            #NOTE: override "net.ipv4.tcp_keepalive_intvl" kernel parameter for this socket
            setsockopt( $client, IPPROTO_TCP, TCP_KEEPINTVL, $tcp_keepalive_intvl )
                or die "Unable to set TCP_KEEPINTVL: $!";
        }
    }
}

=head2 _config_up_to_date

    $server->_config_up_to_date();

Check if the configuration is up to date. Returns 1 if the configuration is up to date, 0 otherwise.

This method is used to check if the configuration stored in the database is different from
the one stored in the object. If the configuration in the database is newer, the method
returns 0 and the object must be updated.

=cut

sub _config_up_to_date {
    my ($self) = @_;

    my $cache                       = Koha::Caches->get_instance();
    my $sip2_resource_last_modified = $cache->get_from_cache("sip2_resource_last_modified");
    my $sip2_config_read_timestamp  = $cache->get_from_cache("sip2_config_read_timestamp");

    unless ($sip2_resource_last_modified) {
        siplog( "LOG_WARNING", "Couldn't find sip2_resource_last_modified, considering configuration not up to date" );
        return 0;
    }
    return $sip2_config_read_timestamp >= $sip2_resource_last_modified;
}

#
# Child
#

# process_request is the callback used by Net::Server to handle
# an incoming connection request.

sub process_request {
    my $self = shift;
    my $service;
    my ( $sockaddr, $port, $proto );
    my $transport;

    $self->{config} = $config;
    unless ( $self->_config_up_to_date() ) {
        $self->{config} = C4::SIP::Sip::Configuration->get_configuration( undef, $self->{config} );
    }

    # Flushing L1 to make sure the request will be processed using the correct data
    Koha::Caches->flush_L1_caches();

    $self->{account} = undef;    # Clear out the account from the last request, it may be different
    $self->{logger}  = set_logger( Koha::Logger->get( { interface => 'sip' } ) );

    # Flush previous MDCs to prevent accidentally leaking incorrect MDC-entries
    Koha::Logger->clear_mdc();

    my $sockname = getsockname(STDIN);

    # Check if socket connection is IPv6 before resolving address
    my $family = Socket::sockaddr_family($sockname);
    if ( $family == AF_INET6 ) {
        ( $port, $sockaddr ) = sockaddr_in6($sockname);
        $sockaddr = Socket::inet_ntop( AF_INET6, $sockaddr );
    } else {
        ( $port, $sockaddr ) = sockaddr_in($sockname);
        $sockaddr = inet_ntoa($sockaddr);
    }
    $proto = $self->{server}->{client}->NS_proto();

    $self->{service} = $config->find_service( $sockaddr, $port, $proto );

    if ( !defined( $self->{service} ) ) {
        siplog(
            "LOG_ERR", "process_request: Unknown recognized server connection: %s:%s/%s", $sockaddr, $port,
            $proto
        );
        die "process_request: Bad server connection";
    }

    $transport = $transports{ $self->{service}->{transport} };

    if ( !defined($transport) ) {
        siplog( "LOG_WARNING", "Unknown transport '%s', dropping", $service->{transport} );
        return;
    } else {
        &$transport($self);
    }
    return;
}

#
# Transports
#

sub raw_transport {
    my $self = shift;
    my $input;
    my $service = $self->{service};

    # If using Net::Server::PreFork you may already have account set from a previous session
    # Ensure you dont
    if ( $self->{account} ) {
        delete $self->{account};
    }

    # Timeout the while loop if we get stuck in it
    # In practice it should only iterate once but be prepared
    local $SIG{ALRM} = sub { die 'raw transport Timed Out!' };
    my $timeout = $self->get_timeout( { transport => 1 } );
    siplog( 'LOG_DEBUG', "raw_transport: timeout is $timeout" );
    alarm $timeout;
    while ( !$self->{account} ) {
        $input = read_request();
        if ( !$input ) {

            # EOF on the socket
            siplog( "LOG_INFO", "raw_transport: shutting down: EOF during login" );
            return;
        }
        $input =~ s/[\r\n]+$//sm;    # Strip off trailing line terminator(s)
        my $reg = qr/^${\(LOGIN)}/;
        last
            if $input !~ $reg
            || C4::SIP::Sip::MsgType::handle( $input, $self, LOGIN );
    }
    alarm 0;

    $self->{logger} = set_logger(
        Koha::Logger->get(
            {
                interface => 'sip',
                category  => $self->{account}->{id},    # Add id to namespace
            }
        )
    );

    # Set MDCs after properly authenticating
    Koha::Logger->put_mdc( "accountid", $self->{account}->{id} );
    Koha::Logger->put_mdc( "peeraddr",  $self->{server}->{peeraddr} );

    siplog(
        "LOG_DEBUG", "raw_transport: uname/inst: '%s/%s'",
        $self->{account}->{id}          // 'undef',
        $self->{account}->{institution} // 'undef'
    );
    if ( !$self->{account}->{id} ) {
        siplog( "LOG_ERR", "Login failed shutting down" );
        return;
    }

    $self->sip_protocol_loop();
    siplog( "LOG_INFO", "raw_transport: shutting down" );
    return;
}

sub get_clean_string {
    my $string = shift;
    if ( defined $string ) {
        siplog( "LOG_DEBUG", "get_clean_string  pre-clean(length %s): %s", length($string), $string );
        chomp($string);
        $string =~ s/^[^A-z0-9]+//;
        $string =~ s/[^A-z0-9]+$//;
        siplog( "LOG_DEBUG", "get_clean_string post-clean(length %s): %s", length($string), $string );
    } else {
        siplog( "LOG_INFO", "get_clean_string called on undefined" );
    }
    return $string;
}

sub get_clean_input {
    local $/ = "\012";
    my $in = <STDIN>;
    $in = get_clean_string($in);
    while ( my $extra = <STDIN> ) {
        siplog( "LOG_ERR", "get_clean_input got extra lines: %s", $extra );
    }
    return $in;
}

sub telnet_transport {
    my $self = shift;
    my ( $uid, $pwd );
    my $strikes = 3;
    my $account = undef;
    my $input;
    my $config  = $self->{config};
    my $timeout = $self->get_timeout( { transport => 1 } );
    siplog( "LOG_DEBUG", "telnet_transport: timeout is $timeout" );

    eval {
        local $SIG{ALRM} = sub { die "telnet_transport: Timed Out ($timeout seconds)!\n"; };
        local $| = 1;                                                                          # Unbuffered output
        $/ = "\015";    # Internet Record Separator (lax version)
                        # Until the terminal has logged in, we don't trust it
                        # so use a timeout to protect ourselves from hanging.

        while ( $strikes-- ) {
            print "login: ";
            alarm $timeout;

            # $uid = &get_clean_input;
            $uid = <STDIN>;
            print "password: ";

            # $pwd = &get_clean_input || '';
            $pwd = <STDIN>;
            alarm 0;

            siplog( "LOG_DEBUG", "telnet_transport 1: uid length %s, pwd length %s", length($uid), length($pwd) );
            $uid = get_clean_string($uid);
            $pwd = get_clean_string($pwd);
            siplog( "LOG_DEBUG", "telnet_transport 2: uid length %s, pwd length %s", length($uid), length($pwd) );

            # Check if user is authorized for SIP access, then authenticate via login_core
            if ( exists( $config->{accounts}->{$uid} ) ) {
                $account = $config->{accounts}->{$uid};
                if ( C4::SIP::Sip::MsgType::login_core( $self, $uid, $pwd ) ) {
                    last;
                }
            }
            siplog( "LOG_WARNING", "Invalid login attempt: '%s'", ( $uid || '' ) );
            print("Invalid login$CRLF");
        }
    };    # End of eval

    if ($@) {
        siplog( "LOG_ERR", "telnet_transport: Login timed out" );
        die "Telnet Login Timed out";
    } elsif ( !defined($account) ) {
        siplog( "LOG_ERR", "telnet_transport: Login Failed" );
        die "Login Failure";
    } else {
        print "Login OK.  Initiating SIP$CRLF";
    }

    $self->{account} = $account;
    siplog( "LOG_DEBUG", "telnet_transport: uname/inst: '%s/%s'", $account->{id}, $account->{institution} );
    $self->sip_protocol_loop();
    siplog( "LOG_INFO", "telnet_transport: shutting down" );
    return;
}

#
# The terminal has logged in, using either the SIP login process
# over a raw socket, or via the pseudo-unix login provided by the
# telnet transport.  From that point on, both the raw and the telnet
# processes are the same:
sub sip_protocol_loop {
    my $self    = shift;
    my $service = $self->{service};
    my $config  = $self->{config};
    my $timeout = $self->get_timeout( { client => 1 } );

    # The spec says the first message will be:
    #     SIP v1: SC_STATUS
    #     SIP v2: LOGIN (or SC_STATUS via telnet?)
    # But it might be SC_REQUEST_RESEND.  As long as we get
    # SC_REQUEST_RESEND, we keep waiting.

    # Comprise reports that no other ILS actually enforces this
    # constraint, so we'll relax about it too.
    # Using the SIP "raw" login process, rather than telnet,
    # requires the LOGIN message and forces SIP 2.00.  In that
    # case, the LOGIN message has already been processed (above).

    # In short, we'll take any valid message here.
    eval {
        local $SIG{ALRM} = sub {
            siplog( 'LOG_DEBUG', 'Inactive: timed out' );
            die "Timed Out!\n";
        };
        my $previous_alarm = alarm($timeout);

        while ( my $inputbuf = read_request() ) {
            if ( !defined $inputbuf ) {
                return;    #EOF
            }
            alarm($timeout);

            unless ($inputbuf) {
                siplog( "LOG_ERR", "sip_protocol_loop: empty input skipped" );
                print("96$CR");
                next;
            }

            my $status = C4::SIP::Sip::MsgType::handle( $inputbuf, $self, q{} );
            if ( !$status ) {
                siplog(
                    "LOG_ERR",
                    "sip_protocol_loop: failed to handle %s",
                    substr( $inputbuf, 0, 2 )
                );
            }
            next if $status eq REQUEST_ACS_RESEND;
        }
        alarm($previous_alarm);
        return;
    };
    if ( $@ =~ m/timed out/i ) {
        return;
    }
    return;
}

sub read_request {
    my $raw_length;
    local $/ = "\015";

    # SIP connections might be active for weeks, clear L1 cache on every request
    Koha::Caches->flush_L1_caches();

    # proper SPEC: (octal) \015 = (hex) x0D = (dec) 13 = (ascii) carriage return
    my $buffer = <STDIN>;
    if ( defined $buffer ) {
        STDIN->flush();    # clear an extra linefeed
        chomp $buffer;
        $raw_length = length $buffer;
        $buffer =~ s/^\s*[^A-z0-9]+//s;

        # Every line must start with a "real" character.  Not whitespace, control chars, etc.
        $buffer =~ s/[^A-z0-9]+$//s;

        # Same for the end.  Note this catches the problem some clients have sending empty fields at the end, like |||
        $buffer =~ s/\015?\012//g;     # Extra line breaks must die
        $buffer =~ s/\015?\012//s;     # Extra line breaks must die
        $buffer =~ s/\015*\012*$//s;

        # treat as one line to include the extra linebreaks we are trying to remove!
    } else {
        siplog( 'LOG_DEBUG', 'EOF returned on read' );
        return;
    }
    my $len = length $buffer;
    if ( $len != $raw_length ) {
        my $trim = $raw_length - $len;
        siplog( 'LOG_DEBUG', "read_request trimmed $trim character(s) " );
    }

    siplog( 'LOG_INFO', "INPUT MSG: '$buffer'" );
    return $buffer;
}

# $server->get_timeout({ $type => 1, fallback => $fallback });
#     where $type is transport | client | policy
#
# Centralizes all timeout logic.
# Transport refers to login process, client to active connections.
# Policy timeout is transaction timeout (used in ACS status message).
#
# Fallback is optional. If you do not pass transport, client or policy,
# you will get fallback or hardcoded default.

sub get_timeout {
    my ( $server, $params ) = @_;
    my $fallback = $params->{fallback} || 30;
    my $service  = $server->{service} // {};
    my $config   = $server->{config}  // {};

    if ( $params->{transport}
        || ( $params->{client} && !exists $service->{client_timeout} ) )
    {
        # We do not allow zero values here.
        # Note: config/timeout seems to be deprecated.
        return $service->{timeout} || $config->{timeout} || $fallback;

    } elsif ( $params->{client} ) {

        # We know that client_timeout exists now.
        # We do allow zero values here to indicate no timeout.
        return 0 if $service->{client_timeout} =~ /^0+$|\D/;
        return $service->{client_timeout};

    } elsif ( $params->{policy} ) {
        my $policy = $server->{policy} // {};
        my $rv     = sprintf( "%03d", $policy->{timeout} // 0 );
        if ( length($rv) != 3 ) {
            siplog( "LOG_ERR", "Policy timeout has wrong size: '%s'", $rv );
            return '000';
        }
        return $rv;

    } else {
        return $fallback;
    }
}

1;

__END__
