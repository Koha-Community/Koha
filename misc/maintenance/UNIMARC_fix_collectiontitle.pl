#!/usr/bin/perl
#
# This script should be used only with UNIMARC flavour
# It is designed to report some missing information from biblio
# table into  marc data
#
use strict;
use warnings;

BEGIN {
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Biblio;

sub process {

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare(qq{UPDATE marc_subfield_structure SET kohafield='biblioitems.collectiontitle' where kohafield='biblio.seriestitle' and not tagfield like "4__"});
    return $sth->execute();


}

if (lc(C4::Context->preference('marcflavour')) eq "unimarc"){
print "count subfields changed :".process()." kohafields biblio.seriestitle changed into biblioitems.collectiontitle";
} 
else {
	print "this script is UNIMARC only and should be used only on unimarc databases\n";
}
