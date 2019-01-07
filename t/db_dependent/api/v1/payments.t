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
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Account::Line;
use Koha::PaymentsTransaction;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest 'get() tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my ($borrowernumber, $sessionid) = create_user_and_session();

    # Create accountline
    Koha::Account::Line->new({
        borrowernumber    => $borrowernumber,
        accounttype       => 'FU',
        amountoutstanding => 10
    })->store;

    # Create payment_transaction.
    my $payment = Koha::PaymentsTransaction->new()->set({
        borrowernumber      => $borrowernumber,
        status              => "unsent",
        description         => '',
    })->store();
    my $transaction_id = $payment->transaction_id;

    # Test transaction without permissions.
    my $tx = $t->ua->build_tx(GET => "/api/v1/payments/transaction/$transaction_id");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    Koha::Auth::PermissionManager->grantAllSubpermissions(
        $borrowernumber, 'updatecharges'
    );

    # Test transaction.
    $tx = $t->ua->build_tx(GET => "/api/v1/payments/transaction/$transaction_id");
    $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'post() tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my ($borrowernumber, $sessionid) = create_user_and_session();
    my $patron = Koha::Patrons->find($borrowernumber);

    # Enable payment interfaces
    t::lib::Mocks::mock_preference('POSIntegration', 'Default:
  POSInterface: CPU
  Default: 123');
    t::lib::Mocks::mock_preference('OnlinePayments', 'Default:
  OnlinePaymentsInterface: CPU
  Default: 123');
    my $secretKey = '1234';
    my $config = {
        CPU => {
            secretKey => $secretKey,
        }
    };
    t::lib::Mocks::mock_config('pos', $config);
    t::lib::Mocks::mock_config('online_payments', $config);

    subtest 'pos tests' => sub {
        plan tests => 6;

        # Create accountline
        Koha::Account::Line->new({
            borrowernumber    => $borrowernumber,
            accounttype       => 'FU',
            amountoutstanding => 10
        })->store;

        # Create payment_transaction.
        my $payment = Koha::PaymentsTransaction->new({
            borrowernumber      => $borrowernumber,
            status              => "unsent",
            description         => '',
            user_branch         => $patron->branchcode,
        })->store;
        my $transaction_id = $payment->transaction_id;

        my $post;
        $post->{Source} = "KOHA";
        $post->{Id} = "77747777777";
        $post->{Status} = 1;
        $post->{Reference} = "77747777777";

        # Calculate checksum
        my $data = $post->{Source}."&".$post->{Id}."&".$post->{Status}."&".$post->{Reference}."&".$secretKey;
        my $hash = Digest::SHA::sha256_hex($data);

        # Add checksum to POST parameters
        $post->{Hash} = $hash;

        # Payment tests
        my $tx = $t->ua->build_tx(POST => "/api/v1/payments/pos/cpu/77747777777/report" => json => $post);
        $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(404);

        $tx = $t->ua->build_tx(POST => "/api/v1/payments/pos/cpu/77747777777/report");
        $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(400);

        $post->{Id} = $payment->transaction_id;
        $post->{Reference} = $payment->transaction_id;

        # Calculate checksum for the response
        $data = $post->{Source}."&".$post->{Id}."&".$post->{Status}."&".$post->{Reference}."&".$secretKey;
        $hash = Digest::SHA::sha256_hex($data);

        # Add checksum to CPU response
        $post->{Hash} = $hash;

        $tx = $t->ua->build_tx(POST => "/api/v1/payments/pos/cpu/$transaction_id/report" => json => $post);
        $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(200);
    };

    subtest 'online payment tests' => sub {
        plan tests => 6;

        # Create accountline
        Koha::Account::Line->new({
            borrowernumber    => $borrowernumber,
            accounttype       => 'FU',
            amountoutstanding => 10
        })->store;

        # Create payment_transaction.
        my $payment = Koha::PaymentsTransaction->new({
            borrowernumber      => $borrowernumber,
            status              => "unsent",
            description         => '',
        })->store;
        my $transaction_id = $payment->transaction_id;

        my $post = {};
        $post->{Source} = "KOHA";
        $post->{Id} = "77747777777";
        $post->{Status} = 1;
        $post->{Reference} = "77747777777";

        # Calculate checksum
        my $data = $post->{Source}."&".$post->{Id}."&".$post->{Status}."&".$post->{Reference}."&".$secretKey;
        my $hash = Digest::SHA::sha256_hex($data);

        # Add checksum to POST parameters
        $post->{Hash} = $hash;

        # Payment tests
        my $tx = $t->ua->build_tx(POST => "/api/v1/payments/online/cpu/77747777777/report" => json => $post);
        $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(404);

        $tx = $t->ua->build_tx(POST => "/api/v1/payments/online/cpu/77747777777/report");
        $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(400);

        $post->{Id} = $payment->transaction_id;
        $post->{Reference} = $payment->transaction_id;

        # Calculate checksum for the response
        $data = $post->{Source}."&".$post->{Id}."&".$post->{Status}."&".$post->{Reference}."&".$secretKey;
        $hash = Digest::SHA::sha256_hex($data);

        # Add checksum to CPU response
        $post->{Hash} = $hash;

        $tx = $t->ua->build_tx(POST => "/api/v1/payments/online/cpu/$transaction_id/report" => json => $post);
        $tx->req->cookies({name => 'CGISESSID', value => $sessionid});
        $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
        $t->request_ok($tx)
          ->status_is(200);
    };

    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my ($flags) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

    my $borrower = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            flags        => $flags,
            lost         => 0,
        }
    });

    my $borrowersession = t::lib::Mocks::mock_session({borrower => $borrower});

    return ($borrower->{borrowernumber}, $borrowersession->id);
}
