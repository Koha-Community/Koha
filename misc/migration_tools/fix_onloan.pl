#!/usr/bin/perl

use Modern::Perl;
use Koha::Script;
use Koha::Items;
#
# the items.onloan field did not exist in koha 2.2
# in koha 3.0, it's used to define item availability
# this script takes the items.onloan field
# and put it in the MARC::Record of the item
#

my $items = Koha::Items->({ onloan => { '!=' => undef } });

$|=1;
while ( my $item = $items->next ) {
    $item->store;
    print sprintf "Onloan : %s for %s / %s\n", $item->onloan, $item->biblionumber, $item->itemnumber;
}
