package Koha::REST::V1::Messages;

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

use Koha::Patron::Messages;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Messages

=head1 API

=head2 Methods

=head3 list

Controller function that handles retrieving a list of Koha::Patron::Message objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        return $c->render(
            status  => 200,
            openapi => $c->objects->search( Koha::Patron::Messages->new )
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Patron::Message object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $message = $c->objects->find( Koha::Patron::Messages->new, $c->param('message_id') );
        return $c->render_resource_not_found("Message")
            unless $message;

        return $c->render( status => 200, openapi => $message );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Patron::Message object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    try {
        my $message = Koha::Patron::Message->new_from_api( $c->req->json );
        my $user    = $c->stash('koha.user');
        $message->set( { manager_id => $user->borrowernumber } ) unless defined $message->manager_id;
        $message->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $message->message_id );

        # Refetching the message from the database to get the auto-generated message_date
        return $c->render(
            status  => 201,
            openapi => $c->objects->find( Koha::Patron::Messages->new, $message->message_id )
        );
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Patron::Message object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $message = Koha::Patron::Messages->find( $c->param('message_id') );

    return $c->render_resource_not_found("Message")
        unless $message;

    return try {
        my $params = $c->req->json;
        $message->set_from_api($params);
        $message->store();
        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($message),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron::Message object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $message = Koha::Patron::Messages->find( $c->param('message_id') );

    return $c->render_resource_not_found("Message")
        unless $message;

    return try {
        $message->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
