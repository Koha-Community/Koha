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
use C4::Output;
use CGI;
use C4::Database;

my $input = new CGI;
print $input->header;
my $type=$input->param('type');
print startpage();
print startmenu('report');

my $duedate;
my $bornum;
my $itemnum;
my $data1;
my $data2;
my $data3;
my $name;
my $phone;
my $email;
my $biblionumber;
my $title;
my $author;
my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);

print "<FONT SIZE=6><em>Items Overdue as of $todaysdate</em></FONT><br><P>";

print << "EOF";
<TABLE  cellspacing=0 cellpadding=5 border=0 align=center>
<TR VALIGN=TOP>
<TD  bgcolor="99cc33" background="/koha/images/background-mem.gif" colspan ><b>Due Date</b></td>
<TD  bgcolor="99cc33" background="/koha/images/background-mem.gif" colspan ><b>Patron</b></td>
<TD  bgcolor="99cc33" background="/koha/images/background-mem.gif"><b>Phone</b></td>
<TD  bgcolor="99cc33" background="/koha/images/background-mem.gif"><b>Title</b></td>
<TD  bgcolor="99cc33" background="/koha/images/background-mem.gif"><b>Author</b></td>
</tr>
EOF

my $dbh=C4Connect;

my $query="select date_due,borrowernumber,itemnumber from issues where isnull(returndate) && date_due<'$todaysdate' order by date_due,borrowernumber";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref) {
  $duedate=$data->{'date_due'};
  $bornum=$data->{'borrowernumber'};
  $itemnum=$data->{'itemnumber'};
  
  my $query="select concat(firstname,' ',surname),phone,emailaddress from borrowers where borrowernumber='$bornum'";
  my $sth1=$dbh->prepare($query);
  $sth1->execute;
  $data1=$sth1->fetchrow_hashref;
  $name=$data1->{'concat(firstname,\' \',surname)'};
  $phone=$data1->{'phone'};
  $email=$data1->{'emailaddress'};
  $sth1->finish;

  my $query="select biblionumber from items where itemnumber='$itemnum'";
  my $sth2=$dbh->prepare($query);
  $sth2->execute;
  $data2=$sth2->fetchrow_hashref;
  $biblionumber=$data2->{'biblionumber'};
  $sth2->finish;

  my $query="select title,author from biblio where biblionumber='$biblionumber'";
  my $sth3=$dbh->prepare($query);
  $sth3->execute;
  $data3=$sth3->fetchrow_hashref;
  $title=$data3->{'title'};
  $author=$data3->{'author'};
  $sth3->finish;

  if (!$email){
    print "<tr><td>$duedate</td><td>$name</td><td>$phone</td><td>$title</td><td>$author</td></tr>";
  } else {
    print "<tr><td>$duedate</td><td><a href=\"mailto:$email?subject=Overdue: $title\">$name</a></td><td>$phone</td><td>$title</td><td>$author</td></tr>";
  }
}

$sth->finish;
$dbh->disconnect;

print "</table>";

print endmenu('report');
print endpage();
