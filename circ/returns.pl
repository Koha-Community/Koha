#!/usr/bin/perl
# WARNING: This file contains mixed-sized tabs! (some 4-character, some 8)
# WARNING: Currently, 4-character tabs seem to be dominant
# WARNING: But there are still lots of 8-character tabs

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
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;


my $query=new CGI;
#getting the template
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "circ/returns.tmpl",
							query => $query,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 1},
                         });

#####################
#Global vars
my %env;
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

my $branches = getbranches();
my $printers = getprinters(\%env);

my $branch = getbranch($query, $branches);
my $printer = getprinter($query, $printers);

#
# Some code to handle the error if there is no branch or printer setting.....
#


$env{'branchcode'}=$branch;
$env{'printer'}=$printer;
$env{'queue'}=$printer;


# Set up the item stack ....
my %returneditems;
my %riduedate;
my %riborrowernumber;
my @inputloop;
foreach ($query->param) {
    (next) unless (/ri-(\d*)/);
	my %input;
    my $counter=$1;
    (next) if ($counter>20);
    my $barcode=$query->param("ri-$counter");
    my $duedate=$query->param("dd-$counter");
    my $borrowernumber=$query->param("bn-$counter");
    $counter++;
    # decode cuecat
    $barcode = cuecatbarcodedecode($barcode);
	######################
	#Are these lines still useful ?
    $returneditems{$counter}=$barcode;
    $riduedate{$counter}=$duedate;
    $riborrowernumber{$counter}=$borrowernumber;
	#######################
	$input{counter}=$counter;
	$input{barcode}=$barcode;
	$input{duedate}=$duedate;
	$input{bornum}=$borrowernumber;
	push (@inputloop, \%input);
}

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
	my $borcnum=$borr->{'cardnumber'};
    my $name = $borr->{'surname'}." ".$borr->{'title'}." ".$borr->{'firstname'};
    my $slip = $query->param('resslip');
    printslip(\%env, $slip);
    if ($tobranchcd ne $branch) {
		$template->param(	itemtitle => $iteminfo->{'title'},
										iteminfo => $iteminfo->{'author'},
										branchname => $branchname,
										name => $name,
										bornum => $borrnum,
										borcnum => $borcnum,
										diffbranch => 1);
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
    if ($returned) {
		$returneditems{0} = $barcode;
		$riborrowernumber{0} = $borrower->{'borrowernumber'};
		$riduedate{0} = $iteminformation->{'date_due'};
		my %input;
		$input{counter}=0;
		$input{first}=1;
		$input{barcode}=$barcode;
		$input{duedate}=$riduedate{0};
		$input{bornum}=$riborrowernumber{0};
		push (@inputloop, \%input);
    } elsif (! $messages->{'BadBarcode'}) {
		my %input;
		$input{counter}=0;
		$input{first}=1;
		$input{barcode}=$barcode;
		$input{duedate}=0;

		$returneditems{0} = $barcode;
		$riduedate{0} = 0;
		if ($messages->{'wthdrawn'}) {
			$input{withdrawn}=1;
			$input{bornum}="Item Cancelled";
			$riborrowernumber{0} = 'Item Cancelled';
		} else {
			$input{bornum}="&nbsp;";
			$riborrowernumber{0} = '&nbsp;';
		}
		push (@inputloop, \%input);
	}
	$template->param(	returned => $returned,
									itemtitle => $iteminformation->{'title'},
#									itembc => $iteminformation->{'barcode'},
#									itemdatedue => $iteminformation->{'datedue'},
									itemauthor => $iteminformation->{'author'});
}
$template->param(inputloop => \@inputloop);


my $found=0;
my $waiting=0;
my $reserved=0;

if ($messages->{'ResFound'}) {
    my $res = $messages->{'ResFound'};
    my $branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
    my ($borr) = getpatroninformation(\%env, $res->{'borrowernumber'}, 0);
    my $name = $borr->{'surname'}." ".$borr->{'title'}." ".$borr->{'firstname'};
    my ($iteminfo) = getiteminformation(\%env, 0, $barcode);

    if ($res->{'ResFound'} eq "Waiting") {
		$template->param(	found => 1,
										name => $name,
										bornum => $res->{'borrowernumber'},
										borcnum => $borr->{'cardnumber'},
										branchname => $branches->{$res->{'branchcode'}}->{'branchname'},
										waiting => 1,
										itemtitle => $iteminfo->{'title'},
										itemauthor => $iteminfo->{'author'});

    }
	if ($res->{'ResFound'} eq "Reserved") {
		my @da = localtime(time());
		my $todaysdate = sprintf ("%0.2d", ($da[3]+1))."/".sprintf ("%0.2d", ($da[4]+1))."/".($da[5]+1900);
		$template->param(	found => 1,
										branchname => $branches->{$res->{'branchcode'}}->{'branchname'},
										reserved => 1,
										today => $todaysdate,
										itemnum => $res->{'itemnumber'},
										itemtitle => $iteminfo->{'title'},
										itemauthor => $iteminfo->{'author'},
										itembarcode => $iteminfo->{'barcode'},
										itemtype => $iteminfo->{'itemtype'},
										itembiblionumber => $iteminfo->{'biblionumber'},
										borsurname => $borr->{'surname'},
										bortitle => $borr->{'title'},
										borfirstname => $borr->{'firstname'},
										bornum => $res->{'borrowernumber'},
										borcnum => $borr->{'cardnumber'},
										borphone => $borr->{'phone'},
										borstraddress => $borr->{'streetaddress'},
										borsub => $borr->{'suburb'},
										bortown => $borr->{'town'},
										boremail => $borr->{'emailadress'},
										barcode => $barcode
										);
    }
}

# Error Messages
my @errmsgloop;
foreach my $code (keys %$messages) {
#    warn $code;
	my %err;
	my $exit_required_p = 0;
    if ($code eq 'BadBarcode'){
		$err{badbarcode}=1;
		$err{msg}= $messages->{'BadBarcode'};
    } elsif ($code eq 'NotIssued'){
		$err{notissued}=1;
		$err{msg}= $branches->{$messages->{'IsPermanent'}}->{'branchname'};
    } elsif ($code eq 'WasLost'){
		$err{waslost}=1;
    } elsif ($code eq 'WasReturned'){
		;	# FIXME... anything to do here?
    } elsif ($code eq 'WasTransfered'){
		;	# FIXME... anything to do here?
    } elsif ($code eq 'wthdrawn'){
		$err{withdrawn}=1;
		$exit_required_p = 1;
    } elsif (($code eq 'IsPermanent') && (not $messages->{'ResFound'})) {
		if ($messages->{'IsPermanent'} ne $branch) {
				$err{ispermanent}=1;
				$err{msg}=$branches->{$messages->{'IsPermanent'}}->{'branchname'} ;
		}
    } else {
		die "Unknown error code $code"; # XXX
    }
	push (@errmsgloop, \%err);
last if $exit_required_p;
}
$template->param(errmsgloop => \@errmsgloop);

# patrontable ....
if ($borrower) {
    my $flags = $borrower->{'flags'};
    my $color = '';
	my @flagloop;
	my $flagset;
    foreach my $flag (sort keys %$flags) {
		my %flaginfo;
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		unless($flagset) { $flagset=1; }
		$flaginfo{color}=$color;
		$flaginfo{redfont} =($flags->{$flag}->{'noissues'});
		$flaginfo{flag}=$flag;
		if ($flag eq 'CHARGES') {
			$flaginfo{msg}=$flag;
			$flaginfo{charges}=1;
		} elsif ($flag eq 'WAITING') {
			$flaginfo{msg}=$flag;
			$flaginfo{waiting}=1;
			my @waitingitemloop;
			my $items = $flags->{$flag}->{'itemlist'};
			foreach my $item (@$items) {
				my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
				my %waitingitem;
				$waitingitem{biblionum}=$iteminformation->{'biblionumber'};
				$waitingitem{barcode}=$iteminformation->{'barcode'};
				$waitingitem{title}=$iteminformation->{'title'};
				$waitingitem{brname}=$branches->{$iteminformation->{'holdingbranch'}}->{'branchname'};
				push(@waitingitemloop, \%waitingitem);
			}
			$flaginfo{itemloop}=\@waitingitemloop;
		} elsif ($flag eq 'ODUES') {
			my $items = $flags->{$flag}->{'itemlist'};
			my @itemloop;
			foreach my $item (sort {$a->{'date_due'} cmp $b->{'date_due'}} @$items) {
				my ($iteminformation) = getiteminformation(\%env, $item->{'itemnumber'}, 0);
				my %overdueitem;
				$overdueitem{duedate}=$item->{'date_due'};
				$overdueitem{biblionum}=$iteminformation->{'biblionumber'};
				$overdueitem{barcode}=$iteminformation->{'barcode'};
				$overdueitem{title}=$iteminformation->{'title'};
				$overdueitem{brname}=$branches->{$iteminformation->{'holdingbranch'}}->{'branchname'};
				push(@itemloop, \%overdueitem);
			}
			$flaginfo{itemloop}=\@itemloop;
			$flaginfo{overdue}=1;
			} else {
			$flaginfo{other}=1;
			$flaginfo{msg}=$flags->{$flag}->{'message'};
		}
		push(@flagloop, \%flaginfo);
    }
	$template->param(	flagset => $flagset,
									flagloop => \@flagloop,
									ribornum => $borrower->{'borrowernumber'},
									riborcnum => $borrower->{'cardnumber'},
									riborsurname => $borrower->{'surname'},
									ribortitle => $borrower->{'title'},
									riborfirstname => $borrower->{'firstname'}
									);
}

my $color='';
#set up so only the lat 8 returned items display (make for faster loading pages)
my $count=0;
my @riloop;
foreach (sort {$a <=> $b} keys %returneditems) {
	my %ri;
    if ($count < 8) {
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		$ri{color}=$color;
		my $barcode = $returneditems{$_};
		my $duedate = $riduedate{$_};
		my $overduetext;
        my $borrowerinfo;
		if ($duedate) {
	    	my @tempdate = split ( /-/ , $duedate ) ;
            my $duedatenz = "$tempdate[2]/$tempdate[1]/$tempdate[0]";
            my @datearr = localtime(time());
            my $todaysdate = $datearr[5].'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);
	    	my ($borrower) = getpatroninformation(\%env, $riborrowernumber{$_}, 0);
			$ri{bornum}=$borrower->{'borrowernumber'};
			$ri{borcnum}=$borrower->{'cardnumber'};
			$ri{borfirstname}=$borrower->{'firstname'};
			$ri{borsurname}=$borrower->{'surname'};
			$ri{bortitle}=$borrower->{'title'};
        } else {
			$ri{bornum}=$riborrowernumber{$_};
		}
		my %ri;
		my ($iteminformation) = getiteminformation(\%env, 0, $barcode);
		$ri{color}=$color;
		$ri{itembiblionumber}=$iteminformation->{'biblionumber'};
		$ri{itemtitle}=$iteminformation->{'title'};
		$ri{itemauthor}=$iteminformation->{'author'};
		$ri{itemtype}=$iteminformation->{'itemtype'};
		$ri{barcode}=$barcode;
	} else {
		last;
    }
    $count++;
	push(@riloop,\%ri);
}
$template->param(riloop => \@riloop);

$template->param(	genbrname => $branches->{$branch}->{'branchname'},
			genprname => $printers->{$printer}->{'printername'},
			branch => $branch,
			printer => $printer,
			hdrbckgdcolor => $headerbackgroundcolor,
			bckgdimg => $backgroundimage,
			errmsgloop => \@errmsgloop
		);

# actually print the page!
output_html_with_http_headers $query, $cookie, $template->output;

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

# Local Variables:
# tab-width: 4
# End:
