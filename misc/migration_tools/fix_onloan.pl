#!/usr/bin/perl

use strict;
use  C4::Context;
use C4::Items;
use C4::Biblio;

#
# the items.onloan field did not exist in koha 2.2
# in koha 3.0, it's used to define item availability
# this script takes the items.onloan field
# and put it in the MARC::Record of the item
#

my $dbh=C4::Context->dbh;

# if (C4::Context->preference("marcflavour") ne "UNIMARC") {
#     print "this script is for UNIMARC only\n";
#     exit;
# }
my $rqbiblios=$dbh->prepare("SELECT biblionumber,itemnumber,onloan FROM items WHERE items.onloan IS NOT NULL");
$rqbiblios->execute;
$|=1;
while (my ($biblionumber,$itemnumber,$onloan)= $rqbiblios->fetchrow){
    ModItem({onloan => "$onloan"}, $biblionumber, $itemnumber);
    print "Onloan : $onloan for $biblionumber / $itemnumber\n";
}