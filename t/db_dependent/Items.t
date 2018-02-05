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
use Data::Dumper;

use MARC::Record;
use C4::Biblio;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Library;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::MarcSubfieldStructures;
use Koha::Caches;

use Test::More tests => 12;

use Test::Warn;

BEGIN {
    use_ok('C4::Items');
    use_ok('Koha::Items');
}

my $schema = Koha::Database->new->schema;
my $location = 'My Location';

subtest 'General Add, Get and Del tests' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $library = $builder->build({
        source => 'Branch',
    });
    my $itemtype = $builder->build({
        source => 'Itemtype',
    });

    # Create a biblio instance for testing
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my ($bibnum, $bibitemnum) = get_biblio();

    # Add an item.
    my ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode}, location => $location, itype => $itemtype->{itemtype} } , $bibnum);
    cmp_ok($item_bibnum, '==', $bibnum, "New item is linked to correct biblionumber.");
    cmp_ok($item_bibitemnum, '==', $bibitemnum, "New item is linked to correct biblioitemnumber.");

    # Get item.
    my $getitem = GetItem($itemnumber);
    cmp_ok($getitem->{'itemnumber'}, '==', $itemnumber, "Retrieved item has correct itemnumber.");
    cmp_ok($getitem->{'biblioitemnumber'}, '==', $item_bibitemnum, "Retrieved item has correct biblioitemnumber.");
    is( $getitem->{location}, $location, "The location should not have been modified" );
    is( $getitem->{permanent_location}, $location, "The permanent_location should have been set to the location value" );

    # Modify item; setting barcode.
    ModItem({ barcode => '987654321' }, $bibnum, $itemnumber);
    my $moditem = GetItem($itemnumber);
    cmp_ok($moditem->{'barcode'}, '==', '987654321', 'Modified item barcode successfully to: '.$moditem->{'barcode'} . '.');

    # Delete item.
    DelItem({ biblionumber => $bibnum, itemnumber => $itemnumber });
    my $getdeleted = GetItem($itemnumber);
    is($getdeleted->{'itemnumber'}, undef, "Item deleted as expected.");

    ($item_bibnum, $item_bibitemnum, $itemnumber) = AddItem({ homebranch => $library->{branchcode}, holdingbranch => $library->{branchcode}, location => $location, permanent_location => 'my permanent location', itype => $itemtype->{itemtype} } , $bibnum);
    $getitem = GetItem($itemnumber);
    is( $getitem->{location}, $location, "The location should not have been modified" );
    is( $getitem->{permanent_location}, 'my permanent location', "The permanent_location should not have modified" );

    ModItem({ location => $location }, $bibnum, $itemnumber);
    $getitem = GetItem($itemnumber);
    is( $getitem->{location}, $location, "The location should have been set to correct location" );
    is( $getitem->{permanent_location}, $location, "The permanent_location should have been set to location" );

    ModItem({ location => 'CART' }, $bibnum, $itemnumber);
    $getitem = GetItem($itemnumber);
    is( $getitem->{location}, 'CART', "The location should have been set to CART" );
    is( $getitem->{permanent_location}, $location, "The permanent_location should not have been set to CART" );

    t::lib::Mocks::mock_preference('item-level_itypes', '1');
    $getitem = GetItem($itemnumber);
    is( $getitem->{itype}, $itemtype->{itemtype}, "Itemtype set correctly when using item-level_itypes" );
    t::lib::Mocks::mock_preference('item-level_itypes', '0');
    $getitem = GetItem($itemnumber);
    is( $getitem->{itype}, undef, "Itemtype set correctly when not using item-level_itypes" );

    $schema->storage->txn_rollback;
};

subtest 'GetHiddenItemnumbers tests' => sub {

    plan tests => 9;

    # This sub is controlled by the OpacHiddenItems system preference.

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $library1 = $builder->build({
        source => 'Branch',
    });

    my $library2 = $builder->build({
        source => 'Branch',
    });
    my $itemtype = $builder->build({
        source => 'Itemtype',
    });

    # Create a new biblio
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my ($biblionumber, $biblioitemnumber) = get_biblio();

    # Add two items
    my ( $item1_bibnum, $item1_bibitemnum, $item1_itemnumber ) = AddItem(
        {
            homebranch    => $library1->{branchcode},
            holdingbranch => $library1->{branchcode},
            withdrawn     => 1,
            itype         => $itemtype->{itemtype},
        },
        $biblionumber
    );
    my ( $item2_bibnum, $item2_bibitemnum, $item2_itemnumber ) = AddItem(
        {
            homebranch    => $library2->{branchcode},
            holdingbranch => $library2->{branchcode},
            withdrawn     => 0,
            itype         => $itemtype->{itemtype},
        },
        $biblionumber
    );

    my $opachiddenitems;
    my @itemnumbers = ($item1_itemnumber,$item2_itemnumber);
    my @hidden;
    my @items;
    push @items, GetItem( $item1_itemnumber );
    push @items, GetItem( $item2_itemnumber );

    # Empty OpacHiddenItems
    t::lib::Mocks::mock_preference('OpacHiddenItems','');
    ok( !defined( GetHiddenItemnumbers( @items ) ),
        "Hidden items list undef if OpacHiddenItems empty");

    # Blank spaces
    t::lib::Mocks::mock_preference('OpacHiddenItems','  ');
    ok( scalar GetHiddenItemnumbers( @items ) == 0,
        "Hidden items list empty if OpacHiddenItems only contains blanks");

    # One variable / value
    $opachiddenitems = "
        withdrawn: [1]";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 1, "Only one hidden item");
    is( $hidden[0], $item1_itemnumber, "withdrawn=1 is hidden");

    # One variable, two values
    $opachiddenitems = "
        withdrawn: [1,0]";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and withdrawn=0 hidden");

    # Two variables, a value each
    $opachiddenitems = "
        withdrawn: [1]
        homebranch: [$library2->{branchcode}]
    ";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and homebranch library2 hidden");

    # Valid OpacHiddenItems, empty list
    @items = ();
    @hidden = GetHiddenItemnumbers( @items );
    ok( scalar @hidden == 0, "Empty items list, no item hidden");

    $schema->storage->txn_rollback;
};

subtest 'GetItemsInfo tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $library1 = $builder->build({
        source => 'Branch',
    });
    my $library2 = $builder->build({
        source => 'Branch',
    });
    my $itemtype = $builder->build({
        source => 'Itemtype',
    });

    # Add a biblio
    my ($biblionumber, $biblioitemnumber) = get_biblio();
    # Add an item
    my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
        {
            homebranch    => $library1->{branchcode},
            holdingbranch => $library2->{branchcode},
            itype         => $itemtype->{itemtype},
        },
        $biblionumber
    );

    my $library = Koha::Libraries->find( $library1->{branchcode} );
    $library->opac_info("homebranch OPAC info");
    $library->store;

    $library = Koha::Libraries->find( $library2->{branchcode} );
    $library->opac_info("holdingbranch OPAC info");
    $library->store;

    my @results = GetItemsInfo( $biblionumber );
    ok( @results, 'GetItemsInfo returns results');
    is( $results[0]->{ home_branch_opac_info }, "homebranch OPAC info",
        'GetItemsInfo returns the correct home branch OPAC info notice' );
    is( $results[0]->{ holding_branch_opac_info }, "holdingbranch OPAC info",
        'GetItemsInfo returns the correct holding branch OPAC info notice' );
    is( exists( $results[0]->{ onsite_checkout } ), 1,
        'GetItemsInfo returns a onsite_checkout key' );

    $schema->storage->txn_rollback;
};

subtest q{Test Koha::Database->schema()->resultset('Item')->itemtype()} => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $schema->resultset('Biblio')->create({
        title       => "Test title",
        datecreated => dt_from_string,
        biblioitems => [ { itemtype => 'BIB_LEVEL' } ],
    });
    my $biblioitem = $biblio->biblioitems->first;
    my $item = $schema->resultset('Item')->create({
        biblioitemnumber => $biblioitem->biblioitemnumber,
        biblionumber     => $biblio->biblionumber,
        itype            => "ITEM_LEVEL",
    });

    t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );
    is( $item->effective_itemtype(), 'BIB_LEVEL', '$item->itemtype() returns biblioitem.itemtype when item-level_itypes is disabled' );

    t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
    is( $item->effective_itemtype(), 'ITEM_LEVEL', '$item->itemtype() returns items.itype when item-level_itypes is enabled' );

    # If itemtype is not defined and item-level_level item types are set
    # fallback to biblio-level itemtype (Bug 14651) and warn
    $item->itype( undef );
    $item->update();
    my $effective_itemtype;
    warning_is { $effective_itemtype = $item->effective_itemtype() }
                "item-level_itypes set but no itemtype set for item (".$item->itemnumber.")",
                '->effective_itemtype() raises a warning when falling back to bib-level';

    ok( defined $effective_itemtype &&
                $effective_itemtype eq 'BIB_LEVEL',
        '$item->effective_itemtype() falls back to biblioitems.itemtype when item-level_itypes is enabled but undef' );

    $schema->storage->txn_rollback;
};

subtest 'SearchItems test' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;
    my $dbh = C4::Context->dbh;
    my $builder = t::lib::TestBuilder->new;

    my $library1 = $builder->build({
        source => 'Branch',
    });
    my $library2 = $builder->build({
        source => 'Branch',
    });
    my $itemtype = $builder->build({
        source => 'Itemtype',
    });

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my $cpl_items_before = SearchItemsByField( 'homebranch', $library1->{branchcode});

    my ($biblionumber) = get_biblio();

    my (undef, $initial_items_count) = SearchItems(undef, {rows => 1});

    # Add two items
    my (undef, undef, $item1_itemnumber) = AddItem({
        homebranch => $library1->{branchcode},
        holdingbranch => $library1->{branchcode},
        itype => $itemtype->{itemtype},
    }, $biblionumber);
    my (undef, undef, $item2_itemnumber) = AddItem({
        homebranch => $library2->{branchcode},
        holdingbranch => $library2->{branchcode},
        itype => $itemtype->{itemtype},
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
        query => $library1->{branchcode},
        operator => '=',
    };
    ($items, $total_results) = SearchItems($filter);
    ok($total_results > 0, "There is at least one CPL item");
    my $all_items_are_CPL = 1;
    foreach my $item (@$items) {
        if ($item->{homebranch} ne $library1->{branchcode}) {
            $all_items_are_CPL = 0;
            last;
        }
    }
    ok($all_items_are_CPL, "All items returned by SearchItems are from CPL");

    # Search all items where homebranch != 'CPL'
    $filter = {
        field => 'homebranch',
        query => $library1->{branchcode},
        operator => '!=',
    };
    ($items, $total_results) = SearchItems($filter);
    ok($total_results > 0, "There is at least one non-CPL item");
    my $all_items_are_not_CPL = 1;
    foreach my $item (@$items) {
        if ($item->{homebranch} eq $library1->{branchcode}) {
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
                query => $library1->{branchcode},
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

    my $frameworkcode = q||;
    my ($itemfield) = GetMarcFromKohaField('items.itemnumber', $frameworkcode);

    # Create item subfield 'z' without link
    $dbh->do('DELETE FROM marc_subfield_structure WHERE tagfield=? AND tagsubfield="z" AND frameworkcode=?', undef, $itemfield, $frameworkcode);
    $dbh->do('INSERT INTO marc_subfield_structure (tagfield, tagsubfield, frameworkcode) VALUES (?, "z", ?)', undef, $itemfield, $frameworkcode);

    # Clear cache
    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache("MarcStructure-0-$frameworkcode");
    $cache->clear_from_cache("MarcStructure-1-$frameworkcode");
    $cache->clear_from_cache("default_value_for_mod_marc-");
    $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

    my $item3_record = new MARC::Record;
    $item3_record->append_fields(
        new MARC::Field(
            $itemfield, '', '',
            'z' => 'foobar',
            'y' => $itemtype->{itemtype}
        )
    );
    my (undef, undef, $item3_itemnumber) = AddItemFromMarc($item3_record,
        $biblionumber);

    # Search item where item subfield z is "foobar"
    $filter = {
        field => 'marc:' . $itemfield . '$z',
        query => 'foobar',
        operator => 'like',
    };
    ($items, $total_results) = SearchItems($filter);
    ok(scalar @$items == 1, 'found 1 item with $z = "foobar"');

    # Link $z to items.itemnotes (and make sure there is no other subfields
    # linked to it)
    $dbh->do('DELETE FROM marc_subfield_structure WHERE kohafield="items.itemnotes" AND frameworkcode=?', undef, $itemfield, $frameworkcode);
    $dbh->do('UPDATE marc_subfield_structure SET kohafield="items.itemnotes" WHERE tagfield=? AND tagsubfield="z" AND frameworkcode=?', undef, $itemfield, $frameworkcode);

    # Clear cache
    $cache->clear_from_cache("MarcStructure-0-$frameworkcode");
    $cache->clear_from_cache("MarcStructure-1-$frameworkcode");
    $cache->clear_from_cache("default_value_for_mod_marc-");
    $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

    ModItemFromMarc($item3_record, $biblionumber, $item3_itemnumber);

    # Make sure the link is used
    my $item3 = GetItem($item3_itemnumber);
    ok($item3->{itemnotes} eq 'foobar', 'itemnotes eq "foobar"');

    # Do the same search again.
    # This time it will search in items.itemnotes
    ($items, $total_results) = SearchItems($filter);
    ok(scalar @$items == 1, 'found 1 item with itemnotes = "foobar"');

    my $cpl_items_after = SearchItemsByField( 'homebranch', $library1->{branchcode});
    is( ( scalar( @$cpl_items_after ) - scalar ( @$cpl_items_before ) ), 1, 'SearchItemsByField should return something' );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Item(s) tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin();

    my $builder = t::lib::TestBuilder->new;
    my $library1 = $builder->build({
        source => 'Branch',
    });
    my $library2 = $builder->build({
        source => 'Branch',
    });
    my $itemtype = $builder->build({
        source => 'Itemtype',
    });

    # Create a biblio and item for testing
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my ($bibnum, $bibitemnum) = get_biblio();
    my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
        {
            homebranch    => $library1->{branchcode},
            holdingbranch => $library2->{branchcode},
            itype         => $itemtype->{itemtype},
        },
        $bibnum
    );

    # Get item.
    my $item = Koha::Items->find( $itemnumber );
    is( ref($item), 'Koha::Item', "Got Koha::Item" );

    my $homebranch = $item->home_branch();
    is( ref($homebranch), 'Koha::Library', "Got Koha::Library from home_branch method" );
    is( $homebranch->branchcode(), $library1->{branchcode}, "Home branch code matches homebranch" );

    my $holdingbranch = $item->holding_branch();
    is( ref($holdingbranch), 'Koha::Library', "Got Koha::Library from holding_branch method" );
    is( $holdingbranch->branchcode(), $library2->{branchcode}, "Home branch code matches holdingbranch" );

    $schema->storage->txn_rollback;
};

subtest 'C4::Biblio::EmbedItemsInMarcBiblio' => sub {
    plan tests => 7;

    $schema->storage->txn_begin();

    my $builder = t::lib::TestBuilder->new;
    my $library1 = $builder->build({
        source => 'Branch',
    });
    my $library2 = $builder->build({
        source => 'Branch',
    });
    my $itemtype = $builder->build({
        source => 'Itemtype',
    });

    my ( $biblionumber, $biblioitemnumber ) = get_biblio();
    my $item_infos = [
        { homebranch => $library1->{branchcode}, holdingbranch => $library1->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library1->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library1->{branchcode} },
        { homebranch => $library2->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library2->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library2->{branchcode} },
        { homebranch => $library1->{branchcode}, holdingbranch => $library2->{branchcode} },
    ];
    my $number_of_items = scalar @$item_infos;
    my $number_of_items_with_homebranch_is_CPL =
      grep { $_->{homebranch} eq $library1->{branchcode} } @$item_infos;

    my @itemnumbers;
    for my $item_info (@$item_infos) {
        my ( undef, undef, $itemnumber ) = AddItem(
            {
                homebranch    => $item_info->{homebranch},
                holdingbranch => $item_info->{holdingbanch},
                itype         => $itemtype->{itemtype},
            },
            $biblionumber
        );
        push @itemnumbers, $itemnumber;
    }

    # Emptied the OpacHiddenItems pref
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', '' );

    my ($itemfield) =
      C4::Biblio::GetMarcFromKohaField( 'items.itemnumber', '' );
    my $record = C4::Biblio::GetMarcBiblio({ biblionumber => $biblionumber });
    warning_is { C4::Biblio::EmbedItemsInMarcBiblio() }
    { carped => 'EmbedItemsInMarcBiblio: No MARC record passed' },
      'Should crap is no record passed.';

    C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblionumber );
    my @items = $record->field($itemfield);
    is( scalar @items, $number_of_items, 'Should return all items' );

    C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblionumber,
        [ $itemnumbers[1], $itemnumbers[3] ] );
    @items = $record->field($itemfield);
    is( scalar @items, 2, 'Should return all items present in the list' );

    C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblionumber, undef, 1 );
    @items = $record->field($itemfield);
    is( scalar @items, $number_of_items, 'Should return all items for opac' );

    my $opachiddenitems = "
        homebranch: ['$library1->{branchcode}']";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );

    C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblionumber );
    @items = $record->field($itemfield);
    is( scalar @items,
        $number_of_items,
        'Even with OpacHiddenItems set, all items should have been embedded' );

    C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblionumber, undef, 1 );
    @items = $record->field($itemfield);
    is(
        scalar @items,
        $number_of_items - $number_of_items_with_homebranch_is_CPL,
'For OPAC, the pref OpacHiddenItems should have been take into account. Only items with homebranch ne CPL should have been embedded'
    );

    $opachiddenitems = "
        homebranch: ['$library1->{branchcode}', '$library2->{branchcode}']";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    C4::Biblio::EmbedItemsInMarcBiblio( $record, $biblionumber, undef, 1 );
    @items = $record->field($itemfield);
    is(
        scalar @items,
        0,
'For OPAC, If all items are hidden, no item should have been embedded'
    );

    $schema->storage->txn_rollback;
};


subtest 'C4::Items::_build_default_values_for_mod_marc' => sub {
    plan tests => 4;

    $schema->storage->txn_begin();

    my $builder = t::lib::TestBuilder->new;
    my $framework = $builder->build({ source => 'BiblioFramework' });

    # Link biblio.biblionumber and biblioitems.biblioitemnumber to avoid _koha_marc_update_bib_ids to fail with 'no biblio[item]number tag for framework"
    Koha::MarcSubfieldStructures->search({ frameworkcode => '', tagfield => '999', tagsubfield => [ 'c', 'd' ] })->delete;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '999', tagsubfield => 'c', kohafield => 'biblio.biblionumber' })->store;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '999', tagsubfield => 'd', kohafield => 'biblioitems.biblioitemnumber' })->store;

    # Same for item fields: itemnumber, barcode, itype
    Koha::MarcSubfieldStructures->search({ frameworkcode => '', tagfield => '952', tagsubfield => [ '9', 'p', 'y' ] })->delete;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '952', tagsubfield => '9', kohafield => 'items.itemnumber' })->store;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '952', tagsubfield => 'p', kohafield => 'items.barcode' })->store;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '952', tagsubfield => 'y', kohafield => 'items.itype' })->store;
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

    my $itemtype = $builder->build({ source => 'Itemtype' })->{itemtype};

    # Create a record with a barcode
    my ($biblionumber) = get_biblio( $framework->{frameworkcode} );
    my $item_record = new MARC::Record;
    my $a_barcode = 'a barcode';
    my $barcode_field = MARC::Field->new(
        '952', ' ', ' ',
        p => $a_barcode,
        y => $itemtype
    );
    my $itemtype_field = MARC::Field->new(
        '952', ' ', ' ',
        y => $itemtype
    );
    $item_record->append_fields( $barcode_field );
    my (undef, undef, $item_itemnumber) = AddItemFromMarc($item_record, $biblionumber);

    # Make sure everything has been set up
    my $item = GetItem($item_itemnumber);
    is( $item->{barcode}, $a_barcode, 'Everything has been set up correctly, the barcode is defined as expected' );

    # Delete the barcode field and save the record
    $item_record->delete_fields( $barcode_field );
    $item_record->append_fields( $itemtype_field ); # itemtype is mandatory
    ModItemFromMarc($item_record, $biblionumber, $item_itemnumber);
    $item = GetItem($item_itemnumber);
    is( $item->{barcode}, undef, 'The default value should have been set to the barcode, the field is mapped to a kohafield' );

    # Re-add the barcode field and save the record
    $item_record->append_fields( $barcode_field );
    ModItemFromMarc($item_record, $biblionumber, $item_itemnumber);
    $item = GetItem($item_itemnumber);
    is( $item->{barcode}, $a_barcode, 'Everything has been set up correctly, the barcode is defined as expected' );

    # Remove the mapping for barcode
    Koha::MarcSubfieldStructures->search({ frameworkcode => '', tagfield => '952', tagsubfield => 'p' })->delete;

    # And make sure the caches are cleared
    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache("default_value_for_mod_marc-");
    $cache->clear_from_cache("MarcSubfieldStructure-");

    # Update the MARC field with another value
    $item_record->delete_fields( $barcode_field );
    my $another_barcode = 'another_barcode';
    my $another_barcode_field = MARC::Field->new(
        '952', ' ', ' ',
        p => $another_barcode,
    );
    $item_record->append_fields( $another_barcode_field );
    # The DB value should not have been updated
    ModItemFromMarc($item_record, $biblionumber, $item_itemnumber);
    $item = GetItem($item_itemnumber);
    is ( $item->{barcode}, $a_barcode, 'items.barcode is not mapped anymore, so the DB column has not been updated' );

    $cache->clear_from_cache("default_value_for_mod_marc-");
    $cache->clear_from_cache( "MarcSubfieldStructure-" );
    $schema->storage->txn_rollback;
};

subtest '_mod_item_dates' => sub {
    plan tests => 11;

    is( C4::Items::_mod_item_dates(), undef, 'Call without parameters' );
    is( C4::Items::_mod_item_dates(1), undef, 'Call without hashref' );

    my $orgitem;
    my $item = {
        itemcallnumber  => 'V II 149 1963',
        barcode         => '109304',
    };
    $orgitem = { %$item };
    C4::Items::_mod_item_dates($item);
    is_deeply( $item, $orgitem, 'No dates passed to _mod_item_dates' );

    # add two correct dates
    t::lib::Mocks::mock_preference('dateformat', 'us');
    $item->{dateaccessioned} = '01/31/2016';
    $item->{onloan} =  $item->{dateaccessioned};
    $orgitem = { %$item };
    C4::Items::_mod_item_dates($item);
    is( $item->{dateaccessioned}, '2016-01-31', 'dateaccessioned is fine' );
    is( $item->{onloan}, '2016-01-31', 'onloan is fine too' );


    # add some invalid dates
    $item->{notexistingcolumndate} = '13/1/2015'; # wrong format
    $item->{anotherdate} = 'tralala'; # even worse
    $item->{myzerodate} = '0000-00-00'; # wrong too
    C4::Items::_mod_item_dates($item);
    is( $item->{notexistingcolumndate}, undef, 'Invalid date became NULL' );
    is( $item->{anotherdate}, undef, 'Second invalid date became NULL too' );
    is( $item->{myzerodate}, undef, '0000-00-00 became NULL too' );

    # check if itemlost_on was not touched
    $item->{itemlost_on} = '12345678';
    $item->{withdrawn_on} = '12/31/2015 23:59:00';
    $orgitem = { %$item };
    C4::Items::_mod_item_dates($item);
    is_deeply( $item, $orgitem, 'Colums with _on are not touched' );

    t::lib::Mocks::mock_preference('dateformat', 'metric');
    $item->{dateaccessioned} = '01/31/2016'; #wrong
    $item->{yetanotherdatetime} = '20/01/2016 13:58:00'; #okay
    C4::Items::_mod_item_dates($item);
    is( $item->{dateaccessioned}, undef, 'dateaccessioned wrong format' );
    is( $item->{yetanotherdatetime}, '2016-01-20 13:58:00',
        'yetanotherdatetime is ok' );
};

subtest 'get_hostitemnumbers_of' => sub {
    plan tests => 1;

    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
        MARC::Field->new('773', ' ', ' ', b => 'b without 0 or 9'),
    );
    my ($biblionumber, $bibitemnum) = AddBiblio($bib, '');

    my @itemnumbers = C4::Items::get_hostitemnumbers_of( $biblionumber );
    is( @itemnumbers, 0, );
};

# Helper method to set up a Biblio.
sub get_biblio {
    my ( $frameworkcode ) = @_;
    $frameworkcode //= '';
    my $bib = MARC::Record->new();
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    );
    my ($bibnum, $bibitemnum) = AddBiblio($bib, $frameworkcode);
    return ($bibnum, $bibitemnum);
}
