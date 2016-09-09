#!/usr/bin/perl

# Copyright 2016 Jacek Ablewicz
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

use C4::Context;
use C4::Overdues qw/CalcFine BorType/;
use C4::Log qw/logaction/;

use Koha::DateUtils;
use Getopt::Long;

my ($help, $verbose, $confirm, $log, $stdout_log);

GetOptions(
    'h|help'    => \$help,
    'v|verbose' => \$verbose,
    'l|log'     => \$log,
    'c|confirm' => \$confirm,
    'p|print'   => \$stdout_log
);

my $usage = << 'ENDUSAGE';

Script for fixing unclosed (FU), non accruing fine records, which
may still need FU -> F correction post-Bug 15675. For details,
see Bug 14390 & Bug 17135.

This script has the following parameters :
    -h --help: this message
    -l --log: log changes to the system logs
    -c --confirm: commit changes (test only mode if not present)
    -p --print: output affected fine records details to the STDOUT
    -v --verbose

ENDUSAGE

{
    if ($help) {
        print $usage;
        exit 0;
    }

    Bug_17135_fix({
        'verbose' => $verbose, 'log' => $log,
        'confirm' => $confirm, 'stdout_log' => $stdout_log
    });

    exit 0;
}

sub Bug_17135_fix {
    my $params = shift;

    my $verbose = $params->{'verbose'};
    my $log = $params->{'log'};
    my $confirm = $params->{'confirm'};
    my $stdout_log = $params->{'stdout_log'};

    my $control = C4::Context->preference('CircControl');
    my $mode = C4::Context->preference('finesMode');
    my $today = DateTime->now( time_zone => C4::Context->tz() );
    my $dbh = C4::Context->dbh;

    ## fetch the unclosed FU fines linked to the issues by issue_id
    my $acclines = getFinesForChecking();

    Warn("Got ".scalar(@$acclines)." FU accountlines to check") if $verbose;

    my $different_dates_cnt = 0;
    my $not_due_not_accruning_cnt = 0;
    my $due_not_accruning_cnt = 0;
    my $forfixing = [];
    my $old_date_pattern;
    for my $fine (@$acclines) {
        my $datedue = dt_from_string( $fine->{date_due} );
        my $due = output_pref($datedue);
        $fine->{current_due_date} = $due;
        my $due_qr = qr/$due/;
        ## if the dates in fine description and in the issue record match,
        ## this is a legit post-Bug Bug 15675 accruing overdue fine
        ## which does not require any correction
        next if ($fine->{description} =~ /$due_qr/);

        if( !$old_date_pattern ) {
            ## for extracting old due date from fine description
            ## not used for fixing anything, logging/debug purposes only
            $old_date_pattern = $due;
            $old_date_pattern =~ s/[A-Za-z]/\[A-Za-z\]/g;
            $old_date_pattern =~ s/[0-9]/\\d/g;
            $old_date_pattern = qr/$old_date_pattern/;
        }
        if ($fine->{description} =~ / ($old_date_pattern)$/) {
            my $old_date_due = $1;
            $fine->{old_date_due} = $old_date_due;
            ### Warn("'$due' vs '$old_date_due'") if $verbose;
        }
        $fine->{old_date_due} //= 'unknown';

        $different_dates_cnt++;
        ## after the last renewal, item is no longer due = it's not accruing,
        ## fine still needs to be closed
        unless ($fine->{item_is_due}) {
            $fine->{log_entry} = 'item not due, fine not accruing';
            $not_due_not_accruning_cnt++;
            push(@$forfixing, $fine);
            next;
        }

        my $is_not_accruing = 0;
        ## item got due again after the last renewal, CalcFine() needs
        ## to be called to establish if the fine is accruning or not
        {
            my $statement;
            if ( C4::Context->preference('item-level_itypes') ) {
                $statement = "SELECT issues.*, items.itype as itemtype, items.homebranch, items.barcode, items.itemlost, items.replacementprice
                    FROM issues
                    LEFT JOIN items USING (itemnumber)
                    WHERE date_due < NOW() AND issue_id = ?
                ";
            } else {
                $statement = "SELECT issues.*, biblioitems.itemtype, items.itype, items.homebranch, items.barcode, items.itemlost, replacementprice
                    FROM issues
                    LEFT JOIN items USING (itemnumber)
                    LEFT JOIN biblioitems USING (biblioitemnumber)
                    WHERE date_due < NOW() AND issue_id = ?
               ";
            }

            my $sth = $dbh->prepare($statement);
            $sth->execute($fine->{issue_id});
            my $overdues = $sth->fetchall_arrayref({});
            last if (@$overdues != 1);
            my $overdue = $overdues->[0];

            ### last if $overdue->{itemlost}; ## arguable
            my $borrower = BorType( $overdue->{borrowernumber} );
            my $branchcode =
             ( $control eq 'ItemHomeLibrary' ) ? $overdue->{homebranch}
             : ( $control eq 'PatronLibrary' )   ? $borrower->{branchcode}
             :                                     $overdue->{branchcode};

            my ($amount) = CalcFine( $overdue, $borrower->{categorycode}, $branchcode, $datedue, $today );
            ### Warn("CalcFine() returned '$amount'");
            last if ($amount > 0); ## accruing fine, skip closing

            ## If we are here: item is due again, but fine is not accruing
            ## yet (overdue may be in the grace period, 1st charging period
            ## is not over yet, all days beetwen due date and today are
            ## holidays etc.). Old fine record needs to be closed
            $is_not_accruing = 1;
        }

        if ($is_not_accruing) {
            $fine->{log_entry} = 'item due, fine not accruing yet';
            $due_not_accruning_cnt++;
            push(@$forfixing, $fine);
        };
    }

    if( $verbose ) {
        Warn( "Fine records with mismatched old vs current due dates: $different_dates_cnt" );
        Warn( "Non-accruing accountlines FU records (item not due): ".$not_due_not_accruning_cnt );
        Warn( "Non-accruing accountlines FU records (item due): ".$due_not_accruning_cnt );
    }

    my $updated_cnt = 0;
    my $update_sql = "UPDATE accountlines SET accounttype = 'F' WHERE accounttype = 'FU' AND accountlines_id = ? LIMIT 1";
    for my $fine (@$forfixing) {
        my $logentry = "Closing old FU fine (Bug 17135); accountlines_id=".$fine->{accountlines_id};
        $logentry .= " issue_id=".$fine->{issue_id}." amount=".$fine->{amount};
        $logentry .= "; due dates (old, current): '".$fine->{old_date_due}."', '".$fine->{current_due_date}."'";
        $logentry .= "; reason: ".$fine->{log_entry};
        print($logentry."\n") if ($stdout_log);

        next unless ($confirm && $mode eq 'production');
        my $rows_affected = $dbh->do($update_sql, undef, $fine->{accountlines_id});
        $updated_cnt += $rows_affected;
        logaction("FINES", "FU", $fine->{borrowernumber}, $logentry) if ($log);
    }

    # Regardless of verbose, we report at least a number here
    if( @$forfixing > 0 ) {
        if( $confirm && $mode eq 'production') {
            Warn( "Database update done, $updated_cnt".
                ( @$forfixing == $updated_cnt? "": ( "/". @$forfixing )).
                " fine records closed successfully." );
        } else {
            Warn( "Dry run (test only mode), skipping ". @$forfixing.
                " fine records." );
        }
    } else {
        Warn( "No fine records needed to be fixed" );
    }
}

sub getFinesForChecking {
    my $dbh = C4::Context->dbh;
    my $query = "SELECT acc.*, iss.date_due,
        IF(iss.date_due < NOW(), 1, 0) AS item_is_due
        FROM accountlines acc
        LEFT JOIN issues iss USING (issue_id)
        WHERE accounttype = 'FU'
        AND iss.issue_id IS NOT NULL
        AND iss.borrowernumber = acc.borrowernumber
        AND iss.itemnumber = acc.itemnumber
        ORDER BY acc.borrowernumber, acc.issue_id
    ";

    my $sth = $dbh->prepare($query);
    $sth->execute();
    return $sth->fetchall_arrayref({});
}

sub Warn {
    print join("\n", @_, '');
}
