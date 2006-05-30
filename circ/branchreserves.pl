#!/usr/bin/perl

# $Id$

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
use C4::Context;
use C4::Output;
use CGI;
use HTML::Template;
use C4::Auth;
use C4::Date;
use C4::Circulation::Circ2;
use Date::Manip;
use C4::Reserves2;
use C4::Search;
use C4::Koha;

my $input = new CGI;

my $item=$input->param('itemnumber');
my $borrowernumber=$input->param('borrowernumber');
my $fbr=$input->param('fbr');
my $tbr=$input->param('tbr');

my $cancel;


my $theme = $input->param('theme'); # only used if allowthemeoverride is set

my ($template, $loggedinuser, $cookie)
      = get_template_and_user({template_name => "circ/branchreserves.tmpl",
	                                 query => $input,
	                                 type => "intranet",
	                                 authnotrequired => 0,
	                                 flagsrequired => {borrowers => 1},
	                                 debug => 1,
	                                 });

my $default = C4::Context->userenv->{'branch'};

my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);


# if we have a return from the form we launch the subroutine CancelReserve
	if ($item){
		my $messages;
		my $nextreservinfo;
		my %env;
		my $waiting;
		($messages,$nextreservinfo) = GlobalCancel($item,$borrowernumber);
# 		if we have a result 
		if ($nextreservinfo){
			my $borrowerinfo = getpatroninformation(\%env,$nextreservinfo);
			my $iteminfo = C4::Circulation::Circ2::getiteminformation(\%env,$item);
			if ($messages->{'transfert'}){
			my $branchname = getbranchname($messages->{'transfert'});
				$template->param(
					messagetransfert => $messages->{'transfert'},
					branchname 	=> $branchname,
				);
			}
			if ($messages->{'waiting'}){
			$waiting = 1;
			}

				$template->param(
					message			=> 1,
					nextreservnumber  =>  $nextreservinfo,
					nextreservsurname => $borrowerinfo->{'surname'},
					nextreservfirstname => $borrowerinfo->{'firstname'},
					nextreservitem		=> $item,
					nextreservtitle		=> $iteminfo->{'title'},
					waiting 		=> $waiting
				);
			}
# 		if the document is not in his homebranch location and there is not reservation after, we transfer it
		if (($fbr ne $tbr) and (not $nextreservinfo)){
			C4::Circulation::Circ2::dotransfer($item,$fbr,$tbr);
		}
	}
	
my @reservloop;
my @getreserves = GetReservesForBranch($default);
foreach my $num (@getreserves) {
	my %getreserv;
	my %env;
	my $gettitle = getiteminformation(\%env,$num->{'itemnumber'});
	my $getborrower = getpatroninformation (\%env,$num->{'borrowernumber'});
	my $itemtypeinfo = getitemtypeinfo($gettitle->{'itemtype'});
	$getreserv{'waitingdate'} = format_date($num->{'waitingdate'});
	my $calcDate=DateCalc($num->{'waitingdate'},"+".C4::Context->preference('ReservesMaxPickUpDelay')."  days");
	my $warning=Date_Cmp(ParseDate("today"),$calcDate);
	if ($warning>0){
		$getreserv{'messcompa'} = 1;
	}
	$getreserv{'title'} = $gettitle->{'title'};
	$getreserv{'itemnumber'} = $gettitle->{'itemnumber'};
	$getreserv{'biblionumber'} = $gettitle->{'biblionumber'};
	$getreserv{'barcode'} = $gettitle->{'barcode'};
	$getreserv{'itemtype'} = $itemtypeinfo->{'description'};
	$getreserv{'homebranch'} = $gettitle->{'homebranch'};
	$getreserv{'holdingbranch'} = $gettitle->{'holdingbranch'};
	if ($gettitle->{'homebranch'} ne $gettitle->{'holdingbranch'}){
		$getreserv{'dotransfer'} = 1;
		}
	$getreserv{'itemcallnumber'} = $gettitle->{'itemcallnumber'};
	$getreserv{'borrowernum'} = $getborrower->{'borrowernumber'};
	$getreserv{'borrowername'} = $getborrower->{'surname'};
	$getreserv{'borrowerfirstname'} =  $getborrower->{'firstname'} ;
	if ($getborrower->{'emailaddress'}){
		$getreserv{'borrowermail'} =  $getborrower->{'emailaddress'} ;
	}
	$getreserv{'borrowerphone'} = $getborrower->{'phone'};
	push(@reservloop, \%getreserv);
}

	$template->param( reserveloop       => \@reservloop,
			show_date	=> format_date($todaysdate),	
			 );
	
	print "Content-Type: text/html\n\n", $template->output;