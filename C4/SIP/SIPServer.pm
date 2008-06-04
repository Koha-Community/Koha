package SIPServer;

use strict;
use warnings;
# use Exporter;
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

use vars qw(@ISA $VERSION);

BEGIN {
	$VERSION = 1.01;
	@ISA = qw(Net::Server::PreFork);
}

#
# Main	# not really, since package SIPServer
#
# FIXME: Is this a module or a script?  
# A script with no MAIN namespace?
# A module that takes command line args?

my %transports = (
    RAW    => \&raw_transport,
    telnet => \&telnet_transport,
    # http   => \&http_transport,	# for http just use the OPAC
);

#
# Read configuration
#
my $config = new Sip::Configuration $ARGV[0];
print STDERR "SIPServer config: \n" . Dumper($config) . "\nEND SIPServer config.\n";
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

print "Params for Net::Server::PreFork : \n" . Dumper(@parms);

#
# This is the main event.
__PACKAGE__ ->run(@parms);

#
# Child
#

# process_request is the callback used by Net::Server to handle
# an incoming connection request.

sub process_request {
    my $self = shift;
    my $service;
    my ($sockaddr, $port, $proto);
    my $transport;

    $self->{config} = $config;

    my $sockname = getsockname(STDIN);
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
		syslog("LOG_WARNING", "Unknown transport '%s', dropping", $service->{transport});
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
    my ($input);
    my $service = $self->{service};
    my $strikes = 3;

    eval {
		local $SIG{ALRM} = sub { die "Timed Out!\n"; };
		syslog("LOG_DEBUG", "raw_transport: timeout is %d", $service->{timeout});
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

    if (length $@) {
		syslog("LOG_ERR", "raw_transport: LOGIN ERROR: '$@'");
		die "raw_transport: login error (timeout? $@), exiting";
    } elsif (!$self->{account}) {
		syslog("LOG_ERR", "raw_transport: LOGIN FAILED");
		die "raw_transport: Login failed (no account), exiting";
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
    my $config  = $self->{config};
	my $timeout = $self->{service}->{timeout} || $config->{timeout} || 30;
	# syslog("LOG_DEBUG", "telnet_transport: timeout is %s", $timeout);

    eval {
	local $SIG{ALRM} = sub { die "Timed Out ($timeout seconds)!\n"; };
	local $| = 1;			# Unbuffered output
    # Until the terminal has logged in, we don't trust it
    # so use a timeout to protect ourselves from hanging.

	while ($strikes--) {
	    print "login: ";
		alarm $timeout;
		$uid = <STDIN>;
		alarm 0;

		if (defined $uid) {
	    print "password: ";
		alarm $timeout;
	    $pwd = <STDIN> || '';
		alarm 0;

		syslog("LOG_DEBUG", "telnet_transport 1: uid length %s, pwd length %s", length($uid), length($pwd));
		while (chomp($uid)) {1;}
		while (chomp($pwd)) {1;}
		syslog("LOG_DEBUG", "telnet_transport 2: uid length %s, pwd length %s", length($uid), length($pwd));
		$uid =~ s/^\s+//;			# 
		$pwd =~ s/^\s+//;			# 
	    $uid =~ s/[\r\n]+$//gms;	# 
	    $pwd =~ s/[\r\n]+$//gms;	# 
	    $uid =~ s/[[:cntrl:]]//g;	# 
	    $pwd =~ s/[[:cntrl:]]//g;	# 
		syslog("LOG_DEBUG", "telnet_transport 3: uid length %s, pwd length %s", length($uid), length($pwd));

	    if (exists ($config->{accounts}->{$uid})
		&& ($pwd eq $config->{accounts}->{$uid}->password())) {
			$account = $config->{accounts}->{$uid};
			last;
	    }
		}
		syslog("LOG_WARNING", "Invalid login attempt: '%s'", ($uid||''));
		print("Invalid login\n");
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
    syslog("LOG_DEBUG", "telnet_transport: uname/inst: '%s/%s'", $account->{id}, $account->{institution});
    $self->sip_protocol_loop();
    syslog("LOG_INFO", "telnet_transport: shutting down");
}

#
# The terminal has logged in, using either the SIP login process
# over a raw socket, or via the pseudo-unix login provided by the
# telnet transport.  From that point on, both the raw and the telnet
# processes are the same:
sub sip_protocol_loop {
	my $self = shift;
	my $service = $self->{service};
	my $config  = $self->{config};
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
    #my $expect = SC_STATUS;
    my $expect = '';
    my $strikes = 3;
    while ($input = Sip::read_SIP_packet(*STDIN)) {
		# begin cheap input hacks
		$input =~ s/^\s+//;			# Kill leading whitespace... a cheap stand in for better Telnet layer
		$input =~ s/[\r\n]+$//sm;	# Strip off any trailing line ends (chomp?)
		while (chomp($input)) {warn "Extra line ending on input";}
		unless ($input) {
			if ($strikes--) {
				syslog("LOG_ERR", "sip_protocol_loop: empty input skipped");
				next;
			} else {
				syslog("LOG_ERR", "sip_protocol_loop: quitting after too many errors");
				die "sip_protocol_loop: quitting after too many errors";
			}
		}
		# end cheap input hacks
		my $status = Sip::MsgType::handle($input, $self, $expect);
		if (!$status) {
			syslog("LOG_ERR", "sip_protocol_loop: failed to handle %s",substr($input,0,2));
			die "sip_protocol_loop: failed Sip::MsgType::handle('$input', $self, '$expect')";
		}
		next if $status eq REQUEST_ACS_RESEND;
		if ($expect && ($status ne $expect)) {
			# We received a non-"RESEND" that wasn't what we were expecting.
		    syslog("LOG_ERR", "sip_protocol_loop: expected %s, received %s, exiting", $expect, $input);
			die "sip_protocol_loop: exiting: expected '$expect', received '$status'";
		}
		# We successfully received and processed what we were expecting
		$expect = '';
	}
}

1;
__END__
