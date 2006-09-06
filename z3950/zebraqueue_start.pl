#!/usr/bin/perl
# script that starts the zebraquee
#  Written by TG on 01/08/2006
use strict;


use C4::Context;
use C4::Biblio;
use C4::AuthoritiesMarc;
use XML::Simple;
use utf8;
### ZEBRA SERVER UPDATER
##Uses its own database handle
my $dbh=C4::Context->dbh;
my $readsth=$dbh->prepare("select id,biblio_auth_number,operation,server from zebraqueue");
my $delsth=$dbh->prepare("delete from zebraqueue where id =?");


AGAIN:
my $wait=C4::Context->preference('zebrawait');
 $wait=120 unless $wait;
my ($id,$biblionumber,$operation,$server,$marcxml);
$readsth->execute;
while (($id,$biblionumber,$operation,$server)=$readsth->fetchrow){
if ($server eq "biblioserver"){
	($marcxml) =ZEBRA_readyXML($dbh,$biblionumber);
	}elsif($server eq "authorityserver"){
	$marcxml =C4::AuthoritiesMarc::XMLgetauthority($dbh,$biblionumber);
	} 

eval {
my $hashed=XMLin($marcxml);
}; ### is it a proper xml? broken xml may crash ZEBRA- slow but safe

if ($@){
warn $@;
## Broken XML-- Should not reach here-- but if it does -lets protect ZEBRA
$delsth->execute($id);
next;
}
my $ok;
eval{
 $ok=ZEBRAopserver($marcxml,$operation,$server);
};
 ## If a delete operation delete the SQL DB as well
	if ($operation eq "recordDelete" && $ok==1){
		if ($server eq "biblioserver"){
		ZEBRAdelbiblio($dbh,$biblionumber);
		}elsif ($server eq "authorityserver"){
		ZEBRAdelauthority($dbh,$biblionumber);
		}
	}
$delsth->execute($id) if ($ok==1);
}

sleep $wait;
goto AGAIN;