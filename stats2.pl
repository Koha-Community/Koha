#!/usr/bin/perl

# $Id$

#written 14/1/2000
#script to display reports


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
use C4::Context;
use C4::Stats;
use Date::Manip;
use CGI;
use C4::Output;
use DBI;

my $input=new CGI;
my $time=$input->param('time');
print $input->header;

print startpage;
print startmenu('report');
print center;

my $date;
my $date2;
if ($time eq 'yesterday'){
  $date=ParseDate('yesterday');
  $date2=ParseDate('today');
}
if ($time eq 'today'){
  $date=ParseDate('today');
  $date2=ParseDate('tomorrow');
}
if ($time eq 'daybefore'){
  $date=ParseDate('2 days ago');
  $date2=ParseDate('yesterday');
}
if ($time=~ /\//){
  $date=ParseDate($time);
  $date2=ParseDateDelta('+ 1 day');
  $date2=DateCalc($date,$date2);
}
$date=UnixDate($date,'%Y-%m-%d');
$date2=UnixDate($date2,'%Y-%m-%d');

my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare("select *
from accountlines,accountoffsets,borrowers where
accountlines.borrowernumber=accountoffsets.borrowernumber and
(accountlines.accountno=accountoffsets.accountno or accountlines.accountno
=accountoffsets.offsetaccount) and accountlines.timestamp >=20000621000000
and borrowers.borrowernumber=accountlines.borrowernumber
group by accountlines.borrowernumber,accountlines.accountno");
$sth->execute();



print mktablehdr;
while (my $data=$sth->fetchrow_hashref){
  print "<TR><Td>$data->{'surname'}</td><td>$data->{'description'}</td><td>$data->{'amount'}
  </td>";
  if ($data->{'accountype'}='Pay'){	# FIXME - This should be "==", not "=", right?
    my $branch=Getpaidbranch($data->{'timestamp'});
    print "<td>$branch</td>";
  }
  print "</tr>";

}


print mktableft;
print endcenter;
#print "<p><b>$total</b>";



print endmenu('report');
print endpage;
$sth->finish;
