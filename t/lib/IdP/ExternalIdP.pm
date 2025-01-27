package t::lib::IdP::ExternalIdP;

use Mojolicious::Lite;
use Mojo::IOLoop;
use Mojo::IOLoop::Server;
use Mojo::Server::Daemon;

print "Configure idp routes\n";

any '/idp/test/authorization_endpoint' => sub {
    my $c = shift;
    print "pasa por acá\n";
    return $c->render( json => { error => 'invalid_request' }, status => 500 )
        unless ( 3 == grep { $c->param($_) } qw(response_type redirect_uri client_id) )
        && $c->param('response_type') eq 'code';

    my $url = Mojo::URL->new( $c->param('redirect_uri') );
    $url->query( { code => 'authorize-code', state => $c->param('state') } );
    return $c->redirect_to($url);
};

any '/idp/test/token_endpoint/with_id_token/with_email' => sub {
    my $c = shift;
    return $c->render( json => { error => 'invalid_request' }, status => 500 )
        unless ( 4 == grep { $c->param($_) } qw(client_id client_secret redirect_uri code) )
        && $c->param('code') eq 'authorize-code';

    my $claims = {
        aud                => $c->param('client_id'),
        email              => 'test.user@some.library.com',
        iss                => $c->url_for('/idp/test')->to_abs,
        given_name         => 'test',
        family_name        => 'user',
        preferred_username => 'test.user@some.library.com',
        sub                => 'test.user'
    };

    my $rsa = Crypt::OpenSSL::RSA->generate_key(2048);

    my $id_token = Mojo::JWT->new(
        algorithm => 'RS256',
        secret    => $rsa->get_private_key_string,
        set_iat   => 1,
        claims    => $claims,
        header    => { kid => 'TEST_SIGNING_KEY' }
    );

    $c->render(
        status => 200,
        json   => {
            access_token   => 'access',
            expires_in     => 3599,
            ext_expires_in => 3599,
            id_token       => $id_token,
            refresh_token  => 'refresh-token',
            scope          => 'openid',
            token_type     => 'Bearer'
        }
    );
};

any '/idp/test/token_endpoint/with_id_token/without_email' => sub {
    my $c = shift;
    return $c->render( json => { error => 'invalid_request' }, status => 500 )
        unless ( 4 == grep { $c->param($_) } qw(client_id client_secret redirect_uri code) )
        && $c->param('code') eq 'authorize-code';

    my $claims = {
        aud                => $c->param('client_id'),
        iss                => $c->url_for('/idp/test')->to_abs,
        given_name         => 'test',
        family_name        => 'user',
        preferred_username => 'test.user',
        sub                => 'test.user'
    };

    my $rsa = Crypt::OpenSSL::RSA->generate_key(2048);

    my $id_token = Mojo::JWT->new(
        algorithm => 'RS256',
        secret    => $rsa->get_private_key_string,
        set_iat   => 1,
        claims    => $claims,
        header    => { kid => 'TEST_SIGNING_KEY' }
    );

    $c->render(
        status => 200,
        json   => {
            access_token   => 'access',
            expires_in     => 3599,
            ext_expires_in => 3599,
            id_token       => $id_token,
            refresh_token  => 'refresh-token',
            scope          => 'openid',
            token_type     => 'Bearer'
        }
    );
};

any '/idp/test/token_endpoint/without_id_token' => sub {
    my $c = shift;
    return $c->render( json => { error => 'invalid_request' }, status => 500 )
        unless ( 4 == grep { $c->param($_) } qw(client_id client_secret redirect_uri code) )
        && $c->param('code') eq 'authorize-code';

    $c->render(
        status => 200,
        json   => {
            access_token   => 'access',
            expires_in     => 3599,
            ext_expires_in => 3599,
            refresh_token  => 'refresh-token',
            scope          => 'some list of scopes',
            token_type     => 'Bearer'
        }
    );
};

any '/idp/test/userinfo_endpoint' => sub {
    my $c = shift;
    return $c->render( text => 'Unauthorized', status => 401 )
        unless $c->req->headers->authorization eq 'Bearer access';

    $c->render(
        status => 200,
        json   => {
            users => [
                {
                    email          => 'test.user@some.library.com',
                    custom_name    => 'test',
                    custom_surname => 'user',
                    id             => 'test.user',
                    last_login     => 'a long time ago'
                }
            ]
        }
    );
};

any '/idp/test/with_email/.well_known' => sub {
    my $c = shift;

    $c->render(
        status => 200,
        json   => {
            authorization_endpoint => $c->url_for('/idp/test/authorization_endpoint')->to_abs,
            token_endpoint         => $c->url_for('/idp/test/token_endpoint/with_id_token/with_email')->to_abs,
            userinfo_endpoint      => $c->url_for('/idp/test/userinfo_endpoint')->to_abs,
        }
    );
};

any '/idp/test/without_email/.well_known' => sub {
    my $c = shift;

    $c->render(
        status => 200,
        json   => {
            authorization_endpoint => $c->url_for('/idp/test/authorization_endpoint')->to_abs,
            token_endpoint         => $c->url_for('/idp/test/token_endpoint/with_id_token/without_email')->to_abs,
            userinfo_endpoint      => $c->url_for('/idp/test/userinfo_endpoint')->to_abs,
        }
    );
};

my $port   = Mojo::IOLoop::Server->generate_port;
my $daemon = Mojo::Server::Daemon->new(
    app    => app,
    listen => ["http://*:$port"]
);

sub start {
    print "Run daemon\n";
    $daemon->start;
    Mojo::IOLoop->start unless Mojo::IOLoop->is_running;
    return $port;
}

sub stop {
    $daemon->stop;
}

1;
