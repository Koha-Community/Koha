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

use C4::Accounts qw(manualinvoice);
use C4::Auth;
use Koha::Account::Line;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'get_balance() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my ( $patron_id, $session_id ) = create_user_and_session({ authorized => 0 });
    my $patron  = Koha::Patrons->find($patron_id);
    my $account = $patron->account;

    my $tx = $t->ua->build_tx(GET => "/api/v1/patrons/$patron_id/account");
    $tx->req->cookies({ name => 'CGISESSID', value => $session_id });
    $tx->req->env({ REMOTE_ADDR => '127.0.0.1' });
    $t->request_ok($tx)->status_is(200)->json_is(
        {   balance             => 0.00,
            outstanding_debits  => { total => 0, lines => [] },
            outstanding_credits => { total => 0, lines => [] }
        }
    );

    my $account_line_1 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            date              => \'NOW()',
            amount            => 50,
            description       => "A description",
            accounttype       => "N", # New card
            amountoutstanding => 50,
            manager_id        => $patron->borrowernumber,
        }
    )->store();
    $account_line_1->discard_changes;

    my $account_line_2 = Koha::Account::Line->new(
        {
            borrowernumber    => $patron->borrowernumber,
            date              => \'NOW()',
            amount            => 50.01,
            description       => "A description",
            accounttype       => "N", # New card
            amountoutstanding => 50.01,
            manager_id        => $patron->borrowernumber,
        }
    )->store();
    $account_line_2->discard_changes;

    $tx = $t->ua->build_tx( GET => "/api/v1/patrons/$patron_id/account" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_is(
        {   balance            => 100.01,
            outstanding_debits => {
                total => 100.01,
                lines => [
                    Koha::REST::V1::Patrons::Account::_to_api( $account_line_1->TO_JSON ),
                    Koha::REST::V1::Patrons::Account::_to_api( $account_line_2->TO_JSON )
                ]
            },
            outstanding_credits => {
                total => 0,
                lines => []
            }
        }
    );

    $account->pay(
        {   amount       => 100.01,
            note         => 'He paid!',
            description  => 'Finally!',
            library_id   => $patron->branchcode,
            account_type => 'Pay',
            offset_type  => 'Payment'
        }
    );

    $tx = $t->ua->build_tx( GET => "/api/v1/patrons/$patron_id/account" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_is(
        {   balance             => 0,
            outstanding_debits  => { total => 0, lines => [] },
            outstanding_credits => { total => 0, lines => [] }
        }
    );

    # add a credit
    my $credit_line = $account->add_credit({ amount => 10, user_id => $patron->id });
    # re-read from the DB
    $credit_line->discard_changes;
    $tx = $t->ua->build_tx( GET => "/api/v1/patrons/$patron_id/account" );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_is(
        {   balance            => -10,
            outstanding_debits => {
                total => 0,
                lines => []
            },
            outstanding_credits => {
                total => -10,
                lines => [ Koha::REST::V1::Patrons::Account::_to_api( $credit_line->TO_JSON ) ]
            }
        }
    );

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? 16 : 0;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags,
                gonenoaddress => 0,
                lost => 0,
                email => 'nobody@example.com',
                emailpro => 'nobody@example.com',
                B_email => 'nobody@example.com'
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
