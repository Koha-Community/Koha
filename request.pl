#!/usr/bin/perl

#script to place reserves/requests
#writen 2/1/00 by chris@katipo.oc.nz

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;
use C4::Reserves2;
use C4::Acquisitions;
my $input = new CGI;
print $input->header;


#setup colours
print startpage();
print startmenu();
my $blah;
my $bib=$input->param('bib');
my $dat=bibdata($bib);
my ($count,$reserves)=FindReserves($bib);
#print $count;
#print $input->dump;


print <<printend
<form action="placerequest.pl" method=post>
<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=187 BORDER=0 src="/images/place-request.gif" align=right >
<input type=hidden name=biblio value=$bib>
<input type=hidden name=type value=str8>
<input type=hidden name=title value="$dat->{'title'}">
<FONT SIZE=6><em>Requesting: <a href=/cgi-bin/koha/detail.pl?bib=$bib>$dat->{'title'}</a> ($dat->{'author'})</em></FONT><P>
<p>

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left >

<!----------------BIBLIO RESERVE TABLE-------------->



<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member Number</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Notes</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
</TR>
<tr VALIGN=TOP  >
<TD><select name=rank-request>
printend
;
$count++;
my $i;
for ($i=1;$i<$count;$i++){
  print "<option value=$i>$i\n";
}
print "<option value=$i selected>$i\n";
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);
$year=$year+1900;
$mon++;
my $date="$mday/$mon/$year";
print <<printend
</select>
</td>
<TD><input type=text size=10 name=member></td>
<TD><input type=text size=20 name=notes></td>
<TD>$date</td>
<TD><select name=pickup>
printend
;
my ($count2,@branches)=branches;                                                                         
for (my $i=0;$i<$count2;$i++){                                                                           
  print "<option value=$branches[$i]->{'branchcode'}";                                                   
  print ">$branches[$i]->{'branchname'}";                                                                
}   
print <<printend
</select>
</td>
<td><input type=checkbox name=request value=any>Next Available, <br>(or choose from list below)</td>
</tr>


</table>
</p>


<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Item Type</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Classification</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Volume</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>ISBN</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Copyright</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pubdate</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Copies</b></TD>
</TR>
printend
;
my $blah;
my ($count2,@data)=bibitems($bib);
for ($i=0;$i<$count2;$i++){
  my @barcodes=barcodes($data[$i]->{'biblioitemnumber'});
  if ($data[$i]->{'dewey'} == 0){
    $data[$i]->{'dewey'}="";
  }
  $data[$i]->{'dewey'}=~ s/\.0000$//;
  $data[$i]->{'dewey'}=~ s/00$//;
  my $class="$data[$i]->{'classification'}$data[$i]->{'dewey'}$data[$i]->{'subclass'}";
  print "<tr VALIGN=TOP  >
  <TD><input type=checkbox name=reqbib value=$data[$i]->{'biblioitemnumber'}>
  <input type=hidden name=biblioitem value=$data[$i]->{'biblioitemnumber'}>
  </td>
  <TD>$data[$i]->{'description'}</td>
  <TD>$class</td>																								
  <td>$data[$i]->{'volumeddesc'}</td>
  <td>$data[$i]->{'isbn'}</td>
  <td>$dat->{'copyrightdate'}</td>
  <td>$data[$i]->{'publicationyear'}</td>
  <td>@barcodes</td>
  </tr>";
}
print <<printend
</table>
</p>
</form>
<p>&nbsp; </p>
<!-----------MODIFY EXISTING REQUESTS----------------->

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >

<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=7><B>MODIFY EXISTING REQUESTS </b></TD>
</TR>
<form action=modrequest.pl method=post>
<TR VALIGN=TOP>

<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Rank</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Member</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Notes</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Date</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Pickup</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Request</b></TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif"><B>Change To</b></TD>
</TR>
printend
;
$count--;

for ($i=0;$i<$count;$i++){
print "<input type=hidden name=borrower value=$reserves->[$i]{'borrowernumber'}>";
print "<input type=hidden name=biblio value=$reserves->[$i]{'biblionumber'}>";
#my $bor=$reserves->[$i]{'firstname'}."%20".$reserves->[$i]{'surname'};
#$bor=~ s/ /%20/g;
my $bor=$reserves->[$i]{'borrowernumber'};
my @temp=split('-',$reserves->[$i]{'reservedate'});
$date="$temp[2]/$temp[1]/$temp[0]";
my $type=$reserves->[$i]{'constrainttype'};
#print "test";
if ($type eq 'a'){
  $type='Next Available';
} elsif ($type eq 'o'){
# print "test";
  my $res=getreservetitle($reserves->[$i]{'biblionumber'},$reserves->[$i]{'borrowernumber'},$reserves->[$i]{'reservedate'},$reserves->[$i]{'timestamp'});
  $type="This type only $res->{'volumeddesc'} $res->{'itemtype'}";
#  my @data=ItemInfo(\$blah,$reserves->[$i]{'borrowernumber'});
  
}
print "<tr VALIGN=TOP  >
<TD><select name=rank-request>
";
for (my $i2=1;$i2<=$count;$i2++){
  print "<option value=$i2";
  if ($reserves->[$i]{'priority'} eq $i2){
    print " selected";
  }
  print">$i2";
}
print "<option value=del>Del";
print "</select>
</td>
<TD><a href=/cgi-bin/koha/moremember.pl?bornum=$bor>$reserves->[$i]{'firstname'} $reserves->[$i]{'surname'}</a></td>
<td>$reserves->[$i]{'reservenotes'}</td>
<TD>$date</td>
<TD><select name=pickup>
";
my ($count2,@branches)=branches;                                                                         
for (my $i2=0;$i2<$count2;$i2++){                                                                           
  print "<option value=$branches[$i2]->{'branchcode'}";                                                   
  if ($reserves->[$i]{'branchcode'} eq $branches[$i2]->{'branchcode'}){                                           
    print " Selected";                                                                                   
  }
  print ">$branches[$i2]->{'branchname'}\n";                                                                
}   
print "
</select>
</td>
<TD>$type</td>
<TD><select name=itemtype>
<option value=next>Next Available
<option value=change>Change Selection
<option value=nc >No Change
</select>
</td>
</tr>
";
}
print <<printend


<tr VALIGN=TOP  >

<TD colspan=6 align=right>
Delete a request by selecting "del" from the rank list.

<INPUT TYPE="image" name="submit"  VALUE="request" height=42  WIDTH=64 BORDER=0 src="/images/ok.gif"></td>


</tr>


</table>
<P>

<br>




</form>
printend
;

print endmenu();
print endpage();
