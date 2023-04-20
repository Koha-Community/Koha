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

use Test::More tests => 23; # +1
use Test::Exception;
use Test::Warn;

use C4::Biblio qw( AddBiblio ModBiblio ModBiblioMarc );
use C4::Circulation qw( AddIssue AddReturn );

use Koha::Database;
use Koha::Cache::Memory::Lite;
use Koha::Caches;
use Koha::Acquisition::Orders;
use Koha::AuthorisedValueCategories;
use Koha::AuthorisedValues;
use Koha::MarcSubfieldStructures;
use Koha::Exception;

use MARC::Field;
use MARC::Record;

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
    my $field = MARC::Field->new('245','','','a' => $title);
    $record->append_fields( $field );
    my ($biblionumber) = C4::Biblio::AddBiblio($record, '');

    my $biblio = Koha::Biblios->find( $biblionumber );
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
    my $rules  = { withdrawn => [ 2 ] };

    t::lib::Mocks::mock_preference( 'OpacHiddenItemsHidesRecord', 0 );

    ok(
        !$biblio->hidden_in_opac({ rules => $rules }),
        'Biblio not hidden if there is no item attached (!OpacHiddenItemsHidesRecord)'
    );

    t::lib::Mocks::mock_preference( 'OpacHiddenItemsHidesRecord', 1 );

    ok(
        !$biblio->hidden_in_opac({ rules => $rules }),
        'Biblio not hidden if there is no item attached (OpacHiddenItemsHidesRecord)'
    );

    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    $item_1->withdrawn( 1 )->store->discard_changes;
    $item_2->withdrawn( 1 )->store->discard_changes;

    ok( !$biblio->hidden_in_opac({ rules => $rules }), 'Biblio not hidden' );

    $item_2->withdrawn( 2 )->store->discard_changes;
    $biblio->discard_changes; # refresh

    ok( !$biblio->hidden_in_opac({ rules => $rules }), 'Biblio not hidden' );

    $item_1->withdrawn( 2 )->store->discard_changes;
    $biblio->discard_changes; # refresh

    ok( $biblio->hidden_in_opac({ rules => $rules }), 'Biblio hidden' );

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

    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    my $items = $biblio->items;
    is( ref($items), 'Koha::Items', 'Returns a Koha::Items resultset' );
    is( $items->count, 2, 'Two items in resultset' );

    $schema->storage->txn_rollback;

};

subtest 'get_coins and get_openurl' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;
    my $biblio = $builder->build_sample_biblio({
            title => 'Title 1',
            author => 'Author 1'
        });
    is(
        $biblio->get_coins,
        'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft.genre=book&amp;rft.btitle=Title%201&amp;rft.au=Author%201',
        'GetCOinsBiblio returned right metadata'
    );

    my $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new('100','','','a' => 'Author 2'), MARC::Field->new('880','','','a' => 'Something') );
    my ( $biblionumber ) = C4::Biblio::AddBiblio($record, '');
    my $biblio_no_title = Koha::Biblios->find($biblionumber);
    is(
        $biblio_no_title->get_coins,
        'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft.genre=book&amp;rft.au=Author%202',
        'GetCOinsBiblio returned right metadata if biblio does not have a title'
    );

    t::lib::Mocks::mock_preference("OpenURLResolverURL", "https://koha.example.com/");
    is(
        $biblio->get_openurl,
        'https://koha.example.com/?ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Abook&amp;rft.genre=book&amp;rft.btitle=Title%201&amp;rft.au=Author%201',
        'Koha::Biblio->get_openurl returned right URL'
    );

    t::lib::Mocks::mock_preference("OpenURLResolverURL", "https://koha.example.com/?client_id=ci1");
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

    $biblio->serial( 1 )->store->discard_changes;
    ok( $biblio->is_serial, 'Bibliographic record is serial' );

    $biblio->serial( 0 )->store->discard_changes;
    ok( !$biblio->is_serial, 'Bibliographic record is not serial' );

    my $record = $biblio->metadata->record;
    $record->leader('00142nas a22     7a 4500');
    ModBiblio($record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find($biblio->biblionumber);

    ok( $biblio->is_serial, 'Bibliographic record is serial' );

    $schema->storage->txn_rollback;
};

subtest 'pickup_locations() tests' => sub {

    plan tests => 11;

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

    my $library1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'zzz' } } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'AAA' } } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0, branchname => 'FFF' } } );
    my $library4 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'CCC' } } );
    my $library5 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'eee' } } );
    my $library6 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'BBB' } } );
    my $library7 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, branchname => 'DDD' } } );
    my $library8 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0, branchname => 'GGG' } } );

    our @branchcodes = map { $_->branchcode } ($library1, $library2, $library3, $library4, $library5, $library6, $library7, $library8);

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library1->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_home_library',
                hold_fulfillment_policy => 'any',
                returnbranch => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library2->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_local_hold_group',
                hold_fulfillment_policy => 'holdgroup',
                returnbranch => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library3->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_local_hold_group',
                hold_fulfillment_policy => 'patrongroup',
                returnbranch => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library4->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_any_library',
                hold_fulfillment_policy => 'holdingbranch',
                returnbranch => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library5->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_any_library',
                hold_fulfillment_policy => 'homebranch',
                returnbranch => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library6->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_home_library',
                hold_fulfillment_policy => 'holdgroup',
                returnbranch => 'any'
            }
        }
    );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library7->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_local_hold_group',
                hold_fulfillment_policy => 'holdingbranch',
                returnbranch => 'any'
            }
        }
    );


    Koha::CirculationRules->set_rules(
        {
            branchcode => $library8->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 'from_any_library',
                hold_fulfillment_policy => 'patrongroup',
                returnbranch => 'any'
            }
        }
    );

    my $group1_1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library1->branchcode } } );
    my $group1_2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library2->branchcode } } );

    my $group2_3 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library3->branchcode } } );
    my $group2_4 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library4->branchcode } } );

    my $group3_5 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library5->branchcode } } );
    my $group3_6 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library6->branchcode } } );
    my $group3_7 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library7->branchcode } } );
    my $group3_8 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root3->id, branchcode => $library8->branchcode } } );

    my $biblio1  = $builder->build_sample_biblio({ title => '1' });
    my $biblio2  = $builder->build_sample_biblio({ title => '2' });

    throws_ok
      { $biblio1->pickup_locations }
      'Koha::Exceptions::MissingParameter',
      'Exception thrown on missing parameter';

    is( $@->parameter, 'patron', 'Exception param correctly set' );

    my $item1_1  = $builder->build_sample_item({
        biblionumber     => $biblio1->biblionumber,
        homebranch       => $library1->branchcode,
        holdingbranch    => $library2->branchcode,
    })->store;

    my $item1_3  = $builder->build_sample_item({
        biblionumber     => $biblio1->biblionumber,
        homebranch       => $library3->branchcode,
        holdingbranch    => $library4->branchcode,
    })->store;

    my $item1_7  = $builder->build_sample_item({
        biblionumber     => $biblio1->biblionumber,
        homebranch       => $library7->branchcode,
        holdingbranch    => $library4->branchcode,
    })->store;

    my $item2_2  = $builder->build_sample_item({
        biblionumber     => $biblio2->biblionumber,
        homebranch       => $library2->branchcode,
        holdingbranch    => $library1->branchcode,
    })->store;

    my $item2_4  = $builder->build_sample_item({
        biblionumber     => $biblio2->biblionumber,
        homebranch       => $library4->branchcode,
        holdingbranch    => $library3->branchcode,
    })->store;

    my $item2_6  = $builder->build_sample_item({
        biblionumber     => $biblio2->biblionumber,
        homebranch       => $library6->branchcode,
        holdingbranch    => $library4->branchcode,
    })->store;

    my $patron1 = $builder->build_object( { class => 'Koha::Patrons', value => { firstname=>'1', branchcode => $library1->branchcode } } );
    my $patron8 = $builder->build_object( { class => 'Koha::Patrons', value => { firstname=>'8', branchcode => $library8->branchcode } } );

    my $results = {
        "ItemHomeLibrary-1-1" => 6,
        "ItemHomeLibrary-1-8" => 1,
        "ItemHomeLibrary-2-1" => 2,
        "ItemHomeLibrary-2-8" => 0,
        "PatronLibrary-1-1" => 6,
        "PatronLibrary-1-8" => 3,
        "PatronLibrary-2-1" => 0,
        "PatronLibrary-2-8" => 3,
    };

    sub _doTest {
        my ( $cbranch, $biblio, $patron, $results ) = @_;
        t::lib::Mocks::mock_preference('ReservesControlBranch', $cbranch);

        my @pl = map {
            my $pickup_location = $_;
            grep { $pickup_location->branchcode eq $_ } @branchcodes
        } $biblio->pickup_locations( { patron => $patron } )->as_list;

        ok(
            scalar(@pl) == $results->{ $cbranch . '-'
                  . $biblio->title . '-'
                  . $patron->firstname },
            'ReservesControlBranch: '
              . $cbranch
              . ', biblio'
              . $biblio->title
              . ', patron'
              . $patron->firstname
              . ' should return '
              . $results->{ $cbranch . '-'
                  . $biblio->title . '-'
                  . $patron->firstname }
              . ' but returns '
              . scalar(@pl)
        );
    }

    foreach my $cbranch ('ItemHomeLibrary','PatronLibrary') {
        my $cache = Koha::Cache::Memory::Lite->get_instance();
        $cache->flush(); # needed since we change ReservesControlBranch
        foreach my $biblio ($biblio1, $biblio2) {
            foreach my $patron ($patron1, $patron8) {
                _doTest($cbranch, $biblio, $patron, $results);
            }
        }
    }

    my @pl_names = map { $_->branchname } $biblio1->pickup_locations( { patron => $patron1 } )->as_list;
    my $pl_ori_str = join('|', @pl_names);
    my $pl_sorted_str = join('|', sort { lc($a) cmp lc($b) } @pl_names);
    ok(
        $pl_ori_str eq $pl_sorted_str,
        'Libraries must be sorted by name'
    );
    $schema->storage->txn_rollback;
};

subtest 'to_api() tests' => sub {

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    my $biblioitem_api = $biblio->biblioitem->to_api;
    my $biblio_api     = $biblio->to_api;

    plan tests => (scalar keys %{ $biblioitem_api }) + 1;

    foreach my $key ( keys %{ $biblioitem_api } ) {
        is( $biblio_api->{$key}, $biblioitem_api->{$key}, "$key is added to the biblio object" );
    }

    $biblio_api = $biblio->to_api({ embed => { items => {} } });
    is_deeply( $biblio_api->{items}, [ $item->to_api ], 'Item correctly embedded' );

    $schema->storage->txn_rollback;
};

subtest 'suggestions() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio     = $builder->build_sample_biblio();

    is( ref($biblio->suggestions), 'Koha::Suggestions', 'Return type is correct' );

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

    my ($host_bibnum) = C4::Biblio::AddBiblio(host_record(), '');
    my $host_biblio = Koha::Biblios->find($host_bibnum);
    t::lib::Mocks::mock_preference( 'SearchEngine', 'Zebra' );
    my $search_mod = Test::MockModule->new( 'Koha::SearchEngine::Zebra::Search' );
    $search_mod->mock( 'search_compat', \&search_component_record2 );

    my $components = $host_biblio->get_marc_components;
    is( ref($components), 'ARRAY', 'Return type is correct' );

    is_deeply(
        $components,
        [],
        '->get_marc_components returns an empty ARRAY'
    );

    $search_mod->unmock( 'search_compat');
    $search_mod->mock( 'search_compat', \&search_component_record1 );
    my $component_record = component_record1()->as_xml();

    is_deeply(
        $host_biblio->get_marc_components,
        [$component_record],
        '->get_marc_components returns the related component part record'
    );
    $search_mod->unmock( 'search_compat');

    $search_mod->mock( 'search_compat',
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
    $search_mod->unmock( 'search_compat');

    $schema->storage->txn_rollback;
};

subtest 'get_components_query' => sub {
    plan tests => 12;

    my $biblio = $builder->build_sample_biblio();
    my $biblionumber = $biblio->biblionumber;
    my $record = $biblio->metadata->record;

    foreach my $engine ('Zebra','Elasticsearch'){
        t::lib::Mocks::mock_preference( 'SearchEngine', $engine );

        t::lib::Mocks::mock_preference( 'UseControlNumber', '0' );
        t::lib::Mocks::mock_preference( 'ComponentSortField', 'author' );
        t::lib::Mocks::mock_preference( 'ComponentSortOrder', 'za' );
        my ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        is($comp_query_str, 'Host-item:("Some boring read")', "$engine: UseControlNumber disabled");
        is($comp_sort, "author_za", "$engine: UseControlNumber disabled sort is correct");

        t::lib::Mocks::mock_preference( 'UseControlNumber', '1' );
        t::lib::Mocks::mock_preference( 'ComponentSortOrder', 'az' );
        my $marc_001_field = MARC::Field->new('001', $biblionumber);
        $record->append_fields($marc_001_field);
        C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
        $biblio = Koha::Biblios->find( $biblio->biblionumber);

        ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        is($comp_query_str, "(rcn:\"$biblionumber\" AND (bib-level:a OR bib-level:b))", "$engine: UseControlNumber enabled without MarcOrgCode");
        is($comp_sort, "author_az", "$engine: UseControlNumber enabled without MarcOrgCode sort is correct");

        my $marc_003_field = MARC::Field->new('003', 'OSt');
        $record->append_fields($marc_003_field);
        C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
        $biblio = Koha::Biblios->find( $biblio->biblionumber);

        t::lib::Mocks::mock_preference( 'ComponentSortField', 'title' );
        t::lib::Mocks::mock_preference( 'ComponentSortOrder', 'asc' );
        ( $comp_query, $comp_query_str, $comp_sort ) = $biblio->get_components_query;
        is($comp_query_str, "(((rcn:\"$biblionumber\" AND cni:\"OSt\") OR rcn:\"OSt $biblionumber\") AND (bib-level:a OR bib-level:b))", "$engine: UseControlNumber enabled with MarcOrgCode");
        is($comp_sort, "title_asc", "$engine: UseControlNumber enabled with MarcOrgCode sort if correct");
        $record->delete_field($marc_003_field);
    }
};

subtest 'orders() and active_orders() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    my $orders        = $biblio->orders;
    my $active_orders = $biblio->active_orders;

    is( ref($orders), 'Koha::Acquisition::Orders', 'Result type is correct' );
    is( $biblio->orders->count, $biblio->active_orders->count, '->orders->count returns the count for the resultset' );

    # Add a couple orders
    foreach (1..2) {
        $builder->build_object(
            {
                class => 'Koha::Acquisition::Orders',
                value => {
                    biblionumber => $biblio->biblionumber,
                    datecancellationprinted => '2019-12-31'
                }
            }
        );
    }

    $builder->build_object(
        {
            class => 'Koha::Acquisition::Orders',
            value => {
                biblionumber => $biblio->biblionumber,
                datecancellationprinted => undef
            }
        }
    );

    $orders = $biblio->orders;
    $active_orders = $biblio->active_orders;

    is( ref($orders), 'Koha::Acquisition::Orders', 'Result type is correct' );
    is( ref($active_orders), 'Koha::Acquisition::Orders', 'Result type is correct' );
    is( $orders->count, $active_orders->count + 2, '->active_orders->count returns the rigt count' );

    $schema->storage->txn_rollback;
};

subtest 'tickets() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $tickets = $biblio->tickets;
    is( ref($tickets), 'Koha::Tickets', 'Koha::Biblio->tickets should return a Koha::Tickets object' );
    is( $tickets->count, 0, 'Koha::Biblio->tickets should return a count of 0 when there are no related tickets' );

    # Add two tickets
    foreach (1..2) {
        $builder->build_object(
            {
                class => 'Koha::Tickets',
                value => { biblio_id => $biblio->biblionumber }
            }
        );
    }

    $tickets = $biblio->tickets;
    is( ref($tickets), 'Koha::Tickets', 'Koha::Biblio->tickets should return a Koha::Tickets object' );
    is( $tickets->count, 2, 'Koha::Biblio->tickets should return the correct number of tickets' );

    $schema->storage->txn_rollback;
};

subtest 'subscriptions() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $subscriptions = $biblio->subscriptions;
    is( ref($subscriptions), 'Koha::Subscriptions',
        'Koha::Biblio->subscriptions should return a Koha::Subscriptions object'
    );
    is( $subscriptions->count, 0, 'Koha::Biblio->subscriptions should return the correct number of subscriptions');

    # Add two subscriptions
    foreach (1..2) {
        $builder->build_object(
            {
                class => 'Koha::Subscriptions',
                value => { biblionumber => $biblio->biblionumber }
            }
        );
    }

    $subscriptions = $biblio->subscriptions;
    is( ref($subscriptions), 'Koha::Subscriptions',
        'Koha::Biblio->subscriptions should return a Koha::Subscriptions object'
    );
    is( $subscriptions->count, 2, 'Koha::Biblio->subscriptions should return the correct number of subscriptions');

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
        MARC::Field->new( '500', '', '', a => 'Note1' ),
        MARC::Field->new( '505', '', '', a => 'Note2', u => 'http://someserver.com' ),
        MARC::Field->new( '520', '', '', a => 'Note3 skipped' ),
        MARC::Field->new( '541', '0', '', a => 'Note4 skipped on opac' ),
        MARC::Field->new( '544', '', '', a => 'Note5' ),
        MARC::Field->new( '590', '', '', a => $av->authorised_value ),
        MARC::Field->new( '545', '', '', a => 'Invisible on OPAC' ),
    );

    my $mss = Koha::MarcSubfieldStructures->find({tagfield => "590", tagsubfield => "a", frameworkcode => $biblio->frameworkcode });
    $mss->update({ authorised_value => $av->category });

    $mss = Koha::MarcSubfieldStructures->find({tagfield => "545", tagsubfield => "a", frameworkcode => $biblio->frameworkcode });
    $mss->update({ hidden => 1 });

    my $cache = Koha::Caches->get_instance;
    $cache->clear_from_cache("MarcStructure-0-");
    $cache->clear_from_cache("MarcStructure-1-");
    $cache->clear_from_cache("MarcSubfieldStructure-");
    $cache->clear_from_cache("MarcCodedFields-");

    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber);

    my $notes = $biblio->get_marc_notes;
    is( $notes->[0]->{marcnote}, 'Note1', 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2', 'Second note' );
    is( $notes->[2]->{marcnote}, 'http://someserver.com', 'URL separated' );
    is( $notes->[3]->{marcnote}, 'Note4 skipped on opac',"Note shows if not opac (Hidden by Indicator)" );
    is( $notes->[4]->{marcnote}, 'Note5', 'Fifth note' );
    is( $notes->[5]->{marcnote}, $av->lib, 'Authorised value is correctly parsed to show description rather than code' );
    is( $notes->[6]->{marcnote}, 'Invisible on OPAC', 'Note shows if not opac (Hidden by framework)' );
    is( @$notes, 7, 'No more notes' );
    $notes = $biblio->get_marc_notes({ opac => 1 });
    is( $notes->[0]->{marcnote}, 'Note1', 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2', 'Second note' );
    is( $notes->[2]->{marcnote}, 'http://someserver.com', 'URL separated' );
    is( $notes->[3]->{marcnote}, 'Note5', 'Fifth note shows after fourth skipped' );
    is( $notes->[4]->{marcnote}, $av->lib_opac, 'Authorised value is correctly parsed for OPAC to show description rather than code' );
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
    $biblio = Koha::Biblios->find( $biblio->biblionumber);
    my $notes = $biblio->get_marc_notes({ marcflavour => 'UNIMARC' });
    is( $notes->[0]->{marcnote}, 'Note1', 'First note' );
    is( $notes->[1]->{marcnote}, 'Note2', 'Second note' );
    is( @$notes, 2, 'No more notes' );

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    $schema->storage->txn_rollback;
};

subtest 'host_items() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio( { frameworkcode => '' } );

    t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 1 );
    my $host_items = $biblio->host_items;
    is( ref($host_items),   'Koha::Items' );
    is( $host_items->count, 0 );

    my $item_1 =
      $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
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
    $biblio = $biblio->get_from_storage;
    $host_items = $biblio->host_items;
    is( $host_items->count, 2 );
    is_deeply( [ $host_items->get_column('itemnumber') ],
        [ $host_item_1->itemnumber, $host_item_2->itemnumber ] );

    t::lib::Mocks::mock_preference( 'EasyAnalyticalRecords', 0 );
    $host_items = $biblio->host_items;
    is( ref($host_items),   'Koha::Items' );
    is( $host_items->count, 0 );

    $schema->storage->txn_rollback;
};

subtest 'article_requests() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $item   = $builder->build_sample_item;
    my $biblio = $item->biblio;

    my $article_requests = $biblio->article_requests;
    is( ref($article_requests), 'Koha::ArticleRequests',
        'In scalar context, type is correct' );
    is( $article_requests->count, 0, 'No article requests' );

    foreach my $i ( 0 .. 3 ) {

        my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

        Koha::ArticleRequest->new(
            {
                borrowernumber => $patron->id,
                biblionumber   => $biblio->id,
                itemnumber     => $item->id,
                title          => $biblio->title,
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

    my $library = $builder->build_object({ class => 'Koha::Libraries' });

    my $patron_1 = $builder->build_object({ class => 'Koha::Patrons' })->unblessed;
    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' })->unblessed;

    my $item_1 = $builder->build_sample_item;
    my $item_2 = $builder->build_sample_item({ biblionumber => $item_1->biblionumber });

    t::lib::Mocks::mock_userenv({ branchcode => $library->id });

    AddIssue( $patron_1, $item_1->barcode );
    AddIssue( $patron_1, $item_2->barcode );

    AddReturn( $item_1->barcode );
    AddIssue( $patron_2, $item_1->barcode );

    my $biblio = $item_1->biblio;
    my $current_checkouts = $biblio->current_checkouts;
    my $old_checkouts = $biblio->old_checkouts;

    is( ref($current_checkouts), 'Koha::Checkouts', 'Type is correct' );
    is( ref($old_checkouts), 'Koha::Old::Checkouts', 'Type is correct' );

    is( $current_checkouts->count, 2, 'Count is correct for current checkouts' );
    is( $old_checkouts->count, 1, 'Count is correct for old checkouts' );

    $schema->storage->txn_rollback;
};

subtest 'get_marc_contributors() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio({ author => 'Main author' });
    my $record = $biblio->metadata->record;

    # add author information
    my $field = MARC::Field->new('700','1','','a' => 'Jefferson, Thomas');
    $record->append_fields($field);
    $field = MARC::Field->new('701','1','','d' => 'Secondary author 2');
    $record->append_fields($field);

    # get record
    C4::Biblio::ModBiblio( $record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblio->biblionumber );

    is( @{$biblio->get_marc_authors}, 3, 'get_marc_authors retrieves correct number of author subfields' );
    is( @{$biblio->get_marc_contributors}, 2, 'get_marc_contributors retrieves correct number of author subfields' );
    $schema->storage->txn_rollback;
};

subtest 'Recalls tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $item1 = $builder->build_sample_item;
    my $biblio = $item1->biblio;
    my $branchcode = $item1->holdingbranch;
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $branchcode } });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $branchcode } });
    my $patron3 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $branchcode } });
    my $item2 = $builder->build_object({ class => 'Koha::Items', value => { holdingbranch => $branchcode, homebranch => $branchcode, biblionumber => $biblio->biblionumber, itype => $item1->effective_itemtype } });
    t::lib::Mocks::mock_userenv({ patron => $patron1 });

    my $recall1 = Koha::Recall->new(
        {   patron_id         => $patron1->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => $item1->itemnumber,
            expiration_date   => undef,
            item_level        => 1
        }
    )->store;
    my $recall2 = Koha::Recall->new(
        {   patron_id         => $patron2->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => undef,
            expiration_date   => undef,
            item_level        => 0
        }
    )->store;
    my $recall3 = Koha::Recall->new(
        {   patron_id         => $patron3->borrowernumber,
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
    $recall2->set_expired({ interface => 'COMMANDLINE' });

    is( $recalls->count, 3, 'Correctly get number of recalls for biblio' );
    is( $recalls->filter_by_current->count, 1, 'Correctly get number of active recalls for biblio' );

    t::lib::Mocks::mock_preference('UseRecalls', 0);
    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall with UseRecalls disabled" );

    t::lib::Mocks::mock_preference("UseRecalls", 1);
    $item1->update({ notforloan => 1 });
    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall with no available items" );

    $item1->update({ notforloan => 0 });
    Koha::CirculationRules->set_rules({
        branchcode => $branchcode,
        categorycode => $patron1->categorycode,
        itemtype => $item1->effective_itemtype,
        rules => {
            recalls_allowed => 0,
            recalls_per_record => 1,
            on_shelf_recalls => 'all',
        },
    });
    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if recalls_allowed = 0" );

    Koha::CirculationRules->set_rules({
        branchcode => $branchcode,
        categorycode => $patron1->categorycode,
        itemtype => $item1->effective_itemtype,
        rules => {
            recalls_allowed => 1,
            recalls_per_record => 1,
            on_shelf_recalls => 'all',
        },
    });
    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if patron has more existing recall(s) than recalls_allowed" );
    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if patron has more existing recall(s) than recalls_per_record" );

    $recall1->set_cancelled;
    C4::Circulation::AddIssue( $patron1->unblessed, $item2->barcode );
    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if patron has already checked out an item attached to this biblio" );

    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if on_shelf_recalls = all and items are still available" );

    Koha::CirculationRules->set_rules({
        branchcode => $branchcode,
        categorycode => $patron1->categorycode,
        itemtype => $item1->effective_itemtype,
        rules => {
            recalls_allowed => 1,
            recalls_per_record => 1,
            on_shelf_recalls => 'any',
        },
    });
    C4::Circulation::AddReturn( $item2->barcode, $branchcode );
    is( $biblio->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if no items are checked out" );

    $recall2->set_cancelled;
    C4::Circulation::AddIssue( $patron2->unblessed, $item2->barcode );
    C4::Circulation::AddIssue( $patron2->unblessed, $item1->barcode );
    is( $biblio->can_be_recalled({ patron => $patron1 }), 2, "Can recall two items" );

    $item1->update({ withdrawn => 1 });
    is( $biblio->can_be_recalled({ patron => $patron1 }), 1, "Can recall one item" );

    $schema->storage->txn_rollback;
};

subtest 'item_groups() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    my @item_groups = $biblio->item_groups->as_list;
    is( scalar(@item_groups), 0, 'Got zero item groups');

    my $item_group_1 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    @item_groups = $biblio->item_groups->as_list;
    is( scalar(@item_groups), 1, 'Got one item group');
    is( $item_groups[0]->id, $item_group_1->id, 'Got correct item group');

    my $item_group_2 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    @item_groups = $biblio->item_groups->as_list;
    is( scalar(@item_groups), 2, 'Got two item groups');
    is( $item_groups[0]->id, $item_group_1->id, 'Got correct item group 1');
    is( $item_groups[1]->id, $item_group_2->id, 'Got correct item group 2');

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
