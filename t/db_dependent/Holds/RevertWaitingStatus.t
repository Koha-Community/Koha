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
use MARC::Record;

use Koha::Libraries;
use Koha::Patrons;
use C4::Context;
use C4::Items;
use C4::Biblio;
use C4::Reserves;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;

$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM old_reserves");

my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
my $itemtype = $builder->build(
    { source => 'Itemtype', value => { notforloan => undef } } )->{itemtype};

local $SIG{__WARN__} = sub { warn $_[0] unless $_[0] =~ /redefined/ };
*C4::Context::userenv = \&Mock_userenv;

sub Mock_userenv {
    my $userenv = { flags => 1, id => '1', branch => $branchcode };
    return $userenv;
}

my $borrowers_count = 3;

# Create a biblio instance
my ( $bibnum, $title, $bibitemnum ) = create_helper_biblio();

# Create an item
my $item_barcode = 'my_barcode';
my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
    {   homebranch    => $branchcode,
        holdingbranch => $branchcode,
        barcode       => $item_barcode,
        itype         => $itemtype
    },
    $bibnum
);

# Create some borrowers
my $patron_category = $builder->build({ source => 'Category' });
my @borrowernumbers;
foreach my $i ( 1 .. $borrowers_count ) {
    my $borrowernumber = Koha::Patron->new({
        firstname    => 'my firstname',
        surname      => 'my surname ' . $i,
        categorycode => $patron_category->{categorycode},
        branchcode   => $branchcode,
    })->store->borrowernumber;
    push @borrowernumbers, $borrowernumber;
}

my $biblionumber = $bibnum;

# Create five item level holds
foreach my $borrowernumber (@borrowernumbers) {
    AddReserve(
        $branchcode,
        $borrowernumber,
        $biblionumber,
        my $bibitems   = q{},
        my $priority,
        my $resdate,
        my $expdate,
        my $notes = q{},
        $title,
        my $checkitem,
        my $found,
    );
}

ModReserveAffect( $itemnumber, $borrowernumbers[0] );
my $patron = Koha::Patrons->find( $borrowernumbers[1] )->unblessed;
C4::Circulation::AddIssue( $patron,
    $item_barcode, my $datedue, my $cancelreserve = 'revert' );

my $priorities = $dbh->selectall_arrayref(
    "SELECT priority FROM reserves ORDER BY priority ASC");
ok( scalar @$priorities == 2,   'Only 2 holds remain in the reserves table' );
ok( $priorities->[0]->[0] == 1, 'First hold has a priority of 1' );
ok( $priorities->[1]->[0] == 2, 'Second hold has a priority of 2' );

$schema->storage->txn_rollback;

# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $bib   = MARC::Record->new();
    my $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new( '100', ' ', ' ', a => 'Moffat, Steven' ),
        MARC::Field->new( '245', ' ', ' ', a => $title ),
    );
    return ( $bibnum, $title, $bibitemnum ) = AddBiblio( $bib, '' );
}
