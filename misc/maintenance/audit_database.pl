#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;

use Koha::Database::Auditor;

my $filename;

GetOptions(
    "filename=s" => \$filename,
) or die("Error in command line arguments\n");

Koha::Database::Auditor->new( { filename => $filename, is_cli => 1 } )->run;
