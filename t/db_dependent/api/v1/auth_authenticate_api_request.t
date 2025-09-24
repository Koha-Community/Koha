#!/usr/bin/env perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 7;
use Test::Mojo;

use Module::Load::Conditional qw(can_load);

use Koha::ApiKeys;
use Koha::Database;
use Koha::Patrons;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $t       = Test::Mojo->new('Koha::REST::V1');
my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

my $remote_address = '127.0.0.1';
my $tx;

# FIXME: CGI::Session::Driver::DBI explicitly sets AutoCommit=1 [1] which breaks the rollback in out tests.
# Until we change into some other library, set SessionStorage to 'tmp'
# [1] https://metacpan.org/source/CGI::Session::Driver::DBI#L28
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

subtest 'token-based tests' => sub {

    if ( can_load( modules => { 'Net::OAuth2::AuthorizationServer' => undef } ) ) {
        plan tests => 15;
    } else {
        plan skip_all => 'Net::OAuth2::AuthorizationServer not available';
    }

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 },
        }
    );

    t::lib::Mocks::mock_preference( 'RESTOAuth2ClientCredentials', 1 );

    my $api_key = Koha::ApiKey->new( { patron_id => $patron->id, description => 'blah' } )->store;

    my $formData = {
        grant_type    => 'client_credentials',
        client_id     => $api_key->client_id,
        client_secret => $api_key->plain_text_secret
    };
    $t->post_ok( '/api/v1/oauth/token', form => $formData )->status_is(200)->json_is( '/expires_in' => 3600 )
        ->json_is( '/token_type' => 'Bearer' )->json_has('/access_token');

    my $access_token = $t->tx->res->json->{access_token};

    my $stash;
    my $interface;
    my $userenv;
    my $language_env;

    my $accept_language = 'es-ES,es;q=0.9,en-US;q=0.8,en;q=0.7';

    my $tx = $t->ua->build_tx( GET => '/api/v1/acquisitions/orders' );
    $tx->req->headers->authorization("Bearer $access_token");
    $tx->req->headers->header( 'x-koha-embed' => 'fund' );
    $tx->req->headers->accept_language($accept_language);

    $t->app->hook(
        after_dispatch => sub {
            $stash        = shift->stash;
            $interface    = C4::Context->interface;
            $userenv      = C4::Context->userenv;
            $language_env = $ENV{HTTP_ACCEPT_LANGUAGE};
        }
    );

    # With access token and permissions, it returns 200
    #$patron->flags(2**4)->store;
    $t->request_ok($tx)->status_is(200);

    my $user = $stash->{'koha.user'};
    ok( defined $user, 'The \'koha.user\' object is defined in the stash' )
        and is( ref($user),            'Koha::Patron',          'Stashed koha.user object type is Koha::Patron' )
        and is( $user->borrowernumber, $patron->borrowernumber, 'The stashed user is the right one' );
    is( $userenv->{number}, $patron->borrowernumber, 'userenv set correctly' );
    is( $interface,         'api',                   "Interface correctly set to \'api\'" );
    is( $language_env,      $accept_language,        'HTTP_ACCEPT_LANGUAGE correctly set in %ENV' );

    my $embed = $stash->{'koha.embed'};
    ok( defined $embed, 'The embed hashref is generated and stashed' );
    is_deeply( $embed, { fund => {} }, 'The embed data structure is correct' );

    $schema->storage->txn_rollback;
};

subtest 'cookie-based tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session( { authorized => 1 } );

    my $stash;
    my $interface;
    my $userenv;
    my $language_env;

    my $accept_language = 'es-ES,es;q=0.9,en-US;q=0.8,en;q=0.7';

    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );
    $tx->req->headers->accept_language($accept_language);

    $t->app->hook(
        after_dispatch => sub {
            $stash        = shift->stash;
            $interface    = C4::Context->interface;
            $userenv      = C4::Context->userenv;
            $language_env = $ENV{HTTP_ACCEPT_LANGUAGE};

        }
    );

    $t->request_ok($tx)->status_is(200);

    my $user = $stash->{'koha.user'};
    ok( defined $user, 'The \'koha.user\' object is defined in the stash' )
        and is( ref($user),            'Koha::Patron',  'Stashed koha.user object type is Koha::Patron' )
        and is( $user->borrowernumber, $borrowernumber, 'The stashed user is the right one' );
    is( $userenv->{number}, $borrowernumber,  'userenv set correctly' );
    is( $interface,         'api',            "Interface correctly set to \'api\'" );
    is( $language_env,      $accept_language, 'HTTP_ACCEPT_LANGUAGE correctly set in %ENV' );

    subtest 'logged-out tests' => sub {
        plan tests => 3;

        # Generate an anonymous session
        my $session = C4::Auth::get_session('');
        $session->param( 'ip',          $remote_address );
        $session->param( 'lasttime',    time() );
        $session->param( 'sessiontype', 'anon' );
        $session->flush;

        my $tx = $t->ua->build_tx( GET => '/api/v1/libraries' );
        $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
        $tx->req->env( { REMOTE_ADDR => $remote_address } );

        $t->request_ok($tx)->status_is( 401, 'Anonymous session on permission protected resource returns 401' )
            ->json_is( { error => 'Authentication failure.' } );
    };

    $schema->storage->txn_rollback;
};

subtest 'anonymous requests to public API' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

    my $password = 'AbcdEFG123';
    my $userid   = 'tomasito';

    # Add a patron
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    $patron->set_password( { password => $password } );

    # Add a biblio
    my $biblio_id = $builder->build_sample_biblio()->biblionumber;

    # Enable the public API
    t::lib::Mocks::mock_preference( 'RESTPublicAPI', 1 );

    # Disable anonymous requests on the public namespace
    t::lib::Mocks::mock_preference( 'RESTPublicAnonymousRequests', 0 );

    $t->get_ok( "/api/v1/public/biblios/" . $biblio_id => { Accept => 'application/marc' } )
        ->status_is( 401, 'Unauthorized anonymous attempt to access a resource' );

    # Disable anonymous requests on the public namespace
    t::lib::Mocks::mock_preference( 'RESTPublicAnonymousRequests', 1 );

    $t->get_ok( "/api/v1/public/biblios/" . $biblio_id => { Accept => 'application/marc' } )
        ->status_is( 200, 'Successfull anonymous access to a resource' );

    $schema->storage->txn_rollback;
};

subtest 'x-koha-library tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $stash;
    my $userenv;

    $t->app->hook(
        after_dispatch => sub {
            $stash   = shift->stash;
            $userenv = C4::Context->userenv;
        }
    );

    t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
    my $superlibrarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $superlibrarian->set_password( { password => $password, skip_validation => 1 } );
    my $superlibrarian_userid = $superlibrarian->userid;

    my $unprivileged = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => undef }
        }
    );
    $unprivileged->set_password( { password => $password, skip_validation => 1 } );
    my $unprivileged_userid = $unprivileged->userid;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    ## Independent branches tests
    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );

    $t->get_ok(
        "//$unprivileged_userid:$password@/api/v1/cities",
        { 'x-koha-library' => $unprivileged->branchcode }
    );

    is( $userenv->{branch}, $unprivileged->branchcode, 'branch set correctly' );

    $t->get_ok( "//$unprivileged_userid:$password@/api/v1/cities" => { 'x-koha-library' => $library->id } )
        ->status_is(403)->json_is( '/error' => 'Unauthorized attempt to set library to ' . $library->id );

    $t->get_ok( "//$superlibrarian_userid:$password@/api/v1/cities" => { 'x-koha-library' => $library->id } )
        ->status_is(200);

    is( $userenv->{branch}, $library->id, 'branch set correctly' );

    ## !Independent branches tests
    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );
    $t->get_ok(
        "//$unprivileged_userid:$password@/api/v1/cities",
        { 'x-koha-library' => $unprivileged->branchcode }
    );
    $t->get_ok(
        "//$unprivileged_userid:$password@/api/v1/cities",
        { 'x-koha-library' => $library->id }
    );

    $schema->storage->txn_rollback;
};

subtest 'x-koha-override stash tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 1 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $patron->userid;

    my $item = $builder->build_sample_item();

    my $hold_data = {
        patron_id         => $patron->id,
        biblio_id         => $item->biblionumber,
        item_id           => $item->id,
        pickup_library_id => $patron->branchcode,
    };

    my $stash;

    $t->app->hook(
        after_dispatch => sub {
            $stash = shift->stash;
        }
    );

    $t->post_ok( "//$userid:$password@/api/v1/holds" => { 'x-koha-override' => "any" } => json => $hold_data );

    my $overrides = $stash->{'koha.overrides'};
    is( ref($overrides), 'HASH', 'arrayref returned' );
    ok( $overrides->{'any'}, "The value 'any' is found" );

    $schema->storage->txn_rollback;
};

subtest 'public routes have "is_public" info stashed' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $stash;
    $t->app->hook(
        after_dispatch => sub {
            $stash = shift->stash;
        }
    );

    $t->get_ok('/api/v1/public/biblios/1');

    my $is_public = $stash->{is_public};

    ok( $is_public, 'Correctly stashed the fact it is a public route' );

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? 16 : 0;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => { flags => $flags }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $user->{borrowernumber} );
    $session->param( 'id',       $user->{userid} );
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    return ( $user->{borrowernumber}, $session->id );
}
