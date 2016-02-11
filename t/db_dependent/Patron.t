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

use Test::More tests => 15;
use Test::Warn;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $categorycode = $schema->resultset('Category')->first()->categorycode();
my $branchcode = $schema->resultset('Branch')->first()->branchcode();

my $object = Koha::Patron->new();

is( $object->in_storage, 0, "Object is not in storage" );

$object->categorycode( $categorycode );
$object->branchcode( $branchcode );
$object->surname("Test Surname");
$object->store();

is( $object->in_storage, 1, "Object is now stored" );
my $guarantee1 = Koha::Patron->new(
    {
        categorycode => $categorycode,
        branchcode   => $branchcode,
        guarantorid  => $object->id
    }
)->store();
my $guarantee2 = Koha::Patron->new(
    {
        categorycode => $categorycode,
        branchcode   => $branchcode,
        guarantorid  => $object->id
    }
)->store();
my @guarantees = $object->guarantees();
is( $guarantees[0]->id, $guarantee1->id, "First guarantee matchs" );
is( $guarantees[1]->id, $guarantee2->id, "Second guarantee matchs" );

my $borrowernumber = $object->borrowernumber;

my $patron = $schema->resultset('Borrower')->find( $borrowernumber );
is( $patron->surname(), "Test Surname", "Object found in database" );

is( $object->is_changed(), 0, "Object is unchanged" );
$object->surname("Test Surname");
is( $object->is_changed(), 0, "Object is still unchanged" );
$object->surname("Test Surname 2");
is( $object->is_changed(), 1, "Object is changed" );

$object->store();
is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

$object->set({ firstname => 'Test Firstname' });
is( $object->is_changed(), 1, "Object is changed after Set" );
$object->store();
is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

$object->delete();
$patron = $schema->resultset('Borrower')->find( $borrowernumber );
ok( ! $patron, "Object no longer found in database" );
is( $object->in_storage, 0, "Object is not in storage" );

1;
