#!/usr/bin/perl
# LUMMEcn_sortFix.pl by Pasi Korkalo / Koha-Suomi Oy

# Fix the cn_sort fields of the item-records for Lumme Libraries. This fix is mainly
# cosmetic, because sorting should right in Lumme as is. It just looks a bit
# ugly after changes in "holds to pull" -report.

# A complete re-indexing is needed after running this.

# LUMME.pm in C4/ClassSortRules will create correct cn_sort fields for items added later
# in similar fashion. You will need to configure your classification scheme to use it
# (in Koha's Administration -> Classification sources).

use utf8;
use strict;
use C4::Context;

my $dbh=C4::Context->dbh();

# Just set cn_sort same as itemcallnumber
$dbh->do("UPDATE items SET cn_sort=itemcallnumber;");
