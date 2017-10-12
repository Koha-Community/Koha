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

use Test::More tests => 14;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use C4::Context;
use C4::Budgets;

use Koha::Database;
use Koha::Patron;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

my $fund1 = {
    budget_code      => 'ABCD',
    budget_amount    => '123.132000',
    budget_name      => 'Periodiques',
    budget_notes     => 'This is a note',
};
my $budget_id = AddBudget($fund1);
isnt( $budget_id, undef, 'AddBudget does not returns undef' );

$t->get_ok('/api/v1/acquisitions/funds')
  ->status_is(401);

$t->get_ok('/api/v1/acquisitions/funds/?name=testFund')
  ->status_is(401);

my ( $borrowernumber, $session_id )
        #= create_user_and_session( { authorized => 1 } );
        = create_user_and_session(  );

my $tx = $t->ua->build_tx(GET => '/api/v1/acquisitions/funds');
$tx->req->cookies({name => 'CGISESSID', value => $session_id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(403);

$tx = $t->ua->build_tx(GET => "/api/v1/acquisitions/funds/?name=" . $fund1->{ budget_name });
$tx->req->cookies({name => 'CGISESSID', value => $session_id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(403);

( $borrowernumber, $session_id )
        = create_user_and_session( { authorized => 1 } );

$tx = $t->ua->build_tx(GET => '/api/v1/acquisitions/funds');
$tx->req->cookies({name => 'CGISESSID', value => $session_id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);

$tx = $t->ua->build_tx(GET => "/api/v1/acquisitions/funds/?name=" . $fund1->{ budget_name });
$tx->req->cookies({name => 'CGISESSID', value => $session_id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200)
  ->json_like('/0/name' => qr/$fund1->{ budget_name }/);

$schema->storage->txn_rollback;

sub create_user_and_session {

    my $args = shift;
    my $flags = ( $args->{authorized} ) ? 2052 : 0;

    # my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh = C4::Context->dbh;

    my $user = $builder->build(
        {   source => 'Borrower',
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

    if ( $args->{authorized} ) {
        $dbh->do(
            q{
            INSERT INTO user_permissions (borrowernumber,module_bit,code)
            VALUES (?,11,'budget_manage_all')},
            undef, $user->{borrowernumber}
        );
    }

    return ( $user->{borrowernumber}, $session->id );
}
