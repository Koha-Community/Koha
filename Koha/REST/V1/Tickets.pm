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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

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
        my $tickets = $c->objects->search( Koha::Tickets->new );
        return $c->render( status => 200, openapi => $tickets );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $ticket = Koha::Tickets->find( $c->param('ticket_id') );
        return $c->render_resource_not_found("Ticket")
            unless $ticket;

        return $c->render( status => 200, openapi => $c->objects->to_api($ticket), );
    } catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

=cut

sub add {
    my $c      = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');

    return try {
        my $body = $c->req->json;

        # Set reporter from session
        $body->{reporter_id} = $patron->id;

        # FIXME: We should allow impersonation at a later date to
        # allow an API user to submit on behalf of a user

        my $ticket = Koha::Ticket->new_from_api($body)->store;
        $ticket->discard_changes;
        $c->res->headers->location( $c->req->url->to_string . '/' . $ticket->id );
        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($ticket),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $ticket = Koha::Tickets->find( $c->param('ticket_id') );

    return $c->render_resource_not_found("Ticket")
        unless $ticket;

    my $assignee_before = $ticket->assignee_id;
    return try {
        $ticket->set_from_api( $c->req->json );
        $ticket->store();

        # Create update if assignee changed
        if ( $assignee_before ne $ticket->assignee_id ) {
            my $patron = $c->stash('koha.user');
            my $update = {
                user_id     => $patron->id,
                ticket_id   => $ticket->id,
                public      => 0,
                assignee_id => $ticket->assignee_id,
                message     => ''
            };
            Koha::Ticket::Update->new($update)->store();
        }
        return $c->render( status => 200, openapi => $c->objects->to_api($ticket) );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $ticket = Koha::Tickets->find( $c->param('ticket_id') );

    return $c->render_resource_not_found("Ticket")
        unless $ticket;

    return try {
        $ticket->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_updates

=cut

sub list_updates {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $ticket = Koha::Tickets->find( $c->param('ticket_id') );

        return $c->render_resource_not_found("Ticket")
            unless $ticket;

        my $updates_set = $ticket->updates;
        my $updates     = $c->objects->search($updates_set);
        return $c->render( status => 200, openapi => $updates );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add_update

=cut

sub add_update {
    my $c      = shift->openapi->valid_input or return;
    my $patron = $c->stash('koha.user');

    my $ticket_id_param = $c->param('ticket_id');
    my $ticket_update   = $c->req->json;
    $ticket_update->{ticket_id} //= $ticket_id_param;

    if ( $ticket_update->{ticket_id} != $ticket_id_param ) {
        return $c->render(
            status  => 400,
            openapi => { error => "Ticket Mismatch" }
        );
    }

    # Set user from session
    $ticket_update->{user_id} = $patron->id;

    # FIXME: We should allow impersonation at a later date to
    # allow an API user to submit on behalf of a user

    return try {
        my $state = delete $ticket_update->{state};

        # Store update
        my $update = Koha::Ticket::Update->new_from_api($ticket_update)->store;
        $update->discard_changes;

        # Update ticket state if needed
        if ( defined($state) && $state eq 'resolved' ) {
            my $ticket = $update->ticket;
            $ticket->set(
                {
                    resolver_id   => $update->user_id,
                    resolved_date => $update->date
                }
            )->store;
        }

        # Update ticket status if needed
        if ( $ticket_update->{status} ) {
            my $ticket = $update->ticket;
            $ticket->set( { status => $ticket_update->{status} } )->store;
        }

        # Update ticket assignee if needed
        if ( $ticket_update->{assignee_id} ) {
            my $ticket = $update->ticket;
            $ticket->set( { assignee_id => $ticket_update->{assignee_id} } )->store;
        }

        # Optionally add to message_queue here to notify reporter
        if ( $update->public ) {
            my $notice =
                ( defined($state) && $state eq 'resolved' )
                ? 'TICKET_RESOLVE'
                : 'TICKET_UPDATE';
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'catalogue',
                letter_code => $notice,
                branchcode  => $update->user->branchcode,
                tables      => { ticket_updates => $update->id }
            );

            if ($letter) {
                my $message_id = C4::Letters::EnqueueLetter(
                    {
                        letter                 => $letter,
                        borrowernumber         => $update->ticket->reporter_id,
                        message_transport_type => 'email',
                    }
                );
            }
        }

        # Return
        $c->res->headers->location( $c->req->url->to_string . '/' . $update->id );
        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($update),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
