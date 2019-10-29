package Koha::REST::V1::ReturnClaims;

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

use Try::Tiny;

use Koha::Checkouts::ReturnClaims;
use Koha::Checkouts;
use Koha::DateUtils qw( dt_from_string output_pref );

=head1 NAME

Koha::REST::V1::ReturnClaims

=head2 Operations

=head3 claim_returned

Claim that a checked out item was returned.

=cut

sub claim_returned {
    my $c    = shift->openapi->valid_input or return;
    my $body = $c->validation->param('body');

    return try {
        my $itemnumber      = $body->{item_id};
        my $charge_lost_fee = $body->{charge_lost_fee} ? 1 : 0;
        my $created_by      = $body->{created_by};
        my $notes           = $body->{notes};

        my $user = $c->stash('koha.user');
        $created_by //= $user->borrowernumber;

        my $checkout = Koha::Checkouts->find( { itemnumber => $itemnumber } );

        return $c->render(
            openapi => { error => "Not found - Checkout not found" },
            status  => 404
        ) unless $checkout;

        my $claim = Koha::Checkouts::ReturnClaims->find(
            {
                issue_id => $checkout->id
            }
        );
        return $c->render(
            openapi => { error => "Bad request - claim exists" },
            status  => 400
        ) if $claim;

        $claim = $checkout->claim_returned(
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
        if ( $_->isa('Koha::Exceptions::Checkouts::ReturnClaims') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "$_" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head3 update_notes

Update the notes of an existing claim

=cut

sub update_notes {
    my $c     = shift->openapi->valid_input or return;
    my $input = $c->validation->output;
    my $body  = $c->validation->param('body');

    return try {
        my $id         = $input->{claim_id};
        my $updated_by = $body->{updated_by};
        my $notes      = $body->{notes};

        $updated_by ||=
          C4::Context->userenv ? C4::Context->userenv->{number} : undef;

        my $claim = Koha::Checkouts::ReturnClaims->find($id);

        return $c->render(
            openapi => { error => "Not found - Claim not found" },
            status  => 404
        ) unless $claim;

        $claim->set(
            {
                notes      => $notes,
                updated_by => $updated_by,
                updated_on => dt_from_string(),
            }
        );
        $claim->store();

        my $data = $claim->unblessed;

        my $c_dt = dt_from_string( $data->{created_on} );
        my $u_dt = dt_from_string( $data->{updated_on} );

        $data->{created_on_formatted} = output_pref( { dt => $c_dt } );
        $data->{updated_on_formatted} = output_pref( { dt => $u_dt } );

        $data->{created_on} = $c_dt->iso8601;
        $data->{updated_on} = $u_dt->iso8601;

        return $c->render( openapi => $data, status => 200 );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => $_->{msg} }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head3 resolve_claim

Marks a claim as resolved

=cut

sub resolve_claim {
    my $c     = shift->openapi->valid_input or return;
    my $input = $c->validation->output;
    my $body  = $c->validation->param('body');

    return try {
        my $id          = $input->{claim_id};
        my $resolved_by = $body->{updated_by};
        my $resolution  = $body->{resolution};

        $resolved_by ||=
          C4::Context->userenv ? C4::Context->userenv->{number} : undef;

        my $claim = Koha::Checkouts::ReturnClaims->find($id);

        return $c->render(
            openapi => { error => "Not found - Claim not found" },
            status  => 404
        ) unless $claim;

        $claim->set(
            {
                resolution  => $resolution,
                resolved_by => $resolved_by,
                resolved_on => dt_from_string(),
            }
        );
        $claim->store();

        return $c->render( openapi => $claim, status => 200 );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => $_->{msg} }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head3 delete_claim

Deletes the claim from the database

=cut

sub delete_claim {
    my $c     = shift->openapi->valid_input or return;
    my $input = $c->validation->output;

    return try {
        my $id = $input->{claim_id};

        my $claim = Koha::Checkouts::ReturnClaims->find($id);

        return $c->render(
            openapi => { error => "Not found - Claim not found" },
            status  => 404
        ) unless $claim;

        $claim->delete();

        return $c->render( openapi => $claim, status => 200 );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => $_->{msg} }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

1;
