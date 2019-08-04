package Koha::REST::V1::Checkouts;

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
use Mojo::JSON;

use C4::Auth qw( haspermission );
use C4::Context;
use C4::Circulation;
use Koha::Checkouts;
use Koha::Old::Checkouts;

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Checkout

=head1 API

=head2 Methods

=head3 list

List Koha::Checkout objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $checked_in = $c->validation->param('checked_in');

    try {
        my $checkouts_set;

        if ( $checked_in ) {
            $checkouts_set = Koha::Old::Checkouts->new;
        } else {
            $checkouts_set = Koha::Checkouts->new;
        }

        my $args = $c->validation->output;
        my $attributes = {};

        # Extract reserved params
        my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($args);

        # Merge sorting into query attributes
        $c->dbic_merge_sorting(
            {
                attributes => $attributes,
                params     => $reserved_params,
                result_set => $checkouts_set
            }
        );

        # Merge pagination into query attributes
        $c->dbic_merge_pagination(
            {
                filter => $attributes,
                params => $reserved_params
            }
        );

        # Call the to_model function by reference, if defined
        if ( defined $filtered_params ) {
            # remove checked_in
            delete $filtered_params->{checked_in};
            # Apply the mapping function to the passed params
            $filtered_params = $checkouts_set->attributes_from_api($filtered_params);
            $filtered_params = $c->build_query_params( $filtered_params, $reserved_params );
        }

        # Perform search
        my $checkouts = $checkouts_set->search( $filtered_params, $attributes );

        if ($checkouts->is_paged) {
            $c->add_pagination_headers({
                total => $checkouts->pager->total_entries,
                params => $args,
            });
        }

        return $c->render( status => 200, openapi => $checkouts->to_api );
    } catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(
                status => 500,
                openapi => { error => $_->{msg} }
            );
        } else {
            return $c->render(
                status => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head3 get

get one checkout

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->validation->param('checkout_id');
    my $checkout = Koha::Checkouts->find( $checkout_id );
    $checkout = Koha::Old::Checkouts->find( $checkout_id )
        unless ($checkout);

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    return $c->render(
        status  => 200,
        openapi => $checkout->to_api
    );
}

=head3 renew

Renew a checkout

=cut

sub renew {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->validation->param('checkout_id');
    my $checkout = Koha::Checkouts->find( $checkout_id );

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    my $borrowernumber = $checkout->borrowernumber;
    my $itemnumber = $checkout->itemnumber;

    my ($can_renew, $error) = C4::Circulation::CanBookBeRenewed(
        $borrowernumber, $itemnumber);

    if (!$can_renew) {
        return $c->render(
            status => 403,
            openapi => { error => "Renewal not authorized ($error)" }
        );
    }

    AddRenewal($borrowernumber, $itemnumber, $checkout->branchcode);
    $checkout = Koha::Checkouts->find($checkout_id);

    $c->res->headers->location( $c->req->url->to_string );
    return $c->render(
        status  => 201,
        openapi => $checkout->to_api
    );
}

=head3 allows_renewal

Checks if the checkout could be renewed and return the related information.

=cut

sub allows_renewal {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->validation->param('checkout_id');
    my $checkout = Koha::Checkouts->find( $checkout_id );

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    my ($can_renew, $error) = C4::Circulation::CanBookBeRenewed(
        $checkout->borrowernumber, $checkout->itemnumber);

    my $renewable = Mojo::JSON->false;
    $renewable = Mojo::JSON->true if $can_renew;

    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            categorycode => $checkout->patron->categorycode,
            itemtype     => $checkout->item->effective_itemtype,
            branchcode   => $checkout->branchcode,
        }
    );
    return $c->render(
        status => 200,
        openapi => {
            allows_renewal => $renewable,
            max_renewals => $rule->renewalsallowed,
            current_renewals => $checkout->renewals,
            error => $error
        }
    );
}

1;
