#!/usr/bin/perl

#script to display detailed information
#written 8/11/99

use strict;
#use DBI;
use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
print $input->header;
#whether it is called from the opac of the intranet
my $type=$input->param('type');
if ($type eq ''){
  $type='intra';
}
#setup colours
my $main;
my $secondary;
if ($type eq 'opac'){
  $main='#99cccc';
  $secondary='#efe5ef';
} else {
  $main='#cccc99';
  $secondary='#ffffcc';
}
print startpage();
print startmenu($type);
#print $type;
my $blah;
my $bib=$input->param('bib');
my $title=$input->param('title');
if ($type ne 'opac'){
  print "<a href=request.pl?bib=$bib><img height=42  WIDTH=120 BORDER=0 src=\"/images/requests.gif\" align=right border=0></a>";
}


my @items=ItemInfo(\$blah,$bib,$type);
my $dat=bibdata($bib);
my $count=@items;
my ($count3,$addauthor)=addauthor($bib);
my $additional=$addauthor->[0]->{'author'};                                                             
for (my $i=1;$i<$count3;$i++){                                                                          
  $additional=$additional."|".$addauthor->[$i]->{'author'};                                             
}  
my @temp=split('\t',$items[0]);
print mkheadr(3,"$dat->{'title'} ($dat->{'author'}) $temp[4]");
print <<printend

<TABLE  CELLSPACING=0  CELLPADDING=5 border=1 align=left width="220">

<!-----------------BIBLIO RECORD TABLE--------->


<form action=/cgi-bin/koha/modbib.pl method=post>
<input type=hidden name=bibnum value=$bib>
<TR VALIGN=TOP>

<td  bgcolor="$main" 
printend
;
if ($type ne 'opac'){
 print "background=\"/images/background-mem.gif\"";
}
print <<printend
><B>BIBLIO RECORD 
printend
;
if ($type ne 'opac'){
  print "$bib";
}
print <<printend
</TD></TR>


<tr VALIGN=TOP  >
<TD>
printend
;
if ($type ne 'opac'){
  print "<INPUT TYPE=\"image\" name=\"submit\"  VALUE=\"modify\" height=42  WIDTH=93 BORDER=0 src=\"/images/modify-mem.gif\"> 
  <INPUT TYPE=\"image\" name=\"delete\"  VALUE=\"delete\" height=42  WIDTH=93 BORDER=0 src=\"/images/delete-mem.gif\">";
}
print <<printend
<br>
<FONT SIZE=2  face="arial, helvetica">
printend
;


if ($type ne 'opac'){
print <<printend
<b>Subtitle:</b> $dat->{'subtitle'}<br>
<b>Author:</b> $dat->{'author'}<br>
<b>Additional Author:</b> $additional<br>
<b>Series Title:</b> $dat->{'seriestitle'}<br>
<b>Subject:</b> $dat->{'subject'}<br>
<b>Copyright:</b> $dat->{'copyrightdate'}<br>
<b>Notes:</b> $dat->{'notes'}<br>
<b>Unititle:</b> $dat->{'unititle'}<br>
<b>Analytical Author:</b> <br>
<b>Analytical Title:</b> <br>
<b>Serial:</b> $dat->{'serial'}<br>
<b>Total Number of Items:</b> $count
<p>
printend
;
}
else {
if ($dat->{'subtitle'} ne ''){
  print "<b>Subtitle:</b> $dat->{'subtitle'}<br>";
}
if ($dat->{'author'} ne ''){
  print "<b>Author:</b> $dat->{'author'}<br>";
}
#Additional Author: <br>
if ($dat->{'seriestitle'} ne ''){
  print "<b>Seriestitle:</b> $dat->{'seriestitle'}<br>";
}
if ($dat->{'subject'} ne ''){
  print "<b>Subject:</b> $dat->{'subject'}<br>";
}
if ($dat->{'copyrightdate'} ne ''){
  print "<b>Copyright:</b> $dat->{'copyrightdate'}<br>";
}
if ($dat->{'notes'} ne ''){
  print "<b>Notes:</b> $dat->{'notes'}<br>";
}
if ($dat->{'unititle'} ne ''){
  print "<b>Unititle:</b> $dat->{'unititle'}<br>";
}
#Analytical Author: <br>
#Analytical Title: <br>
if ($dat->{'serial'} ne '0'){
 print "<b>Serial:</b> Yes<br>";
}
print "<b>Total Number of Items:</b> $count
<p>
";

}
print <<printend
</form>
</font></TD>
</TR>

</TABLE>
<img src="/images/holder.gif" width=16 height=300 align=left>

printend
;


#print @items;

my $i=0;
print center();
print mktablehdr;
if ($type eq 'opac'){

  print mktablerow(6,$main,'Item Type','Class','Branch','Date Due','Last Seen'); 
} else {
  print mktablerow(6,$main,'Itemtype','Class','Location','Date Due','Last Seen','Barcode',"/images/background-mem.gif"); 
}
my $colour=1;
while ($i < $count){
#  print $items[$i],"<br>";
  my @results=split('\t',$items[$i]);
  if ($type ne 'opac'){
    $results[1]=mklink("/cgi-bin/koha/moredetail.pl?item=$results[5]&bib=$bib&bi=$results[8]",$results[1]);
  }
  if ($results[2] eq ''){
    $results[2]='Available';
  }
  if ($colour == 1){
    if ($type ne 'opac'){
#      if ($results[6] eq 'PER'){
        print mktablerow(7,$secondary,$results[6],$results[4],$results[3],$results[2],$results[7],$results[1],$results[9]);
#      } else {
#            print mktablerow(6,$secondary,$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);
#      }
    } else {
       $results[6]=ItemType($results[6]);
#       if ($results[6] =~ /Periodical/){
          print mktablerow(6,$secondary,$results[6],$results[4],$results[3],$results[2],$results[7],$results[9]);
#	} else {
#         print mktablerow(5,$secondary,$results[6],$results[4],$results[3],$results[2],$results[7]);
#       }       
    } 
    $colour=0;                                                                                
  } else{                                                                                     
    if ($type ne 'opac'){
#      if ($results[6] eq 'PER'){
      print mktablerow(7,'white',$results[6],$results[4],$results[3],$results[2],$results[7],$results[1],$results[9]);                                          
#      }else{
#           print mktablerow(6,'white',$results[6],$results[4],$results[3],$results[2],$results[7],$results[1]);                                          
#      }
    } else {
      $results[6]=ItemType($results[6]);
#       if ($results[6] =~ /Periodical/){
          print mktablerow(6,'white',$results[6],$results[4],$results[3],$results[2],$results[7],$results[9]);
#	} else {
#         print mktablerow(5,'white',$results[6],$results[4],$results[3],$results[2],$results[7]);
#       }       
    }
    $colour=1;                                                                                
  }
   $i++;
}

print mktableft();
print "<p>";
print mktablehdr();
if ($type ne 'opac'){
print <<printend
<TR VALIGN=TOP>
<TD  bgcolor="99cc33" background="/images/background-mem.gif" colspan=2><p><b>HELP</b><br>
<b>Update Biblio for all Items:</b> Click on the <b>Modify</b> button [left] to amend the biblio.  Any changes you make will update the record for <b>all</b> the items listed above. <p>
<b>Updating the Biblio for only ONE or SOME Items:</b> If some of the items listed above need a different biblio, or are on the wrong biblio, you must use the <a href="acquisitions/">acquisitions</a> process to fix this. You will need to "re-order" the items, and delete them from this biblio.<p>

   </TR>
printend
;
}
print mktableft();
print endcenter();
print "<br clear=all>";
print endmenu($type);
print endpage();
