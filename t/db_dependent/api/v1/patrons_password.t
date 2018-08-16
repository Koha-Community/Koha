#!/usr/bin/perl

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

use Test::More tests => 1;

use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Patrons;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'set() (authorized user tests)' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my ( $patron, $session ) = create_user_and_session({ authorized => 1 });

    t::lib::Mocks::mock_preference( 'minPasswordLength',     3 );
    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 0 );

    my $new_password = 'abc';

    my $tx
        = $t->ua->build_tx( POST => "/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } );

    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_is( '' );

    $tx
        = $t->ua->build_tx( POST => "/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => 'cde' } );

    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(400)->json_is({ error => 'Passwords don\'t match' });

    t::lib::Mocks::mock_preference( 'minPasswordLength', 5 );
    $tx
        = $t->ua->build_tx( POST => "/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } );

    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(400)->json_is({ error => 'Password length (3) is shorter than required (5)' });

    $new_password = 'abc   ';
    $tx
        = $t->ua->build_tx( POST => "/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } );

    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(400)->json_is({ error => 'Password contains trailing spaces, which is forbidden.' });

    $new_password = 'abcdefg';
    $tx
        = $t->ua->build_tx( POST => "/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } );

    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_is('');

    t::lib::Mocks::mock_preference( 'RequireStrongPassword', 1);
    $tx
        = $t->ua->build_tx( POST => "/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } );

    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(400)->json_is({ error => 'Password is too weak' });

    $new_password = 'ABcde123%&';
    $tx
        = $t->ua->build_tx( POST => "/api/v1/patrons/"
            . $patron->id
            . "/password" => json => { password => $new_password, password_2 => $new_password } );

    $tx->req->cookies( { name => 'CGISESSID', value => $session->id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_is('');

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my ( $args ) = @_;
    my $flags = ( $args->{authorized} ) ? 16 : 0;

    my $user = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => $flags }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $user->borrowernumber );
    $session->param( 'id',       $user->userid );
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    return ( $user, $session );
}
