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

<FONT SIZE=6><em>Add New Junior Member </em></font><br>
<form action=/cgi-bin/koha/newjmember.pl method=post>
<!--<input type=hidden name=joining value="">
<input type=hidden name=expiry value="">
<input type=hidden name=type value="borrowers">-->
<input type=hidden name=borrowernumber value=$member>
<input type=hidden name=updtype value=I>
<input type=hidden name=area value="$data->{'area'}">
<input type=hidden name=city value="$data->{'city'}">
<input type=hidden name=street value="$data->{'address'}">
<input type=hidden name=streetaddress value="$data->{'streetaddress'}">
<input type=hidden name=streetcity value="$data->{'streetcity'}">
<input type=hidden name=phone value="$data->{'phone'}">
<input type=hidden name=phoneday value="$data->{'phoneday'}">

<input type=hidden name=faxnumber value="$data->{'faxnumber'}">
<input type=hidden name=emailaddress value="$data->{'emailaddress'}">
<input type=hidden name=contactname value="$data->{'contactname'}">
<input type=hidden name=altphone value"$data->{'altphone'}">
<table border=0 cellspacing=0 cellpadding=5 >


<tr valign=top><td  COLSPAN=1><input type=reset value="Clear all Fields"></td></tr>
<tr valign=top bgcolor="99cc33" ><td  COLSPAN=5 background="/images/background-mem.gif">
<tr valign=top bgcolor="99cc33" ><td  COLSPAN=5 background="/images/background-mem.gif">
<B>PARENT OR GUARDIAN </b></td></tr>
<tr valign=top bgcolor=white>
<td><SELECT NAME="title" SIZE="1">
<OPTION value=" ">No Title
<OPTION value=Miss
printend
;                                                                               
if ($data->{'title'} eq 'Miss'){                                                
  print " Selected";                                                            
}                                                                               
print ">Miss                                                                    
<OPTION value=Mrs";                                                             
if ($data->{'title'} eq 'Mrs'){                                                 
  print " Selected";                                                            
}                                                                               
print ">Mrs                                                                     
<OPTION value=Ms";                                                              
if ($data->{'title'} eq 'Ms'){                                                  
  print " Selected";                                                            
}                                                                               
print ">Ms                                                                      
<OPTION value=Mr";                                                              
if ($data->{'title'} eq 'Mr'){                                                  
  print " Selected";                                                            
}                                                                              
print ">Mr                                                                      
<OPTION value=Dr";                                                              
if ($data->{'title'} eq 'Dr'){                                                  
  print " Selected";                                                            
}                                                                               
print ">Dr                                                                      
<OPTION value=Sir";                                                             
if ($data->{'title'} eq 'Sir'){                                                 
  print " Selected";                                                            
}                                                                               
print <<printend                                                                
	    >Sir
</SELECT>
</td>


<td><input type=text name=firstname_guardian size=20 value="$data->{'firstname'}"></td>
<td colspan=2><input type=text name=surname_guardian size=20 value="$data->{'surname'}"></td>
<td><input type=text name=guardian_number size=20 value="$data->{'cardnumber'}"></td></tr>
<tr valign=top bgcolor=white>
<td><FONT SIZE=2>Title</FONT></td>

<td><FONT SIZE=2>Given Names*</FONT></td>
<td colspan=2><FONT SIZE=2>Surname*</FONT></td>
<td><FONT SIZE=2>Membership No.</FONT></td>
</tr>

<tr><td>&nbsp; </TD></TR>

printend
;
my $cmember1=NewBorrowerNumber();
for (my $i=0;$i<3;$i++){
my $cmember=$cmember1+$i;
my $count=$i+1;
print <<printend
<tr valign=top bgcolor="99cc33" ><td COLSPAN=5 background="/images/background-mem.gif">
<B>CHILD $count </b></td></TR>
<tr valign=top></tr>

<TR><td  COLSPAN=4   ALIGN=RIGHT ><font size=3 face='arial,helvetica'>
<STRONG>Member# $cmember,   Card Number*</STRONG> </TD><TD><input type=text name=cardnumber_child_$i size=20 value=""><br>
<input type=hidden name=bornumber_child_$i value=$cmember>
</td></TR>
<tr  bgcolor=white>


<td><input type=text name=firstname_child_$i size=20 value=""></td>
<td><input type=text name=surname_child_$i size=20 value=""></td>
<td>
<input type=text name=dateofbirth_child_$i size=10 value="">
</TD><TD>
 <input type="radio" name="sex_child_$i" value="F">F
 <input type="radio" name="sex_child_$i" value="M">M* </td>
 <TD align=right>  
 <input type=text name=school_child_$i size=20 value="">
 </TD>
 </tr>
 <tr valign=top bgcolor=white>
 <td><FONT SIZE=2>Given Names*</FONT></td>
 <td><FONT SIZE=2>Surname*</FONT></td>
 
 <td><FONT SIZE=2>Date of Birth<BR> (dd/mm/yy)*</FONT></td>
 <td><FONT SIZE=2>&nbsp;</FONT></td>
 <td><FONT SIZE=2>School</FONT></td></tr>
 
 
 
 
 <tr valign=top bgcolor=white>
 
 <td  COLSPAN=5><textarea name=altnotes_child_$i wrap=physical cols=70 rows=3></textarea></td></tr><tr valign=top bgcolor=white>
 
 <td><FONT SIZE=2>Notes</font></td>
 </tr>
 <tr><td>&nbsp; </TD></TR>
printend
;
}
print <<printend
   <tr valign=top bgcolor=white><td  COLSPAN=5 align=right >
   <input type=image src="/images/save-changes.gif"  WIDTH=188  HEIGHT=44  ALT="Add New Member" border=0 ></td>
   </tr>
   </TABLE>
   </table>
   

printend
;
print endmenu('member');
print endpage();
