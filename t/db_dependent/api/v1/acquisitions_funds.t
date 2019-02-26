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

use C4::Budgets;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

my $librarian = $builder->build_object({
    class => 'Koha::Patrons',
    value => { flags => 2052 }
});
my $password = 'thePassword123';
$librarian->set_password({ password => $password, skip_validation => 1 });
my $userid = $librarian->userid;

my $patron = $builder->build_object({
    class => 'Koha::Patrons',
    value => { flags => 0 }
});
my $unauth_password = 'thePassword123';
$patron->set_password({ password => $unauth_password, skip_validation => 1 });
my $unauth_userid = $patron->userid;

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

$t->get_ok("//$unauth_userid:$unauth_password@/api/v1/acquisitions/funds")
  ->status_is(403);

$t->get_ok("//$unauth_userid:$unauth_password@/api/v1/acquisitions/funds/?name=" . $fund1->{ budget_name })
  ->status_is(403);

$t->get_ok("//$userid:$password@/api/v1/acquisitions/funds")
  ->status_is(200);

$t->get_ok("//$userid:$password@/api/v1/acquisitions/funds/?name=" . $fund1->{ budget_name })
  ->status_is(200)
  ->json_like('/0/name' => qr/$fund1->{ budget_name }/);

$schema->storage->txn_rollback;

1;
