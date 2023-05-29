package Koha::REST::V1::Checkouts;

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

use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON;

use C4::Auth qw( haspermission );
use C4::Context;
use C4::Circulation qw( AddRenewal CanBookBeRenewed );
use Koha::Checkouts;
use Koha::Old::Checkouts;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Checkout

=head1 API

=head2 Methods

=head3 list

List Koha::Checkout objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $checked_in = $c->param('checked_in');
    $c->req->params->remove('checked_in');

    try {
        my $checkouts_set;

        if ( $checked_in ) {
            $checkouts_set = Koha::Old::Checkouts->new;
        } else {
            $checkouts_set = Koha::Checkouts->new;
        }

        my $checkouts = $c->objects->search( $checkouts_set );

        return $c->render(
            status  => 200,
            openapi => $checkouts
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

get one checkout

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->param('checkout_id');
    my $checkout = Koha::Checkouts->find( $checkout_id );
    $checkout = Koha::Old::Checkouts->find( $checkout_id )
        unless ($checkout);

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    return try {
        return $c->render(
            status  => 200,
            openapi => $checkout->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get_renewals

List Koha::Checkout::Renewals

=cut

sub get_renewals {
    my $c = shift->openapi->valid_input or return;

    try {
        my $checkout_id = $c->param('checkout_id');
        my $checkout    = Koha::Checkouts->find($checkout_id);
        $checkout = Koha::Old::Checkouts->find($checkout_id)
          unless ($checkout);

        unless ($checkout) {
            return $c->render(
                status  => 404,
                openapi => { error => "Checkout doesn't exist" }
            );
        }

        my $renewals_rs = $checkout->renewals;
        my $renewals = $c->objects->search( $renewals_rs );

        return $c->render(
            status  => 200,
            openapi => $renewals
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}


=head3 renew

Renew a checkout

=cut

sub renew {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->param('checkout_id');
    my $seen = $c->param('seen') || 1;
    my $checkout = Koha::Checkouts->find( $checkout_id );

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    return try {
        my ($can_renew, $error) = CanBookBeRenewed($checkout->patron, $checkout);

        if (!$can_renew) {
            return $c->render(
                status => 403,
                openapi => { error => "Renewal not authorized ($error)" }
            );
        }

        AddRenewal(
            $checkout->borrowernumber,
            $checkout->itemnumber,
            $checkout->branchcode,
            undef,
            undef,
            $seen
        );
        $checkout = Koha::Checkouts->find($checkout_id);

        $c->res->headers->location( $c->req->url->to_string );
        return $c->render(
            status  => 201,
            openapi => $checkout->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 allows_renewal

Checks if the checkout could be renewed and return the related information.

=cut

sub allows_renewal {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->param('checkout_id');
    my $checkout = Koha::Checkouts->find( $checkout_id );

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    return try {
        my ($can_renew, $error) = CanBookBeRenewed($checkout->patron, $checkout);

        my $renewable = Mojo::JSON->false;
        $renewable = Mojo::JSON->true if $can_renew;

        my $rule = Koha::CirculationRules->get_effective_rule(
            {
                categorycode => $checkout->patron->categorycode,
                itemtype     => $checkout->item->effective_itemtype,
                branchcode   => $checkout->branchcode,
                rule_name    => 'renewalsallowed',
            }
        );
        return $c->render(
            status => 200,
            openapi => {
                allows_renewal => $renewable,
                max_renewals => $rule->rule_value,
                current_renewals => $checkout->renewals_count,
                unseen_renewals => $checkout->unseen_renewals,
                error => $error
            }
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
