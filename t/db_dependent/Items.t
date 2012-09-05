#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use MARC::Record;
use C4::Biblio;

use Test::More tests => 7;

BEGIN {
    use_ok('C4::Items');
}

# Helper biblio.
diag("Creating biblio instance for testing.");
my ($bibnum, $bibitemnum) = get_biblio();

# Add an item.
my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);
cmp_ok($item_bibnum, '==', $bibnum, "New item is linked to correct biblionumber.");
cmp_ok($item_bibitemnum, '==', $bibitemnum, "New item is linked to correct biblioitemnumber.");

# Get item.
my $getitem = GetItem($itemnumber);
cmp_ok($getitem->{'itemnumber'}, '==', $itemnumber, "Retrieved item has correct itemnumber.");
cmp_ok($getitem->{'biblioitemnumber'}, '==', $item_bibitemnum, "Retrieved item has correct biblioitemnumber.");

# Modify item; setting barcode.
ModItem({ barcode => '987654321' }, $bibnum, $itemnumber);
my $moditem = GetItem($itemnumber);
cmp_ok($moditem->{'barcode'}, '==', '987654321', 'Modified item barcode successfully to: '.$moditem->{'barcode'} . '.');

# Delete item.
my $dbh = C4::Context->dbh;
DelItem($dbh, $bibnum, $itemnumber);
my $getdeleted = GetItem($itemnumber);
is($getdeleted->{'itemnumber'}, undef, "Item deleted as expected.");

# Delete helper Biblio.
diag("Deleting biblio testing instance.");
DelBiblio($bibnum);

# Helper method to set up a Biblio.
sub get_biblio {
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    );
    return ($bibnum, $bibitemnum) = AddBiblio($bib, '');
}
