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

use C4::Context;
use Koha::Database;

use Test::More tests => 8;

use_ok('Koha::Hold');

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

my $hold = Koha::Hold->new({ found => 'W', waitingdate => '2000-01-01'});

C4::Context->set_preference( 'ReservesMaxPickUpDelay', '' );
my $dt = $hold->waiting_expires_on();
is( $dt, undef, "Koha::Hold->waiting_expires_on returns undef if ReservesMaxPickUpDelay is not set");

is( $hold->is_waiting, 1, 'The hold is waiting' );

C4::Context->set_preference( 'ReservesMaxPickUpDelay', '5' );
$dt = $hold->waiting_expires_on();
is( $dt->ymd, "2000-01-06", "Koha::Hold->waiting_expires_on returns DateTime of waitingdate + ReservesMaxPickUpDelay if set");

$hold->found('T');
$dt = $hold->waiting_expires_on();
is( $dt, undef, "Koha::Hold->waiting_expires_on returns undef if found is not 'W' ( Set to 'T' )");
isnt( $hold->is_waiting, 1, 'The hold is not waiting (T)' );

$hold->found(q{});
$dt = $hold->waiting_expires_on();
is( $dt, undef, "Koha::Hold->waiting_expires_on returns undef if found is not 'W' ( Set to empty string )");
isnt( $hold->is_waiting, 1, 'The hold is not waiting (W)' );

$schema->storage->txn_rollback();

1;
