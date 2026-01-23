#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 3;
use Test::NoWarnings;
use Test::Mojo;

use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new();

t::lib::Mocks::mock_preference( 'RESTOAuth2ClientCredentials', 1 );

subtest 'REST Authentication - Intranet' => rest_auth_subtest('Koha::App::Intranet');
subtest 'REST Authentication - OPAC'     => rest_auth_subtest('Koha::App::Opac');

sub rest_auth_subtest {
    my $app = shift;

    return sub {
        plan tests => 12;

        $schema->storage->txn_begin;

        my $t = Test::Mojo->new($app);

        $t->post_ok('/api/v1/oauth/token')
            ->status_is(400)
            ->json_is( '/errors/0/message', 'Missing property.' )
            ->json_is( '/errors/0/path',    '/grant_type' );

        $t->post_ok( '/api/v1/oauth/token', form => { grant_type => 'client_credentials' } )
            ->status_is(403)
            ->json_is( '/error', 'unauthorized_client' );

        my $patron = $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => {
                    flags => 0    # no permissions
                },
            }
        );
        my $api_key       = Koha::ApiKey->new( { patron_id => $patron->id, description => 'blah' } )->store;
        my $client_id     = $api_key->client_id;
        my $client_secret = $api_key->plain_text_secret;

        $t->post_ok(
            '/api/v1/oauth/token',
            form => { grant_type => 'client_credentials', client_id => $client_id, client_secret => $client_secret }
            )
            ->status_is(200)
            ->json_is( '/expires_in' => 3600 )
            ->json_is( '/token_type' => 'Bearer' )
            ->json_has('/access_token');

        $schema->storage->txn_rollback;
    }
}
