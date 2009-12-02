#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;
$dbh->do("ALTER TABLE authorised_values ADD COLUMN `lib_opac` VARCHAR(80) default NULL AFTER `lib`");
print "Upgrade done (Added a lib_opac field in authorised_values table)\n";
