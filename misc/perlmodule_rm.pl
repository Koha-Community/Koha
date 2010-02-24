#!/usr/bin/perl

# Remove a perl module

use warnings;
use ExtUtils::Packlist;
use ExtUtils::Installed;

$ARGV[0] or die "Usage: $0 Module::Name\n";

my $mod = $ARGV[0];

my $inst = ExtUtils::Installed->new();

foreach my $item (sort($inst->files($mod))) {
    print "removing $item\n";
    unlink $item;
}

my $packfile = $inst->packlist($mod)->packlist_file();
print "removing $packfile\n";
unlink $packfile;
