package Koha::REST::V1;

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

use Mojo::Base 'Mojolicious';

use C4::Context;
use Koha::Logger;

use JSON::Validator::OpenAPI::Mojolicious;
use Try::Tiny;

=head1 NAME

Koha::REST::V1 - Main v.1 REST api class

=head1 API

=head2 Class Methods

=head3 startup

Overloaded Mojolicious->startup method. It is called at application startup.

=cut

sub startup {
    my $self = shift;

    $self->hook(
        before_dispatch => sub {
            my $c = shift;

            # Remove /api/v1/app.pl/ from the path
            $c->req->url->base->path('/');

            # Handle CORS
            $c->res->headers->header( 'Access-Control-Allow-Origin' =>
                  C4::Context->preference('AccessControlAllowOrigin') )
              if C4::Context->preference('AccessControlAllowOrigin');
        }
    );

    # Force charset=utf8 in Content-Type header for JSON responses
    $self->types->type( json    => 'application/json; charset=utf8' );
    # MARC-related types
    $self->types->type( marcxml => 'application/marcxml+xml' );
    $self->types->type( mij     => 'application/marc-in-json' );
    $self->types->type( marc    => 'application/marc' );

    my $secret_passphrase = C4::Context->config('api_secret_passphrase');
    if ($secret_passphrase) {
        $self->secrets([$secret_passphrase]);
    }

    my $validator = JSON::Validator::OpenAPI::Mojolicious->new;

    push @{$self->routes->namespaces}, 'Koha::Plugin';

    # Try to load and merge all schemas first and validate the result just once.
    my $spec;
    my $swagger_schema = $self->home->rel_file("api/swagger-v2-schema.json");
    try {
        $spec = $validator->bundle(
            {
                replace => 1,
                schema => $self->home->rel_file("api/v1/swagger/swagger.yaml")
            }
        );

        $self->plugin(
            'Koha::REST::Plugin::PluginRoutes' => {
                spec               => $spec,
                validator          => undef
            }
        ) unless C4::Context->needs_install; # load only if Koha is installed

        $self->plugin(
            OpenAPI => {
                spec  => $spec,
                route => $self->routes->under('/api/v1')->to('Auth#under'),
                schema => ( $swagger_schema ) ? $swagger_schema : undef,
                allow_invalid_ref =>
                1,    # required by our spec because $ref directly under
                        # Paths-, Parameters-, Definitions- & Info-object
                        # is not allowed by the OpenAPI specification.
            }
        );
    }
    catch {
        # Validation of the complete spec failed. Resort to validation one-by-one
        # to catch bad ones.

        # JSON::Validator uses confess, so trim call stack from the message.
        my $logger = Koha::Logger->get({ interface => 'api' });
        $logger->error("Warning: Could not load REST API spec bundle: " . $_);

        try {
            $validator->load_and_validate_schema(
                $self->home->rel_file("api/v1/swagger/swagger.json"),
                {
                    allow_invalid_ref  => 1,
                    schema => ( $swagger_schema ) ? $swagger_schema : undef,
                }
            );

            $spec = $validator->schema->data;
            $self->plugin(
                'Koha::REST::Plugin::PluginRoutes' => {
                    spec      => $spec,
                    validator => $validator
                }
            )  unless C4::Context->needs_install; # load only if Koha is installed

            $self->plugin(
                OpenAPI => {
                    spec  => $spec,
                    route => $self->routes->under('/api/v1')->to('Auth#under'),
                    allow_invalid_ref =>
                    1,    # required by our spec because $ref directly under
                            # Paths-, Parameters-, Definitions- & Info-object
                            # is not allowed by the OpenAPI specification.
                }
            );
        }
        catch {
            # JSON::Validator uses confess, so trim call stack from the message.
            $logger->error("Warning: Could not load REST API spec bundle: " . $_);
        };
    };

    $self->plugin( 'Koha::REST::Plugin::Pagination' );
    $self->plugin( 'Koha::REST::Plugin::Query' );
    $self->plugin( 'Koha::REST::Plugin::Objects' );
    $self->plugin( 'Koha::REST::Plugin::Exceptions' );
}

1;
