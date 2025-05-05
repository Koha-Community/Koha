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
use C4::Output      qw( output_html_with_http_headers );
use C4::Auth        qw( get_template_and_user );
use C4::Items       qw( ModItemTransfer );
use Date::Calc      qw( Date_to_Days Today );
use C4::Reserves    qw( ModReserve ModReserveCancelAll );
use Koha::DateUtils qw( dt_from_string );
use Koha::BiblioFrameworks;
use Koha::Items;
use Koha::ItemTypes;
use Koha::Patrons;
use Koha::BackgroundJob::BatchCancelHold;

my $input = CGI->new;

my $op             = $input->param('op') || q{};
my $item           = $input->param('itemnumber');
my $borrowernumber = $input->param('borrowernumber');
my $fbr            = $input->param('fbr')         || '';
my $tbr            = $input->param('tbr')         || '';
my $all_branches   = $input->param('allbranches') || '';
my $tab            = $input->param('tab');
my $cancelBulk     = $input->param('cancelBulk');

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "circ/waitingreserves.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

my $default = C4::Context->userenv->{'branch'};

my $transfer_when_cancel_all = C4::Context->preference('TransferWhenCancelAllWaitingHolds');
$template->param( TransferWhenCancelAllWaitingHolds => 1 ) if $transfer_when_cancel_all;

my @cancel_result;

# if we have a return from the form we cancel the holds
if ( $op eq 'cud-cancel' && $item ) {
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

if ($cancelBulk) {
    my $reason   = $input->param("cancellation-reason");
    my @hold_ids = split( ',', scalar $input->param("ids") );
    my $params   = {
        reason   => $reason,
        hold_ids => \@hold_ids,
    };
    my $job_id = Koha::BackgroundJob::BatchCancelHold->new->enqueue($params);

    $template->param(
        enqueued => 1,
        job_id   => $job_id
    );
}

my ( @reserve_loop, @over_loop );

# FIXME - Is priority => 0 useful? If yes it must be moved to waiting, otherwise we need to remove it from here.
my $holds = Koha::Holds->waiting->search(
    { priority => 0, ( $all_branches ? () : ( branchcode => $default ) ) },
    { order_by => ['waitingdate'] }
);

# get reserves for the branch we are logged into, or for all branches

my $today = Date_to_Days(&Today);

while ( my $hold = $holds->next ) {
    next unless $hold->waitingdate;

    my ( $expire_year, $expire_month, $expire_day ) = split( /-/, $hold->expirationdate );
    my $calcDate = Date_to_Days( $expire_year, $expire_month, $expire_day );

    if ( $today > $calcDate ) {
        if ( $op eq 'cud-cancelall' ) {
            my $res = cancel(
                $hold->item->itemnumber, $hold->borrowernumber, $hold->item->holdingbranch,
                $hold->item->homebranch, !$transfer_when_cancel_all
            );
            push @cancel_result, $res if $res;
            next;
        } else {
            push @over_loop, $hold;
        }
    } else {
        push @reserve_loop, $hold;
    }

}

my $holds_with_cancellation_requests =
    Koha::Holds->waiting->search( { ( $all_branches ? () : ( branchcode => $default ) ) } )
    ->filter_by_has_cancellation_requests;

$template->param( cancel_result => \@cancel_result ) if @cancel_result;

$template->param(
    reserveloop       => \@reserve_loop,
    reservecount      => scalar @reserve_loop,
    overloop          => \@over_loop,
    overcount         => scalar @over_loop,
    cancel_reqs_count => $holds_with_cancellation_requests->count,
    cancel_reqs       => $holds_with_cancellation_requests,
    show_date         => dt_from_string,
    tab               => $tab,
);

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find('FA');

if ( $item && $tab eq 'holdsover' && !@cancel_result ) {
    print $input->redirect("/cgi-bin/koha/circ/waitingreserves.pl?tab=holdsover");
} elsif ( $op eq 'cud-cancelall' ) {
    print $input->redirect("/cgi-bin/koha/circ/waitingreserves.pl");
} else {
    output_html_with_http_headers $input, $cookie, $template->output;
}

exit;

sub cancel {
    my ( $itemnumber, $borrowernumber, $fbr, $tbr, $skip_transfers ) = @_;

    my $transfer = $fbr ne $tbr;                     # XXX && !$nextreservinfo;
    my $item     = Koha::Items->find($itemnumber);

    return if $transfer && $skip_transfers;

    my ( $messages, $nextreservinfo ) = ModReserveCancelAll( $itemnumber, $borrowernumber );

    # if the document is not in his homebranch location and there is not reservation after, we transfer it
    if ( $transfer && !$nextreservinfo && !$item->itemlost ) {
        ModItemTransfer( $itemnumber, $fbr, $tbr, 'CancelReserve' );
    }

    # if we have a result
    if ($nextreservinfo) {
        my %res;
        my $patron = Koha::Patrons->find($nextreservinfo);
        my $title  = $item->biblio->title;
        if ( $messages->{'transfert'} ) {
            $res{messagetransfert} = $messages->{'transfert'};
            $res{branchcode}       = $messages->{'transfert'};
        }

        $res{message}             = 1;
        $res{nextreservnumber}    = $nextreservinfo;
        $res{nextreservsurname}   = $patron->surname;
        $res{nextreservfirstname} = $patron->firstname;
        $res{nextreservitem}      = $itemnumber;
        $res{nextreservtitle}     = $title;
        $res{waiting}             = $messages->{'waiting'} ? 1 : 0;

        return \%res;
    }

    return;
}
