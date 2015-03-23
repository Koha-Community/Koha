package Koha::REST::V1::Checkout;

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

use C4::Auth qw( haspermission );
use C4::Context;
use C4::Circulation;
use Koha::Checkouts;

sub list {
    my ($c, $args, $cb) = @_;

    my $borrowernumber = $c->param('borrowernumber');
    my $checkouts = C4::Circulation::GetIssues({
        borrowernumber => $borrowernumber
    });

    $c->$cb($checkouts, 200);
}

sub get {
    my ($c, $args, $cb) = @_;

    my $checkout_id = $args->{checkout_id};
    my $checkout = Koha::Checkouts->find($checkout_id);

    if (!$checkout) {
        return $c->$cb({
            error => "Checkout doesn't exist"
        }, 404);
    }

    return $c->$cb($checkout->unblessed, 200);
}

sub renew {
    my ($c, $args, $cb) = @_;

    my $checkout_id = $args->{checkout_id};
    my $checkout = Koha::Checkouts->find($checkout_id);

    if (!$checkout) {
        return $c->$cb({
            error => "Checkout doesn't exist"
        }, 404);
    }

    my $borrowernumber = $checkout->borrowernumber;
    my $itemnumber = $checkout->itemnumber;

    # Disallow renewal if OpacRenewalAllowed is off and user has insufficient rights
    unless (C4::Context->preference('OpacRenewalAllowed')) {
        my $user = $c->stash('koha.user');
        unless ($user && haspermission($user->userid, { circulate => "circulate_remaining_permissions" })) {
            return $c->$cb({error => "Opac Renewal not allowed"}, 403);
        }
    }

    my ($can_renew, $error) = C4::Circulation::CanBookBeRenewed(
        $borrowernumber, $itemnumber);

    if (!$can_renew) {
        return $c->$cb({error => "Renewal not authorized ($error)"}, 403);
    }

    AddRenewal($borrowernumber, $itemnumber, $checkout->branchcode);
    $checkout = Koha::Checkouts->find($checkout_id);

    return $c->$cb($checkout->unblessed, 200);
}

1;
