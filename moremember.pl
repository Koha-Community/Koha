#!/usr/bin/perl

# script to do a borrower enquiry/bring up borrower details etc
# Displays all the details about a borrower
# written 20/12/99 by chris@katipo.co.nz
# last modified 21/1/2000 by chris@katipo.co.nz
# modified 31/1/2001 by chris@katipo.co.nz 
#   to not allow items on request to be renewed
#
# needs html removed and to use the C4::Output more, but its tricky
#


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
use C4::Search;
use Date::Manip;
use C4::Reserves2;
use C4::Circulation::Renewals2;
use C4::Circulation::Circ2;
use C4::Koha;
use C4::Database;

my $dbh=C4Connect;

my $input = new CGI;
my $bornum=$input->param('bornum');


print $input->header;

#start the page and read in includes
print startpage();
print startmenu('member');
my $data=borrdata('',$bornum);


$data->{'dateenrolled'} = slashifyDate($data->{'dateenrolled'});
$data->{'expiry'} = slashifyDate($data->{'expiry'});
$data->{'dateofbirth'} = slashifyDate($data->{'dateofbirth'});

$data->{'ethnicity'} = fixEthnicity($data->{'ethnicity'});

print <<printend
<FONT SIZE=6><em>$data->{'firstname'} $data->{'surname'}</em></FONT><P>
<p>
<form action=/cgi-bin/koha/jmemberentry.pl method=post>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width=270>
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>MEMBERSHIP RECORD</TD></TR>
<tr VALIGN=TOP  >	
<TD>
<p align=right><INPUT TYPE="image" name="submit"  VALUE="add-child" height=42  WIDTH=120 BORDER=0 src="/images/add-child.gif"> 		
<input type=hidden name=type value=Add>
<input type=hidden name=bornum value=$data->{'borrowernumber'}>
</form>
</P><br>
<FONT SIZE=2  face="arial, helvetica">$data->{'title'} $data->{'othernames'}  $data->{'surname'} ($data->{'firstname'}, $data->{'initials'})<p>

Card Number: $data->{'cardnumber'}<BR>
printend
;
if ($data->{'categorycode'} eq 'C'){
    my $data2=borrdata('',$data->{'guarantor'});
    $data->{'streetaddress'}=$data2->{'streetaddress'};
    $data->{'city'}=$data2->{'city'};
    $data->{'physstreet'}=$data2->{'phystreet'};
    $data->{'streetcity'}=$data2->{'streetcity'};
    $data->{'phone'}=$data2->{'phone'};
    $data->{'phoneday'}=$data2->{'phoneday'};
}
my $ethnicityline='';
if ($data->{'ethnicity'} || $data->{'ethnotes'}) {
	$ethnicityline="Ethnicity: $data->{'ethnicity'}, $data->{'ethnotes'}<br>";
}
print <<printend
Postal Address: $data->{'streetaddress'}, $data->{'city'}<BR>
Home Address: $data->{'physstreet'}, $data->{'streetcity'}<BR>
Phone (Home): $data->{'phone'}<BR>
Phone (Daytime): $data->{'phoneday'}<BR>
Fax: $data->{'faxnumber'}<BR>
E-mail: <a href="mailto:$data->{'emailaddress'}">$data->{'emailaddress'}</a><br>
Textmessaging:$data->{'textmessaging'}<p>
Membership Number: $data->{'borrowernumber'}<BR>
Membership: $data->{'categorycode'}<BR>
Area: $data->{'area'}<BR>
Fee:$30/year, Paid<BR>
Joined: $data->{'dateenrolled'},  Expires: $data->{'expiry'} <BR>
Joining Branch: $data->{'homebranch'}<P>
$ethnicityline
DoB: $data->{'dateofbirth'}<BR>
Sex: $data->{'sex'}<P>

Alternative Contact:$data->{'contactname'}<BR>
Phone: $data->{'altphone'}<BR>
Relationship: $data->{'altrelationship'}<BR>
Notes: $data->{'altnotes'}<P>
printend
;

if ($data->{'categorycode'} ne 'C'){
  print " Guarantees:";
  # FIXME
  # It looks like the $i is only being returned to handle walking through
  # the array, which is probably better done as a foreach loop.
  #
  my ($count,$guarantees)=findguarantees($data->{'borrowernumber'});
  for (my $i=0;$i<$count;$i++){
    print "<A HREF=\"/cgi-bin/koha/moremember.pl?bornum=$guarantees->[$i]->{'borrowernumber'}\">$guarantees->[$i]->{'cardnumber'}</a><br>";
  }
} else {
  print "Guarantor:";
  my ($guarantor)=findguarantor($data->{'borrowernumber'});
  if ($guarantor->{'borrowernumber'} == 0){
      print "no guarantor<br>";
  } else {
    print "<A HREF=\"/cgi-bin/koha/moremember.pl?bornum=$guarantor->{'borrowernumber'}\">$guarantor->{'cardnumber'}</a><br>";
  }
}
print <<printend


<P>

General Notes: <!--<A HREF="popbox.html" onclick="messenger(200,250,'Form that lets you add to and delete notes.'); return false">-->
$data->{'borrowernotes'}<!--</a>-->
<p align=right>
<form action=/cgi-bin/koha/memberentry.pl method=post>
<input type=hidden name=bornum value=$bornum>
<INPUT TYPE="image" name="modify"  VALUE="modify" height=42  WIDTH=93 BORDER=0 src="/images/modify-mem.gif"> 

<INPUT TYPE="image" name="delete"  VALUE="delete" height=42  WIDTH=93 BORDER=0 src="/images/delete-mem.gif"> 
</p>

</TD>
</TR>
</TABLE>
</FORM>
<img src="/images/holder.gif" width=16 height=800 align=left>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=4><B>FINES & CHARGES</TD></TR>
printend
;
my %bor;
$bor{'borrowernumber'}=$bornum;

# FIXME
# it looks like $numaccts is a temp variable and that the 
# for (my $i;$i<$numaccts;$i+++) 
# can be turned into a foreach loop instead
#
my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);
#if ($numaccts > 10){
#  $numaccts=10;
#}
for (my$i=0;$i<$numaccts;$i++){
#if ($accts->[$i]{'accounttype'} ne 'Pay'){
  my $amount= $accts->[$i]{'amount'} + 0.00;
    my $amount2= $accts->[$i]{'amountoutstanding'} + 0.00;
  if ($amount2 != 0){
    print "<tr VALIGN=TOP  >";
    my $item=" &nbsp; ";
    
    $accts->[$i]{'date'} = slashifyDate($accts->[$i]{'date'});

    if ($accts->[$i]{'accounttype'} ne 'Res'){
    #get item data
    #$item=
    }
    print "<td>$accts->[$i]{'date'}</td>";
#  print "<TD>$accts->[$i]{'accounttype'}</td>";
    print "<TD>";

    # FIXME
    # why set this variable if it's not going to be used?
    #
    my $env;
    if ($accts->[$i]{'accounttype'} ne 'Res'){
      my $iteminfo=C4::Circulation::Circ2::getiteminformation($env,$accts->[$i]->{'itemnumber'},'');
      print "<a href=/cgi-bin/koha/moredetail.pl?itemnumber=$accts->[$i]->{'itemnumber'}&bib=$iteminfo->{'biblionumber'}&bi=$iteminfo->{'biblioitemnumber'}>$accts->[$i]->{'description'} $accts->[$i]{'title'}</a>";
    }
    print "</td>
    <TD>$amount</td><td>$amount2</td>
    </tr>";
  }
}
print <<printend

<tr VALIGN=TOP  >
<TD colspan=3 align=right>
<nobr>
<a href=/cgi-bin/koha/boraccount.pl?bornum=$bornum><img height=42  WIDTH=187 BORDER=0 src="/images/view-account.gif"></a>
<a href=/cgi-bin/koha/pay.pl?bornum=$bornum><img height=42  WIDTH=187 BORDER=0 src="/images/pay-fines.gif"></a></nobr>
</td>

</tr>


</table>

<p>
<form action="renewscript.pl" method=post>
<input type=hidden name=bornum value=$bornum>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=6><B>ITEMS CURRENTLY ON ISSUE</b></TD>
</TR>

<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Title</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Due</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Itemtype</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Charge</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Renew</b></TD>
</TR>
printend
;
my ($count,$issue)=borrissues($bornum);
my $today=ParseDate('today');
for (my $i=0;$i<$count;$i++){
  print "<tr VALIGN=TOP  >
  <TD>";
    my $datedue=ParseDate($issue->[$i]{'date_due'});

  $issue->[$i]{'date_due'} = slashifyDate($issue->[$i]{'date_due'});

  if ($datedue < $today){  
    print "<font color=red>";
  }
  print "$issue->[$i]{'title'} 
  <a href=/cgi-bin/koha/moredetail.pl?item=$issue->[$i]->{'itemnumber'}&bib=$issue->[$i]->{'biblionumber'}&bi=$issue->[$i]->{'biblioitemnumber'}>
  $issue->[$i]{'barcode'}</a></td>
  <TD>$issue->[$i]{'date_due'}</td>";
  #find the charge for an item
  my ($charge,$itemtype)=calc_charges(undef,$dbh,$issue->[$i]{'itemnumber'},$bornum);
  print "<TD>$itemtype</td>";
  print "<TD>$charge</td>";

#  if ($datedue < $today){
#    print "<td>Overdue</td>";
#  } else {
#    print "<td> &nbsp; </td>";
#  }
  #check item is not reserved
  my ($restype,$reserves)=CheckReserves($issue->[$i]{'itemnumber'});
  if ($restype){
    print "<TD><a href=/cgi-bin/koha/request.pl?bib=$issue->[$i]{'biblionumber'}>On Request - no renewals</a></td></tr>";
#  } elsif ($issue->[$i]->{'renewals'} > 0) {
#      print "<TD>Previously Renewed - no renewals</td></tr>";
  } else {
    print "<TD>";
  
    print "<input type=radio name=\"renew_item_$issue->[$i]{'itemnumber'}\" value=y>Y
    <input type=radio name=\"renew_item_$issue->[$i]{'itemnumber'}\" value=n>N</td>
    </tr>
    ";
  }
}
print <<printend

<tr VALIGN=TOP  >
<TD colspan=5 align=right>
<INPUT TYPE="image" name="submit"  VALUE="update" height=42  WIDTH=187 BORDER=0 src="/images/update-renewals.gif">
</td>
</form>
</tr>


</table>


<P>

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=5><B>ITEMS REQUESTED</b></TD>
</TR>

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Title</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Requested</b></TD>




<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Remove</b></TD>
</TR>
<form action=/cgi-bin/koha/modrequest.pl method=post>
<input type=hidden name=from value=borrower>
printend
;

my ($rescount,$reserves)=FindReserves('',$bornum); #From C4::Reserves2

# FIXME
# does it make sense to turn this into a foreach my $i (0..$rescount) 
# kind of loop? 
#
for (my $i=0;$i<$rescount;$i++){
  $reserves->[$i]{'reservedate2'} = slashifyDate($reserves->[$i]{'reservedate'});
  my $restitle;
  if ($reserves->[$i]{'constrainttype'} eq 'o'){
      $restitle=getreservetitle($reserves->[$i]{'biblionumber'},$reserves->[$i]{'borrowernumber'},$reserves->[$i]{'reservedate'},$reserves->[$i]{'timestamp'});
  } 
  print "<tr VALIGN=TOP  >
  <TD><a href=\"/cgi-bin/koha/request.pl?bib=$reserves->[$i]{'biblionumber'}\">$reserves->[$i]{'btitle'}</a> $restitle->{'volumeddesc'} $restitle->{'itemtype'}</td>
  <TD>$reserves->[$i]{'reservedate2'}</td>
  <input type=hidden name=biblio value=$reserves->[$i]{'biblionumber'}>
  <input type=hidden name=borrower value=$bornum>

  <TD><select name=\"rank-request\">
  <option value=n>No
  <option value=del>Yes
  </select>
  </tr>
  ";
}
print <<printend

<tr VALIGN=TOP  >
<TD colspan=5 align=right>
<INPUT TYPE="image" name="submit"  VALUE="update" height=42  WIDTH=187 BORDER=0 src="/images/cancel-requests.gif"></td>
</tr>
</table>
</form>
<p align=right>
<a href=/cgi-bin/koha/readingrec.pl?bornum=$bornum><img height=42  WIDTH=187 BORDER=0 src="/images/reading-record.gif"></a>
</p>
printend
;


print endmenu('member');
print endpage();


$dbh->disconnect;
