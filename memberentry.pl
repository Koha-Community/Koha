#!/usr/bin/perl

#script to set up screen for modification of borrower details
#written 20/12/99 by chris@katipo.co.nz

use strict;
use C4::Output;
use CGI;
use C4::Search;
use C4::Database;
use C4::Koha;

my $input = new CGI;
my $member=$input->param('bornum');
if ($member eq ''){
  $member=NewBorrowerNumber();
}
my $type=$input->param('type');
my $modify=$input->param('modify.x'); 
my $delete=$input->param('delete.x');
if ($delete){
  print $input->redirect("/cgi-bin/koha/deletemem.pl?member=$member");
} else {
print $input->header;
print startpage();
print startmenu('member');

if ($type ne 'Add'){
  print mkheadr(1,'Update Member Details');
} else {
  print mkheadr(1,'Add New Member');
}
my $data=borrdata('',$member);
print <<printend
<form action=/cgi-bin/koha/newmember.pl method=post>
<input type=hidden name=joining value="$data->{'dateenrolled'}">
<input type=hidden name=expiry value="$data->{'expiry'}">
<input type=hidden name=type value="borrowers">
<input type=hidden name=borrowernumber value="$member">
printend
;
if ($type eq 'Add'){
  print "<input type=hidden name=updtype value=I>";
} else {
  print "<input type=hidden name=updtype value=M>";
}

my $cardnumber=$data->{'cardnumber'};
my %systemprefs=systemprefs();
# FIXME
# This logic should probably be moved out of the presentation code.
# Not tonight though.
#
if ($cardnumber eq '' && $systemprefs{'autoMemberNum'} eq '1') {
  my $dbh=C4Connect;
  my $query="select max(substring(borrowers.cardnumber,2,7)) from borrowers";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $cardnumber=$data->{'max(substring(borrowers.cardnumber,2,7))'};
  $sth->finish;
  $dbh->disconnect;
  # purpose: generate checksum'd member numbers.
  # We'll assume we just got the max value of digits 2-8 of member #'s from the database and our job is to
  # increment that by one, determine the 1st and 9th digits and return the full string.
  my @weightings = (8,4,6,3,5,2,1);
  my $sum;
  my $i = 0;
  if (! $cardnumber) { 			# If DB has no values, start at 1000000
    $cardnumber = 1000000;
  } else {
    $cardnumber = $cardnumber + 1;
  }

  while ($i <8) {			# step from char 1 to 7.
    my $temp1 = $weightings[$i];	# read weightings, left to right, 1 char at a time
    my $temp2 = substr($cardnumber,$i,1);	# sequence left to right, 1 char at a time
#print "$temp2<br>";
    $sum = $sum + ($temp1*$temp2);	# mult each char 1-7 by its corresponding weighting
    $i++;				# increment counter
  }
  my $rem = ($sum%11);			# remainder of sum/11 (eg. 9999999/11, remainder=2)
  if ($rem == 10) {			# if remainder is 10, use X instead
    $rem = "X";
  }  
  $cardnumber="V$cardnumber$rem";
} else {
  $cardnumber=$data->{'cardnumber'};
}

print <<printend

<table border=0 cellspacing=0 cellpadding=5 >


<tr valign=top><td  COLSPAN=2><input type=reset value="Clear all Fields"></td><td  COLSPAN=3   ALIGN=RIGHT ><font size=4 face='arial,helvetica'>
Member# $member,   Card Number* <input type=text name=cardnumber size=10 value="$cardnumber"><br>
</td></tr>


<tr valign=top  ><td  COLSPAN=3 background="/images/background-mem.gif">
<B>MEMBER PERSONAL DETAILS</b></td> <td  COLSPAN=2  ALIGN=RIGHT background="/images/background-mem.gif">
* <input type="radio" name="sex" value="F"
printend
;
if ($data->{'sex'} eq 'F'){
  print " checked";
}
print <<printend
>F  
<input type="radio" name="sex" value="M"
printend
;
if ($data->{'sex'} eq 'M'){
  print " checked";
}
print <<printend
>M
&nbsp; &nbsp;  <B>Date of Birth</B> (dd/mm/yy)
<input type=text name=dateofbirth size=10 value="$data->{'dateofbirth'}">
</td></tr>
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

<td><input type=text name=initials size=5 value="$data->{'initials'}"></td>
<td><input type=text name=firstname size=20 value="$data->{'firstname'}"></td>
<td><input type=text name=surname size=20 value="$data->{'surname'}"></td>
<td><input type=text name=othernames size=20 value="$data->{'othernames'}"></td></tr>
<tr valign=top bgcolor=white>
<td><FONT SIZE=2>Title</FONT></td>
<td><FONT SIZE=2>Initials</FONT></td>
<td><FONT SIZE=2>Given Names*</FONT></td>
<td><FONT SIZE=2>Surname*</FONT></td>
<td><FONT SIZE=2>Prefered Name</FONT></td>
</tr>

<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor=white>
<td colspan=2>
printend
;

my ($categories,$labels)=ethnicitycategories();
print $input->popup_menu(-name=>'ethnicity',
			        -values=>$categories,
			        -default=>$data->{'ethnicity'},
			        -labels=>$labels);
print <<printend
</td>
<td colspan=2><input type=text name=ethnicnotes size=40 ></td>
<td> 
printend
;
($categories,$labels)=borrowercategories();
print $input->popup_menu(-name=>'categorycode',
			        -values=>$categories,
			        -default=>$data->{'categorycode'},
			        -labels=>$labels);



print <<printend

</td>
</tr>																																													
<tr valign=top bgcolor=white>
<td colspan=2><FONT SIZE=2>Ethnicity</FONT></td>
<td colspan=2><FONT SIZE=2>Ethnicity Notes</FONT></td>
<td><FONT SIZE=2>Membership Category*</FONT></td>
</tr>
<tr><td>&nbsp; </TD></TR>

<tr valign=top bgcolor="99cc33" ><td  COLSPAN=5 background="/images/background-mem.gif">
<B>MEMBER ADDRESS</b></td></tr>
<tr valign=top bgcolor=white>
<td  COLSPAN=3><input type=text name=address size=40 value="$data->{'streetaddress'}">
<td><input type=text name=city size=20 value="$data->{'city'}"></td>
<td>
<SELECT NAME="area" SIZE="1">
printend
;

print "
<OPTION value=L";
if ($data->{'area'} eq 'L'){
  print " Selected";
}
print ">L - Levin
<OPTION value=F";
if ($data->{'area'} eq 'F'){
  print " Selected";
}
print ">F - Foxton
<OPTION value=S";
if ($data->{'area'} eq 'S'){
  print " Selected";
}
print ">S - Shannon
<OPTION value=H";
if ($data->{'area'} eq 'H'){
  print " Selected";
}
print ">H - Horowhenua
<OPTION value=K";
if ($data->{'area'} eq 'K'){
  print " Selected";
}
print ">K - Kapiti
<OPTION value=O";
if ($data->{'area'} eq 'O'){
  print " Selected";
}
print ">O - Out of District
<OPTION value=X";
if ($data->{'area'} eq 'X'){
  print " Selected";
}
print ">X - Temporary Visitor
<OPTION value=Z";
if ($data->{'area'} eq 'Z'){
  print " Selected";
}
print ">Z - Interloan Libraries
<OPTION value=V";
if ($data->{'area'} eq 'V'){
  print " Selected";
}
print ">V - Villlage";
print <<printend
</SELECT></td></tr>
<tr valign=top bgcolor=white>
<td  COLSPAN=3><FONT SIZE=2>Postal Address*</FONT></td>
<td><FONT SIZE=2>Town*</FONT></td>
<td><FONT SIZE=2>Area</FONT></td>
</tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor=white>

<td  COLSPAN=3><input type=text name=streetaddress size=40 value="$data->{'physstreet'}"></td>
<td><input type=text name=streetcity size=20 value="$data->{'streetcity'}"></td>
</tr>
</tr>
<tr valign=top bgcolor=white>

<td  COLSPAN=3><FONT SIZE=2>Street Address if different</FONT></td>
<td><FONT SIZE=2>Town</FONT></td>
</tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor="99cc33"  ><td  COLSPAN=5  background="/images/background-mem.gif">
<B>MEMBER CONTACT DETAILS</b></td></tr>


<tr valign=top bgcolor=white>
<td   COLSPAN=2 ><input type=text name=phone size=20 value="$data->{'phone'}"></td>
<td><input type=text name=phoneday size=20 value="$data->{'phoneday'}"></td>
<td><input type=text name=faxnumber size=20 value="$data->{'faxnumber'}"></td>
<td><input type=text name=emailaddress size=20 value="$data->{'emailaddress'}"></td></tr>

<tr valign=top bgcolor=white>
<td   COLSPAN=2 ><FONT SIZE=2>Phone (Home)</td>
<td><FONT SIZE=2>Phone (day)</td>
<td><FONT SIZE=2>Fax</td>
<td><FONT SIZE=2>Email</td></tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor="99cc33"  ><td  COLSPAN=5  background="/images/background-mem.gif">
<B>ALTERNATE CONTACT DETAILS</b> </td></tr>

<tr valign=top bgcolor=white>
<td   COLSPAN=3 ><input type=text name=contactname size=40 value="$data->{'contactname'}"></td>
<td><input type=text name=altphone size=20 value="$data->{'altphone'}"></td>
<td><select name=altrelationship size=1>
<option value="workplace"
printend
;
if ($data->{'altrelationship'} eq 'workplace'){
  print " selected ";
}

print ">Workplace
<option value=\"relative\"";
if ($data->{'altrelationship'} eq 'relative'){
  print " selected ";
}
print ">Relative
<option value=\"friend\"";
if ($data->{'altrelationship'} eq 'workplace'){
  print " selected ";
}
print ">Friend
<option value=\"neighbour\"";
if ($data->{'altrelationship'} eq 'workplace'){
  print " selected ";
}
print <<printend
>Neighbour
</select></td></tr>

<tr valign=top bgcolor=white>
<td   COLSPAN=3 ><FONT SIZE=2>Name*</td>
<td><FONT SIZE=2>Phone</td>
<td><FONT SIZE=2>Relationship*</td></tr>



<tr><td>&nbsp; </TD></TR>


<tr valign=top bgcolor=white>

<td><FONT SIZE=2>Notes</font></td>
<td  COLSPAN=4><textarea name=altnotes wrap=physical cols=70 rows=3>$data->{'altnotes'}</textarea></td></tr>
</tr>


<tr><td>&nbsp; </TD></TR>


<tr valign=top bgcolor="99cc33"  >

<td  COLSPAN=5  background="/images/background-mem.gif"><B>LIBRARY USE</B></td>
</tr>


<tr valign=top >

<td><FONT SIZE=2>Notes</font></td>
<td  COLSPAN=4><textarea name=borrowernotes wrap=physical cols=70 rows=3>$data->{'borrowernotes'}</textarea></td></tr>
<tr><td>&nbsp; </TD></TR>
<tr valign=top bgcolor=white><td  COLSPAN=5 align=right >
printend
;
if ($modify){                                                                                                                                      
  print <<printend                                                                                                                                 
  <tr><td><Font size=2>FLAGS</font></td></tr>                                                                                                        
  <tr><td>Gone No Address</td>                                                                                                                       
  <td><input type=radio name=gna value=1                                                                                                             
printend
;
  if ($data->{'gonenoaddress'} eq '1'){                                                                                                            
    print " checked";                                                                                                                              
  }                                                                                                                                                
  print ">Yes <input type=radio name=gna value=0";                                                                                                   
  if ($data->{'gonenoaddress'} eq '0'){                                                                                                            
    print " checked";                                                                                                                              
  }                                                                                                                                                
  print ">No</td></tr>\n";                                                                                                                         
  print "<tr><td>Lost</td><td><input type=radio name=lost value=1";                                                                                
  if ($data->{'lost'} eq '1'){                                                                                                                     
    print " checked";                                                                                                                              
  }                                                                                                                                                
  print ">Yes<input type=radio name=lost value=0";                                                                                                 
  if ($data->{'lost'} eq '0'){                                                                                                                     
    print " checked";                                                                                                                              
  }                                                                                                                                                
  print ">No</td></tr>\n";                                                                                                                         
  print "<tr><td>Debarred</td><td><input type=radio name=debarred value=1";                                                                        
  if ($data->{'debarred'} eq '1'){                                                                                                                 
    print " checked";                                                                                                                              
  }                                                                                                                                                
  print ">Yes<input type=radio name=debarred value=0";                                                                                             
  if ($data->{'debarred'} eq '0'){                                                                                                                 
    print " checked";                                                                                                                              
  }                                                                                                                                                
  print ">No</td></tr>\n";                                                                                                                         
}                 

if ($type ne 'modify'){
  print <<printend
<tr><td></td><td><input type=image src="/images/save-changes.gif"  WIDTH=188  HEIGHT=44  ALT="Add New Member" border=0 ></td>
printend
;
} else {
print <<printend
<td><td></td><td><input type=image src="/images/save-changes.gif"  WIDTH=188  HEIGHT=44  ALT="Add New Member" border=0 ></td>
printend
;
}
print <<printend
</form>
</tr>
</TABLE>
</table>
																																																													</form>
																																																													
																																																													

printend
;
print endmenu('member');
print endpage();
}
