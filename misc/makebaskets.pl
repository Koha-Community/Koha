#!/usr/bin/perl

use strict;
use C4::Database;

my $dbh=C4Connect;
my $count=0;
my $basket='HLT-';
for (my $i=1;$i<59;$i++){
  my $query = "Select authorisedby,entrydate from aqorders where booksellerid='$i'";            
  $query.=" group by authorisedby,entrydate order by entrydate"; 
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $basket=$count;
    $data->{'authorisedby'}=~ s/\'/\\\'/g;
    my $query2="update aqorders set basketno='$basket' where booksellerid='$i' and authorisedby=
    '$data->{'authorisedby'}' and entrydate='$data->{'entrydate'}'";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    $sth2->finish;
    $count++;
  }
  $sth->finish;
}

$dbh->disconnect;
