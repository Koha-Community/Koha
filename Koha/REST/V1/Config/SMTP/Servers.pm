package Koha::REST::V1::Config::SMTP::Servers;

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

use Koha::SMTP::Servers;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

Controller method that handles listing Koha::SMTP::Server objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $smtp_servers_set = Koha::SMTP::Servers->new;
        my $smtp_servers = $c->objects->search( $smtp_servers_set );
        return $c->render(
            status  => 200,
            openapi => $smtp_servers
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller method that handles retrieving a single Koha::SMTP::Server object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $smtp_server = Koha::SMTP::Servers->find( $c->param('smtp_server_id') );

        unless ($smtp_server) {
            return $c->render(
                status  => 404,
                openapi => {
                    error => "SMTP server not found"
                }
            );
        }

        my $embed = $c->stash('koha.embed');

        return $c->render(
            status  => 200,
            openapi => $smtp_server->to_api({ embed => $embed })
        );
    }
    catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

Controller method that handles adding a new Koha::SMTP::Server object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $smtp_server = Koha::SMTP::Server->new_from_api( $c->req->json );
        $smtp_server->store->discard_changes;

        $c->res->headers->location( $c->req->url->to_string . '/' . $smtp_server->id );

        return $c->render(
            status  => 201,
            openapi => $smtp_server->to_api
        );
    }
    catch {
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

Controller method that handles updating a Koha::SMTP::Server object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $smtp_server = Koha::SMTP::Servers->find( $c->param('smtp_server_id') );

    if ( not defined $smtp_server ) {
        return $c->render(
            status  => 404,
            openapi => {
                error => "Object not found"
            }
        );
    }

    return try {
        $smtp_server->set_from_api( $c->req->json );
        $smtp_server->store->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $smtp_server->to_api
        );
    }
    catch {
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

Controller method that handles deleting a Koha::SMTP::Server object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $smtp_server = Koha::SMTP::Servers->find( $c->param('smtp_server_id') );

    if ( not defined $smtp_server ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    return try {
        $smtp_server->delete;

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
