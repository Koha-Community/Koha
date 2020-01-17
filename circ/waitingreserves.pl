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

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Output;
use C4::Auth;
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
use Koha::DateUtils;
use Koha::BiblioFrameworks;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;

my $input = new CGI;

my $item           = $input->param('itemnumber');
my $borrowernumber = $input->param('borrowernumber');
my $fbr            = $input->param('fbr') || '';
my $tbr            = $input->param('tbr') || '';
my $all_branches   = $input->param('allbranches') || '';
my $cancelall      = $input->param('cancelall');
my $tab            = $input->param('tab');

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
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
# if we have a return from the form we cancel the holds
if ($item) {
    my $res = cancel( $item, $borrowernumber, $fbr, $tbr );
    push @cancel_result, $res if $res;
}

if ( C4::Context->preference('IndependentBranches') ) {
    undef $all_branches;
} else {
    $template->param( all_branches_link => '/cgi-bin/koha/circ/waitingreserves.pl' . '?allbranches=1' )
      unless $all_branches;
}
$template->param( all_branches => 1 ) if $all_branches;

my (@reserve_loop, @over_loop);
# FIXME - Is priority => 0 useful? If yes it must be moved to waiting, otherwise we need to remove it from here.
my $holds = Koha::Holds->waiting->search({ priority => 0, ( $all_branches ? () : ( branchcode => $default ) ) }, { order_by => ['waitingdate'] });

# get reserves for the branch we are logged into, or for all branches

my $today = Date_to_Days(&Today);

while ( my $hold = $holds->next ) {
    next unless ($hold->waitingdate && $hold->waitingdate ne '0000-00-00');

    my ( $expire_year, $expire_month, $expire_day ) = split (/-/, $hold->expirationdate);
    my $calcDate = Date_to_Days( $expire_year, $expire_month, $expire_day );

    if ($today > $calcDate) {
        if ($cancelall) {
            my $res = cancel( $hold->item->itemnumber, $hold->borrowernumber, $hold->item->holdingbranch, $hold->item->homebranch, !$transfer_when_cancel_all );
            push @cancel_result, $res if $res;
            next;
        } else {
            push @over_loop, $hold;
        }
    }else{
        push @reserve_loop, $hold;
    }
    
}

$template->param(cancel_result => \@cancel_result) if @cancel_result;

$template->param(
    reserveloop => \@reserve_loop,
    reservecount => scalar @reserve_loop,
    overloop    => \@over_loop,
    overcount   => scalar @over_loop,
    show_date   => output_pref({ dt => dt_from_string, dateformat => 'iso', dateonly => 1 }),
    tab => $tab,
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find( 'FA' );

if ($item && $tab eq 'holdsover' && !@cancel_result) {
    print $input->redirect("/cgi-bin/koha/circ/waitingreserves.pl#holdsover");
} elsif ($cancelall) {
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
        ModItemTransfer( $item, $fbr, $tbr, 'CancelReserve' );
    }
    # if we have a result
    if ($nextreservinfo) {
        my %res;
        my $patron = Koha::Patrons->find( $nextreservinfo );
        my $title = Koha::Items->find( $item )->biblio->title;
        if ( $messages->{'transfert'} ) {
            $res{messagetransfert} = $messages->{'transfert'};
            $res{branchcode}       = $messages->{'transfert'};
        }

        $res{message}             = 1;
        $res{nextreservnumber}    = $nextreservinfo;
        $res{nextreservsurname}   = $patron->surname;
        $res{nextreservfirstname} = $patron->firstname;
        $res{nextreservitem}      = $item;
        $res{nextreservtitle}     = $title;
        $res{waiting}             = $messages->{'waiting'} ? 1 : 0;

        return \%res;
    }

    return;
}
