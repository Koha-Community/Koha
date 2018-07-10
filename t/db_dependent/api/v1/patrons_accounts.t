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

use Test::More tests => 2;

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

    my ( $patron, $session_id ) = create_user_and_session({ authorized => 0 });
    my $patron_id  = $patron->id;
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

subtest 'add_credit() tests' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my ( $patron, $session_id ) = create_user_and_session( { authorized => 1 } );
    my $patron_id = $patron->id;
    my $account   = $patron->account;

    is( $account->outstanding_debits->count,  0, 'No outstanding debits for patron' );
    is( $account->outstanding_credits->count, 0, 'No outstanding credits for patron' );

    my $credit = { amount => 100 };

    my $tx = $t->ua->build_tx(
        POST => "/api/v1/patrons/$patron_id/account/credits" => json => $credit );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_has('/account_line_id');

    my $outstanding_credits = $account->outstanding_credits;
    is( $outstanding_credits->count,             1 );
    is( $outstanding_credits->total_outstanding, -100 );

    my $debit_1 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->borrowernumber,
            date              => \'NOW()',
            amount            => 10,
            description       => "A description",
            accounttype       => "N",                       # New card
            amountoutstanding => 10,
            manager_id        => $patron->borrowernumber,
        }
    )->store();
    my $debit_2 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->borrowernumber,
            date              => \'NOW()',
            amount            => 15,
            description       => "A description",
            accounttype       => "N",                       # New card
            amountoutstanding => 15,
            manager_id        => $patron->borrowernumber,
        }
    )->store();

    is( $account->outstanding_debits->total_outstanding, 25 );
    $tx = $t->ua->build_tx(
        POST => "/api/v1/patrons/$patron_id/account/credits" => json => $credit );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_has('/account_line_id');

    is( $account->outstanding_debits->total_outstanding,
        0, "Debits have been cancelled automatically" );

    my $debit_3 = Koha::Account::Line->new(
        {   borrowernumber    => $patron->borrowernumber,
            date              => \'NOW()',
            amount            => 100,
            description       => "A description",
            accounttype       => "N",                       # New card
            amountoutstanding => 100,
            manager_id        => $patron->borrowernumber,
        }
    )->store();

    $credit = {
        amount            => 35,
        account_lines_ids => [ $debit_1->id, $debit_2->id, $debit_3->id ]
    };

    $tx = $t->ua->build_tx(
        POST => "/api/v1/patrons/$patron_id/account/credits" => json => $credit );
    $tx->req->cookies( { name => 'CGISESSID', value => $session_id } );
    $tx->req->env( { REMOTE_ADDR => '127.0.0.1' } );
    $t->request_ok($tx)->status_is(200)->json_has('/account_line_id');

    my $outstanding_debits = $account->outstanding_debits;
    is( $outstanding_debits->total_outstanding, 65 );
    is( $outstanding_debits->count,             1 );

    $schema->storage->txn_rollback;
};

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? 2**10 : 0;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value  => {
                flags         => $flags
            }
        }
    );

    # Create a session for the authorized user
    my $session = C4::Auth::get_session('');
    $session->param( 'number',   $patron->id );
    $session->param( 'id',       $patron->userid );
    $session->param( 'ip',       '127.0.0.1' );
    $session->param( 'lasttime', time() );
    $session->flush;

    return ( $patron, $session->id );
}
