#!/usr/bin/perl


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
