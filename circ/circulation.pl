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

sub issues {
    if (my $borrnumber=$query->param('borrnumber')) {
	my ($borrower, $flags) = getpatroninformation(\%env,$borrnumber,0);
	if (my $barcode=$query->param('barcode')) {
	    my %responses;
	    foreach (sort $query->param) {
		if ($_ =~ /response-(\d*)/) {
		    $responses{$1}=$query->param($_);
		}
	    }
	    if (my $qnumber=$query->param('questionnumber')) {
		$responses{$qnumber}=$query->param('answer');
	    }
	    my ($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer) = issuebook(\%env, $borrower, $barcode, \%responses);
	    if ($rejected) {
		if ($rejected == -1) {
		} else {
		    print "Error issuing book: $rejected<br>\n";
		}
	    }
	    if ($question) {
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
	my $issueid=$query->param('issueid');
	($issueid) || ($issueid=int(rand()*1000000000));
	my $flag='';
	my $flagtext='';
	foreach $flag (sort keys %$flags) {
	    $flagtext.="$flag ";
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
	print << "EOF";
	<form method=get>
	<input type=hidden name=module value=issues>
	<input type=hidden name=borrnumber value=$borrnumber>
    <table border=0 cellpadding=5>
    <tr>
	<td align=left>
	    <table border=3 bgcolor=#dddddd>
	        <tr><td colspan=2 bgcolor=black><font color=white><b>Enter Book Barcode</b></font></td></tr>
		<tr><td>Item Barcode:</td><td><input name=barcode size=10></td></tr>
	    </table>
	</td>
	<td align=right>
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
	    <tr><th colspan=5 bgcolor=black><font color=white><b>Today's Issues</b></font></th></tr>
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
<input type=hidden name=module value=issues>
<table border=1 bgcolor=#dddddd>
<tr><th bgcolor=black><font color=white><b>Enter borrower card number<br> or partial last name</b></font></td></tr>
<tr><td><input name=findborrower></td></tr>
</table>
</form>
EOF
	}
    }
}
