#!/usr/bin/perl

# This script will convert a database into the newer, proper
# form ... I think.



# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use C4::Context;
use strict;

my $dbh = C4::Context->dbh;

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

my $sth=$dbh->prepare($query);	# FIXME - There's already a $sth in this scope
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

my $query = "Select * from categories where categorycode = 'ST'";	# FIXME - There's already a $query in this scope
my $sth=$dbh->prepare($query);	# FIXME - There's already a $sth in this scope
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

my $query = "Select * from categories where categorycode = 'BR' or categorycode='CO' or categorycode='IS'";	# FIXME - There's already a $query in this scope
my $sth=$dbh->prepare($query);	# FIXME - There's already a $sth in this scope
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

my $query = "Select * from categories where categorycode = 'TD'  or categorycode='TR'";	# FIXME - There's already a $query in this scope
my $sth=$dbh->prepare($query);	# FIXME - There's already a $sth in this scope
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

my $query = "Select * from categories where categorycode = 'HR'";	# FIXME - There's already a $query in this scope
my $sth=$dbh->prepare($query);	# FIXME - There's already a $sth in this scope
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

my $query = "Select * from categories where categorycode = 'IL'";	# FIXME - There's already a $query in this scope
my $sth=$dbh->prepare($query);	# FIXME - There's already a $sth in this scope
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

my $query = "Select * from categories where categorycode = 'TB'";	# FIXME - There's already a $query in this scope
my $sth=$dbh->prepare($query);	# FIXME - There's already a $sth in this scope
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

my @queryValues =
    ("insert into categories values ('E','Senior Citizen',5,99,0,'A',0,0,0,99,1)",
     "insert into categories values ('A','Adult',5,99,0,'A',0,0,0,99,1)",
     "insert into categories values ('C','Child',5,16,0,'A',0,0,0,99,0)",
     "insert into categories values ('B','Housebound',5,99,0,'E',0,0,0,99,0)",
     "insert into categories values ('F','Family',5,99,0,'A',0,0,0,99,1)",
     "insert into categories values ('W','Workers',5,99,0,'A',0,0,0,99,0)",
     "insert into categories values ('I','Institution',5,99,0,'A',0,0,0,99,0)",
     "insert into categories values ('P','Privileged',5,99,0,'A',0,0,0,99,0)",
     "insert into categories values ('L','Library',5,99,0,'A',0,0,0,99,0)"
     );

foreach $query (@queryValues) {
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
}
