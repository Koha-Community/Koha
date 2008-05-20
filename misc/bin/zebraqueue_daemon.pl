#!/usr/bin/perl

# daemon to watch the zebraqueue and update zebra as needed

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use POE qw(Wheel::SocketFactory Wheel::ReadWrite Filter::Stream Driver::SysRW);
use Unix::Syslog qw(:macros);

use C4::Context;
use C4::Biblio;
use C4::Search;
use C4::AuthoritiesMarc;
use XML::Simple;
use POSIX;
use utf8;


# wait periods governing connection attempts
my $min_connection_wait =    1; # start off at 1 second
my $max_connection_wait = 1024; # max about 17 minutes

# keep separate wait period for bib and authority Zebra databases
my %zoom_connection_waits = (); 

my $db_connection_wait = $min_connection_wait;

# ZOOM and Z39.50 errors that are potentially
# resolvable by connecting again and retrying
# the operation
my %retriable_zoom_errors = (
    10000 => 'ZOOM_ERROR_CONNECT',
    10001 => 'ZOOM_ERROR_MEMORY',
    10002 => 'ZOOM_ERROR_ENCODE',
    10003 => 'ZOOM_ERROR_DECODE',
    10004 => 'ZOOM_ERROR_CONNECTION_LOST',
    10005 => 'ZOOM_ERROR_INIT',
    10006 => 'ZOOM_ERROR_INTERNAL',
    10007 => 'ZOOM_ERROR_TIMEOUT',
);

# structure to store updates that have
# failed and are to be retrieved.  The
# structure is a hashref of hashrefs, 
# e.g.,
#
# $postoned_updates->{$server}->{$record_number} = 1;
#
# If an operation is attempted and fails because
# of a retriable error (see above), the daemon
# will try several times to recover as follows:
#
# 1. close and reopen the connection to the
#    Zebra server, unless the error was a timeout,
#    in which case
# 2. retry the operation
#
# If, after trying this five times, the operation still
# fails, the daemon will mark the record number as
# postponed, and try to process other entries in 
# zebraqueue.  When an update is postponed, the 
# error will be reported to syslog. 
#
# If more than 100 postponed updates are 
# accumulated, the daemon will assume that 
# something is seriously wrong, complain loudly,
# and abort.  If running under the daemon(1) command, 
# this means that the daemon will respawn.
#
my $num_postponed_updates = 0;
my $postponed_updates = {};

my $max_operation_attempts =   5;
my $max_postponed_updates  = 100;

# Zebra connection timeout
my $zconn_timeout            =  30;
my $zconn_timeout_multiplier = 1.5;
my $max_zconn_timeout        = 120;

my $ident = "Koha Zebraqueue ";

my $debug = 0;
Unix::Syslog::openlog $ident, LOG_PID, LOG_LOCAL0;

Unix::Syslog::syslog LOG_INFO, "Starting Zebraqueue log at " . scalar localtime(time) . "\n";

sub handler_start {

    # Starts session. Only ever called once only really used to set an alias
    # for the POE kernel
    my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];

    my $time = localtime(time);
    Unix::Syslog::syslog LOG_INFO, "$time POE Session ", $session->ID, " has started.\n";

    # check status
#    $kernel->yield('status_check');
    $kernel->yield('sleep');
}

sub handler_sleep {

    # can be used to slow down loop execution if needed
    my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
    use Time::HiRes qw (sleep);
    Time::HiRes::sleep(0.5);
    #sleep 1;
    $kernel->yield('status_check');
}

sub handler_check {
    # check if we need to do anything, at the moment just checks the zebraqueue, it could check other things too
    my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
    my $dbh = get_db_connection();
    my $sth = $dbh->prepare("SELECT count(*) AS opcount FROM zebraqueue WHERE done = 0");
    $sth->execute;
    my $data = $sth->fetchrow_hashref();
    if ($data->{'opcount'} > 0) {
        Unix::Syslog::syslog LOG_INFO, "$data->{'opcount'} operations waiting to be run\n";
        $sth->finish();
        $dbh->commit(); # needed so that we get current state of zebraqueue next time
                        # we enter handler_check
        $kernel->yield('do_ops');
    }
    else {
        $sth->finish();
        $dbh->commit(); # needed so that we get current state of zebraqueue next time
                        # we enter handler_check
        $kernel->yield('sleep');
    }
}

sub zebraop {
    # execute operations waiting in the zebraqueue
    my ( $kernel, $heap, $session ) = @_[ KERNEL, HEAP, SESSION ];
    my $dbh = get_db_connection();
    my $readsth = $dbh->prepare("SELECT id, biblio_auth_number, operation, server FROM zebraqueue WHERE done = 0 ORDER BY id DESC");
    $readsth->execute();
    Unix::Syslog::syslog LOG_INFO, "Executing zebra operations\n";

    my $completed_updates = {};
    ZEBRAQUEUE: while (my $data = $readsth->fetchrow_hashref()) {
        warn "Inside while loop" if $debug;

        my $id = $data->{'id'};
        my $op = $data->{'operation'};
        $op = 'recordDelete' if $op =~ /delete/i; # delete ops historically have been coded
                                                  # either delete_record or recordDelete
        my $record_number = $data->{'biblio_auth_number'};
        my $server = $data->{'server'};

        next ZEBRAQUEUE if exists $postponed_updates->{$server}->{$record_number};
        next ZEBRAQUEUE if exists $completed_updates->{$server}->{$record_number}->{$op};

        my $ok = 0;
        my $record;
        if ($op eq 'recordDelete') {
            $ok = process_delete($dbh, $server, $record_number);
        }
        else {
            $ok = process_update($dbh, $server, $record_number, $id);
        }
        if ($ok == 1) {
            mark_done($dbh, $record_number, $op, $server);
            $completed_updates->{$server}->{$record_number}->{$op} = 1;
            if ($op eq 'recordDelete') {
                $completed_updates->{$server}->{$record_number}->{'specialUpdate'} = 1;
            }
        }                            
    }
    $readsth->finish();
    $dbh->commit();
    $kernel->yield('sleep');
}

sub process_delete {
    my $dbh = shift;
    my $server = shift;
    my $record_number = shift;

    my $record;
    my $ok = 0;
    eval {
        warn "Searching for record to delete" if $debug;
        # 1st read the record in zebra, we have to get it from zebra as its no longer in the db
        my $Zconn =  get_zebra_connection($server);
        my $results = $Zconn->search_pqf( '@attr 1=Local-number '.$record_number);
        $results->option(elementSetName => 'marcxml');
        $record = $results->record(0)->raw();
    };
    if ($@) {
        # this doesn't exist, so no need to wail on zebra to delete it
        if ($@->code() eq 13) {
            $ok = 1;
        } else {
            # caught a ZOOM::Exception
            my $message = _format_zoom_error_message($@);
            postpone_update($server, $record_number, $message);
        }
    } else {
        # then, delete the record
        warn "Deleting record" if $debug;
        $ok = zebrado($record, 'recordDelete', $server, $record_number);
    }
    return $ok;
}

sub process_update {
    my $dbh = shift;
    my $server = shift;
    my $record_number = shift;
    my $id = shift;

    my $record;
    my $ok = 0;

    warn "Updating record" if $debug;
    # get the XML
    my $marcxml;
    if ($server eq "biblioserver") {
        my $marc = GetMarcBiblio($record_number);
        $marcxml = $marc->as_xml_record() if $marc;
    } 
    elsif ($server eq "authorityserver") {
        $marcxml = C4::AuthoritiesMarc::GetAuthorityXML($record_number);
    }
    # check it's XML, just in case
    eval {
        my $hashed = XMLin($marcxml);
    }; ### is it a proper xml? broken xml may crash ZEBRA- slow but safe
    ## it's Broken XML-- Should not reach here-- but if it does -lets protect ZEBRA
    if ($@) {
        Unix::Syslog::syslog LOG_ERR, "$server record $record_number is malformed: $@";
        mark_done_by_id($dbh, $id, $server);
        $ok = 0;
    } else {
        # ok, we have everything, do the operation in zebra !
        $ok = zebrado($marcxml, 'specialUpdate', $server, $record_number);
    }
    return $ok;
}

sub mark_done_by_id {
    my $dbh = shift;
    my $id = shift;
    my $server = shift;
    my $delsth = $dbh->prepare("UPDATE zebraqueue SET done = 1 WHERE id = ? AND server = ? AND done = 0");
    $delsth->execute($id, $server);
}

sub mark_done {
    my $dbh = shift;
    my $record_number = shift;
    my $op = shift;
    my $server = shift;

    my $delsth;
    if ($op eq 'recordDelete') {
        # if it's a deletion, we can delete every request on this biblio : in case the user
        # did a modif (or item deletion) just before biblio deletion, there are some specialUpdate
        # that are pending and can't succeed, as we don't have the XML anymore
        # so, delete everything for this biblionumber
        $delsth = $dbh->prepare_cached("UPDATE zebraqueue SET done = 1 
                                        WHERE biblio_auth_number = ? 
                                        AND server = ?
                                        AND done = 0");
        $delsth->execute($record_number, $server);
    } else {
        # if it's not a deletion, delete every pending specialUpdate for this biblionumber
        # in case the user add biblio, then X items, before this script runs
        # this avoid indexing X+1 times where just 1 is enough.
        $delsth = $dbh->prepare("UPDATE zebraqueue SET done = 1 
                                 WHERE biblio_auth_number = ? 
                                 AND operation = 'specialUpdate'
                                 AND server = ?
                                 AND done = 0");
        $delsth->execute($record_number, $server);
    }
}

sub zebrado {
    ###Accepts a $server variable thus we can use it to update  biblios, authorities or other zebra dbs
    my ($record, $op, $server, $record_number) = @_;

    unless ($record) {
        my $message = "error updating index for $server $record $record_number: no source record";
        postpone_update($server, $record_number, $message);
        return 0;
    }

    my $attempts = 0;
    my $ok = 0;
    ATTEMPT: while ($attempts < $max_operation_attempts) {
        $attempts++;
        warn "Attempt $attempts for $op for $server $record_number" if $debug;
        my $Zconn = get_zebra_connection($server);

        my $Zpackage = $Zconn->package();
        $Zpackage->option(action => $op);
        $Zpackage->option(record => $record);

        eval { $Zpackage->send("update") };
        if ($@ && $@->isa("ZOOM::Exception")) {
            my $message = _format_zoom_error_message($@);
            my $error = $@->code();
            if (exists $retriable_zoom_errors{$error}) {
                warn "reattempting operation $op for $server $record_number" if $debug;
                warn "last Zebra error was $message" if $debug;
                $Zpackage->destroy();

                if ($error == 10007 and $zconn_timeout < $max_zconn_timeout) {
                    # bump up connection timeout
                    $zconn_timeout = POSIX::ceil($zconn_timeout * $zconn_timeout_multiplier);
                    $zconn_timeout = $max_zconn_timeout if $zconn_timeout > $max_zconn_timeout;
                    Unix::Syslog::syslog LOG_INFO, "increased Zebra connection timeout to $zconn_timeout\n";
                    warn "increased Zebra connection timeout to $zconn_timeout" if $debug;
                }
                next ATTEMPT;
            } else {
                postpone_update($server, $record_number, $message);
            }
        }
        # FIXME - would be more efficient to send a ES commit
        # after a batch of records, rather than commiting after
        # each one - Zebra handles updates relatively slowly.
        eval { $Zpackage->send('commit'); };
        if ($@) {
            # operation succeeded, but commit
            # did not - we have a problem
            my $message = _format_zoom_error_message($@);
            postpone_update($server, $record_number, $message);
        } else {
            $ok = 1;
            last ATTEMPT;
        }
    }

    unless ($ok) {
        my $message = "Made $attempts attempts to index $server record $record_number without success";
        postpone_update($server, $record_number, $message);
    }

    return $ok; 
}

sub postpone_update {
    my ($server, $record_number, $message) = @_;
    warn $message if $debug;
    $message .= "\n" unless $message =~ /\n$/;
    Unix::Syslog::syslog LOG_ERR, $message;
    $postponed_updates->{$server}->{$record_number} = 1;

    $num_postponed_updates++;
    if ($num_postponed_updates > $max_postponed_updates) {
        warn "exiting, over $max_postponed_updates postponed indexing updates";
        Unix::Syslog::syslog LOG_ERR, "exiting, over $max_postponed_updates postponed indexing updates";
        Unix::Syslog::closelog;
        exit;
    }
}

sub handler_stop {
    my $heap = $_[HEAP];
    my $time = localtime(time);
    Unix::Syslog::syslog LOG_INFO, "$time Session ", $_[SESSION]->ID, " has stopped.\n";
    delete $heap->{session};
}

# get a DB connection
sub get_db_connection {
    my $dbh;

    $db_connection_wait = $min_connection_wait unless defined $db_connection_wait;
    while (1) {
        eval {
            # note that C4::Context caches the
            # DB handle; C4::Context->dbh() will
            # check that handle first before returning
            # it.  If the connection is bad, it
            # then tries (once) to create a new one.
            $dbh = C4::Context->dbh();
        };

        unless ($@) {
            # C4::Context->dbh dies if it cannot
            # establish a connection
            $db_connection_wait = $min_connection_wait;
            $dbh->{AutoCommit} = 0; # do this to reduce number of
                                    # commits to zebraqueue
            return $dbh;
        }

        # connection failed
        my $error = "failed to connect to DB: $DBI::errstr";
        warn $error if $debug;
        Unix::Syslog::syslog LOG_ERR, $error;
        sleep $db_connection_wait;
        $db_connection_wait *= 2 unless $db_connection_wait >= $max_connection_wait;
    }
}

# get a Zebra connection
sub get_zebra_connection {
    my $server = shift;

    # start connection retry wait queue if necessary
    $zoom_connection_waits{$server} = $min_connection_wait unless exists  $zoom_connection_waits{$server};

    # try to connect to Zebra forever until we succeed
    while (1) {
        # what follows assumes that C4::Context->Zconn 
        # makes only one attempt to create a new connection;
        my $Zconn = C4::Context->Zconn($server, 0, 1, '', 'xml');
        $Zconn->option('timeout' => $zconn_timeout);

        # it is important to note that if the existing connection
        # stored by C4::Context has an error (any type of error)
        # from the last transaction, C4::Context->Zconn closes
        # it and establishes a new one.  Therefore, the
        # following check will succeed if we have a new, good 
        # connection or we're using a previously established
        # connection that has experienced no errors.
        if ($Zconn->errcode() == 0) {
            $zoom_connection_waits{$server} = $min_connection_wait;
            return $Zconn;
        }

        # connection failed
        my $error = _format_zoom_error_message($Zconn);
        warn $error if $debug;
        Unix::Syslog::syslog LOG_ERR, $error;
        sleep $zoom_connection_waits{$server};
        $zoom_connection_waits{$server} *= 2 unless $zoom_connection_waits{$server} >= $max_connection_wait;
    }
}

# given a ZOOM::Exception or
# ZOOM::Connection object, generate
# a human-reaable error message
sub _format_zoom_error_message {
    my $err = shift;

    my $message = "";
    if (ref($err) eq 'ZOOM::Connection') {
        $message = $err->errmsg() . " (" . $err->diagset . " " . $err->errcode() . ") " . $err->addinfo();
    } elsif (ref($err) eq 'ZOOM::Exception') {
        $message = $err->message() . " (" . $err->diagset . " " .  $err->code() . ") " . $err->addinfo();
    }
    return $message; 
}

POE::Session->create(
    inline_states => {
        _start       => \&handler_start,
        sleep        => \&handler_sleep,
        status_check => \&handler_check,
        do_ops       => \&zebraop,
        _stop        => \&handler_stop,
    },
);

# start the kernel
$poe_kernel->run();

Unix::Syslog::closelog;

exit;
