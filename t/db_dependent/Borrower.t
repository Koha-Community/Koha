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

use Test::More tests => 12;
use Test::Warn;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Borrower');
}

# Start transaction
my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my $categorycode = Koha::Database->new()->schema()->resultset('Category')->first()->categorycode();
my $branchcode = Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

my $object = Koha::Borrower->new();

is( $object->in_storage, 0, "Object is not in storage" );

$object->categorycode( $categorycode );
$object->branchcode( $branchcode );
$object->surname("Test Surname");
$object->store();

my $borrower = Koha::Database->new()->schema()->resultset('Borrower')->find( $object->borrowernumber() );
is( $borrower->surname(), "Test Surname", "Object found in database" );

is( $object->in_storage, 1, "Object is now stored" );

is( $object->is_changed(), 0, "Object is unchanged" );
$object->surname("Test Surname 2");
is( $object->is_changed(), 1, "Object is changed" );

$object->store();
is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

$object->set({ firstname => 'Test Firstname' });
is( $object->is_changed(), 1, "Object is changed after Set" );
$object->store();
is( $object->is_changed(), 0, "Object no longer marked as changed after being stored" );

$object->delete();
$borrower = Koha::Database->new()->schema()->resultset('Borrower')->find( $object->borrowernumber() );
ok( ! $borrower, "Object no longer found in database" );
is( $object->in_storage, 0, "Object is not in storage" );

1;
