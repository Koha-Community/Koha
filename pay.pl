#!/usr/bin/perl

#wrriten 11/1/2000 by chris@katipo.oc.nz
#part of the koha library system, script to facilitate paying off fines

use strict;
use C4::Output;
use CGI;
use C4::Search;
use C4::Accounts2;
my $input=new CGI;


my $bornum=$input->param('bornum');
if ($bornum eq ''){
  $bornum=$input->param('bornum0');
}
#get borrower details
my $data=borrdata('',$bornum);
my $user=$input->remote_user;

#get account details
my %bor;
$bor{'borrowernumber'}=$bornum;                            


my @names=$input->param;
my %inp;
my $check=0;
for (my $i=0;$i<@names;$i++){
  my$temp=$input->param($names[$i]);
  if ($temp eq 'wo'){
    $inp{$names[$i]}=$temp;
    $check=1;
  }
  if ($temp eq 'yes'){
    my $amount=$input->param($names[$i+4]);
    my $bornum=$input->param($names[$i+5]);
    my $accountno=$input->param($names[$i+6]);
    makepayment($bornum,$accountno,$amount,$user);
    $check=2;
  }
}
my %env;
my $total=$input->param('total');
if ($check ==0){
  if ($total ne ''){
    recordpayment(\%env,$bornum,$total);
  }
my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);     
print $input->header;
print startpage();
print startmenu('member');
print <<printend
<FONT SIZE=6><em>Pay Fines for $data->{'firstname'} $data->{'surname'}</em></FONT><P>
<center>
<p>
<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 >
<TR VALIGN=TOP>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=4><B>FINES & CHARGES</TD>
<td  bgcolor="99cc33" background="/images/background-mem.gif" colspan=4><B>AMOUNT OWING</TD>
</TR>
<form action=/cgi-bin/koha/pay.pl method=post>
<input type=hidden name=bornum value=$bornum>
printend
;
for (my $i=0;$i<$numaccts;$i++){
if ($accts->[$i]{'amountoutstanding'} > 0){
$accts->[$i]{'amount'}+=0.00;
$accts->[$i]{'amountoutstanding'}+=0.00;
print <<printend
<tr VALIGN=TOP  >
<TD><input type=radio name=payfine$i value=no checked>Unpaid
<input type=radio name=payfine$i value=yes>Pay
<input type=radio name=payfine$i value=wo>Writeoff
<input type=hidden name=itemnumber$i value=$accts->[$i]{'itemnumber'}>
<input type=hidden name=accounttype$i value=$accts->[$i]{'accounttype'}>
<input type=hidden name=amount$i value=$accts->[$i]{'amount'}>
<input type=hidden name=out$i value=$accts->[$i]{'amountoutstanding'}>
<input type=hidden name=bornum$i value=$bornum>
<input type=hidden name=accountno$i value=$accts->[$i]{'accountno'}>
</td>
<TD>$accts->[$i]{'description'} $accts->[$i]{'title'}</td>
<TD>$accts->[$i]{'accounttype'}</td>
<td>$accts->[$i]{'amount'}</td>
<TD>$accts->[$i]{'amountoutstanding'}</td>

</tr>
printend
;
}
}
print <<printend
<tr VALIGN=TOP  >
<TD></td>
<TD colspan=2><b>Total Due</b></td>

<TD><b>$total</b></td>

</tr>



<tr VALIGN=TOP  >
<TD></td>
<TD colspan=3><b>AMOUNT PAID</b></td>
<TD><input type=text name=total value="" SIZE=7></td>
</tr>
<tr VALIGN=TOP  >
<TD colspan=5 align=right>
<INPUT TYPE="image" name="submit"  VALUE="pay" height=42  WIDTH=187 BORDER=0 src="/images/pay-fines.gif"></td>
</tr>
</form>
</table>






<br clear=all>
<p> &nbsp; </p>

printend
;
print endmenu('member');
print endpage();

} else {
  my $quety=$input->query_string;
  print $input->redirect("/cgi-bin/koha/sec/writeoff.pl?$quety");
}
