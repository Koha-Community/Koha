#!/usr/bin/perl


# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

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

($branch) || ($branch=(keys %$branches)[0]);
($printer) || ($printer=(keys %$printers)[0]);


# is you force a selection....
my $oldbranch = $branch;
my $oldprinter = $printer;

$branch='';
$printer='';


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
    (next) unless ($branches->{$_}->{'IS'});
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

# set up printer and branch selection forms....
my ($printerform, $branchform);
if ($printercount>1) {
    $printerform=<<"EOF";
<select name=printer> $printeroptions </select>
EOF
} else {
    my ($printer) = keys %$printers;
    $printerform.="Printer: ".$printers->{$printer}->{printername};
} 

if ($branchcount>1) {
    $branchform=<<"EOF";
<select name=branch> $branchoptions </select>
EOF
} else {
    my ($branch) = keys %$branches;
    $branchform.= "Branch: ".$branches->{$branch}->{branchname};
} 



#############################################################################################
# Start writing page....
# set header with cookie....

print $query->header();

print startpage();
print startmenu('circulation');

print << "EOF";
<FONT SIZE=6><em>Circulation: Select Printer and Branch Settings</em></FONT><br>

<center>
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
<input type="hidden" name="setcookies" value=1>
<input type="submit" value="Submit" type="changesettings">
</form>
</center>

EOF


print endmenu('circulation');
print endpage();

