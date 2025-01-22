package Koha::REST::V1::Config::SFTP::Servers;

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

use Koha::File::Transports;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

Controller method that handles listing Koha::SFTP::Server objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $sftp_servers_set = Koha::File::Transports->new;
        my $sftp_servers     = $c->objects->search($sftp_servers_set);
        return $c->render(
            status  => 200,
            openapi => $sftp_servers
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller method that handles retrieving a single Koha::SFTP::Server object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $sftp_server = Koha::File::Transports->find( $c->param('sftp_server_id') );

        return $c->render_resource_not_found("FTP/SFTP server")
            unless $sftp_server;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($sftp_server),
        );
    } catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

Controller method that handles adding a new Koha::SFTP::Server object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $sftp_server = Koha::SFTP::Server->new_from_api( $c->req->json );
        $sftp_server->store->discard_changes;

        $c->res->headers->location( $c->req->url->to_string . '/' . $sftp_server->id );

        return $c->render(
            status  => 201,
            openapi => $c->objects->to_api($sftp_server),
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

Controller method that handles updating a Koha::SFTP::Server object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $sftp_server = Koha::File::Transports->find( $c->param('sftp_server_id') );

    return $c->render_resource_not_found("FTP/SFTP server")
        unless $sftp_server;

    return try {
        $sftp_server->set_from_api( $c->req->json );
        $sftp_server->store->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($sftp_server),
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

Controller method that handles deleting a Koha::SFTP::Server object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $sftp_server = Koha::File::Transports->find( $c->param('sftp_server_id') );

    return $c->render_resource_not_found("FTP/SFTP server")
        unless $sftp_server;

    return try {
        $sftp_server->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 test

Controller method that invokes Koha::SFTP::Server->test_conn

=cut

sub test {
    my $c = shift->openapi->valid_input or return;

    my $sftp_server = Koha::File::Transports->find( $c->param('sftp_server_id') );

    return $c->render_resource_not_found("FTP/SFTP server")
        unless $sftp_server;
}

1;
