#!/usr/bin/perl
#this code has been modified (slightly) by Trendsetters (originally from circulation.pl)
# Please use 8-character tabs for this file (indents are every 4 characters)

#written 8/5/2002 by Finlay
#script to execute issuing of books


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
use C4::Circulation;
use C4::Search;
use C4::Output;
use C4::Print;
use DBI;
use C4::Authsco;
use C4::Output;
use C4::Koha;
use HTML::Template::Pro;
use C4::Dates;

my $query=new CGI;
#my ($loggedinuser, $sessioncookie, $sessionID) = checkauth
#	($query, 0, { circulate => 1 });

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
#Begin code modified by Christina Lee
	template_name	=> 'sco/receipt.tmpl',
	query		=> $query,
	type		=> "opac",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => "circulate_remaining_permissions" },
# End Code Modified by Christina Lee
    });

#Begin code by Christina Lee--Sets variable $borr equal to loggedinuser's data
my ($borr, $flags) = getpatroninformation(undef, $loggedinuser);
# End code by Christina Lee

my %env;
my $linecolor1='#339999';
my $linecolor2='white';

my $branches = getbranches();
my $printers = getprinters(\%env);

my $branch = "APL"; #getbranch($query, $branches);
my $printer = getprinter($query, $printers);


#set up cookie.....
my $branchcookie;
my $printercookie;
if ($query->param('setcookies')) {
	$branchcookie  = $query->cookie(-name=>'branch',  -value=>"$branch",  -expires=>'+1y');
	$printercookie = $query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');
}

$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

my @datearr = localtime(time());
# FIXME - Could just use POSIX::strftime("%Y%m%d", localtime);
my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", ($datearr[3]));
#warn $todaysdate;

################# Start code modified by Christina Lee###########################
# get borrower information ....
#my ($borr, $flags) = getpatroninformation(undef, $loggedinusername);
#my @bordat;
#$bordat[0] = $borr;

#$template->param(BORROWER_INFO => \@bordat);

######################End code modified by christina Lee############################

my $message;
my $borrowerslist;
# if there is a list of find borrowers....
my $findborrower = $query->param('findborrower');
if ($findborrower) {
	my ($count,$borrowers)=BornameSearch(\%env,$findborrower,'web');
	my @borrowers=@$borrowers;
	if ($#borrowers == -1) {
		$query->param('findborrower', '');
		$message =  "'$findborrower'";
	} elsif ($#borrowers == 0) {
		$query->param('borrnumber', $borrowers[0]->{'borrowernumber'});
		$query->param('barcode','');
	} else {
		$borrowerslist = \@borrowers;
	}
}


my $borrowernumber = $query->param('borrnumber');
my $bornum = $query->param('borrnumber');
# check and see if we should print
my $print=$query->param('print');
my $barcode = $query->param('barcode');
if ($barcode eq ''  && $print eq 'maybe'){
	$print = 'yes';
}
if ($print eq 'yes' && $borrowernumber ne ''){
	printslip(\%env,$borrowernumber);
	$query->param('borrnumber','');
	$borrowernumber='';
}

# get the borrower information.....
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


my ($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer);
#Begin code edited by Christina Lee
#my $barc = 123456789;
my $barc = cuecatbarcodedecode($barcode);

(my $year, my $month, my $day) = set_duedate($barc);
#End code edited by Christina Lee

# if the barcode is set
if ($barcode) {
	$barcode = cuecatbarcodedecode($barcode);
 
#note: edit code here --Christina Lee
	my ($datedue, $invalidduedate) = fixdate($year, $month, $day);
	unless ($invalidduedate) {
		$env{'datedue'}=$datedue;
		my @time=localtime();
		my $date= (1900+$time[5])."-".($time[4]+1)."-".$time[3];
		($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer, $message)
					= issuebook(\%env, $borr, $barcode, \%responses, $date);
	}
}

# reload the borrower info for the sake of reseting the flags.....
if ($borrowernumber) {
	($borrower, $flags) = getpatroninformation(\%env,$borrowernumber,0);
}

##################################################################################
# HTML code....

my %responseform;
my @responsearray;
foreach (keys %responses) {
#    $responsesform.="<input type=hidden name=response-$_ value=$responses{$_}>\n";
    $responseform{'name'}=$_;
    $responseform{'value'}=$responses{$_};
    push @responsearray,\%responseform;
}
my $questionform;
my $stickyduedate;
if ($question) {
    $stickyduedate=$query->param('stickyduedate');
}


# Barcode entry box, with hidden inputs attached....

# FIXME - How can we move this HTML into the template?  Can we create
# arrays of the months, dates, etc and use <TMPL_LOOP> in the template to 
# output the data that's getting built here?
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


# make the issued books table.....
my $todaysissues='';
my $previssues='';
my @realtodayissues;
my @realprevissues;
my $allowborrow;
my $hash;
# Begin code altered by christina Lee
if ($borr) {
    ($borr, $flags,$hash) = getpatroninformation(\%env,$loggedinuser,0);
# End code altered by Christina Lee
    $allowborrow= $hash->{'borrow'};
    my @todaysissues;
    my @previousissues;
# Begin code altered by Christina Lee
    my $issueslist = getissues($borr);
# End code altered by Christina Lee
    foreach my $it (keys %$issueslist) {
	my $issuedate = $issueslist->{$it}->{'timestamp'};
	$issuedate = substr($issuedate, 0, 8);
	if ($todaysdate == $issuedate) {
	    push @todaysissues, $issueslist->{$it};
	} else {
	    push @previousissues, $issueslist->{$it};
	}
    }
	my $tcolor = '';
	my $pcolor = '';
	my $od = '';
	foreach my $book (sort {$b->{'timestamp'} <=> $a->{'timestamp'}} @todaysissues){        
		my $dd = $book->{'date_due'};
		my $datedue = $book->{'date_due'};
		$dd=format_date($dd);
		$datedue=~s/-//g;
		if ($datedue < $todaysdate) {
			$od = 'true';
			$dd="$dd\n";
		}
		$tcolor = ($tcolor eq $linecolor1) ? $linecolor2 : $linecolor1;
		$book->{'od'}=$od;
		$book->{'dd'}=$dd;
		$book->{'tcolor'}=$tcolor;
	        if ($book->{'author'} eq ''){
		    $book->{'author'}=' ';
		}
		push @realtodayissues,$book;
	}
    

    # FIXME - For small and private libraries, it'd be nice if this
    # table included a "Return" link next to each book, so that you
    # don't have to remember the book's bar code and type it in on the
    # "Returns" page.

    # This is in the template now, so its possible for a small library to make that link in their
    # template

    foreach my $book (sort {$a->{'date_due'} cmp $b->{'date_due'}} @previousissues){
		my $dd = $book->{'date_due'};
		my $datedue = $book->{'date_due'};
		$dd=format_date($dd);
		my $pcolor = '';
		my $od = '';
		$datedue=~s/-//g;
		if ($datedue < $todaysdate) {
			$od = 'true';
		    $dd="$dd\n";
		}
		$pcolor = ($pcolor eq $linecolor1) ? $linecolor2 : $linecolor1;
		$book->{'dd'}=$dd; 
		$book->{'od'}=$od;
		$book->{'tcolor'}=$pcolor;
		if ($book->{'author'} eq ''){
		    $book->{'author'}=' ';
		}    
		push @realprevissues,$book
	}
}

my @values;
my %labels;
my $CGIselectborrower;
if ($borrowerslist) {
	foreach (sort {$a->{'surname'}.$a->{'firstname'} cmp $b->{'surname'}.$b->{'firstname'}} @$borrowerslist){
		push @values,$_->{'borrowernumber'};
		$labels{$_->{'borrowernumber'}} ="$_->{'surname'}, $_->{'firstname'} ($_->{'cardnumber'})";
	}
	$CGIselectborrower=CGI::scrolling_list( -name     => 'borrnumber',
				-values   => \@values,
				-labels   => \%labels,
				-size     => 7,
				-multiple => 0 );
}
#title

my ($patrontable, $flaginfotable) = patrontable($borrower);
my $amountold=$flags->{'CHARGES'}->{'message'};
my @temp=split(/\$/,$amountold);
$amountold=$temp[1];
$template->param(
		findborrower => $findborrower,
		borrower => $borrower,
		borrowernumber => $borrowernumber,
		branch => $branch,
		printer => $printer,
		branchname => $branches->{$branch}->{'branchname'},
		printername => $printers->{$printer}->{'printername'},
		allowborrow =>$allowborrow,
		#question form
		question => $question,
		title => $iteminformation->{'title'},
		author => $iteminformation->{'author'},
#Begin code by Christina Lee
		firstname => $borr->{'firstname'},
		surname => $borr->{'surname'},
		categorycode => $borr->{'categorycode'},
		streetaddress => $borr->{'streetaddress'},
		city => $borr->{'city'},
		phone => $borr->{'phone'},
		cardnumber => $borr->{'cardnumber'},
#End code by Christina Lee
		question => $question,
		barcode => $barcode,
		questionnumber => $questionnumber,
		dayoptions => $dayoptions,
		monthoptions => $monthoptions,
		yearoptions => $yearoptions,
		stickyduedate => $stickyduedate,
		rejected => $rejected,
		message => $message,
		CGIselectborrower => $CGIselectborrower,
		amountold => $amountold,
		todayissues => \@realtodayissues,
		previssues => \@realprevissues,
		responseloop => \@responsearray,
		month=>$month,
		day=>$day,
		year=>$year
);

if ($branchcookie) {
    $cookie=[$cookie, $branchcookie, $printercookie];
}

output_html_with_http_headers $query, $cookie, $template->output;

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
    if (($year eq 0) && ($month eq 0) && ($year eq 0)) {
		$env{'datedue'}='';
		return(undef,undef);
    } 
	
# FIXME - Can we set two flags here, one that says 'invalidduedate', so that 
# the template can check for it, and then one for a particular message?
# Ex: <TMPL_IF NAME="invalidduedate">  <TMPL_IF NAME="daysinFeb">
# Invalid Due Date Specified. Book was not issued.  Never that many days
# in February! </TMPL_IF> </TMPL_IF>

    my ($date);
	my ($invalidduedate) = "Invalid Due Date Specified. Book was not issued. ";
	if (($year eq 0) || ($month eq 0) || ($year eq 0)) {
	    $invalidduedate .= "<p>\n";
	} else {
	    if (($day>30) && (($month==4) || ($month==6) || ($month==9) || ($month==11))) {
			$invalidduedate .= "Only 30 days in $month month.<p>\n";
	    } elsif (($day > 29) && ($month == 2)) {
			$invalidduedate .= "Never that many days in February!<p>\n";
	    } elsif (($month == 2) && ($day > 28) && (($year%4) && ((!($year%100) || ($year%400))))) {
			$invalidduedate .= "$year is not a leap year.<p>\n";
	    } else {
			$date="$year-$month-$day";
	    }
	}
    return ($date, $invalidduedate);
}


sub patrontable {
    my ($borrower) = @_;
    my $flags = $borrower->{'flags'};
    my $flaginfotable='';
    my $flaginfotext;
    #my $flaginfotext='';
    my $flag;
    my $color='';
    foreach $flag (sort keys %$flags) {
    	warn $flag;
#    	my @itemswaiting='';
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$flags->{$flag}->{'message'}=~s/\n/<br>/g;
	if ($flags->{$flag}->{'noissues'}) {
		$template->param(
			noissues => 'true',
			color => $color,
		);
		if ($flag eq 'GNA'    ){ $template->param(    gna => 'true'); }
		if ($flag eq 'LOST'   ){ $template->param(   lost => 'true'); }
		if ($flag eq 'DBARRED'){ $template->param(dbarred => 'true'); }
		if ($flag eq 'CHARGES'){
			$template->param(
				charges => 'true',
				chargesmsg => $flags->{'CHARGES'}->{'message'}
			);
		}
	} else {
		if ($flag eq 'CHARGES') {
			$template->param(
				charges => 'true',
				chargesmsg => $flags->{'CHARGES'}->{'message'}
			 );
		}
	    if ($flag eq 'WAITING') {
			my $items=$flags->{$flag}->{'itemlist'};
		        my @itemswaiting;
			foreach my $item (@$items) {
				my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
				$iteminformation->{'branchname'} = $branches->{$iteminformation->{'holdingbranch'}}->{'branchname'};
				push @itemswaiting, $iteminformation;
			}
			$template->param(
				waiting => 'true',
				waitingmsg => $flags->{'WAITING'}->{'message'},
				itemswaiting => \@itemswaiting,
			 );
		}
		if ($flag eq 'ODUES') {
			$template->param(
				odues => 'true',
				oduesmsg => $flags->{'ODUES'}->{'message'}
			 );

			my $items=$flags->{$flag}->{'itemlist'};
			my $lcolor=$color;
			my @itemswaiting;
			foreach my $item (@$items) {
				$lcolor = ($lcolor eq $linecolor1) ? $linecolor2 : $linecolor1;
				my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
				push @itemswaiting, $iteminformation;
			}
			if ($query->param('module') ne 'returns'){
				$template->param( nonreturns => 'true' );
			}
		}
		if ($flag eq 'NOTES') {
			$template->param(
				notes => 'true',
				notesmsg => $flags->{'NOTES'}->{'message'}
			);
		}
	}
    }
    return($patrontable, $flaginfotext);
}


# FIXME - This clashes with &C4::Print::printslip
sub printslip {
    my ($env,$borrowernumber)=@_;
    my ($borrower, $flags) = getpatroninformation($env,$borrowernumber,0);
    $env->{'todaysissues'}=1;
    my ($borrowerissues) = currentissues($env, $borrower);
    $env->{'nottodaysissues'}=1;
    $env->{'todaysissues'}=0;
    my ($borroweriss2) = currentissues($env, $borrower);
    $env->{'nottodaysissues'}=0;
    my $i=0;
    my @issues;
    foreach (sort {$a <=> $b} keys %$borrowerissues) {
		$issues[$i]=$borrowerissues->{$_};
		$issues[$i]->{'date_due'} = C4::Dates->new($issues[$i]->{'date_due'},'iso')->output;
		# convert to syspref style date
		$i++;
    }
    foreach (sort {$a <=> $b} keys %$borroweriss2) {
		$issues[$i]=$borroweriss2->{$_};
		$issues[$i]->{'date_due'} = C4::Dates->new($issues[$i]->{'date_due'},'iso')->output;
		# convert to syspref style date
		$i++;
	}
    remoteprint($env,\@issues,$borrower);
}

# Begin code added by Christina Lee
sub set_duedate
{
	my $loanlength;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare ("select loanlength from biblioitems, biblio,itemtypes, items where barcode = ? and biblio.biblionumber = biblioitems.biblionumber and biblioitems.biblionumber = items.biblionumber and biblioitems.itemtype=itemtypes.itemtype;"); 
	$sth->execute($barc);
	while (my @val = $sth->fetchrow_array()) {
		$loanlength = @val[0];
	}
	my ($s, $min, $hr, $mday, $mo, $year, $wday, $yday) = localtime(time + $loanlength * 86400);

	#adjust month and date for output
	$year -= 100;
	$mo++;
	return ($year, $mo, $mday);
}

sub get_due_date {
	# This function is clearly unfinished. Don't rely on it yet.
	my $duedate;
	my $dbh = C4::Context->dbh;
}

# End code added by Christina Lee

# Local Variables:
# tab-width: 8
# End:

