#!/usr/bin/perl

#script to set up screen for modification of borrower details
#written 20/12/99 by chris@katipo.co.nz

use strict;
use C4::Output;
use CGI;
use C4::Search;


my $input = new CGI;
my $member=$input->param('bornum');
if ($member eq ''){
  $member=NewBorrowerNumber();
}
my $type=$input->param('type');

print $input->header;
print startpage();
print startmenu('member');
my $data=borrdata('',$member);
print <<printend
<BLOCKQUOTE>

<FONT SIZE=6><em>Add New Institution</em></FONT><br>
<form action=/cgi-bin/koha/newimember.pl method=post>
<input type=hidden name=joining value="">
<input type=hidden name=expiry value="">
<input type=hidden name=type value="borrowers">
<input type=hidden name=borrowernumber value="$member">
<input type=hidden name=updtype value=I>
<table border=0 cellspacing=0 cellpadding=5 >


<tr valign=top><td ><input type=reset value="Clear all Fields"></td></tr><tr>
<TR align=right><td  COLSPAN=2   ALIGN=RIGHT ><font size=3 face='arial,helvetica'>
<STRONG>Member# $member,   Card Number*</STRONG> </TD><TD align=right><input type=text name=cardnumber_institution size=20 value=" "><br>
</td></TR>
<tr><td>&nbsp; </TD></TR>

<tr valign=top bgcolor="99cc33" ><td  COLSPAN=5 background="/images/background-mem.gif">
<B>INSTITUTION DETAILS</b></td> <td  COLSPAN=2  ALIGN=RIGHT background="/images/background-mem.gif">

</td></tr>
<tr valign=top bgcolor=white>

<td colspan=3><input type=text name=institution_name size=50 value=""></td>
</tr>
<tr valign=top bgcolor=white>

<td><FONT SIZE=2>Institution Name</FONT></td>
</tr>

<tr><td>&nbsp; </TD></TR>
        
	
	<tr valign=top bgcolor="99cc33" ><td  COLSPAN=5 background="/images/background-mem.gif">
	<B>INSTITUTION ADDRESS</b></td></tr>
	<tr valign=top bgcolor=white>
	<td><input type=text name=address size=40 value="">
	<td><input type=text name=city size=20 value=""></td>
	<td>
	<SELECT NAME="area" SIZE="1">
	<OPTION value=L
	
	>L - Levin
	<OPTION value=F>F - Foxton
	<OPTION value=S>S - Shannon
	<OPTION value=H>H - Horowhenua
	<OPTION value=K>K - Kapiti
	<OPTION value=O>O - Out of District
	<OPTION value=X>X - Temporary Visitor
	<OPTION value=Z>Z - Interloan Libraries
	<OPTION value=V>V - Villlage</SELECT></td></tr>
	<tr valign=top bgcolor=white>
	<td ><FONT SIZE=2>Postal Address*</FONT></td>
	<td><FONT SIZE=2>Town*</FONT></td>
	<td><FONT SIZE=2>Area</FONT></td>
	</tr>
	<tr><td>&nbsp; </TD></TR>
	<tr valign=top bgcolor="99cc33"  ><td  COLSPAN=5  background="/images/background-mem.gif">
	<B>CONTACT DETAILS</b></td></tr>
	<tr valign=top bgcolor=white>
	<td   COLSPAN=3 ><input type=text name=contactname size=40 value=""></td>
	</tr>
	
	<tr valign=top bgcolor=white>
	<td   COLSPAN=3 ><FONT SIZE=2>Contact Name*</td></tr>
	
	<tr valign=top bgcolor=white>
	
	<td ><input type=text name=phoneday size=20 value=""></td>
	<td><input type=text name=faxnumber size=20 value=""></td>
	<td ><input type=text name=emailaddress size=20 value=""></td></tr>
	
	<tr valign=top bgcolor=white>
	
	<td><FONT SIZE=2>Phone (day)</td>
	<td><FONT SIZE=2>Fax</td>
	<td><FONT SIZE=2>Email</td></tr>
	<tr><td>&nbsp; </TD></TR>
	
	
	<tr valign=top bgcolor=white>
	
	
	<td  COLSPAN=4><textarea name=altnotes wrap=physical cols=70 rows=3></textarea></td></tr>
	</tr>
	<tr valign=top bgcolor=white>
	<td><FONT SIZE=2>Notes</font></td></tr>
	<tr><td>&nbsp; </TD></TR>
	
	
	<tr valign=top bgcolor="99cc33"  >
	
	<td  COLSPAN=5  background="/images/background-mem.gif"><B>LIBRARY USE</B></td>
	</tr>
	
	
	<tr valign=top >
	
	
	<td  COLSPAN=5><textarea name=borrowernotes wrap=physical cols=70 rows=3></textarea></td></tr>
	<tr><td>&nbsp; </TD></TR>
	<tr valign=top bgcolor=white>
	<td ><FONT SIZE=2>Notes</font></td>
	</tr><tr valign=top bgcolor=white>
	
	
	<td  COLSPAN=5 align=right >
	<input type=image src="/images/save-changes.gif"  WIDTH=188  HEIGHT=44  ALT="Add New Member" border=0 ></td>
	</tr>
	</TABLE>
	</table>
	                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        </form>
																																																														                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
																																																																																																																											                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
																																																																																																																																																																																								
																																																																																																																																																																																								<br clear=all>
																																																																																																																																																																																								
																																																																																																																																																																																								<p> &nbsp; </p>
																																																																																																																																																																																								

printend
;
print endmenu('member');
print endpage();
