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

use C4::Circulation;
use Koha::Database;
use Koha::Patron;
use Koha::Biblio;
use Koha::Item;
use Koha::Holds;
use Koha::Hold;
use t::lib::TestBuilder;

use Test::More tests => 14;

my $dbh    = C4::Context->dbh;
my $schema = Koha::Database->new()->schema();
my $builder = t::lib::TestBuilder->new;

# Start transaction
$dbh->{RaiseError} = 1;
$schema->storage->txn_begin();

$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM issuingrules');
$dbh->do('DELETE FROM borrowers');
$dbh->do('DELETE FROM items');

my $library  = $builder->build( { source => 'Branch' } );
my $category = $builder->build( { source => 'Category' } );
my $itemtype = $builder->build( { source => 'Itemtype' } )->{itemtype};

# Set userenv
C4::Context->_new_userenv('xxx');
C4::Context->set_userenv( 0, 0, 0, 'firstname', 'surname', $library->{branchcode}, 'Midway Public Library', '', '', '' );
is( C4::Context->userenv->{branch}, $library->{branchcode}, 'userenv set' );

my @patrons;
for my $i ( 1 .. 20 ) {
    my $patron = Koha::Patron->new(
        { cardnumber => $i, firstname => 'Kyle', surname => 'Hall', categorycode => $category->{categorycode}, branchcode => $library->{branchcode} } )
      ->store();
    push( @patrons, $patron );
}

my $biblio = Koha::Biblio->new()->store();
my $biblioitem =
  $schema->resultset('Biblioitem')->new( { biblionumber => $biblio->biblionumber } )->insert();

my @items;
for my $i ( 1 .. 10 ) {
    my $item = Koha::Item->new(
        {
            biblionumber     => $biblio->id(),
            biblioitemnumber => $biblioitem->id(),
            barcode          => $i,
            itype            => $itemtype
        }
    )->store();
    push( @items, $item );
}

for my $i ( 0 .. 5 ) {
    my $patron = $patrons[$i];
    my $hold   = Koha::Hold->new(
        {
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            branchcode     => $library->{branchcode},
        }
    )->store();
}

$builder->build(
    {
        source => 'Issuingrule',
        value => {
            branchcode => '*',
            categorycode => '*',
            itemtype => '*',
            issuelength => '14',
            lengthunit => 'days',
            reservesallowed => '99',
        }
    }
);

my $item   = pop(@items);
my $patron = pop(@patrons);

C4::Context->set_preference( 'decreaseLoanHighHolds',               1 );
C4::Context->set_preference( 'decreaseLoanHighHoldsDuration',       1 );
C4::Context->set_preference( 'decreaseLoanHighHoldsValue',          1 );
C4::Context->set_preference( 'decreaseLoanHighHoldsControl',        'static' );
C4::Context->set_preference( 'decreaseLoanHighHoldsIgnoreStatuses', 'damaged,itemlost,notforloan,withdrawn' );

my $item_hr = { itemnumber => $item->id, biblionumber => $biblio->id, homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode}, barcode => $item->barcode };
my $patron_hr = { borrowernumber => $patron->id, branchcode => $library->{branchcode} };

my $data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded},        1,          "Static mode should exceed threshold" );
is( $data->{outstanding},     6,          "Should have 5 outstanding holds" );
is( $data->{duration},        1,          "Should have duration of 1" );
is( ref( $data->{due_date} ), 'DateTime', "due_date should be a DateTime object" );

C4::Context->set_preference( 'decreaseLoanHighHoldsControl', 'dynamic' );
$data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded}, 0, "Should not exceed threshold" );

for my $i ( 5 .. 10 ) {
    my $patron = $patrons[$i];
    my $hold   = Koha::Hold->new(
        {
            borrowernumber => $patron->id,
            biblionumber   => $biblio->id,
            branchcode     => $library->{branchcode},
        }
    )->store();
}

$data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded}, 1, "Should exceed threshold of 1" );

C4::Context->set_preference( 'decreaseLoanHighHoldsValue', 2 );
$data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded}, 0, "Should not exceed threshold of 2" );

my $unholdable = pop(@items);
$unholdable->damaged(-1);
$unholdable->store();

$data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded}, 1, "Should exceed threshold with one damaged item" );

$unholdable->damaged(0);
$unholdable->itemlost(-1);
$unholdable->store();

$data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded}, 1, "Should exceed threshold with one lost item" );

$unholdable->itemlost(0);
$unholdable->notforloan(-1);
$unholdable->store();

$data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded}, 1, "Should exceed threshold with one notforloan item" );

$unholdable->notforloan(0);
$unholdable->withdrawn(-1);
$unholdable->store();

$data = C4::Circulation::checkHighHolds( $item_hr, $patron_hr );
is( $data->{exceeded}, 1, "Should exceed threshold with one withdrawn item" );

C4::Context->set_preference('CircControl', 'PatronLibrary');

my ( undef, $needsconfirmation ) = CanBookBeIssued( $patron_hr, $item->barcode );
ok( $needsconfirmation->{HIGHHOLDS}, "High holds checkout needs confirmation" );

( undef, $needsconfirmation ) = CanBookBeIssued( $patron_hr, $item->barcode, undef, undef, undef, { override_high_holds => 1 } );
ok( !$needsconfirmation->{HIGHHOLDS}, "High holds checkout does not need confirmation" );

$schema->storage->txn_rollback();
1;
