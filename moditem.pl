#!/usr/bin/perl

#script to modify/delete biblios
#written 8/11/99
# modified 11/11/99 by chris@katipo.co.nz

use strict;

use C4::Search;
use CGI;
use C4::Output;
use C4::Acquisitions;

my $input = new CGI;
my $submit=$input->param('delete.x');
my $itemnum=$input->param('item');
my $bibitemnum=$input->param('bibitem');
if ($submit ne ''){
  print $input->redirect("/cgi-bin/koha/delitem.pl?itemnum=$itemnum&bibitemnum=$bibitemnum");
}

print $input->header;
#print $input->dump;

my $data=bibitemdata($bibitemnum);

my $item=itemnodata('blah','',$itemnum);
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
$inputs{'Barcode'}="text\t$item->{'barcode'}\t0";
$inputs{'Class'}="hidden\t$data->{'classification'}$dewey$data->{'subclass'}\t2";
#$inputs{'Item Type'}="text\t$data->{'itemtype'}\t3";
#$inputs{'Subject'}="textarea\t$sub\t4";
$inputs{'Publisher'}="hidden\t$data->{'publishercode'}\t5";
#$inputs{'Copyright date'}="text\t$data->{'copyrightdate'}\t6";
$inputs{'ISBN'}="hidden\t$data->{'isbn'}\t7";
$inputs{'Publication Year'}="hidden\t$data->{'publicationyear'}\t8";
$inputs{'Pages'}="hidden\t$data->{'pages'}\t9";
$inputs{'Illustrations'}="hidden\t$data->{'illustration'}\t10";
#$inputs{'Series Title'}="text\t$data->{'seriestitle'}\t11";
#$inputs{'Additional Author'}="text\t$additional\t12";
#$inputs{'Subtitle'}="text\t$subtitle->[0]->{'subtitle'}\t13";
#$inputs{'Unititle'}="text\t$data->{'unititle'}\t14";
$inputs{'ItemNotes'}="textarea\t$item->{'itemnotes'}\t15";
#$inputs{'Serial'}="text\t$data->{'serial'}\t16";
$inputs{'Volume'}="hidden\t$data->{'volumeddesc'}\t17";
$inputs{'Home Branch'}="text\t$item->{'homebranch'}\t18";
$inputs{'Lost'}="radio\t$item->{'itemlost'}\t19";
#$inputs{'Analytic author'}="text\t\t18";
#$inputs{'Analytic title'}="text\t\t19";

$inputs{'bibnum'}="hidden\t$data->{'biblionumber'}\t20";
$inputs{'bibitemnum'}="hidden\t$data->{'biblioitemnumber'}\t21";
$inputs{'itemnumber'}="hidden\t$itemnum\t22";



print <<printend
<FONT SIZE=6><em>$data->{'title'} ($data->{'author'})</em></FONT><br>
<table border=0 cellspacing=0 cellpadding=5>
<tr valign=top bgcolor=white><td><form action=updateitem.pl method=post>
<table border=0 cellspacing=0 cellpadding=5>
<tr valign=top bgcolor=white><td>Barcode</td><td><input type=text name=Barcode value="$item->{'barcode'}" size=40></td></tr>
<input type=hidden name=Class value="$data->{'classification'}$dewey$data->{'subclass'}">
<input type=hidden name=Publisher value="$data->{'publisher'}">
<input type=hidden name=ISBN value="$data->{'isbn'}">
<input type=hidden name=Publication Year value="$data->{'publicationyear'}">
<input type=hidden name=Pages value="$data->{'pages'}">
<input type=hidden name=Illustrations value="$data->{'illustration'}">
<tr valign=top bgcolor=white><td>ItemNotes</td><td><textarea name=ItemNotes cols=40 rows=4>$item->{'itemnotes'}</textarea></td></tr>
<input type=hidden name=Volume value="$data->{'volumeddesc'}">
<tr valign=top bgcolor=white><td>Home Branch</td><td><input type=text name=Home Branch value="$item->{'homebranch'}" size=40></td></tr>
<tr valign=top bgcolor=white><td>Lost</td><td><input type=radio name=Lost value=1
printend
;
if ($item->{'itemlost'} ==1){
  print " checked ";
}
print <<printend
>Yes
<input type=radio name=Lost value=0
printend
;
if ($item->{'itemlost'} ==0){
  print " checked ";
}
print <<printend
>No</td></tr>
<tr valign=top bgcolor=white><td>Cancelled</td><td><input type=radio name=withdrawn value=1
printend
;
if ($item->{'wthdrawn'} ==1){
  print " checked ";
}
print <<printend
>Yes
<input type=radio name=withdrawn value=0
printend
;
if ($item->{'wthdrawn'} ==0){
  print " checked ";
}
print <<printend
>No</td></tr>
<input type=hidden name=bibnum value="$data->{'biblionumber'}">	
<input type=hidden name=bibitemnum value="$data->{'biblioitemnumber'}">
<input type=hidden name=itemnumber value="$itemnum">
<tr valign=top bgcolor=white><td></td><td>

<input type=image  name=submit src=/images/save-changes.gif border=0 width=187 
height=42></td></tr>
</table>
</form></td></tr>
</table>
	
printend
;





print endmenu();
print endpage();
