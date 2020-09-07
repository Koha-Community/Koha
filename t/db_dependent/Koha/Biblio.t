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

use Test::More tests => 12;

use C4::Biblio;
use Koha::Database;
use Koha::Acquisition::Orders;

use t::lib::TestBuilder;
use t::lib::Mocks;

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

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    ok( !$biblio->hidden_in_opac({ rules => { withdrawn => [ 2 ] } }), 'Biblio not hidden if there is no item attached' );

    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    $item_1->withdrawn( 1 )->store->discard_changes;
    $item_2->withdrawn( 1 )->store->discard_changes;

    ok( !$biblio->hidden_in_opac({ rules => { withdrawn => [ 2 ] } }), 'Biblio not hidden' );

    $item_2->withdrawn( 2 )->store->discard_changes;
    $biblio->discard_changes; # refresh

    ok( !$biblio->hidden_in_opac({ rules => { withdrawn => [ 2 ] } }), 'Biblio not hidden' );

    $item_1->withdrawn( 2 )->store->discard_changes;
    $biblio->discard_changes; # refresh

    ok( $biblio->hidden_in_opac({ rules => { withdrawn => [ 2 ] } }), 'Biblio hidden' );

    $schema->storage->txn_rollback;
};

subtest 'items() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    is( $biblio->items->count, 0, 'No items, count is 0' );

    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    my $items = $biblio->items;
    is( ref($items), 'Koha::Items', 'Returns a Koha::Items resultset' );
    is( $items->count, 2, 'Two items in resultset' );

    my @items = $biblio->items->as_list;
    is( scalar @items, 2, 'Same result, but in list context' );

    $schema->storage->txn_rollback;

};

subtest 'get_coins and get_openurl' => sub {

    plan tests => 3;

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

subtest 'pickup_locations' => sub {
    plan tests => 29;

    $schema->storage->txn_begin;

    my $dbh = C4::Context->dbh;

    # Cleanup database
    Koha::Holds->search->delete;
    Koha::Patrons->search->delete;
    Koha::Items->search->delete;
    Koha::Libraries->search->delete;
    Koha::CirculationRules->search->delete;
    $dbh->do('DELETE FROM issues');
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

    my $library1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0 } } );
    my $library4 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library5 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library6 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library7 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1 } } );
    my $library8 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0 } } );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $library1->branchcode,
            itemtype   => undef,
            rules => {
                holdallowed => 1,
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
                holdallowed => 3,
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
                holdallowed => 3,
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
                holdallowed => 2,
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
                holdallowed => 2,
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
                holdallowed => 1,
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
                holdallowed => 3,
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
                holdallowed => 2,
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

        my @pl = @{ $biblio->pickup_locations( { patron => $patron} ) };

        foreach my $pickup_location (@pl) {
            is( ref($pickup_location), 'Koha::Library', 'Object type is correct' );
        }

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
        foreach my $biblio ($biblio1, $biblio2) {
            foreach my $patron ($patron1, $patron8) {
                _doTest($cbranch, $biblio, $patron, $results);
            }
        }
    }

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
