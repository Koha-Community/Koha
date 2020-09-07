#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 6;

use Koha::Database;
use Koha::Patron::HouseboundRoles;
use Koha::Patrons;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

# Profile Tests

my $role = $builder->build({ source => 'HouseboundRole' });

is(
    Koha::Patron::HouseboundRoles
          ->find($role->{borrowernumber_id})->borrowernumber_id,
    $role->{borrowernumber_id},
    "Find created role."
);

my @roles = Koha::Patron::HouseboundRoles
    ->search({ borrowernumber_id => $role->{borrowernumber_id} });
my $found_role = shift @roles;
is(
    $found_role->borrowernumber_id,
    $role->{borrowernumber_id},
    "Search for created role."
);

# patron_choosers and patron_deliverers Tests

# Current Patron Chooser / Deliverer count
my $orig_del_count = Koha::Patrons->search_housebound_deliverers->count;
my $orig_cho_count = Koha::Patrons->search_housebound_choosers->count;

# We add one, just in case the above is 0, so we're guaranteed one of each.
my $patron_chooser = $builder->build({ source => 'Borrower' });
$builder->build({
    source => 'HouseboundRole',
    value  => {
        borrowernumber_id  => $patron_chooser->{borrowernumber},
        housebound_chooser   => 1,
        housebound_deliverer => 0,
    },
});

my $patron_deliverer = $builder->build({ source => 'Borrower' });
$builder->build({
    source => 'HouseboundRole',
    value  => {
        borrowernumber_id    => $patron_deliverer->{borrowernumber},
        housebound_deliverer => 1,
        housebound_chooser   => 0,
    },
});

# Test search_housebound_choosers
is(Koha::Patrons->search_housebound_choosers->count, $orig_cho_count + 1, "Correct count of choosers.");
is(Koha::Patrons->search_housebound_deliverers->count, $orig_del_count + 1, "Correct count of deliverers");

isa_ok(Koha::Patrons->search_housebound_choosers->next, "Koha::Patron");
isa_ok(Koha::Patrons->search_housebound_deliverers->next, "Koha::Patron");


$schema->storage->txn_rollback;

