#!/usr/bin/perl
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#

use Modern::Perl;

use MARC::Record;
use C4::Biblio;
use C4::Branch;
use Koha::Database;

use Test::More tests => 6;

BEGIN {
    use_ok('C4::Items');
}

my $dbh = C4::Context->dbh;

subtest 'General Add, Get and Del tests' => sub {

    plan tests => 6;

    # Start transaction
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    # Create a biblio instance for testing
    C4::Context->set_preference('marcflavour', 'MARC21');
    my ($bibnum, $bibitemnum) = get_biblio();

    # Add an item.
    my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => 'CPL', holdingbranch => 'CPL' } , $bibnum);
    cmp_ok($item_bibnum, '==', $bibnum, "New item is linked to correct biblionumber.");
    cmp_ok($item_bibitemnum, '==', $bibitemnum, "New item is linked to correct biblioitemnumber.");

    # Get item.
    my $getitem = GetItem($itemnumber);
    cmp_ok($getitem->{'itemnumber'}, '==', $itemnumber, "Retrieved item has correct itemnumber.");
    cmp_ok($getitem->{'biblioitemnumber'}, '==', $item_bibitemnum, "Retrieved item has correct biblioitemnumber.");

    # Modify item; setting barcode.
    ModItem({ barcode => '987654321' }, $bibnum, $itemnumber);
    my $moditem = GetItem($itemnumber);
    cmp_ok($moditem->{'barcode'}, '==', '987654321', 'Modified item barcode successfully to: '.$moditem->{'barcode'} . '.');

    # Delete item.
    DelItem({ biblionumber => $bibnum, itemnumber => $itemnumber });
    my $getdeleted = GetItem($itemnumber);
    is($getdeleted->{'itemnumber'}, undef, "Item deleted as expected.");

    $dbh->rollback;
};

subtest 'GetHiddenItemnumbers tests' => sub {

    plan tests => 9;

    # This sub is controlled by the OpacHiddenItems system preference.

    # Start transaction
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    # Create a new biblio
    C4::Context->set_preference('marcflavour', 'MARC21');
    my ($biblionumber, $biblioitemnumber) = get_biblio();

    # Add branches if they don't exist
    if (not defined GetBranchDetail('CPL')) {
        ModBranch({add => 1, branchcode => 'CPL', branchname => 'Centerville'});
    }
    if (not defined GetBranchDetail('MPL')) {
        ModBranch({add => 1, branchcode => 'MPL', branchname => 'Midway'});
    }

    # Add two items
    my ($item1_bibnum, $item1_bibitemnum, $item1_itemnumber) = AddItem(
            { homebranch => 'CPL',
              holdingbranch => 'CPL',
              withdrawn => 1 },
            $biblionumber
    );
    my ($item2_bibnum, $item2_bibitemnum, $item2_itemnumber) = AddItem(
            { homebranch => 'MPL',
              holdingbranch => 'MPL',
              withdrawn => 0 },
            $biblionumber
    );

    my $opachiddenitems;
    my @itemnumbers = ($item1_itemnumber,$item2_itemnumber);
    my @hidden;
    my @items;
    push @items, GetItem( $item1_itemnumber );
    push @items, GetItem( $item2_itemnumber );

    # Empty OpacHiddenItems
    C4::Context->set_preference('OpacHiddenItems','');
    ok( !defined( GetHiddenItemnumbers( @items ) ),
        "Hidden items list undef if OpacHiddenItems empty");

    # Blank spaces
    C4::Context->set_preference('OpacHiddenItems','  ');
    ok( scalar GetHiddenItemnumbers( @items ) == 0,
        "Hidden items list empty if OpacHiddenItems only contains blanks");

    # One variable / value
    $opachiddenitems = "
        withdrawn: [1]";
    C4::Context->set_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 1, "Only one hidden item");
    is( $hidden[0], $item1_itemnumber, "withdrawn=1 is hidden");

    # One variable, two values
    $opachiddenitems = "
        withdrawn: [1,0]";
    C4::Context->set_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and withdrawn=0 hidden");

    # Two variables, a value each
    $opachiddenitems = "
        withdrawn: [1]
        homebranch: [MPL]
    ";
    C4::Context->set_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and homebranch=MPL hidden");

    # Valid OpacHiddenItems, empty list
    @items = ();
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 0, "Empty items list, no item hidden");

    $dbh->rollback;
};

subtest 'GetItemsInfo tests' => sub {

    plan tests => 3;

    # Start transaction
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    my $homebranch    = 'CPL';
    my $holdingbranch = 'MPL';

    # Add a biblio
    my $biblionumber = get_biblio();
    # Add an item
    my ($item_bibnum, $item_bibitemnum, $itemnumber)
        = AddItem({
                homebranch    => $homebranch,
                holdingbranch => $holdingbranch
            }, $biblionumber );

    my $branch = GetBranchDetail( $homebranch );
    $branch->{ opac_info } = "homebranch OPAC info";
    ModBranch($branch);

    $branch = GetBranchDetail( $holdingbranch );
    $branch->{ opac_info } = "holdingbranch OPAC info";
    ModBranch($branch);

    my @results = GetItemsInfo( $biblionumber );
    ok( @results, 'GetItemsInfo returns results');
    is( $results[0]->{ home_branch_opac_info }, "homebranch OPAC info",
        'GetItemsInfo returns the correct home branch OPAC info notice' );
    is( $results[0]->{ holding_branch_opac_info }, "holdingbranch OPAC info",
        'GetItemsInfo returns the correct holding branch OPAC info notice' );

    $dbh->rollback;
};

subtest q{Test Koha::Database->schema()->resultset('Item')->itemtype()} => sub {

    plan tests => 2;

    # Start transaction
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    my $schema = Koha::Database->new()->schema();

    my $biblio =
    $schema->resultset('Biblio')->create(
        {
            title       => "Test title",
            biblioitems => [
                {
                    itemtype => 'BIB_LEVEL',
                    items    => [ { itype => "ITEM_LEVEL" } ]
                }
            ]
        }
    );

    my $biblioitem = $biblio->biblioitem();
    my ( $item ) = $biblioitem->items();

    C4::Context->set_preference( 'item-level_itypes', 0 );
    ok( $item->effective_itemtype() eq 'BIB_LEVEL', '$item->itemtype() returns biblioitem.itemtype when item-level_itypes is disabled' );

    C4::Context->set_preference( 'item-level_itypes', 1 );
    ok( $item->effective_itemtype() eq 'ITEM_LEVEL', '$item->itemtype() returns items.itype when item-level_itypes is enabled' );

    $dbh->rollback;
};

subtest 'SearchItems test' => sub {
    plan tests => 10;

    # Start transaction
    $dbh->{AutoCommit} = 0;
    $dbh->{RaiseError} = 1;

    C4::Context->set_preference('marcflavour', 'MARC21');
    my ($biblionumber) = get_biblio();

    # Add branches if they don't exist
    if (not defined GetBranchDetail('CPL')) {
        ModBranch({add => 1, branchcode => 'CPL', branchname => 'Centerville'});
    }
    if (not defined GetBranchDetail('MPL')) {
        ModBranch({add => 1, branchcode => 'MPL', branchname => 'Midway'});
    }

    my (undef, $initial_items_count) = SearchItems(undef, {rows => 1});

    # Add two items
    my (undef, undef, $item1_itemnumber) = AddItem({
        homebranch => 'CPL',
        holdingbranch => 'CPL',
    }, $biblionumber);
    my (undef, undef, $item2_itemnumber) = AddItem({
        homebranch => 'MPL',
        holdingbranch => 'MPL',
    }, $biblionumber);

    my ($items, $total_results);

    ($items, $total_results) = SearchItems();
    is($total_results, $initial_items_count + 2, "Created 2 new items");
    is(scalar @$items, $total_results, "SearchItems() returns all items");

    ($items, $total_results) = SearchItems(undef, {rows => 1});
    is($total_results, $initial_items_count + 2);
    is(scalar @$items, 1, "SearchItems(undef, {rows => 1}) returns only 1 item");

    # Search all items where homebranch = 'CPL'
    my $filter = {
        field => 'homebranch',
        query => 'CPL',
        operator => '=',
    };
    ($items, $total_results) = SearchItems($filter);
    ok($total_results > 0, "There is at least one CPL item");
    my $all_items_are_CPL = 1;
    foreach my $item (@$items) {
        if ($item->{homebranch} ne 'CPL') {
            $all_items_are_CPL = 0;
            last;
        }
    }
    ok($all_items_are_CPL, "All items returned by SearchItems are from CPL");

    # Search all items where homebranch != 'CPL'
    $filter = {
        field => 'homebranch',
        query => 'CPL',
        operator => '!=',
    };
    ($items, $total_results) = SearchItems($filter);
    ok($total_results > 0, "There is at least one non-CPL item");
    my $all_items_are_not_CPL = 1;
    foreach my $item (@$items) {
        if ($item->{homebranch} eq 'CPL') {
            $all_items_are_not_CPL = 0;
            last;
        }
    }
    ok($all_items_are_not_CPL, "All items returned by SearchItems are not from CPL");

    # Search all items where biblio title (245$a) is like 'Silence in the %'
    $filter = {
        field => 'marc:245$a',
        query => 'Silence in the %',
        operator => 'like',
    };
    ($items, $total_results) = SearchItems($filter);
    ok($total_results >= 2, "There is at least 2 items with a biblio title like 'Silence in the %'");

    # Search all items where biblio title is 'Silence in the library'
    # and homebranch is 'CPL'
    $filter = {
        conjunction => 'AND',
        filters => [
            {
                field => 'marc:245$a',
                query => 'Silence in the %',
                operator => 'like',
            },
            {
                field => 'homebranch',
                query => 'CPL',
                operator => '=',
            },
        ],
    };
    ($items, $total_results) = SearchItems($filter);
    my $found = 0;
    foreach my $item (@$items) {
        if ($item->{itemnumber} == $item1_itemnumber) {
            $found = 1;
            last;
        }
    }
    ok($found, "item1 found");

    $dbh->rollback;
};

# Helper method to set up a Biblio.
sub get_biblio {
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    );
    my ($bibnum, $bibitemnum) = AddBiblio($bib, '');
    return ($bibnum, $bibitemnum);
}
