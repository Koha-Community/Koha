#!/usr/bin/perl

use C4::Database;
use strict;

my $dbh=C4Connect;

my $sth=$dbh->prepare("Select ordernumber,biblionumber from aqorders order by ordernumber");
$sth->execute;
my $number;
my $i=92000;
while (my $data=$sth->fetchrow_hashref){
  if ($data->{'ordernumber'} != $number){    
  } else {
    my $query="update aqorders set ordernumber=$i where ordernumber=$data->{'ordernumber'} and biblionumber=$data->{'biblionumber'}";
    my $sth2=$dbh->prepare($query);
    $sth2->execute;
    $sth2->finish;
    $query="update aqorderbreakdown set ordernumber=$i where ordernumber=$data->{'ordernumber'}";
    $sth2=$dbh->prepare($query);
    $sth2->execute;
    $sth2->finish;
        $i++;
  }
  $number=$data->{'ordernumber'};
}
$sth->finish;


$dbh->disconnect;
