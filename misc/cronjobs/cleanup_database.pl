#!/usr/bin/perl

# Copyright 2009 PTFS, Inc.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use constant DEFAULT_ZEBRAQ_PURGEDAYS => 30;
use constant DEFAULT_MAIL_PURGEDAYS => 30;
use constant DEFAULT_IMPORT_PURGEDAYS => 60;
use constant DEFAULT_LOGS_PURGEDAYS => 180;
use constant DEFAULT_SEARCHHISTORY_PURGEDAYS => 30;

BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Dates;

use C4::Search;

use Getopt::Long;

sub usage {
    print STDERR <<USAGE;
Usage: $0 [-h|--help] [--sessions] [--sessdays DAYS] [-v|--verbose] [--zebraqueue DAYS] [-m|--mail] [--merged] [--import DAYS] [--logs DAYS] [--searchhistory DAYS]

   -h --help          prints this help message, and exits, ignoring all
                      other options
   --sessions         purge the sessions table.  If you use this while users 
                      are logged into Koha, they will have to reconnect.
   --sessdays DAYS    purge only sessions older than DAYS days.
   -v --verbose       will cause the script to give you a bit more information
                      about the run.
   --zebraqueue DAYS  purge completed zebraqueue entries older than DAYS days.
                      Defaults to 30 days if no days specified.
   -m --mail DAYS     purge items from the mail queue that are older than DAYS days.
                      Defaults to 30 days if no days specified.
   --merged           purged completed entries from need_merge_authorities.
   --import DAYS      purge records from import tables older than DAYS days.
                      Defaults to 60 days if no days specified.
   --logs DAYS        purge entries from action_logs older than DAYS days.
                      Defaults to 180 days if no days specified.
   --searchhistory DAYS  purge entries from search_history older than DAYS days.
                         Defaults to 30 days if no days specified
USAGE
    exit $_[0];
}

my ( $help, $sessions, $sess_days, $verbose, $zebraqueue_days, $mail, $purge_merged, $pImport, $pLogs, $pSearchhistory);

GetOptions(
    'h|help'       => \$help,
    'sessions'     => \$sessions,
    'sessdays:i'   => \$sess_days,
    'v|verbose'    => \$verbose,
    'm|mail:i'       => \$mail,
    'zebraqueue:i' => \$zebraqueue_days,
    'merged'       => \$purge_merged,
    'import:i'     => \$pImport,
    'logs:i'       => \$pLogs,
    'searchhistory:i' => \$pSearchhistory,
) || usage(1);

$sessions=1 if $sess_days && $sess_days>0;
# if --import, --logs, --zebraqueue or --searchhistory were passed without number of days,
# use defaults
$pImport= DEFAULT_IMPORT_PURGEDAYS if defined($pImport) && $pImport==0;
$pLogs= DEFAULT_LOGS_PURGEDAYS if defined($pLogs) && $pLogs==0;
$zebraqueue_days= DEFAULT_ZEBRAQ_PURGEDAYS if defined($zebraqueue_days) && $zebraqueue_days==0;
$mail= DEFAULT_MAIL_PURGEDAYS if defined($mail) && $mail==0;
$pSearchhistory= DEFAULT_SEARCHHISTORY_PURGEDAYS if defined($pSearchhistory) && $pSearchhistory==0;

if ($help) {
    usage(0);
}

if ( !( $sessions || $zebraqueue_days || $mail || $purge_merged || $pImport || $pLogs || $pSearchhistory ) ) {
    print "You did not specify any cleanup work for the script to do.\n\n";
    usage(1);
}

my $dbh = C4::Context->dbh();
my $query;
my $sth;
my $sth2;
my $count;

if ( $sessions && !$sess_days ) {
    if ($verbose) {
        print "Session purge triggered.\n";
        $sth = $dbh->prepare("SELECT COUNT(*) FROM sessions");
        $sth->execute() or die $dbh->errstr;
        my @count_arr = $sth->fetchrow_array;
        print "$count_arr[0] entries will be deleted.\n";
    }
    $sth = $dbh->prepare("TRUNCATE sessions");
    $sth->execute() or die $dbh->errstr;
    if ($verbose) {
        print "Done with session purge.\n";
    }
} elsif ( $sessions && $sess_days > 0 ) {
    if ($verbose) {
        print "Session purge triggered with days>$sess_days.\n";
    }
    RemoveOldSessions();
    if ($verbose) {
        print "Done with session purge with days>$sess_days.\n";
    }
}

if ($zebraqueue_days) {
    $count = 0;
    if ($verbose) {
        print "Zebraqueue purge triggered for $zebraqueue_days days.\n";
    }
    $sth = $dbh->prepare(
        "SELECT id,biblio_auth_number,server,time FROM zebraqueue
                          WHERE done=1 and time < date_sub(curdate(), interval ? day)"
    );
    $sth->execute($zebraqueue_days) or die $dbh->errstr;
    $sth2 = $dbh->prepare("DELETE FROM zebraqueue WHERE id=?");
    while ( my $record = $sth->fetchrow_hashref ) {
        $sth2->execute( $record->{id} ) or die $dbh->errstr;
        $count++;
    }
    if ($verbose) {
        print "$count records were deleted.\nDone with zebraqueue purge.\n";
    }
}

if ($mail) {
    print "Mail queue purge triggered for $mail days.\n" if ($verbose);

    $sth = $dbh->prepare("DELETE FROM message_queue WHERE time_queued < date_sub(curdate(), interval ? day)");
    $sth->execute($mail) or die $dbh->errstr;
    my $count = $sth->rows;
    $sth->finish;

    print "$count messages were deleted from the mail queue.\nDone with message_queue purge.\n" if ($verbose);
}

if($purge_merged) {
    print "Purging completed entries from need_merge_authorities.\n" if $verbose;
    $sth = $dbh->prepare("DELETE FROM need_merge_authorities WHERE done=1");
    $sth->execute() or die $dbh->errstr;
    print "Done with purging need_merge_authorities.\n" if $verbose;
}

if($pImport) {
    print "Purging records from import tables.\n" if $verbose;
    PurgeImportTables();
    print "Done with purging import tables.\n" if $verbose;
}

if($pLogs) {
    print "Purging records from action_logs.\n" if $verbose;
    $sth = $dbh->prepare("DELETE FROM action_logs WHERE timestamp < date_sub(curdate(), interval ? DAY)");
    $sth->execute($pLogs) or die $dbh->errstr;
    print "Done with purging action_logs.\n" if $verbose;
}

if($pSearchhistory) {
    print "Purging records older than $pSearchhistory from search_history.\n" if $verbose;
    PurgeSearchHistory($pSearchhistory);
    print "Done with purging search_history.\n" if $verbose;
}

exit(0);

sub RemoveOldSessions {
    my ( $id, $a_session, $limit, $lasttime );
    $limit = time() - 24 * 3600 * $sess_days;

    $sth = $dbh->prepare("SELECT id, a_session FROM sessions");
    $sth->execute or die $dbh->errstr;
    $sth->bind_columns( \$id, \$a_session );
    $sth2  = $dbh->prepare("DELETE FROM sessions WHERE id=?");
    $count = 0;

    while ( $sth->fetch ) {
        $lasttime = 0;
        if ( $a_session =~ /lasttime:\s+'?(\d+)/ ) {
            $lasttime = $1;
        } elsif ( $a_session =~ /(ATIME|CTIME):\s+'?(\d+)/ ) {
            $lasttime = $2;
        }
        if ( $lasttime && $lasttime < $limit ) {
            $sth2->execute($id) or die $dbh->errstr;
            $count++;
        }
    }
    if ($verbose) {
        print "$count sessions were deleted.\n";
    }
}

sub PurgeImportTables {
    #First purge import_records
    #Delete cascades to import_biblios, import_items and import_record_matches
    $sth = $dbh->prepare("DELETE FROM import_records WHERE upload_timestamp < date_sub(curdate(), interval ? DAY)");
    $sth->execute($pImport) or die $dbh->errstr;

    # Now purge import_batches
    # Timestamp cannot be used here without care, because records are added
    # continuously to batches without updating timestamp (z3950 search).
    # So we only delete older empty batches.
    # This delete will therefore not have a cascading effect.
    $sth = $dbh->prepare("DELETE ba
 FROM import_batches ba
 LEFT JOIN import_records re ON re.import_batch_id=ba.import_batch_id
 WHERE re.import_record_id IS NULL AND
 ba.upload_timestamp < date_sub(curdate(), interval ? DAY)");
    $sth->execute($pImport) or die $dbh->errstr;
}
