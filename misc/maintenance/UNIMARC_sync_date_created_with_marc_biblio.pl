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

sub updateMarc {
    my $id = shift;
    my $dbh = C4::Context->dbh;
    my $field;
    my $biblio = GetMarcBiblio($id);

    if(!$biblio->field('099'))
    {
        $field = new MARC::Field('099','','',
                    'c' => '',
                    'd'=>'');
        $biblio->add_fields($field);
    }

    $field = $biblio->field('099');

    my $sth = $dbh->prepare("SELECT DATE_FORMAT(datecreated,'%Y-%m-%d') as datecreated,
                                    DATE_FORMAT(timestamp,'%Y-%m-%d') as timestamp,
                                    frameworkcode
                                    FROM biblio
                                    WHERE biblionumber = ?");
    $sth->execute($id);
    (my $bibliorow = $sth->fetchrow_hashref);
    my $frameworkcode = $bibliorow->{'frameworkcode'};

    $field->update( 'c' => $bibliorow->{'datecreated'},
                    'd' => $bibliorow->{'timestamp'}
                    );

     if(&ModBiblio($biblio, $id, $frameworkcode))
     {
        print "\r$id";
     }

}

sub process {

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare("SELECT biblionumber FROM biblio");
    $sth->execute();

    while(my $biblios = $sth->fetchrow_hashref)
    {
        updateMarc($biblios->{'biblionumber'});
        print ".";
    }

}

if (lc(C4::Context->preference('marcflavour')) eq "unimarc"){
process();
} 
else {
	print "this script is UNIMARC only and should be used only on unimarc databases";
}
