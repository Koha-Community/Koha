#!/usr/bin/env perl

# Copyright 2017 Koha-Suomi Oy
#
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

use Test::More tests => 3;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Patrons;

use Mojolicious::Lite;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );
my $mock = create_test_endpoint();

my $remote_address = '127.0.0.1';
my $t              = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my ($patron, $session) = create_user_and_session(0);
my ($guarantor, $session2) = create_user_and_session(0);
Koha::Patrons->find($patron->{borrowernumber})
             ->guarantorid($guarantor->{borrowernumber})
             ->store;
my ($librarian, $lib_session) = create_user_and_session(16);

subtest 'without permission, owner of object tests' => sub {
    plan tests => 3;

    my $borrowernumber = $patron->{borrowernumber};
    my $tx = $t->ua->build_tx(GET => "/api/v1/patrons/$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(418)
      ->json_is('/error', 'is_owner_access');
};


subtest 'without permissions, guarantor of the owner of the object tests' => sub {
    plan tests => 3;

    my $borrowernumber = $patron->{borrowernumber};
    my $tx = $t->ua->build_tx(GET => "/api/v1/patrons/$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session2->id});
    $t->request_ok($tx)
      ->status_is(418)
      ->json_is('/error', 'is_guarantor_access');
};

subtest 'with permissions tests' => sub {
    plan tests => 3;

    my $borrowernumber = $librarian->{borrowernumber};
    my $tx = $t->ua->build_tx(GET => "/api/v1/patrons/$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $lib_session->id});
    $t->request_ok($tx)
      ->status_is(418)
      ->json_is('/error', 'librarian_access');
};

$schema->storage->txn_rollback;

sub create_test_endpoint {
    # Mock Koha::REST::V1::Patron::get to read stash for owner access
    my $mock = Test::MockModule->new('Koha::REST::V1::Patron');
    $mock->mock(get => sub {
        my $c = shift;
        if ($c->stash('is_owner_access')) {
            return $c->render( status => 418,
                               json => { error => "is_owner_access" });
        } elsif ($c->stash('is_guarantor_access')) {
            return $c->render( status => 418,
                               json => { error => "is_guarantor_access" });
        }
        return $c->render( status => 418,
                           json => { error => "librarian_access" });
    });
    return $mock;
}

sub create_user_and_session {
    my ($flags) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
    my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
    my $patron = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            flags        => $flags,
            lost         => 0,
        }
    });
    my $session = C4::Auth::get_session('');
    $session->param('number', $patron->{ borrowernumber });
    $session->param('id', $patron->{ userid });
    $session->param('ip', '127.0.0.1');
    $session->param('lasttime', time());
    $session->flush;

    return ($patron, $session);
}
