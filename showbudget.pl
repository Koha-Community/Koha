#!/usr/bin/perl

#script to show list of budgets and bookfunds
#written 4/2/00 by chris@katipo.co.nz
#called as an include by the acquisitions index page

use C4::Acquisitions;
#use CGI;
#my $inp=new CGI;
#print $inp->header;
my ($count,@results)=bookfunds;

open (FILE,'>/usr/local/www/hdl/htdocs/includes/budgets.inc') || die "Cant open file";
print FILE <<printend

<TABLE  width="40%"  cellspacing=0 cellpadding=5 border=1 >
<FORM ACTION="/cgi-bin/koha/search.pl">
<TR VALIGN=TOP>
<TD  bgcolor="99cc33" background="/images/background-mem.gif" colspan=2><b>BUDGETS AND BOOKFUNDS</b></TD></TR>
<TR VALIGN=TOP>
<TD colspan=2><table>


<tr><td>
<b>Budgets</B></TD> <TD><b>Total</B></TD> <TD><b>Spent</B></TD><TD><b>Comtd</B></TD><TD><b>Avail</B></TD></TR>
printend
;
my $total=0;
my $totspent=0;
my $totcomtd=0;
my $totavail=0;
for (my $i=0;$i<$count;$i++){
  my ($spent,$comtd)=bookfundbreakdown($results[$i]->{'bookfundid'});
  my $avail=$results[$i]->{'budgetamount'}-($spent+$comtd);
  print FILE <<EOP
<tr><td>
$results[$i]->{'bookfundname'} </TD> 
<TD>$results[$i]->{'budgetamount'}</TD> <TD>
EOP
;
printf FILE ("%.2f", $spent);
print FILE "</TD><TD>";
printf FILE ("%.2f",$comtd);
print FILE "</TD><TD>";
printf FILE ("%.2f",$avail);
print FILE "</TD></TR>";
  $total+=$results[$i]->{'budgetamount'};
  $totspent+=$spent;
  $totcomtd+=$comtd;
  $totavail+=$avail;
}

print FILE <<printend
<tr><td colspan=5>
<hr size=1 noshade></TD></TR>

<tr><td>
Total </TD> <TD>$total</TD> <TD>
printend
;
printf FILE ("%.2f",$totspent);
print FILE "</TD><TD>";
printf FILE ("%.2f",$totcomtd);
print FILE "</TD><TD>";
printf FILE ("%.2f",$totavail);
print FILE "</TD></TR>";
print FILE <<printend
</table><br>
Use your reload button [ctrl + r] to get the most recent figures.
Committed figures are approximate only, as exchange rates will affect the amount actually paid.

</TD></TR>
</form>
</table>

printend
;

close FILE;
