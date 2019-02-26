package Koha::REST::V1::Hold;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Biblio;
use C4::Reserves;

use Koha::Items;
use Koha::Patrons;
use Koha::Holds;
use Koha::DateUtils;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $params = $c->req->query_params->to_hash;
    my @valid_params = Koha::Holds->_resultset->result_source->columns;
    foreach my $key (keys %$params) {
        delete $params->{$key} unless grep { $key eq $_ } @valid_params;
    }
    my $holds = Koha::Holds->search($params);

    return $c->render(status => 200, openapi => $holds);
}

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;

    my $borrowernumber = $body->{borrowernumber};
    my $biblionumber = $body->{biblionumber};
    my $itemnumber = $body->{itemnumber};
    my $branchcode = $body->{branchcode};
    my $expirationdate = $body->{expirationdate};
    my $itemtype = $body->{itemtype};

    my $borrower = Koha::Patrons->find($borrowernumber);
    unless ($borrower) {
        return $c->render( status  => 404,
                           openapi => {error => "Borrower not found"} );
    }

    unless ($biblionumber or $itemnumber) {
        return $c->render( status => 400, openapi => {
            error => "At least one of biblionumber, itemnumber should be given"
        } );
    }
    unless ($branchcode) {
        return $c->render( status  => 400,
                           openapi => { error => "Branchcode is required" } );
    }

    my $biblio;
    if ($itemnumber) {
        my $item = Koha::Items->find( $itemnumber );
        $biblio = $item->biblio;
        if ($biblionumber and $biblionumber != $biblio->biblionumber) {
            return $c->render(
                status => 400,
                openapi => {
                    error => "Item $itemnumber doesn't belong to biblio $biblionumber"
                });
        }
        $biblionumber ||= $biblio->biblionumber;
    } else {
        $biblio = Koha::Biblios->find( $biblionumber );
    }

    my $can_reserve =
      $itemnumber
      ? CanItemBeReserved( $borrowernumber, $itemnumber )
      : CanBookBeReserved( $borrowernumber, $biblionumber );

    unless ($can_reserve->{status} eq 'OK') {
        return $c->render( status => 403, openapi => {
            error => "Reserve cannot be placed. Reason: ". $can_reserve->{status}
        } );
    }

    my $priority = C4::Reserves::CalculatePriority($biblionumber);
    $itemnumber ||= undef;

    # AddReserve expects date to be in syspref format
    if ($expirationdate) {
        $expirationdate = output_pref(dt_from_string($expirationdate, 'iso'));
    }

    my $reserve_id = C4::Reserves::AddReserve($branchcode, $borrowernumber,
        $biblionumber, undef, $priority, undef, $expirationdate, undef,
        $biblio->title, $itemnumber, undef, $itemtype);

    unless ($reserve_id) {
        return $c->render( status => 500, openapi => {
            error => "Error while placing reserve. See Koha logs for details."
        } );
    }

    my $reserve = Koha::Holds->find($reserve_id);

    return $c->render( status => 201, openapi => $reserve );
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $reserve_id = $c->validation->param('reserve_id');
    my $hold = Koha::Holds->find( $reserve_id );

    unless ($hold) {
        return $c->render( status  => 404,
                           openapi => {error => "Reserve not found"} );
    }

    my $body = $c->req->json;

    my $branchcode = $body->{branchcode};
    my $priority = $body->{priority};
    my $suspend_until = $body->{suspend_until};

    if ($suspend_until) {
        $suspend_until = output_pref(dt_from_string($suspend_until, 'iso'));
    }

    my $params = {
        reserve_id => $reserve_id,
        branchcode => $branchcode,
        rank => $priority,
        suspend_until => $suspend_until,
        itemnumber => $hold->itemnumber
    };

    C4::Reserves::ModReserve($params);
    $hold = Koha::Holds->find($reserve_id);

    return $c->render( status => 200, openapi => $hold );
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $reserve_id = $c->validation->param('reserve_id');
    my $hold = Koha::Holds->find( $reserve_id );

    unless ($hold) {
        return $c->render( status => 404, openapi => {error => "Reserve not found"} );
    }

    $hold->cancel;

    return $c->render( status => 200, openapi => {} );
}

1;
