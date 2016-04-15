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

use Koha::Patrons;
use Koha::Holds;
use Koha::DateUtils;

sub list {
    my ($c, $args, $cb) = @_;

    my $params = $c->req->query_params->to_hash;
    my @valid_params = Koha::Holds->_resultset->result_source->columns;
    foreach my $key (keys %$params) {
        delete $params->{$key} unless grep { $key eq $_ } @valid_params;
    }
    my $holds = Koha::Holds->search($params)->unblessed;

    return $c->$cb($holds, 200);
}

sub add {
    my ($c, $args, $cb) = @_;

    my $body = $c->req->json;

    my $borrowernumber = $body->{borrowernumber};
    my $biblionumber = $body->{biblionumber};
    my $itemnumber = $body->{itemnumber};
    my $branchcode = $body->{branchcode};
    my $expirationdate = $body->{expirationdate};
    my $borrower = Koha::Patrons->find($borrowernumber);
    unless ($borrower) {
        return $c->$cb({error => "Borrower not found"}, 404);
    }

    unless ($biblionumber or $itemnumber) {
        return $c->$cb({
            error => "At least one of biblionumber, itemnumber should be given"
        }, 400);
    }
    unless ($branchcode) {
        return $c->$cb({
            error => "Branchcode is required"
        }, 400);
    }

    if ($itemnumber) {
        my $item_biblionumber = C4::Biblio::GetBiblionumberFromItemnumber($itemnumber);
        if ($biblionumber and $biblionumber != $item_biblionumber) {
            return $c->$cb({
                error => "Item $itemnumber doesn't belong to biblio $biblionumber"
            }, 400);
        }
        $biblionumber ||= $item_biblionumber;
    }

    my $biblio = C4::Biblio::GetBiblio($biblionumber);

    my $can_reserve =
      $itemnumber
      ? CanItemBeReserved( $borrowernumber, $itemnumber )
      : CanBookBeReserved( $borrowernumber, $biblionumber );

    unless ($can_reserve eq 'OK') {
        return $c->$cb({
            error => "Reserve cannot be placed. Reason: $can_reserve"
        }, 403);
    }

    my $priority = C4::Reserves::CalculatePriority($biblionumber);
    $itemnumber ||= undef;

    # AddReserve expects date to be in syspref format
    if ($expirationdate) {
        $expirationdate = output_pref(dt_from_string($expirationdate, 'iso'));
    }

    my $reserve_id = C4::Reserves::AddReserve($branchcode, $borrowernumber,
        $biblionumber, undef, $priority, undef, $expirationdate, undef,
        $biblio->{title}, $itemnumber);

    unless ($reserve_id) {
        return $c->$cb({
            error => "Error while placing reserve. See Koha logs for details."
        }, 500);
    }

    my $reserve = C4::Reserves::GetReserve($reserve_id);

    return $c->$cb($reserve, 201);
}

sub edit {
    my ($c, $args, $cb) = @_;

    my $reserve_id = $args->{reserve_id};
    my $reserve = C4::Reserves::GetReserve($reserve_id);

    unless ($reserve) {
        return $c->$cb({error => "Reserve not found"}, 404);
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
    };
    C4::Reserves::ModReserve($params);
    $reserve = C4::Reserves::GetReserve($reserve_id);

    return $c->$cb($reserve, 200);
}

sub delete {
    my ($c, $args, $cb) = @_;

    my $reserve_id = $args->{reserve_id};
    my $reserve = C4::Reserves::GetReserve($reserve_id);

    unless ($reserve) {
        return $c->$cb({error => "Reserve not found"}, 404);
    }

    C4::Reserves::CancelReserve({ reserve_id => $reserve_id });

    return $c->$cb({}, 200);
}

1;
