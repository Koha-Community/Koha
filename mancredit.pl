#!/usr/bin/perl

#wrriten 11/1/2000 by chris@katipo.oc.nz
#script to display borrowers account details

use strict;
use C4::Auth;
use C4::Output;
use CGI;
use C4::Search;
use C4::Accounts2;
my $input=new CGI;

# Authentication script added, superlibrarian set as default requirement

my $flagsrequired;
$flagsrequired->{superlibrarian}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);



my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);
my $add=$input->param('add');
if ($add){
  my $itemnum=$input->param('itemnum');
  my $desc=$input->param('desc');
  my $amount=$input->param('amount');
  $amount=$amount*-1;
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
