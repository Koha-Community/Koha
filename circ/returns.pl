#!/usr/bin/perl

#written 11/3/2002 by Finlay
#script to execute returns of books


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
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;
use C4::Print;
use C4::Reserves2;

my %env;
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

my $query=new CGI;
my $branches = getbranches();
my $printers = getprinters(\%env);

my $branch = $query->param("branch");
my $printer = $query->param("printer");

($branch) || ($branch=$query->cookie('branch')) ;
($printer) || ($printer=$query->cookie('printer')) ;


#
# Some code to handle the error if there is no branch or printer setting.....
#


$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

# Set up the item stack ....
my $ritext = '';
my %returneditems;
my %riduedate;
my %riborrowernumber;
foreach ($query->param) {
    (next) unless (/ri-(\d*)/);
    my $counter=$1;
    (next) if ($counter>20);
    my $barcode=$query->param("ri-$counter");
    my $duedate=$query->param("dd-$counter");
    my $borrowernumber=$query->param("bn-$counter");
    $counter++;
    # decode cuecat
    $barcode = cuecatbarcodedecode($barcode);
    $returneditems{$counter}=$barcode;
    $riduedate{$counter}=$duedate;
    $riborrowernumber{$counter}=$borrowernumber;
    $ritext.="<input type=hidden name=ri-$counter value=$barcode>\n";
    $ritext.="<input type=hidden name=dd-$counter value=$duedate>\n";
    $ritext.="<input type=hidden name=bn-$counter value=$borrowernumber>\n";
}

# Collect a few messages here...
my $messagetext='';
my $reservetext='';

############
# Deal with the requests....
if ($query->param('resbarcode')) {
    my $item = $query->param('itemnumber');
    my $borrnum = $query->param('borrowernumber');
    my $resbarcode = $query->param('resbarcode');
# set to waiting....
    my $iteminfo = getiteminformation(\%env, $item);
    my $tobranchcd = ReserveWaiting($item, $borrnum);
    my $branchname = $branches->{$tobranchcd}->{'branchname'};
    my ($borr) = getpatroninformation(\%env, $borrnum, 0);
    my $name = $borr->{'surname'}." ".$borr->{'title'}." ".$borr->{'firstname'};
    my $number = "<a href=/cgi-bin/koha/moremember.pl?bornum=$borr->{'borrowernumber'} onClick='openWindow(this,'Member', 480, 640)'>$borr->{'cardnumber'}</a>";
    my $slip = $query->param('resslip');
    printslip(\%env, $slip);
    if ($tobranchcd ne $branch) {
#	my ($transfered, $messages, $iteminfo) = transferbook($tobranchcd, $resbarcode, 1);
	$reservetext .= <<"EOF";
<font color='red' size='+2'>Item marked Waiting:</font><br>
    Item: $iteminfo->{'title'} ($iteminfo->{'author'})<br>
 needs to be transfered to <b>$branchname</b> <br>
to be picked up by $name ($number).
<center><form method=post action='returns.pl'>
$ritext
<input type=hidden name=barcode value=0>
<input type=submit value="OK">
</form></center>
EOF
    }
}


my $iteminformation;
my $borrower;
my $returned = 0;
my $messages;
my $barcode = $query->param('barcode');
# actually return book and prepare item table.....
if ($barcode) {
    # decode cuecat
    $barcode = cuecatbarcodedecode($barcode);
    ($returned, $messages, $iteminformation, $borrower) = returnbook($barcode, $branch);
    $ritext.= "<input type=hidden name=ri-0 value=$barcode>\n";
    if ($returned) {
	$returneditems{0} = $barcode;
	$riborrowernumber{0} = $borrower->{'borrowernumber'};
	$riduedate{0} = $iteminformation->{'date_due'};
	$ritext.= "<input type=hidden name=dd-0 value=$iteminformation->{'date_due'}>\n";
	$ritext.= "<input type=hidden name=bn-0 value=$borrower->{'borrowernumber'}>\n";
    } elsif (! $messages->{'BadBarcode'}) {
	$returneditems{0} = $barcode;
	$riduedate{0} = 0;
	$ritext.= "<input type=hidden name=dd-0 value=0>\n";
	if ($messages->{'wthdrawn'}) {
	    $ritext.= "<input type=hidden name=bn-0 value='Item Cancelled'>\n";
	    $riborrowernumber{0} = 'Item Cancelled';
	} else {
	    $ritext.= "<input type=hidden name=bn-0 value='&nbsp;'>\n";
	    $riborrowernumber{0} = '&nbsp;';
	}
    }
}

##################################################################################
# HTML code....
# title....
my $title = <<"EOF";
<FONT SIZE=6><em>Circulation: Returns</em></FONT><br>
<b>Branch:</b> $branches->{$branch}->{'branchname'} &nbsp<b>Printer:</b> $printers->{$printer}->{'printername'}<br>
<a href=selectbranchprinter.pl>Change Settings</a>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
<p>
EOF

my $links = <<"EOF";
<table align="right"><tr><td>
<a href=circulation.pl>
<img src="/images/button-issues.gif" width="99" height="42" border="0" alt="Issues"></a>
&nbsp<a href=branchtransfers.pl><img src="/images/button-transfers.gif" width="127" height="42" border="0" alt="Issues"></a>
</td></tr></table>
EOF


my $itemtable;
if ($iteminformation) {
    $itemtable = <<"EOF";
<table border=1 cellpadding=5 cellspacing=0>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage>
<font color=black>Returned Item Information</font></th></tr>
<tr><td>
Title: $iteminformation->{'title'}<br>
<!--Hlt decided they dont want these showing, uncoment the html to make it work

Author: $iteminformation->{'author'}<br>
Barcode: <a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}
&type=intra onClick="openWindow(this, 'Item', 480, 640)">$iteminformation->{'barcode'}</a><br>
Date Due: $iteminformation->{'date_due'}-->
</td></tr>
</table>
EOF
}

# Barcode entry box, with hidden inputs attached....
my $barcodeentrytext = << "EOF";
<form method=post action=/cgi-bin/koha/circ/returns.pl>
<table border=1 cellpadding=5 cellspacing=0>
<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage>
<font color=black><b>Enter Book Barcode</b></font></td></tr>
<tr><td>Item Barcode:</td><td><input name=barcode size=10></td></tr>
</table>
$ritext
</form>
EOF


if ($messages->{'ResFound'}) {
    my $res = $messages->{'ResFound'};
    my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
    my ($borr) = getpatroninformation(\%env, $res->{'borrowernumber'}, 0);
    my $name = $borr->{'surname'}." ".$borr->{'title'}." ".$borr->{'firstname'};
    my $number = "<a href=/cgi-bin/koha/moremember.pl?bornum=$borr->{'borrowernumber'} onClick='openWindow(this,'Member', 480, 640)'>$borr->{'cardnumber'}</a>";
    my ($iteminfo) = getiteminformation(\%env, 0, $barcode);

    if ($res->{'ResFound'} eq "Waiting") {
	$reservetext = <<"EOF";
<font color='red' size='+2'>Item marked Waiting:</font><br>
    Item $iteminfo->{'title'} ($iteminfo->{'author'}) <br>
is marked waiting at <b>$branchname</b> for $name ($number).
<center><form method=post action='returns.pl'>
$ritext
<input type=hidden name=barcode value=0>
<input type=submit value="OK">
</form></center>
EOF
    }    if ($res->{'ResFound'} eq "Reserved") {
	my @da = localtime(time());
	my $todaysdate = sprintf ("%0.2d", ($da[3]+1))."/".sprintf ("%0.2d", ($da[4]+1))."/".($da[5]+1900);
	my $slip =  <<"EOF";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Date: $todaysdate;

ITEM RESERVED:$iteminfo->{'title'} ($iteminfo->{'author'})
barcode: $iteminfo->{'barcode'}
itemtype: $iteminfo->{'itemtype'}
COLLECT AT: $branchname

BORROWER:
$borr->{'title'} $borr->{'firstname'} $borr->{'surname'}
card number: $borr->{'cardnumber'}
Phone: $borr->{'phone'}
$borr->{'streetaddress'}
$borr->{'suburb'}
$borr->{'town'}
$borr->{'emailaddress'}

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

EOF

	$reservetext = <<"EOF";
<font color='red' size='+2'>Reserve found:</font> Item: $iteminfo->{'title'} ($iteminfo->{'author'}) <a href=/cgi-bin/koha/detail.pl?bib=$iteminfo->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$barcode</a> <br>
for $name ($number) to be collected at <b>$branchname</b>.
<table cellpadding=5 cellspacing=0>
<tr><td valign="top">Change status to waiting and print<a href="" onClick='alert(document.forms[0].resslip.value); return false'>slip</a>?: </td>
<td valign="top">
<form method=post action='returns.pl'>
$ritext
<input type=hidden name=itemnumber value=$res->{'itemnumber'}>
<input type=hidden name=borrowernumber value=$res->{'borrowernumber'}>
<input type=hidden name=resbarcode value=$barcode>
<input type=hidden name=resslip value="$slip">
<input type=submit value="Print">
</form>
</td></tr>
</table>
EOF
    }
}
my $reservefoundtext;
if ($reservetext) {
    $reservefoundtext = <<"EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd'>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font>Reserve Found</font></th></tr>
<tr><td> $reservetext </td></tr></table>
EOF
}

# collect the messages and put into message table....
foreach my $code (keys %$messages) {
#    warn $code;
    if ($code eq 'BadBarcode'){
	$messagetext .= "<font color='red' size='+2'> No Item with barcode: $messages->{'BadBarcode'} </font> <br>";
    }
    if ($code eq 'NotIssued'){
	my $braname = $branches->{$messages->{'IsPermanent'}}->{'branchname'};
	$messagetext .= "<font color='red' size='+2'> Item not on issue. </font> <br>";
    }
    if ($code eq 'WasLost'){
	$messagetext .= "<font color='red' size='+2'> Item was lost, now found. </font> <br>";
    }
    if ($code eq 'wthdrawn'){
	$messagetext = "<font color='red' size='+2'> Item Cancelled. </font> <br>";
	last;
    }
    if (($code eq 'IsPermanent') && (not $messages->{'ResFound'})) {
	if ($messages->{'IsPermanent'} ne $branch) {
	    $messagetext .= "<font color='red' size='+2'> Please return to $branches->{$messages->{'IsPermanent'}}->{'branchname'} </font> <br>";
	}
    }
}
$messagetext = substr($messagetext, 0, -4);

my $messagetable;
if ($messagetext) {
    $messagetable = << "EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd'>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font>Messages</font></th></tr>
<tr><td> $messagetext </td></tr></table>
EOF
}


# patrontable ....
my $borrowertable;
my $flaginfotable;
if ($borrower) {
    $borrowertable = << "EOF";
<table border=1 cellpadding=5 cellspacing=0>
<tr><td colspan=2 bgcolor=$headerbackgroundcolor background=$backgroundimage>
<font color=black><b>Borrower Information</b></font></td></tr>
<tr><td colspan=2>
<a href=/cgi-bin/koha/moremember.pl?bornum=$borrower->{'borrowernumber'}onClick="openWindow(this,'Member', 480, 640)">$borrower->{'cardnumber'}</a>
$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'}<br>
</td></tr>
EOF
    my $flags = $borrower->{'flags'};
    my $flaginfotext='';
    my $displayflag = '';
    my $color = '';
    foreach my $flag (sort keys %$flags) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	if ($flags->{$flag}->{'noissues'}) {
	    $displayflag = "<font color=red>$flag</font>";
	} else {
	    $displayflag = $flag;
	}	if ($flag eq 'CHARGES') {
	    $flaginfotext.= <<"EOF";
<tr><td valign=top>$displayflag</td>
<td bgcolor=$color><b>$flags->{$flag}->{'message'}</b><a href=/cgi-bin/koha/pay.pl?bornum=$borrower->{'borrowernumber'}onClick="openWindow(this, 'Payment', 480,640)">Payment</a></td></tr>
EOF
	} elsif ($flag eq 'WAITING') {
	    my $itemswaiting='';
	    my $items = $flags->{$flag}->{'itemlist'};
	    foreach my $item (@$items) {
		my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
		$itemswaiting .= <<"EOF";
<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intraonClick="openWindow(this, 'Item', 480, 640)">$iteminformation->{'barcode'}</a>$iteminformation->{'title'}($branches->{$iteminformation->{'holdingbranch'}}->{'branchname'})<br>
EOF
            }
            $flaginfotext.="<tr><td valign=top>$displayflag</td><td>$itemswaiting</td></tr>\n";
	} elsif ($flag eq 'ODUES') {
	    my $itemsoverdue = '';
	    my $items = $flags->{$flag}->{'itemlist'};
            foreach my $item (sort {$a->{'date_due'} cmp $b->{'date_due'}} @$items) {
		my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
                $itemsoverdue .=  <<"EOF";
<font color=red>$item->{'date_due'}</font>
<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intraonClick="openWindow(this, 'Item', 480, 640)">$iteminformation->{'barcode'}</a>$iteminformation->{'title'}
<br>
EOF
	    }
	    $flaginfotext .= "<tr><td valign=top>$displayflag</td><td>$itemsoverdue</td></tr>\n";
        } else {
	    $flaginfotext.= <<"EOF";
<tr><td valign=top>$displayflag</td>
<td bgcolor=$color>$flags->{$flag}->{'message'}</td></tr>
EOF
	}
    }
    if ($flaginfotext) {
	$borrowertable .= << "EOF";
<tr><td bgcolor=$headerbackgroundcolor background=$backgroundimage colspan=2>
<b>Flags</b></td></tr>
$flaginfotext
EOF
    }
    $borrowertable .= "</table>";
}

# the returned items.....
my $returneditemstable = << "EOF";
<table border=1 cellpadding=5 cellspacing=0>
<tr><th colspan=6 bgcolor=$headerbackgroundcolor background=$backgroundimage>
<font color=black>Returned Items</font></th></tr>
<tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Type</th><th>Borrower</th></tr>
EOF

my $color='';
#set up so only the lat 8 returned items display (make for faster loading pages)
my $count=0;
foreach (sort {$a <=> $b} keys %returneditems) {
    if ($count < 8) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	my $barcode = $returneditems{$_};
	my $duedate = $riduedate{$_};
	my $overduetext;
        my $borrowerinfo;
	if ($duedate) {
	    my @tempdate = split ( /-/ , $duedate ) ;
            my $duedatenz = "$tempdate[2]/$tempdate[1]/$tempdate[0]";
            my @datearr = localtime(time());
            my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);
	    $overduetext = "$duedatenz";
	    ($overduetext="<font color=red>$duedate</font>") if ($duedate lt $todaysdate);
	    ($duedatenz) || ($overduetext = "<img src=/images/blackdot.gif>");
	    my ($borrower) = getpatroninformation(\%env, $riborrowernumber{$_}, 0);
            $borrowerinfo = "<a href=/cgi-bin/koha/moremember.pl?bornum=$borrower->{'borrowernumber'} onClick=\"openWindow(this,'Member', 480, 640)\">$borrower->{'cardnumber'}</a> $borrower->{'firstname'} $borrower->{'surname'}";
        } else {
            $overduetext = "Not on Issue.";
	    $borrowerinfo = $riborrowernumber{$_};
	}
	my ($iteminformation) = getiteminformation(\%env, 0, $barcode);;
	$returneditemstable .= << "EOF";
<tr><td bgcolor=$color>$overduetext</td>
<td bgcolor=$color align=center>
<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$barcode</a></td>
<td bgcolor=$color>$iteminformation->{'title'}</td>
<td bgcolor=$color>$iteminformation->{'author'}</td>
<td bgcolor=$color align=center>$iteminformation->{'itemtype'}</td>
<td bgcolor=$color>
$borrowerinfo</td></tr>
EOF
    } else {
	last;
    }
    $count++;
}
$returneditemstable .= "</table>\n";


# actually print the page!
print $query->header();
print startpage();
print startmenu('circulation');


#debug
#    foreach my $key (keys %$messages) {
#	print "$key : $messages->{$key}<br>";
#    }


print <<"EOF";
$links
$title


<table cellpadding=5 cellspacing=0 width=100%>
EOF

if ($reservefoundtext) {
    print <<"EOF";
<tr>
<td colspan=2>$reservefoundtext</td>
</tr>
<tr>
<td colspan=2>$messagetable</td>
</tr>

EOF
} else {
    print <<"EOF";
<tr>
<td valign=top align=left>$barcodeentrytext</td>
<td valign=top align=left>$messagetable</td>
</tr>
EOF
}
if ($returned) {
    print <<"EOF";
<tr>
<td valign=top align=left>$itemtable</td>
<td valign=top align=left>$borrowertable</td>
<tr>
EOF
}
if (%returneditems) {
    print "<tr><td colspan=2>$returneditemstable</td></tr>";
}

print "</table>";

print endmenu('circulation');
print endpage();

sub cuecatbarcodedecode {
    my ($barcode) = @_;
    chomp($barcode);
    my @fields = split(/\./,$barcode);
    my @results = map(decode($_), @fields[1..$#fields]);
    if ($#results == 2){
  	return $results[2];
    } else {
	return $barcode;
    }}
