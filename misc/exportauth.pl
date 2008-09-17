#!/usr/bin/perl
## This script allows you to export a rel_2_2 bibliographic db in 
#MARC21 format from the command line.
#

use strict;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

use C4::Context;
use C4::Output;  # contains gettemplate
use C4::Biblio;
use C4::Auth;
my $outfile = $ARGV[0];
open(OUT,">$outfile") or die $!;
my $dbh=C4::Context->dbh;
#$dbh->do("set character_set_client='latin5'"); 
$dbh->do("set character_set_connection='utf8'");
#$dbh->do("set character_set_results='latin5'");        
my $sth=$dbh->prepare("select marc from auth_header order by authid");
$sth->execute();
while (my ($marc) = $sth->fetchrow) {
    print OUT $marc;
 }
close(OUT);
