#!/usr/bin/perl

use Modern::Perl;
use Getopt::Long;

use Koha::Database::Auditor;

my $filename;

GetOptions(
    "filename=s" => \$filename,
) or die("Error in command line arguments\n");

my $auditor  = Koha::Database::Auditor->new( { filename => $filename } );
my $db_audit = $auditor->run;
print $db_audit->{title} . "\n" . $db_audit->{message} . "\n" . ( $db_audit->{diff_found} ? $db_audit->{diff} : '' );
