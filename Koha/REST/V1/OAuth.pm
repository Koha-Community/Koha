package Koha::REST::V1::OAuth;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Net::OAuth2::AuthorizationServer;
use Koha::OAuth;

use C4::Context;

sub token {
    my $c = shift->openapi->valid_input or return;

    my $grant_type = $c->validation->param('grant_type');
    unless ($grant_type eq 'client_credentials') {
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

    my $at = Koha::OAuthAccessTokens->search({ access_token => $token })->next;

    my $response = {
        access_token => $token,
        token_type => 'Bearer',
        expires_in => $expires_in,
    };

    return $c->render(status => 200, openapi => $response);
}

1;
