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

use Test::More tests => 5;
use Test::MockModule;

use C4::Circulation;
use C4::Items;
use C4::Biblio;
use Koha::Database;
use Koha::DateUtils;
use Koha::Patrons;

use t::lib::TestBuilder;
use t::lib::Mocks;

use MARC::Record;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $library = $builder->build({ source => 'Branch' });
my $itemtype = $builder->build({ source => 'Itemtype' })->{itemtype};
my $patron_category = $builder->build({ source => 'Category' });

t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });

my $borrowernumber = Koha::Patron->new({
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode => $library->{branchcode},
})->store->borrowernumber;

my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
my $record = MARC::Record->new();
my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $record, '' );

my $item = $builder->build_sample_item(
    {
        biblionumber     => $biblionumber,
        library          => $library->{branchcode},
        itype            => $itemtype
    }
);

is ( IsItemIssued( $item->itemnumber ), 0, "item is not on loan at first" );

AddIssue($borrower, $item->barcode);
is ( IsItemIssued( $item->itemnumber ), 1, "item is now on loan" );

is(
    DelItemCheck( $biblionumber, $item->itemnumber),
    'book_on_loan',
    'item that is on loan cannot be deleted',
);

AddReturn($item->barcode, $library->{branchcode});
is ( IsItemIssued( $item->itemnumber ), 0, "item has been returned" );

is(
    DelItemCheck( $biblionumber, $item->itemnumber),
    1,
    'item that is not on loan can be deleted',
);

$schema->storage->txn_rollback;

