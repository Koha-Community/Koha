#!/usr/bin/perl

#written 8/5/2002 by Finlay
#script to execute issuing of books

use strict;
use CGI;
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;


my %env;
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

my $branches = getbranches();
my $printers = getprinters(\%env);

my $query = new CGI;

my $branch = $query->param("branch");
my $printer = $query->param("printer");

($branch) || ($branch=$query->cookie('branch')) ;
($printer) || ($printer=$query->cookie('printer')) ;

#set up cookie.....
my $branchcookie;
my $printercookie;
unless ($query->cookie('branch')) {
    $branchcookie = $query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
}
unless ($query->cookie('printer')) {
    $printercookie = $query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');
}

$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);



my $message;
my $borrowerslist;
# if there is a list of find borrowers....
my $findborrower = $query->param('findborrower');
if ($findborrower) {
    my ($borrowers, $flags) = findborrower(\%env, $findborrower);
    my @borrowers=@$borrowers;
    if ($#borrowers == -1) {
	$query->param('findborrower', '');
	$message =  "No borrower matched '$findborrower'";
    } elsif ($#borrowers == 0) {
	$query->param('borrnumber', $borrowers[0]->{'borrowernumber'});
	$query->param('barcode','');
    } else {
	$borrowerslist = \@borrowers;
    }
}

my $borrowernumber = $query->param('borrnumber');    

# get the currently issued books......
my $borrower;
my $flags;
if ($borrowernumber) {
    ($borrower, $flags) = getpatroninformation(\%env,$borrowernumber,0);
}

# get the responses to any questions.....
my %responses;
foreach (sort $query->param) {
    if ($_ =~ /response-(\d*)/) {
	$responses{$1} = $query->param($_);
    }
}
if (my $qnumber = $query->param('questionnumber')) {
    $responses{$qnumber} = $query->param('answer');
}


# if the barcode is set    
my $barcode = $query->param('barcode');
my ($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer);

my $year=$query->param('year');
my $month=$query->param('month');
my $day=$query->param('day');


if ($barcode) {
    $barcode = cuecatbarcodedecode($barcode);
    my ($datedue, $invalidduedate) = fixdate($year, $month, $day);

    unless ($invalidduedate) {
	my @time=localtime(time);
	my $date= (1900+$time[5])."-".($time[4]+1)."-".$time[3];
	($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer, $message) 
                     = issuebook(\%env, $borrower, $barcode, \%responses, $date);
    }
}


##################################################################################
# HTML code....


my $rejectedtext;
if ($rejected) {
    if ($rejected == -1) {
    } else {
	$rejectedtext = << "EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor="#dddddd">
<tr><th><font color=black size=6>Error Issuing Book</font></th></tr>
<tr><td><font color=red size=6>$rejected</font></td></tr>
</table>
<br>
EOF
    }
}

my $selectborrower;
if ($borrowerslist) {
    $selectborrower = <<"EOF";
<form method=get action=/cgi-bin/koha/circ/issues.pl>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
<table border=1 cellspacing=0 cellpadding=5 bgcolor="#dddddd">
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage>
<font color=black><b>Select a borrower</b></font></th></tr>\n
<tr><td align=center>
<select name=borrnumber size=7>
EOF
    foreach (sort {$a->{'surname'}.$a->{'firstname'} cmp $b->{'surname'}.$b->{'firstname'}} @$borrowerslist){
	$selectborrower .= <<"EOF";
<option value=$_->{'borrowernumber'}>$_->{'surname'}, $_->{'firstname'} ($_->{'cardnumber'})
EOF
    }
    $selectborrower .= <<"EOF";
</select><br>
<input type=submit>
</td></tr></table>
EOF
}

# title....
my $title = <<"EOF";
<p>
<table border=0 cellpadding=5 width=90%><tr>
<td align="left"><FONT SIZE=6><em>Circulation: Issues</em></FONT><br>
<b>Branch:</b> $branches->{$branch}->{'branchname'} &nbsp 
<b>Printer:</b> $printers->{$printer}->{'printername'} <br>
<a href=selectbranchprinter.pl>Change Settings</a></td>
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



my $cardnumberinput = << "EOF";
<form method=get action=/cgi-bin/koha/circ/issues.pl>
<table border=1 cellpadding=5 cellspacing=0 bgcolor="#dddddd">
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage>
<font color=black><b>Enter borrower card number<br> or partial last name</b></font></td></tr>
<tr><td><input name=findborrower></td></tr>
</table>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
</form>
EOF

my $responsesform = '';
foreach (keys %responses) {
    $responsesform.="<input type=hidden name=response-$_ value=$responses{$_}>\n";
}
my $questionform;
if ($question) {
    my $stickyduedate=$query->param('stickyduedate');
    $questionform = <<"EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor="#dddddd">
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage>
<font color=black><b>Issuing Question</b></font></th></tr>
<tr><td><table border=0 cellpadding=10><tr><td> 
Attempting to issue $iteminformation->{'title'} 
by $iteminformation->{'author'} to $borrower->{'firstname'} $borrower->{'surname'}.
<p>
$question
</td></tr></table></td></tr>
<tr><td align=center>
<table border=0>
<tr><td>
<form method=get>
<input type=hidden name=borrnumber value=$borrowernumber>
<input type=hidden name=barcode value=$barcode>
<input type=hidden name=questionnumber value=$questionnumber>
<input type=hidden name=day value=$day>
<input type=hidden name=month value=$month>
<input type=hidden name=year value=$year>
<input type=hidden name=stickyduedate value=$stickyduedate>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
$responsesform
<input type=hidden name=answer value=Y>
<input type=submit value=Yes>
</form>
</td>
<td>
<form method=get>
<input type=hidden name=borrnumber value=$borrowernumber>
<input type=hidden name=barcode value=$barcode>
<input type=hidden name=questionnumber value=$questionnumber>
<input type=hidden name=day value=$day>
<input type=hidden name=month value=$month>
<input type=hidden name=year value=$year>
<input type=hidden name=stickyduedate value=$stickyduedate>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
$responsesform
<input type=hidden name=answer value=N>
<input type=submit value=No>
</form>
</td>
</tr>
</table>
</td></tr>
</table>
</td></tr>
</table>
EOF
}


# Barcode entry box, with hidden inputs attached....
my $counter = 1;
my $dayoptions = '';
my $monthoptions = '';
my $yearoptions = '';
for (my $i=1; $i<32; $i++) {
    my $selected='';
    if (($query->param('stickyduedate')) && ($day==$i)) {
	$selected='selected';
    }
    $dayoptions.="<option value=$i $selected>$i";
}
foreach (('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')) {
    my $selected='';
    if (($query->param('stickyduedate')) && ($month==$counter)) {
	$selected='selected';
    }
    $monthoptions.="<option value=$counter $selected>$_";
    $counter++;
}
for (my $i=$datearr[5]+1900; $i<$datearr[5]+1905; $i++) {
    my $selected='';
    if (($query->param('stickyduedate')) && ($year==$i)) {
	$selected='selected';
    }
    $yearoptions.="<option value=$i $selected>$i";
}
my $selected='';
($query->param('stickyduedate')) && ($selected='checked');


my $barcodeentrytext = <<"EOF";
<form method=post action=/cgi-bin/koha/circ/issues.pl>
<table border=1 cellpadding=5>
<tr>
<td align=center valign=top>
<table border=0 cellspacing=0 cellpadding=5>
<tr><th align=center background=$backgroundimage>
<font color=black><b>Enter Book Barcode</b></font></th></tr>
<tr><td align=center>
<table border=0>
<tr><td>Item Barcode:</td><td><input name=barcode size=10></td><td><input type=submit value=Issue></td></tr>
<tr><td colspan=3 align=center>
<table border=0 cellpadding=0 cellspacing=0>
<tr><td>
<select name=day><option value=0>Day$dayoptions</select>
</td><td>
<select name=month><option value=0>Month$monthoptions</select>
</td><td>
<select name=year><option value=0>Year$yearoptions</select>
</td></tr>
</table>
<input type=checkbox name=stickyduedate $selected> Sticky Due Date
</td></tr>
</table>
<input type=hidden name=borrnumber value=$borrowernumber>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
</td></tr></table>
</td></tr></table>
</form>
EOF


# collect the messages and put into message table....
my $messagetable;
if ($message) {
    $messagetable = << "EOF";
<table border=1 cellpadding=5 cellspacing=0 bgcolor='#dddddd'>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font>Messages</font></th></tr>
<tr><td> $message </td></tr></table>
EOF
}



# make the issued books table.....
my $todaysissues='';
my $previssues='';
my $info='';
if ($borrower) {
    my $issueslist = getissues($borrower);
    my $tcolor = '';
    my $pcolor = '';
    foreach my $it (sort keys %$issueslist) {
	my $dd = $issueslist->{$it}->{'date_due'};
	my $issuedate = $issueslist->{$it}->{'timestamp'};
	$issuedate = substr($issuedate, 0, 8);

	my $bookissue = $issueslist->{$it};
	my $bgcolor='';
	my $datedue = $bookissue->{'date_due'};
	#convert to nz style dates
	#this should be set with some kinda config variable	    
	my @tempdate=split(/-/,$dd);
	$dd="$tempdate[2]/$tempdate[1]/$tempdate[0]";
     	$datedue=~s/-//g;
	if ($datedue < $todaysdate) {
	    $dd="<font color=red>$dd</font>\n";
	}
	if ($todaysdate == $issuedate) {
	    ($tcolor eq $linecolor1) ? ($tcolor=$linecolor2) : ($tcolor=$linecolor1);
	    $todaysissues .=<< "EOF";
<tr><td bgcolor=$tcolor align=center>$dd</td>
<td bgcolor=$tcolor align=center>
<a href=/cgi-bin/koha/detail.pl?bib=$bookissue->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$bookissue->{'barcode'}</a></td>
<td bgcolor=$tcolor>$bookissue->{'title'}</td>
<td bgcolor=$tcolor>$bookissue->{'author'}</td>
<td bgcolor=$tcolor align=center>$bookissue->{'dewey'} $bookissue->{'subclass'}</td></tr>
EOF
        } else {
	    ($pcolor eq $linecolor1) ? ($pcolor=$linecolor2) : ($pcolor=$linecolor1);
	    $previssues .= << "EOF";
<tr><td bgcolor=$pcolor align=center>$dd</td>
<td bgcolor=$pcolor align=center>
<a href=/cgi-bin/koha/detail.pl?bib=$bookissue->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$bookissue->{'barcode'}</a></td>
<td bgcolor=$pcolor>$bookissue->{'title'}</td>
<td bgcolor=$pcolor>$bookissue->{'author'}</td>
<td bgcolor=$pcolor align=center>$bookissue->{'dewey'} $bookissue->{'subclass'}</td></tr>
EOF
	}
    }
}

my $issuedbookstable;
if ($todaysissues) {
    $issuedbookstable .= <<"EOF";
<table border=1 cellpadding=5 cellspacing=0 width=80%>
<tr><th colspan=5 bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>
<b>Todays Issues</b></font></th></tr>
<tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Class</th></tr>
$todaysissues
</table>
EOF
}
if ($previssues) {
    $issuedbookstable .= <<"EOF";
<table border=1 cellpadding=5 cellspacing=0 width=80%>
<tr><th colspan=5 bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>
<b>Previous Issues</b></font></th></tr>
<tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Class</th></tr>
$previssues
</table>
EOF
}





# actually print the page!


if ($branchcookie && $printercookie) {
    print $query->header(-type=>'text/html',-expires=>'now', -cookie=>[$branchcookie,$printercookie]);
} else {
    print $query->header();
}

print startpage();
print startmenu('circulation');

print $title;


print $info;

if ($question) {
    print $questionform;
}

print $rejectedtext;
print $messagetable;

unless ($borrower) {
    if ($borrowerslist) {
	print $selectborrower;
    } else {
	print $cardnumberinput;
    }
}



if ($borrower) {
    my ($patrontable, $flaginfotable) = patrontable($borrower);
    print $patrontable;
    print $flaginfotable;
    print $barcodeentrytext;
    print "<p clear=all>";
    print $issuedbookstable;
}




print endmenu('circulation');
print endpage();


####################################################################
# Extra subroutines,,,

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

sub fixdate {
    my ($year, $month, $day) = @_;
    my $invalidduedate;
    my $date;
    if (($year eq 0) && ($month eq 0) && ($year eq 0)) {
	$env{'datedue'}='';
    } else {
	if (($year eq 0) || ($month eq 0) || ($year eq 0)) {
	    $invalidduedate="Invalid Due Date Specified. Book was not issued.<p>\n";
	} else {
	    if (($day>30) && (($month==4) || ($month==6) || ($month==9) || ($month==11))) {
		$invalidduedate = "Invalid Due Date Specified. Book was not issued. Only 30 days in $month month.<p>\n";
	    } elsif (($day > 29) && ($month == 2)) {
		$invalidduedate="Invalid Due Date Specified. Book was not issued.  Never that many days in February!<p>\n";
	    } elsif (($month == 2) && ($day > 28) && (($year%4) && ((!($year%100) || ($year%400))))) {
		$invalidduedate="Invalid Due Date Specified. Book was not issued.  $year is not a leap year.<p>\n";
	    } else {
		$date="$year-$month-$day";
	    }
	}
    }
    return ($date, $invalidduedate);
}


sub patrontable {
    my ($borrower) = @_;
    my $flags = $borrower->{'flags'};
    my $flaginfotable='';
    my $flaginfotext='';
    my $flag;
    my $color='';
    foreach $flag (sort keys %$flags) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$flags->{$flag}->{'message'}=~s/\n/<br>/g;
	if ($flags->{$flag}->{'noissues'}) {
	    if ($flag eq 'CHARGES') {
		$flaginfotext.="<tr><td valign=top><font color=red>$flag</font></td><td bgcolor=$color><b>$flags->{$flag}->{'message'}</b> <a href=/cgi-bin/koha/pay.pl?bornum=$borrower->{'borrowernumber'} onClick=\"openWindow(this, 'Payment', 480,640)\">Payment</a></td></tr>\n";
	    } else {
		$flaginfotext.="<tr><td valign=top><font color=red>$flag</font></td><td bgcolor=$color>$flags->{$flag}->{'message'}</td></tr>\n";
	    }
	} else {
	    if ($flag eq 'CHARGES') {
		$flaginfotext.="<tr><td valign=top>$flag</td><td> $flags->{$flag}->{'message'} <a href=/cgi-bin/koha/pay.pl?bornum=$borrower->{'borrowernumber'} onClick=\"openWindow(this, 'Payment', 480,640)\">Payment</a></td></tr>\n";
	    } elsif ($flag eq 'WAITING') {
		my $itemswaiting='';
		my $items=$flags->{$flag}->{'itemlist'};
		foreach my $item (@$items) {
		    my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
		    $itemswaiting.="<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$iteminformation->{'barcode'}</a> $iteminformation->{'title'} ($branches->{$iteminformation->{'holdingbranch'}}->{'branchname'})<br>\n";
		}
		$flaginfotext.="<tr><td valign=top>$flag</td><td>$itemswaiting</td></tr>\n";
	    } elsif ($flag eq 'ODUES') {
		my $items=$flags->{$flag}->{'itemlist'};
		my $itemswaiting="<table border=1 cellspacing=0 cellpadding=2>\n";
		my $currentcolor=$color;
		{
		    my $color=$currentcolor;
		    foreach my $item (@$items) {
			($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
			my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
			$itemswaiting.="<tr><td><font color=red>$iteminformation->{'date_due'}</font></td><td bgcolor=$color><a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$iteminformation->{'barcode'}</a></td><td>$iteminformation->{'title'}</td></tr>\n";
		    }		    
		}
		$itemswaiting.="</table>\n";
		if ($query->param('module') ne 'returns'){
  		  $flaginfotext.="<tr><td valign=top>$flag</td><td>$flags->{$flag}->{'message'}, See below</td></tr>\n";
		} else {
  		  $flaginfotext.="<tr><td valign=top>$flag</td><td>$flags->{$flag}->{'message'}</td></tr>\n"; 
		}
	    } else {
		$flaginfotext.="<tr><td valign=top>$flag</td><td>$flags->{$flag}->{'message'}</td></tr>\n";
	    }
	}
    }
    ($flaginfotext) && ($flaginfotext="<tr><td bgcolor=$headerbackgroundcolor background=$backgroundimage colspan=2><b>Flags</b></td></tr>$flaginfotext\n");
    $flaginfotext.="</table>";
    my $patrontable= << "EOF";
<br><p>
    <table border=1 cellpadding=5 cellspacing=0 align=right>
    <tr><td bgcolor=$headerbackgroundcolor background=$backgroundimage colspan=2><font color=black><b>Patron Information</b></font></td></tr>
    <tr><td colspan=2>
    <a href=/cgi-bin/koha/moremember.pl?bornum=$borrower->{'borrowernumber'} onClick="openWindow(this,'Member', 480, 640)">$borrower->{'cardnumber'}</a> $borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'}<br>$borrower->{'streetaddress'} $borrower->{'city'} Cat: $borrower->{'categorycode'} </td></tr>
EOF
    return($patrontable, $flaginfotext);
}




