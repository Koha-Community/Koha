#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# parts copyright 2010 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

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
my $all_branches   = $input->param('allbranches') || '';
my $cancelall      = $input->param('cancelall');

my $cancel;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "circ/waitingreserves.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
        debug           => 1,
    }
);

my $default = C4::Context->userenv->{'branch'};

my $transfer_when_cancel_all = C4::Context->preference('TransferWhenCancelAllWaitingHolds');
$template->param( TransferWhenCancelAllWaitingHolds => 1 ) if $transfer_when_cancel_all;

my @cancel_result;
# if we have a return from the form we launch the subroutine CancelReserve
if ($item) {
    my $res = cancel( $item, $borrowernumber, $fbr, $tbr );
    push @cancel_result, $res if $res;
}

if ( C4::Context->preference('IndependentBranches') ) {
    undef $all_branches;
} else {
    $template->param( all_branches_link => $input->url . '?allbranches=1' )
      unless $all_branches;
}
$template->param( all_branches => 1 ) if $all_branches;

my (@reservloop, @overloop);
my ($reservcount, $overcount);
my @getreserves = $all_branches ? GetReservesForBranch() : GetReservesForBranch($default);
# get reserves for the branch we are logged into, or for all branches

my $today = Date_to_Days(&Today);
foreach my $num (@getreserves) {
    next unless ($num->{'waitingdate'} && $num->{'waitingdate'} ne '0000-00-00');

    my $itemnumber = $num->{'itemnumber'};
    my $gettitle     = GetBiblioFromItemNumber( $itemnumber );
    my $borrowernum = $num->{'borrowernumber'};
    my $holdingbranch = $gettitle->{'holdingbranch'};
    my $homebranch = $gettitle->{'homebranch'};

    my %getreserv = (
        itemnumber => $itemnumber,
        borrowernum => $borrowernum,
    );

    # fix up item type for display
    $gettitle->{'itemtype'} = C4::Context->preference('item-level_itypes') ? $gettitle->{'itype'} : $gettitle->{'itemtype'};
    my $getborrower = GetMember(borrowernumber => $num->{'borrowernumber'});
    my $itemtypeinfo = getitemtypeinfo( $gettitle->{'itemtype'} );  # using the fixed up itype/itemtype
    $getreserv{'waitingdate'} = $num->{'waitingdate'};
    my ( $waiting_year, $waiting_month, $waiting_day ) = split (/-/, $num->{'waitingdate'});
    ( $waiting_year, $waiting_month, $waiting_day ) =
      Add_Delta_Days( $waiting_year, $waiting_month, $waiting_day,
        C4::Context->preference('ReservesMaxPickUpDelay'));
    my $calcDate = Date_to_Days( $waiting_year, $waiting_month, $waiting_day );

    $getreserv{'itemtype'}       = $itemtypeinfo->{'description'};
    $getreserv{'title'}          = $gettitle->{'title'};
    $getreserv{'subtitle'}       = GetRecordValue('subtitle', GetMarcBiblio($gettitle->{'biblionumber'}), GetFrameworkCode($gettitle->{'biblionumber'}));
    $getreserv{'biblionumber'}   = $gettitle->{'biblionumber'};
    $getreserv{'barcode'}        = $gettitle->{'barcode'};
    $getreserv{'branchname'}     = GetBranchName($gettitle->{'homebranch'});
    $getreserv{'homebranch'}     = $gettitle->{'homebranch'};
    $getreserv{'holdingbranch'}  = $gettitle->{'holdingbranch'};
    $getreserv{'itemcallnumber'} = $gettitle->{'itemcallnumber'};
    $getreserv{'enumchron'}      = $gettitle->{'enumchron'};
    $getreserv{'copynumber'}     = $gettitle->{'copynumber'};
    if ( $homebranch ne $holdingbranch ) {
        $getreserv{'dotransfer'} = 1;
    }
    $getreserv{'borrowername'}      = $getborrower->{'surname'};
    $getreserv{'borrowerfirstname'} = $getborrower->{'firstname'};
    $getreserv{'borrowerphone'}     = $getborrower->{'phone'};

    my $borEmail = GetFirstValidEmailAddress( $borrowernum );

    if ( $borEmail ) {
        $getreserv{'borrowermail'}  = $borEmail;
    }

    if ($today > $calcDate) {
        if ($cancelall) {
            my $res = cancel( $itemnumber, $borrowernum, $holdingbranch, $homebranch, !$transfer_when_cancel_all );
            push @cancel_result, $res if $res;
            next;
        } else {
            push @overloop,   \%getreserv;
            $overcount++;
        }
    }else{
        push @reservloop, \%getreserv;
        $reservcount++;
    }
    
}

$template->param(cancel_result => \@cancel_result) if @cancel_result;
$template->param(
    reserveloop => \@reservloop,
    reservecount => $reservcount,
    overloop    => \@overloop,
    overcount   => $overcount,
    show_date   => format_date(C4::Dates->today('iso')),
    ReservesMaxPickUpDelay => C4::Context->preference('ReservesMaxPickUpDelay')
);

if ($cancelall) {
    print $input->redirect("/cgi-bin/koha/circ/waitingreserves.pl");
} else {
    output_html_with_http_headers $input, $cookie, $template->output;
}

exit;

sub cancel {
    my ($item, $borrowernumber, $fbr, $tbr, $skip_transfers ) = @_;

    my $transfer = $fbr ne $tbr; # XXX && !$nextreservinfo;

    return if $transfer && $skip_transfers;

    my ( $messages, $nextreservinfo ) = ModReserveCancelAll( $item, $borrowernumber );

# 	if the document is not in his homebranch location and there is not reservation after, we transfer it
    if ($transfer && !$nextreservinfo) {
        ModItemTransfer( $item, $fbr, $tbr );
    }
    # if we have a result
    if ($nextreservinfo) {
        my %res;
        my $borrowerinfo = GetMemberDetails( $nextreservinfo );
        my $iteminfo = GetBiblioFromItemNumber($item);
        if ( $messages->{'transfert'} ) {
            $res{messagetransfert} = $messages->{'transfert'};
            $res{branchname}       = GetBranchName($messages->{'transfert'});
        }

        $res{message}             = 1;
        $res{nextreservnumber}    = $nextreservinfo;
        $res{nextreservsurname}   = $borrowerinfo->{'surname'};
        $res{nextreservfirstname} = $borrowerinfo->{'firstname'};
        $res{nextreservitem}      = $item;
        $res{nextreservtitle}     = $iteminfo->{'title'};
        $res{waiting}             = $messages->{'waiting'} ? 1 : 0;

        return \%res;
    }

    return;
}
