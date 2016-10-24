#!/usr/bin/perl
# OUTIcn_sortFix.pl by Pasi Korkalo/OUTI-Libraries

# Fix the cn_sort fields of the item-records to drop out the first part of the signum.
# This will make sorting the "holds to pull" and search results work right (with updated
# pendingreserves.pl).

# A complete re-indexing is needed after running this.

# OUTI.pm in C4/ClassSortRules will create correct cn_sort fields for items added later
# in similar fashion. You will need to configure your classification scheme to use it
# (in Koha's Administration -> Classification sources).

use utf8;
use strict;
use C4::Context;

my $dbh=C4::Context->dbh();

# Simple enough, we make cn_sort by truncating the first part of the signum leaving only the classification and main heading parts
$dbh->do("UPDATE items SET cn_sort=SUBSTR(items.itemcallnumber, LOCATE(' ', items.itemcallnumber) + 1);");
