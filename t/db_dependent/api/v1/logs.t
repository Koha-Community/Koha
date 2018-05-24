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

use Test::More tests => 8;
use Test::Mojo;
use Test::Warn;

use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use Koha::Cities;
use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');


$schema->storage->txn_begin;

my $log = {
    module    => "Module",
    action   => "Action",
    object => "1234",
    info => "Info"
};

my ( $borrowernumber, $session_id ) =
    create_user_and_session( { authorized => 1 } );

my $tx = $t->ua->build_tx( POST => "/api/v1/logs/" => json => $log );
$tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
$tx->req->env( { REMOTE_ADDR => $remote_address } );
$t->request_ok($tx)->status_is(200);

$tx = $t->ua->build_tx( GET => "/api/v1/logs/" => json => $log );
$tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
$tx->req->env( { REMOTE_ADDR => $remote_address } );
$t->request_ok($tx)->status_is(200);

my $log2 = {
    module    => "Module2",
    action   => "Action2",
    object => "1234",
    info => "Info2"
};

my ( $borrowernumber2, $session_id2 ) =
    create_user_and_session( { authorized => 0 } );

$tx = $t->ua->build_tx( POST => "/api/v1/logs/" => json => $log2 );
$tx->req->cookies( { name => 'CGISESSID', value => $session_id2 } );
$tx->req->env( { REMOTE_ADDR => $remote_address } );
$t->request_ok($tx)->status_is(403);

$tx = $t->ua->build_tx( GET => "/api/v1/logs/" => json => $log2 );
$tx->req->cookies( { name => 'CGISESSID', value => $session_id2 } );
$tx->req->env( { REMOTE_ADDR => $remote_address } );
$t->request_ok($tx)->status_is(403);


$schema->storage->txn_rollback;

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh   = C4::Context->dbh;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags,
                lost  => 0,
            }
        }
    );

    # Create a session for the authorized user
    my $session = t::lib::Mocks::mock_session({borrower => $user});

    if ( $args->{authorized} ) {
        my $patron = Koha::Patrons->find($user->{borrowernumber});
        Koha::Auth::PermissionManager->grantPermission($patron, 'auth',
                                        'get_session');
    }

    return ( $user->{borrowernumber}, $session->id );
}