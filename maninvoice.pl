#!/usr/bin/perl

#wrriten 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details

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
#  print $input->header;
  my $itemnum=$input->param('itemnum');
  my $desc=$input->param('desc');
  my $amount=$input->param('amount');
  my $type=$input->param('type');
  manualinvoice($bornum,$itemnum,$desc,$type,$amount);
  print $input->redirect("/cgi-bin/koha/moremember.pl?bornum=$bornum");
} else {
  print $input->header;
  print startpage();
  print startmenu('member');
print <<printend
<Center><h3>Manual Invoice</h3></center>
<form action=/cgi-bin/koha/maninvoice.pl method=post>
<table cellpadding=2 cellspacing=0 border=0>
<input type=hidden name=bornum value=$bornum>
<tr><td><b>Borrowernumber<b></td><td>$bornum</td></tr>
<!--<tr><td><b>Cardnumber<b></td><td></td></tr>-->
<tr><td><b>Type</b></td><Td>
<select name=type>
<option value=L>Lost Item</option>
<option value=F>Fine</option>
<option value=A>Account Management Fee</option>
<option value=N>New Card</option>
<option value=M>Sundry</option>
<option value=REF>Cash Refund</option>
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
