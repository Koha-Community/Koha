#!/usr/bin/perl

#written 14/1/2000
#script to display reports

use C4::Stats;
use strict;
use Date::Manip;
use CGI;
use C4::Output;
use DBI;
use C4::Database;

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

my $dbh=C4Connect;
my $query="select * 
from accountlines,accountoffsets,borrowers where
accountlines.borrowernumber=accountoffsets.borrowernumber and
(accountlines.accountno=accountoffsets.accountno or accountlines.accountno
=accountoffsets.offsetaccount) and accountlines.timestamp >=20000621000000 
and borrowers.borrowernumber=accountlines.borrowernumber
group by accountlines.borrowernumber,accountlines.accountno";
my $sth=$dbh->prepare($query);
$sth->execute;



print mktablehdr;
while (my $data=$sth->fetchrow_hashref){
  print "<TR><Td>$data->{'surname'}</td><td>$data->{'description'}</td><td>$data->{'amount'}
  </td>";
  if ($data->{'accountype'}='Pay'){
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
$dbh->disconnect;
