#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;
$dbh->do("ALTER TABLE borrower_attribute_types ADD COLUMN `display_checkout` TINYINT(1) NOT NULL DEFAULT '0';");
print "Upgrade done (Added a display_checkout field in borrower_attribute_types table)\n";
