#!/usr/bin/perl

use C4::Database;
use strict;

my $dbh=C4Connect;

my $sth=$dbh->prepare("Select biblio.biblionumber,biblio.title from biblio,catalogueentry where catalogueentry.entrytype
='t' and catalogueentry.catalogueentry=biblio.title limit 500");
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  my $query="Update catalogueentry set biblionumber='$data->{'biblionumber'}' where catalogueentry.catalogueentry =
  \"$data->{'title'}\" and catalogueentry.entrytype='t'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
}
$sth->finish;


$dbh->disconnect;
