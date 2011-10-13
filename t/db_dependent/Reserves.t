#!/usr/bin/perl

use strict;
use warnings;
use C4::Branch;

use Test::More tests => 4;

BEGIN {
	use FindBin;
	use lib $FindBin::Bin;
	use_ok('C4::Reserves');
}

my $dbh = C4::Context->dbh;
my $query = qq/SELECT borrowernumber
    FROM   borrowers
    LIMIT  1/;
my $sth = $dbh->prepare($query);
$sth->execute;
my $borrower = $sth->fetchrow_hashref;

$query = qq/SELECT biblionumber, title, itemnumber, barcode
    FROM biblio
    LEFT JOIN items USING (biblionumber)
    WHERE barcode <> ""
    AND barcode IS NOT NULL
    LIMIT  1/;
$sth = $dbh->prepare($query);
$sth->execute;
my $biblio = $sth->fetchrow_hashref;


my $borrowernumber = $borrower->{'borrowernumber'};
my $biblionumber   = $biblio->{'biblionumber'};
my $itemnumber     = $biblio->{'itemnumber'};
my $barcode        = $biblio->{'barcode'};

my $constraint     = 'a';
my $bibitems       = '';
my $priority       = '1';
my $notes          = '';
my $title          = $biblio->{'title'};
my $checkitem      = undef;
my $found          = undef;

my @branches = GetBranchesLoop();
my $branch = $branches[0][0]{value};

AddReserve($branch,    $borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority,       $notes,
        $title,      $checkitem, $found);
        
my ($status, $reserve, $all_reserves) = CheckReserves($itemnumber, $barcode);
ok($status eq "Reserved", "CheckReserves Test 1");

($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok($status eq "Reserved", "CheckReserves Test 2");

($status, $reserve, $all_reserves) = CheckReserves(undef, $barcode);
ok($status eq "Reserved", "CheckReserves Test 3");

