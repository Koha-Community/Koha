package Koha::REST::V1::Tickets;

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

use Koha::Ticket;
use Koha::Tickets;
use Koha::Ticket::Update;
use Koha::Ticket::Updates;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $tickets_set = Koha::Tickets->new;
        my $tickets     = $c->objects->search($tickets_set);
        return $c->render( status => 200, openapi => $tickets );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $ticket = Koha::Tickets->find( $c->validation->param('ticket_id') );
        unless ($ticket) {
            return $c->render(
                status  => 404,
                openapi => { error => "Ticket not found" }
            );
        }

        return $c->render( status => 200, openapi => $ticket->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

=cut

sub add {
    my $c = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');

    return try {
        my $body   = $c->validation->param('body');

        # Set reporter from session
        $body->{reporter_id} = $patron->id;
        # FIXME: We should allow impersonation at a later date to
        # allow an API user to submit on behalf of a user

        my $ticket = Koha::Ticket->new_from_api($body)->store;
        $ticket->discard_changes;
        $c->res->headers->location(
            $c->req->url->to_string . '/' . $ticket->id );
        return $c->render(
            status  => 201,
            openapi => $ticket->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $ticket = Koha::Tickets->find( $c->validation->param('ticket_id') );

    if ( not defined $ticket ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        );
    }

    return try {
        $ticket->set_from_api( $c->validation->param('body') );
        $ticket->store();
        return $c->render( status => 200, openapi => $ticket->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $ticket = Koha::Tickets->find( $c->validation->param('ticket_id') );
    if ( not defined $ticket ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Object not found" }
        );
    }

    return try {
        $ticket->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
