#!/usr/bin/perl -w

# Copyright 2012 CatalystIT
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

use strict;
use warnings;

use Getopt::Long;

my ($help, $config, $daemon);

GetOptions(
    'config|c=s'    => \$config,
    'daemon|d'      => \$daemon,
    'help|?'        => \$help,
);

if($help || !$config){
    print <<EOF
$0 --config=my.conf
Parameters :
  --daemon | -d  - go to background; prints pid to stdout
  --config | -c  - config file
  --help   | -?  - this message

Config file format:
  Lines of the form:
  name: value

  # comments are supported
  No quotes

  Parameter Names:
  host     - ip address or hostname to bind to, defaults all available
  port     - port to bind to, mandatory
  log      - log file path, stderr if omitted
  debug    - dumps requests to the log file, passwords inclusive
  koha     - koha intranet base url, eg http://librarian.koha
  user     - koha user, authentication
  password - koha user password, authentication
  match          - marc_matchers.code: ISBN or ISSN
  overlay_action - import_batches.overlay_action: replace, create_new or ignore
  nomatch_action - import_batches.nomatch_action: create_new or ignore
  item_action    - import_batches.item_action:    always_add,
                      add_only_for_matches, add_only_for_new or ignore
  import_mode    - stage or direct
  framework      - to be used if import_mode is direct

  All process related parameters (all but ip and port) have default values as
  per Koha import process.
EOF
;
    exit;
}

my $server = ImportProxyServer->new($config);

if ($daemon) {
    print $server->background;
} else {
    $server->run;
}

exit;

{
package ImportProxyServer;

use Carp;
use IO::Socket::INET;
# use IO::Socket::IP;
use IO::Select;
use POSIX;
use HTTP::Status qw(:constants);
use strict;
use warnings;

use LWP::UserAgent;
use XML::Simple;
use MARC::Record;
use MARC::File::XML;

use constant CLIENT_READ_TIMEOUT     => 5;
use constant CLIENT_READ_BUFFER_SIZE => 100000;
use constant AUTH_URI       => "/cgi-bin/koha/mainpage.pl";
use constant IMPORT_SVC_URI => "/cgi-bin/koha/svc/import_bib";

sub new {
    my $class = shift;
    my $config_file = shift or croak "No config file";

    my $self = {time_to_die => 0, config_file => $config_file };
    bless $self, $class;

    $self->parse_config;
    return $self;
}

sub parse_config {
    my $self = shift;

    my $config_file = $self->{config_file};

    open (my $conf_fh, '<', $config_file) or die "Cannot open config file $config: $!";

    my %param;
    my $line = 0;
    while (<$conf_fh>) {
        $line++;
        chomp;
        s/\s*#.*//o; # remove comments
        s/^\s+//o;   # trim leading spaces
        s/\s+$//o;   # trim trailing spaces
        next unless $_;

        my ($p, $v) = m/(\S+?):\s*(.*)/o;
        die "Invalid config line $line: $_" unless defined $v;
        $param{$p} = $v;
    }

    $self->{koha} = delete( $param{koha} )
      or die "No koha base url in config file";
    $self->{user} = delete( $param{user} )
      or die "No koha user in config file";
    $self->{password} = delete( $param{password} )
      or die "No koha user password in config file";

    $self->{host} = delete( $param{host} );
    $self->{port} = delete( $param{port} )
      or die "Port not specified";

    $self->{debug} = delete( $param{debug} );

    my $log_fh;
    close $self->{log_fh} if $self->{log_fh};
    if (my $logfile = delete $param{log}) {
        open ($log_fh, '>>', $logfile) or die "Cannot open $logfile for write: $!";
    } else {
        $log_fh = \*STDERR;
    }
    $self->{log_fh} = $log_fh;

    $self->{params} = \%param;
}

sub log {
    my $self = shift;
    my $log_fh = $self->{log_fh}
      or warn "No log fh",
         return;
    my $t = localtime;
    print $log_fh map "$t: $_\n", @_;
}

sub background {
    my $self = shift;

    my $pid = fork;
    return ($pid) if $pid; # parent

    die "Couldn't fork: $!" unless defined($pid);

    POSIX::setsid() or die "Can't start a new session: $!";

    $SIG{INT} = $SIG{TERM} = $SIG{HUP} = sub { $self->{time_to_die} = 1 };
    # trap or ignore $SIG{PIPE}
    $SIG{USR1} = sub { $self->parse_config };

    $self->run;
}

sub run {
    my $self = shift;

    my $server_port = $self->{port};
    my $server_host = $self->{host};

    my $server = IO::Socket::INET->new(
        LocalHost => $server_host,
        LocalPort => $server_port,
        Type      => SOCK_STREAM,
        Proto     => "tcp",
        Listen    => 12,
        Blocking  => 1,
        ReuseAddr => 1,
    ) or die "Couldn't be a tcp server on port $server_port: $! $@";

    $self->log("Started tcp listener on $server_host:$server_port");

    $self->{ua} = _ua();

    while ("FOREVER") {
        my $client = $server->accept()
          or die "Cannot accept: $!";
        my $oldfh = select($client);
        $self->handle_request($client);
        select($oldfh);
        last if $self->{time_to_die};
    }

    close($server);
}

sub _ua {
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->cookie_jar({});
    return $ua;
}

sub read_request {
    my ( $self, $io ) = @_;

    my ($in, @in_arr, $timeout, $bad_marc);
    my $select = IO::Select->new($io) ;
    while ( "FOREVER" ) {
        if ( $select->can_read(CLIENT_READ_TIMEOUT) ){
            $io->recv($in, CLIENT_READ_BUFFER_SIZE);
            last unless $in;

            # XXX ignore after NULL
            if ( $in =~ m/^(.*)\000/so ) { # null received, EOT
                push @in_arr, $1;
                last;
            }
            push @in_arr, $in;
        }
        else {
            last;
        }
    }

    $in = join '', @in_arr;

    $in =~ m/(.)$/;
    my $lastchar = $1;
    my ($xml, $user, $password, $local_user);
    my $data = $in; # copy for diagmostic purposes
    while () {
        my $first = substr( $data, 0, 1 );
        if (!defined $first) {
           last;
        }
        $first eq 'U' && do {
            ($user, $data) = _trim_identifier($data);
            next;
        };
        $first eq 'A' && do {
            ($local_user, $data) = _trim_identifier($data);
            next;
        };
        $first eq 'P' && do {
            ($password, $data) = _trim_identifier($data);
            next;
        };
        $first eq ' ' && do {
            $data = substr( $data, 1 ); # trim
            next;
        };
        $data =~ m/^[0-9]/ && do {
            # What we have here might be a MARC record...
            my $marc_record;
            eval { $marc_record = MARC::Record->new_from_usmarc($data); };
            if ($@) {
                $bad_marc = 1;
            }
            else {
               $xml = $marc_record->as_xml();
            }
            last;
        };
        last; # unexpected input
    }

    my @details;
    push @details, "Timeout" if $timeout;
    push @details, "Bad MARC" if $bad_marc;
    push @details, "User: $user" if $user;
    push @details, "Password: " . ( $self->{debug} ? $password : ("x" x length($password)) ) if $password;
    push @details, "Local user: $local_user" if $local_user;
    push @details, "XML: $xml" if $xml;
    push @details, "Remaining data: $data" if ($data && !$xml);
    unless ($xml) {
        $self->log("Invalid request", $in, @details);
        return;
    }

    $self->log("Request", @details);
    $self->log($in) if $self->{debug};
    return ($xml, $user, $password);
}

sub _trim_identifier {
    #my ($a, $len) = unpack "cc", substr( $_[0], 0, 2 );
    my $len=ord(substr ($_[0], 1, 1)) - 64;
    if ($len <0) {  #length is numeric, and thus comes from the web client, not the desktop client.
       $_[0] =~ m/.(\d+)/;
       $len = $1;
       return ( substr( $_[0], length($len)+1 , $len ), substr( $_[0], length($len) + 1 + $len ) );
    }
    return ( substr( $_[0], 2 , $len ), substr( $_[0], 2 + $len ) );
}

sub handle_request {
    my ( $self, $io ) = @_;

    my ($data, $user, $password) = $self->read_request($io)
      or return $self->error_response("Bad request");

    my $ua;
    if ($self->{user}) {
        $user = $self->{user};
        $password = $self->{password};
        $ua = $self->{ua};
    }
    else {
        $ua  = _ua(); # fresh one, needs to authenticate
    }

    my $base_url = $self->{koha};
    my $resp = $ua->post( $base_url.IMPORT_SVC_URI,
                              {'nomatch_action' => $self->{params}->{nomatch_action},
                               'overlay_action' => $self->{params}->{overlay_action},
                               'match'          => $self->{params}->{match},
                               'import_mode'    => $self->{params}->{import_mode},
                               'framework'      => $self->{params}->{framework},
                               'item_action'    => $self->{params}->{item_action},
                               'xml'            => $data});

    my $status = $resp->code;
    if ($status == HTTP_UNAUTHORIZED || $status == HTTP_FORBIDDEN) {
        my $user = $self->{user};
        my $password = $self->{password};
        $resp = $ua->post( $base_url.AUTH_URI, { userid => $user, password => $password } );
        $resp = $ua->post( $base_url.IMPORT_SVC_URI,
                              {'nomatch_action' => $self->{params}->{nomatch_action},
                               'overlay_action' => $self->{params}->{overlay_action},
                               'match'          => $self->{params}->{match},
                               'import_mode'    => $self->{params}->{import_mode},
                               'framework'      => $self->{params}->{framework},
                               'item_action'    => $self->{params}->{item_action},
                               'xml'            => $data})
          if $resp->is_success;
    }
    unless ($resp->is_success) {
        $self->log("Unsuccessful request", $resp->request->as_string, $resp->as_string);
        return $self->error_response("Unsuccessful request");
    }

    my ($koha_status, $bib, $overlay, $batch_id, $error, $url);
    if ( my $r = eval { XMLin($resp->content) } ) {
        $koha_status = $r->{status};
        $batch_id    = $r->{import_batch_id};
        $error       = $r->{error};
        $bib         = $r->{biblionumber};
        $overlay     = $r->{match_status};
        $url         = $r->{url};
    }
    else {
        $koha_status = "error";
        $self->log("Response format error:\n$resp->content");
        return $self->error_response("Invalid response");
    }

    if ($koha_status eq "ok") {
        my $response_string = sprintf( "Success.  Batch number %s - biblio record number %s",
                                        $batch_id,$bib);
        $response_string .= $overlay eq 'no_match' ? ' added to Koha.' : ' overlaid by import.';
        $response_string .= "\n\n$url";

        return $self->response( $response_string );
    }

    return $self->error_response( sprintf( "%s.  Please contact administrator.", $error ) );
}

sub error_response {
    my $self = shift;
    $self->response(@_);
}

sub response {
    my $self = shift;
    $self->log("Response: $_[0]");
    printf $_[0] . "\0";
}


} # package
