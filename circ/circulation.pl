#!/usr/bin/perl

use strict;
use CGI qw/:standard/;
use C4::Circulation::Circ2;
use C4::Output;
use C4::Print;
use DBI;


# this is a reorganisation of circulationold.pl 
# dividing it up into three scripts......
# this will be the first one that chooses branch and printer settings....

#general design stuff...
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

# try to get the branch and printer settings from the http....
my %env;
my $query=new CGI;
my $branches=getbranches(\%env);
my $printers=getprinters(\%env);
my $branch=$query->param('branch');
my $printer=$query->param('printer');

($branch) || ($branch=$query->cookie('branch'));
($printer) || ($printer=$query->cookie('printer'));

# is you force a selection....
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

#set up cookie.....
my $branchcookie=$query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
my $printercookie=$query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');


# set up printer and branch selection forms....
my ($printerform, $branchform);
if ($printercount>1) {
    $printerform=<<"EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd' >
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
<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd' >
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

#############################################################################################
# Start writing page....
# set header with cookie....
print $query->header(-type=>'text/html',-expires=>'now', -cookie=>[$branchcookie,$printercookie]);

print startpage();
print startmenu('circulation');

# if the settings are already set...
# Page has links through to the other circulation modules....
if ($branch and $printer) {
    print << "EOF";
<p align=left><FONT SIZE=6><em>Circulation: Issues</em></FONT></p>
<p align=right>
<FONT SIZE=2  face="arial, helvetica">
<a href=circulationold.pl?module=issues&branch=$branch&printer=$printer&print>Next Borrower</a> ||
<a href=returns.pl?&branch=$branch&printer=$printer>Returns</a> ||
<a href=branchtransfers.pl>Transfer Book</a></font>
<input type=hidden name=module value=issues>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
<input type=hidden name=barcode value=" ">
</p>

<table align=left border=1 cellpadding=5 cellspacing=0 >
<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage>
<font color=black><b>Branch and Printer Settings<b></font>
</td></tr>
<tr><td>
<b>Branch:</b> $branches->{$branch}->{'branchname'} </td><td><b>Printer:</b>$printers->{$printer}->{'printername'} 
</td></tr><tr><td colspan=2> 
<a href=circulation.pl?selectnewbranchprinter=1>Select new branch and printer</a>
</td></tr>
</table>


<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd' align=right>
<form method=post action=/cgi-bin/koha/circ/circulationold.pl>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>
<b>Enter borrower card number<br> or partial last name</b></font>
</td></tr>
<tr><td><input name=findborrower></td></tr>
<input type=hidden name=module value=issues>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
<input type=hidden name=barcode value=" ">
</form>
</table>



EOF
# To change the settings....
} else {
    print << "EOF";
<FONT SIZE=6><em>Circulation: Select Printer and Branch Settings</em></FONT><br>

<form method=post action=/cgi-bin/koha/circ/circulation.pl>
<table border=1 cellpadding=5 cellspacing=0>
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

