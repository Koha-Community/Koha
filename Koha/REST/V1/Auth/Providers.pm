package Koha::REST::V1::Auth::Providers;

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

use Koha::Auth::Provider::OAuth;
use Koha::Auth::Provider::OIDC;
use Koha::Auth::Providers;

use Koha::Database;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Auth::Providers - Controller library for handling
authentication providers routes.

=head2 Operations

=head3 list

Controller method for listing authentication providers.

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $providers_rs = Koha::Auth::Providers->new;
        return $c->render(
            status  => 200,
            openapi => $c->objects->search($providers_rs)
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller method for retrieving an authentication provider.

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $auth_provider_id = $c->validation->param('auth_provider_id');
        my $provider = $c->objects->find( Koha::Auth::Providers->new, $auth_provider_id );

        unless ( $provider ) {
            return $c->render(
                status  => 404,
                openapi => {
                    error      => 'Object not found',
                    error_code => 'not_found',
                }
            );
        }

        return $c->render( status => 200, openapi => $provider );
    }
    catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

Controller method for adding an authentication provider.

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                my $config   = delete $body->{config};
                my $mapping  = delete $body->{mapping};
                my $protocol = delete $body->{protocol};

                my $class = Koha::Auth::Provider::protocol_to_class_mapping->{$protocol};

                my $provider = $class->new_from_api( $body );
                $provider->store;

                $provider->set_config( $config );
                $provider->set_mapping( $mapping );

                $c->res->headers->location( $c->req->url->to_string . '/' . $provider->auth_provider_id );
                return $c->render(
                    status  => 201,
                    openapi => $provider->to_api
                );
            }
        );
    }
    catch {
        if ( blessed($_) ) {
            if ( $_->isa('Koha::Exceptions::MissingParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                        error      => "Missing parameter config." . $_->parameter,
                        error_code => 'missing_parameter'
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller method for updating an authentication provider.

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $auth_provider_id = $c->validation->param('auth_provider_id');
    my $provider = Koha::Auth::Providers->find( $auth_provider_id );

    unless ( $provider ) {
        return $c->render(
            status  => 404,
            openapi => {
                error      => 'Object not found',
                error_code => 'not_found',
            }
        );
    }

    return try {

        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                my $config   = delete $body->{config};
                my $mapping  = delete $body->{mapping};

                $provider = $provider->set_from_api( $body )->upgrade_class;

                $provider->set_config( $config );
                $provider->set_mapping( $mapping );
                # set_config and set_mapping already called store()
                $provider->discard_changes;

                return $c->render(
                    status  => 200,
                    openapi => $provider->to_api
                );
            }
        );
    }
    catch {
        if ( blessed($_) ) {
            if ( $_->isa('Koha::Exceptions::MissingParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                        error      => "Missing parameter config." . $_->parameter,
                        error_code => 'missing_parameter'
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller method for deleting an authentication provider.

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $provider = Koha::Auth::Providers->find( $c->validation->param('auth_provider_id') );
    unless ( $provider ) {
        return $c->render(
            status  => 404,
            openapi => {
                error      => 'Object not found',
                error_code => 'not_found',
            }
        );
    }

    return try {
        $provider->delete;
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
