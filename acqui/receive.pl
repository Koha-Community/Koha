#!/usr/bin/perl

#script to recieve orders
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

use C4::Catalogue;
use C4::Biblio;
use C4::Output;
use CGI;
use strict;

my $input=new CGI;
print $input->header();
my $id=$input->param('id');
my ($count,@booksellers)=bookseller($id);
my $invoice=$input->param('invoice');
my $freight=$input->param('freight');
my $gst=$input->param('gst');
my $user=$input->remote_user;
my $date=localtime(time);
print startpage;

print startmenu('acquisitions');

print <<EOP

<div align=right>
Invoice: $invoice<br>
Received By: $user<br>
$date
</div>
<FONT SIZE=6><em>Receipt Summary For : <a href=whitcoulls.html>$booksellers[0]->{'name'}</a> </em></FONT>
<CENTER>

<FORM ACTION="/cgi-bin/koha/acqui/acquire.pl">
<input type=hidden name=gst value=$gst>
<input type=hidden name=freight value=$freight>
<input type=hidden name=invoice value=$invoice>

<b>Search ISBN or Title:</b> <INPUT TYPE="text"  SIZE="25"   NAME="recieve">
</form>
<p>
<FORM ACTION="" method=post name=orderform>

<table border=0 cellspacing=0 cellpadding=5>
<tr valign=top bgcolor=#99cc33>
<td background="/images/background-mem.gif"><b>BASKET</b></td>
<td background="/images/background-mem.gif"><b>ISBN</b></td>
<td background="/images/background-mem.gif"><b>TITLE</b></td>
<td background="/images/background-mem.gif"><b>AUTHOR</b></td>
<td background="/images/background-mem.gif"><b>ACTUAL</b></td>
<td background="/images/background-mem.gif"><b>P&P</b></td>
<td background="/images/background-mem.gif"><b>QTY</b></td>
<td background="/images/background-mem.gif"><b>TOTAL</b></td></tr>

EOP
;
my @results;
($count,@results)=invoice($invoice);
if ($invoice eq ''){
  ($count,@results)=getallorders($id);
}
print $count;
my $totalprice=0;
my $totalfreight=0;
my $totalquantity=0;
my $total;
my $tototal;
for (my$i=0;$i<$count;$i++){
 $total=($results[$i]->{'unitprice'} + $results[$i]->{'freight'}) * $results[$i]->{'quantityreceived'};
$results[$i]->{'unitprice'}+=0;
print <<EOP
<tr valign=top bgcolor=#ffffcc>
<td>$results[$i]->{'basketno'}</td>
<td>$results[$i]->{'isbn'}</td>
<td><a href="acquire.pl?recieve=$results[$i]->{'ordernumber'}&biblio=$results[$i]->{'biblionumber'}&invoice=$invoice&gst=$gst&freight=$freight">$results[$i]->{'title'}</a></td>
<td>$results[$i]->{'author'}</td>
<td>\$$results[$i]->{'unitprice'}</td>
<td></td>
<td>$results[$i]->{'quantityreceived'}</td>
<td>\$ $total</td>
</tr>
EOP
;
$totalprice+=$results[$i]->{'unitprice'};
$totalfreight+=$results[$i]->{'freight'};
$totalquantity+=$results[$i]->{'quantityreceived'};
$tototal+=$total;
}
$totalfreight=$freight;
$tototal=$tototal+$freight;

my $grandtot=$tototal+$gst;
print <<EOP
<tr valign=top bgcolor=white>
<td colspan=8><hr>
</td></tr>



<tr valign=top bgcolor=white>
<td></td>
<td></td>
<td></td>
<td><b>SUBTOTALS</b></td>
<td>\$$totalprice</td>
<td>$totalfreight</td>
<td>$totalquantity</td>
<td>\$$tototal</td>
</tr>
<tr valign=top bgcolor=white>
<td colspan=5 rowspan=2  bgcolor=#99cc33 background="/images/background-mem.gif">
<b>HELP</b>
<br>
The total at the bottom of the page should be within a few cents of the total for the invoice.<p>
When you have finished this invoice save the changes.
</td>																												                
<td colspan=2 align=right><b>GST</b></td>
<td>\$$gst</td>
</tr>
<tr valign=top bgcolor=white>
<td colspan=2 align=right ><b>TOTAL</b></td>
<td>\$$grandtot</td>
</tr>
<tr valign=top bgcolor=white>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td colspan=3><input type=image  name=submit src=/images/save-changes.gif border=0 width=187 height=42 align=right></td>
</tr>
</table>
</CENTER>
EOP
;


print endmenu('acquisitions');

print endpage;
