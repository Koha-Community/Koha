#!/usr/bin/perl

use CGI qw/:standard/;
use C4::Circulation::Circ2;
use C4::Output;
use C4::Print;
use DBI;


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
my ($oldbranch, $oldprinter);
if ($query->param('selectnewbranchprinter')) {
    $oldbranch=$branch;
    $oldprinter=$printer;
    $branch='';
    $printer='';
}
$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;
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


my $branchcookie=$query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
my $printercookie=$query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');

print $query->header(-type=>'text/html',-expires=>'now', -cookie=>[$branchcookie,$printercookie]);
#print $query->dump;
print startpage();
print startmenu('circulation');


print <<EOF
<script language="javascript" type="text/javascript">
<!--
function messenger(url){
   window1=window.open(url,"window1","height=700,width=600,left=150,top=50,350,screenY=50");
}
//-->
</script>
EOF

if ($printer && $branch) {

    SWITCH: {
	if ($query->param('module') eq 'issues') { issues(); last SWITCH; }
	if ($query->param('module') eq 'returns') { returns(); last SWITCH; }
	issues();
    }
} else {
    my ($printerform, $branchform);
    if ($printercount>1) {
	$printerform=<<"EOF";

<table border=0 cellspacing=0 cellpadding=5>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Choose a Printer</font></td></tr>
<tr><td>
<select name=printer>
$printeroptions
</select>
</td></tr>
</table>
EOF
    } else {
	my ($printer) = keys %$printers;
	$printerform=<<"EOF";
	<input type=hidden name=printer value=$printer>
EOF
    }

    if ($branchcount>1) {
	$branchform=<<"EOF";
<table border=0 cellpadding=5 cellspacing=0>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Choose a Branch</font></td></tr>
<tr><td>
<select name=branch>
$branchoptions
</select>
</td></tr>
</table>
EOF
    }
    print << "EOF";
    <center>
    Select a branch and a printer
    <form method=get>
    <table border=0>
    <tr><td>
    $branchform
    </td><td>
    $printerform
    </td></tr>
    </table>
    <input type=submit>
    </form>
EOF
}


print endmenu('circulation');
print endpage();
sub default {
print << "EOF";
<a href=circulation.pl?module=issues&branch=$branch&printer=$printer>Issues</a>
<a href=circulation.pl?module=returns&branch=$branch&printer=$printer>Returns</a>
EOF
}


sub decode {
    ($encoded) = @_;
    $seq = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-';
    @s = map { index($seq,$_); } split(//,$encoded);
    $l = ($#s+1) % 4;
    if ($l)
    {
	if ($l == 1)
	{
	    print "Error!";
	    return;
	}
	$l = 4-$l;
	$#s += $l;
    }
    $r = '';
    while ($#s >= 0)
    {
	$n = (($s[0] << 6 | $s[1]) << 6 | $s[2]) << 6 | $s[3];
	$r .=chr(($n >> 16) ^ 67) .
	     chr(($n >> 8 & 255) ^ 67) .
	     chr(($n & 255) ^ 67);
	@s = @s[4..$#s];
    }
    $r = substr($r,0,length($r)-$l);
    return $r;
}

sub returns {
    my %returneditems;
    print << "EOF";
    <table border=0 cellpadding=10 cellspacing=0 cellpadding=5><tr><th background=$backgroundimage>Circulation - Returns</th></tr><tr><td bgcolor=$circbackgroundcolor align=center>
EOF
    foreach ($query->param) {
	(next) unless (/ri-(\d*)/);
	my $counter=$1;
	(next) if ($counter>20);
	my $barcode=$query->param("ri-$counter");
      # I'm not POSITIVE this decode belongs here - can't tell what causes it to run.
      # decode cuecat
      chomp($barcode);
      @fields = split(/\./,$barcode);
      @results = map(decode($_), @fields[1..$#fields]);
      if ($#results == 2)
      {
  	$barcode=$results[2];
      }
      # end decode
	my $duedate=$query->param("dd-$counter");
	my $borrowernumber=$query->param("bn-$counter");
	$counter++;
	$returneditems{$counter}=$barcode;
	$riduedate{$counter}=$duedate;
	$riborrowernumber{$counter}=$borrowernumber;
	$ritext.="<input type=hidden name=ri-$counter value=$barcode>\n";
	$ritext.="<input type=hidden name=dd-$counter value=$duedate>\n";
	$ritext.="<input type=hidden name=bn-$counter value=$borrowernumber>\n";
    }
    if (my $barcode=$query->param('barcode')) {
      # decode cuecat
      chomp($barcode);
      @fields = split(/\./,$barcode);
      @results = map(decode($_), @fields[1..$#fields]);
      if ($#results == 2)
      {
  	$barcode=$results[2];
      }
      # end decode
	$ritext.="<input type=hidden name=ri-0 value=$barcode>\n";
	$returneditems{0}=$barcode;
    }
	
    my $barcodeentrytext= << "EOF";
    <form method=get>
    <table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
	<tr><td colspan=2 bgcolor=$headerbackgroundcolor align=center background=$backgroundimage><font color=black><b>Enter Book Barcode</b></font></td></tr>
	<tr><td>Item Barcode:</td><td><input name=barcode size=10></td></tr>
    </table>
    <input type=hidden name=module value=returns>
    <input type=hidden name=branch value=$branch>
    <input type=hidden name=printer value=$printer>
    $ritext
EOF
    if ((my $barcode=$query->param('barcode')) || (%returneditems)) {
      # decode cuecat
      chomp($barcode);
      @fields = split(/\./,$barcode);
      @results = map(decode($_), @fields[1..$#fields]);
      if ($#results == 2)
      {
  	$barcode=$results[2];
      }
      # end decode
	my ($iteminformation, $borrower, $messages, $overduecharge) = returnbook(\%env, $barcode);
	
	(my $nosuchitem=1) unless ($iteminformation);
	$riborrowernumber{0}=$borrower->{'borrowernumber'};
	$riduedate{0}=$iteminformation->{'date_due'};
	$barcodeentrytext.= "<input type=hidden name=dd-0 value=$iteminformation->{'date_due'}>\n";
	$barcodeentrytext.= "<input type=hidden name=bn-0 value=$borrower->{'borrowernumber'}>\n";
	my @datearr = localtime(time());
	my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);
	my $itemtable=<<"EOF";
<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Returned Item Information</font></th></tr>
<tr><td>
Title: $iteminformation->{'title'}<br>
<!--Hlt decided they dont want these showing, uncoment the html to make it work

Author: $iteminformation->{'author'}<br>
Barcode: <a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra onClick="openWindow(this, 'Item', 480, 640)">$iteminformation->{'barcode'}</a><br>
Date Due: $iteminformation->{'date_due'}-->
</td></tr>
</table>
EOF
	if ($messages) {
	    my $messagetext='';
	    foreach (@$messages) {
		$messagetext.="$_<p>\n";
	    }
	    print << "EOF";
<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
<tr><th bgcolor=$headerbackgroundcolor $background=$backgroundimage><font color=black>Messages</font></th></tr>
<tr><td>
$messagetext
</td></tr>
</table>
<p>
EOF
	}
	if (($nosuchitem) && ($barcode)) {
	    print << "EOF";
	    <table border=0 cellpadding=1>
	    <tr>
	    <td valign=top>
	    $barcodeentrytext
	    </td>
	    <td valign=top>
	    <table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
	    <tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Error</font></th></tr>
	    <tr><td>
	    <table border=0 cellpadding=5>
	    <tr><td>
	    $barcode is not a valid barcode.
	    </td></tr>
	    </table>
	    </td></tr>
	    </table>
	    </td>
	    </tr>
	    </table>
EOF
	} elsif ($nosuchitem) {
	    print << "EOF";
	    <table border=0 cellpadding=1>
	    <tr>
	    <td valign=top>
	    $barcodeentrytext
	    </td>
	    </tr>
	    </table>
EOF
	} else {
	    if ($borrower->{'borrowernumber'}) {
		my ($patrontable, $flaginfotext) = patrontable($borrower);
		print << "EOF";
		<table border=0 cellpadding=5>
		    <tr>
			<td>
			$barcodeentrytext
			</td>
			<td align=center valign=top>
			$itemtable
			</td>
		    </tr>
		    <tr>
			<td valign=top align=center colspan=2>
			<table border=0>
			<tr><td valign=top>
			$patrontable
			</td>
			<td valign=top>
			$flaginfotext
			</td>
			</tr>
			</table>
			</td>
		    </tr>
		</table>
		<br>
EOF
	    } else {
		print << "EOF";
		<table border=0 cellpadding=5>
		<tr><td>
		$barcodeentrytext
		</td>
		<td>

		<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
		<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Error</font></th></tr>
		<tr><td>
		<table border=0 cellpadding=5>
		<tr><td>
		$iteminformation->{'title'} by $iteminformation->{'author'} was not loaned out.
		</td></tr>
		</table>
		</td></tr>
		</table>
		</td>
		</tr>
		</table>
EOF
	    }
	}
	print << "EOF";
	<p>
	<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
	<tr><th colspan=6 bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Returned Items</font></th></tr>
	<tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Type</th><th>Borrower</th></tr>
EOF
	my $color='';
	foreach (sort {$a <=> $b} keys %returneditems) {
	    ($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	    my $barcode=$returneditems{$_};
	    my $duedate=$riduedate{$_};
	    my @datearr = localtime(time());
	    my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);
	    my $overduetext="$duedate";
	    ($overduetext="<font color=red>$duedate</font>") if ($duedate lt $todaysdate);
	    ($duedate) || ($overduetext="<img src=/koha/images/blackdot.gif>");
	    my $borrowernumber=$riborrowernumber{$_};
	    my ($borrower) = getpatroninformation(\%env,$borrowernumber,0);
	    my ($iteminformation) = getiteminformation(\%env, 0, $barcode);
	    print "<tr><td bgcolor=$color>$overduetext</td><td bgcolor=$color align=center><a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$barcode</a></td><td bgcolor=$color>$iteminformation->{'title'}</td><td bgcolor=$color>$iteminformation->{'author'}</td><td bgcolor=$color align=center>$iteminformation->{'itemtype'}</td><td bgcolor=$color><img src=/koha/images/blackdot.gif><a href=/cgi-bin/koha/moremember.pl?bornum=$borrower->{'borrowernumber'} onClick=\"openWindow(this,'Member', 480, 640)\">$borrower->{'cardnumber'}</a> $borrower->{'firstname'} $borrower->{'surname'}</td></tr>\n";
	}
	print "</table>\n";
    } else {
	print $barcodeentrytext;
    }
    print "</form>\n";
    print "</td></tr></table>\n";
}

sub issues {
    my ($noheader) = shift;
    my $print=$query->param('print');
    my $borrowernumber=$query->param('borrnumber');    
    my $barcode=$query->param('barcode');
    if ($barcode eq ''){
      $print='yes';     
    } elsif ($barcode eq ' '){
      $query->param('barcode','');
      $barcode='';
    }
    if ($print eq 'yes'){
      my ($borrower, $flags) = getpatroninformation(\%env,$borrowernumber,0);
      $env{'todaysissues'}=1;
      my ($borrowerissues) = currentissues(\%env, $borrower);
      $env{'nottodaysissues'}=1;
      $env{'todaysissues'}=0;
      my ($borroweriss2)=currentissues(\%env, $borrower);
      $env{'nottodaysissues'}=0;
      my $i=0;
      my @issues;
      foreach (sort keys %$borrowerissues) {
        $issues[$i]=$borrowerissues->{$_};
	$i++;
      }
      foreach (sort keys %$borroweriss2) {
        $issues[$i]=$borroweriss2->{$_};
	$i++;
      }
      remoteprint(\%env,\@issues,$borrower);
      $query->param('borrnumber','')
    }
    unless ($noheader) {
      print <<EOF
      <p align=right>
      <FONT SIZE=2  face="arial, helvetica">
      <a href=circulation.pl?borrnumber=$borrowernumber&module=issues&branch=$branch&printer=$printer&print>Next Borrower</a> ||
      <a href=circulation.pl?module=returns&branch=$branch&printer=$printer>Returns</a></font><p>
       
        
	</p>
EOF
    }
    if (my $borrnumber=$query->param('borrnumber')) {
	my ($borrower, $flags) = getpatroninformation(\%env,$borrnumber,0);
	my $year=$query->param('year');
	my $month=$query->param('month');
	my $day=$query->param('day');
	if (my $barcode=$query->param('barcode')) {
          # decode cuecat
          chomp($barcode);
          @fields = split(/\./,$barcode);
          @results = map(decode($_), @fields[1..$#fields]);
          if ($#results == 2)
          {
      	    $barcode=$results[2];
          }
          # end decode
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
			print "Invalid Due Date Specified. Book was not issued. Only 30 days in $month month.<p>\n";
			$invalidduedate=1;
		    } elsif (($day>29) && ($month==2)) {
			print "Invalid Due Date Specified. Book was not issued.  Never that many days in February!<p>\n";
			$invalidduedate=1;
		    } elsif (($month==2) && ($day>28) && (($year%4) && ((!($year%100) || ($year%400))))) {
			print "Invalid Due Date Specified. Book was not issued.  $year is not a leap year.<p>\n";
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
		my ($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer, $message) = issuebook(\%env, $borrower, $barcode, \%responses);
		unless ($iteminformation) {
		    print << "EOF";
		    <table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
		    <tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Error</font></th></tr>
		    <tr><td>
		    <table border=0 cellpadding=5>
		    <tr><td>
		    $barcode is not a valid barcode.
		    </td></tr>
		    </table>
EOF
		}
		if ($rejected) {
		    if ($rejected == -1) {
		    } else {
			print << "EOF"
			<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
			<tr><th bgcolor= background=$backgroundimage><font color=black>Error Issuing Book</font></th></tr>
			<tr><td><font color=red>$rejected</font></td></tr>
			</table>
			<br>
EOF
		    }
		}
		my $responsesform='';
		foreach (keys %responses) {
		    $responsesform.="<input type=hidden name=response-$_ value=$responses{$_}>\n";
		}
		if ($question) {
		    my $stickyduedate=$query->param('stickyduedate');
		    print << "EOF";
		    <table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
		    <tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black><b>Issuing Question</b></font></td></tr>
		    <tr><td>
		    <table border=0 cellpadding=10>
		    <tr><td>
		    Attempting to issue $iteminformation->{'title'} by $iteminformation->{'author'} to $borrower->{'firstname'} $borrower->{'surname'}.
		    <p>
		    $question
		    </td></tr>
		    </table>
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
		    <input type=hidden name=branch value=$branch>
		    <input type=hidden name=printer value=$printer>
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
		    return;
		}
		if ($message) {
		    print << "EOF";
		    <table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
		    <tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black>Message</font></th></tr>
		    <tr><td>$message</td></tr>
		    </table>
		    <p>
EOF
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
		$flaginfotext.="<tr><td bgcolor=red valign=top><font color=black><b>$flag</b></font></td><td bgcolor=red><font color=black><b>$flags->{$flag}->{'message'}</b></font></td></tr>\n";
	    } else {
		$flaginfotext.="<tr><td valign=top>$flag</td><td>$flags->{$flag}->{'message'}</td></tr>\n";
	    }
	}
	if ($flaginfotext) {
	    $flaginfotext="<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd><tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage colspan=2><font color=black>Patron Flags</font></th></tr>$flaginfotext</table>\n";
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
	my $color='';
	foreach (sort keys %$borrowerissues) {
	    ($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	    my $bookissue=$borrowerissues->{$_};
	    my $bgcolor='';
	    my $datedue=$bookissue->{'date_due'};
	    my $dd=$bookissue->{'date_due'};
	    $datedue=~s/-//g;
	    if ($datedue < $todaysdate) {
		$dd="<font color=red>$dd</font>\n";
	    }
	    $previssues.="<tr><td bgcolor=$color align=center>$dd</td><td bgcolor=$color align=center><a href=/cgi-bin/koha/detail.pl?bib=$bookissue->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$bookissue->{'barcode'}</a></td><td bgcolor=$color>$bookissue->{'title'}</td><td bgcolor=$color>$bookissue->{'author'}</td><td bgcolor=$color align=center>$bookissue->{'dewey'} $bookissue->{'subclass'}</td></tr>\n";
	}
	my $todaysissues='';
	$color='';
	foreach (sort keys %$today) {
	    ($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	    my $bookissue=$today->{$_};
	    $todaysissues.="<tr><td bgcolor=$color align=center>$bookissue->{'date_due'}</td><td bgcolor=$color align=center><a href=/cgi-bin/koha/detail.pl?bib=$bookissue->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$bookissue->{'barcode'}</a></td><td bgcolor=$color>$bookissue->{'title'}</td><td bgcolor=$color>$bookissue->{'author'}</td><td bgcolor=$color align=center>$bookissue->{'dewey'} $bookissue->{'subclass'}</td></tr>\n";
	}
	for ($i=1; $i<32; $i++) {
	    my $selected='';
	    if (($query->param('stickyduedate')) && ($day==$i)) {
		$selected='selected';
	    }
	    $dayoptions.="<option value=$i $selected>$i";
	}
	my $counter=1;
	foreach (('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')) {
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
	my ($borrower, $flags) = getpatroninformation(\%env,$borrnumber,0);
	my ($patrontable, $flaginfotable) = patrontable($borrower);
	print << "EOF";
	$patrontable
	$flaginfotable
	<FONT SIZE=6><em>Issues</em></FONT> &nbsp; &nbsp;<br> <a href=circulation.pl?selectnewbranchprinter=1><b>Branch:</b></a> $branch,
	 <a href=circulation.pl?selectnewbranchprinter=1><b>Printer:</b></a> $printer<P>
	 <p>
	<form method=get>
    <table border=1 cellpadding=5>
    <tr>
	<td align=center valign=top>
	    <table border=0 cellspacing=0 cellpadding=5>
	        <tr><th align=center background=$backgroundimage><font color=black><b>Enter Book Barcode</b></font></th></tr>
		<tr><td align=center>
		<table border=0>
		<tr><td>Item Barcode:</td><td><input name=barcode size=10></td><td><input type=submit value=Issue></tr>
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
       	<input type=hidden name=module value=issues>
	<input type=hidden name=borrnumber value=$borrnumber>
	<input type=hidden name=branch value=$branch>
	<input type=hidden name=printer value=$printer>
	</form>
	</td>


    </tr>
    </table>
    </table>
    
    <p clear=all>
<!-- issues tables-->
	<table border=1 cellpadding=5 cellspacing=0 width=90%>
	<td colspan=2 align=center>
	<table border=0 cellpadding=5 cellspacing=0 width=100% > 
	    <tr><th colspan=5 bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black><b>Issues Today</b></font></th></tr>
	    <tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Class</th></tr>
	    $todaysissues
	</table>
	</td>
    </tr>

    <tr>
	<td colspan=2 align=center>
	<table border=0 cellpadding=5 cellspacing=0 width=100%>
	    <tr><th colspan=5 bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black><b>Previous Issues</b></font></th></tr>
	    <tr><th>Due Date</th><th>Bar Code</th><th>Title</th><th>Author</th><th>Class</th></tr>
	    $previssues
	</table>
	</td>
    </tr>
</table>
</td></tr></table>
<p>
EOF
    } else {
	if (my $findborrower=$query->param('findborrower')) {
	    my ($borrowers, $flags) = findborrower(\%env, $findborrower);
	    my @borrowers=@$borrowers;
	    if ($#borrowers == -1) {
		$query->param('findborrower', '');
		print "No borrower matched '$findborrower'<p>\n";
		issues(1);
		return;
	    }
	    if ($#borrowers == 0) {
		$query->param('borrnumber', $borrowers[0]->{'borrowernumber'});
		$query->param('barcode',' ');
		issues(1);
		return;
	    } else {
		print "<form method=get>\n";
		print "<input type=hidden name=module value=issues>\n";
		print "<input type=hidden name=branch value=$branch>\n";
		print "<input type=hidden name=printer value=$printer>\n";
		print "<input type=hidden name=barcode value=\" \">\n";
		print "<table border=0 cellspacing=0 cellpadding=5 bgcolor=#dddddd>";
		print "<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black><b>Select a borrower</b></font></th></tr>\n";
		print "<tr><td align=center>\n";
		print "<select name=borrnumber size=7>\n";
		foreach (sort {$a->{'surname'}.$a->{'firstname'} cmp $b->{'surname'}.$b->{'firstname'}} @$borrowers) {
		    print "<option value=$_->{'borrowernumber'}>$_->{'surname'}, $_->{'firstname'} ($_->{'cardnumber'})\n";
		}
		print "</select><br>";
		print "<input type=submit>\n";
		print "</td></tr></table>\n";
		print "</td></tr></table>\n";
	    }
	} else {
	    print << "EOF";
<form method=get>
<table border=0 cellpadding=5 cellspacing=0 bgcolor=#dddddd>
<tr><th bgcolor=$headerbackgroundcolor background=$backgroundimage><font color=black><b>Enter borrower card number<br> or partial last name</b></font></td></tr>
<tr><td><input name=findborrower></td></tr>
</table>
<input type=hidden name=module value=issues>
<input type=hidden name=branch value=$branch>
<input type=hidden name=printer value=$printer>
<input type=hidden name=barcode value=" ">
</form>
</td></tr></table>
EOF
	}
    }
}


sub patrontable {
    my ($borrower) = @_;
    my $flags=$borrower->{'flags'};
    my $flagtext='';
    my $flaginfotable='';
    my $flaginfotext='';
    my $flag;
    foreach $flag (sort keys %$flags) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	if ($flags->{$flag}->{'noissues'}) {
	    $flagtext.="<font color=red>$flag</font> ";
	} else {
	    $flagtext.="$flag ";
	}
	$flags->{$flag}->{'message'}=~s/\n/<br>/g;
	if ($flags->{$flag}->{'noissues'}) {
	    if ($flag eq 'CHARGES') {
		$flaginfotext.="<tr><td valign=top><font color=red>$flag</font></td><td bgcolor=$color><b>$flags->{$flag}->{'message'}</b> <a href=/cgi-bin/koha/pay.pl?bornum=$borrower->{'borrowernumber'} onClick=\"openWindow(this, 'Payment', 480,640)\">Payment</a></td></tr>\n";
	    } else {
		$flaginfotext.="<tr><td valign=top><font color=red>$flag</font></td><td bgcolor=$color>$flags->{$flag}->{'message'}</td></tr>\n";
	    }
	} else {
	    if ($flag eq 'CHARGES') {
		$flaginfotext.="<tr><td valign=top>$flag</td><td $flags->{$flag}->{'message'} <a href=/cgi-bin/koha/pay.pl?bornum=$borrower->{'borrowernumber'} onClick=\"openWindow(this, 'Payment', 480,640)\">Payment</a></td></tr>\n";
	    } elsif ($flag eq 'WAITING') {
		my $itemswaiting='';
		my $items=$flags->{$flag}->{'itemlist'};
		foreach $item (@$items) {
		    my ($iteminformation) = getiteminformation($env, $item->{'itemnumber'}, 0);
		    $itemswaiting.="<a href=/cgi-bin/koha/detail.pl?bib=$iteminformation->{'biblionumber'}&type=intra onClick=\"openWindow(this, 'Item', 480, 640)\">$iteminformation->{'barcode'}</a> $iteminformation->{'title'} ($branches->{$iteminformation->{'holdingbranch'}}->{'branchname'})<br>\n";
		}
		$flaginfotext.="<tr><td valign=top>$flag</td><td>$itemswaiting</td></tr>\n";
	    } elsif ($flag eq 'ODUES') {
		my $items=$flags->{$flag}->{'itemlist'};
		my $itemswaiting="<table border=0 cellspacing=0 cellpadding=2>\n";
		my $currentcolor=$color;
		{
		    my $color=$currentcolor;
		    foreach $item (@$items) {
			($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
			my ($iteminformation) = getiteminformation($env, $item->{'itemnumber'}, 0);
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
    ($flaginfotext) && ($flaginfotext="<tr><td bgcolor=$headerbackgroundcolor background=$backgroundimage colspan=2><b>Flags</b></td></tr>$flaginfotext</table>\n");
    my $patrontable= << "EOF";
    <table border=1
    cellpadding=5 cellspacing=0 align=right>
    <tr><td bgcolor=$headerbackgroundcolor background=$backgroundimage colspan=2><font color=black><b>Patron Information</b></font></td></tr>
    <tr><td colspan=2>
    <a href=/cgi-bin/koha/moremember.pl?bornum=$borrower->{'borrowernumber'} onClick="openWindow(this,'Member', 480, 640)">$borrower->{'cardnumber'}</a> $borrower->{'surname'}, $borrower->{'title'} $borrower->{'firstname'}<br>
EOF
    if ($query->param('module') ne 'returns'){ 
       $patrontable.="$borrower->{'streetaddress'} $borrower->{'city'} Cat:
       $borrower->{'categorycode'} ";
     }
    $patrontable.=<< "EOF";
    
    </td></tr>

EOF
    return($patrontable, $flaginfotext);
}
