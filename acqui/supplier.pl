#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
use strict;

my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my ($count,@booksellers)=bookseller($id); 
print startpage;

print startmenu('acquisitions');

print <<EOP
<form action=updatesupplier.pl method=post>

<input type=hidden name=id value=$id>
<FONT SIZE=6><em>Update: $booksellers[0]->{'name'}</em></FONT>
<P>
<CENTER>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width="40%">
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>COMPANY DETAILS</B></td></tr>
<TR VALIGN=TOP>
<TD><b>Company Name</b></td>
<td><input type=text size=20 name=company value="$booksellers[0]->{'name'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Postal Address</td>
<td><textarea name=company_postal cols=20 rows=3>$booksellers[0]->{'postal'}
</textarea></td>
</tr>
<TR VALIGN=TOP>
<TD>Physical Address</td>
<td><textarea name=physical cols=20 rows=4>$booksellers[0]->{'address1'}
$booksellers[0]->{'address2'}
$booksellers[0]->{'address3'}
$booksellers[0]->{'address4'}
</textarea>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Phone</td>
<td><input type=text size=20 name=company_phone value="$booksellers[0]->{'phone'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Fax</td>
<td><input type=text size=20 name=company_fax value="$booksellers[0]->{'fax'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Website</td>
<td><input type=text size=20 name=website value="$booksellers[0]->{'url'}">
</td>
</tr>
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>CONTACT DETAILS</B></td></tr>
<TR VALIGN=TOP>
<TD>Contact Name</td>
<td><input type=text size=20 name=company_contact_name value="$booksellers[0]->{'contact'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Position</td>
<td><input type=text size=20 name=company_contact_position value="$booksellers[0]->{'contpos'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Phone</td>
<td><input type=text size=20 name=contact_phone value="$booksellers[0]->{'contphone'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Alternative Phone</td>
<td><input type=text size=20 name=contact_phone_2 value="$booksellers[0]->{'contaltphone'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Fax</td>
<td><input type=text size=20 name=contact_fax value="$booksellers[0]->{'contfax'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>E-mail</td>
<td><input type=text size=20 name=company_email value="$booksellers[0]->{'contemail'}">
</td>
</tr>
<TR VALIGN=TOP>
<TD>Notes</td>
<td><textarea name=notes cols=20 rows=4>$booksellers[0]->{'contnotes'}</textarea>
</td>
</tr>
<tr valign=right><td><input type=image  name=submit src=/images/save-changes.gif border=0 width=187 height=42 align=right></td></tr>
</table>
<img src="/images/holder.gif" width=32 height=250 align=left>

<table border=1 cellspacing=0 cellpadding=5 width="40%">
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>CURRENT STATUS</B></td></tr>
<TR VALIGN=TOP>
<TD>Supplier is</td>
<td><input type=radio name=status value=1
EOP
;
if ($booksellers[0]->{'active'}==1){
  print " checked ";
}
print ">Active
<input type=radio name=status value=0";
if ($booksellers[0]->{'active'}==0){
  print " checked ";
}
print <<EOP
>Inactive
</td>
</tr>
<tr valign=top bgcolor=#99cc33><td background="/images/background-mem.gif" colspan=2><B>ORDERING INFORMATION</B></td></tr>
<TR VALIGN=TOP>
<TD>Publishers and Imprints</td>
<td><textarea name=publishers_imprints cols=20 rows=4>$booksellers[0]->{'specialty'}</textarea>
</td>
</tr>
<TR VALIGN=TOP>
<TD>List Prices are</td>
<td><select name=list_currency size=1>
<option value=NZD
EOP
;
if ($booksellers[0]->{'listprice'} eq 'NZD'){
  print " selected";
}
print ">\$ NZ
<option value=AUD";
if ($booksellers[0]->{'listprice'} eq 'AUD'){
  print " selected";
}
print ">\$ Aus
<option value=USD";
if ($booksellers[0]->{'listprice'} eq 'USD'){
  print " selected";
}
print ">\$ USA
<option value=UKP";
if ($booksellers[0]->{'listprice'} eq 'UKP'){
  print " selected";
}

print <<EOP
>&pound; Sterling
</select>
</td>
</tr>
<TR VALIGN=TOP>
<TD>Invoice Prices are</td>
<td><select name=invoice_currency size=1>
<option value=NZD
EOP
;
if ($booksellers[0]->{'invoiceprice'} eq 'NZD'){
  print " selected";
}
print ">\$ NZ
<option value=AUD";
if ($booksellers[0]->{'invoiceprice'} eq 'AUD'){
  print " selected";
}
print ">\$ Aus
<option value=USD";
if ($booksellers[0]->{'invoiceprice'} eq 'USD'){
  print " selected";
}
print ">\$ USA
<option value=UKP";
if ($booksellers[0]->{'invoiceprice'} eq 'UKP'){
  print " selected";
}
print <<EOP
>&pound; Sterling
</select>
</td>
</tr>
<TR VALIGN=TOP>
<TD>GST Registered</td>
<td><input type=radio name=gst value=1
EOP
;
if ($booksellers[0]->{'gstreg'}==1){
  print " checked";
}
print ">Yes 
<input type=radio name=gst value=0";
if ($booksellers[0]->{'gstreg'}==0){
  print " checked";
}
print <<EOP
>No
</td>
</tr>
<TR VALIGN=TOP>
<TD>List Item Price Includes GST</td>
<td><input type=radio name=list_gst value=1
EOP
;
if ($booksellers[0]->{'listincgst'}==1){
  print " checked";
}
print ">Yes 
<input type=radio name=list_gst value=0";
if ($booksellers[0]->{'listincgst'}==0){
  print " checked";
}
print <<EOP
>No
</td>
</tr>
<TR VALIGN=TOP>
<TD>Invoice Item Price Includes GST</td>
<td><input type=radio name=invoice_gst value=1
EOP
;
if ($booksellers[0]->{'invoiceincgst'}==1){
  print " checked";
}
print ">Yes 
<input type=radio name=invoice_gst value=0";
if ($booksellers[0]->{'invoiceincgst'}==0){
  print " checked";
}
print <<EOP
>No
</td>
</tr>
<TR VALIGN=TOP>				
<TD>Discount</td>
<td><input type=text size=3 name=discount value=$booksellers[0]->{'discount'}> %
</tr>
</table>

</form>
</center>
EOP
;


print endmenu('acquisitions');

print endpage;
