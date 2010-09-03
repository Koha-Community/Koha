#!/usr/bin/perl

use strict;
use warnings;

use C4::Context;
use C4::Biblio;
use Getopt::Long;

my ($wherestring,$run,$want_help);
my $result           = GetOptions(
    'where:s'        => \$wherestring,
    '--run'        => \$run,
    'help|h'            => \$want_help,
);
if ( not $result or $want_help ) {
    print_usage();
    exit 0;
}


my $dbh=C4::Context->dbh;
my $querysth=qq{SELECT biblionumber from biblioitems };
$querysth.=" WHERE $wherestring " if ($wherestring);
my $query=$dbh->prepare($querysth);

$query->execute;
while (my $biblionumber=$query->fetchrow){
    my $record=GetMarcBiblio($biblionumber);
    
    if ($record){
        ModBiblio($record,$biblionumber,GetFrameworkCode($biblionumber)) ;
    }
    else {
        print "error in $biblionumber : can't parse biblio";
    }
}
sub print_usage {
    print <<_USAGE_;
$0: removes items from selected biblios


Parameters:
    -where                  use this to limit modifications to some biblios
    --run                   run the command
    --help or -h            show this message.
_USAGE_
}

#
