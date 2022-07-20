#!/usr/bin/perl
#
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
use Data::Dumper;

use MARC::Record;
use C4::Items qw( ModItemTransfer GetHiddenItemnumbers GetItemsInfo SearchItems AddItemFromMarc ModItemFromMarc get_hostitemnumbers_of Item2Marc );
use C4::Biblio qw( GetMarcFromKohaField EmbedItemsInMarcBiblio GetMarcBiblio AddBiblio );
use Koha::Items;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Library;
use Koha::DateUtils;
use Koha::MarcSubfieldStructures;
use Koha::Caches;
use Koha::AuthorisedValues;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Test::More tests => 14;

use Test::Warn;

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
    my $biblio = $builder->build_sample_biblio();

    # Add an item.
    my $item = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->{branchcode},
            location     => $location,
            itype        => $itemtype->{itemtype}
        }
    );
    my $itemnumber = $item->itemnumber;
    cmp_ok($item->biblionumber, '==', $biblio->biblionumber, "New item is linked to correct biblionumber.");
    cmp_ok($item->biblioitemnumber, '==', $biblio->biblioitem->biblioitemnumber, "New item is linked to correct biblioitemnumber.");

    # Get item.
    my $getitem = Koha::Items->find($itemnumber);
    cmp_ok($getitem->itemnumber, '==', $itemnumber, "Retrieved item has correct itemnumber.");
    cmp_ok($getitem->biblioitemnumber, '==', $item->biblioitemnumber, "Retrieved item has correct biblioitemnumber."); # We are not testing anything useful here
    is( $getitem->location, $location, "The location should not have been modified" );
    is( $getitem->permanent_location, $location, "The permanent_location should have been set to the location value" );


    # Do not modify anything, and do not explode!
    $getitem->set({})->store;

    # Modify item; setting barcode.
    $getitem->barcode('987654321')->store;
    my $moditem = Koha::Items->find($itemnumber);
    cmp_ok($moditem->barcode, '==', '987654321', 'Modified item barcode successfully to: '.$moditem->barcode . '.');

    # Delete item.
    $moditem->delete;
    my $getdeleted = Koha::Items->find($itemnumber);
    is($getdeleted, undef, "Item deleted as expected.");

    $itemnumber = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->{branchcode},
            location     => $location,
            permanent_location => 'my permanent location',
            itype        => $itemtype->{itemtype}
        }
    )->itemnumber;
    $getitem = Koha::Items->find($itemnumber);
    is( $getitem->location, $location, "The location should not have been modified" );
    is( $getitem->permanent_location, 'my permanent location', "The permanent_location should not have modified" );

    my $new_location = "New location";
    $getitem->location($new_location)->store;
    $getitem = Koha::Items->find($itemnumber);
    is( $getitem->location, $new_location, "The location should have been set to correct location" );
    is( $getitem->permanent_location, $new_location, "The permanent_location should have been set to location" );

    $getitem->location('CART')->store;
    $getitem = Koha::Items->find($itemnumber);
    is( $getitem->location, 'CART', "The location should have been set to CART" );
    is( $getitem->permanent_location, $new_location, "The permanent_location should not have been set to CART" );

    t::lib::Mocks::mock_preference('item-level_itypes', '1');
    $getitem = Koha::Items->find($itemnumber);
    is( $getitem->effective_itemtype, $itemtype->{itemtype}, "Itemtype set correctly when using item-level_itypes" );
    t::lib::Mocks::mock_preference('item-level_itypes', '0');
    $getitem = Koha::Items->find($itemnumber);
    is( $getitem->effective_itemtype, $biblio->biblioitem->itemtype, "Itemtype set correctly when not using item-level_itypes" );

    $schema->storage->txn_rollback;
};

subtest 'ModItemTransfer tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $item    = $builder->build_sample_item();

    my $library1 = $builder->build(
        {
            source => 'Branch',
        }
    );
    my $library2 = $builder->build(
        {
            source => 'Branch',
        }
    );

    ModItemTransfer( $item->itemnumber, $library1->{branchcode},
        $library2->{branchcode}, 'Manual' );

    my $transfers = Koha::Item::Transfers->search(
        {
            itemnumber => $item->itemnumber
        }
    );

    is( $transfers->count, 1, "One transfer created with ModItemTransfer" );
    $item->discard_changes;
    is($item->holdingbranch, $library1->{branchcode}, "Items holding branch was updated to frombranch");

    ModItemTransfer( $item->itemnumber, $library2->{branchcode},
        $library1->{branchcode}, 'Manual' );
    $transfers = Koha::Item::Transfers->search(
        { itemnumber => $item->itemnumber, },
        { order_by   => { '-asc' => 'branchtransfer_id' } }
    );

    is($transfers->count, 2, "Second transfer recorded on second call of ModItemTransfer");
    my $transfer1 = $transfers->next;
    my $transfer2 = $transfers->next;
    isnt($transfer1->datecancelled, undef, "First transfer marked as cancelled by ModItemTransfer");
    like($transfer1->cancellation_reason,qr/^Manual/, "First transfer contains cancellation_reason 'Manual'");
    is($transfer2->datearrived, undef, "Second transfer is now the active transfer");
    $item->discard_changes;
    is($item->holdingbranch, $library2->{branchcode}, "Items holding branch was updated to frombranch");

    # Check 'reason' is populated when passed
    ModItemTransfer( $item->itemnumber, $library2->{branchcode},
        $library1->{branchcode}, "Manual" );

    $transfers = Koha::Item::Transfers->search(
        { itemnumber => $item->itemnumber, },
        { order_by   => { '-desc' => 'branchtransfer_id' } }
    );

    my $transfer3 = $transfers->next;
    is($transfer3->reason, 'Manual', "Reason set via ModItemTransfer");

    $schema->storage->txn_rollback;
};

subtest 'GetHiddenItemnumbers tests' => sub {

    plan tests => 11;

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
    my $biblio = $builder->build_sample_biblio();

    # Add two items
    my $item1_itemnumber = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library1->{branchcode},
            withdrawn    => 1,
            itype        => $itemtype->{itemtype}
        }
    )->itemnumber;
    my $item2_itemnumber = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library2->{branchcode},
            withdrawn    => 0,
            itype        => $itemtype->{itemtype}
        }
    )->itemnumber;
    my $opachiddenitems;
    my @itemnumbers = ($item1_itemnumber,$item2_itemnumber);
    my @hidden;
    my @items;
    push @items, Koha::Items->find( $item1_itemnumber )->unblessed;
    push @items, Koha::Items->find( $item2_itemnumber )->unblessed;

    # Empty OpacHiddenItems
    t::lib::Mocks::mock_preference('OpacHiddenItems','');
    ok( !defined( GetHiddenItemnumbers( { items => \@items } ) ),
        "Hidden items list undef if OpacHiddenItems empty");

    # Blank spaces
    t::lib::Mocks::mock_preference('OpacHiddenItems','  ');
    ok( scalar GetHiddenItemnumbers( { items => \@items } ) == 0,
        "Hidden items list empty if OpacHiddenItems only contains blanks");

    # One variable / value
    $opachiddenitems = "
        withdrawn: [1]";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( { items => \@items } );
    ok( scalar @hidden == 1, "Only one hidden item");
    is( $hidden[0], $item1_itemnumber, "withdrawn=1 is hidden");

    # One variable, two values
    $opachiddenitems = "
        withdrawn: [1,0]";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( { items => \@items } );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and withdrawn=0 hidden");

    # Two variables, a value each
    $opachiddenitems = "
        withdrawn: [1]
        homebranch: [$library2->{branchcode}]
    ";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    @hidden = GetHiddenItemnumbers( { items => \@items } );
    ok( scalar @hidden == 2, "Two items hidden");
    is_deeply( \@hidden, \@itemnumbers, "withdrawn=1 and homebranch library2 hidden");

    # Override hidden with patron category
    t::lib::Mocks::mock_preference( 'OpacHiddenItemsExceptions', 'S' );
    @hidden = GetHiddenItemnumbers( { items => \@items, borcat => 'PT' } );
    ok( scalar @hidden == 2, "Two items still hidden");
    @hidden = GetHiddenItemnumbers( { items => \@items, borcat => 'S' } );
    ok( scalar @hidden == 0, "Two items not hidden");

    # Valid OpacHiddenItems, empty list
    @items = ();
    @hidden = GetHiddenItemnumbers( { items => \@items } );
    ok( scalar @hidden == 0, "Empty items list, no item hidden");

    $schema->storage->txn_rollback;
};

subtest 'GetItemsInfo tests' => sub {

    plan tests => 9;

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

    Koha::AuthorisedValues->delete;
    my $av1 = Koha::AuthorisedValue->new(
        {
            category         => 'RESTRICTED',
            authorised_value => '1',
            lib              => 'Restricted Access',
            lib_opac         => 'Restricted Access OPAC',
        }
    )->store();

    # Add a biblio
    my $biblio = $builder->build_sample_biblio();
    # Add an item
    my $itemnumber = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            homebranch    => $library1->{branchcode},
            holdingbranch => $library2->{branchcode},
            itype         => $itemtype->{itemtype},
            restricted    => 1,
        }
    )->itemnumber;

    my $library = Koha::Libraries->find( $library1->{branchcode} );
    $library->opac_info("homebranch OPAC info");
    $library->store;

    $library = Koha::Libraries->find( $library2->{branchcode} );
    $library->opac_info("holdingbranch OPAC info");
    $library->store;

    my @results = GetItemsInfo( $biblio->biblionumber );
    ok( @results, 'GetItemsInfo returns results');

    is( $results[0]->{ home_branch_opac_info }, "homebranch OPAC info",
        'GetItemsInfo returns the correct home branch OPAC info notice' );
    is( $results[0]->{ holding_branch_opac_info }, "holdingbranch OPAC info",
        'GetItemsInfo returns the correct holding branch OPAC info notice' );
    is( exists( $results[0]->{ onsite_checkout } ), 1,
        'GetItemsInfo returns a onsite_checkout key' );
    is( $results[0]->{ restricted }, 1,
        'GetItemsInfo returns a restricted value code' );
    is( $results[0]->{ restrictedvalue }, "Restricted Access",
        'GetItemsInfo returns a restricted value description (staff)' );
    is( $results[0]->{ restrictedvalueopac }, "Restricted Access OPAC",
        'GetItemsInfo returns a restricted value description (OPAC)' );

    #place item into holds queue
    my $dbh = C4::Context->dbh;
    @results = GetItemsInfo( $biblio->biblionumber );
    is( $results[0]->{ has_pending_hold }, "0",
        'Hold not marked as pending/unavailable if nothing in tmp_holdsqueue for item' );

    $dbh->do(q{INSERT INTO tmp_holdsqueue (biblionumber, itemnumber, surname, borrowernumber ) VALUES (?, ?, "Zorro", 42)}, undef, $biblio->biblionumber, $itemnumber);
    @results = GetItemsInfo( $biblio->biblionumber );
    is( $results[0]->{ has_pending_hold }, "1",
        'Hold marked as pending/unavailable if tmp_holdsqueue is not empty for item' );

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
    plan tests => 17;

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
    my ($cpl_items_before) = SearchItems( { field => 'homebranch', query => $library1->{branchcode} } );

    my $biblio = $builder->build_sample_biblio({ title => 'Silence in the library' });
    $builder->build_sample_biblio({ title => 'Silence in the shadow' });

    my (undef, $initial_items_count) = SearchItems(undef, {rows => 1});

    # Add two items
    my $item1_itemnumber = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library1->{branchcode},
            itype        => $itemtype->{itemtype}
        }
    )->itemnumber;
    my $item2_itemnumber = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library2->{branchcode},
            itype        => $itemtype->{itemtype}
        }
    )->itemnumber;

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
    my ($itemfield) = GetMarcFromKohaField( 'items.itemnumber' );

    # Create item subfield 'z' without link
    $dbh->do('DELETE FROM marc_subfield_structure WHERE tagfield=? AND tagsubfield="z" AND frameworkcode=?', undef, $itemfield, $frameworkcode);
    $dbh->do('INSERT INTO marc_subfield_structure (tagfield, tagsubfield, frameworkcode) VALUES (?, "z", ?)', undef, $itemfield, $frameworkcode);

    # Clear cache
    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache("MarcStructure-0-$frameworkcode");
    $cache->clear_from_cache("MarcStructure-1-$frameworkcode");
    $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

    my $item3_record = MARC::Record->new;
    $item3_record->append_fields(
        MARC::Field->new(
            $itemfield, '', '',
            'z' => 'foobar',
            'y' => $itemtype->{itemtype}
        )
    );
    my (undef, undef, $item3_itemnumber) = AddItemFromMarc($item3_record,
        $biblio->biblionumber);

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
    $cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

    ModItemFromMarc($item3_record, $biblio->biblionumber, $item3_itemnumber);

    # Make sure the link is used
    my $item3 = Koha::Items->find($item3_itemnumber);
    is($item3->itemnotes, 'foobar', 'itemnotes eq "foobar"');

    # Do the same search again.
    # This time it will search in items.itemnotes
    ($items, $total_results) = SearchItems($filter);
    is(scalar(@$items), 1, 'found 1 item with itemnotes = "foobar"');

    my ($cpl_items_after) = SearchItems( { field => 'homebranch', query => $library1->{branchcode} } );
    is( ( scalar( @$cpl_items_after ) - scalar ( @$cpl_items_before ) ), 1, 'SearchItems should return something' );

    # Issues count = 0
    $filter = {
        conjunction => 'AND',
        filters => [
            {
                field => 'issues',
                query => 0,
                operator => '=',
            },
            {
                field => 'homebranch',
                query => $library1->{branchcode},
                operator => '=',
            },
        ],
    };
    ($items, $total_results) = SearchItems($filter);
    is($total_results, 1, "Search items.issues issues = 0 returns result (items.issues defaults to 0)");

    # Is null
    $filter = {
        conjunction => 'AND',
        filters     => [
            {
                field    => 'new_status',
                query    => 0,
                operator => '='
            },
            {
                field    => 'homebranch',
                query    => $library1->{branchcode},
                operator => '=',
            },
        ],
    };
    ($items, $total_results) = SearchItems($filter);
    is($total_results, 0, 'found no item with new_status=0 without ifnull');

    $filter->{filters}[0]->{ifnull} = 0;
    ($items, $total_results) = SearchItems($filter);
    is($total_results, 1, 'found all items of library1 with new_status=0 with ifnull = 0');

    $schema->storage->txn_rollback;
};

subtest 'Koha::Item(s) tests' => sub {

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

    # Create a biblio and item for testing
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my $biblio = $builder->build_sample_biblio();
    my $itemnumber = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            homebranch    => $library1->{branchcode},
            holdingbranch => $library2->{branchcode},
            itype         => $itemtype->{itemtype}
        }
    )->itemnumber;

    # Get item.
    my $item = Koha::Items->find( $itemnumber );
    is( ref($item), 'Koha::Item', "Got Koha::Item" );

    my $homebranch = $item->home_branch();
    is( ref($homebranch), 'Koha::Library', "Got Koha::Library from home_branch method" );
    is( $homebranch->branchcode(), $library1->{branchcode}, "Home branch code matches homebranch" );

    my $holdingbranch = $item->holding_branch();
    is( ref($holdingbranch), 'Koha::Library', "Got Koha::Library from holding_branch method" );
    is( $holdingbranch->branchcode(), $library2->{branchcode}, "Home branch code matches holdingbranch" );

    $biblio = $item->biblio();
    is( ref($item->biblio), 'Koha::Biblio', "Got Koha::Biblio from biblio method" );
    is( $item->biblio->title(), $biblio->title, 'Title matches biblio title' );

    $schema->storage->txn_rollback;
};

subtest 'C4::Biblio::EmbedItemsInMarcBiblio' => sub {
    plan tests => 8;

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

    my $biblio = $builder->build_sample_biblio();
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
        my $itemnumber = $builder->build_sample_item(
            {
                biblionumber  => $biblio->biblionumber,
                homebranch    => $item_info->{homebranch},
                holdingbranch => $item_info->{holdingbranch},
                itype         => $itemtype->{itemtype}
            }
        )->itemnumber;

        push @itemnumbers, $itemnumber;
    }

    # Emptied the OpacHiddenItems pref
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', '' );

    my ($itemfield) =
      C4::Biblio::GetMarcFromKohaField( 'items.itemnumber' );
    my $record = C4::Biblio::GetMarcBiblio({ biblionumber => $biblio->biblionumber });
    warning_is { C4::Biblio::EmbedItemsInMarcBiblio() }
    { carped => 'EmbedItemsInMarcBiblio: No MARC record passed' },
      'Should carp is no record passed.';

    C4::Biblio::EmbedItemsInMarcBiblio({
        marc_record  => $record,
        biblionumber => $biblio->biblionumber });
    my @items = $record->field($itemfield);
    is( scalar @items, $number_of_items, 'Should return all items' );

    my $marc_with_items = C4::Biblio::GetMarcBiblio({
        biblionumber => $biblio->biblionumber,
        embed_items  => 1 });
    is_deeply( $record, $marc_with_items, 'A direct call to GetMarcBiblio with items matches');

    C4::Biblio::EmbedItemsInMarcBiblio({
        marc_record  => $record,
        biblionumber => $biblio->biblionumber,
        item_numbers => [ $itemnumbers[1], $itemnumbers[3] ] });
    @items = $record->field($itemfield);
    is( scalar @items, 2, 'Should return all items present in the list' );

    C4::Biblio::EmbedItemsInMarcBiblio({
        marc_record  => $record,
        biblionumber => $biblio->biblionumber,
        opac         => 1 });
    @items = $record->field($itemfield);
    is( scalar @items, $number_of_items, 'Should return all items for opac' );

    my $opachiddenitems = "
        homebranch: ['$library1->{branchcode}']";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );

    C4::Biblio::EmbedItemsInMarcBiblio({
        marc_record  => $record,
        biblionumber => $biblio->biblionumber });
    @items = $record->field($itemfield);
    is( scalar @items,
        $number_of_items,
        'Even with OpacHiddenItems set, all items should have been embedded' );

    C4::Biblio::EmbedItemsInMarcBiblio({
        marc_record  => $record,
        biblionumber => $biblio->biblionumber,
        opac         => 1 });
    @items = $record->field($itemfield);
    is(
        scalar @items,
        $number_of_items - $number_of_items_with_homebranch_is_CPL,
'For OPAC, the pref OpacHiddenItems should have been take into account. Only items with homebranch ne CPL should have been embedded'
    );

    $opachiddenitems = "
        homebranch: ['$library1->{branchcode}', '$library2->{branchcode}']";
    t::lib::Mocks::mock_preference( 'OpacHiddenItems', $opachiddenitems );
    C4::Biblio::EmbedItemsInMarcBiblio({
        marc_record  => $record,
        biblionumber => $biblio->biblionumber,
        opac         => 1 });
    @items = $record->field($itemfield);
    is(
        scalar @items,
        0,
'For OPAC, If all items are hidden, no item should have been embedded'
    );

    $schema->storage->txn_rollback;
};


subtest 'get_hostitemnumbers_of' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;
    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    my $builder = t::lib::TestBuilder->new;

    # Host item field without 0 or 9
    my $bib1 = MARC::Record->new();
    $bib1->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
        MARC::Field->new('773', ' ', ' ', b => 'b without 0 or 9'),
    );
    my ($biblionumber1, $bibitemnum1) = AddBiblio($bib1, '');
    my @itemnumbers1 = C4::Items::get_hostitemnumbers_of( $biblionumber1 );
    is( scalar @itemnumbers1, 0, '773 without 0 or 9');

    # Correct host item field, analytical records on
    t::lib::Mocks::mock_preference('EasyAnalyticalRecords', 1);
    my $hostitem = $builder->build_sample_item();
    my $bib2 = MARC::Record->new();
    $bib2->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
        MARC::Field->new('773', ' ', ' ', 0 => $hostitem->biblionumber , 9 => $hostitem->itemnumber, b => 'b' ),
    );
    my ($biblionumber2, $bibitemnum2) = AddBiblio($bib2, '');
    my @itemnumbers2 = C4::Items::get_hostitemnumbers_of( $biblionumber2 );
    is( scalar @itemnumbers2, 1, '773 with 0 and 9, EasyAnalyticalRecords on');

    # Correct host item field, analytical records off
    t::lib::Mocks::mock_preference('EasyAnalyticalRecords', 0);
    @itemnumbers2 = C4::Items::get_hostitemnumbers_of( $biblionumber2 );
    is( scalar @itemnumbers2, 0, '773 with 0 and 9, EasyAnalyticalRecords off');

    $schema->storage->txn_rollback;
};

subtest 'Test logging for ModItem' => sub {

    plan tests => 3;

    t::lib::Mocks::mock_preference('CataloguingLog', 1);

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
    my $biblio = $builder->build_sample_biblio();

    # Add an item.
    my $item = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library->{homebranch},
            location     => $location,
            itype        => $itemtype->{itemtype}
        }
    );

    # False means no logging
    $schema->resultset('ActionLog')->search()->delete();
    $item->location($location)->store({ log_action => 0 });
    is( $schema->resultset('ActionLog')->count(), 0, 'False value does not trigger logging' );

    # True means logging
    $schema->resultset('ActionLog')->search()->delete();
    $item->location('new location')->store({ log_action => 1 });
    is( $schema->resultset('ActionLog')->count(), 1, 'True value does trigger logging' );

    # Undefined defaults to true
    $schema->resultset('ActionLog')->search()->delete();
    $item->location($location)->store();
    is( $schema->resultset('ActionLog')->count(), 1, 'Undefined value defaults to true, triggers logging' );

    $schema->storage->txn_rollback;
};

subtest 'Check stockrotationitem relationship' => sub {
    plan tests => 1;

    $schema->storage->txn_begin();

    my $builder = t::lib::TestBuilder->new;
    my $item = $builder->build_sample_item;

    $builder->build({
        source => 'Stockrotationitem',
        value  => { itemnumber_id => $item->itemnumber }
    });

    my $sritem = Koha::Items->find($item->itemnumber)->stockrotationitem;
    isa_ok( $sritem, 'Koha::StockRotationItem', "Relationship works and correctly creates Koha::Object." );

    $schema->storage->txn_rollback;
};

subtest 'Check add_to_rota method' => sub {
    plan tests => 2;

    $schema->storage->txn_begin();

    my $builder = t::lib::TestBuilder->new;
    my $item = $builder->build_sample_item;
    my $rota = $builder->build({ source => 'Stockrotationrota' });
    my $srrota = Koha::StockRotationRotas->find($rota->{rota_id});

    $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });

    my $sritem = Koha::Items->find($item->itemnumber);
    $sritem->add_to_rota($rota->{rota_id});

    is(
        Koha::StockRotationItems->find($item->itemnumber)->stage_id,
        $srrota->stockrotationstages->next->stage_id,
        "Adding to a rota a new sritem item being assigned to its first stage."
    );

    my $newrota = $builder->build({ source => 'Stockrotationrota' });

    my $srnewrota = Koha::StockRotationRotas->find($newrota->{rota_id});

    $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $newrota->{rota_id} },
    });

    $sritem->add_to_rota($newrota->{rota_id});

    is(
        Koha::StockRotationItems->find($item->itemnumber)->stage_id,
        $srnewrota->stockrotationstages->next->stage_id,
        "Moving an item results in that sritem being assigned to the new first stage."
    );

    $schema->storage->txn_rollback;
};

subtest 'Split subfields in Item2Marc (Bug 21774)' => sub {
    plan tests => 3;
    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $item = $builder->build_sample_item({ ccode => 'A|B' });

    Koha::MarcSubfieldStructures->search({ tagfield => '952', tagsubfield => '8' })->delete; # theoretical precaution
    Koha::MarcSubfieldStructures->search({ kohafield => 'items.ccode' })->delete;
    my $mapping = Koha::MarcSubfieldStructure->new(
        {
            frameworkcode => q{},
            tagfield      => '952',
            tagsubfield   => '8',
            kohafield     => 'items.ccode',
            repeatable    => 1
        }
    )->store;
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

    # Start testing
    my $marc = C4::Items::Item2Marc( $item->unblessed, $item->biblionumber );
    my @subs = $marc->subfield( $mapping->tagfield, $mapping->tagsubfield );
    is( @subs, 2, 'Expect two subfields' );
    is( $subs[0], 'A', 'First subfield matches' );
    is( $subs[1], 'B', 'Second subfield matches' );

    $schema->storage->txn_rollback;
};

subtest 'ModItemFromMarc' => sub {
    plan tests => 6;
    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my ($itemfield) = GetMarcFromKohaField( 'items.itemnumber' );
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $biblio = $builder->build_sample_biblio;
    my ( $lost_tag, $lost_sf ) = GetMarcFromKohaField( 'items.itemlost' );
    my $item_record = MARC::Record->new;
    $item_record->append_fields(
        MARC::Field->new(
            $itemfield, '', '',
            'y' => $itemtype->itemtype,
        ),
        MARC::Field->new(
            $itemfield, '', '',
            $lost_sf => '1',
        ),
    );
    my (undef, undef, $itemnumber) = AddItemFromMarc($item_record,
        $biblio->biblionumber);

    my $item = Koha::Items->find($itemnumber);
    is( $item->itemlost, 1, 'itemlost picked from the item marc');

    $item->new_status("this is something")->store;

    my $updated_item_record = MARC::Record->new;
    $updated_item_record->append_fields(
        MARC::Field->new(
            $itemfield, '', '',
            'y' => $itemtype->itemtype,
        )
    );

    my $updated_item = ModItemFromMarc($updated_item_record, $biblio->biblionumber, $itemnumber);
    is( $updated_item->{itemlost}, 0, 'itemlost should have been reset to the default value in DB' );
    is( $updated_item->{new_status}, "this is something", "Non mapped field has not been reset" );
    is( Koha::Items->find($itemnumber)->new_status, "this is something" );

    subtest 'cn_sort' => sub {
        plan tests => 3;

        my $item = $builder->build_sample_item;
        $item->set({ cn_source => 'ddc', itemcallnumber => 'xxx' })->store;
        is( $item->cn_sort, 'XXX', 'init values set are expected' );

        my $marc = C4::Items::Item2Marc( $item->get_from_storage->unblessed, $item->biblionumber );
        ModItemFromMarc( $marc, $item->biblionumber, $item->itemnumber );
        is( $item->get_from_storage->cn_sort, 'XXX', 'cn_sort has not been updated' );

        $marc = C4::Items::Item2Marc( { %{$item->unblessed}, itemcallnumber => 'yyy' }, $item->biblionumber );
        ModItemFromMarc( $marc, $item->biblionumber, $item->itemnumber );
        is( $item->get_from_storage->cn_sort, 'YYY', 'cn_sort has been updated' );
    };

    subtest 'permanent_location' => sub {
        plan tests => 10;

        # Make sure items.permanent_location is not mapped
        Koha::MarcSubfieldStructures->search(
            {
                frameworkcode => q{},
                kohafield     => 'items.permanent_location',
            }
        )->delete;
        Koha::MarcSubfieldStructures->search(
            {
                frameworkcode => q{},
                tagfield     => '952',
                tagsubfield     => 'C',
            }
        )->delete;
        Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

        my $item = $builder->build_sample_item;

        # By default, setting location to something new should set permanent location to the same thing
        # with the usual exceptions
        $item->set({ location => 'A', permanent_location => 'A' })->store;
        is( $item->location, 'A', 'initial location set as expected' );
        is( $item->permanent_location, 'A', 'initial permanent location set as expected' );

        $item->location('B');
        my $marc = C4::Items::Item2Marc( $item->unblessed, $item->biblionumber );
        ModItemFromMarc( $marc, $item->biblionumber, $item->itemnumber );

        $item = $item->get_from_storage;
        is( $item->location, 'B', 'new location set as expected' );
        is( $item->permanent_location, 'B', 'new permanent location set as expected' );

        # Added a marc mapping for permanent location, allows it to be edited independently
        my $mapping = Koha::MarcSubfieldStructure->new(
            {
                frameworkcode => q{},
                tagfield      => '952',
                tagsubfield   => 'C',
                kohafield     => 'items.permanent_location',
                repeatable    => 0,
                tab           => 10,
                hidden        => 0,
            }
        )->store;
        Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

        # Now if we change location, and also pass in a permanent location
        # the permanent_location will not be overwritten by location
        $item->location('C');
        $marc = C4::Items::Item2Marc( $item->unblessed, $item->biblionumber );
        ModItemFromMarc( $marc, $item->biblionumber, $item->itemnumber );
        $item = $item->get_from_storage;
        is( $item->location, 'C', 'next new location set as expected' );
        is( $item->permanent_location, 'B', 'permanent location remains unchanged as expected' );

        $item->permanent_location(undef)->more_subfields_xml(undef)->store;
        # Clear values from the DB
        $item = $item->get_from_storage;

        # Update the location
        $item->location('D');
        $marc = C4::Items::Item2Marc( $item->unblessed, $item->biblionumber );
        # Remove the permanent_location field from the form
        $marc->field('952')->delete_subfield("C");
        ModItemFromMarc( $marc, $item->biblionumber, $item->itemnumber );
        $item = $item->get_from_storage;
        is( $item->location, 'D', 'next new location set as expected' );
        is( $item->permanent_location, 'D', 'permanent location is updated if not previously set and no value passed' );

        # Clear values from the DB
        $item->permanent_location(undef)->more_subfields_xml(undef)->store;
        $item = $item->get_from_storage;

        # This time nothing is set, but we pass an empty string
        $item->permanent_location("");
        $item->location('E');
        $marc = C4::Items::Item2Marc( $item->unblessed, $item->biblionumber );
        $marc->field('952')->add_subfields( "C", "" );
        ModItemFromMarc( $marc, $item->biblionumber, $item->itemnumber );
        $item = $item->get_from_storage;
        is( $item->location, 'E', 'next new location set as expected' );
        is( $item->permanent_location, undef, 'permanent location is not updated if previously set as blank string' );
    };

    $schema->storage->txn_rollback;
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
}
