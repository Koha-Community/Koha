#!/usr/bin/perl

#written 11/3/2002 by Finlay
#script to execute returns of books

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;
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

my $request=$query->param('request');


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

############
# Deal with the requests....
if ($request eq "KillWaiting") {
    my $item = $query->param('itemnumber');
    my $borrnum = $query->param('borrowernumber');
    CancelReserve(0, $item, $borrnum);
    $messagetext .= "Reserve Cancelled<br>";
}
if ($request eq "SetWaiting") {
    my $item = $query->param('itemnumber');
    my $borrnum = $query->param('borrowernumber');
    my $barcode2 = $query->param('barcode2');
    my $tobranchcd = ReserveWaiting($item, $borrnum);
    my ($transfered, $messages, $iteminfo) = transferbook($tobranchcd, $barcode2, 1);
    $messagetext .= "Item should now be waiting at branch: <b>$branches->{$tobranchcd}->{'branchname'}</b><br>";
}
if ($request eq 'KillReserved'){
    my $biblio = $query->param('biblionumber');
    my $borrnum = $query->param('borrowernumber');
    CancelReserve($biblio, 0, $borrnum);
    $messagetext .= "Reserve Cancelled<br>";
}



my $iteminformation;
my $borrower;
my $returned = 0;
my $messages;
my $barcode = $query->param('barcode');
# actually return book (SQL CALL) and prepare item table.....
if ($barcode) {
    # decode cuecat
    $barcode = cuecatbarcodedecode($barcode);
    ($returned, $messages, $iteminformation, $borrower) = returnbook($barcode, $branch);
    if ($returned) {
	$returneditems{0} = $barcode;
	$riborrowernumber{0} = $borrower->{'borrowernumber'};
	$riduedate{0} = $iteminformation->{'date_due'};
	$ritext.= "<input type=hidden name=ri-0 value=$barcode>\n";
	$ritext.= "<input type=hidden name=dd-0 value=$iteminformation->{'date_due'}>\n";
	$ritext.= "<input type=hidden name=bn-0 value=$borrower->{'borrowernumber'}>\n";
    }
}

##################################################################################
# HTML code....
# title....
my $title = <<"EOF";
<p>
<table border=0 cellpadding=5 width=90%><tr>
<td align="left"><FONT SIZE=6><em>Circulation: Returns</em></FONT><br>
<b>Branch:</b> $branches->{$branch}->{'branchname'} &nbsp 
<b>Printer:</b> $printers->{$printer}->{'printername'}<br>
<a href=selectbranchprinter.pl>Change Settings</a>
</td>
<td align="right" valign="top">
<FONT SIZE=2  face="arial, helvetica">
<a href=circulation.pl>Next Borrower</a> || 
<a href=returns.pl>Returns</a> || 
<a href=branchtransfers.pl>Transfers</a></font><p>
</td></tr></table>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
</p>
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
<p>
EOF
}

# Barcode entry box, with hidden inputs attached....
my $barcodeentrytext = << "EOF";
<form method=post action=/cgi-bin/koha/circ/returns.pl>
<table border=1 cellpadding=5 cellspacing=0 align=left>
<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage>
<font color=black><b>Enter Book Barcode</b></font></td></tr>
<tr><td>Item Barcode:</td><td><input name=barcode size=10></td></tr>
</table>
$ritext
</form>
<img src="/images/holder.gif" width=24 height=50 align=left>
EOF


my $reservefoundtext;
if ($messages->{'ResFound'}) {
    my $res = $messages->{'ResFound'};
    my $reservetext;
    my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
    my ($borr) = getpatroninformation(\%env, $res->{'borrowernumber'}, 0);
    my $name = $borr->{'surname'}." ".$borr->{'title'}." ".$borr->{'firstname'};
    my $number = "<a href=/cgi-bin/koha/moremember.pl?bornum=$borr->{'borrowernumber'} onClick='openWindow(this,'Member', 480, 640)'>$borr->{'cardnumber'}</a>";
    if ($res->{'ResFound'} eq "Waiting") {
	$reservetext = <<"EOF";
<font color='red' size='+2'>Item marked Waiting:</font><br>
    Item is marked waiting at <b>$branchname</b> for $name ($number).<br>
<table border=1 cellpadding=5 cellspacing=0>
<tr><td>Cancel reservation: </td>
<td>
<form method=post action='returns.pl'>
$ritext
<input type=hidden name=itemnumber value=$res->{'itemnumber'}>
<input type=hidden name=borrowernumber value=$res->{'borrowernumber'}>
<input type=hidden name=request value='KillWaiting'>
<input type=hidden name=barcode value=0>
<input type=submit value="Cancel">
</form>
</td></tr>
<tr><td>Back to returns: </td>
<td>
<form method=post action='returns.pl'>
$ritext
<input type=hidden name=barcode value=0>
<input type=submit value="OK">
</form>
</td></tr></table>
EOF
    } 
    if ($res->{'ResFound'} eq "Reserved") {
	$reservetext = <<"EOF";
<font color='red' size='+2'>Reserved:</font> reserve found for $name ($number).
<table border=1 cellpadding=5 cellspacing=0>
<tr><td>Set reserve to waiting and transfer book to <b>$branchname </b>: </td>
<td>
<form method=post action='returns.pl'>
$ritext
<input type=hidden name=itemnumber value=$res->{'itemnumber'}>
<input type=hidden name=borrowernumber value=$res->{'borrowernumber'}>
<input type=hidden name=barcode2 value=$barcode>
<input type=hidden name=request value='SetWaiting'>
<input type=submit value="Waiting">
</form>
</td></tr>
<tr><td>Cancel reservation: </td>
<td>
<form method=post action='returns.pl'>
$ritext
<input type=hidden name=biblionumber value=$res->{'biblionumber'}>
<input type=hidden name=borrowernumber value=$res->{'borrowernumber'}>
<input type=hidden name=barcode value=0>
<input type=hidden name=request value='KillReserved'>
<input type=submit value="Cancel">
</form>
</td></tr><tr><td>Back to returns: </td>
<td>
<form method=post action='returns.pl'>
<input type=hidden name=barcode value=0>
$ritext
<input type=submit value="OK">
</form>
</td></tr></table>
EOF
    }
    $reservefoundtext = <<"EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd'>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font>Reserve Found</font></th></tr>
<tr><td> $reservetext </td></tr></table>
<img src="/images/holder.gif" width=24 height=24>
EOF
}

# collect the messages and put into message table....
foreach my $code (keys %$messages) {
    if ($code eq 'BadBarcode'){
	$messagetext .= "<font color='red' size='+2'> No Item with barcode: $messages->{'BadBarcode'} </font> <br>";
    }
    if ($code eq 'NotIssued'){
	my $braname = $branches->{$messages->{'IsPermanent'}}->{'branchname'};
	$messagetext .= "<font color='red' size='+2'> Item is not Issued, cannot be returned. </font> <br>";
    }
    if ($code eq 'WasLost'){
	$messagetext .= "<font color='red' size='+2'> Item was lost, now found. </font> <br>";
    }
    if (($code eq 'IsPermanent') && (not $messages->{'ResFound'})) {
	if ($messages->{'IsPermanent'} ne $branch) {
	    $messagetext .= "<font color='red' size='+2'> Item is part of permanent collection, please return to $branches->{$messages->{'IsPermanent'}}->{'branchname'} </font> <br>";
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
if ($borrower) {
    my $patrontable = << "EOF";
<table border=1 cellpadding=5 cellspacing=0 align=right>
<tr><td colspan=2 bgcolor=$headerbackgroundcolor background=$backgroundimage>
<font color=black><b>Patron Information</b></font></td></tr>
<tr><td colspan=2>
<a href=/cgi-bin/koha/moremember.pl?bornum=$borrower->{'borrowernumber'} 
onClick="openWindow(this,'Member', 480, 640)">$borrower->{'cardnumber'}</a>
$borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'}<br>
</td></tr></table>
EOF
    my $flags = $borrower->{'flags'};
    my $flaginfotext='';
    my $flag;
    my $color = '';
    foreach $flag (sort keys %$flags) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$flags->{$flag}->{'message'}=~s/\n/<br>/g;
	if ($flags->{$flag}->{'noissues'}) {
	    if ($flag eq 'CHARGES') {
		$flaginfotext.= <<"EOF";
<tr><td valign=top><font color=red>$flag</font></td>
<td bgcolor=$color><b>$flags->{$flag}->{'message'}</b> 
<a href=/cgi-bin/koha/pay.pl?bornum=$borrower->{'borrowernumber'} 
onClick=\"openWindow(this, 'Payment', 480,640)\">Payment</a></td></tr>
EOF
	    } else {
		$flaginfotext.= <<"EOF";
<tr><td valign=top><font color=red>$flag</font></td>
<td bgcolor=$color>$flags->{$flag}->{'message'}</td></tr>
EOF
	    }
	} else {
	    if ($flag eq 'CHARGES') {
		$flaginfotext .= << "EOF";
<tr><td valign=top>$flag</td>
<td> $flags->{$flag}->{'message'} <a href=/cgi-bin/koha/pay.pl?bornum=$borrower->{'borrowernumber'} 
onClick=\"openWindow(this, 'Payment', 480,640)\">Payment</a></td></tr>
EOF
	    } elsif ($flag eq 'WAITING') {
		my $itemswaiting='';
		my $items = $flags->{$flag}->{'itemlist'};
		foreach my $item (@$items) {
		    my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
		    $itemswaiting .= <<"EOF";
<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra 
onClick=\"openWindow(this, 'Item', 480, 640)\">$iteminformation->{'barcode'}</a> 
$iteminformation->{'title'} ($branches->{$iteminformation->{'holdingbranch'}}->{'branchname'})<br>
EOF
		}
		$flaginfotext.="<tr><td valign=top>$flag</td><td>$itemswaiting</td></tr>\n";
	    } elsif ($flag eq 'ODUES') {
		my $items = $flags->{$flag}->{'itemlist'};
		$flaginfotext .=  <<"EOF";
<tr><td bgcolor=$color><font color=red>$flag</font></td>
<td bgcolor=$color>Patron has Overdue books</td></tr>
EOF
	    } else {
		$flaginfotext .= "<tr><td valign=top>$flag</td><td>$flags->{$flag}->{'message'}</td></tr>\n";
	    }
	}
    }
    if ($flaginfotext) {
	$flaginfotext = << "EOF";
<table border=1 cellpadding=5 cellspacing=0> <tr><td bgcolor=$headerbackgroundcolor background=$backgroundimage colspan=2><b>Flags</b></td></tr>
$flaginfotext 
</table>
EOF
    }
    $borrowertable = << "EOF";
<table border=0 cellpadding=5>
<tr>
<td valign=top>$patrontable</td>
<td valign=top>$flaginfotext</td>
</tr>
</table>
EOF
}

# the returned items.....
my $returneditemstable = << "EOF";
<br><p>
<table border=1 cellpadding=5 cellspacing=0 align=left>
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
	my @datearr = localtime(time());
	###
	# convert to nz date format
	my @tempdate = split(/-/,$duedate);
	$duedate = "$tempdate[2]/$tempdate[1]/$tempdate[0]";
	####
	my $todaysdate 
	    = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);
	my $overduetext = "$duedate";
	($overduetext="<font color=red>$duedate</font>") if ($duedate lt $todaysdate);
	($duedate) || ($overduetext = "<img src=/images/blackdot.gif>");
	my $borrowernumber = $riborrowernumber{$_};
	my ($borrower) = getpatroninformation(\%env,$borrowernumber,0);
	my ($iteminformation) = getiteminformation(\%env, 0, $barcode);;
	$returneditemstable .= << "EOF";
<tr><td bgcolor=$color>$overduetext</td>
<td bgcolor=$color align=center>
<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$barcode</a></td>
<td bgcolor=$color>$iteminformation->{'title'}</td>
<td bgcolor=$color>$iteminformation->{'author'}</td>
<td bgcolor=$color align=center>$iteminformation->{'itemtype'}</td>
<td bgcolor=$color>
<a href=/cgi-bin/koha/moremember.pl?bornum=$borrower->{'borrowernumber'} onClick=\"openWindow(this,'Member', 480, 640)\">$borrower->{'cardnumber'}</a> $borrower->{'firstname'} $borrower->{'surname'}</td></tr>
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

print $title;

if ($reservefoundtext) {
    print $reservefoundtext;
} else {
    print $barcodeentrytext;
}

print $messagetable;

if ($returned) {
    print $itemtable;
    print $borrowertable;
}
(print $returneditemstable) if (%returneditems); 

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
    } 
} 

