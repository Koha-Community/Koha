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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 41;
use Test::Exception;
use Test::Warn;

use C4::Biblio      qw( AddBiblio ModBiblio ModBiblioMarc );
use C4::Circulation qw( AddIssue AddReturn );
use C4::Reserves    qw( AddReserve );

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Cache::Memory::Lite;
use Koha::Caches;
use Koha::Acquisition::Orders;
use Koha::AuthorisedValueCategories;
use Koha::AuthorisedValues;
use Koha::MarcSubfieldStructures;
use Koha::Exception;

use MARC::Field;
use MARC::Record;

use t::lib::Dates;
use t::lib::TestBuilder;
use t::lib::Mocks;
use Test::MockModule;

BEGIN {
    use_ok('Koha::Biblio');
    use_ok('Koha::Biblios');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'metadata() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $title = 'Oranges and Peaches';

    my $record = MARC::Record->new();
    my $field  = MARC::Field->new( '245', '', '', 'a' => $title );
    $record->append_fields($field);
    my ($biblionumber) = C4::Biblio::AddBiblio( $record, '' );

    my $biblio = Koha::Biblios->find($biblionumber);
    is( ref $biblio, 'Koha::Biblio', 'Found a Koha::Biblio object' );

    my $metadata = $biblio->metadata;
    is( ref $metadata, 'Koha::Biblio::Metadata', 'Method metadata() returned a Koha::Biblio::Metadata object' );

    my $record2 = $metadata->record;
    is( ref $record2, 'MARC::Record', 'Method record() returned a MARC::Record object' );

    is( $record2->field('245')->subfield("a"), $title, 'Title in 245$a matches title from original record object' );

    $schema->storage->txn_rollback;
};

subtest 'hidden_in_opac() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $rules  = { withdrawn => [2] };

    t::lib::Mocks::mock_preference( 'OpacHiddenItemsHidesRecord', 0 );

    ok(
        !$biblio->hidden_in_opac( { rules => $rules } ),
        'Biblio not hidden if there is no item attached (!OpacHiddenItemsHidesRecord)'
    );

    t::lib::Mocks::mock_preference( 'OpacHiddenItemsHidesRecord', 1 );

    ok(
        !$biblio->hidden_in_opac( { rules => $rules } ),
        'Biblio not hidden if there is no item attached (OpacHiddenItemsHidesRecord)'
    );

    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    $item_1->withdrawn(1)->store->discard_changes;
    $item_2->withdrawn(1)->store->discard_changes;

    ok( !$biblio->hidden_in_opac( { rules => $rules } ), 'Biblio not hidden' );

    $item_2->withdrawn(2)->store->discard_changes;
    $biblio->discard_changes;    # refresh

    ok( !$biblio->hidden_in_opac( { rules => $rules } ), 'Biblio not hidden' );

    $item_1->withdrawn(2)->store->discard_changes;
    $biblio->discard_changes;    # refresh

    ok( $biblio->hidden_in_opac( { rules => $rules } ), 'Biblio hidden' );

    t::lib::Mocks::mock_preference( 'OpacHiddenItemsHidesRecord', 0 );
    ok(
        !$biblio->hidden_in_opac( { rules => $rules } ),
        'Biblio hidden (!OpacHiddenItemsHidesRecord)'
    );

    $schema->storage->txn_rollback;
};

subtest 'items() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    is( $biblio->items->count, 0, 'No items, count is 0' );

    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $items = $biblio->items;
    is( ref($items),   'Koha::Items', 'Returns a Koha::Items resultset' );
    is( $items->count, 2,             'Two items in resultset' );

    $schema->storage->txn_rollback;

};

subtest 'bookable_items() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    # bookable items
    my $bookable_item1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );

    # not bookable items
    my $non_bookable_item1 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 0 } );
    my $non_bookable_item2 = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 0 } );

    is( ref( $biblio->bookable_items ), 'Koha::Items', "bookable_items returns a Koha::Items resultset" );
    is( $biblio->bookable_items->count, 1,             "bookable_items returns the correct number of items" );
    is(
        $biblio->bookable_items->next->itemnumber, $bookable_item1->itemnumber,
        "bookable_items returned the correct item"
    );

    $schema->storage->txn_rollback;
};

subtest 'get_coins and get_openurl' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $biblio  = $builder->build_sample_biblio(
        {
            title  => 'Title 1',
            author => 'Author 1'
        }
    );
    is(
        $biblio->get_coins,
        'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft.genre=book&amp;rft.btitle=Title%201&amp;rft.au=Author%201',
        'GetCOinsBiblio returned right metadata'
    );

    my $record = MARC::Record->new();
    $record->append_fields(
        MARC::Field->new( '100', '', '', 'a' => 'Author 2' ),
        MARC::Field->new( '880', '', '', 'a' => 'Something' )
    );
    my ($biblionumber) = C4::Biblio::AddBiblio( $record, '' );
    my $biblio_no_title = Koha::Biblios->find($biblionumber);
    is(
        $biblio_no_title->get_coins,
        'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft.genre=book&amp;rft.au=Author%202',
        'GetCOinsBiblio returned right metadata if biblio does not have a title'
    );

    t::lib::Mocks::mock_preference( "OpenURLResolverURL", "https://koha.example.com/" );
    is(
        $biblio->get_openurl,
        'https://koha.example.com/?ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft.genre=book&amp;rft.btitle=Title%201&amp;rft.au=Author%201',
        'Koha::Biblio->get_openurl returned right URL'
    );

    t::lib::Mocks::mock_preference( "OpenURLResolverURL", "https://koha.example.com/?client_id=ci1" );
    is(
        $biblio->get_openurl,
        'https://koha.example.com/?client_id=ci1&amp;ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft.genre=book&amp;rft.btitle=Title%201&amp;rft.au=Author%201',
        'Koha::Biblio->get_openurl returned right URL'
    );

    $schema->storage->txn_rollback;
};

subtest 'is_serial() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    $biblio->serial(1)->store->discard_changes;
    ok( $biblio->is_serial, 'Bibliographic record is serial' );

    $biblio->serial(0)->store->discard_changes;
    ok( !$biblio->is_serial, 'Bibliographic record is not serial' );

    my $record = $biblio->metadata->record;
    $record->leader('00142nas a22     7a 4500');
    ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    ok( $biblio->is_serial, 'Bibliographic record is serial' );

    $schema->storage->txn_rollback;
};

subtest 'pickup_locations() tests' => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    Koha::CirculationRules->search->delete;
    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                reservesallowed => 25,
            }
        }
    );

    my $root1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );
    my $root2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );
    my $root3 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1 } } );

    my $library1 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'zzz' } } );
    my $library2 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'AAA' } } );
    my $library3 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 0, branchname => 'FFF' } } );
    my $library4 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'CCC' } } );
    my $library5 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'eee' } } );
    my $library6 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'BBB' } } );
    my $library7 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'DDD' } } );
    my $library8 = $builder->build_object(
        { class => 'Koha::Libraries', value => { pickup_location => 0, branchname => 'GGG' } } );

    our @branchcodes = map { $_->branchcode }
        ( $library1, $library2, $library3, $library4, $library5, $library6, $library7, $library8 );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library1->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_home_library',
                hold_fulfillment_policy => 'any',
                returnbranch            => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_local_hold_group',
                hold_fulfillment_policy => 'holdgroup',
                returnbranch            => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library3->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_local_hold_group',
                hold_fulfillment_policy => 'patrongroup',
                returnbranch            => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library4->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_any_library',
                hold_fulfillment_policy => 'holdingbranch',
                returnbranch            => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library5->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_any_library',
                hold_fulfillment_policy => 'homebranch',
                returnbranch            => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library6->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_home_library',
                hold_fulfillment_policy => 'holdgroup',
                returnbranch            => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library7->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_local_hold_group',
                hold_fulfillment_policy => 'holdingbranch',
                returnbranch            => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library8->branchcode,
            itemtype   => undef,
            rules      => {
                holdallowed             => 'from_any_library',
                hold_fulfillment_policy => 'patrongroup',
                returnbranch            => 'any'
            }
        }
    );

    my $group1_1 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library1->branchcode } }
    );
    my $group1_2 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library2->branchcode } }
    );

    my $group2_3 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library3->branchcode } }
    );
    my $group2_4 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library4->branchcode } }
    );

    my $group3_5 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library5->branchcode } }
    );
    my $group3_6 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library6->branchcode } }
    );
    my $group3_7 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library7->branchcode } }
    );
    my $group3_8 = $builder->build_object(
        { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library8->branchcode } }
    );

    my $biblio1 = $builder->build_sample_biblio( { title => '1' } );
    my $biblio2 = $builder->build_sample_biblio( { title => '2' } );

    throws_ok { $biblio1->pickup_locations }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown on missing parameter';

    is( $@->parameter, 'patron', 'Exception param correctly set' );

    my $item1_1 = $builder->build_sample_item(
        {
            biblionumber  => $biblio1->biblionumber,
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
        }
    )->store;

    my $item1_3 = $builder->build_sample_item(
        {
            biblionumber  => $biblio1->biblionumber,
            homebranch    => $library3->branchcode,
            holdingbranch => $library4->branchcode,
        }
    )->store;

    my $item1_7 = $builder->build_sample_item(
        {
            biblionumber  => $biblio1->biblionumber,
            homebranch    => $library7->branchcode,
            holdingbranch => $library4->branchcode,
        }
    )->store;

    my $item2_2 = $builder->build_sample_item(
        {
            biblionumber  => $biblio2->biblionumber,
            homebranch    => $library2->branchcode,
            holdingbranch => $library1->branchcode,
        }
    )->store;

    my $item2_4 = $builder->build_sample_item(
        {
            biblionumber  => $biblio2->biblionumber,
            homebranch    => $library4->branchcode,
            holdingbranch => $library3->branchcode,
        }
    )->store;

    my $item2_6 = $builder->build_sample_item(
        {
            biblionumber  => $biblio2->biblionumber,
            homebranch    => $library6->branchcode,
            holdingbranch => $library4->branchcode,
        }
    )->store;

    my $patron1 = $builder->build_object(
        { class => 'Koha::Patrons', value => { firstname => '1', branchcode => $library1->branchcode } } );
    my $patron8 = $builder->build_object(
        { class => 'Koha::Patrons', value => { firstname => '8', branchcode => $library8->branchcode } } );

    my $results = {
        "ItemHomeLibrary-1-1" => 6,
        "ItemHomeLibrary-1-8" => 1,
        "ItemHomeLibrary-2-1" => 2,
        "ItemHomeLibrary-2-8" => 0,
        "PatronLibrary-1-1"   => 6,
        "PatronLibrary-1-8"   => 3,
        "PatronLibrary-2-1"   => 0,
        "PatronLibrary-2-8"   => 3,
    };

    my $items_results = {
        "ItemHomeLibrary-1-1" => {
            $library1->branchcode => [ $item1_1->itemnumber ],
            $library2->branchcode => [ $item1_1->itemnumber ],
            $library4->branchcode => [ $item1_1->itemnumber ],
            $library5->branchcode => [ $item1_1->itemnumber ],
            $library6->branchcode => [ $item1_1->itemnumber ],
            $library7->branchcode => [ $item1_1->itemnumber ]
        },
        "ItemHomeLibrary-1-8" => {
            $library4->branchcode => [ $item1_7->itemnumber ],
        },
        "ItemHomeLibrary-2-1" => {
            $library1->branchcode => [ $item2_2->itemnumber ],
            $library2->branchcode => [ $item2_2->itemnumber ],
        },
        "ItemHomeLibrary-2-8" => {},
        "PatronLibrary-1-1"   => {
            $library1->branchcode => [ $item1_1->itemnumber ],
            $library2->branchcode => [ $item1_1->itemnumber ],
            $library4->branchcode => [ $item1_1->itemnumber ],
            $library5->branchcode => [ $item1_1->itemnumber ],
            $library6->branchcode => [ $item1_1->itemnumber ],
            $library7->branchcode => [ $item1_1->itemnumber ]
        },
        "PatronLibrary-1-8" => {
            $library5->branchcode => [ $item1_1->itemnumber, $item1_3->itemnumber, $item1_7->itemnumber ],
            $library6->branchcode => [ $item1_1->itemnumber, $item1_3->itemnumber, $item1_7->itemnumber ],
            $library7->branchcode => [ $item1_1->itemnumber, $item1_3->itemnumber, $item1_7->itemnumber ],
        },
        "PatronLibrary-2-1" => {},
        "PatronLibrary-2-8" => {
            $library5->branchcode => [ $item2_2->itemnumber, $item2_4->itemnumber, $item2_6->itemnumber ],
            $library6->branchcode => [ $item2_2->itemnumber, $item2_4->itemnumber, $item2_6->itemnumber ],
            $library7->branchcode => [ $item2_2->itemnumber, $item2_4->itemnumber, $item2_6->itemnumber ],
        }
    };

    sub _doTest {
        my ( $cbranch, $biblio, $patron, $results, $items_results ) = @_;
        t::lib::Mocks::mock_preference( 'ReservesControlBranch', $cbranch );

        my $pl = $biblio->pickup_locations( { patron => $patron } );

        # Filter to just test branches
        my @pl = map {
            my $pickup_location = $_;
            grep { $pickup_location->branchcode eq $_ } @branchcodes
        } $pl->as_list;

        ok(
            scalar(@pl) == $results->{ $cbranch . '-' . $biblio->title . '-' . $patron->firstname },
            'ReservesControlBranch: '
                . $cbranch
                . ', biblio'
                . $biblio->title
                . ', patron'
                . $patron->firstname
                . ' should return '
                . $results->{ $cbranch . '-' . $biblio->title . '-' . $patron->firstname }
                . ' and returns '
                . scalar(@pl)
        );

        my %filtered_location_items = map { $_ => $pl->{_pickup_location_items}->{$_} }
            grep { exists $pl->{_pickup_location_items}->{$_} } @branchcodes;

        is_deeply(
            \%filtered_location_items, \%{ $items_results->{ $cbranch . '-'
                        . $biblio->title . '-'
                        . $patron->firstname } }, 'Items per location correctly cached in resultset'
        );
    }

    foreach my $cbranch ( 'ItemHomeLibrary', 'PatronLibrary' ) {
        my $cache = Koha::Cache::Memory::Lite->get_instance();
        $cache->flush();    # needed since we change ReservesControlBranch
        foreach my $biblio ( $biblio1, $biblio2 ) {
            foreach my $patron ( $patron1, $patron8 ) {
                _doTest( $cbranch, $biblio, $patron, $results, $items_results );
            }
        }
    }

    my @pl_names      = map { $_->branchname } $biblio1->pickup_locations( { patron => $patron1 } )->as_list;
    my $pl_ori_str    = join( '|', @pl_names );
    my $pl_sorted_str = join( '|', sort { lc($a) cmp lc($b) } @pl_names );
    ok(
        $pl_ori_str eq $pl_sorted_str,
        'Libraries must be sorted by name'
    );
    $schema->storage->txn_rollback;
};

subtest 'to_api() tests' => sub {

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $biblioitem_api = $biblio->biblioitem->to_api;
    my $biblio_api     = $biblio->to_api;

    plan tests => ( scalar keys %{$biblioitem_api} ) + 4;

    foreach my $key ( keys %{$biblioitem_api} ) {
        if ( $key eq 'timestamp' ) {
            t::lib::Dates::compare(
                $biblio_api->{$key}, $biblioitem_api->{$key},
                "$key is added to the biblio object"
            );
        }
        is( $biblio_api->{$key}, $biblioitem_api->{$key}, "$key is added to the biblio object" );
    }

    $biblio_api = $biblio->to_api( { embed => { items => {} } } );
    is_deeply( $biblio_api->{items}, [ $item->to_api ], 'Item correctly embedded' );

    $biblio->biblioitem->delete();
    throws_ok { $biblio->to_api }
    'Koha::Exceptions::RelatedObjectNotFound',
        'Exception thrown if the biblioitem accessor returns undef';
    is( $@->class,    'Koha::Biblioitem' );
    is( $@->accessor, 'biblioitem' );

    $schema->storage->txn_rollback;
};

subtest 'bookings() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    is( ref( $biblio->bookings ), 'Koha::Bookings', 'Return type is correct' );

    is_deeply(
        $biblio->bookings->unblessed,
        [],
        '->bookings returns an empty Koha::Bookings resultset'
    );

    my $booking = $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => { biblio_id => $biblio->biblionumber }
        }
    );

    my $bookings = $biblio->bookings->unblessed;

    is_deeply(
        $biblio->bookings->unblessed,
        [ $booking->unblessed ],
        '->bookings returns the related Koha::Booking objects'
    );

    $schema->storage->txn_rollback;
};

subtest 'merge of records' => sub {
    plan tests => 9;

    subtest 'move items' => sub {
        plan tests => 9;
        $schema->storage->txn_begin;

        # 3 items from 3 different biblio records
        my $item1 = $builder->build_sample_item;
        my $item2 = $builder->build_sample_item;
        my $item3 = $builder->build_sample_item;

        my $biblio1 = $item1->biblio;
        my $biblio2 = $item2->biblio;
        my $biblio3 = $item3->biblio;

        my $pre_merged_rs = Koha::Biblios->search(
            { biblionumber => [ $biblio1->biblionumber, $biblio2->biblionumber, $biblio3->biblionumber ] } );
        is( $pre_merged_rs->count, 3, '3 biblios exist' );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber, $biblio3->biblionumber ] ) } q{};
        is( $biblio1->items->count, 3, "After merge we have 3 items on first record" );

        is( ref( $biblio1->get_from_storage ), 'Koha::Biblio', 'biblio record 1 still exists' );
        is( $biblio2->get_from_storage,        undef,          'biblio record 2 no longer exists' );
        is( $biblio3->get_from_storage,        undef,          'biblio record 3 no longer exists' );

        is( $item1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $item2->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $item3->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move holds' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $hold1 =
            $builder->build_object( { class => 'Koha::Holds', value => { biblionumber => $biblio1->biblionumber } } );
        my $hold2 =
            $builder->build_object( { class => 'Koha::Holds', value => { biblionumber => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $hold1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $hold2->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move item groups' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $ig1 = $builder->build_object(
            { class => 'Koha::Biblio::ItemGroups', value => { biblio_id => $biblio1->biblionumber } } );
        my $ig2 = $builder->build_object(
            { class => 'Koha::Biblio::ItemGroups', value => { biblio_id => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $ig1->get_from_storage->biblio_id, $biblio1->biblionumber );
        is( $ig2->get_from_storage->biblio_id, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move article requests' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $ar1 = $builder->build_object(
            { class => 'Koha::ArticleRequests', value => { biblionumber => $biblio1->biblionumber } } );
        my $ar2 = $builder->build_object(
            { class => 'Koha::ArticleRequests', value => { biblionumber => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $ar1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $ar2->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move subscriptions' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $sub1 = $builder->build_object(
            { class => 'Koha::Subscriptions', value => { biblionumber => $biblio1->biblionumber } } );
        my $sub2 = $builder->build_object(
            { class => 'Koha::Subscriptions', value => { biblionumber => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $sub1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $sub2->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move serials' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $serial1 =
            $builder->build_object( { class => 'Koha::Serials', value => { biblionumber => $biblio1->biblionumber } } );
        my $serial2 =
            $builder->build_object( { class => 'Koha::Serials', value => { biblionumber => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $serial1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $serial2->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move subscription history' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $sh1 = $builder->build_object(
            { class => 'Koha::Subscription::Histories', value => { biblionumber => $biblio1->biblionumber } } );
        my $sh2 = $builder->build_object(
            { class => 'Koha::Subscription::Histories', value => { biblionumber => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $sh1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $sh2->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move suggestions' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $suggestion1 = $builder->build_object(
            { class => 'Koha::Suggestions', value => { biblionumber => $biblio1->biblionumber } } );
        my $suggestion2 = $builder->build_object(
            { class => 'Koha::Suggestions', value => { biblionumber => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $suggestion1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $suggestion2->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

    subtest 'move orders' => sub {
        plan tests => 3;
        $schema->storage->txn_begin;

        my $biblio1 = $builder->build_sample_biblio;
        my $biblio2 = $builder->build_sample_biblio;

        my $order1 = $builder->build_object(
            { class => 'Koha::Acquisition::Orders', value => { biblionumber => $biblio1->biblionumber } } );
        my $order2 = $builder->build_object(
            { class => 'Koha::Acquisition::Orders', value => { biblionumber => $biblio2->biblionumber } } );

        warning_like { $biblio1->merge_with( [ $biblio2->biblionumber ] ) } q{};

        is( $order1->get_from_storage->biblionumber, $biblio1->biblionumber );
        is( $order2->get_from_storage->biblionumber, $biblio1->biblionumber );

        $schema->storage->txn_rollback;
    };

};

subtest 'suggestions() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    is( ref( $biblio->suggestions ), 'Koha::Suggestions', 'Return type is correct' );

    is_deeply(
        $biblio->suggestions->unblessed,
        [],
        '->suggestions returns an empty Koha::Suggestions resultset'
    );

    my $suggestion = $builder->build_object(
        {
            class => 'Koha::Suggestions',
            value => { biblionumber => $biblio->biblionumber }
        }
    );

    my $suggestions = $biblio->suggestions->unblessed;

    is_deeply(
        $biblio->suggestions->unblessed,
        [ $suggestion->unblessed ],
        '->suggestions returns the related Koha::Suggestion objects'
    );

    $schema->storage->txn_rollback;
};

subtest 'get_marc_components() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my ($host_bibnum) = C4::Biblio::AddBiblio( host_record(), '' );
    my $host_biblio = Koha::Biblios->find($host_bibnum);
    t::lib::Mocks::mock_preference( 'SearchEngine', 'Zebra' );
    my $search_mod = Test::MockModule->new('Koha::SearchEngine::Zebra::Search');
    $search_mod->mock( 'search_compat', \&search_component_record2 );

    my $components = $host_biblio->get_marc_components;
    is( ref($components), 'ARRAY', 'Return type is correct' );

    is_deeply(
        $components,
        [],
        '->get_marc_components returns an empty ARRAY'
    );

    $search_mod->unmock('search_compat');
    $search_mod->mock( 'search_compat', \&search_component_record1 );
    my $component_record = component_record1()->as_xml();

    is_deeply(
        $host_biblio->get_marc_components,
        [$component_record],
        '->get_marc_components returns the related component part record'
    );
    $search_mod->unmock('search_compat');

    $search_mod->mock(
        'search_compat',
        sub { Koha::Exception->throw("error searching analytics") }
    );
    warning_like { $components = $host_biblio->get_marc_components }
    qr{Warning from search_compat: .* 'error searching analytics'};

    is_deeply(
        $host_biblio->object_messages,
        [
            {
                type    => 'error',
                message => 'component_search',
                payload => "Exception 'Koha::Exception' thrown 'error searching analytics'\n"
            }
        ]
    );
    $search_mod->unmock('search_compat');

    $schema->storage->txn_rollback;
};

subtest 'get_components_query' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    my $biblio       = $builder->build_sample_biblio();
    my $biblionumber = $biblio->biblionumber;
    my $record       = $biblio->metadata->record;

    foreach my $engine ( 'Zebra', 'Elasticsearch' ) {
        t::lib::Mocks::mock_preference( 'SearchEngine', $engine );

        t::lib::Mocks::mock_preference( 'UseControlNumber',   '0' );
        t::lib::Mocks::mock_preference( 'ComponentSortField', 'author' );
        t::lib::Mocks::mock_preference( 'ComponentSortOrder', 'za' );
        my ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        is( $comp_query_str, 'Host-item:("Some boring read")', "$engine: UseControlNumber disabled" );
        is( $comp_sort,      "author_za",                      "$engine: UseControlNumber disabled sort is correct" );

        t::lib::Mocks::mock_preference( 'UseControlNumber',   '1' );
        t::lib::Mocks::mock_preference( 'ComponentSortOrder', 'az' );
        my $marc_001_field = MARC::Field->new( '001', $biblionumber );
        $record->append_fields($marc_001_field);
        C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
        $biblio = Koha::Biblios->find( $biblio->biblionumber );

        ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        is(
            $comp_query_str, "(rcn:\"$biblionumber\" AND (bib-level:a OR bib-level:b))",
            "$engine: UseControlNumber enabled without MarcOrgCode"
        );
        is( $comp_sort, "author_az", "$engine: UseControlNumber enabled without MarcOrgCode sort is correct" );

        my $marc_003_field = MARC::Field->new( '003', 'OSt' );
        $record->append_fields($marc_003_field);
        C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
        $biblio = Koha::Biblios->find( $biblio->biblionumber );

        t::lib::Mocks::mock_preference( 'ComponentSortField', 'title' );
        t::lib::Mocks::mock_preference( 'ComponentSortOrder', 'asc' );
        ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        is(
            $comp_query_str,
            "(((rcn:\"$biblionumber\" AND cni:\"OSt\") OR rcn:\"OSt $biblionumber\") AND (bib-level:a OR bib-level:b))",
            "$engine: UseControlNumber enabled with MarcOrgCode"
        );
        is( $comp_sort, "title_asc", "$engine: UseControlNumber enabled with MarcOrgCode sort if correct" );
        $record->delete_field($marc_003_field);
    }

    $schema->storage->txn_rollback;

};

subtest 'get_volumes_query' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio       = $builder->build_sample_biblio();
    my $biblionumber = $biblio->biblionumber;
    my $record       = $biblio->metadata->record;

    # Ensure our mocked record is captured as a set or monographic series
    my $ldr = $record->leader();
    substr( $ldr, 19, 1 ) = 'a';
    $record->leader($ldr);
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    t::lib::Mocks::mock_preference( 'UseControlNumber', '0' );
    is(
        $biblio->get_volumes_query,
        "(title-series,phr:(\"Some boring read\") OR Host-item,phr:(\"Some boring read\") NOT (bib-level:a OR bib-level:b))",
        "UseControlNumber disabled"
    );

    t::lib::Mocks::mock_preference( 'UseControlNumber', '1' );
    my $marc_001_field = MARC::Field->new( '001', $biblionumber );
    $record->append_fields($marc_001_field);
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    is(
        $biblio->get_volumes_query, "(rcn:$biblionumber NOT (bib-level:a OR bib-level:b))",
        "UseControlNumber enabled without MarcOrgCode"
    );

    my $marc_003_field = MARC::Field->new( '003', 'OSt' );
    $record->append_fields($marc_003_field);
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    is(
        $biblio->get_volumes_query,
        "(((rcn:$biblionumber AND cni:OSt) OR rcn:\"OSt $biblionumber\") NOT (bib-level:a OR bib-level:b))",
        "UseControlNumber enabled with MarcOrgCode"
    );

    $schema->storage->txn_rollback;

};

subtest 'generate_marc_host_field' => sub {
    plan tests => 36;

    $schema->storage->txn_begin;

    # Set up MARC21 tests
    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    # 1. Complete MARC21 record test
    my $record = MARC::Record->new();
    $record->leader('00000nam a22000007a 4500');
    $record->append_fields(
        MARC::Field->new( '001', '12345' ),
        MARC::Field->new( '003', 'NB' ),
        MARC::Field->new( '020', '',  '',  'a' => '978-3-16-148410-0' ),
        MARC::Field->new( '022', '',  '',  'a' => '1234-5678' ),
        MARC::Field->new( '100', '1', '',  'a' => 'Smith, John',  'e' => 'author',   '9' => 'xyz', '4' => 'aut' ),
        MARC::Field->new( '245', '1', '0', 'a' => 'The Title',    'b' => 'Subtitle', 'c' => 'John Smith' ),
        MARC::Field->new( '250', '',  '',  'a' => '2nd edition',  'b' => 'revised' ),
        MARC::Field->new( '260', '',  '',  'a' => 'New York',     'b' => 'Publisher', 'c' => '2023' ),
        MARC::Field->new( '830', '',  '',  'a' => 'Series Title', 'v' => 'vol. 2',    'x' => '2345-6789' )
    );
    my ($biblio_id) = AddBiblio( $record, qw{} );
    my $biblio = Koha::Biblios->find($biblio_id);

    # Test MARC21 with UseControlNumber off
    t::lib::Mocks::mock_preference( 'UseControlNumber', 0 );
    my $link = $biblio->generate_marc_host_field();

    # Test standard MARC21 field
    is( ref($link),          'MARC::Field', 'Returns a MARC::Field object' );
    is( $link->tag(),        '773',         'Field tag is 773 for MARC21' );
    is( $link->indicator(1), '0',           'First indicator is 0' );
    is( $link->indicator(2), ' ',           'Second indicator is blank' );

    # Check all subfields
    is( $link->subfield('7'), 'p1am',        'Subfield 7 correctly formed' );
    is( $link->subfield('a'), 'Smith, John', 'Subfield a contains author from 100a' );
    is(
        $link->subfield('t'), 'The Title Subtitle',
        'Subfield t contains title without trailing punctuation from 245ab'
    );
    is( $link->subfield('b'), '2nd edition revised',     'Subfield b contains edition info from 250ab' );
    is( $link->subfield('d'), 'New York Publisher 2023', 'Subfield d contains publication info from 260abc' );
    is( $link->subfield('k'), 'Series Title, ISSN 2345-6789 ; vol. 2', 'Subfield k contains series info from 830' );
    is( $link->subfield('x'), '1234-5678',                             'Subfield x contains ISSN from 022a' );
    is( $link->subfield('z'), '978-3-16-148410-0',                     'Subfield z contains ISBN from 020a' );
    is( $link->subfield('w'), undef, 'Subfield w is undefined when UseControlNumber is disabled' );

    # Test with UseControlNumber enabled
    t::lib::Mocks::mock_preference( 'UseControlNumber', '1' );
    $link = $biblio->generate_marc_host_field();
    is(
        $link->subfield('w'), '(NB)12345',
        'Subfield w contains control number with source when UseControlNumber is enabled'
    );

    # 245 punctuation handling tests
    # Trailing slash
    $record->field('245')->update( a => 'A title /', b => '', c => '', 'ind2' => '0' );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);
    $link   = $biblio->generate_marc_host_field();
    is( $link->subfield('t'), 'A title', "Trailing slash is removed from 245a" );

    # Trailing period
    $record->field('245')->update( a => 'Another title.', 'ind2' => '0' );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);
    $link   = $biblio->generate_marc_host_field();
    is( $link->subfield('t'), 'Another title', "Trailing period is removed from 245a" );

    # Offset from indicator 2 = 4
    $record->field('245')->update( a => 'The offset title', 'ind2' => '4' );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);
    $link   = $biblio->generate_marc_host_field();
    is( $link->subfield('t'), 'Offset title', "Title offset applied from indicator 2" );

    # Capitalization after offset
    $record->field('245')->update( a => 'the capital test', 'ind2' => '0' );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);
    $link   = $biblio->generate_marc_host_field();
    is( $link->subfield('t'), 'The capital test', "Title is capitalized after indicator offset" );

    # 240 uniform title tests
    $record->append_fields( MARC::Field->new( '240', '1', '0', 'a' => 'Bible. English', 'l' => 'English' ) );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);
    $link   = $biblio->generate_marc_host_field();
    is( $link->subfield('s'), 'Bible. English', "Subfield s contains uniform title from 240a" );

    # 260/264 handling tests
    $record->append_fields(
        MARC::Field->new( '264', '', '', a => 'Publication 264' ),
    );
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    $link = $biblio->generate_marc_host_field();
    is(
        $link->subfield('d'), 'Publication 264',
        'MARC::Field->subfield(d) returns content from 264 in preference to 260'
    );

    $record->append_fields(
        MARC::Field->new( '264', '3', '', a => 'Publication 264', b => 'Preferred' ),
    );
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    $link = $biblio->generate_marc_host_field();
    is(
        $link->subfield('d'), 'Publication 264 Preferred',
        'MARC::Field->subfield(d) returns content from 264 with indicator 1 = 3 in preference to 264 without'
    );

    # 2. Test MARC21 with corporate author (110)
    my $record_corporate = MARC::Record->new();
    $record_corporate->leader('00000nam a22000007a 4500');
    $record_corporate->append_fields(
        MARC::Field->new( '110', '2', '',  'a' => 'Corporate Author', 'e' => 'sponsor', '9' => 'xyz', '4' => 'spn' ),
        MARC::Field->new( '245', '1', '0', 'a' => 'The Title' )
    );
    ($biblio_id) = AddBiblio( $record_corporate, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);

    $link = $biblio->generate_marc_host_field();
    is( $link->subfield('7'), 'c2am',             'Subfield 7 correctly formed for corporate author' );
    is( $link->subfield('a'), 'Corporate Author', 'Subfield a contains corporate author' );

    # 3. Test MARC21 with meeting name (111)
    my $record_meeting = MARC::Record->new();
    $record_meeting->leader('00000nam a22000007a 4500');
    $record_meeting->append_fields(
        MARC::Field->new( '111', '2', '',  'a' => 'Conference Name', 'j' => 'relator', '9' => 'xyz', '4' => 'spn' ),
        MARC::Field->new( '245', '1', '0', 'a' => 'The Title' )
    );
    ($biblio_id) = AddBiblio( $record_meeting, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);

    $link = $biblio->generate_marc_host_field();
    is( $link->subfield('7'), 'm2am', 'Subfield 7 correctly formed for meeting name' );

    # 4. Test MARC21 with minimal record
    my $record_minimal = MARC::Record->new();
    $record_minimal->leader('00000nam a22000007a 4500');
    $record_minimal->append_fields( MARC::Field->new( '245', '0', '0', 'a' => 'Title Only' ) );
    ($biblio_id) = AddBiblio( $record_minimal, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);

    $link = $biblio->generate_marc_host_field();
    is( $link->subfield('7'), 'nnam', 'Subfield 7 correctly formed with no main entry' );

    # 5. Test UNIMARC
    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );
    $biblio = $builder->build_sample_biblio();
    my $record_unimarc = MARC::Record->new();
    $record_unimarc->append_fields(
        MARC::Field->new( '001', '54321' ),
        MARC::Field->new( '010', '', '', 'a' => '978-0-12-345678-9' ),
        MARC::Field->new( '011', '', '', 'a' => '2345-6789' ),
        MARC::Field->new( '200', '', '', 'a' => 'UNIMARC Title' ),
        MARC::Field->new( '205', '', '', 'a' => 'Third edition' ),
        MARC::Field->new( '210', '', '', 'a' => 'Paris', 'd' => '2023' ),
        MARC::Field->new( '700', '', '', 'a' => 'Doe',   'b' => 'Jane' ),
        MARC::Field->new( '856', '', '', 'u' => 'http://example.com' )
    );
    ($biblio_id) = AddBiblio( $record_unimarc, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);

    $link = $biblio->generate_marc_host_field();

    is( ref($link),          'MARC::Field', 'Returns a MARC::Field object for UNIMARC' );
    is( $link->tag(),        '461',         'Field tag is 461 for UNIMARC' );
    is( $link->indicator(1), '0',           'First indicator is 0 for UNIMARC' );
    is( $link->indicator(2), ' ',           'Second indicator is blank for UNIMARC' );

    # Check UNIMARC subfields
    is( $link->subfield('a'), 'Doe Jane',      'Subfield a contains author for UNIMARC' );
    is( $link->subfield('t'), 'UNIMARC Title', 'Subfield t contains title for UNIMARC' );
    is( $link->subfield('c'), 'Paris',         'Subfield c contains place of publication for UNIMARC' );
    is( $link->subfield('d'), '2023',          'Subfield d contains date of publication for UNIMARC' );
    is( $link->subfield('0'), '54321',         'Subfield 0 contains control number for UNIMARC' );

    # 6. Test UNIMARC with different author types
    my $record_unimarc_corporate = MARC::Record->new();
    $record_unimarc_corporate->append_fields(
        MARC::Field->new( '710', '', '', 'a' => 'Corporate', 'b' => 'Department' ),
        MARC::Field->new( '200', '', '', 'a' => 'Title' )
    );
    C4::Biblio::ModBiblio( $record_unimarc_corporate, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    $link = $biblio->generate_marc_host_field();
    is( $link->subfield('a'), 'Corporate Department', 'Subfield a contains corporate author for UNIMARC' );

    my $record_unimarc_family = MARC::Record->new();
    $record_unimarc_family->append_fields(
        MARC::Field->new( '720', '', '', 'a' => 'Family', 'b' => 'Name' ),
        MARC::Field->new( '200', '', '', 'a' => 'Title' )
    );
    C4::Biblio::ModBiblio( $record_unimarc_family, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    $link = $biblio->generate_marc_host_field();
    is( $link->subfield('a'), 'Family Name', 'Subfield a contains family name for UNIMARC' );

    $schema->storage->txn_rollback;
    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
};

subtest 'link_marc_host' => sub {
    plan tests => 6;
    $schema->storage->txn_begin;

    my $host = $builder->build_sample_biblio();

    my $child        = $builder->build_sample_biblio();
    my $child_record = $child->metadata->record;

    is( $child_record->field('773'), undef, "773 field is undefined before link_marc_host" );
    $child->link_marc_host( { host => $host->biblionumber } );
    $child->discard_changes;
    $child_record = $child->metadata->record;
    is(
        ref( $child_record->field('773') ), 'MARC::Field',
        '773 field is set after calling link_marc_host({ host => $biblionumber })'
    );

    $child        = $builder->build_sample_biblio();
    $child_record = $child->metadata->record;
    is( $child_record->field('773'), undef, "773 field is undefined before link_marc_host" );
    $child->link_marc_host( { host => $host } );
    $child->discard_changes;
    $child_record = $child->metadata->record;
    is(
        ref( $child_record->field('773') ), 'MARC::Field',
        '773 field is set after calling link_marc_host({ host => $biblio })'
    );

    $child        = $builder->build_sample_biblio();
    $child_record = $child->metadata->record;
    is( $child_record->field('773'), undef, "773 field is undefined before link_marc_host" );
    my $link_field = $host->generate_marc_host_field;
    $child->link_marc_host( { field => $link_field } );
    $child->discard_changes;
    $child_record = $child->metadata->record;
    is(
        ref( $child_record->field('773') ), 'MARC::Field',
        '773 field is set after calling link_marc_host({ field => $link_field })'
    );

    $schema->storage->txn_rollback;
};

subtest '->orders, ->uncancelled_orders and ->acq_status tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    my $orders             = $biblio->orders;
    my $uncancelled_orders = $biblio->uncancelled_orders;

    is( ref($orders), 'Koha::Acquisition::Orders', 'Result type is correct' );
    is(
        $biblio->orders->count, $biblio->uncancelled_orders->count,
        '->orders->count returns the count for the resultset'
    );

    # Add a couple orders
    foreach ( 1 .. 2 ) {
        $builder->build_object(
            {
                class => 'Koha::Acquisition::Orders',
                value => {
                    biblionumber            => $biblio->biblionumber,
                    datecancellationprinted => '2019-12-31',
                    orderstatus             => 'cancelled',
                }
            }
        );
    }

    $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                biblionumber            => $biblio->biblionumber,
                datecancellationprinted => undef,
                orderstatus             => 'ordered',
                quantity                => 1,
                quantityreceived        => 0,
            }
        }
    );

    $orders             = $biblio->orders;
    $uncancelled_orders = $biblio->uncancelled_orders;

    is( ref($orders),             'Koha::Acquisition::Orders', 'Result type is correct' );
    is( ref($uncancelled_orders), 'Koha::Acquisition::Orders', 'Result type is correct' );
    is( $orders->count, $uncancelled_orders->count + 2,        '->uncancelled_orders->count returns the right count' );

    # Check acq status
    is( $biblio->acq_status, 'processing', 'Processing for presence of ordered lines' );
    $orders->filter_by_active->update( { orderstatus => 'new' } );
    is( $biblio->acq_status, 'processing', 'Still processing for presence of new lines' );
    $orders->filter_out_cancelled->update( { orderstatus => 'complete' } );
    is( $biblio->acq_status, 'acquired', 'Acquired: some complete, rest cancelled' );
    $orders->update( { orderstatus => 'cancelled', datecancellationprinted => dt_from_string() } );
    is( $biblio->acq_status, 'cancelled', 'Cancelled for only cancelled lines' );

    $schema->storage->txn_rollback;
};

subtest 'tickets() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio  = $builder->build_sample_biblio();
    my $tickets = $biblio->tickets;
    is( ref($tickets),   'Koha::Tickets', 'Koha::Biblio->tickets should return a Koha::Tickets object' );
    is( $tickets->count, 0, 'Koha::Biblio->tickets should return a count of 0 when there are no related tickets' );

    # Add two tickets
    foreach ( 1 .. 2 ) {
        $builder->build_object(
            {
                class => 'Koha::Tickets',
                value => { biblio_id => $biblio->biblionumber }
            }
        );
    }

    $tickets = $biblio->tickets;
    is( ref($tickets),   'Koha::Tickets', 'Koha::Biblio->tickets should return a Koha::Tickets object' );
    is( $tickets->count, 2,               'Koha::Biblio->tickets should return the correct number of tickets' );

    $schema->storage->txn_rollback;
};

subtest 'serials() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $serials = $biblio->serials;
    is(
        ref($serials), 'Koha::Serials',
        'Koha::Biblio->serials should return a Koha::Serials object'
    );
    is( $serials->count, 0, 'Koha::Biblio->serials should return the correct number of serials' );

    # Add two serials
    foreach ( 1 .. 2 ) {
        $builder->build_object(
            {
                class => 'Koha::Serials',
                value => { biblionumber => $biblio->biblionumber }
            }
        );
    }

    $serials = $biblio->serials;
    is(
        ref($serials), 'Koha::Serials',
        'Koha::Biblio->serials should return a Koha::Serials object'
    );
    is( $serials->count, 2, 'Koha::Biblio->serials should return the correct number of serials' );

    $schema->storage->txn_rollback;
};

subtest 'subscriptions() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $subscriptions = $biblio->subscriptions;
    is(
        ref($subscriptions), 'Koha::Subscriptions',
        'Koha::Biblio->subscriptions should return a Koha::Subscriptions object'
    );
    is( $subscriptions->count, 0, 'Koha::Biblio->subscriptions should return the correct number of subscriptions' );

    # Add two subscriptions
    foreach ( 1 .. 2 ) {
        $builder->build_object(
            {
                class => 'Koha::Subscriptions',
                value => { biblionumber => $biblio->biblionumber }
            }
        );
    }

    $subscriptions = $biblio->subscriptions;
    is(
        ref($subscriptions), 'Koha::Subscriptions',
        'Koha::Biblio->subscriptions should return a Koha::Subscriptions object'
    );
    is( $subscriptions->count, 2, 'Koha::Biblio->subscriptions should return the correct number of subscriptions' );

    $schema->storage->txn_rollback;
};

subtest 'subscription_histories() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $sub_histories = $biblio->subscription_histories;
    is(
        ref($sub_histories), 'Koha::Subscription::Histories',
        'Koha::Biblio->subscription_histories should return a Koha::Subscription::Histories object'
    );
    is(
        $sub_histories->count, 0,
        'Koha::Biblio->subscription_histories should return the correct number of subscription histories'
    );

    # Add two subscription histories
    foreach ( 1 .. 2 ) {
        $builder->build_object(
            {
                class => 'Koha::Subscription::Histories',
                value => { biblionumber => $biblio->biblionumber }
            }
        );
    }

    $sub_histories = $biblio->subscription_histories;
    is(
        ref($sub_histories), 'Koha::Subscription::Histories',
        'Koha::Biblio->subscription_histories should return a Koha::Subscription::Histories object'
    );
    is(
        $sub_histories->count, 2,
        'Koha::Biblio->subscription_histories should return the correct number of subscription histories'
    );

    $schema->storage->txn_rollback;
};

subtest 'get_marc_notes() MARC21 tests' => sub {
    plan tests => 14;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'NotesToHide', '520' );

    my $av = $builder->build_object( { class => 'Koha::AuthorisedValues' } );

    my $biblio = $builder->build_sample_biblio;
    my $record = $biblio->metadata->record;
    $record->append_fields(
        MARC::Field->new( '500', '',  '', a => 'Note1' ),
        MARC::Field->new( '505', '',  '', a => 'Note2', u => 'http://someserver.com' ),
        MARC::Field->new( '520', '',  '', a => 'Note3 skipped' ),
        MARC::Field->new( '541', '0', '', a => 'Note4 skipped on opac' ),
        MARC::Field->new( '544', '',  '', a => 'Note5' ),
        MARC::Field->new( '590', '',  '', a => $av->authorised_value ),
        MARC::Field->new( '545', '',  '', a => 'Invisible on OPAC' ),
    );

    my $mss = Koha::MarcSubfieldStructures->find(
        { tagfield => "590", tagsubfield => "a", frameworkcode => $biblio->frameworkcode } );
    $mss->update( { authorised_value => $av->category } );

    $mss = Koha::MarcSubfieldStructures->find(
        { tagfield => "545", tagsubfield => "a", frameworkcode => $biblio->frameworkcode } );
    $mss->update( { hidden => 1 } );

    my $cache = Koha::Caches->get_instance;
    $cache->clear_from_cache("MarcStructure-0-");
    $cache->clear_from_cache("MarcStructure-1-");
    $cache->clear_from_cache("MarcSubfieldStructure-");
    $cache->clear_from_cache("MarcCodedFields-");

    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    my $notes = $biblio->get_marc_notes;
    is( $notes->[0]->{marcnote}, 'Note1',                 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2',                 'Second note' );
    is( $notes->[2]->{marcnote}, 'http://someserver.com', 'URL separated' );
    is( $notes->[3]->{marcnote}, 'Note4 skipped on opac', "Note shows if not opac (Hidden by Indicator)" );
    is( $notes->[4]->{marcnote}, 'Note5',                 'Fifth note' );
    is(
        $notes->[5]->{marcnote}, $av->lib,
        'Authorised value is correctly parsed to show description rather than code'
    );
    is( $notes->[6]->{marcnote}, 'Invisible on OPAC', 'Note shows if not opac (Hidden by framework)' );
    is( @$notes,                 7,                   'No more notes' );
    $notes = $biblio->get_marc_notes( { opac => 1 } );
    is( $notes->[0]->{marcnote}, 'Note1',                 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2',                 'Second note' );
    is( $notes->[2]->{marcnote}, 'http://someserver.com', 'URL separated' );
    is( $notes->[3]->{marcnote}, 'Note5',                 'Fifth note shows after fourth skipped' );
    is(
        $notes->[4]->{marcnote}, $av->lib_opac,
        'Authorised value is correctly parsed for OPAC to show description rather than code'
    );
    is( @$notes, 5, 'No more notes' );

    $cache->clear_from_cache("MarcStructure-0-");
    $cache->clear_from_cache("MarcStructure-1-");
    $cache->clear_from_cache("MarcSubfieldStructure-");
    $cache->clear_from_cache("MarcCodedFields-");

    $schema->storage->txn_rollback;
};

subtest 'get_marc_notes() UNIMARC tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'NotesToHide', '310' );
    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

    my $biblio = $builder->build_sample_biblio;
    my $record = $biblio->metadata->record;
    $record->append_fields(
        MARC::Field->new( '300', '', '', a => 'Note1' ),
        MARC::Field->new( '300', '', '', a => 'Note2' ),
        MARC::Field->new( '310', '', '', a => 'Note3 skipped' ),
    );
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );
    my $notes = $biblio->get_marc_notes( { marcflavour => 'UNIMARC' } );
    is( $notes->[0]->{marcnote}, 'Note1', 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2', 'Second note' );
    is( @$notes,                 2,       'No more notes' );

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    $schema->storage->txn_rollback;
};

subtest 'host_items() tests' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio( { frameworkcode => '' } );

    t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 1 );
    my $host_items = $biblio->host_items;
    is( ref($host_items),   'Koha::Items' );
    is( $host_items->count, 0 );

    my $item_1      = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $host_item_1 = $builder->build_sample_item;
    my $host_item_2 = $builder->build_sample_item;

    my $record = $biblio->metadata->record;
    $record->append_fields(
        MARC::Field->new(
            '773', '', '',
            9 => $host_item_1->itemnumber,
            9 => $host_item_2->itemnumber
        ),
    );
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio     = $biblio->get_from_storage;
    $host_items = $biblio->host_items;
    is( $host_items->count, 2 );
    is_deeply(
        [ $host_items->get_column('itemnumber') ],
        [ $host_item_1->itemnumber, $host_item_2->itemnumber ]
    );

    my $transfer = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber => $host_item_1->itemnumber,
                frombranch => $host_item_1->holdingbranch,
            }
        }
    );
    ok(
        $host_items->search(
            {},
            {
                join     => 'branchtransfers',
                order_by => 'branchtransfers.daterequested'
            }
        )->as_list,
        "host_items can be used with a join query on itemnumber"
    );
    $transfer->delete;

    t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 0 );
    $host_items = $biblio->host_items;
    is( ref($host_items),   'Koha::Items' );
    is( $host_items->count, 0 );

    subtest 'test host_items param in items()' => sub {
        plan tests => 5;

        t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 1 );

        my $items = $biblio->items;
        is( $items->count, 1, "Without host_items param we only get the items on the biblio" );

        $items = $biblio->items( { host_items => 1 } );
        is( $items->count, 3,             "With param host_items we get the biblio items plus analytics" );
        is( ref($items),   'Koha::Items', "We correctly get an Items object" );
        is_deeply(
            [ $items->get_column('itemnumber') ],
            [ $item_1->itemnumber, $host_item_1->itemnumber, $host_item_2->itemnumber ]
        );

        t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 0 );

        $items = $biblio->items( { host_items => 1 } );
        is(
            $items->count, 1,
            "With host_items param but EasyAnalyticalRecords disabled we only get the items on the biblio"
        );
    };

    $schema->storage->txn_rollback;
};

subtest 'article_requests() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $item   = $builder->build_sample_item;
    my $biblio = $item->biblio;

    my $article_requests = $biblio->article_requests;
    is(
        ref($article_requests), 'Koha::ArticleRequests',
        'In scalar context, type is correct'
    );
    is( $article_requests->count, 0, 'No article requests' );

    foreach my $i ( 0 .. 3 ) {

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        $builder->build_object(
            {
                class => 'Koha::ArticleRequests',
                value => {
                    borrowernumber => $patron->id,
                    biblionumber   => $biblio->id,
                    itemnumber     => $item->id,
                    title          => $biblio->title,

                }
            }
        )->request;
    }

    $article_requests = $biblio->article_requests;
    is( $article_requests->count, 4, '4 article requests' );

    $schema->storage->txn_rollback;
};

subtest 'current_checkouts() and old_checkouts() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $item_1 = $builder->build_sample_item;
    my $item_2 = $builder->build_sample_item( { biblionumber => $item_1->biblionumber } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->id } );

    AddIssue( $patron_1, $item_1->barcode );
    AddIssue( $patron_1, $item_2->barcode );

    AddReturn( $item_1->barcode );
    AddIssue( $patron_2, $item_1->barcode );

    my $biblio            = $item_1->biblio;
    my $current_checkouts = $biblio->current_checkouts;
    my $old_checkouts     = $biblio->old_checkouts;

    is( ref($current_checkouts), 'Koha::Checkouts',      'Type is correct' );
    is( ref($old_checkouts),     'Koha::Old::Checkouts', 'Type is correct' );

    is( $current_checkouts->count, 2, 'Count is correct for current checkouts' );
    is( $old_checkouts->count,     1, 'Count is correct for old checkouts' );

    $schema->storage->txn_rollback;
};

subtest 'get_marc_contributors() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio( { author => 'Main author' } );
    my $record = $biblio->metadata->record;

    # add author information
    my $field = MARC::Field->new( '700', '1', '', 'a' => 'Jefferson, Thomas' );
    $record->append_fields($field);
    $field = MARC::Field->new( '701', '1', '', 'd' => 'Secondary author 2' );
    $record->append_fields($field);

    # get record
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    is( @{ $biblio->get_marc_authors },      3, 'get_marc_authors retrieves correct number of author subfields' );
    is( @{ $biblio->get_marc_contributors }, 2, 'get_marc_contributors retrieves correct number of author subfields' );
    $schema->storage->txn_rollback;
};

subtest 'Recalls tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $item1      = $builder->build_sample_item;
    my $biblio     = $item1->biblio;
    my $branchcode = $item1->holdingbranch;
    my $patron1    = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $branchcode } } );
    my $patron2    = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $branchcode } } );
    my $patron3    = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $branchcode } } );
    my $item2      = $builder->build_object(
        {
            class => 'Koha::Items',
            value => {
                holdingbranch => $branchcode, homebranch => $branchcode, biblionumber => $biblio->biblionumber,
                itype         => $item1->effective_itemtype
            }
        }
    );
    t::lib::Mocks::mock_userenv( { patron => $patron1 } );

    my $recall1 = Koha::Recall->new(
        {
            patron_id         => $patron1->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => $item1->itemnumber,
            expiration_date   => undef,
            item_level        => 1
        }
    )->store;
    my $recall2 = Koha::Recall->new(
        {
            patron_id         => $patron2->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => undef,
            expiration_date   => undef,
            item_level        => 0
        }
    )->store;
    my $recall3 = Koha::Recall->new(
        {
            patron_id         => $patron3->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => $item1->itemnumber,
            expiration_date   => undef,
            item_level        => 1
        }
    )->store;

    my $recalls = $biblio->recalls;
    is( $recalls->count, 3, 'Correctly get number of recalls for biblio' );

    $recall1->set_cancelled;
    $recall2->set_expired( { interface => 'COMMANDLINE' } );

    is( $recalls->count,                    3, 'Correctly get number of recalls for biblio' );
    is( $recalls->filter_by_current->count, 1, 'Correctly get number of active recalls for biblio' );

    t::lib::Mocks::mock_preference( 'UseRecalls', 0 );
    is( $biblio->can_be_recalled( { patron => $patron1 } ), 0, "Can't recall with UseRecalls disabled" );

    t::lib::Mocks::mock_preference( "UseRecalls", 1 );
    $item1->update( { notforloan => 1 } );
    is( $biblio->can_be_recalled( { patron => $patron1 } ), 0, "Can't recall with no available items" );

    $item1->update( { notforloan => 0 } );
    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branchcode,
            categorycode => $patron1->categorycode,
            itemtype     => $item1->effective_itemtype,
            rules        => {
                recalls_allowed    => 0,
                recalls_per_record => 1,
                on_shelf_recalls   => 'all',
            },
        }
    );
    is( $biblio->can_be_recalled( { patron => $patron1 } ), 0, "Can't recall if recalls_allowed = 0" );

    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branchcode,
            categorycode => $patron1->categorycode,
            itemtype     => $item1->effective_itemtype,
            rules        => {
                recalls_allowed    => 1,
                recalls_per_record => 1,
                on_shelf_recalls   => 'all',
            },
        }
    );
    is(
        $biblio->can_be_recalled( { patron => $patron1 } ), 0,
        "Can't recall if patron has more existing recall(s) than recalls_allowed"
    );
    is(
        $biblio->can_be_recalled( { patron => $patron1 } ), 0,
        "Can't recall if patron has more existing recall(s) than recalls_per_record"
    );

    $recall1->set_cancelled;
    C4::Circulation::AddIssue( $patron1, $item2->barcode );
    is(
        $biblio->can_be_recalled( { patron => $patron1 } ), 0,
        "Can't recall if patron has already checked out an item attached to this biblio"
    );

    is(
        $biblio->can_be_recalled( { patron => $patron1 } ), 0,
        "Can't recall if on_shelf_recalls = all and items are still available"
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode   => $branchcode,
            categorycode => $patron1->categorycode,
            itemtype     => $item1->effective_itemtype,
            rules        => {
                recalls_allowed    => 1,
                recalls_per_record => 1,
                on_shelf_recalls   => 'any',
            },
        }
    );
    C4::Circulation::AddReturn( $item2->barcode, $branchcode );
    is( $biblio->can_be_recalled( { patron => $patron1 } ), 0, "Can't recall if no items are checked out" );

    $recall2->set_cancelled;
    C4::Circulation::AddIssue( $patron2, $item2->barcode );
    C4::Circulation::AddIssue( $patron2, $item1->barcode );
    is( $biblio->can_be_recalled( { patron => $patron1 } ), 2, "Can recall two items" );

    $item1->update( { withdrawn => 1 } );
    is( $biblio->can_be_recalled( { patron => $patron1 } ), 1, "Can recall one item" );

    $schema->storage->txn_rollback;
};

subtest 'ill_requests() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $rs = $biblio->ill_requests;
    is( ref($rs), 'Koha::ILL::Requests' );
    is( $rs->count, 0, 'No linked requests' );

    foreach ( 1 .. 10 ) {
        $builder->build_object(
            {
                class => 'Koha::ILL::Requests',
                value => { biblio_id => $biblio->id }
            }
        );
    }

    is( $biblio->ill_requests->count, 10, 'Linked requests are present' );

    $schema->storage->txn_rollback;
};

subtest 'item_groups() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    my @item_groups = $biblio->item_groups->as_list;
    is( scalar(@item_groups), 0, 'Got zero item groups' );

    my $item_group_1 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    @item_groups = $biblio->item_groups->as_list;
    is( scalar(@item_groups), 1,                 'Got one item group' );
    is( $item_groups[0]->id,  $item_group_1->id, 'Got correct item group' );

    my $item_group_2 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    @item_groups = $biblio->item_groups->as_list;
    is( scalar(@item_groups), 2,                 'Got two item groups' );
    is( $item_groups[0]->id,  $item_group_1->id, 'Got correct item group 1' );
    is( $item_groups[1]->id,  $item_group_2->id, 'Got correct item group 2' );

    $schema->storage->txn_rollback;
};

subtest 'normalized_isbn() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    # We will move the tests from GetNormalizedISBN here when it will get replaced
    my $biblio = $builder->build_sample_biblio();
    $biblio->biblioitem->set( { isbn => '9781250067128 | 125006712X' } )->store;
    is(
        $biblio->normalized_isbn, C4::Koha::GetNormalizedISBN( $biblio->biblioitem->isbn ),
        'normalized_isbn is a wrapper around C4::Koha::GetNormalizedISBN'
    );

    $schema->storage->txn_rollback;

};

subtest 'normalized_upc() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    # We will move the tests from GetNormalizedUPC here when it will get replaced
    # Note that only a single test exist and it's not really meaningful...
    my $biblio = $builder->build_sample_biblio();
    is(
        $biblio->normalized_upc, C4::Koha::GetNormalizedUPC( $biblio->metadata->record ),
        'normalized_upc is a wrapper around C4::Koha::GetNormalizedUPC'
    );

    $schema->storage->txn_rollback;

};

subtest 'normalized_oclc() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    # We will move the tests from GetNormalizedOCLC here when it will get replaced
    # Note that only a single test exist and it's not really meaningful...
    my $biblio = $builder->build_sample_biblio();
    is(
        $biblio->normalized_oclc, C4::Koha::GetNormalizedOCLCNumber( $biblio->metadata->record ),
        'normalized_oclc is a wrapper around C4::Koha::GetNormalizedOCLCNumber'
    );

    $schema->storage->txn_rollback;

};

subtest 'opac_suppressed() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $record = MARC::Record->new;
    $record->append_fields(
        MARC::Field->new( '245', '', '', a => 'Some title 1' ),
        MARC::Field->new( '942', '', '', n => '1' ),
    );

    my ($biblio_id) = AddBiblio( $record, qw{} );
    my $biblio = Koha::Biblios->find($biblio_id);

    ok( $biblio->opac_suppressed(), 'Record is suppressed' );

    $record->field('942')->replace_with( MARC::Field->new( '942', '', '', n => '0' ) );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);

    ok( !$biblio->opac_suppressed(), 'Record is not suppressed' );

    $record->field('942')->replace_with( MARC::Field->new( '942', '', '', n => '' ) );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);

    ok( !$biblio->opac_suppressed(), 'Record is not suppressed' );

    $record->delete_field( $record->field('942') );
    ($biblio_id) = AddBiblio( $record, qw{} );
    $biblio = Koha::Biblios->find($biblio_id);

    ok( !$biblio->opac_suppressed(), 'Record is not suppressed' );

    $schema->storage->txn_rollback;
};

subtest 'ratings' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    # See t/db_dependent/Koha/Ratings.t
    ok(1);

    $schema->storage->txn_rollback;
};

subtest 'opac_summary_html' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $author = 'my author';
    my $title  = 'my title';
    my $isbn   = '9781250067128 | 125006712X';
    my $biblio = $builder->build_sample_biblio( { author => $author, title => $title } );
    $biblio->biblioitem->set( { isbn => '9781250067128 | 125006712X' } )->store;

    t::lib::Mocks::mock_preference( 'OPACMySummaryHTML', '' );
    is( $biblio->opac_summary_html, '', 'opac_summary_html returns empty string if pref is off' );

    t::lib::Mocks::mock_preference(
        'OPACMySummaryHTML',
        'Replace {AUTHOR}, {TITLE}, {ISBN} AND {BIBLIONUMBER} please'
    );
    is(
        $biblio->opac_summary_html,
        sprintf( 'Replace %s, %s, %s AND %s please', $author, $title, $biblio->normalized_isbn, $biblio->biblionumber ),
        'opac_summary_html replaces the different patterns'
    );

    $schema->storage->txn_rollback;

};

subtest 'can_be_edited() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $biblio = $builder->build_sample_biblio;

    my $source_allows_editing = 1;

    my $mock_metadata = Test::MockModule->new('Koha::Biblio::Metadata');
    $mock_metadata->mock( 'source_allows_editing', sub { return $source_allows_editing; } );

    ok( !$biblio->can_be_edited($patron), "Patron needs 'edit_catalog' subpermission" );

    # Add editcatalogue => edit_catalog subpermission
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->id,
                module_bit     => 9,                  # editcatalogue
                code           => 'edit_catalogue',
            },
        }
    );

    ok( $biblio->can_be_edited($patron), "Patron with 'edit_catalogue' can edit" );

    my $fa_biblio = $builder->build_sample_biblio( { frameworkcode => 'FA' } );
    my $fa_patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );

    # Add editcatalogue => edit_catalog subpermission
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $fa_patron->id,
                module_bit     => 9,                   # editcatalogue
                code           => 'fast_cataloging',
            },
        }
    );

    ok( !$biblio->can_be_edited($fa_patron),   "Fast add permissions are not enough" );
    ok( $fa_biblio->can_be_edited($fa_patron), "Fast add user can edit FA records" );
    ok( $fa_biblio->can_be_edited($patron),    "edit_catalogue user can edit FA records" );

    # Mock the record source doesn't allow direct editing
    $source_allows_editing = 0;
    ok( !$biblio->can_be_edited($patron), "Patron needs 'edit_locked_record' subpermission for locked records" );

    # Add editcatalogue => edit_catalog subpermission
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $patron->id,
                module_bit     => 9,                       # editcatalogue
                code           => 'edit_locked_records',
            },
        }
    );
    ok( $biblio->can_be_edited($patron), "Patron needs 'edit_locked_record' subpermission for locked records" );

    throws_ok { $biblio->can_be_edited() }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown on missing parameter';

    my $potato = 'Potato';

    throws_ok { $biblio->can_be_edited($potato) }
    'Koha::Exceptions::MissingParameter',
        'Exception thrown if parameter not a Koha::Patron reference';

    $schema->storage->txn_rollback;
};

sub component_record1 {
    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '001', '3456' ),
        MARC::Field->new( '245', '', '', a => 'Some title 1' ),
        MARC::Field->new( '773', '', '', w => '(FIRST)1234' ),
    );
    return $marc;
}

sub search_component_record1 {
    my @results = ( component_record1()->as_xml() );
    return ( undef, { biblioserver => { RECORDS => \@results, hits => 1 } }, 1 );
}

sub search_component_record2 {
    my @results;
    return ( undef, { biblioserver => { RECORDS => \@results, hits => 0 } }, 0 );
}

sub host_record {
    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '001', '1234' ),
        MARC::Field->new( '003', 'FIRST' ),
        MARC::Field->new( '245', '', '', a => 'Some title' ),
    );
    return $marc;
}

subtest 'check_booking tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my @items;
    for ( 0 .. 2 ) {
        my $item = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 1 } );
        push @items, $item;
    }

    my $can_book = $biblio->check_booking(
        {
            start_date => dt_from_string(),
            end_date   => dt_from_string()->add( days => 7 )
        }
    );

    is(
        $can_book, 1,
        "True returned from Koha::Biblio->check_booking if there are no bookings"
    );

    my $start_1 = dt_from_string()->subtract( days => 7 );
    my $end_1   = dt_from_string()->subtract( days => 1 );
    my $start_2 = dt_from_string();
    my $end_2   = dt_from_string()->add( days => 7 );

    # Past bookings
    my @bookings;
    for my $item (@items) {

        my $booking = $builder->build_object(
            {
                class => 'Koha::Bookings',
                value => {
                    biblio_id  => $biblio->biblionumber,
                    item_id    => $item->itemnumber,
                    start_date => $start_1,
                    end_date   => $end_1
                }
            }
        );
        push @bookings, $booking;
    }

    $can_book = $biblio->check_booking(
        {
            start_date => dt_from_string(),
            end_date   => dt_from_string()->add( days => 7 ),
        }
    );

    is(
        $can_book,
        1,
        "Koha::Biblio->check_booking returns true when we all existing bookings are in the past"
    );

    # Current bookings
    my @current_bookings;
    for my $item (@items) {
        my $booking = $builder->build_object(
            {
                class => 'Koha::Bookings',
                value => {
                    biblio_id  => $biblio->biblionumber,
                    item_id    => $item->itemnumber,
                    start_date => $start_2,
                    end_date   => $end_2
                }
            }
        );
        push @current_bookings, $booking;
    }

    $can_book = $biblio->check_booking(
        {
            start_date => dt_from_string(),
            end_date   => dt_from_string()->add( days => 7 ),
        }
    );
    is(
        $can_book,
        0,
        "Koha::Biblio->check_booking returns false if the booking would conflict with existing bookings"
    );

    $can_book = $biblio->check_booking(
        {
            start_date => dt_from_string(),
            end_date   => dt_from_string()->add( days => 7 ),
            booking_id => $current_bookings[0]->booking_id
        }
    );
    is(
        $can_book,
        1,
        "Koha::Biblio->check_booking returns true if we pass the booking_id of one of the bookings that we would conflict with"
    );

    # Cancelled booking
    $current_bookings[0]->update( { status => 'cancelled' } );
    $can_book = $biblio->check_booking(
        {
            start_date => dt_from_string(),
            end_date   => dt_from_string()->add( days => 7 ),
        }
    );
    is(
        $can_book,
        1,
        "Koha::Item->check_booking takes account of cancelled status in bookings check"
    );

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    t::lib::Mocks::mock_userenv( { branchcode => $library->id } );

    # Create a a test biblio with 8 items
    my $new_biblio = $builder->build_object(
        {
            class => 'Koha::Biblios',
            value => { title => 'Test biblio with items' }
        }
    );
    my @new_items;
    for ( 1 .. 8 ) {
        my $item = $builder->build_object(
            {
                class => 'Koha::Items',
                value => {
                    homebranch    => $library->branchcode,
                    holdingbranch => $library->branchcode,
                    biblionumber  => $new_biblio->biblionumber,
                    bookable      => 1
                }
            }
        );
        push @new_items, $item;
    }

    my @item_numbers  = map { $_->itemnumber } @new_items;
    my @item_barcodes = map { $_->barcode } @new_items;

    # Check-out all of those 6 items
    @item_barcodes = splice @item_barcodes, 0, 6;
    for my $item_barcode (@item_barcodes) {
        AddIssue( $patron_1, $item_barcode );
    }

    @item_numbers = splice @item_numbers, 0, 6;
    my @new_bookings;
    for my $itemnumber (@item_numbers) {
        my $booking = $builder->build_object(
            {
                class => 'Koha::Bookings',
                value => {
                    biblio_id  => $new_biblio->biblionumber,
                    item_id    => $itemnumber,
                    start_date => $start_2,
                    end_date   => $end_2,
                    status     => 'new'
                }
            }
        );
        push @new_bookings, $booking;
    }

    # Place a booking on one of the 2 remaining items
    my $item = ( grep { $_->itemnumber ne $new_bookings[0]->item_id } @new_items )[0];

    my $check_booking = $new_biblio->get_from_storage->check_booking(
        {
            start_date => $start_2,
            end_date   => $end_2,
            item_id    => $item->itemnumber
        }
    );

    is( $check_booking, 1, "Koha::Biblio->check_booking returns true when we can book on an item" );

    $schema->storage->txn_rollback;
};
