#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000


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
use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use C4::Search;

my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my $title=$input->param('title');
my $author=$input->param('author');
my $copyright=$input->param('copyright');
my ($count,@booksellers)=bookseller($id);
my $ordnum=$input->param('ordnum');
my $biblio=$input->param('biblio');
my $data;
my $new;
if ($ordnum eq ''){
  $new='yes';
  $ordnum=newordernum;
  if ($biblio) {
  		$data=bibdata($biblio);
	}
  if ($data->{'title'} eq ''){
    $data->{'title'}=$title;
    $data->{'author'}=$author;
    $data->{'copyrightdate'}=$copyright;
  }
}else {
  $data=getsingleorder($ordnum);
  $biblio=$data->{'biblionumber'};
}

print startpage;

print startmenu('acquisitions');


my $basket=$input->param('basket');
print <<printend


<script language="javascript" type="text/javascript">

<!--

function update(f){
  //collect values
  quantity=f.quantity.value
  discount=f.discount.value
  listinc=parseInt(f.listinc.value)
  currency=f.currency.value
  applygst=parseInt(f.applygst.value)
  listprice=f.list_price.value
  //  rrp=f.rrp.value
  //  ecost=f.ecost.value  //budgetted cost
  //  GST=f.GST.value
  //  total=f.total.value
  //make useful constants out of the above
  exchangerate=f.elements[currency].value      //get exchange rate
  gst_on=(!listinc && applygst);
  //do real stuff
  rrp=listprice*exchangerate;
  ecost=rrp*(100-discount)/100
  GST=0;
  if (gst_on){
    rrp=rrp*1.125;
    GST=ecost*0.125
  }

  total=(ecost+GST)*quantity


  f.rrp.value=display(rrp)
  f.ecost.value=display(ecost)
  f.GST.value=display(GST)
  f.total.value=display(total)

}



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
<form action=/cgi-bin/koha/acqui/addorder.pl method=post name=frusin>
printend
;

if ($biblio eq ''){
  print "<input type=hidden name=existing value=no>";
}

print <<printend
<!--$title-->
<input type=hidden name=ordnum value=$ordnum>
<input type=hidden name=basket value=$basket>
<input type=hidden name=supplier value=$id>
<input type=hidden name=biblio value=$biblio>
<input type=hidden name=bibitemnum value=$data->{'biblioitemnumber'}>
<input type=hidden name=oldtype value=$data->{'itemtype'}>
<input type=hidden name=discount value=$booksellers[0]->{'discount'}>
<input type=hidden name=listinc value=$booksellers[0]->{'listincgst'}>
<input type=hidden name=currency value=$booksellers[0]->{'listprice'}>
<input type=hidden name=applygst value=$booksellers[0]->{'gstreg'}>
printend
;
my ($count2,$currencies)=getcurrencies;
for (my $i=0;$i<$count2;$i++){
  print "<input type=hidden name=\"$currencies->[$i]->{'currency'}\" value=$currencies->[0]->{'rate'}>\n";
}
if ($new ne 'yes'){
  print "<input type=hidden name=orderexists value=yes>\n";
}
print <<printend
<a href=basket.pl?basket=$basket><img src=/images/view-basket.gif width=187 heigth=42 border=0 align=right alt="View Basket"></a>
<FONT SIZE=6><em>$ordnum - Order Details </em></FONT><br>
Shopping Basket For: $booksellers[0]->{'name'}
<P>
<CENTER>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width="40%">
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>CATALOGUE DETAILS</B></td></tr>
<TR VALIGN=TOP>
<TD><b>Title *</b></td>
<td><input type=text size=20 name=title value="$data->{'title'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Author</td>
<td><input type=text size=20 name=author value="$data->{'author'}" >
</td>
</tr>
<TR VALIGN=TOP>
<TD>Copyright Date</td>
<td><input type=text size=20 name=copyright value="$data->{'copyrightdate'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Format</td>
<td>
<select name=format size=1>
printend
;

my $dbh = C4::Context->dbh;
my $query="Select itemtype,description from itemtypes order by description";
my $sth=$dbh->prepare($query);
$sth->execute;
print "<option value=\"\">Please choose:\n";
while (my $data2=$sth->fetchrow_hashref){
	if ($data2->{'itemtype'} eq $data->{'itemtype'}) {
  		print "<option value=\"" . $data2->{'itemtype'} . "\" SELECTED>" . $data2->{'description'} . "\n";
	} else {
  		print "<option value=\"" . $data2->{'itemtype'} . "\">" . $data2->{'description'} . "\n";
	}
}
$sth->finish;

print <<printend
</select>


</td>
</tr>
<TR VALIGN=TOP>
<TD>ISBN</td>
<td><input type=text size=20 name=ISBN value=$data->{'isbn'}>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Series</td>
<td><input type=text size=20 name=Series value="$data->{'seriestitle'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Branch</td>
<td><select name=branch size=1>
printend
;
my @branches;
($count2,@branches)=branches();
for (my $i=0;$i<$count2;$i++){
  print "<option value=$branches[$i]->{'branchcode'}";
  if ($data->{'branchcode'} == $branches[$i]->{'branchcode'}){
    print " Selected";
  }
  print ">$branches[$i]->{'branchname'}";
}

print <<printend
</select>
</td>
</tr>
<TR VALIGN=TOP  bgcolor=#ffffcc>
<TD >Item Barcode</td>
<td><input type=text size=20 name=barcode value=
printend
;

my $auto_barcode = C4::Context->boolean_preference("autoBarcode") || 0;
	# See whether barcodes should be automatically allocated.
	# Defaults to 0, meaning "no".
if ($auto_barcode eq '1') {
  my $dbh = C4::Context->dbh;
  my $query="Select barcode from items order by barcode desc";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  print $data->{'barcode'}+1;
  $sth->finish;
}

print <<printend
>
</td>
</tr>
</table>
<img src="/images/holder.gif" width=32 height=250 align=left>
<table border=1 cellspacing=0 cellpadding=5 width="40%">
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>ACCOUNTING DETAILS</B></td></tr>
<TR VALIGN=TOP>
<TD>Quantity</td>
<td><input type=text size=20 name=quantity value="$data->{'quantity'}" onchange='update(this.form)' >
</td>
</tr>
<TR VALIGN=TOP>
<TD>Bookfund</td>
<td><select name=bookfund size=1>
printend
;

my @bookfund;
($count2,@bookfund)=bookfunds();
for (my $i=0;$i<$count2;$i++){
  print "<option value=$bookfund[$i]->{'bookfundid'}";
  if ($data->{'bookfundid'} == $bookfund[$i]->{'bookfundid'}){
    print " Selected";
  }
  print ">$bookfund[$i]->{'bookfundname'}";
}

print <<printend
</select>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Suppliers List Price</td>
<td><input type=text size=20 name=list_price value="$data->{'listprice'}" onchange='update(this.form)'>
</tr>
<TR VALIGN=TOP>
<TD>Replacement Cost <br>
<FONT SIZE=2>(NZ\$ inc GST)</td>
<td><input type=text size=20 name=rrp value="$data->{'rrp'}" onchange='update(this.form)'>
</tr>
<TR VALIGN=TOP>
<TD>
Budgeted Cost<BR>
<FONT SIZE=2>(NZ\$ ex GST, inc discount)</FONT> </td>
<td><input type=text size=20 name=ecost value="$data->{'ecost'}" onchange='update(this.form)'>
</td>
</tr>
<TR VALIGN=TOP>
<TD>
Budgeted GST</td>
<td><input type=text size=20 name=GST value="" onchange='update(this.form)'>
</td>
</tr>
<TR VALIGN=TOP>
<TD><B>
BUDGETED TOTAL</B></td>
<td><input type=text size=20 name=total value="" onchange='update(this.form)'>
</td>
</tr>
<TR VALIGN=TOP  bgcolor=#ffffcc>
<TD>Actual Cost</td>
<td><input type=text size=20 name=cost>
</td>
</tr>
<TR VALIGN=TOP  bgcolor=#ffffcc>
<TD>Invoice Number *</td>
<td><input type=text size=20 name=invoice >
<TR VALIGN=TOP>
<TD>Notes</td>
<td><input type=text size=20 name=notes value="$data->{'notes'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD colspan=2>
<input type=image  name=submit src=/images/add-order.gif border=0 width=187 height=42 align=right>
</td>
</tr>
</table>
</form>
</center>
<table>
<tr><td bgcolor=#cccc99  background="/images/background-mem.gif"><B>HELP</B><br>
<UL>
<LI>If ordering more than one copy of an item you will be prompted to  choose additional bookfunds, and put in additional barcodes at the next screen<P>
<LI><B>Bold</B> fields must be filled in to create a new bibilo and item.<p>
<LI>Shaded fields can be used to do a "quick" receive, when items have been purchased locally or gifted. In this case the quantity "ordered" will also  be entered into the database as the quantity received.
</UL>
</td></tr></table>
<p> &nbsp; </p>
printend
;

print endmenu('acquisitions');

print endpage;
