package C4::BatchOverlay::ReportManager;

# Copyright (C) 2016 KohaSuomi
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Scalar::Util qw(blessed);
use Try::Tiny;
use Data::Dumper;
use DateTime;

use Koha::Logger;
use Koha::Validation;

use C4::Biblio::Diff;
use C4::BatchOverlay::Report;
use C4::BatchOverlay::ReportContainer;
use C4::Context;

use Koha::Exception::BadParameter;
use Koha::Exception::DB;

our $logger = Koha::Logger->get();

sub new {
    my ($class, $self) = @_;
    $self = {} unless(ref($self) eq 'HASH');
    bless($self, $class);

    return $self;
}

=head removeReports

    C4::BatchOverlay::ReportManager->removeReports({from => DateTime, to => DateTime, borrowernumber => 443});
    C4::BatchOverlay::ReportManager->removeReports({from => DateTime, to => DateTime});

@PARAM1 HASHref of params,
          'from', DateTime, inclusive time where to start removing existing report containers.
          'to', DateTime, inclusive time into which to remove existing report containers
          'borrowernumber', Long, koha.borrowers.borrowernumber of the overlay operation executer.
@THROWS Koha::Exception::BadParameter if params are not valid, or if no params are given. You must give
                                      an arbitrary HASH with a key to confirm deletion of all reports in DB.
@THROWS Koha::Exception::DB if something bad happened when doing SQL queries

=cut

sub removeReports {
    my ($class, $params) = @_;
    my $from = $params->{from};
    my $to = $params->{to};
    my $borrowernumber = $params->{borrowernumber};

    unless (ref($params) eq 'HASH' && scalar(keys(%$params)) > 0) {
        my @cc1 = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc1[3]." is trying to delete all batch_overlay_reports without any parameters. For safety reasons preventing removal of all reports. Pass a parameter HASH with some keys to pass this safety check, for ex '{do => 1}'");
    }

    Koha::Validation->tries('from', $from, 'DateTime') if $from;
    Koha::Validation->tries('to', $to, 'DateTime') if $to;
    Koha::Validation->tries('borrowernumber', $borrowernumber, 'digit') if $borrowernumber;

    my @params;
    my $sql = "DELETE FROM batch_overlay_reports WHERE 1 ";
    if ($from) {
        $sql .= " AND timestamp >= ? ";
        push(@params, $from);
    }
    if ($to) {
        $sql .= " AND timestamp <= ? ";
        push(@params, $to);
    }
    if ($borrowernumber) {
        $sql .= " AND borrowernumber = ? ";
        push(@params, $borrowernumber);
    }

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare($sql);
    $sth->execute(@params);
    if ($sth->err) {
        my @cc = caller(1);
        Koha::Exception::DB->throw(error => $cc[3]." is trying to delete all batch overlay report containers using parameters from:'$from', to:'$to', borrowernumber:'$borrowernumber', but got this error:\n".$sth->errstr."\n");
    }
}

=head getReports

    my $reports = C4::BatchOverlay::ReportManager->getReports($batchOverlayReportsId, $showAllExceptions);

@param {Integer} $batchOverlayReportsId
@param {boolean} $showAllExceptions, show all exceptions or hide the default exceptions.
@RETURNS ARRAYref of C4::BatchOverlay::Report-objects for the given batch overlay report container

=cut

sub getReports {
    my ($class, $batchOverlayReportsId, $showAllExceptions) = @_;

    my $excludedExceptions = ($showAllExceptions) ? [] : C4::BatchOverlay::RuleManager->new()->getExcludedExceptions();
    my $diffs = $class->listDiffs($batchOverlayReportsId, $excludedExceptions);
    for(my $i=0 ; $i<scalar(@$diffs) ; $i++) {
        $diffs->[$i] = C4::BatchOverlay::Report->newFromDB($diffs->[$i]);
    }
    return $diffs;
}

=head getReportContainers

    my $reports = C4::BatchOverlay::ReportManager->getReportContainers();

@RETURNS ARRAYref of C4::BatchOverlay::ReportContainer-objects for the given batch overlay report container.
                     Objects lazy load all related objects when needed.

=cut

sub getReportContainers {
    my ($class) = @_;

    my $reportContainers = $class->listReports();
    for(my $i=0 ; $i<scalar(@$reportContainers) ; $i++) {
        $reportContainers->[$i] = C4::BatchOverlay::ReportContainer->newFromDB($reportContainers->[$i]);
    }
    return $reportContainers;
}

=head listReports

    my $reportContainers = $reportManager->listReports();

@RETURNS ARRAYref of HASHrefs of koha.batch_overlay_reports -table rows with column overlayCount to signal how many overlay operations this report container contains.
@THROWS Koha::Exception::DB
=cut

sub listReports {
    my ($self) = @_;

    my $dbh = C4::Context->dbh();
    my $sql = "SELECT bor.*, SUM(IF(bod.operation NOT REGEXP 'error',1,0)) as reportsCount, SUM(IF(bod.operation REGEXP 'error',1,0)) as errorsCount FROM batch_overlay_reports bor LEFT JOIN batch_overlay_diff bod ON bor.id = bod.batch_overlay_reports_id GROUP BY bor.id";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    if ($sth->err) {
        my @cc = caller(1);
        Koha::Exception::DB->throw(error => $cc[3]." is trying to fetch all batch overlay report containers, but got this error:\n".$sth->errstr."\n");
    }
    return $sth->fetchall_arrayref({});
}

=head listDiffs

    my $diffs = $reportManager->listDiffs($batchOverlayReportsId, $showAllExceptions);

@param {ArrayRef of Strings} $excludedExceptions, Exception class names, or partial
                names of the error reports that should not be returned.
@RETURNS ARRAYRef of C4::BatchOverlay::Report-objects
@THROWS Koha::Exception::DB;

=cut

sub listDiffs {
    my ($self, $batchOverlayReportsId, $excludedExceptions) = @_;

    my $dbh = C4::Context->dbh();
    my $sql = "SELECT * FROM batch_overlay_diff bod WHERE batch_overlay_reports_id = ? ";
    my @params = ($batchOverlayReportsId);
    foreach my $ee (@$excludedExceptions) {
        $sql .= " AND diff NOT LIKE CONCAT('%',?,'%') ";
        push(@params, $ee);
    }

    Koha::Logger->sql($logger, 'trace', $sql, \@params) if $logger->is_trace();
    my $sth = $dbh->prepare($sql);
    $sth->execute(@params);
    if ($sth->err) {
        my @cc = caller(1);
        Koha::Exception::DB->throw(error => $cc[3]." is trying to fetch all batch overlay diffs for batch overlay report container '$batchOverlayReportsId', excluding '".($excludedExceptions ? "@$excludedExceptions" : "")."' exceptions but got this error:\n".$sth->errstr."\n");
    }
    return $sth->fetchall_arrayref({});
}

=head listHeaders

    my $diffs = $reportManager->listHeaders($batchOverlayDiffId);

@RETURNS ARRAYRef of C4::BatchOverlay::Report::Header-objects
@THROWS Koha::Exception::DB;

=cut

sub listHeaders {
    my ($self, $batchOverlayDiffId) = @_;

    my $dbh = C4::Context->dbh();
    my $sql = "SELECT * FROM batch_overlay_diff_header boh WHERE batch_overlay_diff_id = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($batchOverlayDiffId);
    if ($sth->err) {
        my @cc = caller(1);
        Koha::Exception::DB->throw(error => $cc[3]." is trying to fetch all batch overlay headers for diff '$batchOverlayDiffId', but got this error:\n".$sth->errstr."\n");
    }
    return $sth->fetchall_arrayref({});
}

sub _insertDiffToDB {
    my ($class, $borcid, $biblionumber, $operation, $overlayRuleName, $diff) = @_;

    my $dbh = C4::Context->dbh();
    my $sql = "INSERT INTO batch_overlay_diff (batch_overlay_reports_id, biblionumber, operation, ruleName, diff) VALUES (?,?,?,?,?)";
    my $sth = $dbh->prepare($sql);
    $sth->execute($borcid, $biblionumber, $operation, $overlayRuleName, $diff);
    if ($sth->err) {
        my @cc = caller(1);
        Koha::Exception::DB->throw(error => $cc[3]."($biblionumber, $operation, $overlayRuleName, ".substr($diff,0,10)."):> Trying to persist myself, but got this error:\n".$sth->errstr."\n");
    }

    my $newId = $dbh->last_insert_id(undef, undef, 'batch_overlay_diff', 'id');
    unless($newId) {
        my @params = ($borcid, $operation, length($diff));
        $sql = "SELECT id FROM batch_overlay_diff WHERE batch_overlay_reports_id = ? AND operation = ? AND CHAR_LENGTH(diff) = ?";
        if ($biblionumber) { #if we have biblionumber, we must have a rulename
            push(@params, $biblionumber);
            $sql .= " AND biblionumber = ? ";
            push(@params, $overlayRuleName);
            $sql .= " AND ruleName = ? ";
        }

        $sth = $dbh->prepare($sql);
        $sth->execute( @params );
        if ($sth->err) {
            my @cc = caller(1);
            Koha::Exception::DB->throw(error => $cc[3]."($biblionumber, $operation, $overlayRuleName, ".substr($diff,0,10)."):> Trying to get my id while persisting myself, but got this error:\n".$sth->errstr."\n");
        }

        ($newId) = $sth->fetchrow;
    }

    return $newId;
}

sub _insertHeaderToDB {
    my ($class, $bodid, $biblionumber, $breedingid, $title, $stdid) = @_;
    my $dbh = C4::Context->dbh();
    my $sql = "INSERT INTO batch_overlay_diff_header (batch_overlay_diff_id, biblionumber, breedingid, title, stdid) VALUES (?,?,?,?,?)";
    my $sth = $dbh->prepare($sql);
    $sth->execute($bodid, $biblionumber, $breedingid, $title, $stdid);
    if ($sth->err) {
        my @cc = caller(1);
        Koha::Exception::DB->throw(error => $cc[3]."($bodid, ".($biblionumber || '').", ".($breedingid || '').", $title, $stdid):> Trying to persist myself, but got this error:\n".$sth->errstr."\n");
    }

    my $newId = $dbh->last_insert_id(undef, undef, 'batch_overlay_diff_header', 'id');
    unless ($newId) {
        $sql = "SELECT id FROM batch_overlay_diff_header WHERE batch_overlay_diff_id = ? AND biblionumber = ? AND breedingid = ? AND title = ? AND stdid = ?";
        $sth = $dbh->prepare($sql);
        $sth->execute($bodid, $biblionumber, $breedingid, $title, $stdid);
        if ($sth->err) {
            my @cc = caller(1);
            Koha::Exception::DB->throw(error => $cc[3]."($bodid, ".($biblionumber || '').", ".($breedingid || '').", $title, $stdid):> Trying to persist myself, but got this error:\n".$sth->errstr."\n");
        }

        ($newId) = $sth->fetchrow;
    }

    return $newId;
}

sub _insertReportContainerToDB {
    my ($class, $timestamp, $borrowernumber) = @_;
    unless(blessed($timestamp) && $timestamp->isa('DateTime')) {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc[3]." is persisting a report container, but the param \$timestamp '$timestamp' is not a DateTime-object");
    }
    if ($borrowernumber && not($borrowernumber =~ /^\d+$/)) {
        my @cc = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc[3]." is persisting a report container, but the param \$borrowernumber '$borrowernumber' is not a digit");
    }

    #INSERT
    my $dbh = C4::Context->dbh();
    my $sql = "INSERT INTO batch_overlay_reports (timestamp, borrowernumber) VALUES (?,?)";
    my $sth = $dbh->prepare($sql);
    $sth->execute($timestamp->iso8601(), $borrowernumber);
    if ($sth->err) {
        my @cc = caller(0);
        Koha::Exception::DB->throw(error => $cc[3]."(".$timestamp->iso8601().", $borrowernumber):> Trying to create a parent container for batch overlay reports, but got this error:\n".$sth->err."\n");
    }

    #GET what we entered with the autoincrementing id safely
    $sql = "SELECT * FROM batch_overlay_reports WHERE timestamp = ? AND borrowernumber = ?";
    $sth = $dbh->prepare($sql);
    $sth->execute($timestamp->iso8601(), $borrowernumber);
    if ($sth->err) {
        my @cc = caller(0);
        Koha::Exception::DB->throw(error => $cc[3]."(".$timestamp->iso8601().", $borrowernumber):> Trying to get the id of a batch overlay report container, but got this error:\n".$sth->err."\n");
    }
    my $borc = $sth->fetchrow_hashref();
    return $borc;
}

1;
