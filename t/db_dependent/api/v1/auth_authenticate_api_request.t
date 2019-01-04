#!/usr/bin/env perl

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

use Test::More tests => 2;
use Test::Mojo;

use Module::Load::Conditional qw(can_load);

use Koha::ApiKeys;
use Koha::Database;
use Koha::Patrons;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $t = Test::Mojo->new('Koha::REST::V1');
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
        plan tests => 10;
    }
    else {
        plan skip_all => 'Net::OAuth2::AuthorizationServer not available';
    }

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value  => {
            flags => 16 # no permissions
        },
    });

    t::lib::Mocks::mock_preference('RESTOAuth2ClientCredentials', 1);

    my $api_key = Koha::ApiKey->new({ patron_id => $patron->id, description => 'blah' })->store;

    my $formData = {
        grant_type    => 'client_credentials',
        client_id     => $api_key->client_id,
        client_secret => $api_key->secret
    };
    $t->post_ok('/api/v1/oauth/token', form => $formData)
        ->status_is(200)
        ->json_is('/expires_in' => 3600)
        ->json_is('/token_type' => 'Bearer')
        ->json_has('/access_token');

    my $access_token = $t->tx->res->json->{access_token};

    # With access token and permissions, it returns 200
    #$patron->flags(2**4)->store;

    my $stash;

    my $tx = $t->ua->build_tx(GET => '/api/v1/patrons');
    $tx->req->headers->authorization("Bearer $access_token");

    $t->app->hook(after_dispatch => sub { $stash = shift->stash });
    $t->request_ok($tx)->status_is(200);

    my $user = $stash->{'koha.user'};
    ok( defined $user, 'The \'koha.user\' object is defined in the stash') and
    is( ref($user), 'Koha::Patron', 'Stashed koha.user object type is Koha::Patron') and
    is( $user->borrowernumber, $patron->borrowernumber, 'The stashed user is the right one' );

    $schema->storage->txn_rollback;
};

subtest 'cookie-based tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my ( $borrowernumber, $session_id ) = create_user_and_session({ authorized => 1 });

    $tx = $t->ua->build_tx( GET => "/api/v1/patrons" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => $remote_address } );

    my $stash;
    $t->app->hook(after_dispatch => sub { $stash = shift->stash });
    $t->request_ok($tx)->status_is(200);

    my $user = $stash->{'koha.user'};
    ok( defined $user, 'The \'koha.user\' object is defined in the stash') and
    is( ref($user), 'Koha::Patron', 'Stashed koha.user object type is Koha::Patron') and
    is( $user->borrowernumber, $borrowernumber, 'The stashed user is the right one' );

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? 16 : 0;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags
            }
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
