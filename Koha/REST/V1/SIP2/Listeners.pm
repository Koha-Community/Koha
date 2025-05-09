package Koha::REST::V1::SIP2::Listeners;

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

use Koha::SIP2::Listener;
use Koha::SIP2::Listeners;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $listeners = $c->objects->search( Koha::SIP2::Listeners->new );
        return $c->render( status => 200, openapi => $listeners );
    } catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::SIP2::Listener object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $listener = $c->objects->find( Koha::SIP2::Listeners->search, $c->param('sip_listener_id') );

        return $c->render_resource_not_found("Listener")
            unless $listener;

        return $c->render(
            status  => 200,
            openapi => $listener
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::SIP2::Listener object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $listener = Koha::SIP2::Listener->new_from_api($body)->store;

                $c->res->headers->location( $c->req->url->to_string . '/' . $listener->sip_listener_id );
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($listener),
                );
            }
        );
    } catch {

        my $to_api_mapping = Koha::SIP2::Listener->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::ObjectNotCreated') ) {
                return $c->render(
                    status  => 500,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::SIP2::Listener object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $listener = Koha::SIP2::Listeners->find( $c->param('sip_listener_id') );

    return $c->render_resource_not_found("Listener")
        unless $listener;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                $listener->set_from_api($body)->store;

                $c->res->headers->location( $c->req->url->to_string . '/' . $listener->sip_listener_id );
                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($listener),
                );
            }
        );
    } catch {
        my $to_api_mapping = Koha::SIP2::Listener->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $listener = Koha::SIP2::Listeners->find( $c->param('sip_listener_id') );

    return $c->render_resource_not_found("Listener")
        unless $listener;

    return try {
        $listener->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
