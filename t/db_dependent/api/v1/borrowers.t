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

use Test::More tests => 1;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::AuthUtils;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

subtest '/borrowers/status get() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $password = '1234';
    my $hashed_password = Koha::AuthUtils::hash_password($password);
    my $user = $builder->build({
        source => 'Borrower',
        value => {
            cardnumber => '11A01',
            password => $hashed_password,
            lost     => 0,
        }
    });
    my $b = Koha::Patrons->find($user->{borrowernumber});

    my $tx = $t->ua->build_tx( GET => '/api/v1/borrowers/status' );
    $tx->req->body( Mojo::Parameters->new("uname=".$b->cardnumber."&passwd=4321")->to_string);
    $tx->req->headers->remove('Content-Type');
    $tx->req->headers->add('Content-Type' => 'application/x-www-form-urlencoded');
    $t->request_ok($tx)
      ->status_is(400)
      ->json_like('/error' => qr/password/ );

    $tx = $t->ua->build_tx( GET => '/api/v1/borrowers/status' );
    $tx->req->body( Mojo::Parameters->new("uname=".$b->cardnumber."&passwd=1234")->to_string);
    $tx->req->headers->remove('Content-Type');
    $tx->req->headers->add('Content-Type' => 'application/x-www-form-urlencoded');
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/cardnumber' => $b->cardnumber );

    $schema->storage->txn_rollback;
};

1;
