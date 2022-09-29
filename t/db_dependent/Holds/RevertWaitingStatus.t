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
use C4::Reserves qw( AddReserve ModReserve ModReserveAffect );

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

$dbh->do("DELETE FROM reserves");
$dbh->do("DELETE FROM old_reserves");

my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
my $itemtype = $builder->build(
    { source => 'Itemtype', value => { notforloan => undef } } )->{itemtype};

t::lib::Mocks::mock_userenv({ flags => 1, userid => '1', branchcode => $branchcode });

my $borrowers_count = 3;

my $biblio = $builder->build_sample_biblio();
my $item_barcode = 'my_barcode';
my $itemnumber = Koha::Item->new(
    {
        biblionumber  => $biblio->biblionumber,
        homebranch    => $branchcode,
        holdingbranch => $branchcode,
        barcode       => $item_barcode,
        itype         => $itemtype
    },
)->store->itemnumber;

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

# Create five item level holds
foreach my $borrowernumber (@borrowernumbers) {
    AddReserve(
        {
            branchcode     => $branchcode,
            borrowernumber => $borrowernumber,
            biblionumber   => $biblio->biblionumber,
        }
    );
}

ModReserveAffect( $itemnumber, $borrowernumbers[0] );
my $patron = Koha::Patrons->find( $borrowernumbers[1] );
C4::Circulation::AddIssue( $patron, $item_barcode, undef, 'revert' );

my $priorities = $dbh->selectall_arrayref(
    "SELECT priority FROM reserves ORDER BY priority ASC");
ok( scalar @$priorities == 2,   'Only 2 holds remain in the reserves table' );
ok( $priorities->[0]->[0] == 1, 'First hold has a priority of 1' );
ok( $priorities->[1]->[0] == 2, 'Second hold has a priority of 2' );

$schema->storage->txn_rollback;
