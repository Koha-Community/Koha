#!/usr/bin/perl
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
use C4::Circulation::Circ2;
use C4::Search;
use C4::Output;
use C4::Print;
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Date;

my $query=new CGI;
#my ($loggedinuser, $sessioncookie, $sessionID) = checkauth
#	($query, 0, { circulate => 1 });

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
	template_name	=> 'circ/circulation.tmpl',
	query		=> $query,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });


my %env;
my $linecolor1='#ffffcc';
my $linecolor2='white';

my $branches = getbranches();
my $printers = getprinters(\%env);

my $branch = getbranch($query, $branches);
my $printer = getprinter($query, $printers);


#set up cookie.....
my $branchcookie;
my $printercookie;
if ($query->param('setcookies')) {
	$branchcookie = $query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
	$printercookie = $query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');
}

$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

my @datearr = localtime(time());
# FIXME - Could just use POSIX::strftime("%Y%m%d", localtime);
my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", ($datearr[3]));
#warn $todaysdate;


my $message;
my $borrowerslist;
# if there is a list of find borrowers....
my $findborrower = $query->param('findborrower');
if ($findborrower) {
	my ($count,$borrowers)=BornameSearch(\%env,$findborrower,'web');
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

my $year=$query->param('year');
my $month=$query->param('month');
my $day=$query->param('day');

# if the barcode is set
if ($barcode) {
	$barcode = cuecatbarcodedecode($barcode);
	my ($datedue, $invalidduedate) = fixdate($year, $month, $day);
	unless ($invalidduedate) {
		$env{'datedue'}=$datedue;
		my @time=localtime(time);
		my $date= (1900+$time[5])."-".($time[4]+1)."-".$time[3];
		($iteminformation, $duedate, $rejected, $question, $questionnumber, $defaultanswer, $message)
					= issuebook(\%env, $borrower, $barcode, \%responses, $date);
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
if ($borrower) {
    ($borrower, $flags,$hash) = getpatroninformation(\%env,$borrowernumber,0);
    $allowborrow= $hash->{'borrow'};
    my @todaysissues;
    my @previousissues;
    my $issueslist = getissues($borrower);
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
	foreach my $book (sort {$b->{'timestamp'} <=> $a->{'timestamp'}} @todaysissues){
		my $dd = $book->{'date_due'};
		my $datedue = $book->{'date_due'};
		$dd=format_date($dd);
		$datedue=~s/-//g;
		if ($datedue < $todaysdate) {
			$dd="<font color=red>$dd</font>\n";
		}
		($tcolor eq $linecolor1) ? ($tcolor=$linecolor2) : ($tcolor=$linecolor1);
		$book->{'dd'}=$dd;
		$book->{'tcolor'}=$tcolor;
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
	$datedue=~s/-//g;
	if ($datedue < $todaysdate) {
	    $dd="<font color=red>$dd</font>\n";
	}
	($pcolor eq $linecolor1) ? ($pcolor=$linecolor2) : ($pcolor=$linecolor1); 
	$book->{'dd'}=$dd; 
	$book->{'tcolor'}=$pcolor; 
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
		firstname => $borrower->{'firstname'},
		surname => $borrower->{'surname'},
		categorycode => $borrower->{'categorycode'},
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
    my $flaginfotext;
    #my $flaginfotext='';
    my $flag;
    my $color='';
    foreach $flag (sort keys %$flags) {
    	warn $flag;
    	my @itemswaiting='';
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$flags->{$flag}->{'message'}=~s/\n/<br>/g;
	if ($flags->{$flag}->{'noissues'}) {
		$template->param(
			noissues => 'true',
			color => $color,
			 );
		if ($flag eq 'CHARGES') {
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
			my $currentcolor=$color;
			{
			my $color=$currentcolor;
			foreach my $item (@$items) {
				($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
				my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
				push @itemswaiting, $iteminformation;
			}
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
    my ($borroweriss2)=currentissues($env, $borrower);
    $env->{'nottodaysissues'}=0;
    my $i=0;
    my @issues;
    foreach (sort {$a <=> $b} keys %$borrowerissues) {
	$issues[$i]=$borrowerissues->{$_};
	my $dd=$issues[$i]->{'date_due'};
	#convert to nz style dates
	#this should be set with some kinda config variable
	my @tempdate=split(/-/,$dd);
	$issues[$i]->{'date_due'}="$tempdate[2]/$tempdate[1]/$tempdate[0]";
	$i++;
    }
    foreach (sort {$a <=> $b} keys %$borroweriss2) {
	$issues[$i]=$borroweriss2->{$_};
	my $dd=$issues[$i]->{'date_due'};
	#convert to nz style dates
	#this should be set with some kinda config variable
	my @tempdate=split(/-/,$dd);
	$issues[$i]->{'date_due'}="$tempdate[2]/$tempdate[1]/$tempdate[0]";
	$i++;
    }
    remoteprint($env,\@issues,$borrower);
}

# Local Variables:
# tab-width: 8
# End:
