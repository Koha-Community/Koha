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

#
# PARAMETERS READING
#
my $query=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
	template_name	=> 'circ/circulation.tmpl',
	query		=> $query,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });
my $branches = getbranches();
my $printers = getprinters();
my $branch = getbranch($query, $branches);
my $printer = getprinter($query, $printers);

my $findborrower = $query->param('findborrower');
my $borrowernumber = $query->param('borrnumber');
my $print=$query->param('print');
my $barcode = $query->param('barcode');
my $year=$query->param('year');
my $month=$query->param('month');
my $day=$query->param('day');
my $stickyduedate=$query->param('stickyduedate');
my $issueconfirmed = $query->param('issueconfirmed');


#set up cookie.....
my $branchcookie;
my $printercookie;
if ($query->param('setcookies')) {
	$branchcookie = $query->cookie(-name=>'branch', -value=>"$branch", -expires=>'+1y');
	$printercookie = $query->cookie(-name=>'printer', -value=>"$printer", -expires=>'+1y');
}

my %env; # FIXME env is used as an "environment" variable. Could be dropped probably...
$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;

my @datearr = localtime(time());
# FIXME - Could just use POSIX::strftime("%Y%m%d", localtime);
my $todaysdate = (1900+$datearr[5]).sprintf ("%0.2d", ($datearr[4]+1)).sprintf ("%0.2d", ($datearr[3]));

# my $message;

#
# STEP 2 : FIND BORROWER
# if there is a list of find borrowers....
#
my $borrowerslist;
if ($findborrower) {
	my ($count,$borrowers)=BornameSearch(\%env,$findborrower,'web');
	my @borrowers=@$borrowers;
	if ($#borrowers == -1) {
		$query->param('findborrower', '');
	} elsif ($#borrowers == 0) {
		$query->param('borrnumber', $borrowers[0]->{'borrowernumber'});
		$query->param('barcode','');
		$borrowernumber=$borrowers[0]->{'borrowernumber'};
	} else {
		$borrowerslist = \@borrowers;
	}
}

# get the borrower information.....
my $borrower;
if ($borrowernumber) {
	$borrower = getpatroninformation(\%env,$borrowernumber,0);
	my ($od,$issue,$fines)=borrdata2(\%env,$borrowernumber);
	$template->param(overduecount => $od,
							issuecount => $issue,
							finetotal => $fines);
}


#
# STEP 3 : ISSUING
#
#

# check and see if we should print
# if ($barcode eq ''  && $print eq 'maybe'){
# 	$print = 'yes';
# }
# if ($print eq 'yes' && $borrowernumber ne ''){
# 	printslip(\%env,$borrowernumber);
# 	$query->param('borrnumber','');
# 	$borrowernumber='';
# }

if ($barcode) {
	$barcode = cuecatbarcodedecode($barcode);
	my ($datedue, $invalidduedate) = fixdate($year, $month, $day);
	if ($issueconfirmed) {
			issuebook(\%env, $borrower, $barcode, $datedue);
	} else {
		my ($error, $question) = canbookbeissued(\%env, $borrower, $barcode, $year, $month, $day);
		my $noerror=1;
		my $noquestion = 1;
		foreach my $impossible (keys %$error) {
			$template->param($impossible => $$error{$impossible},
							IMPOSSIBLE => 1);
			$noerror = 0;
		}
		foreach my $needsconfirmation (keys %$question) {
			$template->param($needsconfirmation => $$question{$needsconfirmation},
							NEEDSCONFIRMATION => 1);
			$noquestion = 0;
		}
		$template->param(day => $day,
						month => $month,
						year => $year);
		if ($noerror && ($noquestion || $issueconfirmed)) {
			issuebook(\%env, $borrower, $barcode, $datedue);
		}
	}
}

# reload the borrower info for the sake of reseting the flags.....
if ($borrowernumber) {
	$borrower = getpatroninformation(\%env,$borrowernumber,0);
}


##################################################################################
# BUILD HTML

# make the issued books table.....
my $todaysissues='';
my $previssues='';
my @realtodayissues;
my @realprevissues;
my $allowborrow;
if ($borrower) {
# get each issue of the borrower & separate them in todayissues & previous issues
	my @todaysissues;
	my @previousissues;
	my $issueslist = getissues($borrower);
	# split in 2 arrays for today & previous
	foreach my $it (keys %$issueslist) {
		my $issuedate = $issueslist->{$it}->{'timestamp'};
		$issuedate = substr($issuedate, 0, 8);
		if ($todaysdate == $issuedate) {
			push @todaysissues, $issueslist->{$it};
		} else {
			push @previousissues, $issueslist->{$it};
		}
    }
	my $od; # overdues
	my $togglecolor;
	# parses today & build Template array
	foreach my $book (sort {$b->{'timestamp'} <=> $a->{'timestamp'}} @todaysissues){
		my $dd = $book->{'date_due'};
		my $datedue = $book->{'date_due'};
		$dd=format_date($dd);
		$datedue=~s/-//g;
		if ($datedue < $todaysdate) {
			$od = 1;
		} else {
			$od=0;
		}
		$book->{'od'}=$od;
		$book->{'dd'}=$dd;
		$book->{'tcolor'}=$togglecolor;
		if ($togglecolor) {
			$togglecolor=0;
		} else {
			$togglecolor=1;
		}
		if ($book->{'author'} eq ''){
			$book->{'author'}=' ';
		}    
		push @realtodayissues,$book;
	}
    
	# parses previous & build Template array
    foreach my $book (sort {$a->{'date_due'} cmp $b->{'date_due'}} @previousissues){
		my $dd = $book->{'date_due'};
		my $datedue = $book->{'date_due'};
		$dd=format_date($dd);
		my $pcolor = '';
		my $od = '';
		$datedue=~s/-//g;
		if ($datedue < $todaysdate) {
			$od = 1;
		} else {
			$od = 0;
		}
		$book->{'tcolor'}=$togglecolor;
		if ($togglecolor) {
			$togglecolor=0;
		} else {
			$togglecolor=1;
		}
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

my $amountold=$borrower->{flags}->{'CHARGES'}->{'message'};
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
		firstname => $borrower->{'firstname'},
		surname => $borrower->{'surname'},
		categorycode => $borrower->{'categorycode'},
		streetaddress => $borrower->{'streetaddress'},
		borrowernotes => $borrower->{'borrowernotes'},
		city => $borrower->{'city'},
		phone => $borrower->{'phone'},
		cardnumber => $borrower->{'cardnumber'},
		amountold => $amountold,
		barcode => $barcode,
		stickyduedate => $stickyduedate,
		CGIselectborrower => $CGIselectborrower,
		todayissues => \@realtodayissues,
		previssues => \@realprevissues,
	);
# set return date if stickyduedate
if ($stickyduedate) {
	my $t_year = "year".$year;
	my $t_month = "month".$month;
	my $t_day = "day".$day;
	$template->param(
		$t_year => 1,
		$t_month => 1,
		$t_day => 1,
	);
}


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

# Local Variables:
# tab-width: 8
# End:
