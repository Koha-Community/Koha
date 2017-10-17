#!/usr/bin/perl

use Modern::Perl;
use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Getopt::Long;

use C4::KohaSuomi::DebianPackages;

my $help;
my $install;

GetOptions(
    'h|help'             => \$help,
    'i|install'          => \$install
);

my $usage = << 'ENDUSAGE';

SYNOPSIS:

This script returns all the debian packages Koha needs in a nice list.
All packages which are not core-Koha are excluded.

Such as apache2, idzebra2, mysql-*, memcached.

These are intended to be installed in separate servers or by using specific Ansible roles 
or script can be used to install them to current server with sudo and option -i or -install.

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

my $packageNames = C4::KohaSuomi::DebianPackages::getKohaSuomiDebianPackageNames();
if ($install) {
	foreach my $package (@$packageNames) {
		my $cmd = "/usr/bin/apt-get install $package";
      		my $output = system($cmd);
		print "$output\n";
		print "--------------------------------------------------------------------------------------------------------\n";
	}
} else {
	print join("\n", @$packageNames);
}
