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

use Test::More tests => 8;

use Koha::Database;
use Koha::Patron::HouseboundVisits;
use Koha::Patron::HouseboundVisit;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

########### Test HouseboundVisits

my $visit = $builder->build({ source => 'HouseboundVisit' });

is(
    Koha::Patron::HouseboundVisits
          ->find($visit->{id})->id,
    $visit->{id},
    "Find created visit."
);

# Using our Prefetching search

# Does it work implicitly?
my @visits = Koha::Patron::HouseboundVisits
    ->special_search({ borrowernumber => $visit->{borrowernumber} });
my $found_visit = shift @visits;
is(
    $found_visit->borrowernumber,
    $visit->{borrowernumber},
    "Search for created visit."
);

# Does it work Explicitly?
@visits = Koha::Patron::HouseboundVisits
    ->special_search({ 'me.borrowernumber' => $visit->{borrowernumber} });
$found_visit = shift @visits;
is(
    $found_visit->borrowernumber,
    $visit->{borrowernumber},
    "Search for created visit."
);

# Does it work without prefetcing?
@visits = Koha::Patron::HouseboundVisits
    ->special_search({ borrowernumber => $visit->{borrowernumber} }, { prefetch => [] });
$found_visit = shift @visits;
is(
    $found_visit->borrowernumber,
    $visit->{borrowernumber},
    "Search for created visit."
);

########### Test HouseboundVisit

my $result = Koha::Patron::HouseboundVisits->find($visit->{id});

is( $result->deliverer->borrowernumber, $visit->{deliverer_brwnumber} );

is( $result->chooser->borrowernumber, $visit->{chooser_brwnumber} );

TODO: {
    local $TODO = "We want our results here to be Koha::Patron objects, but they by default return DBIC Schema objects.  The currently accepted solution to this (use the _from_dbic method), is defined for Koha::Objects, but not for Koha::Object.  We do not resolve this issue here";
    isa_ok( $result->deliverer, "Koha::Patron");
    isa_ok( $result->chooser, "Koha::Patron");
}

$schema->storage->txn_rollback;

1;
