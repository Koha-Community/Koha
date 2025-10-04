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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use Getopt::Long qw( GetOptions );

my ( $help, $config, $daemon );

GetOptions(
    'config|c=s' => \$config,
    'daemon|d'   => \$daemon,
    'help|?'     => \$help,
);

if ( $help || !$config ) {
    print <<EOF
OCLC Import Daemon

This script hosts a server which listens for connections from an OCLC Connexion
client or WorldShare Record Manager.

The records are forwarded to Koha by sending a request to the handler at
`/cgi-bin/koha/svc/import_bib` on the staff interface of the configured Koha
instance. The request is authenticated using the credentials of a Koha staff
user.

See the documentation for the `import_bib` endpoint at
https://wiki.koha-community.org/wiki/Koha_/svc/_HTTP_API#POST_.2Fsvc.2Fimport_bib .
The `import_bib` endpoint is being phased out. This script should be rewritten
to use the newer REST API instead.

If you have multiple Koha instances, run a separate instance of this script for
each one, using a different port and different credentials for each one.

Usage:
  $0 --config=my.conf

Command line options:
  --daemon | -d  - Run in the background. Prints the process ID to stdout.
  --config | -c  - Specify the config file to use. Required.
  --help   | -?  - Print this message.

Config file format:
  Each line has the form:
    NAME: VALUE
  For example:
    port: 5500

  Empty parameters look like this:
    NAME:
  For example:
    overlay_framework:

  Values should not be quoted.

  Lines starting with # are treated as comments.

  Parameters:
    host
      The IP address or host name to bind to (that is, listen on).
      Defaults to 0.0.0.0, that is, listen on all interfaces.

    port
      The port to bind to (that is, listen on).  Typically 5500.
      This must be different from the port used by any other service on the
      same machine.
      Required.

    log
      The path to the log file.
      Logs are written to stderr if omitted.

    debug
      Dumps all incoming requests to the log file.
      WARNING: This includes the connexion user's password, if it is  part of
      the request.
      Use 1 for on and 0 for off.
      Defaults to 0 (off).

    koha
      The base URL of the staff interface for your Koha instance, for example,
      http://librarian.koha
      When this script is running on the same machine as the Koha instance, and
      you have dedicated port for the Koha staff interface, you can use
      http://localhost:port here. Otherwise, use the URL you would use when
      accessing the Koha staff interface through a browser.
      Required.

    user
      The Koha user used for logging in to the staff interface for the Koha
      instance.
      Required.

    password
      The password of the Koha user.
      Required.

    connexion_user
      The user name expected to be sent by the connexion client with every
      request.
      If set, also set `connexion_password`. In this case, request
      authentication will be checked.
      If omitted, also omit `connexion_password`. In this case, request
      authentication will not be checked, and anyone with access to the port
      opened by this script will be able to send records into the
      Koha instance.

    connexion_password
      The password expected to be sent by the connexion client with every
      request.
      WARNING: Do NOT use the same password as the Koha user password.

    import_mode
      Where the imported records should go. See the explanation below.
      Available values:
        stage
          The records will be imported into the staging area (reservoir)
          at /cgi-bin/koha/tools/manage-marc-import.pl into a batch called
          `(webservice)`.
          The records will also show up below the catalog results in the staff
          interface when doing a "cataloging search" at
          /cgi-bin/koha/cataloguing/addbooks.pl?q=...
        direct
          The records will be imported directly into the catalog. They will
          show up in all catalog searches as soon as the indexing catches up.
      Defaults to `stage`.

    match
      Which code to use for matching MARC records when deciding whether to add
      or replace a record.
      Corresponds to the "Matching rule applied" field at
      /cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=...
      Available options:
        ISBN
          Use the International Standard Book Number (MARC 020\$a)
        ISSN
          Use the International Standard Serial Number (MARC 022\$a)
        KohaBiblio
          Use the Koha biblio number (MARC 999\$c)
      See `C4::Matcher`.

    overlay_action
      What to do when the incoming record matches a record already in the
      catalog.
      Corresponds to the "Action if matching record found" field at
      /cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=...
      Available values:
        replace
          Replace the existing record with the incoming record.
        create_new
          Create a new record alongside the existing record.
        ignore
          Discard the incoming record.

    nomatch_action
      What to do when the incoming record does not match any record in the
      catalog.
      Corresponds to the "Action if no match found" field at
      /cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=...
      Available values:
        create_new
          Create a new record.
        ignore
          Discard the incoming record.

    item_action
      What to do when the incoming MARC record contains one or more items
      embedded in field 952.
      Corresponds to the "Item processing" field at
      /cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=...
      Available values:
        always_add
        add_only_for_matches
        add_only_for_new
        replace
        ignore

    framework
      The cataloging framework to use when no match was found in the catalog
      (that is, when adding a new record).
      Defaults to the default framework configured at
      /cgi-bin/koha/admin/biblio_framework.pl

    overlay_framework
      The cataloging framework to use when a match was found in the catalog
      (that is, when replacing an existing record).
      Corresponds to the "Replacement record framework" field at
      /cgi-bin/koha/tools/manage-marc-import.pl?import_batch_id=...
      You have three options here:
        Do not specify this parameter.
          The default framework configured at
          /cgi-bin/koha/admin/biblio_framework.pl is used.
        Specify this parameter without a value, that is, `overlay_framework:`.
          The new record will use the same framework as the record being
          replaced.
        Specify this parameter with a value, for example,
          `overlay_framework: my_framework`.
          The new record will use the specified framework.

Explanation of `import_mode`:
- When using `direct`, each request will create a new batch and import the
  batch immediately.
- When using `stage`, each request will cause records to be added to an
  existing batch.
- The batch name is always `(webservice)`.
- If you change `import_mode` from `stage` to `direct` after some records
  have already been staged, the next request will cause all records in that
  batch to be imported into the catalog, not just the records from the latest
  request.
- These config parameters define the settings of the batch that is created,
  whether or not it is imported immediately:
  - `match`
  - `overlay_action`
  - `nomatch_action`
  - `item_action`
  - `framework`
  - `overlay_framework`
- If one or more of these parameters are changed, a new batch is created with
  the new settings, and any new records are added to that batch instead of to
  the old one.
- If you stage a record that cannot be imported then all future imports will
  be stuck until that batch is cleaned and deleted.

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

    use Carp             qw( croak );
    use IO::Socket::INET qw( SOCK_STREAM );

    # use IO::Socket::IP;
    use IO::Select;
    use POSIX;
    use HTTP::Status qw( HTTP_FORBIDDEN HTTP_UNAUTHORIZED );
    use strict;
    use warnings;

    use LWP::UserAgent;
    use XML::Simple qw( XMLin );
    use MARC::Record;
    use MARC::File::XML;

    use constant CLIENT_READ_TIMEOUT     => 5;
    use constant CLIENT_READ_BUFFER_SIZE => 100000;
    use constant AUTH_URI                => "/cgi-bin/koha/svc/authentication";
    use constant IMPORT_SVC_URI          => "/cgi-bin/koha/svc/import_bib";

    sub new {
        my $class       = shift;
        my $config_file = shift or croak "No config file";

        my $self = { time_to_die => 0, config_file => $config_file };
        bless $self, $class;

        $self->parse_config;
        return $self;
    }

    sub parse_config {
        my $self = shift;

        my $config_file = $self->{config_file};

        open( my $conf_fh, '<', $config_file ) or die "Cannot open config file $config: $!";

        my %param;
        my $line = 0;
        while (<$conf_fh>) {
            $line++;
            chomp;
            s/\s*#.*//o;    # remove comments
            s/^\s+//o;      # trim leading spaces
            s/\s+$//o;      # trim trailing spaces
            next unless $_;

            my ( $p, $v ) = m/(\S+?):\s*(.*)/o;
            die "Invalid config line $line: $_" unless defined $v;
            $param{$p} = $v;
        }
        close($conf_fh);

        $self->{koha} = delete( $param{koha} )
            or die "No koha base url in config file";
        $self->{user} = delete( $param{user} )
            or die "No koha user in config file";
        $self->{password} = delete( $param{password} )
            or die "No koha user password in config file";

        if ( defined $param{connexion_user} || defined $param{connexion_password} ) {

            # If either is defined we expect both
            $self->{connexion_user} = delete( $param{connexion_user} )
                or die "No koha connexion_user in config file";
            $self->{connexion_password} = delete( $param{connexion_password} )
                or die "No koha user connexion_password in config file";
        }

        $self->{host} = delete( $param{host} );
        $self->{port} = delete( $param{port} )
            or die "Port not specified";

        $self->{debug} = delete( $param{debug} );

        my $log_fh;
        close $self->{log_fh} if $self->{log_fh};
        if ( my $logfile = delete $param{log} ) {
            open( $log_fh, '>>', $logfile ) or die "Cannot open $logfile for write: $!";
        } else {
            $log_fh = \*STDERR;
        }
        $self->{log_fh} = $log_fh;

        $self->{params} = \%param;
    }

    sub log {
        my $self   = shift;
        my $log_fh = $self->{log_fh}
            or warn "No log fh",
            return;
        my $t = localtime;
        print $log_fh map "$t: $_\n", @_;
    }

    sub background {
        my $self = shift;

        my $pid = fork;
        return ($pid) if $pid;    # parent

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
        $ua->cookie_jar( {} );
        return $ua;
    }

    sub get_current_csrf_token {
        my $self = shift;
        my $ua   = $self->{ua};
        my $url  = $self->{koha} . AUTH_URI;
        return $ua->get($url)->header('CSRF-TOKEN');
    }

    sub authenticate {
        my $self = shift;
        my $ua   = $self->{ua};
        my $url  = $self->{koha} . AUTH_URI;
        my $resp = $ua->post(
            $url,
            {
                login_userid   => $self->{user},
                login_password => $self->{password},
                csrf_token     => $self->get_current_csrf_token,
            }
        );
        if ( !$resp->is_success ) {
            $self->log( "Authentication failed", $resp->request->as_string, $resp->as_string );
            return;
        }
        return $resp->header('CSRF-TOKEN');
    }

    sub read_request {
        my ( $self, $io ) = @_;

        my ( $in, @in_arr, $timeout, $bad_marc );
        my $select = IO::Select->new($io);
        while ("FOREVER") {
            if ( $select->can_read(CLIENT_READ_TIMEOUT) ) {
                $io->recv( $in, CLIENT_READ_BUFFER_SIZE );
                last unless $in;

                # XXX ignore after NULL
                if ( $in =~ m/^(.*)\000/so ) {    # null received, EOT
                    push @in_arr, $1;
                    last;
                }
                push @in_arr, $in;
            } else {
                last;
            }
        }

        $in = join '', @in_arr;
        $in =~ m/(.)$/;
        my $lastchar = $1;
        my ( $xml, $user, $password, $local_user );
        my $data = $in;    # copy for diagnostic purposes
        while () {
            my $first = substr( $data, 0, 1 );
            if ( !defined $first ) {
                last;
            }
            $first eq 'U' && do {
                ( $user, $data ) = _trim_identifier($data);
                next;
            };
            $first eq 'A' && do {
                ( $local_user, $data ) = _trim_identifier($data);
                next;
            };
            $first eq 'P' && do {
                ( $password, $data ) = _trim_identifier($data);
                next;
            };
            $first eq ' ' && do {
                $data = substr( $data, 1 );    # trim
                next;
            };
            $data =~ m/^[0-9]/ && do {

                # What we have here might be a MARC record...
                my $marc_record;
                eval { $marc_record = MARC::Record->new_from_usmarc($data); };
                if ($@) {
                    $bad_marc = 1;
                } else {
                    $xml = $marc_record->as_xml();
                }
                last;
            };
            last;    # unexpected input
        }

        my @details;
        push @details, "Timeout"                                                                   if $timeout;
        push @details, "Bad MARC"                                                                  if $bad_marc;
        push @details, "User: $user"                                                               if $user;
        push @details, "Password: " . ( $self->{debug} ? $password : ( "x" x length($password) ) ) if $password;
        push @details, "Local user: $local_user"                                                   if $local_user;
        push @details, "XML: $xml"                                                                 if $xml;
        push @details, "Remaining data: $data" if ( $data && !$xml );

        unless ($xml) {
            $self->log( "Invalid request", $in, @details );
            return;
        }
        $user = $local_user if !$user && $local_user;

        $self->log( "Request", @details );
        $self->log($in) if $self->{debug};
        return ( $xml, $user, $password );
    }

    sub _trim_identifier {

        #my ($a, $len) = unpack "cc", substr( $_[0], 0, 2 );
        my $len = ord( substr( $_[0], 1, 1 ) ) - 64;
        if ( $len < 0 ) {    #length is numeric, and thus comes from the web client, not the desktop client.
            $_[0] =~ m/.(\d+)/;
            $len = $1;
            return ( substr( $_[0], length($len) + 1, $len ), substr( $_[0], length($len) + 1 + $len ) );
        }
        return ( substr( $_[0], 2, $len ), substr( $_[0], 2 + $len ) );
    }

    sub handle_request {
        my ( $self, $io ) = @_;
        my ( $data, $user, $password ) = $self->read_request($io)
            or return $self->error_response("Bad request");

        unless ( !( defined $self->{connexion_user} )
            || ( $user eq $self->{connexion_user} && $password eq $self->{connexion_password} ) )
        {
            return $self->error_response("Unauthorized request");
        }

        my $ua;
        if ( $self->{user} ) {
            $user     = $self->{user};
            $password = $self->{password};
            $ua       = $self->{ua};
        } else {
            $ua = _ua();    # fresh one, needs to authenticate
        }

        my $base_url  = $self->{koha};
        my $post_body = {
            'nomatch_action'    => $self->{params}->{nomatch_action},
            'overlay_action'    => $self->{params}->{overlay_action},
            'match'             => $self->{params}->{match},
            'import_mode'       => $self->{params}->{import_mode},
            'framework'         => $self->{params}->{framework},
            'overlay_framework' => $self->{params}->{overlay_framework},
            'item_action'       => $self->{params}->{item_action},
            'xml'               => $data
        };

        # If we have a token, try it, else, authenticate for the first time.
        $self->{csrf_token} = $self->authenticate unless $self->{csrf_token};
        my $resp = $ua->post(
            $base_url . IMPORT_SVC_URI,
            $post_body,
            csrf_token => $self->{csrf_token},
        );

        my $status = $resp->code;
        if ( $status == HTTP_UNAUTHORIZED || $status == HTTP_FORBIDDEN ) {

            # Our token might have expired. Re-authenticate and post again.
            $ua                 = _ua();                 # fresh one, needs to authenticate
            $self->{ua}         = $ua;
            $self->{csrf_token} = $self->authenticate;
            $resp               = $ua->post(
                $base_url . IMPORT_SVC_URI,
                $post_body,
                csrf_token => $self->{csrf_token},
            );
        }
        unless ( $resp->is_success ) {
            $self->log( "Unsuccessful request", $resp->request->as_string, $resp->as_string );
            return $self->error_response("Unsuccessful request");
        }

        my ( $koha_status, $bib, $overlay, $batch_id, $error, $url );
        if ( my $r = eval { XMLin( $resp->content ) } ) {
            $koha_status = $r->{status};
            $batch_id    = $r->{import_batch_id};
            $error       = $r->{error};
            $bib         = $r->{biblionumber};
            $overlay     = $r->{match_status};
            $url         = $r->{url};
        } else {
            $koha_status = "error";
            $self->log("Response format error:\n$resp->content");
            return $self->error_response("Invalid response");
        }

        if ( $koha_status eq "ok" ) {
            my $response_string = sprintf(
                "Success.  Batch number %s - biblio record number %s",
                $batch_id, $bib
            );
            $response_string .= $overlay eq 'no_match' ? ' added to Koha.' : ' overlaid by import.';
            $response_string .= "\n\n$url";

            return $self->response($response_string);
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

}    # package
