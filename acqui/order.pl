#!/usr/bin/perl

#script to show suppliers and orders
#written by chris@katipo.co.nz 23/2/2000

use C4::Acquisitions;
use C4::Output;
use CGI;
use strict;

my $input=new CGI;
print $input->header();
my $supplier=$input->param('supplier');
print startpage;

print startmenu('acquisitions');
my ($count,@suppliers)=bookseller($supplier);

print <<printend
<FONT SIZE=6><em>Supplier Search Results</em></FONT>
<div align=right>
<a href=supplier.pl?id=0><img  alt="Add New Supplier" src="/images/new-supplier.gif"  WIDTH=187  HEIGHT=42 BORDER=0 border=0></a>
</div>
<CENTER>
You searched on <b>supplier $supplier,</b> $count results found<p>
<table border=0 cellspacing=0 cellpadding=5>
<tr valign=top bgcolor=#99cc33>
<td background="/images/background-mem.gif">&nbsp;</td>
<td background="/images/background-mem.gif"><b>COMPANY</b></td>
<td background="/images/background-mem.gif"><b>BASKETS</b></td><td background="/images/background-mem.gif"><b>ITEMS</b></td><td background="/images/background-mem.gif"><b>STAFF</b></td><td background="/images/background-mem.gif"><b>DATE</b></td></tr>
printend
;
my $colour='#ffffcc';
my $toggle=0;
for (my $i=0; $i<$count; $i++) {
 if ($toggle==0){
   $colour='#ffffcc';
   $toggle=1;
 } else {
   $colour='white';
   $toggle=0;
 }
 my ($ordcount,$orders)=getorders($suppliers[$i]->{'id'});
# print $ordcount;
 print <<printend
 <tr valign=top bgcolor=$colour>
 <td><a href="newbasket.pl?id=$suppliers[$i]->{'id'}"><img src="/images/new-basket-short.gif" alt="New Basket" width=77 height=32 border=0 ></a> 
 <a href="recieveorder.pl?id=$suppliers[$i]->{'id'}"><img src="/images/receive-order-short.gif" alt="Receive Order" width=77 height=32 border=0 ></a></td>
 <td><a href="supplier.pl?id=$suppliers[$i]->{'id'}">$suppliers[$i]->{'name'}</a></td>
 <td><a href="/cgi-bin/koha/acqui/basket.pl?basket=$orders->[0]->{'basketno'}">HLT-$orders->[0]->{'basketno'}</a></td>
 <td>$orders->[0]->{'count(*)'}</td>
 <td>$orders->[0]->{'authorisedby'}</td>
 <td>$orders->[0]->{'entrydate'}</td></tr>
printend
;
 for (my $i2=1;$i2<$ordcount;$i2++){
   print <<printend
   <tr valign=top bgcolor=$colour>
   <td> &nbsp; </td>
   <td> &nbsp; </td>
   <td><a href="/cgi-bin/koha/acqui/basket.pl?basket=$orders->[$i2]->{'basketno'}">HLT-$orders->[$i2]->{'basketno'}</a></td>
   <td>$orders->[$i2]->{'count(*)'}</td><td>$orders->[$i2]->{'authorisedby'} &nbsp; </td>
   <td>$orders->[$i2]->{'entrydate'}</td></tr>
   
printend
;
 }
}

print <<printend
</table>

</CENTER>
printend
;

print endmenu('acquisitions');

print endpage;
