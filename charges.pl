#!/usr/bin/perl

#script to display reports
#written 8/11/99

use strict;
use CGI;
use C4::Output;
use C4::Database;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
print startpage();
print startmenu('issue');
print "Each box needs to be filled in with fine,time to start charging,charging cycle<br>
eg 1,7,7 = $1 fine, after 7 days, every 7 days";

my $dbh=C4Connect;
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
    $query="select * from categoryitem where categorycode='$trow3[$i]' and itemtype='$data->{'itemtype'}'";
    my $sth2=$dbh->prepare($query);
    $sth2->execute;
    my $dat=$sth2->fetchrow_hashref;
    $sth2->finish;
    my $fine=$dat->{'fine'}+0;
    $trow2[$i]="<input type=text name=\"$trow3[$i]$data->{'itemtype'}\" value=\"$fine,$dat->{'startcharge'},$dat->{'chargeperiod'}\" size=6>";
  }
  print mktablerow(11,'white',$data->{'description'},@trow2);
}

$sth->finish;


print "</table>";
print "<input type=submit></form>";
print endmenu('issue');
print endpage();
