#!/usr/bin/perl

#script to modify/delete groups

#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz
# modified 18/4/00 by chris@katipo.co.nz
use strict;

use C4::Search;
use CGI;
use C4::Output;

my $input = new CGI;
#
my $bibitemnum=$input->param('bibitem');
my $data=bibitemdata($bibitemnum);
my $biblio=$input->param('biblio');
my $submit=$input->param('submit.x');
if ($submit eq ''){                                                                                                      
  print $input->redirect("/cgi-bin/koha/delbibitem.pl?bibitemnum=$bibitemnum&biblio=$biblio");                            
}
print $input->header;
#my ($count,$subject)=subject($data->{'biblionumber'});
#my ($count2,$subtitle)=subtitle($data->{'biblionumber'});
#my ($count3,$addauthor)=addauthor($data->{'biblionumber'});

#my ($analytictitle)=analytic($biblionumber,'t');
#my ($analyticauthor)=analytic($biblionumber,'a');
print startpage();
print startmenu();
my %inputs;

#hash is set up with input name being the key then
#the value is a tab separated list, the first item being the input type
#$inputs{'Author'}="text\t$data->{'author'}\t0";
#$inputs{'Title'}="text\t$data->{'title'}\t1";
my $dewey = $data->{'dewey'};                                                      
$dewey =~ s/0+$//;                                                                 
if ($dewey eq "000.") { $dewey = "";};                                             
if ($dewey < 10){$dewey='00'.$dewey;}                                              
if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}                               
if ($dewey <= 0){                                                                  
  $dewey='';                                                                       
} 
$dewey=~ s/\.$//;
$inputs{'Class'}="text\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
$inputs{'Item Type'}="text\t$data->{'itemtype'}\t3";
#$inputs{'Subject'}="textarea\t$sub\t4";
$inputs{'Publisher'}="text\t$data->{'publishercode'}\t5";
#$inputs{'Copyright date'}="text\t$data->{'copyrightdate'}\t6";
$inputs{'ISBN'}="text\t$data->{'isbn'}\t7";
$inputs{'Publication Year'}="text\t$data->{'publicationyear'}\t8";
$inputs{'Pages'}="text\t$data->{'pages'}\t9";
$inputs{'Illustrations'}="text\t$data->{'illustration'}\t10";
#$inputs{'Series Title'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'Additional Author'}="text\t$additional\t12";
#$inputs{'Subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
#$inputs{'Unititle'}="text\t$data->{'unititle'}\t14";
#$inputs{'Notes'}="textarea\t$data->{'notes'}\t15";
#$inputs{'Serial'}="text\t$data->{'serial'}\t16";
$inputs{'Volume'}="text\t$data->{'volumeddesc'}\t17";
#$inputs{'Analytic author'}="text\t\t18";
#$inputs{'Analytic title'}="text\t\t19";

$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";

print <<printend

<BLOCKQUOTE><FONT SIZE=6>
<em><a href=/cgi-bin/koha/detail.pl?bib=$data->{'biblionumber'}&type=intra>$data->{'title'} ($data->{'author'})</a><br>
Modify Group - $data->{'description'}</em></FONT><br>             
<form action=updatebibitem.pl method=post>
<table border=0 cellspacing=0 cellpadding=5 align=left>

<TR VALIGN=TOP  bgcolor="99cc33">
<TD  bgcolor="99cc33" background="/images/background-mem.gif" colspan=2 ><b><input type=radio name=existing value=YES > RE-ASSIGN TO EXISTING GROUP</b></td></tr>

printend
;
my ($count,@bibitems)=bibitems($data->{'biblionumber'});
print "<tr valign=top><td colspan=3><select name=existinggroup>\n";
for (my $i=0;$i<$count;$i++){
  print "<option value=$bibitems[$i]->{'biblioitemnumber'}>$bibitems[$i]->{'description'} - $bibitems[$i]->{'isbn'}\n";
}
print "</select></td></tr>";
print <<printend
<TR VALIGN=TOP  bgcolor="99cc33">
<TD  bgcolor="99cc33" background="/images/background-mem.gif" colspan=2 ><b><input type=radio name=existing value=NO checked >OR MODIFY DETAILS</b></td></tr>



<tr valign=top bgcolor=white><td>Item Type</td><td><input type=text name=Item Type value="$data->{'itemtype'}" size=20></td></tr>

<tr valign=top bgcolor=white><td>Class</td><td><input type=text name=Class value="$data->{'classification'}$dewey$data->{'subclass'}" size=20></td></tr>



<tr valign=top bgcolor=white><td>Publisher</td><td><input type=text name=Publisher value="$data->{'publishercode'}" size=20></td></tr>
<tr valign=top bgcolor=white><td>Place</td><td><input type=text name=Place value="$data->{'place'}" size=20></td></tr>


<tr valign=top bgcolor=white><td>ISBN</td><td><input type=text name=ISBN value="$data->{'isbn'}" size=20></td></tr>

<tr valign=top bgcolor=white><td>Publication Year</td><td><input type=text name=Publication Year value="$data->{'publicationyear'}" size=20></td></tr>

<tr valign=top bgcolor=white><td>Pages</td><td><input type=text name=Pages value="$data->{'pages'}" size=20></td></tr>

<tr valign=top bgcolor=white><td>Illustrations</td><td><input type=text name=Illustrations value="$data->{'illustration'}" size=20></td></tr>

<tr valign=top bgcolor=white><td>Volume</td>
<td><input type=text name=Volume value="$data->{'volumeddesc'}" size=20></td></tr>
<tr valign=top bgcolor=white><td>Notes</td>
<td><input type=text name=Notes value="$data->{'notes'}" size=20></td></tr>
<tr valign=top bgcolor=white><td>Size</td>
<td><input type=text name=Size value="$data->{'size'}" size=20></td></tr>

<input type=hidden name=bibnum value="$data->{'biblionumber'}">

<input type=hidden name=bibitemnum value="$data->{'biblioitemnumber'}">

</table>

<img src="/images/holder.gif" width=16 height=500 align=left>




<TABLE  cellspacing=0 cellpadding=5 border=0 >
printend
;


print <<printend;
<TR VALIGN=TOP  bgcolor="99cc33">
<TD  bgcolor="99cc33" background="/images/background-mem.gif" colspan=5 ><b>CHANGES TO AFFECT THESE BARCODES<br>
Tick ALL barcodes that changes are to apply too. Those left un-ticked will keep the original group record.</td></tr>

<tr valign=top bgcolor=99cc33>
<td background="/images/background-mem.gif">&nbsp;</td>
<td background="/images/background-mem.gif">Barcode</td>
<td background="/images/background-mem.gif">Location</td>
<td background="/images/background-mem.gif">Date Due</td>
<td background="/images/background-mem.gif">Last Seen</td></tr>

printend
;
my (@items)=itemissues($data->{'biblioitemnumber'});                                                                        
#print @items;                                                                                      
my $count=@items;           
for (my $i=0;$i<$count;$i++){
  my @temp=split('-',$items[$i]->{'datelastseen'});                                                      
  $items[$i]->{'datelastseen'}="$temp[2]/$temp[1]/$temp[0]"; 
  print <<printend
<tr valign=top gcolor=#ffffcc>
<td><input type=checkbox name="check_group_$items[$i]->{'barcode'}"></td>
<td><a href="/cgi-bin/koha/moredetail.pl?item=$items[$i]->{'itemnumber'}&bib=$data->{'biblionumber'}&bi=$data->{'biblioitemnumber'}">$items[$i]->{'barcode'}</a></td>
<td>$items[$i]->{'holdingbranch'}</td>
<td></td>
<td>$items[$i]->{'datelastseen'}</td>
</tr>
printend
;
}
print <<printend

</table>
<p>

<input type=image  name=submit src=/images/save-changes.gif border=0 width=187 height=42>


</form>
<p>


<B>HELP:</B> You <b>must</b> click on the appropriate radio button (in the green boxes), and choose to either re-assign the item/s to a record already in the system, or modify this record.  IF your changes only apply to some
 items, tick the appropriate ones and a new group record will be created automatically for them.
 <br clear=all>
 
 <p> &nbsp; </p>
 
 
printend
;


print endmenu();
print endpage();
