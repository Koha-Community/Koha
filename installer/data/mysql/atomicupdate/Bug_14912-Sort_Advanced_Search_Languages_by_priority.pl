#! /usr/bin/perl

use strict;
use warnings;
use C4::Context;
use Koha::AtomicUpdater;

my $dbh = C4::Context->dbh;
my $atomicUpdater = Koha::AtomicUpdater->new();

unless($atomicUpdater->find('Bug14912')) {
    $dbh->do("INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('AdvancedSearchLanguagesSort', '0', NULL, 'Use AdvancedSearchLanguages to sort the drop-down list. The leftmost language has the highest priority and appears on top of the drop-down.', 'YesNo')");
    print "Upgrade to done (Bug 14912 - Sort Advanced Search languages by priority)\n";
}