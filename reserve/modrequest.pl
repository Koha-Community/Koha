#!/usr/bin/perl

#script to modify reserves/requests
#written 2/1/00 by chris@katipo.oc.nz
#last update 27/1/2000 by chris@katipo.co.nz

# Copyright 2000-2002 Katipo Communications
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
use URI;
use List::MoreUtils qw( uniq );
use Try::Tiny;

use C4::Output;
use C4::Reserves qw( ModReserve );
use C4::Auth     qw( checkauth );
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;

my $query = CGI->new;

checkauth( $query, 0, { reserveforothers => '*' }, 'intranet' );

my $op              = $query->param('op') || 'cud-modifyall';
my @reserve_id      = $query->multi_param('reserve_id');
my @rank            = $query->multi_param('rank-request');
my @borrower        = $query->multi_param('borrowernumber');
my @reservedates    = $query->multi_param('reservedate');
my @expirationdates = $query->multi_param('expirationdate');
my @branch          = $query->multi_param('pickup');
my @itemnumber      = $query->multi_param('itemnumber');
my @biblionumber    = $query->multi_param('biblionumber');
my $count           = @rank;

@biblionumber = uniq @biblionumber;

# Cancel or modify the queue list of reserves (without item linked)
if ( $op eq 'cud-cancelall' || $op eq 'cud-modifyall' ) {
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        undef $itemnumber[$i] if !$itemnumber[$i];
        my $suspend_until       = $query->param( "suspend_until_" . $reserve_id[$i] );
        my $cancellation_reason = $query->param("cancellation-reason");
        my $params              = {
            rank           => $rank[$i],
            reserve_id     => $reserve_id[$i],
            expirationdate => $expirationdates[$i] || undef,
            branchcode     => $branch[$i],
            itemnumber     => $itemnumber[$i],
            defined $suspend_until ? ( suspend_until => $suspend_until ) : (),
            cancellation_reason => $cancellation_reason,
        };
        if ( C4::Context->preference('AllowHoldDateInFuture') ) {
            $params->{reservedate} = $reservedates[$i] || undef;
        }

        try {
            ModReserve($params);
        } catch {
            if ( $_->isa('Koha::Exceptions::ObjectNotFound') ) {
                warn $_;
            } else {
                $_->rethrow;
            }
        };

        if ( $query->param( "change_hold_type_" . $reserve_id[$i] ) ) {
            my $hold = Koha::Holds->find( $reserve_id[$i] );

            try {
                $hold->change_type;
            } catch {
                if ( $_->isa('Koha::Exceptions::Hold::CannotChangeHoldType') ) {
                    warn $_;
                } else {
                    $_->rethrow;
                }
            }
        }
    }
    my @biblio_ids = uniq @biblionumber;
    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => \@biblio_ids } )
        if C4::Context->preference('RealTimeHoldsQueue');
}

my $from = $query->param('from');
$from ||= q{};
if ( $from eq 'borrower' ) {
    print $query->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$borrower[0]");
} elsif ( $from eq 'circ' ) {
    print $query->redirect("/cgi-bin/koha/circ/circulation.pl?borrowernumber=$borrower[0]");
} else {
    my $url = URI->new("/cgi-bin/koha/reserve/request.pl");
    $url->query_form( biblionumber => [@biblionumber] );
    print $query->redirect($url);
}
