#!/usr/bin/perl -w
#-----------------------------------
# Script Name: longoverdue.pl
# Script Version: 1.0.0
# Date:  2004/04/01
# Author:  Stephen Hedges  shedges@skemotah.com
# Description: set itemlost status to '2'
#    ("long overdue") on items more than 90
#    days overdue.
# Usage: longoverdue.pl.
# Revision History:
#    1.0.0  2004/04/01:  original version
#-----------------------------------

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}
use C4::Context;

my $dbh = C4::Context->dbh;

my $itemnos_sth=$dbh->prepare("SELECT items.itemnumber FROM issues,items WHERE items.itemnumber=issues.itemnumber AND DATE_SUB(CURDATE(),INTERVAL 90 DAY) > date_due AND returndate IS NULL AND (itemlost=0 OR itemlost IS NULL)");
my $put_sth=$dbh->prepare("UPDATE items SET itemlost=2 WHERE itemnumber=?");

#    get itemnumbers of items more than 90 days overdue
$itemnos_sth->execute();

while (my $row=$itemnos_sth->fetchrow_arrayref) {
    my $item=$row->[0];

    $put_sth->execute($item);
    $put_sth->finish;
#    print "$item\n";
}

$itemnos_sth->finish;
$dbh->disconnect;
