#!/usr/bin/perl

#script to display reports
#written 8/11/99


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
use CGI;
use C4::Context;
use C4::Output;
use C4::Database;
use C4::Auth;

my $input = new CGI;

my $flagsrequired;
$flagsrequired->{circulation}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);


print $input->header;
my $type=$input->param('type');
# print startpage();
# print startmenu('issue');
print "Each box needs to be filled in with fine,time to start charging,charging cycle<br>
eg 1,7,7 = $1 fine, after 7 days, every 7 days";

my $dbh = C4::Context->dbh;
my $query="Select description,categorycode from categories";
my $sth=$dbh->prepare($query);
$sth->execute;
print mktablehdr;
my @trow;
my @trow3;
my $i=0;
while (my $data=$sth->fetchrow_hashref){
  $trow[$i]=$data->{'description'};
  $trow3[$i]=$data->{'categorycode'};
  $i++;
}
$sth->finish;
print mktablerow(10,'white','',@trow);
print "<form action=/cgi-bin/koha/updatecharges.pl method=post>";
$query="Select description,itemtype from itemtypes";
$sth=$dbh->prepare($query);
$sth->execute;
$i=0;

while (my $data=$sth->fetchrow_hashref){
  my @trow2;
  for ($i=0;$i<9;$i++){
    $query="select * from categoryitem where categorycode=? and itemtype=?";
    my $sth2=$dbh->prepare($query);
    $sth2->execute($trow3[$i],$data->{'itemtype'});
    my $dat=$sth2->fetchrow_hashref;
    $sth2->finish;
    my $fine=$dat->{'fine'}+0;
    $trow2[$i]="<input type=text name=\"$trow3[$i].$data->{'itemtype'}\" value=\"$fine,$dat->{'firstremind'},$dat->{'chargeperiod'}\" size=6>";
  }
  print mktablerow(11,'white',$data->{'description'},@trow2);
}

$sth->finish;


print "</table>";
print "<input type=submit></form>";
print endmenu('issue');
print endpage();
