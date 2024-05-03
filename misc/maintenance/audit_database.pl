#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;

use Koha::Database::Auditor;

my $filename;

GetOptions(
    "filename=s" => \$filename,
) or die("Error in command line arguments\n");

my $auditor = Koha::Database::Auditor->new( { filename => $filename } );
my $diff    = $auditor->run;

my $warning = "\n"
    . "WARNING!!!\n"
    . "These commands are only suggestions! They are not a replacement for updatedatabase.pl!\n"
    . "Review the database, updatedatabase.pl, and kohastructure.sql before making any changes!\n" . "\n";

print $diff . $warning;
