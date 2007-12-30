#!/usr/bin/perl

use ExtUtils::Installed;
my $instmod = ExtUtils::Installed->new();
foreach my $module ($instmod->modules()) {
my $version = $instmod->version($module) || "???";
       print "$module -- $version\n";
}
