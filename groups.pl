#!/usr/bin/perl

# $Id$

#written 14/1/2000
#script to display reports


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

use CGI qw/:standard/;
use C4::Output;
use C4::Groups;
use C4::Circulation::Circ2;
use C4::Print;
use DBI;
use C4::Database;

my $configfile=configfile();
my $intranetdir=$configfile->{'intranetdir'};


my $input=new CGI;

# Authentication script added, superlibrarian set as default requirement

my $flagsrequired;
$flagsrequired->{superlibrarian}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

my $time=$input->param('time');
#print $input->header;


my $branches=getbranches(\%env);
my $printers=getprinters(\%env);
my $branch=$input->param('branch');
my $printer=$input->param('printer');
($branch) || ($branch=$input->cookie('branch'));
($printer) || ($printer=$input->cookie('printer'));
my ($oldbranch, $oldprinter);
if ($input->param('selectnewbranchprinter')) {
    $oldbranch=$branch;
    $oldprinter=$printer;
    $branch='';
    $printer='';
}
$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
#$env{'queue'}=$printer;
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
    ($selected='selected') if ($_ eq $branch);
    $branchoptions.="<option value=$_ $selected>$branches->{$_}->{'branchname'}\n";
}
foreach (keys %$printers) {
    (next) unless ($_);
    $printercount++;
    my $selected='';
    ($selected='selected') if ($_ eq $oldprinter || $_ eq $printer);
    $printeroptions.="<option value=$_ $selected>$printers->{$_}->{'printername'}\n";
}
if ($printercount==1) {
    ($printer)=keys %$printers;
}
if ($branchcount==1) {
    ($branch)=keys %$branches;
}


my $branchname='';
my $printername='';
if ($branch && $printer) {
    $branchname=$branches->{$branch}->{'branchname'};
    $printername=$printers->{$printer}->{'printername'};
}


my $branchcookie=$input->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y', -path=>'/cgi-bin/koha/');
my $printercookie=$input->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y', -path=>'/cgi-bin/koha/');

print $input->header(-type=>'text/html',-expires=>'now', -cookie=>[$branchcookie,$printercookie]);
print startpage;
unless ($input->param('printable')) {
    print startmenu('report');
}
print center;



my $type=$input->param('type');
my $groups=getgroups();
if ($input->param('print')) {
    if ($input->param('groupsselected')) {
	foreach ($input->param()) {
	    if (/print_(.*)/) {
		my $group=$1;
		printgroup($group,$input->param('type'));
	    }
	}
    } else {
	print "<h2>Select the groups to print</h2>\n";
	print "<form method=post>\n";
	print "<input type=hidden name=print value=1>\n";
	print "<input type=hidden name=groupsselected value=1>\n";
	print "<table border=0><tr><td bgcolor=#dddddd>\n";
	print "<table border=1 cellspacing=5 cellpadding=10><tr>\n";
	my $counter=0;
	foreach (sort {$groups->{$a} cmp $groups->{$b}} keys %$groups) {
	    (next) unless ($groups->{$_});
	    if ($counter>3) {
		$counter=0;
		print "</tr><tr>\n";
	    } else {
	    }
	    print << "EOF";
<td><input type=checkbox name=print_$_ value=0> $groups->{$_}
</td>
EOF
	    $counter++;
	}
	print << "EOF";
</tr></table>
</td></tr></table>
<p>
Printer:
<select name=printer>
$printeroptions
</select>
<p>
<input type=radio name=type value=issues> Issues <input type=radio name=type value=overdues checked> Overdues
<p>
<input type=submit value=Print>
</body></html>
EOF
	exit;
    }
}
if (my $group=$input->param('group')) {
    print "<a href=groups.pl?type=$type>Back to group list</a><p>\n";
    if ($input->param('printable')) {
	print "<head><title>Overdue list for $groups->{$group}</title></head><body>\n";
    }
    my $members=groupmembers($env, $group);
    print "<table border=0><tr><td bgcolor=#dddddd>\n";
    print "<table border=1 cellspacing=5 cellpadding=10>\n";
    my $typetext='';
    ($type eq 'overdues') ? ($typetext="Overdues") : ($typetext="Issues");
    print "<thead><tr><th>Card #</th><th>Name</th><th>IS/OD</th><th>$typetext</th></tr></thead>\n";
    foreach (sort { $a->{'surname'}." ".$a->{'firstname'} cmp $b->{'surname'}." ".$b->{'firstname'} }  @$members) {
	my $fullname=$_->{'firstname'}." ".$_->{'surname'};
	my $userid=$_->{'userid'};
	my $cardnumber=$_->{'cardnumber'};
	my $currentissues=$_->{'currentissues'};
	my $counter=0;
	my $overduecounter=0;
	my $overduelist='';
	foreach (keys %$currentissues) {
	    $counter++;
	    if ($currentissues->{$_}->{'overdue'}) {
		$overduecounter++;
		$title=$currentissues->{$_}->{'title'};
		$author=$currentissues->{$_}->{'author'};
		$date_due=$currentissues->{$_}->{'date_due'};
		$overduelist.="<u>$title</u> by $author (<font color=red>$date_due</font>)<br>\n";
	    } else {
		if ($type eq 'issues') {
		    $title=$currentissues->{$_}->{'title'};
		    $author=$currentissues->{$_}->{'author'};
		    $date_due=$currentissues->{$_}->{'date_due'};
		    $overduelist.="<u>$title</u> by $author due on $date_due<br>\n";
		}
	    }
	}
	my $overduetext="0";
	if ($overduecounter) {
	    $overduetext="<font color=red>$overduecounter</font>";
	}
	(next) unless ($overduecounter || $counter);
	if ($overduecounter==0 && $type eq 'overdues') {
	    next;
	}
	print "<tr><td align=center>$cardnumber</td><td>$fullname</td><td align=center>$counter/$overduetext</td><td>$overduelist</td></tr>\n";
    }
    print "</table>\n";
    print "</td></tr></table>\n";
} else {
    print "<a href=groups.pl?print=1>Print Reports</a><p>\n";
    print "<h2>Pick a group</h2>\n";
    print "<table border=0><tr><td bgcolor=#dddddd>\n";
    print "<table border=1 cellspacing=5 cellpadding=10><tr>\n";
    my $counter=0;
    foreach (sort {$groups->{$a} cmp $groups->{$b}} keys %$groups) {
	(next) unless ($groups->{$_});
	if ($counter>3) {
	    $counter=0;
	    print "</tr><tr>\n";
	} else {
	}
	print << "EOF";
<td align=center>$groups->{$_}
<br>
<a href=groups.pl?type=issues&group=$_>Issues</a> | <a href=groups.pl?type=overdues&group=$_>Overdues</a>
</td>
EOF
	$counter++;
    }
    print "</tr></table>\n";
    print "</td></tr></table>\n";
}


unless ($input->param('printable')) {
    print endmenu('report');
}
print endpage;



sub printgroup {
    my $group=shift;
    my $type=shift;
    $output= "<head><title>Overdue list for $groups->{$group}</title></head><body><center>\n";
    my $members=groupmembers($env, $group);
    ($type eq 'overdues') && ($output.="<img src=/images/overdues.jpg><br>\n");
    $output.= "<table border=1 cellspacing=5 cellpadding=10>\n";
    my $typetext='';
    ($type eq 'overdues') ? ($typetext="Overdues") : ($typetext="Issues");
    $output.= "<thead><tr><th>Card #</th><th>Name</th><th>IS/OD</th><th>$typetext</th></tr></thead>\n";
    foreach (sort { $a->{'surname'}." ".$a->{'firstname'} cmp $b->{'surname'}." ".$b->{'firstname'} }  @$members) {
	my $fullname=$_->{'firstname'}." ".$_->{'surname'};
	my $userid=$_->{'userid'};
	my $cardnumber=$_->{'cardnumber'};
	my $currentissues=$_->{'currentissues'};
	my $counter=0;
	my $overduecounter=0;
	my $overduelist='';
	foreach (keys %$currentissues) {
	    $counter++;
	    if ($currentissues->{$_}->{'overdue'}) {
		$overduecounter++;
		$title=$currentissues->{$_}->{'title'};
		$author=$currentissues->{$_}->{'author'};
		$date_due=$currentissues->{$_}->{'date_due'};
		$overduelist.="<u>$title</u> by $author (<font color=red>$date_due</font>)<br>\n";
	    } else {
		if ($type eq 'issues') {
		    $title=$currentissues->{$_}->{'title'};
		    $author=$currentissues->{$_}->{'author'};
		    $date_due=$currentissues->{$_}->{'date_due'};
		    $overduelist.="<u>$title</u> by $author due on $date_due<br>\n";
		}
	    }
	}
	my $overduetext="0";
	if ($overduecounter) {
	    $overduetext="<font color=red>$overduecounter</font>";
	}
	(next) unless ($overduecounter || $counter);
	if ($overduecounter==0 && $type eq 'overdues') {
	    next;
	}
	$output.= "<tr><td align=center>$cardnumber</td><td>$fullname</td><td align=center>$counter/$overduetext</td><td>$overduelist</td></tr>\n";
    }
    $output.= "</table>\n";
    $output.= "</td></tr></table>\n";
    open (P, "|html2ps | lpr -P$printer");
    print P $output;
    close P;
}
