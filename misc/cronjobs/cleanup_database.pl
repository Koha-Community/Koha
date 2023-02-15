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
use constant DEFAULT_MESSAGES_PURGEDAYS           => 365;
use constant DEFAULT_SEARCHHISTORY_PURGEDAYS      => 30;
use constant DEFAULT_SHARE_INVITATION_EXPIRY_DAYS => 14;
use constant DEFAULT_DEBARMENTS_PURGEDAYS         => 30;
use constant DEFAULT_JOBS_PURGEDAYS               => 1;
use constant DEFAULT_JOBS_PURGETYPES              => qw{ update_elastic_index };
use constant DEFAULT_EDIFACT_MSG_PURGEDAYS        => 365;

use Koha::Script -cron;
use C4::Context;
use C4::Search;
use C4::Search::History;
use Getopt::Long qw( GetOptions );
use C4::Log qw( cronlogaction );
use C4::Accounts qw( purge_zero_balance_fees );
use Koha::UploadedFiles;
use Koha::BackgroundJobs;
use Koha::Old::Biblios;
use Koha::Old::Items;
use Koha::Old::Biblioitems;
use Koha::Old::Checkouts;
use Koha::Old::Holds;
use Koha::Old::Patrons;
use Koha::Item::Transfers;
use Koha::PseudonymizedTransactions;
use Koha::Patron::Messages;
use Koha::Patron::Debarments qw( DelDebarment );
use Koha::Database;

sub usage {
    print STDERR <<USAGE;
Usage: $0 [-h|--help] [--confirm] [--sessions] [--sessdays DAYS] [-v|--verbose] [--zebraqueue DAYS] [-m|--mail] [--merged] [--import DAYS] [--logs DAYS] [--searchhistory DAYS] [--restrictions DAYS] [--all-restrictions] [--fees DAYS] [--temp-uploads] [--temp-uploads-days DAYS] [--uploads-missing 0|1 ] [--statistics DAYS] [--deleted-catalog DAYS] [--deleted-patrons DAYS] [--old-issues DAYS] [--old-reserves DAYS] [--transfers DAYS] [--labels DAYS] [--cards DAYS] [--bg-days DAYS [--bg-type TYPE] ] [--edifact-messages DAYS]

   -h --help          prints this help message, and exits, ignoring all
                      other options
   --confirm          Confirmation flag, the script will be running in dry-run mode is not set.
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
   --messages DAYS    purge entries from messages table older than DAYS days.
                      Defaults to 365 days if no days specified.
   --import DAYS      purge records from import tables older than DAYS days.
                      Defaults to 60 days if no days specified.
   --z3950            purge records from import tables that are the result
                      of Z39.50 searches
   --fees DAYS        purge entries accountlines older than DAYS days, where
                      amountoutstanding is 0 or NULL.
                      In the case of --fees, DAYS must be greater than
                      or equal to 1.
   --log-modules      Specify which action log modules to trim. Repeatable.
   --preserve-log     Specify which action logs to exclude. Repeatable.
   --logs DAYS        purge entries from action_logs older than DAYS days.
                      Defaults to 180 days if no days specified.
   --searchhistory DAYS  purge entries from search_history older than DAYS days.
                         Defaults to 30 days if no days specified
   --list-invites  DAYS  purge (unaccepted) list share invites older than DAYS
                         days.  Defaults to 14 days if no days specified.
   --restrictions DAYS   purge patrons restrictions expired since more than DAYS days.
                         Defaults to 30 days if no days specified.
   --all-restrictions   purge all expired patrons restrictions.
   --del-exp-selfreg  Delete expired self registration accounts
   --del-unv-selfreg  DAYS  Delete unverified self registrations older than DAYS
   --unique-holidays DAYS  Delete all unique holidays older than DAYS
   --temp-uploads     Delete temporary uploads.
   --temp-uploads-days DAYS Override the corresponding preference value.
   --uploads-missing FLAG Delete upload records for missing files when FLAG is true, count them otherwise
   --oauth-tokens     Delete expired OAuth2 tokens
   --statistics DAYS       Purge statistics entries more than DAYS days old.
                           This table is used to build reports, make sure you are aware of the consequences of this before using it!
   --deleted-catalog  DAYS Purge catalog records deleted more then DAYS days ago
                           (from tables deleteditems, deletedbiblioitems, deletedbiblio_metadata and deletedbiblio).
   --deleted-patrons DAYS  Purge patrons deleted more than DAYS days ago.
   --old-issues DAYS       Purge checkouts (old_issues) returned more than DAYS days ago.
   --old-reserves DAYS     Purge reserves (old_reserves) more than DAYS old.
   --transfers DAYS        Purge transfers completed more than DAYS day ago.
   --pseudo-transactions DAYS   Purge the pseudonymized transactions that have been originally created more than DAYS days ago
                                DAYS is optional and can be replaced by:
                                    --pseudo-transactions-from YYYY-MM-DD and/or --pseudo-transactions-to YYYY-MM-DD
   --labels DAYS           Purge item label batches last added to more than DAYS days ago.
   --cards DAY             Purge card creator batches last added to more than DAYS days ago.
   --return-claims         Purge all resolved return claims older than the number of days specified in
                           the system preference CleanUpDatabaseReturnClaims.
   --jobs-days DAYS        Purge all finished background jobs this many days old. Defaults to 1 if no DAYS provided.
   --jobs-type TYPES       What type of background job to purge. Defaults to "update_elastic_index" if omitted
                           Specifying "all" will purge all types. Repeatable.
   --reports DAYS          Purge reports data saved more than DAYS days ago. The data is created by running runreport.pl with the --store-results option.
   --edifact-messages DAYS   Purge entries from edifact_messages table older than DAYS days.
                             Defaults to 365 days if no days specified.
USAGE
    exit $_[0];
}

my $help;
my $confirm;
my $sessions;
my $sess_days;
my $verbose;
my $zebraqueue_days;
my $mail;
my $purge_merged;
my $pImport;
my $pLogs;
my $pSearchhistory;
my $pZ3950;
my $pListShareInvites;
my $pDebarments;
my $allDebarments;
my $return_claims;
my $pExpSelfReg;
my $pUnvSelfReg;
my $fees_days;
my $special_holidays_days;
my $temp_uploads;
my $temp_uploads_days;
my $uploads_missing;
my $oauth_tokens;
my $pStatistics;
my $pDeletedCatalog;
my $pDeletedPatrons;
my $pOldIssues;
my $pOldReserves;
my $pTransfers;
my ( $pPseudoTransactions, $pPseudoTransactionsFrom, $pPseudoTransactionsTo );
my $pMessages;
my $lock_days = C4::Context->preference('LockExpiredDelay');
my $labels;
my $cards;
my @log_modules;
my @preserve_logs;
my $jobs_days;
my @jobs_types;
my $reports;
my $edifact_msg_days;

my $command_line_options = join(" ",@ARGV);

GetOptions(
    'h|help'                     => \$help,
    'confirm'                    => \$confirm,
    'sessions'                   => \$sessions,
    'sessdays:i'                 => \$sess_days,
    'v|verbose'                  => \$verbose,
    'm|mail:i'                   => \$mail,
    'zebraqueue:i'               => \$zebraqueue_days,
    'merged'                     => \$purge_merged,
    'import:i'                   => \$pImport,
    'z3950'                      => \$pZ3950,
    'logs:i'                     => \$pLogs,
    'log-module:s'               => \@log_modules,
    'preserve-log:s'             => \@preserve_logs,
    'messages:i'                 => \$pMessages,
    'fees:i'                     => \$fees_days,
    'searchhistory:i'            => \$pSearchhistory,
    'list-invites:i'             => \$pListShareInvites,
    'restrictions:i'             => \$pDebarments,
    'all-restrictions'           => \$allDebarments,
    'del-exp-selfreg'            => \$pExpSelfReg,
    'del-unv-selfreg:i'          => \$pUnvSelfReg,
    'unique-holidays:i'          => \$special_holidays_days,
    'temp-uploads'               => \$temp_uploads,
    'temp-uploads-days:i'        => \$temp_uploads_days,
    'uploads-missing:i'          => \$uploads_missing,
    'oauth-tokens'               => \$oauth_tokens,
    'statistics:i'               => \$pStatistics,
    'deleted-catalog:i'          => \$pDeletedCatalog,
    'deleted-patrons:i'          => \$pDeletedPatrons,
    'old-issues:i'               => \$pOldIssues,
    'old-reserves:i'             => \$pOldReserves,
    'transfers:i'                => \$pTransfers,
    'pseudo-transactions:i'      => \$pPseudoTransactions,
    'pseudo-transactions-from:s' => \$pPseudoTransactionsFrom,
    'pseudo-transactions-to:s'   => \$pPseudoTransactionsTo,
    'labels'                     => \$labels,
    'cards'                      => \$cards,
    'return-claims'              => \$return_claims,
    'jobs-type:s'                => \@jobs_types,
    'jobs-days:i'                => \$jobs_days,
    'reports:i'                  => \$reports,
    'edifact-messages:i'         => \$edifact_msg_days,
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
$pMessages         = DEFAULT_MESSAGES_PURGEDAYS           if defined($pMessages)         && $pMessages == 0;
$jobs_days         = DEFAULT_JOBS_PURGEDAYS               if defined($jobs_days)         && $jobs_days == 0;
@jobs_types        = (DEFAULT_JOBS_PURGETYPES)            if $jobs_days                  && @jobs_types == 0;
$edifact_msg_days  = DEFAULT_EDIFACT_MSG_PURGEDAYS        if defined($edifact_msg_days)  && $edifact_msg_days == 0;

if ($help) {
    usage(0);
}

unless ( $sessions
    || $zebraqueue_days
    || $mail
    || $purge_merged
    || $pImport
    || $pLogs
    || $fees_days
    || $pSearchhistory
    || $pZ3950
    || $pListShareInvites
    || $pDebarments
    || $allDebarments
    || $pExpSelfReg
    || $pUnvSelfReg
    || $special_holidays_days
    || $temp_uploads
    || defined $uploads_missing
    || $oauth_tokens
    || $pStatistics
    || $pDeletedCatalog
    || $pDeletedPatrons
    || $pOldIssues
    || $pOldReserves
    || $pTransfers
    || defined $pPseudoTransactions
    || $pPseudoTransactionsFrom
    || $pPseudoTransactionsTo
    || $pMessages
    || defined $lock_days && $lock_days ne q{}
    || $labels
    || $cards
    || $return_claims
    || $jobs_days
    || $reports
    || $edifact_msg_days
) {
    print "You did not specify any cleanup work for the script to do.\n\n";
    usage(1);
}

if ($pDebarments && $allDebarments) {
    print "You can not specify both --restrictions and --all-restrictions.\n\n";
    usage(1);
}

say "Confirm flag not passed, running in dry-run mode..." unless $confirm;

cronlogaction({ info => $command_line_options });

my $dbh = C4::Context->dbh();
my $sth;
my $sth2;

if ( $sessions && !$sess_days ) {
    if ($verbose) {
        say "Session purge triggered.";
        $sth = $dbh->prepare(q{ SELECT COUNT(*) FROM sessions });
        $sth->execute() or die $dbh->errstr;
        my @count_arr = $sth->fetchrow_array;
        say $confirm ? "$count_arr[0] entries will be deleted." : "$count_arr[0] entries would be deleted.";
    }
    if ( $confirm ) {
        $sth = $dbh->prepare(q{ TRUNCATE sessions });
        $sth->execute() or die $dbh->errstr;
    }
    if ($verbose) {
        print "Done with session purge.\n";
    }
}
elsif ( $sessions && $sess_days > 0 ) {
    print "Session purge triggered with days>$sess_days.\n" if $verbose;
    RemoveOldSessions() if $confirm;
    print "Done with session purge with days>$sess_days.\n" if $verbose;
}

if ($zebraqueue_days) {
    my $count = 0;
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
        if ( $confirm ) {
            $sth2->execute( $record->{id} ) or die $dbh->errstr;
        }
        $count++;
    }
    if ( $verbose ) {
        say $confirm ? "$count records were deleted." : "$count records would have been deleted.";
        say "Done with zebraqueue purge.";
    }
}

if ($mail) {
    my $count = 0;
    print "Mail queue purge triggered for $mail days.\n" if $verbose;
    $sth = $dbh->prepare(
        q{
            DELETE FROM message_queue
            WHERE time_queued < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    if ( $confirm ) {
        $sth->execute($mail) or die $dbh->errstr;
        $count = $sth->rows;
    }
    if ( $verbose ) {
        say $confirm ? "$count messages were deleted from the mail queue." : "Message from message_queue would have been deleted";
        say "Done with message_queue purge.";
    }
}

if ($purge_merged) {
    print "Purging completed entries from need_merge_authorities.\n" if $verbose;
    if ( $confirm ) {
        $sth = $dbh->prepare(q{ DELETE FROM need_merge_authorities WHERE done=1 });
        $sth->execute() or die $dbh->errstr;
    }
    print "Done with purging need_merge_authorities.\n" if $verbose;
}

if ($pImport) {
    print "Purging records from import tables.\n" if $verbose;
    PurgeImportTables() if $confirm;
    print "Done with purging import tables.\n" if $verbose;
}

if ($pZ3950) {
    print "Purging Z39.50 records from import tables.\n" if $verbose;
    PurgeZ3950() if $confirm;
    print "Done with purging Z39.50 records from import tables.\n" if $verbose;
}

if ($pLogs) {
    print "Purging records from action_logs.\n" if $verbose;
    my $log_query = q{
            DELETE FROM action_logs
            WHERE timestamp < date_sub(curdate(), INTERVAL ? DAY)
    };
    my @query_params = ();
    if( @preserve_logs ){
        $log_query .= " AND module NOT IN (" . join(',',('?') x @preserve_logs ) . ")";
        push @query_params, @preserve_logs;
    }
    if( @log_modules ){
        $log_query .= " AND module IN (" . join(',',('?') x @log_modules ) . ")";
        push @query_params, @log_modules;
    }
    $sth = $dbh->prepare( $log_query );
    if ( $confirm ) {
        $sth->execute($pLogs, @query_params) or die $dbh->errstr;
    }
    print "Done with purging action_logs.\n" if $verbose;
}

if ($pMessages) {
    print "Purging messages older than $pMessages days.\n" if $verbose;
    my $messages = Koha::Patron::Messages->filter_by_last_update(
        { timestamp_column_name => 'message_date', days => $pMessages } );
    my $count = $messages->count;
    $messages->delete if $confirm;
    if ( $verbose ) {
        say $confirm
          ? sprintf( "Done with purging %d messages", $count )
          : sprintf( "%d messages would have been removed", $count );
    }
}

if ($fees_days) {
    print "Purging records from accountlines.\n" if $verbose;
    purge_zero_balance_fees( $fees_days ) if $confirm;
    print "Done purging records from accountlines.\n" if $verbose;
}

if ($pSearchhistory) {
    print "Purging records older than $pSearchhistory from search_history.\n" if $verbose;
    C4::Search::History::delete({ interval => $pSearchhistory }) if $confirm;
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
    if ( $confirm ) {
        $sth->execute($pListShareInvites);
    }
    print "Done with purging unaccepted list share invites.\n" if $verbose;
}

if ($pDebarments) {
    print "Expired patrons restrictions purge triggered for $pDebarments days.\n" if $verbose;
    my $count = PurgeDebarments($pDebarments, $confirm);
    if ( $verbose ) {
        say $confirm ? "$count restrictions were deleted." : "$count restrictions would have been deleted";
        say "Done with restrictions purge.";
    }
}

if($allDebarments) {
    print "All expired patrons restrictions purge triggered.\n" if $verbose;
    my $count = PurgeDebarments(0, $confirm);
    if ( $verbose ) {
        say $confirm ? "$count restrictions were deleted." : "$count restrictions would have been deleted";
        say "Done with all restrictions purge.";
    }
}

# Lock expired patrons?
if( defined $lock_days && $lock_days ne q{} ) {
    say "Start locking expired patrons" if $verbose;
    my $expired_patrons = Koha::Patrons->filter_by_expiration_date({ days => $lock_days })->search({ login_attempts => { '!=' => -1 } });
    my $count = $expired_patrons->count;
    $expired_patrons->lock({ remove => 1 }) if $confirm;
    if( $verbose ) {
        say $confirm ? sprintf("Locked %d patrons", $count) : sprintf("Found %d patrons", $count);
    }
}

# Handle unsubscribe requests from GDPR consent form, depends on UnsubscribeReflectionDelay preference
say "Start lock unsubscribed, anonymize and delete" if $verbose;
my $unsubscribed_patrons = Koha::Patrons->search_unsubscribed;
my $count = $unsubscribed_patrons->count;
$unsubscribed_patrons->lock( { expire => 1, remove => 1 } ) if $confirm;
say $confirm ? sprintf("Locked %d patrons", $count) : sprintf("%d patrons would have been locked", $count) if $verbose;

# Anonymize patron data, depending on PatronAnonymizeDelay
my $anonymize_candidates = Koha::Patrons->search_anonymize_candidates( { locked => 1 } );
$count = $anonymize_candidates->count;
$anonymize_candidates->anonymize if $confirm;
say $confirm ? sprintf("Anonymized %d patrons", $count) : sprintf("%d patrons would have been anonymized", $count) if $verbose;

# Remove patron data, depending on PatronRemovalDelay (will raise an exception if problem encountered
my $anonymized_patrons = Koha::Patrons->search_anonymized;
$count = $anonymized_patrons->count;
if ( $confirm ) {
    $anonymized_patrons->delete( { move => 1 } );
    if ($@) {
        warn $@;
    }
}
if ($verbose) {
    say $confirm ? sprintf("Deleted %d patrons", $count) : sprintf("%d patrons would have been deleted", $count);
}

# FIXME The output for dry-run mode needs to be improved
# But non trivial changes to C4::Members need to be done before.
if( $pExpSelfReg ) {
    if ( $confirm ) {
        DeleteExpiredSelfRegs();
    } elsif ( $verbose ) {
        say "self-registered borrowers may be deleted";
    }
}
if( $pUnvSelfReg ) {
    if ( $confirm ) {
        DeleteUnverifiedSelfRegs( $pUnvSelfReg );
    } elsif ( $verbose ) {
        say "unverified self-registrations may be deleted";
    }
}

if ($special_holidays_days) {
    if ( $confirm ) {
        DeleteSpecialHolidays( abs($special_holidays_days) );
    } elsif ( $verbose ) {
        say "self-registered borrowers may be deleted";
    }
}

if( $temp_uploads ) {
    # Delete temporary uploads, governed by a pref (unless you override)
    print "Purging temporary uploads.\n" if $verbose;
    if ( $confirm ) {
        Koha::UploadedFiles->delete_temporary({
            defined($temp_uploads_days)
                ? ( override_pref => $temp_uploads_days )
                : ()
        });
    }
    print "Done purging temporary uploads.\n" if $verbose;
}

if( defined $uploads_missing ) {
    print "Looking for missing uploads\n" if $verbose;
    if ( $confirm ) {
        my $keep = $uploads_missing == 1 ? 0 : 1;
        my $count = Koha::UploadedFiles->delete_missing({ keep_record => $keep });
        if( $keep ) {
            print "Counted $count missing uploaded files\n";
        } else {
            print "Removed $count records for missing uploads\n";
        }
    } else {
        # FIXME need to create a filter_by_missing method (then call ->delete) instead of delete_missing
        say "Dry-run mode cannot guess how many uploads would have been deleted";
    }
}

if ($oauth_tokens) {
    require Koha::OAuthAccessTokens;

    my $tokens = Koha::OAuthAccessTokens->search({ expires => { '<=', time } });
    my $count = $tokens->count;
    $tokens->delete if $confirm;
    if ( $verbose ) {
        say $confirm
          ? sprintf( "Removed %d expired OAuth2 tokens", $count )
          : sprintf( "%d expired OAuth tokens would have been removed", $count );
    }
}

if ($pStatistics) {
    print "Purging statistics older than $pStatistics days.\n" if $verbose;
    my $statistics = Koha::Statistics->filter_by_last_update(
        { timestamp_column_name => 'datetime', days => $pStatistics } );
    my $count = $statistics->count;
    $statistics->delete if $confirm;
    if ( $verbose ) {
        say $confirm
          ? sprintf( "Done with purging %d statistics", $count )
          : sprintf( "%d statistics would have been removed", $count );
    }
}

if( $return_claims && ( my $days = C4::Context->preference('CleanUpDatabaseReturnClaims') )) {
    print "Purging return claims older than $days days.\n" if $verbose;

    $return_claims = Koha::Checkouts::ReturnClaims->filter_by_last_update(
        {
            timestamp_column_name => 'resolved_on',
            days => $days,
        }
    );

    my $count = $return_claims->count;
    $return_claims->delete if $confirm;

    if ($verbose) {
        say $confirm
            ? sprintf "Done with purging %d resolved return claims.", $count
            : sprintf "%d resolved return claims would have been purged.", $count;
    }
}

if ($pDeletedCatalog) {
    print "Purging deleted catalog older than $pDeletedCatalog days.\n"
      if $verbose;
    my $old_items = Koha::Old::Items->filter_by_last_update( { days => $pDeletedCatalog } );
    my $old_biblioitems = Koha::Old::Biblioitems->filter_by_last_update( { days => $pDeletedCatalog } );
    my $old_biblios = Koha::Old::Biblios->filter_by_last_update( { days => $pDeletedCatalog } );
    my ( $c_i, $c_bi, $c_b ) =
      ( $old_items->count, $old_biblioitems->count, $old_biblios->count );
    if ($confirm) {
        $old_items->delete;
        $old_biblioitems->delete;
        $old_biblios->delete;
    }
    if ($verbose) {
        say sprintf(
            $confirm
            ? "Done with purging deleted catalog (%d items, %d biblioitems, %d biblios)."
            : "Deleted catalog would have been removed (%d items, %d biblioitems, %d biblios).",
        $c_i, $c_bi, $c_b);
    }
}

if ($pDeletedPatrons) {
    print "Purging deleted patrons older than $pDeletedPatrons days.\n" if $verbose;
    my $old_patrons = Koha::Old::Patrons->filter_by_last_update(
        { timestamp_column_name => 'updated_on', days => $pDeletedPatrons } );
    my $count = $old_patrons->count;
    $old_patrons->delete if $confirm;
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d deleted patrons.", $count
          : sprintf "%d deleted patrons would have been purged.", $count;
    }
}

if ($pOldIssues) {
    print "Purging old checkouts older than $pOldIssues days.\n" if $verbose;
    my $old_checkouts = Koha::Old::Checkouts->filter_by_last_update( { days => $pOldIssues } );
    my $count = $old_checkouts->count;
    $old_checkouts->delete if $confirm;
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d old checkouts.", $count
          : sprintf "%d old checkouts would have been purged.", $count;
    }
}

if ($pOldReserves) {
    print "Purging old reserves older than $pOldReserves days.\n" if $verbose;
    my $old_reserves = Koha::Old::Holds->filter_by_last_update( { days => $pOldReserves } );
    my $count = $old_reserves->count;
    $old_reserves->delete if $confirm;
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d old reserves.", $count
          : sprintf "%d old reserves would have been purged.", $count;
    }
}

if ($pTransfers) {
    print "Purging arrived item transfers older than $pTransfers days.\n" if $verbose;
    my $transfers = Koha::Item::Transfers->filter_by_last_update(
        {
            timestamp_column_name => 'datearrived',
            days => $pTransfers,
        }
    );
    my $count = $transfers->count;
    $transfers->delete if $confirm;
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d transfers.", $count
          : sprintf "%d transfers would have been purged.", $count;
    }
}

if (defined $pPseudoTransactions or $pPseudoTransactionsFrom or $pPseudoTransactionsTo ) {
    print "Purging pseudonymized transactions\n" if $verbose;
    my $anonymized_transactions = Koha::PseudonymizedTransactions->filter_by_last_update(
        {
            timestamp_column_name => 'datetime',
            ( defined $pPseudoTransactions  ? ( days => $pPseudoTransactions     ) : () ),
            ( $pPseudoTransactionsFrom      ? ( from => $pPseudoTransactionsFrom ) : () ),
            ( $pPseudoTransactionsTo        ? ( to   => $pPseudoTransactionsTo   ) : () ),
        }
    );
    my $count = $anonymized_transactions->count;
    $anonymized_transactions->delete if $confirm;
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d pseudonymized transactions.", $count
          : sprintf "%d pseudonymized transactions would have been purged.", $count;
    }
}

if ($labels) {
    print "Purging item label batches last added to more than $labels days ago.\n" if $verbose;
    my $count = PurgeCreatorBatches($labels, 'labels', $confirm);
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d item label batches last added to more than %d days ago.\n", $count, $labels
          : sprintf "%d item label batches would have been purged.", $count;
    }
}

if ($cards) {
    print "Purging card creator batches last added to more than $cards days ago.\n" if $verbose;
    my $count = PurgeCreatorBatches($labels, 'patroncards', $confirm);
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d card creator batches last added to more than %d days ago.\n", $count, $labels
          : sprintf "%d card creator batches would have been purged.", $count;
    }
}

if ($jobs_days) {
    print "Purging background jobs more than $jobs_days days ago.\n"
      if $verbose;
    my $jobs = Koha::BackgroundJobs->search(
        {
            status => 'finished',
            ( $jobs_types[0] eq 'all' ? () : ( type => \@jobs_types ) )
        }
    )->filter_by_last_update(
        {
            timestamp_column_name => 'ended_on',
            days => $jobs_days,
        }
    );
    my $count = $jobs->count;
    $jobs->delete if $confirm;
    if ($verbose) {
        say $confirm
          ? sprintf "Done with purging %d background jobs of type(s): %s added more than %d days ago.\n",
          $count, join( ',', @jobs_types ), $jobs_days
          : sprintf "%d background jobs of type(s): %s added more than %d days ago would have been purged.",
          $count, join( ',', @jobs_types ), $jobs_days;
    }
}

if ($reports) {
    if ( $confirm ) {
        PurgeSavedReports($reports);
    } if ( $verbose ) {
        say "Purging reports data saved more than $reports days ago.\n";
    }
}

if($edifact_msg_days) {
    print "Purging edifact messages older than $edifact_msg_days days.\n" if $verbose;
    my $count = PurgeEdifactMessages($edifact_msg_days, $confirm);
    if ( $verbose ) {
        say $confirm
          ? sprintf( "Done with purging %d edifact messages", $count )
          : sprintf( "%d edifact messages would have been removed", $count );
    }
}

cronlogaction({ action => 'End', info => "COMPLETED" });

exit(0);

sub RemoveOldSessions {
    my ( $id, $a_session, $limit, $lasttime );
    $limit = time() - 24 * 3600 * $sess_days;

    $sth = $dbh->prepare(q{ SELECT id, a_session FROM sessions });
    $sth->execute or die $dbh->errstr;
    $sth->bind_columns( \$id, \$a_session );
    $sth2  = $dbh->prepare(q{ DELETE FROM sessions WHERE id=? });
    my $count = 0;

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
    require Koha::Patron::Debarments;
    my ( $days, $doit ) = @_;
    my $count = 0;
    $sth   = $dbh->prepare(
        q{
            SELECT borrower_debarment_id
            FROM borrower_debarments
            WHERE expiration < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($days) or die $dbh->errstr;
    while ( my ($borrower_debarment_id) = $sth->fetchrow_array ) {
        Koha::Patron::Debarments::DelDebarment($borrower_debarment_id) if $doit;
        $count++;
    }
    return $count;
}

sub PurgeCreatorBatches {
    require C4::Labels::Batch;
    my ( $days, $creator, $doit ) = @_;
    my $count = 0;
    $sth = $dbh->prepare(
        q{
            SELECT batch_id, branch_code FROM creator_batches
            WHERE batch_id in
                (SELECT batch_id
                FROM (SELECT batch_id
                        FROM creator_batches
                        WHERE creator=?
                        GROUP BY batch_id
                        HAVING max(timestamp) <= date_sub(curdate(),interval ? day)) a)
        }
    );
    $sth->execute( $creator, $days ) or die $dbh->errstr;
    while ( my ( $batch_id, $branch_code ) = $sth->fetchrow_array ) {
        C4::Labels::Batch::delete(
            batch_id    => $batch_id,
            branch_code => $branch_code
        ) if $doit;
        $count++;
    }
    return $count;
}

sub DeleteExpiredSelfRegs {
    my $cnt= C4::Members::DeleteExpiredOpacRegistrations();
    print "Removed $cnt expired self-registered borrowers\n" if $verbose;
}

sub DeleteUnverifiedSelfRegs {
    my $cnt= C4::Members::DeleteUnverifiedOpacRegistrations( $_[0] );
    print "Removed $cnt unverified self-registrations\n" if $verbose;
}

sub DeleteSpecialHolidays {
    my ( $days ) = @_;

    my $sth = $dbh->prepare(q{
        DELETE FROM special_holidays
        WHERE DATE( CONCAT( year, '-', month, '-', day ) ) < DATE_SUB( CAST(NOW() AS DATE), INTERVAL ? DAY );
    });
    my $count = $sth->execute( $days ) + 0;
    print "Removed $count unique holidays\n" if $verbose;
}

sub PurgeSavedReports {
    my ( $reports ) = @_;

    my $sth = $dbh->prepare(q{
            DELETE FROM saved_reports
            WHERE date(date_run) < DATE_SUB(CURDATE(),INTERVAL ? DAY );
        });
    $sth->execute( $reports );
}

sub PurgeEdifactMessages {
    my ( $days, $doit ) = @_;

    my $count = 0;
    my $schema = Koha::Database->new()->schema();

    $sth = $dbh->prepare(
        q{
            SELECT id
            FROM edifact_messages
            WHERE transfer_date < date_sub(curdate(), INTERVAL ? DAY)
        }
    );
    $sth->execute($days) or die $dbh->errstr;

    while ( my ($msg_id) = $sth->fetchrow_array) {
        my $msg = $schema->resultset('EdifactMessage')->find($msg_id);
        $msg->delete if $doit;
        $count++;
    }
    return $count;
}
