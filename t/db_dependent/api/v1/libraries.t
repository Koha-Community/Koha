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

use t::lib::TestBuilder;

use Test::More tests => 11;
use Test::Mojo;

use C4::Auth;
use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Libraries');
}

my $schema  = Koha::Database->schema;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my $branch = $builder->build({ source => 'Branch' });

my $tx = $t->ua->build_tx(GET => '/api/v1/libraries');
#$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);

$tx = $t->ua->build_tx(GET => "/api/v1/libraries/" . $branch->{ branchcode });
#$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/branchcode' => $branch->{ branchcode })
  ->json_is('/branchname' => $branch->{ branchname });

$tx = $t->ua->build_tx(GET => "/api/v1/libraries/" . "nonexistent");
$t->request_ok($tx)
  ->status_is(404)
  ->json_is('/error' => "Library with branchcode \"nonexistent\" not found");

$schema->storage->txn_rollback;
