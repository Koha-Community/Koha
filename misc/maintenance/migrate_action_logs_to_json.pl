#!/usr/bin/perl

# Copyright (C) 2025 OpenFifth
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

use Modern::Perl;
use Getopt::Long qw( GetOptions );
use Pod::Usage   qw( pod2usage );
use JSON         ();

use Koha::Script;
use C4::Context;
use Koha::ActionLogs;
use Koha::Checkouts;
use Koha::Old::Checkouts;
use Koha::Holds;
use Koha::Old::Holds;

=head1 NAME

migrate_action_logs_to_json.pl - Migrate old circulation and holds log entries to JSON format

=head1 SYNOPSIS

migrate_action_logs_to_json.pl [ -c | --commit ] [ -v | --verbose ] [ --help ]

 Options:
   --help or -h       Brief usage message
   --commit or -c     Actually update the database (default is dry run)
   --verbose or -v    Print detailed information about each conversion
   --batch-size       Number of records to process per batch (default: 1000)

=head1 DESCRIPTION

This script migrates old action log entries from the legacy ID-only format to
the new consistent JSON format. This is necessary after the fix for Bug 41358
which ensures all circulation and holds logs are stored in JSON format for
consistent reporting.

The script will:
1. Find all CIRCULATION ISSUE log entries where info is just an itemnumber (not JSON)
2. Find all HOLDS CREATE log entries where info is just a hold_id (not JSON)
3. Convert them to JSON format with the appropriate structure:

   For CIRCULATION ISSUE:
   {
     "issue": <issue_id if available>,
     "branchcode": <branchcode if available>,
     "itemnumber": <itemnumber>,
     "confirmations": [],
     "forced": []
   }

   For HOLDS CREATE:
   {
     "hold": <hold_id>,
     "branchcode": <branchcode if available>,
     "biblionumber": <biblionumber if available>,
     "itemnumber": <itemnumber if available>,
     "confirmations": [],
     "forced": []
   }

By default, the script runs in dry-run mode. Use --commit to actually update the database.

=head1 WARNING

This script may take a long time to run on large databases with many action_logs entries.
It's recommended to run it during off-peak hours.

=cut

my $help       = 0;
my $commit     = 0;
my $verbose    = 0;
my $batch_size = 1000;

GetOptions(
    'h|help'       => \$help,
    'c|commit'     => \$commit,
    'v|verbose'    => \$verbose,
    'batch-size=i' => \$batch_size,
) || pod2usage(1);

if ($help) {
    pod2usage(1);
}

my $dbh = C4::Context->dbh;

print "Starting migration of action logs to JSON format...\n";
print $commit
    ? "COMMIT MODE - Changes will be saved\n"
    : "DRY RUN MODE - No changes will be saved (use --commit to save)\n";
print "\n";

# Count CIRCULATION ISSUE entries
my $circ_count_sql = q(
    SELECT COUNT(*)
    FROM action_logs
    WHERE module = 'CIRCULATION'
      AND action = 'ISSUE'
      AND info IS NOT NULL
      AND info NOT LIKE '{%'
      AND info REGEXP '^[0-9]+$'
);

my ($circ_count) = $dbh->selectrow_array($circ_count_sql);

# Count HOLDS CREATE entries
my $holds_count_sql = q(
    SELECT COUNT(*)
    FROM action_logs
    WHERE module = 'HOLDS'
      AND action = 'CREATE'
      AND info IS NOT NULL
      AND info NOT LIKE '{%'
      AND info REGEXP '^[0-9]+$'
);

my ($holds_count) = $dbh->selectrow_array($holds_count_sql);

my $total_count = $circ_count + $holds_count;

print "Found $circ_count CIRCULATION ISSUE log entries to migrate\n";
print "Found $holds_count HOLDS CREATE log entries to migrate\n";
print "Total: $total_count entries\n";
print "\n";

if ( $total_count == 0 ) {
    print "No entries need migration. Exiting.\n";
    exit 0;
}

# Both loops below use keyset pagination by action_id rather than OFFSET/LIMIT.
# Under --commit each UPDATE removes the row from the matching set, so
# OFFSET-based pagination would silently skip records as the set shrinks.
# Paging on "action_id > last_seen" is stable under mutation and works the
# same in dry-run mode.

# Process CIRCULATION ISSUE logs
print "=== Processing CIRCULATION ISSUE logs ===\n\n" if $circ_count > 0;

my $converted      = 0;
my $errors         = 0;
my $circ_last_id   = 0;
my $circ_processed = 0;

while (1) {
    my $select_sql = q(
        SELECT action_id, info, object, timestamp
        FROM action_logs
        WHERE module = 'CIRCULATION'
          AND action = 'ISSUE'
          AND info IS NOT NULL
          AND info NOT LIKE '{%'
          AND info REGEXP '^[0-9]+$'
          AND action_id > ?
        ORDER BY action_id
        LIMIT ?
    );

    my $sth = $dbh->prepare($select_sql);
    $sth->execute( $circ_last_id, $batch_size );

    my $batch_count = 0;

    while ( my $row = $sth->fetchrow_hashref ) {
        my $action_id      = $row->{action_id};
        my $info           = $row->{info};
        my $borrowernumber = $row->{object};
        my $timestamp      = $row->{timestamp};

        $circ_last_id = $action_id;

        # The info should be an itemnumber
        my $itemnumber = $info;

        # Try to find the corresponding issue to get issue_id and branchcode
        my $issue_id;
        my $branchcode;

        # First check old_issues (most likely location for old logs)
        my $old_checkout = Koha::Old::Checkouts->search(
            {
                itemnumber     => $itemnumber,
                borrowernumber => $borrowernumber,
            },
            {
                order_by => { -desc => 'returndate' },
                rows     => 1
            }
        )->next;

        if ($old_checkout) {
            $issue_id   = $old_checkout->issue_id;
            $branchcode = $old_checkout->branchcode;
        } else {

            # Try current issues table (unlikely but possible)
            my $current_issue = Koha::Checkouts->search(
                {
                    itemnumber     => $itemnumber,
                    borrowernumber => $borrowernumber,
                }
            )->next;

            if ($current_issue) {
                $issue_id   = $current_issue->issue_id;
                $branchcode = $current_issue->branchcode;
            }
        }

        # Build the JSON structure
        my $json_data = {
            issue         => $issue_id,
            branchcode    => $branchcode,
            itemnumber    => $itemnumber,
            confirmations => [],
            forced        => []
        };

        # Match the pretty/canonical encoding used by AddIssue so the
        # converted entries are byte-identical to freshly logged ones.
        my $json_info = JSON->new->pretty(1)->canonical(1)->encode($json_data);

        if ($verbose) {
            print "Converting action_id $action_id:\n";
            print "  Old: $info\n";
            print "  New: " .        ( $json_info =~ s/\n/ /gr ) . "\n";
            print "  issue_id: " .   ( $issue_id   // 'NULL' ) . "\n";
            print "  branchcode: " . ( $branchcode // 'NULL' ) . "\n";
            print "\n";
        }

        if ($commit) {
            my $update_sql = q(
                UPDATE action_logs
                SET info = ?
                WHERE action_id = ?
            );
            my $update_sth = $dbh->prepare($update_sql);
            if ( $update_sth->execute( $json_info, $action_id ) ) {
                $converted++;
            } else {
                print STDERR "ERROR: Failed to update action_id $action_id: " . $dbh->errstr . "\n";
                $errors++;
            }
        } else {
            $converted++;
        }

        $batch_count++;
    }

    last unless $batch_count;

    $circ_processed += $batch_count;

    unless ($verbose) {
        print "Processed $circ_processed / $circ_count records...\r";
    }
}

print "\n" unless $verbose;
print "Completed CIRCULATION ISSUE: $converted converted, $errors errors\n\n";

# Process HOLDS CREATE logs
print "=== Processing HOLDS CREATE logs ===\n\n" if $holds_count > 0;

my $holds_converted = 0;
my $holds_errors    = 0;
my $holds_last_id   = 0;
my $holds_processed = 0;

while (1) {
    my $select_sql = q(
        SELECT action_id, info, object, timestamp
        FROM action_logs
        WHERE module = 'HOLDS'
          AND action = 'CREATE'
          AND info IS NOT NULL
          AND info NOT LIKE '{%'
          AND info REGEXP '^[0-9]+$'
          AND action_id > ?
        ORDER BY action_id
        LIMIT ?
    );

    my $sth = $dbh->prepare($select_sql);
    $sth->execute( $holds_last_id, $batch_size );

    my $batch_count = 0;

    while ( my $row = $sth->fetchrow_hashref ) {
        my $action_id = $row->{action_id};
        my $info      = $row->{info};

        $holds_last_id = $action_id;

        # The info should be a hold_id
        my $hold_id = $info;

        # Try to find the corresponding hold to get full details
        my $branchcode;
        my $biblionumber;
        my $itemnumber;

        # First check old_reserves (most likely location for old logs)
        my $old_hold = Koha::Old::Holds->search(
            { reserve_id => $hold_id },
            { rows       => 1 }
        )->next;

        if ($old_hold) {
            $branchcode   = $old_hold->branchcode;
            $biblionumber = $old_hold->biblionumber;
            $itemnumber   = $old_hold->itemnumber;
        } else {

            # Try current reserves table (unlikely but possible)
            my $current_hold = Koha::Holds->search( { reserve_id => $hold_id } )->next;

            if ($current_hold) {
                $branchcode   = $current_hold->branchcode;
                $biblionumber = $current_hold->biblionumber;
                $itemnumber   = $current_hold->itemnumber;
            }
        }

        # Build the JSON structure
        my $json_data = {
            hold          => $hold_id,
            branchcode    => $branchcode,
            biblionumber  => $biblionumber,
            itemnumber    => $itemnumber,
            confirmations => [],
            forced        => []
        };

        # Match the pretty/canonical encoding used by AddReserve so the
        # converted entries are byte-identical to freshly logged ones.
        my $json_info = JSON->new->pretty(1)->canonical(1)->encode($json_data);

        if ($verbose) {
            print "Converting action_id $action_id:\n";
            print "  Old: $info\n";
            print "  New: " . ( $json_info =~ s/\n/ /gr ) . "\n";
            print "  hold_id: $hold_id\n";
            print "  branchcode: " .   ( $branchcode   // 'NULL' ) . "\n";
            print "  biblionumber: " . ( $biblionumber // 'NULL' ) . "\n";
            print "  itemnumber: " .   ( $itemnumber   // 'NULL' ) . "\n";
            print "\n";
        }

        if ($commit) {
            my $update_sql = q(
                UPDATE action_logs
                SET info = ?
                WHERE action_id = ?
            );
            my $update_sth = $dbh->prepare($update_sql);
            if ( $update_sth->execute( $json_info, $action_id ) ) {
                $holds_converted++;
            } else {
                print STDERR "ERROR: Failed to update action_id $action_id: " . $dbh->errstr . "\n";
                $holds_errors++;
            }
        } else {
            $holds_converted++;
        }

        $batch_count++;
    }

    last unless $batch_count;

    $holds_processed += $batch_count;

    unless ($verbose) {
        print "Processed $holds_processed / $holds_count records...\r";
    }
}

print "\n" unless $verbose;
print "Completed HOLDS CREATE: $holds_converted converted, $holds_errors errors\n\n";

# Final summary
print "=== Migration Summary ===\n";
print "CIRCULATION ISSUE:\n";
print "  Converted: $converted\n";
print "  Errors: $errors\n";
print "HOLDS CREATE:\n";
print "  Converted: $holds_converted\n";
print "  Errors: $holds_errors\n";
print "TOTAL:\n";
print "  Converted: " . ( $converted + $holds_converted ) . "\n";
print "  Errors: " .    ( $errors + $holds_errors ) . "\n";
print "\n";

if ( !$commit && ( $converted > 0 || $holds_converted > 0 ) ) {
    print "This was a DRY RUN. Use --commit to actually update the database.\n";
}

=head1 AUTHOR

Koha Development Team

=cut
