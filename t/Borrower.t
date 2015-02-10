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

use Test::More tests => 13;
use Test::Warn;

use Koha::Database;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Borrower');
}

my $object = Koha::Borrower->new( { surname => 'Test Borrower' } );

is( $object->surname(), 'Test Borrower', "Accessor returns correct value" );

$object->surname('Test Borrower Surname');
is( $object->surname(), 'Test Borrower Surname', "Accessor returns correct value after set" );

my $object2 = Koha::Borrower->new( { surname => 'Test Borrower 2' } );
is( $object2->surname(), 'Test Borrower 2', "Accessor returns correct value" );

$object2->surname('Test Borrower Surname 2');
is( $object2->surname(), 'Test Borrower Surname 2', "Accessor returns correct value after set" );

my $ret;
$ret = $object2->set({ surname => "Test Borrower Surname 3", firstname => "Test Firstname" });
ok( ref($ret) eq 'Koha::Borrower', "Set returns object on success" );
is( $object2->surname(), "Test Borrower Surname 3", "Set sets first field correctly" );
is( $object2->firstname(), "Test Firstname", "Set sets second field correctly" );

$ret = $object->set({ surname => "Test Borrower Surname 4", bork => "bork" });
is( $object2->surname(), "Test Borrower Surname 3", "Bad Set does not set field" );
is( $ret, 0, "Set returns 0 when passed a bad property" );

ok( ! defined $object->bork(), 'Bad getter returns undef' );
ok( ! defined $object->bork('bork'), 'Bad setter returns undef' );

1;
