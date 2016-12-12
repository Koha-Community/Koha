#!/usr/bin/perl

use Modern::Perl;
use open qw( :std :encoding(UTF-8) );
binmode( STDOUT, ":encoding(UTF-8)" );

use Getopt::Long;

use C4::KohaSuomi::DebianPackages;

my $help;

GetOptions(
    'h|help'             => \$help,
);

my $usage = << 'ENDUSAGE';

SYNOPSIS:

This script returns all the debian packages Koha needs in a nice list.
All packages which are not core-Koha are excluded.

Such as apache2, idzebra2, mysql-*, memcached.

These are intended to be installed in separate servers or by using specific Ansible roles.

ENDUSAGE

if ($help) {
    print $usage;
    exit;
}

my $packageNames = C4::KohaSuomi::DebianPackages::getKohaSuomiDebianPackageNames();
print join("\n", @$packageNames);
