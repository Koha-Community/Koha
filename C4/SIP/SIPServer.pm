package SIPServer;

use strict;
use warnings;
use Exporter;
use Sys::Syslog qw(syslog);
use Net::Server::PreFork;
use IO::Socket::INET;
use Socket;
use Data::Dumper;		# For debugging
require UNIVERSAL::require;

#use Sip qw(readline);
use Sip::Constants qw(:all);
use Sip::Configuration;
use Sip::Checksum qw(checksum verify_cksum);
use Sip::MsgType;

use constant LOG_SIP => "local6"; # Local alias for the logging facility

our @ISA = qw(Net::Server::PreFork);
#
# Main
#

my %transports = (
    RAW    => \&raw_transport,
    telnet => \&telnet_transport,
    http   => \&http_transport,
);

# Read configuration

my $config = new Sip::Configuration $ARGV[0];

my @parms;

#
# Ports to bind
#
foreach my $svc (keys %{$config->{listeners}}) {
    push @parms, "port=" . $svc;
}

#
# Logging
#
push @parms, "log_file=Sys::Syslog", "syslog_ident=acs-server",
  "syslog_facility=" . LOG_SIP;

#
# Server Management: set parameters for the Net::Server::PreFork
# module.  The module silently ignores parameters that it doesn't
# recognize, and complains about invalid values for parameters
# that it does.
#
if (defined($config->{'server-params'})) {
    while (my ($key, $val) = each %{$config->{'server-params'}}) {
	push @parms, $key . '=' . $val;
    }
}

print Dumper(@parms);

#
# This is the main event.
SIPServer->run(@parms);

#
# Child
#

# process_request is the callback used by Net::Server to handle
# an incoming connection request.

sub process_request {
    my $self = shift;
    my $service;
    my $sockname;
    my ($sockaddr, $port, $proto);
    my $transport;

    $self->{config} = $config;

    $sockname = getsockname(STDIN);
    ($port, $sockaddr) = sockaddr_in($sockname);
    $sockaddr = inet_ntoa($sockaddr);
    $proto = $self->{server}->{client}->NS_proto();

    $self->{service} = $config->find_service($sockaddr, $port, $proto);

    if (!defined($self->{service})) {
	syslog("LOG_ERR", "process_request: Unknown recognized server connection: %s:%s/%s", $sockaddr, $port, $proto);
	die "process_request: Bad server connection";
    }

    $transport = $transports{$self->{service}->{transport}};

    if (!defined($transport)) {
	syslog("LOG_WARN", "Unknown transport '%s', dropping", $service->{transport});
	return;
    } else {
	&$transport($self);
    }
}

#
# Transports
#

sub raw_transport {
    my $self = shift;
    my ($uid, $pwd);
    my $input;
    my $service = $self->{service};
    my $strikes = 3;
    my $expect;
    my $inst;

    eval {
	local $SIG{ALRM} = sub { die "alarm\n"; };
	syslog("LOG_DEBUG", "raw_transport: timeout is %d",
	       $service->{timeout});
	while ($strikes--) {
	    alarm $service->{timeout};
	    $input = Sip::read_SIP_packet(*STDIN);
	    alarm 0;
	if (!$input) {
		# EOF on the socket
		syslog("LOG_INFO", "raw_transport: shutting down: EOF during login");
		return;
	    }

	    $input =~ s/[\r\n]+$//sm;	# Strip off trailing line terminator

	    last if Sip::MsgType::handle($input, $self, LOGIN);
	}
    };

    if ($@) {
	syslog("LOG_ERR", "raw_transport: LOGIN ERROR: '$@'");
	die "raw_transport: login error, exiting";
    } elsif (!$self->{account}) {
	syslog("LOG_ERR", "raw_transport: LOGIN FAILED");
	die "raw_transport: Login failed, exiting";
    }

    syslog("LOG_DEBUG", "raw_transport: uname/inst: '%s/%s'",
	   $self->{account}->{id},
	   $self->{account}->{institution});

    $self->sip_protocol_loop();

    syslog("LOG_INFO", "raw_transport: shutting down");
}

sub telnet_transport {
    my $self = shift;
    my ($uid, $pwd);
    my $strikes = 3;
    my $account = undef;
    my $input;
    my $config = $self->{config};

    # Until the terminal has logged in, we don't trust it
    # so use a timeout to protect ourselves from hanging.
    eval {
	local $SIG{ALRM} = sub { die "alarm\n"; };
	local $|;
	my $timeout = 0;
	$| = 1;			# Unbuffered output
	$timeout = $config->{timeout} if (exists($config->{timeout}));

	while ($strikes--) {
	    print "login: ";
	    alarm $timeout;
	    $uid = <STDIN>;
	    alarm 0;

	    print "password: ";
	    alarm $timeout;
	    $pwd = <STDIN>;
	    alarm 0;

	    $uid =~ s/[\r\n]+$//;
	    $pwd =~ s/[\r\n]+$//;

	    if (exists($config->{accounts}->{$uid})
		&& ($pwd eq $config->{accounts}->{$uid}->password())) {
		$account = $config->{accounts}->{$uid};
		last;
	    } else {
		syslog("LOG_WARNING", "Invalid login attempt: '%s'", $uid);
		print("Invalid login\n");
	    }
	}
    }; # End of eval

    if ($@) {
	syslog("LOG_ERR", "telnet_transport: Login timed out");
	die "Telnet Login Timed out";
    } elsif (!defined($account)) {
	syslog("LOG_ERR", "telnet_transport: Login Failed");
	die "Login Failure";
    } else {
	print "Login OK.  Initiating SIP\n";
    }

    $self->{account} = $account;

    $self->sip_protocol_loop();
    syslog("LOG_INFO", "telnet_transport: shutting down");
}


sub http_transport {
}

#
# The terminal has logged in, using either the SIP login process
# over a raw socket, or via the pseudo-unix login provided by the
# telnet transport.  From that point on, both the raw and the telnet
# processes are the same:
sub sip_protocol_loop {
    my $self = shift;
    my $expect;
    my $service = $self->{service};
    my $config = $self->{config};
    my $input;
    # Now that the terminal has logged in, the first message
    # we recieve must be an SC_STATUS message.  But it might be
    # an SC_REQUEST_RESEND.  So, as long as we keep receiving
    # SC_REQUEST_RESEND, we keep waiting for an SC_STATUS

    # Comprise reports that no other ILS actually enforces this
    # constraint, so we'll relax about it too.  As long as everybody
    # uses the SIP "raw" login process, rather than telnet, this
    # will be fine, becaues the LOGIN protocol exchange will force
    # us into SIP 2.00 anyway.  Machines that want to log in using
    # telnet MUST send an SC Status message first, even though we're
    # not enforcing it.
    # 
    #$expect = SC_STATUS;
    $expect = '';

    while ($input = Sip::read_SIP_packet(*STDIN)) {
	my $status;

	$input =~ s/[\r\n]+$//sm;	# Strip off any trailing line ends

	$status = Sip::MsgType::handle($input, $self, $expect);
	next if $status eq REQUEST_ACS_RESEND;
#### stopped here rch
	if (!$status) {
	    syslog("LOG_ERR", "raw_transport: failed to handle %s",
		   substr($input, 0, 2));
	    die "raw_transport: dying";
	} elsif ($expect && ($status ne $expect)) {
	    # We received a non-"RESEND" that wasn't what we were
	    # expecting.
	    syslog("LOG_ERR",
		   "raw_transport: expected %s, received %s, exiting",
		   $expect, $input);
	    die "raw_transport: exiting: expected '$expect', received '$status'";
	}
	# We successfully received and processed what we were expecting
	# to receive
	$expect = '';
    }
}
