#!/usr/bin/perl

use strict;
use C4::Database;

my $dbh=C4Connect;
my $count=0;
my $query="Select biblionumber from aqorders where datereceived = '0000-00-00'";
my $sth=$dbh->prepare($query);
$sth->execute;

my $query2="Select max(biblioitemnumber) from biblioitems";
my $sth2=$dbh->prepare($query2);
$sth2->execute;
my $data=$sth2->fetchrow_hashref;
my $bibitemno=$data->{'max(biblioitemnumber)'};
print $bibitemno;
$bibitemno++;
$sth2->finish;
while (my $data=$sth->fetchrow_hashref){
  $sth2=$dbh->prepare("insert into biblioitems (biblioitemnumber,biblionumber) values
  ($bibitemno,$data->{'biblionumber'})");
  $sth2->execute;
  $sth2->finish;
  $sth2=$dbh->prepare("update aqorders set biblioitemnumber=$bibitemno where biblionumber
  =$data->{'biblionumber'}");
  $sth2->execute;
  $sth2->finish;
  $bibitemno++
  
}
$sth->finish;


$dbh->disconnect;
