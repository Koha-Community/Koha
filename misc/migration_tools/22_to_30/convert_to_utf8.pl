#!/usr/bin/perl

# small script to convert mysql tables to utf-8

use strict;
use warnings;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../../kohalib.pl" };
}

use C4::Context;
my $dbh = C4::Context->dbh();
my $sth = $dbh->prepare("Show tables");
$sth->execute();
while (my @table = $sth->fetchrow_array()) {
    print "Altering table $table[0]\n";
    my $alter_query = "ALTER TABLE $table[0] convert to CHARACTER SET UTF8 collate utf8_general_ci";
    my $sth2        = $dbh->prepare($alter_query);
    $sth2->execute();
    $sth2->finish();
}
