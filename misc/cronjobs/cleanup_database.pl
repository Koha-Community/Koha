#!/usr/bin/perl

# Copyright 2009 PTFS, Inc.
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

use Modern::Perl;

use constant DEFAULT_ZEBRAQ_PURGEDAYS             => 30;
use constant DEFAULT_MAIL_PURGEDAYS               => 30;
use constant DEFAULT_IMPORT_PURGEDAYS             => 60;
use constant DEFAULT_LOGS_PURGEDAYS               => 180;
use constant DEFAULT_SEARCHHISTORY_PURGEDAYS      => 30;
use constant DEFAULT_SHARE_INVITATION_EXPIRY_DAYS => 14;
use constant DEFAULT_DEBARMENTS_PURGEDAYS         => 30;

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
Usage: $0 [-h|--help] [--sessions] [--sessdays DAYS] [-v|--verbose] [--zebraqueue DAYS] [-m|--mail] [--merged] [--import DAYS] [--logs DAYS] [--searchhistory DAYS] [--restrictions DAYS]

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
   --z3950            purge records from import tables that are the result
                      of Z39.50 searches
   --logs DAYS        purge entries from action_logs older than DAYS days.
                      Defaults to 180 days if no days specified.
   --searchhistory DAYS  purge entries from search_history older than DAYS days.
                         Defaults to 30 days if no days specified
   --list-invites  DAYS  purge (unaccepted) list share invites older than DAYS
                         days.  Defaults to 14 days if no days specified.
   --restrictions DAYS   purge patrons restrictions expired since more than DAYS days.
                         Defaults to 30 days if no days specified.
USAGE
    exit $_[0];
}

my (
    $help,   $sessions,          $sess_days, $verbose, $zebraqueue_days,
    $mail,   $purge_merged,      $pImport,   $pLogs,   $pSearchhistory,
    $pZ3950, $pListShareInvites, $pDebarments,
);

GetOptions(
    'h|help'          => \$help,
    'sessions'        => \$sessions,
    'sessdays:i'      => \$sess_days,
    'v|verbose'       => \$verbose,
    'm|mail:i'        => \$mail,
    'zebraqueue:i'    => \$zebraqueue_days,
    'merged'          => \$purge_merged,
    'import:i'        => \$pImport,
    'z3950'           => \$pZ3950,
    'logs:i'          => \$pLogs,
    'searchhistory:i' => \$pSearchhistory,
    'list-invites:i'  => \$pListShareInvites,
    'restrictions:i'  => \$pDebarments,
) || usage(1);

# Use default values
$sessions          = 1                                    if $sess_days                  && $sess_days > 0;
$pImport           = DEFAULT_IMPORT_PURGEDAYS             if defined($pImport)           && $pImport == 0;
$pLogs             = DEFAULT_LOGS_PURGEDAYS               if defined($pLogs)             && $pLogs == 0;
$zebraqueue_days   = DEFAULT_ZEBRAQ_PURGEDAYS             if defined($zebraqueue_days)   && $zebraqueue_days == 0;
$mail              = DEFAULT_MAIL_PURGEDAYS               if defined($mail)              && $mail == 0;
$pSearchhistory    = DEFAULT_SEARCHHISTORY_PURGEDAYS      if defined($pSearchhistory)    && $pSearchhistory == 0;
$pListShareInvites = DEFAULT_SHARE_INVITATION_EXPIRY_DAYS if defined($pListShareInvites) && $pListShareInvites == 0;
$pDebarments       = DEFAULT_DEBARMENTS_PURGEDAYS         if defined($pDebarments)       && $pDebarments == 0;

if ($help) {
    usage(0);
}

unless ( $sessions
    || $zebraqueue_days
    || $mail
    || $purge_merged
    || $pImport
    || $pLogs
    || $pSearchhistory
    || $pZ3950
    || $pListShareInvites
    || $pDebarments )
{
    print "You did not specify any cleanup work for the script to do.\n\n";
    usage(1);
}

my $dbh = C4::Context->dbh();
my $sth;
my $sth2;
my $count;

if ( $sessions && !$sess_days ) {
    if ($verbose) {
        print "Session purge triggered.\n";
        $sth = $dbh->prepare(q{ SELECT COUNT(*) FROM sessions });
        $sth->execute() or die $dbh->errstr;
        my @count_arr = $sth->fetchrow_array;
        print "$count_arr[0] entries will be deleted.\n";
    }
    $sth = $dbh->prepare(q{ TRUNCATE sessions });
    $sth->execute() or die $dbh->errstr;
    if ($verbose) {
        print "Done with session purge.\n";
    }
}
elsif ( $sessions && $sess_days > 0 ) {
    print "Session purge triggered with days>$sess_days.\n" if $verbose;
    RemoveOldSessions();
    print "Done with session purge with days>$sess_days.\n" if $verbose;
}

if ($zebraqueue_days) {
    $count = 0;
    print "Zebraqueue purge triggered for $zebraqueue_days days.\n" if $verbose;
    $sth = $dbh->prepare(
        q{
            SELECT id,biblio_auth_number,server,time
            FROM zebraqueue
            WHERE done=1 AND time < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($zebraqueue_days) or die $dbh->errstr;
    $sth2 = $dbh->prepare(q{ DELETE FROM zebraqueue WHERE id=? });
    while ( my $record = $sth->fetchrow_hashref ) {
        $sth2->execute( $record->{id} ) or die $dbh->errstr;
        $count++;
    }
    print "$count records were deleted.\nDone with zebraqueue purge.\n" if $verbose;
}

if ($mail) {
    print "Mail queue purge triggered for $mail days.\n" if $verbose;
    $sth = $dbh->prepare(
        q{
            DELETE FROM message_queue
            WHERE time_queued < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($mail) or die $dbh->errstr;
    $count = $sth->rows;
    $sth->finish;
    print "$count messages were deleted from the mail queue.\nDone with message_queue purge.\n" if $verbose;
}

if ($purge_merged) {
    print "Purging completed entries from need_merge_authorities.\n" if $verbose;
    $sth = $dbh->prepare(q{ DELETE FROM need_merge_authorities WHERE done=1 });
    $sth->execute() or die $dbh->errstr;
    print "Done with purging need_merge_authorities.\n" if $verbose;
}

if ($pImport) {
    print "Purging records from import tables.\n" if $verbose;
    PurgeImportTables();
    print "Done with purging import tables.\n" if $verbose;
}

if ($pZ3950) {
    print "Purging Z39.50 records from import tables.\n" if $verbose;
    PurgeZ3950();
    print "Done with purging Z39.50 records from import tables.\n" if $verbose;
}

if ($pLogs) {
    print "Purging records from action_logs.\n" if $verbose;
    $sth = $dbh->prepare(
        q{
            DELETE FROM action_logs
            WHERE timestamp < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($pLogs) or die $dbh->errstr;
    print "Done with purging action_logs.\n" if $verbose;
}

if ($pSearchhistory) {
    print "Purging records older than $pSearchhistory from search_history.\n" if $verbose;
    PurgeSearchHistory($pSearchhistory);
    print "Done with purging search_history.\n" if $verbose;
}

if ($pListShareInvites) {
    print "Purging unaccepted list share invites older than $pListShareInvites days.\n" if $verbose;
    $sth = $dbh->prepare(
        q{
            DELETE FROM virtualshelfshares
            WHERE invitekey IS NOT NULL
            AND (sharedate + INTERVAL ? DAY) < NOW()
        }
    );
    $sth->execute($pListShareInvites);
    print "Done with purging unaccepted list share invites.\n" if $verbose;
}

if ($pDebarments) {
    print "Expired patrons restrictions purge triggered for $pDebarments days.\n" if $verbose;
    $count = PurgeDebarments();
    print "$count restrictions were deleted.\nDone with restrictions purge.\n" if $verbose;
}

exit(0);

sub RemoveOldSessions {
    my ( $id, $a_session, $limit, $lasttime );
    $limit = time() - 24 * 3600 * $sess_days;

    $sth = $dbh->prepare(q{ SELECT id, a_session FROM sessions });
    $sth->execute or die $dbh->errstr;
    $sth->bind_columns( \$id, \$a_session );
    $sth2  = $dbh->prepare(q{ DELETE FROM sessions WHERE id=? });
    $count = 0;

    while ( $sth->fetch ) {
        $lasttime = 0;
        if ( $a_session =~ /lasttime:\s+'?(\d+)/ ) {
            $lasttime = $1;
        }
        elsif ( $a_session =~ /(ATIME|CTIME):\s+'?(\d+)/ ) {
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
    $sth = $dbh->prepare(
        q{
            DELETE FROM import_records
            WHERE upload_timestamp < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($pImport) or die $dbh->errstr;

    # Now purge import_batches
    # Timestamp cannot be used here without care, because records are added
    # continuously to batches without updating timestamp (Z39.50 search).
    # So we only delete older empty batches.
    # This delete will therefore not have a cascading effect.
    $sth = $dbh->prepare(
        q{
            DELETE ba
            FROM import_batches ba
            LEFT JOIN import_records re ON re.import_batch_id=ba.import_batch_id
            WHERE re.import_record_id IS NULL AND
            ba.upload_timestamp < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($pImport) or die $dbh->errstr;
}

sub PurgeZ3950 {
    $sth = $dbh->prepare(
        q{
            DELETE FROM import_batches
            WHERE batch_type = 'z3950'
        }
    );
    $sth->execute() or die $dbh->errstr;
}

sub PurgeDebarments {
    require Koha::Borrower::Debarments;
    $count = 0;
    $sth   = $dbh->prepare(
        q{
            SELECT borrower_debarment_id
            FROM borrower_debarments
            WHERE expiration < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($pDebarments) or die $dbh->errstr;
    while ( my ($borrower_debarment_id) = $sth->fetchrow_array ) {
        Koha::Borrower::Debarments::DelDebarment($borrower_debarment_id);
        $count++;
    }
    return $count;
}
