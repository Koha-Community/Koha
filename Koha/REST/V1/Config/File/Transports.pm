package Koha::REST::V1::Config::File::Transports;

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

use Koha::File::Transports;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

Controller method that handles listing Koha::File::Transport objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $file_transports_set = Koha::File::Transports->new;
        my $file_transports     = $c->objects->search($file_transports_set);
        return $c->render(
            status  => 200,
            openapi => $file_transports
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller method that handles retrieving a single Koha::File::Transport object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $file_transport = Koha::File::Transports->find( $c->param('file_transport_id') );

        return $c->render_resource_not_found("File transport")
            unless $file_transport;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($file_transport),
        );
    } catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

Controller method that handles adding a new Koha::File::Transport object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $file_transport = Koha::File::Transport->new_from_api( $c->req->json );
        $file_transport->store->discard_changes;

        $c->res->headers->location( $c->req->url->to_string . '/' . $file_transport->id );

        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($file_transport),
        );
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error    => $_->error,
                    conflict => $_->duplicate_id
                }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller method that handles updating a Koha::File::Transport object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $file_transport = Koha::File::Transports->find( $c->param('file_transport_id') );

    return $c->render_resource_not_found("File transport")
        unless $file_transport;

    return try {
        $file_transport->set_from_api( $c->req->json );
        $file_transport->store->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($file_transport),
        );
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error    => $_->error,
                    conflict => $_->duplicate_id
                }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller method that handles deleting a Koha::File::Transport object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $file_transport = Koha::File::Transports->find( $c->param('file_transport_id') );

    return $c->render_resource_not_found("File transport")
        unless $file_transport;

    return try {
        $file_transport->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
