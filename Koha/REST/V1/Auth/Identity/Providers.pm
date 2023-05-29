package Koha::REST::V1::Auth::Identity::Providers;

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

use Koha::Auth::Identity::Provider::OAuth;
use Koha::Auth::Identity::Provider::OIDC;
use Koha::Auth::Identity::Providers;

use Koha::Database;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Auth::Identity::Providers - Controller library for handling
identity providers routes.

=head2 Operations

=head3 list

Controller method for listing identity providers.

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $providers_rs = Koha::Auth::Identity::Providers->new;
        return $c->render(
            status  => 200,
            openapi => $c->objects->search($providers_rs)
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller method for retrieving an identity provider.

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $provider = $c->objects->find( Koha::Auth::Identity::Providers->new, $c->param('identity_provider_id') );

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

Controller method for adding an identity provider.

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $config   = delete $body->{config};
                my $mapping  = delete $body->{mapping};
                my $protocol = delete $body->{protocol};

                my $class = Koha::Auth::Identity::Provider::protocol_to_class_mapping->{$protocol};

                my $provider = $class->new_from_api( $body )
                                     ->set_config( $config )
                                     ->set_mapping( $mapping )
                                     ->store;

                $c->res->headers->location( $c->req->url->to_string . '/' . $provider->identity_provider_id );
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

Controller method for updating an identity provider.

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $provider = Koha::Auth::Identity::Providers->find( $c->param('identity_provider_id') );

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

                my $body = $c->req->json;

                my $config   = delete $body->{config};
                my $mapping  = delete $body->{mapping};

                $provider = $provider->set_from_api( $body )->upgrade_class;

                $provider->set_config( $config )
                         ->set_mapping( $mapping )
                         ->store;

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

Controller method for deleting an identity provider.

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $provider = Koha::Auth::Identity::Providers->find( $c->param('identity_provider_id') );
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
