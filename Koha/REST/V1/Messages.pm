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

use Koha::Libraries;
use Koha::Patron::Messages;
use Koha::Patrons;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

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
            openapi => $c->objects->search( Koha::Patron::Messages->search_limited )
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
        my $message = $c->objects->find( Koha::Patron::Messages->search_limited, $c->param('message_id') );
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

    return try {
        my $body = $c->req->json;

        # null library_id means 'use the logged in user library'
        delete $body->{library_id} unless defined $body->{library_id};

        my $error = $c->_validate_body($body);
        return $c->render( status => 400, openapi => $error )
            if $error;

        my $message = Koha::Patron::Message->new_from_api($body);
        my $user    = $c->stash('koha.user');
        $message->set( { manager_id => $user->borrowernumber } ) unless defined $message->manager_id;
        $message->set( { branchcode => $user->branchcode } )     unless defined $message->branchcode;
        $message->store->discard_changes;

        $c->res->headers->location( $c->req->url->to_string . '/' . $message->message_id );
        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($message),
        );
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            my $field = Koha::Patron::Message->to_api_mapping->{ $_->broken_fk } // $_->broken_fk;
            return $c->render(
                status  => 400,
                openapi => { error => "Given $field does not exist", error_code => "invalid_$field" }
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

    return try {
        my $message = $c->_get_editable_message;

        return $c->render_resource_not_found("Message")
            unless $message;

        my $body = $c->req->json;

        my $error = $c->_validate_body($body);
        return $c->render( status => 400, openapi => $error )
            if $error;

        $message->set_from_api($body)->store;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($message),
        );
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            my $field = Koha::Patron::Message->to_api_mapping->{ $_->broken_fk } // $_->broken_fk;
            return $c->render(
                status  => 400,
                openapi => { error => "Given $field does not exist", error_code => "invalid_$field" }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron::Message object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $message = $c->_get_editable_message;

        return $c->render_resource_not_found("Message")
            unless $message;

        $message->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head2 Internal methods

=head3 _get_editable_message

    my $message = $c->_get_editable_message;

Returns the Koha::Patron::Message identified by the I<message_id> path
parameter, if the logged in user is allowed to modify it. Unless
I<AllowAllMessageDeletion> is enabled, only messages from the user's
library can be modified.

=cut

sub _get_editable_message {
    my ($c) = @_;

    my $filters = { message_id => $c->param('message_id') };

    $filters->{branchcode} = $c->stash('koha.user')->branchcode
        unless C4::Context->preference('AllowAllMessageDeletion');

    return Koha::Patron::Messages->search_limited($filters)->next;
}

=head3 _validate_body

    my $error = $c->_validate_body( $body );

Validates the relations in a request body. Returns an error structure
suitable for a 400 response, or undef if the body is valid.

=cut

sub _validate_body {
    my ( $c, $body ) = @_;

    # the patron needs to exist and be visible to the logged in user
    return { error => "Invalid patron_id", error_code => 'invalid_patron_id' }
        if exists $body->{patron_id}
        && !Koha::Patrons->search_limited->find( $body->{patron_id} );

    # messages.branchcode has no FK constraint
    return { error => "Invalid library_id", error_code => 'invalid_library_id' }
        if exists $body->{library_id}
        && !( defined $body->{library_id} && Koha::Libraries->find( $body->{library_id} ) );

    return;
}

1;
