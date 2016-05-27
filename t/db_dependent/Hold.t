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

use t::lib::Mocks;
use C4::Context;
use C4::Biblio qw( AddBiblio );
use Koha::Database;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Item;
use Koha::DateUtils;
use t::lib::TestBuilder;

use Test::More tests => 32;
use Test::Warn;

use_ok('Koha::Hold');

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

# add two branches and a borrower
my $builder = t::lib::TestBuilder->new;
my @branches;
foreach( 1..2 ) {
    push @branches, $builder->build({ source => 'Branch' });
}
my $borrower = $builder->build({ source => 'Borrower' });

my $biblio = MARC::Record->new();
my $title  = 'Silence in the library';
$biblio->append_fields(
    MARC::Field->new( '100', ' ', ' ', a => 'Moffat, Steven' ),
    MARC::Field->new( '245', ' ', ' ', a => $title ),
);
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $biblio, '' );

my $item = Koha::Item->new(
    {
        biblionumber     => $biblionumber,
        biblioitemnumber => $biblioitemnumber,
        holdingbranch    => $branches[0]->{branchcode},
        homebranch       => $branches[0]->{branchcode},
    }
);
$item->store();

my $hold = Koha::Hold->new(
    {
        biblionumber   => $biblionumber,
        itemnumber     => $item->id(),
        waitingdate    => '2000-01-01',
        borrowernumber => $borrower->{borrowernumber},
        branchcode     => $branches[1]->{branchcode},
        suspend        => 0,
    }
);
$hold->store();

is( $hold->suspend, 0, "Hold is not suspended" );
$hold->suspend_hold();
is( $hold->suspend, 1, "Hold is suspended" );
$hold->resume();
is( $hold->suspend, 0, "Hold is not suspended" );
my $dt = dt_from_string();
$hold->suspend_hold( $dt );
$dt->truncate( to => 'day' );
is( $hold->suspend, 1, "Hold is suspended" );
is( $hold->suspend_until, "$dt", "Hold is suspended with a date, truncation takes place automatically" );
$hold->resume();
is( $hold->suspend, 0, "Hold is not suspended" );
is( $hold->suspend_until, undef, "Hold no longer has suspend_until date" );
$hold->found('W');
warning_like { $hold->suspend_hold }
    qr/Unable to suspend waiting hold!/, 'Catch warn about failed suspend';
is( $hold->suspend, 0, "Waiting hold cannot be suspended" );

$item = $hold->item();

my $hold_borrower = $hold->borrower();
ok( $hold_borrower, 'Got hold borrower' );
is( $hold_borrower->borrowernumber(), $borrower->{borrowernumber}, 'Hold borrower matches correct borrower' );

t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay', '' );
$dt = $hold->waiting_expires_on();
is( $dt, undef, "Koha::Hold->waiting_expires_on returns undef if ReservesMaxPickUpDelay is not set" );

is( $hold->is_waiting, 1, 'The hold is waiting' );
is( $hold->is_found, 1, 'The hold is found');
ok( !$hold->is_in_transit, 'The hold is not in transit' );

t::lib::Mocks::mock_preference( 'ReservesMaxPickUpDelay', '5' );
$dt = $hold->waiting_expires_on();
is( $dt->ymd, "2000-01-06",
    "Koha::Hold->waiting_expires_on returns DateTime of waitingdate + ReservesMaxPickUpDelay if set" );

$hold->found('T');
$dt = $hold->waiting_expires_on();
is( $dt, undef, "Koha::Hold->waiting_expires_on returns undef if found is not 'W' ( Set to 'T' )" );
isnt( $hold->is_waiting, 1, 'The hold is not waiting (T)' );
is( $hold->is_found, 1, 'The hold is found');
is( $hold->is_in_transit, 1, 'The hold is in transit' );

$hold->found(q{});
$dt = $hold->waiting_expires_on();
is( $dt, undef, "Koha::Hold->waiting_expires_on returns undef if found is not 'W' ( Set to empty string )" );
isnt( $hold->is_waiting, 1, 'The hold is not waiting (W)' );
is( $hold->is_found, 0, 'The hold is not found' );
ok( !$hold->is_in_transit, 'The hold is not in transit' );

# Test method is_cancelable
$hold->found(undef);
ok( $hold->is_cancelable(), "Unfound hold is cancelable" );
$hold->found('W');
ok( $hold->is_cancelable, "Waiting hold is cancelable" );
$hold->found('T');
ok( !$hold->is_cancelable, "In transit hold is not cancelable" );

# Test method is_at_destination
$hold->found(undef);
ok( !$hold->is_at_destination(), "Unfound hold cannot be at destination" );
$hold->found('T');
ok( !$hold->is_at_destination(), "In transit hold cannot be at destination" );
$hold->found('W');
ok( !$hold->is_at_destination(), "Waiting hold where hold branchcode is not the same as the item's holdingbranch is not at destination" );
$item->holdingbranch( $branches[1]->{branchcode} );
ok( $hold->is_at_destination(), "Waiting hold where hold branchcode is the same as the item's holdingbranch is at destination" );

$schema->storage->txn_rollback();

1;
