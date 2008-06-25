#!/usr/bin/perl

# Part of the Koha Library Software www.koha.org
# Licensed under the GPL.

use strict;
use warnings;

# CPAN modules
use DBI;
use Getopt::Long;

# Koha modules
use C4::Context;
use C4::Items;
use C4::Debug;
use Data::Dumper;

use vars qw($debug $dbh $VERSION);
$dbh = C4::Context->dbh;
$VERSION = "1.00";

sub get_counts() {
	my $query = q(
	SELECT
	(SELECT count(*) FROM statistics WHERE branch="NO_LIBRARY"       ) AS NO_LIBRARY,
	(SELECT count(*) FROM statistics WHERE branch             IS NULL) AS NULL_BRANCH,
	(SELECT count(*) FROM statistics WHERE itemtype           IS NULL AND itemnumber IS NOT NULL) AS NULL_ITEMTYPE,
	(SELECT count(*) FROM statistics WHERE usercode           IS NULL) AS NULL_USERCODE,
	(SELECT count(*) FROM statistics WHERE borrowernumber     IS NULL) AS NULL_BORROWERNUMBER,
	(SELECT count(*) FROM statistics WHERE associatedborrower IS NULL) AS NULL_ASSOCIATEDBORROWER,
	(SELECT count(*) FROM statistics                                 ) AS Total
	);
	my $sth = $dbh->prepare($query);
	$sth->execute;
	return $sth->fetchrow_hashref;
}

sub itemnumber_array() {
	my $query = q(
		SELECT DISTINCT itemnumber
		FROM statistics
		WHERE itemtype IS NULL
		AND itemnumber IS NOT NULL
	);
	my $sth = $dbh->prepare($query);
	$sth->execute;
	my @itemnumbers = map {shift @$_} @{$sth->fetchall_arrayref};
	return @itemnumbers;
}
sub null_borrower_lines() {
	my $query = "SELECT * FROM statistics WHERE borrowernumber IS NULL";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	print "Number of lines with NULL_BORROWERNUMBER: ", scalar($sth->rows), "\n";
	return $sth->fetchall_arrayref({});
}

sub show_counts() {
	print "\nThe following counts represent the number of (potential) errors in your statistics table:\n";
	my $counts = get_counts;
	foreach (sort keys %$counts) {
		$_ eq 'Total' and next;	
		$counts->{Error_Total} += $counts->{$_};
		print sprintf("%30s : %3d \n",$_ ,$counts->{$_});
	}
	print sprintf("%30s : %3d (potential) errors in %d lines\n",'Error_Total',$counts->{Error_Total}, $counts->{'Total'});
}

##### MAIN #####
print "This operation may take a while.\n";
(scalar @ARGV) or show_counts;
print "\nAttempting to populate missing data.\n";

my (@itemnumbers) = (scalar @ARGV) ? @ARGV : &itemnumber_array;
$debug and print "itemnumbers: ", Dumper(\@itemnumbers);
print "Number of distinct itemnumbers paired with NULL_ITEMTYPE: ", scalar(@itemnumbers), "\n";

my $query = "UPDATE statistics SET itemtype = ? WHERE itemnumber = ?";
my $update = $dbh->prepare($query);
# $debug and print "Update Query: $query\n";
foreach (@itemnumbers) {
	my $item = GetItem($_);
	unless ($item) {
		print STDERR "\tNo item found for itemnumber $_\n"; 
		next;
	}
	$update->execute($item->{itype},$_) or warn "Error in UPDATE execution";
	printf "\titemnumber %5d : %7s  (%s rows)\n", $_, $item->{itype}, $update->rows;
}

my $old_issues = $dbh->prepare("SELECT * FROM old_issues WHERE timestamp = ? AND itemnumber = ?");
my     $issues = $dbh->prepare("SELECT * FROM     issues WHERE timestamp = ? AND itemnumber = ?");
$update = $dbh->prepare("UPDATE statistics SET borrowernumber = ? WHERE datetime = ? AND itemnumber = ?");
my $nullborrs = null_borrower_lines;
$debug and print Dumper($nullborrs);
foreach (@$nullborrs) {
	$old_issues->execute($_->{datetime},$_->{itemnumber});
	my $issue;
	if ($old_issues->rows != 1) {
		print STDERR "Warning!  Unexpected number of matches from old_issues: ",$old_issues->rows;
		$issues->execute($_->{datetime},$_->{itemnumber});
		if ($issues->rows != 1) {
			print STDERR ", from issues: ",$issues->rows,"\tskipping this record\n";
			next;
		}
		print STDERR "\n";
		$issue = $issues->fetchrow_hashref;
	} else {
		$issue = $old_issues->fetchrow_hashref;
	}
	printf "\titemnumber: %5d at %20s -- borrowernumber: %5d\n", $_->{itemnumber}, $_->{datetime}, $issue->{borrowernumber};
	$update->execute($issue->{borrowernumber},$_->{datetime},$_->{itemnumber});
}

print "\nOperations complete.\n";
(scalar @ARGV) or show_counts;

