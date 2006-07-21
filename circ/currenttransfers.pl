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
use C4::Koha;
use C4::Search;
use C4::Reserves2;

my $input = new CGI;

my $theme = $input->param('theme'); # only used if allowthemeoverride is set
my $itemnumber = $input->param('itemnumber');
# if we have a resturn of the form to delete the transfer, we launch the subrroutine
if ($itemnumber){
	C4::Circulation::Circ2::DeleteTransfer($itemnumber);
}

my ($template, $loggedinuser, $cookie)
      = get_template_and_user({template_name => "circ/currenttransfers.tmpl",
	                                 query => $input,
	                                 type => "intranet",
	                                 authnotrequired => 0,
	                                 flagsrequired => {borrowers => 1},
	                                 debug => 1,
	                                 });


# set the userenv branch
my $default = C4::Context->userenv->{'branch'};


my @datearr = localtime(time());
my $todaysdate = (1900+$datearr[5]).'-'.sprintf ("%0.2d", ($datearr[4]+1)).'-'.sprintf ("%0.2d", $datearr[3]);

# get the all the branches for reference
my $branches = GetBranches();
my @branchesloop;
foreach my $br (keys %$branches) {
	my @transferloop;
	my %branchloop;
	$branchloop{'branchname'} = $branches->{$br}->{'branchname'};
	$branchloop{'branchcode'} = $branches->{$br}->{'branchcode'};
	# # # # # # # # # # # # # # # # # # # # # # 
	my @gettransfers = GetTransfersFromBib($branches->{$br}->{'branchcode'},$default);
		if (@gettransfers){
		foreach my $num (@gettransfers) {
			my %getransf;
			my %env;
			my $calcDate=DateCalc($num->{'datesent'},"+".C4::Context->preference('TransfersMaxDaysWarning')."  days");
			my $warning=Date_Cmp(ParseDate("today"),$calcDate);
			if ($warning>0){
				$getransf{'messcompa'} = 1;
			}
			my $gettitle = getiteminformation(\%env,$num->{'itemnumber'});
			my $itemtypeinfo = getitemtypeinfo($gettitle->{'itemtype'});
			
				$getransf{'title'} = $gettitle->{'title'};
				$getransf{'datetransfer'} = format_date($num->{'datesent'});
				$getransf{'biblionumber'} = $gettitle->{'biblionumber'};
				$getransf{'itemnumber'} = $gettitle->{'itemnumber'};
				$getransf{'barcode'} = $gettitle->{'barcode'};
				$getransf{'itemtype'} = $itemtypeinfo->{'description'};
				$getransf{'homebranch'} = $gettitle->{'homebranch'};
				$getransf{'holdingbranch'} = $gettitle->{'holdingbranch'};
				$getransf{'itemcallnumber'} = $gettitle->{'itemcallnumber'};

# 				we check if we have a reserv for this transfer
				my @checkreserv = FastFindReserves($num->{'itemnumber'});
				if (@checkreserv[0]){
					my $getborrower = getpatroninformation (\%env,$checkreserv[1]);
					$getransf{'borrowernum'} = $getborrower->{'borrowernumber'};
					$getransf{'borrowername'} = $getborrower->{'surname'};
					$getransf{'borrowerfirstname'} =  $getborrower->{'firstname'};
						if ($getborrower->{'emailaddress'}){
							$getransf{'borrowermail'} =  $getborrower->{'emailaddress'} ;
						}
					$getransf{'borrowerphone'} = $getborrower->{'phone'};	

				}
				push(@transferloop, \%getransf);
			}
# 		If we have a return of reservloop we put it in the branchloop sequence
		$branchloop{'reserv'} = \@transferloop ;
		}		
	else {
# 	if we don't have a retrun from reservestobranch we unset branchname and branchcode
	$branchloop{'branchname'} = 0;
	$branchloop{'branchcode'} = 0;
	}
push(@branchesloop, \%branchloop);
}
	$template->param( branchesloop  => \@branchesloop,
			show_date	=> format_date($todaysdate)	
			 );
	
	print "Content-Type: text/html\n\n", $template->output;



