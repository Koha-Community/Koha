#!/usr/bin/perl

use CGI qw/:standard/;
use C4::Circulation::Circ2;
use C4::Output;
use DBI;


my %env;
my $query=new CGI;
print $query->header;
print startpage();
print startmenu('catalogue');

print << "EOF";
<center>
<a href=circulation.pl?module=issues>Issues</a> |
<a href=circulation.pl?module=returns>Returns</a>
<hr>
EOF

SWITCH: {
    if ($query->param('module') eq 'issues') { issues(); last SWITCH; }
    if ($query->param('module') eq 'returns') { returns(); last SWITCH; }
    issues();
}


print endmenu();
print endpage();
sub default {
print << "EOF";
<a href=circulation.pl?module=issues>Issues</a>
<a href=circulation.pl?module=returns>Returns</a>
EOF
}


sub returns {
    if (my $barcode=$query->param('barcode')) {
	print "Returning $barcode<br>\n";
	my ($iteminformation, $borrower, $messages, $overduecharge) = returnbook(\%env, $barcode);
	if ($borrower) {
	    print "Borrowed by $borrower->{'title'} $borrower->{'firstname'} $borrower->{'surname'}<p>\n";
	} else {
	    print "Not loaned out.\n";
	}
    }
    print << "EOF";
    <form method=post name=barcode>
    <table border=3 bgcolor=#dddddd>
	<tr><td colspan=2 bgcolor=black><font color=white><b>Enter Book Barcode</b></font></td></tr>
	<tr><td>Item Barcode:</td><td><input name=barcode size=10></td></tr>
    </table>
    <input type=hidden name=module value=returns>
    </form>
EOF
}

sub issues {
    if (my $borrnumber=$query->param('borrnumber')) {
	my ($borrower, $flags) = getpatroninformation(\%env,$borrnumber,0);
	my $year=$query->param('year');
	my $month=$query->param('month');
	my $day=$query->param('day');
	if (my $barcode=$query->param('barcode')) {
	    my $invalidduedate=0;
	    $env{'datedue'}='';
	    if (($year eq 0) && ($month eq 0) && ($year eq 0)) {
		$env{'datedue'}='';
	    } else {
		if (($year eq 0) || ($month eq 0) || ($year eq 0)) {
		    print "Invalid Due Date Specified. Book was not issued.<p>\n";
		    $invalidduedate=1;
		} else {
		    if (($day>30) && (($month==4) || ($month==6) || ($month==9) || ($month==11))) {
			print "Invalid Due Date Specified. Book was not issued.<p>\n";
			$invalidduedate=1;
		    } elsif (($day>29) && ($month==2)) {
			print "Invalid Due Date Specified. Book was not issued.<p>\n";
			$invalidduedate=1;
		    } elsif (($day>28) && (($year%4) && ((!($year%100) || ($year%400))))) {
			print "Invalid Due Date Specified. Book was not issued.<p>\n";
			$invalidduedate=1;
		    } else {
			$env{'datedue'}="$year-$month-$day";
		    }
		}
	    }
	    my %responses;
	    foreach (sort $query->param) {
		if ($_ =~ /response-(\d*)/) {
		    $responses{$1}=$query->param($_);
		}
	    }
	    if (my $qnumber=$query->param('questionnumber')) {
		$responses{$qnumber}=$query->param('answer');
	    }
	    unless ($invalidduedate) {
		my ($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer) = issuebook(\%env, $borrower, $barcode, \%responses);
		if ($rejected) {
		    if ($rejected == -1) {
		    } else {
			print "Error issuing book: $rejected<br>\n";
		    }
		}
		my $responsesform='';
		foreach (keys %responses) {
		    $responsesform.="<input type=hidden name=response-$_ value=$responses{$_}>\n";
		}
		if ($question) {
		    my $stickyduedate=$query->param('stickyduedate');
		    print << "EOF";
		    <table border=1 bgcolor=#dddddd>
		    <tr><th bgcolor=black><font color=white><b>Issuing Question</b></font></td></tr>
		    <tr><td>
		    Attempting to issue $iteminformation->{'title'} by $iteminformation->{'author'} to $borrower->{'firstname'} $borrower->{'surname'}.
		    <br>
		    $question
		    </td></tr>

		    <tr><td align=center>
		    <table border=0>
		    <tr><td>
		    <form method=get>
		    <input type=hidden name=module value=issues>
		    <input type=hidden name=borrnumber value=$borrnumber>
		    <input type=hidden name=barcode value=$barcode>
		    <input type=hidden name=questionnumber value=$questionnumber>
		    <input type=hidden name=day value=$day>
		    <input type=hidden name=month value=$month>
		    <input type=hidden name=year value=$year>
		    <input type=hidden name=stickyduedate value=$stickyduedate>
		    $responsesform
		    <input type=hidden name=answer value=Y>
		    <input type=submit value=Yes>
		    </form>
		    </td>
		    <td>
		    <form method=get>
		    <input type=hidden name=module value=issues>
		    <input type=hidden name=borrnumber value=$borrnumber>
		    <input type=hidden name=barcode value=$barcode>
		    <input type=hidden name=questionnumber value=$questionnumber>
		    <input type=hidden name=day value=$day>
		    <input type=hidden name=month value=$month>
		    <input type=hidden name=year value=$year>
		    <input type=hidden name=stickyduedate value=$stickyduedate>
		    $responsesform
		    <input type=hidden name=answer value=N>
		    <input type=submit value=No>
		    </form>
		    </td>
		    </tr>
		    </table>
		    </td></tr>
		    </table>
EOF
		    return;
		}
	    }
	}
	my $issueid=$query->param('issueid');
	($issueid) || ($issueid=int(rand()*1000000000));
	my $flag='';
	my $flagtext='';
	my $flaginfotext='';
	foreach $flag (sort keys %$flags) {
	    if ($flags->{$flag}->{'noissues'}) {
		$flagtext.="<font color=red>$flag</font> ";
	    } else {
		$flagtext.="$flag ";
	    }
	    $flags->{$flag}->{'message'}=~s/\n/<br>/g;
	    if ($flags->{$flag}->{'noissues'}) {
		$flaginfotext.="<tr><td bgcolor=red><font color=white><b>$flag</b></font></td><td bgcolor=red><font color=white><b>$flags->{$flag}->{'message'}</b></font></td></tr>\n";
	    } else {
		$flaginfotext.="<tr><td>$flag</td><td>$flags->{$flag}->{'message'}</td></tr>\n";
	    }
	}
	if ($flaginfotext) {
	    $flaginfotext="<table border=1 width=70%><tr><th bgcolor=black colspan=2><font color=white>Patron Flags</font></th></tr>$flaginfotext</table>\n";
	}
	$env{'nottodaysissues'}=1;
	my ($borrowerissues) = currentissues(\%env, $borrower);
	$env{'nottodaysissues'}=0;
	$env{'todaysissues'}=1;
	my ($today) = currentissues(\%env, $borrower);
	$env{'todaysissues'}=0;
	my $previssues='';
	my @datearr = localtime(time());
	my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", $datearr[3]);
	foreach (sort keys %$borrowerissues) {
	    my $bookissue=$borrowerissues->{$_};
	    my $bgcolor='';
	    my $datedue=$bookissue->{'date_due'};
	    $datedue=~s/-//g;
	    if ($datedue < $todaysdate) {
		$bgcolor="bgcolor=red";
	    }
	    $previssues.="<tr $bgcolor><td>$bookissue->{'date_due'}</td><td>$bookissue->{'barcode'}</td><td>$bookissue->{'title'}</td><td>$bookissue->{'author'}</td><td>$bookissue->{'dewey'} $bookissue->{'subclass'}</td></tr>\n";
	}
	my $todaysissues='';
	foreach (sort keys %$today) {
	    my $bookissue=$today->{$_};
	    $todaysissues.="<tr><td>$bookissue->{'date_due'}</td><td>$bookissue->{'barcode'}</td><td>$bookissue->{'title'}</td><td>$bookissue->{'author'}</td><td>$bookissue->{'dewey'} $bookissue->{'subclass'}</td></tr>\n";
	}
	for ($i=1; $i<32; $i++) {
	    my $selected='';
	    if (($query->param('stickyduedate')) && ($day==$i)) {
		$selected='selected';
	    }
	    $dayoptions.="<option value=$i $selected>$i";
	}
	my $counter=1;
	foreach (('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December')) {
	    my $selected='';
	    if (($query->param('stickyduedate')) && ($month==$counter)) {
		$selected='selected';
	    }
	    $monthoptions.="<option value=$counter $selected>$_";
	    $counter++;
	}
	for ($i=$datearr[5]+1900; $i<$datearr[5]+1905; $i++) {
	    my $selected='';
	    if (($query->param('stickyduedate')) && ($year==$i)) {
		$selected='selected';
	    }
	    $yearoptions.="<option value=$i $selected>$i";
	}

	my $selected='';
	($query->param('stickyduedate')) && ($selected='checked');
	print << "EOF";
	<form method=get>
    <table border=0 cellpadding=5>
    <tr>
	<td align=left>
	    <table border=1 bgcolor=#dddddd>
	        <tr><td bgcolor=black><font color=white><b>Enter Book Barcode</b></font></td></tr>
		<tr><td>
		<table border=0 bgcolor=#dddddd>
		<tr><td>Item Barcode:</td><td><input name=barcode size=10></td><td><input type=submit value=Issue></tr>
		<tr><td colspan=3 align=center>
		<select name=day><option value=0>Day$dayoptions</select>
		<select name=month><option value=0>Month$monthoptions</select>
		<select name=year><option value=0>Year$yearoptions</select>
		<br>
		<input type=checkbox name=stickyduedate $selected> Sticky Due Date
		</td></tr>
		</table>
		</td></tr>
	    </table>
	<input type=hidden name=module value=issues>
	<input type=hidden name=borrnumber value=$borrnumber>
	</form>
	</td>
	<td align=right valign=top>
	<table border=1 bgcolor=#dddddd>
	<tr><th bgcolor=black><font color=white><b>Patron Information</b></font></td></tr>
	<tr><td>
	$borrower->{'cardnumber'} $borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'}<br>
	$borrower->{'streetaddress'} $borrower->{'city'}<br>
	$borrower->{'categorycode'} $flagtext
	</td></tr>
	</table>
	</td>
    </tr>
    <tr>
	<td colspan=2 align=center>
	<table border=1 width=100% bgcolor=#dddddd>
	    <tr><th colspan=5 bgcolor=black><font color=white><b>Issues Today</b></font></th></tr>
	    <tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Class</th></tr>
	    $todaysissues
	</table>
	</td>
    </tr>
    <tr>
	<td colspan=2 align=center>
	<table border=1 width=100% bgcolor=#dddddd>
	    <tr><th colspan=5 bgcolor=black><font color=white><b>Previous Issues</b></font></th></tr>
	    <tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Class</th></tr>
	    $previssues
	</table>
	</td>
    </tr>
</table>
<p>
$flaginfotext
EOF
    } else {
	if (my $findborrower=$query->param('findborrower')) {
	    my ($borrowers, $flags) = findborrower(\%env, $findborrower);
	    print "<form method=get>\n";
	    print "<input type=hidden name=module value=issues>\n";
	    my @borrowers=@$borrowers;
	    if ($#borrowers == 0) {
		$query->param('borrnumber', $borrowers[0]->{'borrowernumber'});
		issues();
		return;
	    } else {
		print "<table border=1 cellpadding=5 bgcolor=#dddddd>";
		print "<tr><th bgcolor=black><font color=white><b>Select a borrower</b></font></th></tr>\n";
		print "<tr><td align=center>\n";
		print "<select name=borrnumber size=7>\n";
		foreach (sort {$a->{'surname'}.$a->{'firstname'} cmp $b->{'surname'}.$b->{'firstname'}} @$borrowers) {
		    print "<option value=$_->{'borrowernumber'}>$_->{'surname'}, $_->{'firstname'} ($_->{'cardnumber'})\n";
		}
		print "</select><br>";
		print "<input type=submit>\n";
		print "</td></tr></table>\n";
	    }
	} else {
	    print << "EOF";
	    <h1>Issues Module</h1>
<form method=get>
<table border=1 bgcolor=#dddddd>
<tr><th bgcolor=black><font color=white><b>Enter borrower card number<br> or partial last name</b></font></td></tr>
<tr><td><input name=findborrower></td></tr>
</table>
<input type=hidden name=module value=issues>
</form>
EOF
	}
    }
}
