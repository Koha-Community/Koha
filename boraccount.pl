#!/usr/bin/perl

#wrriten 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details


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
my $input=new CGI;


my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);


#get account details
my %bor;
$bor{'borrowernumber'}=$bornum;                            
my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);   


  
print $input->header;
print startpage();
print startmenu('member');
print <<printend
<FONT SIZE=6><em>Account for $data->{'firstname'} $data->{'surname'}</em></FONT><P>
<a href=/cgi-bin/koha/maninvoice.pl?bornum=$bornum><image src=/images/create-man-invoice.gif border=0></a>
 &nbsp; <a href=/cgi-bin/koha/mancredit.pl?bornum=$bornum><image src=/images/create-man-credit.gif border=0></a>
<center>
<p>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=2><B>FINES & CHARGES</TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=1><B>AMOUNT</TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=1><B>STILL OWING</TD>
</TR>

printend
;
for (my $i=0;$i<$numaccts;$i++){
  $accts->[$i]{'amount'}+=0.00;
  $accts->[$i]{'amountoutstanding'}+=0.00;
  print <<printend
  <tr VALIGN=TOP  >
  <td>$accts->[$i]{'date'}</td>
  <TD>$accts->[$i]{'description'}
printend
;
  if ($accts->[$i]{'accounttype'} ne 'F' && $accts->[$i]{'accounttype'} ne 'FU'){
     print "$accts->[$i]{'title'}";
  }
  print <<printend
  </td>

  <td>$accts->[$i]{'amount'}</td>
  <TD>$accts->[$i]{'amountoutstanding'}</td>
</tr>
printend
;
}
print <<printend
<tr VALIGN=TOP  >
<TD></td>
<TD colspan=2><b>Total Due</b></td>

<TD><b>$total</b></td>

</tr>
</table>
<br clear=all>
<p> &nbsp; </p>

printend
;
print endmenu('member');
print endpage();

