#!/usr/bin/perl

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
use warnings;
use CGI;
use C4::Context;
use C4::Output;
use C4::Branch; # GetBranchName
use C4::Auth;
use C4::Dates qw/format_date/;
use C4::Circulation;
use C4::Members;
use C4::Biblio;
use C4::Items;

use Date::Calc qw(
  Today
  Add_Delta_Days
  Date_to_Days
);
use C4::Reserves;
use C4::Koha;

my $input = new CGI;

my $item           = $input->param('itemnumber');
my $borrowernumber = $input->param('borrowernumber');
my $fbr            = $input->param('fbr') || '';
my $tbr            = $input->param('tbr') || '';

my $cancel;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/waitingreserves.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $default = C4::Context->userenv->{'branch'};

# if we have a return from the form we launch the subroutine CancelReserve
if ($item) {
    my ( $messages, $nextreservinfo ) = ModReserveCancelAll( $item, $borrowernumber );
    # if we have a result
    if ($nextreservinfo) {
        my $borrowerinfo = GetMemberDetails( $nextreservinfo );
        my $iteminfo = GetBiblioFromItemNumber($item);
        if ( $messages->{'transfert'} ) {
            $template->param(
                messagetransfert => $messages->{'transfert'},
                branchname       => GetBranchName($messages->{'transfert'}),
            );
        }

        $template->param(
            message             => 1,
            nextreservnumber    => $nextreservinfo,
            nextreservsurname   => $borrowerinfo->{'surname'},
            nextreservfirstname => $borrowerinfo->{'firstname'},
            nextreservitem      => $item,
            nextreservtitle     => $iteminfo->{'title'},
            waiting             => ($messages->{'waiting'}) ? 1 : 0,
        );
    }

# 	if the document is not in his homebranch location and there is not reservation after, we transfer it
    if ($fbr ne $tbr  and not $nextreservinfo) {
        ModItemTransfer( $item, $fbr, $tbr );
    }
}

my @reservloop;
my @getreserves = C4::Context->preference('IndependantBranches') ? GetReservesForBranch($default) : GetReservesForBranch();
# get reserves for the branch we are logged into, or for all branches
	
my $today = Date_to_Days(&Today);
foreach my $num (@getreserves) {
    next unless ($num->{'waitingdate'} && $num->{'waitingdate'} ne '0000-00-00');
    my %getreserv;
    my $gettitle     = GetBiblioFromItemNumber( $num->{'itemnumber'} );
    # fix up item type for display
    $gettitle->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $gettitle->{'itype'} : $gettitle->{'itemtype'};
    my $getborrower  = GetMemberDetails( $num->{'borrowernumber'} );
    my $itemtypeinfo = getitemtypeinfo( $gettitle->{'itemtype'} );  # using the fixed up itype/itemtype
    $getreserv{'waitingdate'} = format_date( $num->{'waitingdate'} );

    my ( $waiting_year, $waiting_month, $waiting_day ) = split /-/, $num->{'waitingdate'};
    ( $waiting_year, $waiting_month, $waiting_day ) =
      Add_Delta_Days( $waiting_year, $waiting_month, $waiting_day,
        C4::Context->preference('ReservesMaxPickUpDelay'));
    my $calcDate = Date_to_Days( $waiting_year, $waiting_month, $waiting_day );

    if ($today > $calcDate) {
        $getreserv{'messcompa'} = 1;
    }
    $getreserv{'itemtype'}       = $itemtypeinfo->{'description'};
    $getreserv{'title'}          = $gettitle->{'title'};
    $getreserv{'itemnumber'}     = $gettitle->{'itemnumber'};
    $getreserv{'biblionumber'}   = $gettitle->{'biblionumber'};
    $getreserv{'barcode'}        = $gettitle->{'barcode'};
    $getreserv{'homebranch'}     = $gettitle->{'homebranch'};
    $getreserv{'holdingbranch'}  = $gettitle->{'holdingbranch'};
    $getreserv{'itemcallnumber'} = $gettitle->{'itemcallnumber'};
    if ( $gettitle->{'homebranch'} ne $gettitle->{'holdingbranch'} ) {
        $getreserv{'dotransfer'} = 1;
    }
    $getreserv{'borrowernum'}       = $getborrower->{'borrowernumber'};
    $getreserv{'borrowername'}      = $getborrower->{'surname'};
    $getreserv{'borrowerfirstname'} = $getborrower->{'firstname'};
    $getreserv{'borrowerphone'}     = $getborrower->{'phone'};
    if ( $getborrower->{'emailaddress'} ) {
        $getreserv{'borrowermail'}  = $getborrower->{'emailaddress'};
    }
    push @reservloop, \%getreserv;
}

$template->param(
    reserveloop => \@reservloop,
    show_date   => format_date(C4::Dates->today('iso')),
	dateformat  => C4::Context->preference("dateformat"),
);

output_html_with_http_headers $input, $cookie, $template->output;
