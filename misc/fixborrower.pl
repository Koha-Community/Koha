#!/usr/bin/perl

use C4::Database;
use strict;

my $dbh=C4Connect;
my $query = "Select * from categories where (categorycode like 'L%' or categorycode like 'F%'
or categorycode like 'S%' or categorycode like 'O%' or categorycode like 'H%') and (categorycode <>'HR' 
and categorycode <> 'ST')";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
    my $temp=substr($data->{'categorycode'},0,1);
  $query="update borrowers set area='$temp' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  $temp=substr($data->{'categorycode'},1,1);
  $query="update borrowers set categorycode='$temp' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}

$query = "Select * from categories where (categorycode like 'V%') and (categorycode <>'HR' 
and categorycode <> 'ST')";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
#    my $temp=substr($data->{'categorycode'},0,1);
  $query="update borrowers set area='V' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  my $temp=substr($data->{'categorycode'},1,1);
  $query="update borrowers set categorycode='$temp' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}

my $query = "Select * from categories where categorycode = 'ST'";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
  $query="update borrowers set area='' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  $query="update borrowers set categorycode='W' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}

my $query = "Select * from categories where categorycode = 'BR' or categorycode='CO' or categorycode='IS'";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
  $query="update borrowers set area='' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  $query="update borrowers set categorycode='I' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}
my $query = "Select * from categories where categorycode = 'TD'  or categorycode='TR'";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
  $query="update borrowers set area='X' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  $query="update borrowers set categorycode='A' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}

my $query = "Select * from categories where categorycode = 'HR'";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
  $query="update borrowers set area='K' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  $query="update borrowers set categorycode='A' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}

my $query = "Select * from categories where categorycode = 'IL'";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
  $query="update borrowers set area='Z' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  $query="update borrowers set categorycode='L' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}
my $query = "Select * from categories where categorycode = 'TB'";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  #update borrowers corresponding
  #update categories
  $query="update borrowers set area='' where categorycode='$data->{'categorycode'}'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
  $query="update borrowers set categorycode='P' where categorycode='$data->{'categorycode'}'"; 
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;
   $query="delete from categories where categorycode='$data->{'categorycode'}'";
  $sth2=$dbh->prepare($query);
  $sth2->execute;
  $sth2->finish;

}

$sth->finish;
$query="insert into categories values ('A','Adult',5,99,0,'A',0,0,0,99,1)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;
$query="insert into categories values ('E','Senior Citizen',5,99,0,'A',0,0,0,99,1)";                                                                
$sth=$dbh->prepare($query);                                                                                                                       
$sth->execute;                                                                                                                                    
$sth->finish;    
$query="insert into categories values ('C','Child',5,16,0,'A',0,0,0,99,0)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;
$query="insert into categories values ('B','Housebound',5,99,0,'E',0,0,0,99,0)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;
$query="insert into categories values ('F','Family',5,99,0,'A',0,0,0,99,1)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;
$query="insert into categories values ('W','Workers',5,99,0,'A',0,0,0,99,0)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;
$query="insert into categories values ('I','Institution',5,99,0,'A',0,0,0,99,0)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;
$query="insert into categories values ('P','Privileged',5,99,0,'A',0,0,0,99,0)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;
$query="insert into categories values ('L','Library',5,99,0,'A',0,0,0,99,0)";
$sth=$dbh->prepare($query);
$sth->execute;
$sth->finish;



$dbh->disconnect;
