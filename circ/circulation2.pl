#!/usr/bin/perl

use strict;
use CGI qw/:standard/;
use C4::Circulation::Circ2;
use C4::Output;
use C4::Print;
use DBI;


# this is a reorganisation of circulation.pl 
# dividing it up into three scripts......
# this will be the first one that chooses branch and printer settings....

my %env;
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

my $query=new CGI;
my $branches=getbranches(\%env);
my $printers=getprinters(\%env);
my $branch=$query->param('branch');
my $printer=$query->param('printer');

($branch) || ($branch=$query->cookie('branch'));
($printer) || ($printer=$query->cookie('printer'));

my $oldbranch;
my $oldprinter;
if ($query->param('selectnewbranchprinter')) {
    $oldbranch=$branch;
    $oldprinter=$printer;
    $branch='';
    $printer='';
}

$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

# set up select options....
my $branchcount=0;
my $printercount=0;
my $branchoptions;
my $printeroptions;
foreach (keys %$branches) {
    (next) unless ($_);
    (next) if (/^TR$/);
    $branchcount++;
    my $selected='';
    ($selected='selected') if ($_ eq $oldbranch);
    $branchoptions.="<option value=$_ $selected>$branches->{$_}->{'branchname'}\n";
}
foreach (keys %$printers) {
    (next) unless ($_);
    $printercount++;
    my $selected='';
    ($selected='selected') if ($_ eq $oldprinter);
    $printeroptions.="<option value=$_ $selected>$printers->{$_}->{'printername'}\n";
}

# if there is only one....

if ($printercount==1) {
    ($printer)=keys %$printers;
}
if ($branchcount==1) {
    ($branch)=keys %$branches;
}

my $branchcookie=$query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
my $printercookie=$query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');


my ($printerform, $branchform);
if ($printercount>1) {
    $printerform=<<"EOF";
<table border=0 cellpadding=5 cellspacing=0 bgcolor='#dddddd' >
<tr><td><select name=printer> $printeroptions </select></td></tr>
</table>
<input type=hidden name=branch value=$printer>
EOF
} else {
    my ($printer) = keys %$printers;
    $printerform=<<"EOF";
<input type=hidden name=printer value=$printer>
EOF
} 

if ($branchcount>1) {
    $branchform=<<"EOF";
<table border=0 cellpadding=5 cellspacing=0 bgcolor='#dddddd' >
<tr><td> <select name=branch> $branchoptions </select> </td></tr>
</table>
<input type=hidden name=branch value=$branch>
EOF
} else {
    my ($branch) = keys %$branches;
    $branchform=<<"EOF";
<input type=hidden name=printer value=$printer>
EOF
} 


# set header with cookie....
print $query->header(-type=>'text/html',-expires=>'now', -cookie=>[$branchcookie,$printercookie]);


print startpage();
print startmenu('circulation');

if ($branch and $printer) {
    print << "EOF";
<p align=right>
<FONT SIZE=2  face="arial, helvetica">
<a href=circulation.pl?module=issues&branch=$branch&printer=$printer&print>Next Borrower</a> ||
<a href=circulation.pl?module=returns&branch=$branch&printer=$printer>Returns</a> ||
<a href=branchtransfers.pl>Transfer Book</a></font>
<input type=hidden name=module value=issues>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
<input type=hidden name=barcode value=" ">
</p>

<table align=left border=0 cellpadding=5 cellspacing=0 >
<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage>
<font color=black><b>Branch and Printer Settings<b></font>
</td></tr>
<tr><td>
<b>Branch:</b> $branches->{$branch}->{'branchname'} </td><td><b>Printer:</b>$printers->{$printer}->{'printername'} 
</td></tr>
<tr><td colspace=2>
<a href=circulation2.pl?selectnewbranchprinter=1>Select new branch and printer</a>
</td></tr>
</table>

<img src="/images/holder.gif" width=24 height=50 align=left>

<table border=0 cellpadding=5 cellspacing=0 bgcolor='#dddddd' align=right>
<form method=get>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>
<b>Enter borrower card number<br> or partial last name</b></font>
</td></tr>
<tr><td><input name=findborrower></td></tr>
</form>
</table>



EOF
} else {
    print << "EOF";
<form method=post action=/cgi-bin/koha/circ/circulation2.pl>
<table border=0 cellpadding=5 cellspacing=0>
<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage>
<font color=black><b>Please Set Branch and Printer</b></font></td></tr>
<tr><td>
$branchform
</td>
<td>
$printerform
</td></tr>
</table>
<input type="submit" value="Change Settings" type="changesettings">
</form>


EOF
}

print endmenu('circulation');
print endpage();

