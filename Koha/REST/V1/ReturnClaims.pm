package Koha::REST::V1::ReturnClaims;

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

use Try::Tiny qw( catch try );

use Koha::Checkouts::ReturnClaims;
use Koha::Checkouts;

=head1 NAME

Koha::REST::V1::ReturnClaims

=head1 API

=head2 Methods

=head3 claim_returned

Claim that a checked out item was returned.

=cut

sub claim_returned {
    my $c    = shift->openapi->valid_input or return;
    my $body = $c->req->json;

    return try {
        my $itemnumber      = $body->{item_id};
        my $charge_lost_fee = $body->{charge_lost_fee} ? 1 : 0;
        my $created_by      = $body->{created_by};
        my $notes           = $body->{notes};

        my $user = $c->stash('koha.user');
        $created_by //= $user->borrowernumber;

        my $checkout = Koha::Checkouts->find( { itemnumber => $itemnumber } );

        return $c->render(
            openapi => { error => "Checkout not found" },
            status  => 404
        ) unless $checkout;

        my $claim = $checkout->claim_returned(
            {
                charge_lost_fee => $charge_lost_fee,
                created_by      => $created_by,
                notes           => $notes,
            }
        );

        $c->res->headers->location($c->req->url->to_string . '/' . $claim->id );
        return $c->render(
            status  => 201,
            openapi => $claim->to_api
        );
    }
    catch {
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => "$_" }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Checkouts::ReturnClaims::NoCreatedBy') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Mandatory attribute created_by missing" }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 update_notes

Update the notes of an existing claim

=cut

sub update_notes {
    my $c = shift->openapi->valid_input or return;

    my $claim_id = $c->param('claim_id');
    my $body     = $c->req->json;

    my $claim = Koha::Checkouts::ReturnClaims->find( $claim_id );

    return $c->render(
        status  => 404,
        openapi => {
            error => "Claim not found"
        }
    ) unless $claim;

    return try {
        my $updated_by = $body->{updated_by};
        my $notes      = $body->{notes};

        my $user = $c->stash('koha.user');
        $updated_by //= $user->borrowernumber;

        $claim->set(
            {
                notes      => $notes,
                updated_by => $updated_by
            }
        )->store;
        $claim->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $claim->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 resolve_claim

Marks a claim as resolved

=cut

sub resolve_claim {
    my $c = shift->openapi->valid_input or return;

    my $claim_id = $c->param('claim_id');
    my $body     = $c->req->json;

    my $claim = Koha::Checkouts::ReturnClaims->find($claim_id);

    return $c->render(
        status  => 404,
        openapi => { error => "Claim not found" }
    ) unless $claim;

    return try {

        my $resolved_by     = $body->{resolved_by};
        my $resolution      = $body->{resolution};
        my $new_lost_status = $body->{new_lost_status};

        my $user = $c->stash('koha.user');
        $resolved_by //= $user->borrowernumber;

        $claim->resolve(
            {
                resolution      => $resolution,
                resolved_by     => $resolved_by,
                new_lost_status => $new_lost_status,
            }
        )->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $claim->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete_claim

Deletes the claim from the database

=cut

sub delete_claim {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $claim = Koha::Checkouts::ReturnClaims->find( $c->param('claim_id') );

        return $c->render(
            status  => 404,
            openapi => { error => "Claim not found" }
        ) unless $claim;

        $claim->delete();

        return $c->render(
            status  => 204,
            openapi => {}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
