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
use C4::Accounts2;
my $input=new CGI;


my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);
my $add=$input->param('add');
if ($add){
  my $itemnum=$input->param('itemnum');
  my $desc=$input->param('desc');
  my $amount=$input->param('amount');
  $amount = -$amount;
  my $type=$input->param('type');
  manualinvoice($bornum,$itemnum,$desc,$type,$amount);
  print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$bornum");
} else {
  print $input->header;
  print startpage();
  print startmenu('member');
print <<printend
<Center><h3>Manual Credit</h3></center>
<form action=/cgi-bin/koha/mancredit.pl method=post>
<table cellpadding=2 cellspacing=0 border=0>
<input type=hidden name=bornum value=$bornum>
<tr><td><b>Borrowernumber<b></td><td>$bornum</td></tr>
<!--<tr><td><b>Cardnumber<b></td><td></td></tr>-->
<tr><td><b>Type</b></td><Td>
<select name=type>
<option value=C>Credit</option>
<option value=BAY>Baycorp Adjustment</option>
<option value=WORK>Worked off</option>
</select>
</td></tr>
<tr><td><b>Itemnumber</b></td><td><input type=text name=itemnum></td></tr>
<tr><td><b>Description</b></td><td><input type=text name=desc size=50></td></tr>
<tr><td><b>Amount</b></td><td><input type=text name=amount></td></tr>
<tr><td><input type=submit name=add value=Add></td></tr>
</table>
</form>
printend
;
print endmenu('member');
print endpage();

}
