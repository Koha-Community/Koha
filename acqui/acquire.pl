#!/usr/bin/perl

#script to recieve orders
#written by chris@katipo.co.nz 24/2/2000

use C4::Acquisitions;
use C4::Biblio;
use C4::Output;
use C4::Database;
use C4::Search;
use CGI;
use strict;

my $input=new CGI;

# Authentication script added, superlibrarian set as default requirement

my $flagsrequired;
$flagsrequired->{superlibrarian}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

print $input->header();
my $id=$input->param('id');

print startpage;

print startmenu('acquisitions');

my $search=$input->param('recieve');
my $invoice=$input->param('invoice');
my $freight=$input->param('freight');
my $biblio=$input->param('biblio');
my $catview=$input->param('catview');
my $gst=$input->param('gst');
my ($count,@results)=ordersearch($search,$biblio,$catview);
my ($count2,@booksellers)=bookseller($results[0]->{'booksellerid'}); 
#print $count;
my @date=split('-',$results[0]->{'entrydate'});
my $date="$date[2]/$date[1]/$date[0]";

if ($count == 1){


print <<EOP

<script language="javascript" type="text/javascript">
<!--
function messenger(X,Y,etc){
win=window.open("","mess","height="+X+",width="+Y+",screenX=150,screenY=0");
win.focus();
win.document.close();
win.document.write("<body link='#333333' bgcolor='#ffffff' text='#000000'><font size=2><p><br>");
win.document.write(etc);
win.document.write("<center><form><input type=button onclick='self.close()' value=Close></form></center>");
win.document.write("</font></body></html>");
}
//-->
</script>
<form action="/cgi-bin/koha/acqui/finishreceive.pl" method=post>
<input type=hidden name=biblio value=$results[0]->{'biblionumber'}>
<input type=hidden name=ordnum value=$results[0]->{'ordernumber'}>
<input type=hidden name=biblioitemnum value=$results[0]->{'biblioitemnumber'}>
<input type=hidden name=bookseller value=$results[0]->{'booksellerid'}>
<input type=hidden name=freight value=$freight>
<input type=hidden name=gst value=$gst>
EOP
;
if ($catview ne 'yes'){
  print "<input type=image  name=submit src=/images/save-changes.gif border=0 width=187 height=42 align=right>";
} else {
  print "<a href=/cgi-bin/koha/acqui/newbiblio.pl?ordnum=$results[0]->{'ordernumber'}&id=$results[0]->{'booksellerid'}><img src=/images/modify-mem.gif align=right border=0></a>";
}
print <<EOP
<FONT SIZE=6><em>$results[0]->{'ordernumber'} - Receive Order</em></FONT><br>
Shopping Basket For: $booksellers[0]->{'name'}
<br> Order placed: $date
<P>
<CENTER>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width="40%">
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>CATALOGUE DETAILS</B></td></tr>

<TR VALIGN=TOP>
<TD><b>Title *</b></td>
<td><input type=text size=20 name=title value="$results[0]->{'title'}" >
</td>
</tr>
<TR VALIGN=TOP>
<TD>Author</td>
<td><input type=text size=20 name=author value="$results[0]->{'author'}" >
</td>
</tr>
<TR VALIGN=TOP>
<TD>Copyright Date</td>
<td><input type=text size=20 name=copyright value="$results[0]->{'copyrightdate'}" >
</td>
</tr>
<TR VALIGN=TOP>

<TD>Format</td>
<td>
<select name=format size=1>
EOP
;

my $dbh=C4Connect;
my $query="Select itemtype,description from itemtypes order by description";
my $sth=$dbh->prepare($query);
$sth->execute;
while (my $data=$sth->fetchrow_hashref){
  if ($data->{'itemtype'} eq $results[0]->{'itemtype'}) {
    print "<option SELECTED value=\"" . $data->{'itemtype'} . "\">" . $data->{'description'} . "\n";
  } else {
    print "<option value=\"" . $data->{'itemtype'} . "\">" . $data->{'description'} . "\n";
  }
}
$sth->finish;
$dbh->disconnect;

print <<EOP
</select>

</td>
</tr>

<TR VALIGN=TOP>

<TD>ISBN</td>
<td><input type=text size=20 name=ISBN value="$results[0]->{'isbn'}">
</td>
</tr>

<TR VALIGN=TOP>

<TD>Series</td>
<td><input type=text size=20 name=Series value="$results[0]->{'seriestitle'}">
</td>
</tr>

<TR VALIGN=TOP>
<TD>Branch</td>
<td><select name=branch size=1>
EOP
;
my ($count2,@branches)=branches();                                                                         
for (my $i=0;$i<$count2;$i++){                                                                           
  print "<option value=$branches[$i]->{'branchcode'}";                                                   
  if ($results[0]->{'branchcode'} == $branches[$i]->{'branchcode'}){                                           
  print " Selected";                                                                                   
  }                                                                                                      
  print ">$branches[$i]->{'branchname'}";                                                                
}   
print <<EOP
</select>
</td>
</tr>

<TR VALIGN=TOP bgcolor=#ffffcc >
<TD><B>Item Barcode *</B></td>

<td><input type=text size=20 name=barcode value=
EOP
;

my %systemprefs=systemprefs();
if ($systemprefs{'autoBarcode'} eq '1') {
  my $dbh=C4Connect;
  my $query="Select barcode from items order by barcode desc";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  print $data->{'barcode'}+1;
  $sth->finish;
  $dbh->disconnect;
}

print <<EOP
>
</td>
</tr>

<TR VALIGN=TOP bgcolor=#ffffcc >
<TD><B>Volume Info (for serials) *</B></td>

<td><input type=text size=20 name=volinf>
</td>
</tr>
</table>



<img src="/images/holder.gif" width=32 height=250 align=left>

<table border=1 cellspacing=0 cellpadding=5 width="40%">

<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>ACCOUNTING DETAILS</B></td></tr>
<TR VALIGN=TOP>
<TD><B>Bookfund *</B></td>
<td><select name=bookfund size=1>
EOP
;
my @bookfund;
($count2,@bookfund)=bookfunds();                                                    
for (my $i=0;$i<$count2;$i++){                                                       
  print "<option value=$bookfund[$i]->{'bookfundid'}";
  if ($bookfund[$i]->{'bookfundid'}==$results[0]->{'bookfundid'}){
    print " Selected";
  }
  print ">$bookfund[$i]->{'bookfundname'}";
}      

my $rrp=$results[0]->{'rrp'};
if ($results[0]->{'quantityreceived'} == 0){
  $results[0]->{'quantityreceived'}='';
}
if ($results[0]->{'unitprice'} == 0){
  $results[0]->{'unitprice'}='';
}
print <<EOP
</select>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Quantity Ordered</td>
<td><input type=text size=20 name=quantity value=$results[0]->{'quantity'}>
</td>
</tr>
<TR VALIGN=TOP bgcolor=#ffffcc>
<TD><B>Quantity Received *</B></td>
<td><input type=text size=20 name=quantityrec value=$results[0]->{'quantityreceived'}>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Replacement Cost</td>
<td><input type=text size=20 name=rrp value=$rrp>
</tr>
<TR VALIGN=TOP>
<TD>
Budgeted Cost </td>
<td><input type=text size=20 name=ecost value="$results[0]->{'ecost'}">
</td>
</tr>
<TR VALIGN=TOP bgcolor=#ffffcc>
<TD><B>Actual Cost *</B></td>
<td><input type=text size=20 name=cost value="$results[0]->{'unitprice'}">
</td>
</tr>
<TR VALIGN=TOP bgcolor=#ffffcc>
<TD>Invoice Number</td>
<td>$invoice
<input type=hidden name=invoice value="$invoice">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Notes</td>
<td><input type=text size=20 name=notes value="$results[0]->{'notes'}">
</td>
</tr>
</table>
</form>
</center>
<br clear=all>		
<p> &nbsp; </p>

EOP
;
} else {
print "<center><table>";
print <<EOP
<tr valign=top bgcolor=#99cc33>                                                                

<td background="/images/background-mem.gif"><b>ISBN</b></td>                                   
<td background="/images/background-mem.gif"><b>TITLE</b></td>                                  
<td background="/images/background-mem.gif"><b>AUTHOR</b></td>                                 
</tr>
EOP
;
for (my $i=0;$i<$count;$i++){
  print "<tr><td>$results[$i]->{'isbn'}</td>
  <td><a href=acquire.pl?recieve=$results[$i]->{'ordernumber'}&biblio=$results[$i]->{'biblionumber'}&invoice=$invoice&freight=$freight&gst=$gst>$results[$i]->{'title'}</a></td>
  <td>$results[$i]->{'author'}</td></tr>";
}
print "</table></center>";
}



print endmenu('acquisitions');

print endpage;
