package Koha::REST::V1;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious';

use C4::Context;
use JSON::Validator::OpenAPI::Mojolicious;

=head1 NAME

Koha::REST::V1 - Main v.1 REST api class

=head1 API

=head2 Class Methods

=head3 startup

Overloaded Mojolicious->startup method. It is called at application startup.

=cut

sub startup {
    my $self = shift;

    # Remove /api/v1/app.pl/ from the path
    $self->hook( before_dispatch => sub {
        shift->req->url->base->path('/');
    });

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
    $validator->load_and_validate_schema(
        $self->home->rel_file("api/v1/swagger/swagger.json"),
        {
          allow_invalid_ref  => 1,
        }
      );

    push @{$self->routes->namespaces}, 'Koha::Plugin';

    my $spec = $validator->schema->data;
    $self->plugin(
        'Koha::REST::Plugin::PluginRoutes' => {
            spec      => $spec,
            validator => $validator
        }
    );

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

    $self->plugin( 'Koha::REST::Plugin::Pagination' );
    $self->plugin( 'Koha::REST::Plugin::Query' );
    $self->plugin( 'Koha::REST::Plugin::Objects' );
}

1;
