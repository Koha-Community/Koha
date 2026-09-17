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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

cleanup_database.pl - Purge or clean up expired and stale entries from the Koha database.

=cut

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
use constant DEFAULT_JOBS_UNFINISHED_PURGEDAYS    => 365;
use constant DEFAULT_JOBS_UNFINISHED_PURGETYPES   => qw{ update_elastic_index };
use constant DEFAULT_EDIFACT_MSG_PURGEDAYS        => 365;
use constant DEFAULT_ILLREQUESTS_PURGEDAYS        => 30;

use Try::Tiny;

use Koha::Script -cron;

use C4::Accounts qw( purge_zero_balance_fees );
use C4::Context;
use C4::Log qw( cronlogaction );
use C4::Search::History;
use C4::Search;
use Koha::BackgroundJobs;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Item::Transfers;
use Koha::ILL::Requests;
use Koha::Library::Calendar::Exceptions;
use Koha::Library::Calendar::SingleClosures;
use Koha::Old::Biblioitems;
use Koha::Old::Biblios;
use Koha::Old::Checkouts;
use Koha::Old::Holds;
use Koha::Old::Items;
use Koha::Old::Patrons;
use Koha::Patron::Debarments qw( DelDebarment );
use Koha::Patron::Messages;
use Koha::PseudonymizedTransactions;
use Koha::Statistics;
use Koha::UploadedFiles;

my $lock_days = C4::Context->preference('LockExpiredDelay');

my $command_line_options = join( " ", @ARGV );
cronlogaction( { info => $command_line_options } );

my ( $opt, $usage ) = Koha::Script->describe_options(
    'Purge or clean up expired and stale entries from the Koha database. Runs in dry-run mode unless --confirm is given.

%c %o',
    [ 'confirm',   'commit changes to the database; without this, changes are reported but not made' ],
    [ 'verbose|v', 'give more information about what the script did/would do' ],

    [ 'sessions',   'purge the sessions table; logged-in users will have to reconnect' ],
    [ 'sessdays:i', 'purge only sessions older than this many days' ],

    [
        'zebraqueue:i',
        'purge completed zebraqueue entries older than this many days (default: ' . DEFAULT_ZEBRAQ_PURGEDAYS . ')'
    ],
    [ 'mail|m:i', 'purge mail queue entries older than this many days (default: ' . DEFAULT_MAIL_PURGEDAYS . ')' ],
    [ 'merged',   'purge completed entries from need_merge_authorities' ],
    [
        'import:i',
        'purge records from import tables older than this many days (default: ' . DEFAULT_IMPORT_PURGEDAYS . ')'
    ],
    [ 'z3950', 'purge import table records that are the result of Z39.50 searches' ],

    [ 'log-module:s@',   'action log module to trim (repeatable)' ],
    [ 'preserve-log:s@', 'action log module to exclude from trimming (repeatable)' ],
    [ 'log-action:s@',   'action log action entry to trim (repeatable)' ],
    [ 'logs:i', 'purge action_logs entries older than this many days (default: ' . DEFAULT_LOGS_PURGEDAYS . ')' ],

    [
        'messages:i',
        'purge messages table entries older than this many days (default: ' . DEFAULT_MESSAGES_PURGEDAYS . ')'
    ],
    [ 'fees:i', 'purge accountlines entries with a zero/null balance older than this many days (must be >= 1)' ],
    [
        'searchhistory:i',
        'purge search_history entries older than this many days (default: ' . DEFAULT_SEARCHHISTORY_PURGEDAYS . ')'
    ],
    [
        'list-invites:i',
        'purge unaccepted list share invites older than this many days; overrides the PurgeListShareInvitesOlderThan system preference'
    ],
    [
        'restrictions:i',
        'purge expired patron restrictions older than this many days (default: '
            . DEFAULT_DEBARMENTS_PURGEDAYS
            . '); may not be used with --all-restrictions'
    ],
    [ 'all-restrictions',    'purge all expired patron restrictions; may not be used with --restrictions' ],
    [ 'del-exp-selfreg',     'delete expired self-registration accounts' ],
    [ 'del-unv-selfreg:i',   'delete unverified self-registrations older than this many days' ],
    [ 'unique-holidays:i',   'delete unique holidays older than this many days' ],
    [ 'temp-uploads',        'delete temporary uploads' ],
    [ 'temp-uploads-days:i', 'override the corresponding system preference value' ],
    [ 'uploads-missing:i',   'delete upload records for missing files (1) or just count them (0)' ],
    [ 'oauth-tokens',        'delete expired OAuth2 tokens' ],
    [
        'statistics:i',
        'purge statistics entries older than this many days -- this table is used to build reports, be aware of the consequences before using it'
    ],
    [ 'statistics-type:s@', 'type of statistics to purge (repeatable); purges all types if omitted' ],
    [
        'statistics-type-pseudo:i',
        'purge pseudonymization statistic types (@Koha::Statistic::pseudonymization_types), unless more types are given with --statistics-type'
    ],
    [
        'deleted-catalog:i',
        'purge catalog records deleted more than this many days ago (deleteditems, deletedbiblioitems, deletedbiblio_metadata, deletedbiblio)'
    ],
    [ 'deleted-patrons:i', 'purge patrons deleted more than this many days ago' ],
    [ 'old-issues:i',      'purge checkouts (old_issues) returned more than this many days ago' ],
    [ 'old-reserves:i',    'purge reserves (old_reserves) more than this many days old' ],
    [ 'transfers:i',       'purge transfers completed more than this many days ago' ],
    [
        'pseudo-transactions:i',
        'purge pseudonymized transactions created more than this many days ago; may be replaced by --pseudo-transactions-from/-to'
    ],
    [ 'pseudo-transactions-from=s', 'purge pseudonymized transactions from this date (YYYY-MM-DD)' ],
    [ 'pseudo-transactions-to=s',   'purge pseudonymized transactions to this date (YYYY-MM-DD)' ],
    [ 'labels:i',                   'purge item label batches last added to more than this many days ago' ],
    [ 'cards:i',                    'purge card creator batches last added to more than this many days ago' ],
    [
        'return-claims',
        'purge all resolved return claims older than the number of days in the CleanUpDatabaseReturnClaims system preference'
    ],
    [
        'jobs-unfinished-type:s@',
        'type of unfinished background job to purge (repeatable, default: update_elastic_index); "all" purges all types'
    ],
    [
        'jobs-unfinished-days:i',
        'purge unfinished background jobs older than this many days (default: '
            . DEFAULT_JOBS_UNFINISHED_PURGEDAYS . ')'
    ],
    [
        'jobs-type:s@',
        'type of finished background job to purge (repeatable, default: update_elastic_index); "all" purges all types'
    ],
    [
        'jobs-days:i',
        'purge finished background jobs older than this many days (default: ' . DEFAULT_JOBS_PURGEDAYS . ')'
    ],
    [ 'reports:i', 'purge saved report data (from running runreport.pl --store-results) older than this many days' ],
    [
        'edifact-messages:i',
        'purge processed/failed EDIFACT messages older than this many days (default: '
            . DEFAULT_EDIFACT_MSG_PURGEDAYS . ')'
    ],
    [ 'illrequests-status:s@', 'ILL request status to remove (repeatable); requires --illrequests-days' ],
    [
        'illrequests-days:i',
        'purge ILL requests with the given status(es) older than this many days (default: '
            . DEFAULT_ILLREQUESTS_PURGEDAYS . ')'
    ],
    {
              epilog => "Examples:\n"
            . "  %c --sessions --verbose\n    Report (without deleting) how many sessions would be purged.\n\n"
            . "  %c --sessions --confirm\n    Purge the sessions table.\n\n"
            . "  %c --old-issues 730 --old-reserves 730 --confirm\n"
            . "    Purge old checkouts and reserves more than 2 years old.\n",
        exclusive => [ [qw(restrictions all-restrictions)] ],
    },
);

my $confirm                 = $opt->confirm;
my $sessions                = $opt->sessions;
my $sess_days               = $opt->sessdays;
my $verbose                 = $opt->verbose;
my $zebraqueue_days         = $opt->zebraqueue;
my $mail                    = $opt->mail;
my $purge_merged            = $opt->merged;
my $pImport                 = $opt->import;
my $pZ3950                  = $opt->z3950;
my $pLogs                   = $opt->logs;
my @log_modules             = @{ $opt->log_module   // [] };
my @preserve_logs           = @{ $opt->preserve_log // [] };
my @log_actions             = @{ $opt->log_action   // [] };
my $pMessages               = $opt->messages;
my $fees_days               = $opt->fees;
my $pSearchhistory          = $opt->searchhistory;
my $pListShareInvites       = $opt->list_invites;
my $pDebarments             = $opt->restrictions;
my $allDebarments           = $opt->all_restrictions;
my $pExpSelfReg             = $opt->del_exp_selfreg;
my $pUnvSelfReg             = $opt->del_unv_selfreg;
my $special_holidays_days   = $opt->unique_holidays;
my $temp_uploads            = $opt->temp_uploads;
my $temp_uploads_days       = $opt->temp_uploads_days;
my $uploads_missing         = $opt->uploads_missing;
my $oauth_tokens            = $opt->oauth_tokens;
my $pStatistics             = $opt->statistics;
my @statistics_types        = @{ $opt->statistics_type // [] };
my $statistics_type_pseudo  = $opt->statistics_type_pseudo;
my $pDeletedCatalog         = $opt->deleted_catalog;
my $pDeletedPatrons         = $opt->deleted_patrons;
my $pOldIssues              = $opt->old_issues;
my $pOldReserves            = $opt->old_reserves;
my $pTransfers              = $opt->transfers;
my $pPseudoTransactions     = $opt->pseudo_transactions;
my $pPseudoTransactionsFrom = $opt->pseudo_transactions_from;
my $pPseudoTransactionsTo   = $opt->pseudo_transactions_to;
my $labels                  = $opt->labels;
my $cards                   = $opt->cards;
my $return_claims           = $opt->return_claims;
my @jobs_unfinished_types   = @{ $opt->jobs_unfinished_type // [] };
my $jobs_unfinished_days    = $opt->jobs_unfinished_days;
my @jobs_types              = @{ $opt->jobs_type // [] };
my $jobs_days               = $opt->jobs_days;
my $reports                 = $opt->reports;
my $edifact_msg_days        = $opt->edifact_messages;
my $illrequests_days        = $opt->illrequests_days;
my @illrequests_statuses    = @{ $opt->illrequests_status // [] };

# Use default values
$sessions             = 1                               if $sess_days                && $sess_days > 0;
$pImport              = DEFAULT_IMPORT_PURGEDAYS        if defined($pImport)         && $pImport == 0;
$pLogs                = DEFAULT_LOGS_PURGEDAYS          if defined($pLogs)           && $pLogs == 0;
$zebraqueue_days      = DEFAULT_ZEBRAQ_PURGEDAYS        if defined($zebraqueue_days) && $zebraqueue_days == 0;
$mail                 = DEFAULT_MAIL_PURGEDAYS          if defined($mail)            && $mail == 0;
$pSearchhistory       = DEFAULT_SEARCHHISTORY_PURGEDAYS if defined($pSearchhistory)  && $pSearchhistory == 0;
$pDebarments          = DEFAULT_DEBARMENTS_PURGEDAYS    if defined($pDebarments)     && $pDebarments == 0;
$pMessages            = DEFAULT_MESSAGES_PURGEDAYS      if defined($pMessages)       && $pMessages == 0;
$jobs_unfinished_days = DEFAULT_JOBS_UNFINISHED_PURGEDAYS
    if defined($jobs_unfinished_days) && $jobs_unfinished_days == 0;
@jobs_unfinished_types = (DEFAULT_JOBS_UNFINISHED_PURGETYPES) if $jobs_unfinished_days && @jobs_unfinished_types == 0;
$jobs_days             = DEFAULT_JOBS_PURGEDAYS               if defined($jobs_days)   && $jobs_days == 0;
@jobs_types            = (DEFAULT_JOBS_PURGETYPES)            if $jobs_days            && @jobs_types == 0;
$edifact_msg_days      = DEFAULT_EDIFACT_MSG_PURGEDAYS        if defined($edifact_msg_days) && $edifact_msg_days == 0;
$illrequests_days      = DEFAULT_ILLREQUESTS_PURGEDAYS        if defined($illrequests_days) && $illrequests_days == 0;

@statistics_types = ( @statistics_types, @Koha::Statistic::pseudonymization_types ) if defined($statistics_type_pseudo);
@statistics_types = keys %{ { map { $_, 1 } @statistics_types } };    # remove duplicate types

# Choose the number of days at which to purge unaccepted list invites:
# - DAYS defined in the list-invites parameter is prioritised first
# - PurgeListShareInvitesOlderThan system preference is prioritised second
# - Default value of 14 days is prioritised last - if the list-invites parameter is passed without a DAYS value and the PurgeListShareInvitesOlderThan syspref is empty.
if ( !defined($pListShareInvites) ) {
    if ( C4::Context->preference('PurgeListShareInvitesOlderThan') ) {
        $pListShareInvites = C4::Context->preference('PurgeListShareInvitesOlderThan');
    }
} elsif ( defined($pListShareInvites) && $pListShareInvites == 0 ) {
    $pListShareInvites = DEFAULT_SHARE_INVITATION_EXPIRY_DAYS;
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
    || $jobs_unfinished_days
    || $reports
    || $edifact_msg_days
    || $illrequests_days
    || @illrequests_statuses )
{
    $usage->die( { pre_text => "You did not specify any cleanup work for the script to do.\n\n" } );
}

if ( @illrequests_statuses && !$illrequests_days ) {
    $illrequests_days = DEFAULT_ILLREQUESTS_PURGEDAYS;
}

if ( $illrequests_days && !@illrequests_statuses ) {
    $usage->die(
        { pre_text => "You must specify at least one --illrequests-status when using --illrequests-days.\n\n" } );
}

say "Confirm flag not passed, running in dry-run mode..." unless $confirm;

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
    if ($confirm) {
        $sth = $dbh->prepare(q{ TRUNCATE sessions });
        $sth->execute() or die $dbh->errstr;
    }
    if ($verbose) {
        print "Done with session purge.\n";
    }
} elsif ( $sessions && $sess_days > 0 ) {
    print "Session purge triggered with days>$sess_days.\n" if $verbose;
    RemoveOldSessions()                                     if $confirm;
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
        if ($confirm) {
            $sth2->execute( $record->{id} ) or die $dbh->errstr;
        }
        $count++;
    }
    if ($verbose) {
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
    if ($confirm) {
        $sth->execute($mail) or die $dbh->errstr;
        $count = $sth->rows;
    }
    if ($verbose) {
        say $confirm
            ? "$count messages were deleted from the mail queue."
            : "Message from message_queue would have been deleted";
        say "Done with message_queue purge.";
    }
}

if ($purge_merged) {
    print "Purging completed entries from need_merge_authorities.\n" if $verbose;
    if ($confirm) {
        $sth = $dbh->prepare(q{ DELETE FROM need_merge_authorities WHERE done=1 });
        $sth->execute() or die $dbh->errstr;
    }
    print "Done with purging need_merge_authorities.\n" if $verbose;
}

if ($pImport) {
    print "Purging records from import tables.\n" if $verbose;
    PurgeImportTables()                           if $confirm;
    print "Done with purging import tables.\n"    if $verbose;
}

if ($pZ3950) {
    print "Purging Z39.50 records from import tables.\n"           if $verbose;
    PurgeZ3950()                                                   if $confirm;
    print "Done with purging Z39.50 records from import tables.\n" if $verbose;
}

if ($pLogs) {
    print "Purging records from action_logs.\n" if $verbose;
    my $log_query = q{
            DELETE FROM action_logs
            WHERE timestamp < date_sub(curdate(), INTERVAL ? DAY)
    };
    my @query_params = ();
    if (@preserve_logs) {
        $log_query .= " AND module NOT IN (" . join( ',', ('?') x @preserve_logs ) . ")";
        push @query_params, @preserve_logs;
    }
    if (@log_modules) {
        $log_query .= " AND module IN (" . join( ',', ('?') x @log_modules ) . ")";
        push @query_params, @log_modules;
    }
    if (@log_actions) {
        $log_query .= " AND action IN (" . join( ',', ('?') x @log_actions ) . ")";
        push @query_params, @log_actions;
    }
    $sth = $dbh->prepare($log_query);
    if ($confirm) {
        $sth->execute( $pLogs, @query_params ) or die $dbh->errstr;
    }
    print "Done with purging action_logs.\n" if $verbose;
}

if ($pMessages) {
    print "Purging messages older than $pMessages days.\n" if $verbose;
    my $messages = Koha::Patron::Messages->filter_by_last_update(
        { timestamp_column_name => 'message_date', days => $pMessages } );
    my $count = $messages->count;
    $messages->delete if $confirm;
    if ($verbose) {
        say $confirm
            ? sprintf( "Done with purging %d messages",       $count )
            : sprintf( "%d messages would have been removed", $count );
    }
}

if ($fees_days) {
    print "Purging records from accountlines.\n"      if $verbose;
    purge_zero_balance_fees($fees_days)               if $confirm;
    print "Done purging records from accountlines.\n" if $verbose;
}

if ($pSearchhistory) {
    print "Purging records older than $pSearchhistory from search_history.\n" if $verbose;
    C4::Search::History::delete( { interval => $pSearchhistory } )            if $confirm;
    print "Done with purging search_history.\n"                               if $verbose;
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
    if ($confirm) {
        $sth->execute($pListShareInvites);
    }
    print "Done with purging unaccepted list share invites.\n" if $verbose;
}

if ($pDebarments) {
    print "Expired patrons restrictions purge triggered for $pDebarments days.\n" if $verbose;
    my $count = PurgeDebarments( $pDebarments, $confirm );
    if ($verbose) {
        say $confirm ? "$count restrictions were deleted." : "$count restrictions would have been deleted";
        say "Done with restrictions purge.";
    }
}

if ($allDebarments) {
    print "All expired patrons restrictions purge triggered.\n" if $verbose;
    my $count = PurgeDebarments( 0, $confirm );
    if ($verbose) {
        say $confirm ? "$count restrictions were deleted." : "$count restrictions would have been deleted";
        say "Done with all restrictions purge.";
    }
}

# Lock expired patrons?
if ( defined $lock_days && $lock_days ne q{} ) {
    say "Start locking expired patrons" if $verbose;
    my $expired_patrons = Koha::Patrons->filter_by_expiration_date( { days => $lock_days } )
        ->search( { login_attempts => { '!=' => -1 } } );
    my $count = $expired_patrons->count;
    $expired_patrons->lock( { remove => 1 } ) if $confirm;
    if ($verbose) {
        say $confirm ? sprintf( "Locked %d patrons", $count ) : sprintf( "Found %d patrons", $count );
    }
}

# Handle unsubscribe requests from GDPR consent form, depends on UnsubscribeReflectionDelay preference
say "Start lock unsubscribed, anonymize and delete" if $verbose;
my $unsubscribed_patrons = Koha::Patrons->search_unsubscribed;
my $count                = $unsubscribed_patrons->count;
$unsubscribed_patrons->lock( { expire => 1, remove => 1 } ) if $confirm;
say $confirm ? sprintf( "Locked %d patrons", $count ) : sprintf( "%d patrons would have been locked", $count )
    if $verbose;

# Anonymize patron data, depending on PatronAnonymizeDelay
my $anonymize_candidates = Koha::Patrons->search_anonymize_candidates( { locked => 1 } );
$count = $anonymize_candidates->count;
$anonymize_candidates->anonymize if $confirm;
say $confirm ? sprintf( "Anonymized %d patrons", $count ) : sprintf( "%d patrons would have been anonymized", $count )
    if $verbose;

# Remove patron data, depending on PatronRemovalDelay (will raise an exception if problem encountered
my $anonymized_patrons = Koha::Patrons->search_anonymized;
$count = $anonymized_patrons->count;
if ($confirm) {
    $anonymized_patrons->delete( { move => 1 } );
    if ($@) {
        warn $@;
    }
}
if ($verbose) {
    say $confirm ? sprintf( "Deleted %d patrons", $count ) : sprintf( "%d patrons would have been deleted", $count );
}

if ( $pExpSelfReg && C4::Context->preference('PatronSelfRegistration') ) {
    try {
        my $opac_registrations = Koha::Patrons->search->filter_by_expired_opac_registrations->filter_by_safe_to_delete;
        my $count              = $opac_registrations->count;
        $opac_registrations->delete if $confirm;
        if ($verbose) {
            say $confirm
                ? sprintf( "Done with removing %d expired self-registrations",      $count )
                : sprintf( "%d expired self-registrations would have been removed", $count );
        }
    } catch {
        if ( ref($_) eq 'Koha::Exceptions::SysPref::NotSet' ) {
            say sprintf "Self-registrations cannot be removed, system preference %s is not set", $_->syspref;
        } else {
            $_->rethrow;
        }
    };
}

if ($pUnvSelfReg) {
    my $opac_registrations =
        Koha::Patron::Modifications->search( { borrowernumber => 0 } )
        ->filter_by_last_update( { days => $pUnvSelfReg } );
    my $count = $opac_registrations->count;
    $opac_registrations->delete if $confirm;
    if ($verbose) {
        say $confirm
            ? sprintf( "Done with removing %d unverified self-registrations",      $count )
            : sprintf( "%d unverified self-registrations would have been removed", $count );
    }
}

# FIXME The output for dry-run mode needs to be improved
# But non trivial changes to C4::Members need to be done before.
if ($special_holidays_days) {
    if ($confirm) {
        DeleteSpecialHolidays( abs($special_holidays_days) );
    } elsif ($verbose) {
        say "self-registered borrowers may be deleted";
    }
}

if ($temp_uploads) {

    # Delete temporary uploads, governed by a pref (unless you override)
    print "Purging temporary uploads.\n" if $verbose;
    if ($confirm) {
        Koha::UploadedFiles->delete_temporary(
            {
                defined($temp_uploads_days)
                ? ( override_pref => $temp_uploads_days )
                : ()
            }
        );
    }
    print "Done purging temporary uploads.\n" if $verbose;
}

if ( defined $uploads_missing ) {
    print "Looking for missing uploads\n" if $verbose;
    if ($confirm) {
        my $keep  = $uploads_missing == 1 ? 0 : 1;
        my $count = Koha::UploadedFiles->delete_missing( { keep_record => $keep } );
        if ($keep) {
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

    my $tokens = Koha::OAuthAccessTokens->search( { expires => { '<=', time } } );
    my $count  = $tokens->count;
    $tokens->delete if $confirm;
    if ($verbose) {
        say $confirm
            ? sprintf( "Removed %d expired OAuth2 tokens",                $count )
            : sprintf( "%d expired OAuth tokens would have been removed", $count );
    }
}

if ($pStatistics) {
    print "Purging statistics older than $pStatistics days" if $verbose;
    my $statistics_search_params = {};

    if ( scalar(@statistics_types) ) {
        print " with types \"" . join( ',', @statistics_types ) . "\".\n" if $verbose;
        $statistics_search_params->{type} = \@statistics_types;

    }
    print "\n" if $verbose;

    my $statistics = Koha::Statistics->search($statistics_search_params);
    my $filtered_statistics =
        $statistics->filter_by_last_update( { timestamp_column_name => 'datetime', days => $pStatistics } );
    my $count = $filtered_statistics->count;
    $filtered_statistics->delete if $confirm;
    if ($verbose) {
        say $confirm
            ? sprintf( "Done with purging %d statistics",       $count )
            : sprintf( "%d statistics would have been removed", $count );
    }
}

if ( $return_claims && ( my $days = C4::Context->preference('CleanUpDatabaseReturnClaims') ) ) {
    print "Purging return claims older than $days days.\n" if $verbose;

    $return_claims = Koha::Checkouts::ReturnClaims->filter_by_last_update(
        {
            timestamp_column_name => 'resolved_on',
            days                  => $days,
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
    my $old_items       = Koha::Old::Items->filter_by_last_update( { days => $pDeletedCatalog } );
    my $old_biblioitems = Koha::Old::Biblioitems->filter_by_last_update( { days => $pDeletedCatalog } );
    my $old_biblios     = Koha::Old::Biblios->filter_by_last_update( { days => $pDeletedCatalog } );
    my ( $c_i, $c_bi, $c_b ) = ( $old_items->count, $old_biblioitems->count, $old_biblios->count );
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
            $c_i, $c_bi, $c_b
        );
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
    my $count         = $old_checkouts->count;
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
    my $count        = $old_reserves->count;
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
            days                  => $pTransfers,
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

if ( defined $pPseudoTransactions or $pPseudoTransactionsFrom or $pPseudoTransactionsTo ) {
    print "Purging pseudonymized transactions\n" if $verbose;
    if ($pPseudoTransactionsTo) {
        $pPseudoTransactionsTo = dt_from_string($pPseudoTransactionsTo);
        if ( $pPseudoTransactionsTo->hour == 0 && $pPseudoTransactionsTo->minute == 0 ) {
            $pPseudoTransactionsTo->set( hour => 23, minute => 59, second => 59 );
        }
    }
    if ($pPseudoTransactionsFrom) {
        $pPseudoTransactionsFrom = dt_from_string($pPseudoTransactionsFrom);
    }
    my $anonymized_transactions = Koha::PseudonymizedTransactions->filter_by_last_update(
        {
            timestamp_column_name => 'datetime',
            ( defined $pPseudoTransactions ? ( days => $pPseudoTransactions )     : () ),
            ( $pPseudoTransactionsFrom     ? ( from => $pPseudoTransactionsFrom ) : () ),
            ( $pPseudoTransactionsTo       ? ( to   => $pPseudoTransactionsTo )   : () ),
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
    my $count = PurgeCreatorBatches( $labels, 'labels', $confirm );
    if ($verbose) {
        say $confirm
            ? sprintf "Done with purging %d item label batches last added to more than %d days ago.\n", $count, $labels
            : sprintf "%d item label batches would have been purged.", $count;
    }
}

if ($cards) {
    print "Purging card creator batches last added to more than $cards days ago.\n" if $verbose;
    my $count = PurgeCreatorBatches( $cards, 'patroncards', $confirm );
    if ($verbose) {
        say $confirm
            ? sprintf "Done with purging %d card creator batches last added to more than %d days ago.\n", $count,
            $cards
            : sprintf "%d card creator batches would have been purged.", $count;
    }
}

if ($jobs_unfinished_days) {
    print "Purging unfinished background jobs more than $jobs_unfinished_days days ago.\n"
        if $verbose;
    my $jobs = Koha::BackgroundJobs->search(
        {
            status => { '!=' => 'finished' },
            ( $jobs_unfinished_types[0] eq 'all' ? () : ( type => \@jobs_unfinished_types ) )
        }
    )->filter_by_last_update(
        {
            timestamp_column_name => 'enqueued_on',
            days                  => $jobs_unfinished_days,
        }
    );
    my $count = $jobs->count;
    $jobs->delete if $confirm;
    if ($verbose) {
        say $confirm
            ? sprintf "Done with purging unfinished %d background jobs of type(s): %s added more than %d days ago.\n",
            $count, join( ',', @jobs_unfinished_types ), $jobs_unfinished_days
            : sprintf
            "%d unfinished background jobs of type(s): %s added more than %d days ago would have been purged.",
            $count, join( ',', @jobs_unfinished_types ), $jobs_unfinished_days;
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
            days                  => $jobs_days,
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
    if ($confirm) {
        PurgeSavedReports($reports);
    }
    if ($verbose) {
        say "Purging reports data saved more than $reports days ago.\n";
    }
}

if ($edifact_msg_days) {
    print "Purging EDIFACT messages older than $edifact_msg_days days.\n" if $verbose;
    my $count = PurgeEdifactMessages( $edifact_msg_days, $confirm );
    if ($verbose) {
        say $confirm
            ? sprintf( "Done with purging %d EDIFACT messages",       $count )
            : sprintf( "%d EDIFACT messages would have been removed", $count );
    }
}

if ($illrequests_days) {
    print "Purging ILL requests with statuses "
        . join( ', ', @illrequests_statuses )
        . " older than $illrequests_days days.\n"
        if $verbose;
    my $purgeable =
        Koha::ILL::Requests->filter_by_purgeable( { days => $illrequests_days, statuses => \@illrequests_statuses } );
    my $count = $purgeable->count;
    $purgeable->delete if $confirm;
    if ($verbose) {
        say $confirm
            ? sprintf( "Done with purging %d ILL requests.",      $count )
            : sprintf( "%d ILL requests would have been removed", $count );
    }
}

cronlogaction( { action => 'End', info => "COMPLETED" } );

exit(0);

sub RemoveOldSessions {
    my ( $id, $a_session, $limit, $lasttime );
    $limit = time() - 24 * 3600 * $sess_days;

    $sth = $dbh->prepare(q{ SELECT id, a_session FROM sessions });
    $sth->execute or die $dbh->errstr;
    $sth->bind_columns( \$id, \$a_session );
    $sth2 = $dbh->prepare(q{ DELETE FROM sessions WHERE id=? });
    my $count = 0;

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
    $sth = $dbh->prepare(
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

sub DeleteSpecialHolidays {
    my ($days) = @_;

    my $dtf    = Koha::Database->new->schema->storage->datetime_parser;
    my $cutoff = $dtf->format_date( dt_from_string->subtract( days => $days ) );

    my $count = 0;
    $count += Koha::Library::Calendar::SingleClosures->search( { date => { '<' => $cutoff } } )->delete + 0;
    $count += Koha::Library::Calendar::Exceptions->search( { date => { '<' => $cutoff } } )->delete + 0;

    print "Removed $count unique holidays\n" if $verbose;
}

sub PurgeSavedReports {
    my ($reports) = @_;

    my $sth = $dbh->prepare(
        q{
            DELETE FROM saved_reports
            WHERE date(date_run) < DATE_SUB(CURDATE(),INTERVAL ? DAY );
        }
    );
    $sth->execute($reports);
}

sub PurgeEdifactMessages {
    my ( $days, $doit ) = @_;

    my $schema    = Koha::Database->new()->schema();
    my $dtf       = $schema->storage->datetime_parser;
    my $resultset = $schema->resultset('EdifactMessage')->search(
        {
            transfer_date => { '<'  => $dtf->format_datetime( dt_from_string->subtract( days => $days ) ) },
            status        => { '!=' => 'new' },
        }
    );
    my $count = $resultset->count;

    $resultset->delete if $doit;

    return $count;
}

