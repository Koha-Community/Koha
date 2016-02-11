#!/usr/bin/perl

# Copyright 2016 ByWater Solutions
#
# This file is part of Koha
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
use Koha::SMS::Provider;
use Koha::SMS::Providers;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $count = Koha::SMS::Providers->search->count;

my $builder = t::lib::TestBuilder->new;
my $provider1 =
  Koha::SMS::Provider->new( { name => 'Test 1', domain => 'test1.com' } )
  ->store();
my $provider2 =
  Koha::SMS::Provider->new( { name => 'Test 2', domain => 'test2.com' } )
  ->store();

my $patron1 = $builder->build(
    {
        source => 'Borrower',
        value  => { sms_provider_id => $provider1->id, }
    }
);

my $patron2 = $builder->build(
    {
        source => 'Borrower',
        value  => { sms_provider_id => $provider1->id, }
    }
);

like( $provider1->id, qr|^\d+$|,
    'Adding a new provider should have set the id' );
is( Koha::SMS::Providers->search->count,
    $count + 2, 'The 2 providers should have been added' );

is ( $provider1->patrons_using(), 2, 'Found the correct number of patrons using provider' );
is ( $provider2->patrons_using(), 0, 'Found the correct number of patrons using unused provider' );

my $provider = Koha::SMS::Providers->find( $provider1->id );
is( $provider->name, $provider1->name,
    'Find a provider by id should return the correct provider' );

$provider1->delete;
is( Koha::SMS::Providers->search->count,
    $count + 1, 'Delete should have deleted the provider' );

$schema->storage->txn_rollback;

1;
