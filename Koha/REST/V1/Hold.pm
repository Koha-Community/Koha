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
    my $borrower = Koha::Patrons->find($borrowernumber);
    unless ($borrower) {
        return $c->render( status  => 404,
                           openapi => {error => "Borrower not found"} );
    }

    if (my $problem = _opac_patron_restrictions($c, $borrower)) {
        return $c->render( status => 403, openapi => {
            error => "Reserve cannot be placed. Reason: $problem"} );
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

    if ($itemnumber) {
        my $item_biblionumber = C4::Biblio::GetBiblionumberFromItemnumber($itemnumber);
        if ($biblionumber and $biblionumber != $item_biblionumber) {
            return $c->render( status => 400, openapi => {
                error => "Item $itemnumber doesn't belong to biblio $biblionumber"
            } );
        }
        $biblionumber ||= $item_biblionumber;
    }

    my $biblio = C4::Biblio::GetBiblio($biblionumber);

    my $can_reserve =
      $itemnumber
      ? CanItemBeReserved( $borrowernumber, $itemnumber )
      : CanBookBeReserved( $borrowernumber, $biblionumber );

    unless ($can_reserve eq 'OK') {
        return $c->render( status => 403, openapi => {
            error => "Reserve cannot be placed. Reason: $can_reserve"
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
        $biblio->{title}, $itemnumber);

    unless ($reserve_id) {
        return $c->render( status => 500, openapi => {
            error => "Error while placing reserve. See Koha logs for details."
        } );
    }

    my $hold = Koha::Holds->find($reserve_id);

    return $c->render( status => 201, openapi => $hold );
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $reserve_id = $c->validation->param('reserve_id');
    my $reserve = C4::Reserves::GetReserve($reserve_id);

    unless ($reserve) {
        return $c->render( status  => 404,
                           openapi => {error => "Reserve not found"} );
    }

    if (my $problem = _opac_patron_restrictions($c, $c->stash('koha.user'))) {
        return $c->render( status => 403, openapi => {
            error => "Reserve cannot be modified. Reason: $problem"} );
    }

    my $body = $c->req->json;

    my $branchcode = $body->{branchcode} || $reserve->{branchcode};
    my $priority;
    if (!$c->stash('is_owner_access') && !$c->stash('is_guarantor_access')) {
        $priority = defined $body->{priority}
                    ? $body->{priority}
                    : $reserve->{priority};
    } else {
        $priority = $reserve->{priority};
    }
    my $suspend_until = $body->{suspend_until} || $reserve->{suspend_until};

    if ($suspend_until) {
        $suspend_until = output_pref(dt_from_string($suspend_until, 'iso'));
    }

    my $params = {
        reserve_id => $reserve_id,
        branchcode => $branchcode,
        rank => $priority,
    };

    C4::Reserves::ModReserve($params);

    my $borrowernumber = $reserve->{borrowernumber};
    if (C4::Reserves::CanReserveBeCanceledFromOpac($reserve_id, $borrowernumber)){
        C4::Reserves::ToggleSuspend( $reserve_id, $suspend_until ) if
            (defined $body->{suspend} || $suspend_until);
    }

    $reserve = Koha::Holds->find($reserve_id);

    return $c->render( status => 200, openapi => $reserve );
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $reserve_id = $c->validation->param('reserve_id');
    my $reserve = C4::Reserves::GetReserve($reserve_id);
    my $user = $c->stash('koha.user');

    unless ($reserve) {
        return $c->render( status => 404, openapi => {error => "Reserve not found"} );
    }

    if (my $problem = _opac_patron_restrictions($c, $user)) {
        return $c->render( status => 403, openapi => {
            error => "Reserve cannot be cancelled. Reason: $problem"} )
            if ($problem ne 'maximumholdsreached');
    }

    if ($user
        && ($c->stash('is_owner_access') || $c->stash('is_guarantor_access'))
        && !C4::Reserves::CanReserveBeCanceledFromOpac($reserve_id,
                                                       $user->borrowernumber)) {
        return $c->render( status  => 403, openapi =>
                          {error => "Hold is already in transfer or waiting and "
                                ."cannot be cancelled by patron."});
    }

    C4::Reserves::CancelReserve({ reserve_id => $reserve_id });

    return $c->render( status => 200, openapi => {} );
}

# Restrict operations via REST API if patron has some restrictions.
#
# The following reasons can be returned:
#
# 1. debarred
# 2. gonenoaddress
# 3. cardexpired
# 4. maximumholdsreached
# 5. (cardlost, but this is returned via different error message. See KD-2165)
#
sub _opac_patron_restrictions {
    my ($c, $patron) = @_;

    $patron = ref($patron) eq 'Koha::Patron'
                ? $patron
                : Koha::Patrons->find($patron);
    return 0 unless $patron;
    return 0 if (!$c->stash('is_owner_access')
                 && !$c->stash('is_guarantor_access'));
    my @problems = $patron->status_not_ok;
    foreach my $problem (@problems) {
        $problem = ref($problem);
        next if $problem =~ /Debt/;
        next if $problem =~ /Checkout/;
        $problem =~ s/Koha::Exceptions::(.*::)*//;
        return lc($problem);
    }
    return 0;
}

1;
