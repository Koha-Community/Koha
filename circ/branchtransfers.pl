#!/usr/bin/perl
# WARNING: This file uses 4-character tabs!

#written 11/3/2002 by Finlay
#script to execute branch transfers of books


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
use C4::Output;
use C4::Reserves2;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

###############################################
# constants

my %env;
my $headerbackgroundcolor='#99cc33';
my $circbackgroundcolor='#ffffcc';
my $circbackgroundcolor='white';
my $linecolor1='#ffffcc';
my $linecolor2='white';
my $backgroundimage="/images/background-mem.gif";

my $branches = getbranches();
my $printers = getprinters(\%env);


###############################################
#  Getting state

my $query=new CGI;
my ($loggedinuser, $sessioncookie, $sessionID) = checkauth($query);


my $branch = $query->param("branch");
my $printer = $query->param("printer");

($branch) || ($branch=$query->cookie('branch')) ;
($printer) || ($printer=$query->cookie('printer')) ;

($branches->{$branch}) || ($branch=(keys %$branches)[0]);
($printers->{$printer}) || ($printer=(keys %$printers)[0]);

my $genbrname = $branches->{$branch}->{'branchname'} ;
my $genprname = $printers->{$printer}->{'printername'};

my $messages;
my $found;
my $reserved;
my $waiting;
my $reqmessage;
my $cancelled;
my $setwaiting;
my $reqbrchname;

my $request=$query->param('request');
my $borrnum = $query->param('borrowernumber');

my $tobranchcd=$query->param('tobranchcd');
my $frbranchcd='';

############
# Deal with the requests....
if ($request eq "KillWaiting") {
    my $item = $query->param('itemnumber');
    CancelReserve(0, $item, $borrnum);
	$cancelled = 1;
	$reqmessage =1;
}

my $ignoreRs = 0;
if ($request eq "SetWaiting") {
    my $item = $query->param('itemnumber');
    $tobranchcd = ReserveWaiting($item, $borrnum);
	$reqbrchname = $branches->{$tobranchcd}->{'branchname'};
    $ignoreRs = 1;
	$setwaiting = 1;
	$reqmessage =1;
}
if ($request eq 'KillReserved'){
    my $biblio = $query->param('biblionumber');
    CancelReserve($biblio, 0, $borrnum);
	$cancelled = 1;
	$reqmessage =1;
}



# set up the branchselect options....
my @branchoptionloop;
foreach my $br (keys %$branches) {
    (next) unless $branches->{$br}->{'CU'};
    my %branch;
    $branch{selected}=($br eq $tobranchcd);
	$branch{code}=$br;
	$branch{name}=$branches->{$br}->{'branchname'};
	push (@branchoptionloop, \%branch);
}


# collect the stack of books already transfered so they can printed...
my @trsfitemloop;
my %transfereditems;
my %frbranchcds;
my %tobranchcds;
my $color=$linecolor2;

my $barcode = $query->param('barcode');
if ($barcode) {
	my $transfered;
	my $iteminformation;
	($transfered, $messages, $iteminformation)
			= transferbook($tobranchcd, $barcode, $ignoreRs);
	$found = $messages->{'ResFound'};
	if ($transfered) {
		my %item;
		my $frbranchcd = $iteminformation->{'holdingbranch'};
		if (not ($found)) {
			($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
			$item{'color'}=$color;
			$item{'biblionumber'}=$iteminformation->{'biblionumber'};
			$item{'title'}=$iteminformation->{'title'};
			$item{'author'}=$iteminformation->{'author'};
			$item{'itemtype'}=$iteminformation->{'itemtype'};
			$item{'frbrname'}=$branches->{$frbranchcd}->{'branchname'};
			$item{'tobrname'}=$branches->{$tobranchcd}->{'branchname'};
		}
		$item{counter}=0;
		$item{barcode}=$barcode;
		$item{frombrcd}=$frbranchcd;
		$item{tobrcd}=$tobranchcd;
##########
#Are these lines still useful ???
		$transfereditems{0}=$barcode;
		$frbranchcds{0}=$frbranchcd;
		$tobranchcds{0}=$tobranchcd;
##########
		push (@trsfitemloop, \%item);
	}
}

foreach ($query->param){
	(next) unless (/bc-(\d*)/);
	my $counter=$1;
	my %item;
	my $bc=$query->param("bc-$counter");
	my $frbcd=$query->param("fb-$counter");
	my $tobcd=$query->param("tb-$counter");
	$counter++;
	$item{counter}=$counter;
	$item{barcode}=$bc;
	$item{frombrcd}=$frbcd;
	$item{tobrcd}=$tobcd;
	my ($iteminformation) = getiteminformation(\%env, 0, $bc);
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$item{'color'}=$color;
	$item{'biblionumber'}=$iteminformation->{'biblionumber'};
	$item{'title'}=$iteminformation->{'title'};
	$item{'author'}=$iteminformation->{'author'};
	$item{'itemtype'}=$iteminformation->{'itemtype'};
	$item{'frbrname'}=$branches->{$frbcd}->{'branchname'};
	$item{'tobrname'}=$branches->{$tobcd}->{'branchname'};
##########
#Are these lines still useful ???
	$transfereditems{$counter}=$bc;
	$frbranchcds{$counter}=$frbcd;
	$tobranchcds{$counter}=$tobcd;
#########
	push (@trsfitemloop, \%item);
}


my $name;
my $bornum;
my $borcnum;
my $itemnumber;
my $biblionum;
my $branchname;


#####################

if ($found) {
    my $res = $messages->{'ResFound'};
	$branchname = $branches->{$res->{'branchcode'}}->{'branchname'};
	my ($borr) = getpatroninformation(\%env, $res->{'borrowernumber'}, 0);
	$name = name($borr);
	$bornum = $borr->{'borrowernumber'}; #Hopefully, borr->{borrowernumber}=res->{borrowernumber}
	$borcnum = $borr->{'cardnumber'};
	$itemnumber = $res->{'itemnumber'};

	if ($res->{'ResFound'} eq "Waiting") {
		$waiting = 1;
	}
	if ($res->{'ResFound'} eq "Reserved") {
		$reserved = 1;
		$biblionum = $res->{'biblionumber'};
	}
}

#####################

my @errmsgloop;
foreach my $code (keys %$messages) {
	my %err;
    $err{errbadcode} = ($code eq 'BadBarcode');
	if ($code eq 'BadBarcode') {
		$err{msg}=$messages->{'BadBarcode'};
	}

    $err{errispermanent} = ($code eq 'IsPermanent');
    if ($code eq 'IsPermanent'){
		$err{msg} = $branches->{$messages->{'IsPermanent'}}->{'branchname'};
		# Here, msg contains the branchname
		# Not so satisfied with this... But should work
    }
    $err{errdesteqholding} = ($code eq 'DestinationEqualsHolding');

	$err{errwasreturned} = ($code eq 'WasReturned');
	if ($code eq 'WasReturned') {
		my ($borrowerinfo) = getpatroninformation(\%env, $messages->{'WasReturned'}, 0);
		$name =name($borrowerinfo);
		$bornum =$borrowerinfo->{'borrowernumber'};
		$borcnum =$borrowerinfo->{'cardnumber'};
    }
    if ($code eq 'WasTransfered'){
# Put code here if you want to notify the user that item was transfered...
    }
	push (@errmsgloop, \%err);
}


#######################################################################################
# Make the page .....
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "circ/branchtransfers.tmpl",
							query => $query,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {parameters => 1},
                         });
$template->param(	genbrname => $genbrname,
								genprname => $genprname,
								branch => $branch,
								printer => $printer,
								found => $found,
								hdrbckgdcolor => $headerbackgroundcolor,
								bckgdimg => $backgroundimage,
								reserved => $reserved,
								waiting => $waiting,
								name => $name,
								bornum => $bornum,
								borcnum => $borcnum,
								branchname => $branchname,
								itemnumber => $itemnumber,
								barcode => $barcode,
								biblionumber => $biblionum,
								tobranchcd => $tobranchcd,
								reqmessage => $reqmessage,
								cancelled => $cancelled,
								setwaiting => $setwaiting,
								trsfitemloop => \@trsfitemloop,
								branchoptionloop => \@branchoptionloop,
								errmsgloop => \@errmsgloop
							);
output_html_with_http_headers $query, $sessioncookie, $template->output;


sub name {
	my ($borinfo) = @_;
	return $borinfo->{'surname'}." ".$borinfo->{'title'}." ".$borinfo->{'firstname'};
}

# Local Variables:
# tab-width: 4
# End:
