#!/usr/bin/perl

use strict;
use warnings;
use C4::Branch;

use Test::More tests => 4;
use MARC::Record;
use C4::Biblio;
use C4::Items;

BEGIN {
	use FindBin;
	use lib $FindBin::Bin;
	use_ok('C4::Reserves');
}

# Setup Test------------------------
# Helper biblio.
diag("\nCreating biblio instance for testing.");
my ($bibnum, $title, $bibitemnum) = create_helper_biblio();

# Helper item for that biblio.
diag("Creating item instance for testing.");
my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);

# Modify item; setting barcode.
my $testbarcode = '97531';
ModItem({ barcode => $testbarcode }, $bibnum, $itemnumber);

# Get a borrower
my $dbh = C4::Context->dbh;
my $query = qq/SELECT borrowernumber
    FROM   borrowers
    LIMIT  1/;
my $sth = $dbh->prepare($query);
$sth->execute;
my $borrower = $sth->fetchrow_hashref;

my $borrowernumber = $borrower->{'borrowernumber'};
my $biblionumber   = $bibnum;
my $barcode        = $testbarcode;

my $constraint     = 'a';
my $bibitems       = '';
my $priority       = '1';
my $resdate        = undef;
my $expdate        = undef;
my $notes          = '';
my $checkitem      = undef;
my $found          = undef;

my @branches = GetBranchesLoop();
my $branch = $branches[0][0]{value};

AddReserve($branch,    $borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority, $resdate, $expdate, $notes,
        $title,      $checkitem, $found);
        
my ($status, $reserve, $all_reserves) = CheckReserves($itemnumber, $barcode);
ok($status eq "Reserved", "CheckReserves Test 1");

($status, $reserve, $all_reserves) = CheckReserves($itemnumber);
ok($status eq "Reserved", "CheckReserves Test 2");

($status, $reserve, $all_reserves) = CheckReserves(undef, $barcode);
ok($status eq "Reserved", "CheckReserves Test 3");


# Teardown Test---------------------
# Delete item.
diag("Deleting item testing instance.");
DelItem($dbh, $bibnum, $itemnumber);

# Delete helper Biblio.
diag("Deleting biblio testing instance.");
DelBiblio($bibnum);

# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $bib = MARC::Record->new();
    my $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
    );
    return ($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');
}
