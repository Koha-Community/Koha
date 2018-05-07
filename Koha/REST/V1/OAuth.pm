package Koha::REST::V1::OAuth;

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

use Module::Load::Conditional;

use C4::Context;
use Koha::OAuth;

use Mojo::Base 'Mojolicious::Controller';

=head1 NAME

Koha::REST::V1::OAuth - Controller library for handling OAuth2-related token handling

=head2 Operations

=head3 token

Controller method handling token requests

=cut

sub token {

    my $c = shift->openapi->valid_input or return;

    if ( Module::Load::Conditional::can_load('Net::OAuth2::AuthorizationServer') ) {
        require Net::OAuth2::AuthorizationServer;
    }
    else {
        return $c->render( status => 400, openapi => { error => 'Unimplemented grant type' } );
    }

    my $grant_type = $c->validation->param('grant_type');
    unless ( $grant_type eq 'client_credentials' and C4::Context->preference('RESTOAuth2ClientCredentials') ) {
        return $c->render(status => 400, openapi => {error => 'Unimplemented grant type'});
    }

    my $client_id = $c->validation->param('client_id');
    my $client_secret = $c->validation->param('client_secret');

    my $cb = "${grant_type}_grant";
    my $server = Net::OAuth2::AuthorizationServer->new;
    my $grant = $server->$cb(Koha::OAuth::config);

    # verify a client against known clients
    my ( $is_valid, $error ) = $grant->verify_client(
        client_id     => $client_id,
        client_secret => $client_secret,
    );

    unless ($is_valid) {
        return $c->render(status => 403, openapi => {error => $error});
    }

    # generate a token
    my $token = $grant->token(
        client_id => $client_id,
        type      => 'access',
    );

    # store access token
    my $expires_in = 3600;
    $grant->store_access_token(
        client_id    => $client_id,
        access_token => $token,
        expires_in   => $expires_in,
    );

    my $response = {
        access_token => $token,
        token_type => 'Bearer',
        expires_in => $expires_in,
    };

    return $c->render(status => 200, openapi => $response);
}

1;
