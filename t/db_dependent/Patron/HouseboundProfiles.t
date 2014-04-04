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

use Test::More tests => 3;

use Koha::Database;
use Koha::Patron::HouseboundProfiles;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

# Profile Tests

my $profile = $builder->build({ source => 'HouseboundProfile' });

is(
    Koha::Patron::HouseboundProfiles
          ->find($profile->{borrowernumber})->borrowernumber,
    $profile->{borrowernumber},
    "Find created profile."
);

my @profiles = Koha::Patron::HouseboundProfiles
    ->search({ day => $profile->{day} });
my $found_profile = shift @profiles;
is(
    $found_profile->borrowernumber,
    $profile->{borrowernumber},
    "Search for created profile."
);

# ->housebound_profile Tests

my $visit1 = $builder->build({
    source => 'HouseboundVisit',
    value  => {
        borrowernumber => $profile->{borrowernumber},
    },
});
my $visit2 = $builder->build({
    source => 'HouseboundVisit',
    value  => {
        borrowernumber => $profile->{borrowernumber},
    },
});

is(
    scalar @{$found_profile->housebound_visits},
    2,
    "Fetch housebound_visits."
);

$schema->storage->txn_rollback;

1;
