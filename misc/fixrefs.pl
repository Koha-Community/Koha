#!/usr/bin/perl

use strict;
use C4::Database;

my $dbh=C4Connect;
my $count=0;
my $query="Select * from biblioitems where itemtype='REF' or itemtype='TREF'";
my $sth=$dbh->prepare($query);
$sth->execute;

while (my $data=$sth->fetchrow_hashref){
  $query="update items set notforloan=1 where biblioitemnumber='$data->{'biblioitemnumber'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
}
$sth->finish;


$dbh->disconnect;
