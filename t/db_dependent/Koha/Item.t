#!/usr/bin/perl

# Copyright 2019 Koha Development team
#
# This file is part of Koha
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
use utf8;

use Test::More tests => 28;
use Test::Exception;
use Test::MockModule;

use C4::Biblio qw( GetMarcSubfieldStructure );
use C4::Circulation qw( AddIssue AddReturn );

use Koha::Caches;
use Koha::Items;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Old::Items;
use Koha::Recalls;

use List::MoreUtils qw(all);

use t::lib::TestBuilder;
use t::lib::Mocks;
use t::lib::Dates;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'return_claims relationship' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
    });
    my $return_claims = $item->return_claims;
    is( ref($return_claims), 'Koha::Checkouts::ReturnClaims', 'return_claims returns a Koha::Checkouts::ReturnClaims object set' );
    is($item->return_claims->count, 0, "Empty Koha::Checkouts::ReturnClaims set returned if no return_claims");
    my $claim1 = $builder->build({ source => 'ReturnClaim', value => { itemnumber => $item->itemnumber }});
    my $claim2 = $builder->build({ source => 'ReturnClaim', value => { itemnumber => $item->itemnumber }});

    is($item->return_claims()->count,2,"Two ReturnClaims found for item");

    $schema->storage->txn_rollback;
};

subtest 'return_claim accessor' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
    });
    my $return_claim = $item->return_claim;
    is( $return_claim, undef, 'return_claim returned undefined if there are no claims for this item' );

    my $claim1 = $builder->build_object(
        {
            class => 'Koha::Checkouts::ReturnClaims',
            value => { itemnumber => $item->itemnumber, resolution => undef, created_on => dt_from_string()->subtract( minutes => 10 ) }
        }
    );
    my $claim2 = $builder->build_object(
        {
            class => 'Koha::Checkouts::ReturnClaims',
            value  => { itemnumber => $item->itemnumber, resolution => undef, created_on => dt_from_string()->subtract( minutes => 5 ) }
        }
    );

    $return_claim = $item->return_claim;
    is( ref($return_claim), 'Koha::Checkouts::ReturnClaim', 'return_claim returned a Koha::Checkouts::ReturnClaim object' );
    is( $return_claim->id, $claim2->id, 'return_claim returns the most recent unresolved claim');

    $claim2->resolution('test')->store();
    $return_claim = $item->return_claim;
    is( $return_claim->id, $claim1->id, 'return_claim returns the only unresolved claim');

    $claim1->resolution('test')->store();
    $return_claim = $item->return_claim;
    is( $return_claim, undef, 'return_claim returned undefined if there are no active claims for this item' );

    $schema->storage->txn_rollback;
};

subtest 'tracked_links relationship' => sub {
    plan tests => 3;

    my $biblio = $builder->build_sample_biblio();
    my $item   = $builder->build_sample_item({
        biblionumber => $biblio->biblionumber,
    });
    my $tracked_links = $item->tracked_links;
    is( ref($tracked_links), 'Koha::TrackedLinks', 'tracked_links returns a Koha::TrackedLinks object set' );
    is($item->tracked_links->count, 0, "Empty Koha::TrackedLinks set returned if no tracked_links");
    my $link1 = $builder->build({ source => 'Linktracker', value => { itemnumber => $item->itemnumber }});
    my $link2 = $builder->build({ source => 'Linktracker', value => { itemnumber => $item->itemnumber }});

    is($item->tracked_links()->count,2,"Two tracked links found");
};

subtest 'is_bundle tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $item   = $builder->build_sample_item();

    my $is_bundle = $item->is_bundle;
    is($is_bundle, 0, 'is_bundle returns 0 when there are no items attached');

    my $item2 = $builder->build_sample_item();
    $schema->resultset('ItemBundle')
      ->create( { host => $item->itemnumber, item => $item2->itemnumber } );

    $is_bundle = $item->is_bundle;
    is($is_bundle, 1, 'is_bundle returns 1 when there is at least one item attached');

    $schema->storage->txn_rollback;
};

subtest 'in_bundle tests' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $item   = $builder->build_sample_item();

    my $in_bundle = $item->in_bundle;
    is($in_bundle, 0, 'in_bundle returns 0 when the item is not in a bundle');

    my $host_item = $builder->build_sample_item();
    $schema->resultset('ItemBundle')
      ->create( { host => $host_item->itemnumber, item => $item->itemnumber } );

    $in_bundle = $item->in_bundle;
    is($in_bundle, 1, 'in_bundle returns 1 when the item is in a bundle');

    $schema->storage->txn_rollback;
};

subtest 'bundle_items tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $host_item = $builder->build_sample_item();
    my $bundle_items = $host_item->bundle_items;
    is( ref($bundle_items), 'Koha::Items',
        'bundle_items returns a Koha::Items object set' );
    is( $bundle_items->count, 0,
        'bundle_items set is empty when no items are bundled' );

    my $bundle_item1 = $builder->build_sample_item();
    my $bundle_item2 = $builder->build_sample_item();
    my $bundle_item3 = $builder->build_sample_item();
    $schema->resultset('ItemBundle')
      ->create(
        { host => $host_item->itemnumber, item => $bundle_item1->itemnumber } );
    $schema->resultset('ItemBundle')
      ->create(
        { host => $host_item->itemnumber, item => $bundle_item2->itemnumber } );
    $schema->resultset('ItemBundle')
      ->create(
        { host => $host_item->itemnumber, item => $bundle_item3->itemnumber } );

    $bundle_items = $host_item->bundle_items;
    is( $bundle_items->count, 3,
        'bundle_items returns all the bundled items in the set' );

    $schema->storage->txn_rollback;
};

subtest 'bundle_host tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $host_item = $builder->build_sample_item();
    my $bundle_item1 = $builder->build_sample_item();
    my $bundle_item2 = $builder->build_sample_item();
    $schema->resultset('ItemBundle')
      ->create(
        { host => $host_item->itemnumber, item => $bundle_item2->itemnumber } );

    my $bundle_host = $bundle_item1->bundle_host;
    is( $bundle_host, undef, 'bundle_host returns undefined when the item it not part of a bundle');
    $bundle_host = $bundle_item2->bundle_host;
    is( ref($bundle_host), 'Koha::Item', 'bundle_host returns a Koha::Item object when the item is in a bundle');
    is( $bundle_host->id, $host_item->id, 'bundle_host returns the host item when called against an item in a bundle');

    $schema->storage->txn_rollback;
};

subtest 'add_to_bundle tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'BundleNotLoanValue', 1 );

    my $host_item = $builder->build_sample_item();
    my $bundle_item1 = $builder->build_sample_item();
    my $bundle_item2 = $builder->build_sample_item();

    throws_ok { $host_item->add_to_bundle($host_item) }
    'Koha::Exceptions::Item::Bundle::IsBundle',
      'Exception thrown if you try to add the item to itself';

    ok($host_item->add_to_bundle($bundle_item1), 'bundle_item1 added to bundle');
    is($bundle_item1->notforloan, 1, 'add_to_bundle sets notforloan to BundleNotLoanValue');

    throws_ok { $host_item->add_to_bundle($bundle_item1) }
    'Koha::Exceptions::Object::DuplicateID',
      'Exception thrown if you try to add the same item twice';

    throws_ok { $bundle_item1->add_to_bundle($bundle_item2) }
    'Koha::Exceptions::Item::Bundle::IsBundle',
      'Exception thrown if you try to add an item to a bundled item';

    throws_ok { $bundle_item2->add_to_bundle($host_item) }
    'Koha::Exceptions::Item::Bundle::IsBundle',
      'Exception thrown if you try to add a bundle host to a bundle item';

    $schema->storage->txn_rollback;
};

subtest 'remove_from_bundle tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $host_item = $builder->build_sample_item();
    my $bundle_item1 = $builder->build_sample_item({ notforloan => 1 });
    $schema->resultset('ItemBundle')
      ->create(
        { host => $host_item->itemnumber, item => $bundle_item1->itemnumber } );

    is($bundle_item1->remove_from_bundle(), 1, 'remove_from_bundle returns 1 when item is removed from a bundle');
    is($bundle_item1->notforloan, 0, 'remove_from_bundle resets notforloan to 0');
    $bundle_item1 = $bundle_item1->get_from_storage;
    is($bundle_item1->remove_from_bundle(), 0, 'remove_from_bundle returns 0 when item is not in a bundle');

    $schema->storage->txn_rollback;
};

subtest 'hidden_in_opac() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $item  = $builder->build_sample_item({ itemlost => 2 });
    my $rules = {};

    # disable hidelostitems as it interteres with OpachiddenItems for the calculation
    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );

    ok( !$item->hidden_in_opac, 'No rules passed, shouldn\'t hide' );
    ok( !$item->hidden_in_opac({ rules => $rules }), 'Empty rules passed, shouldn\'t hide' );

    # enable hidelostitems to verify correct behaviour
    t::lib::Mocks::mock_preference( 'hidelostitems', 1 );
    ok( $item->hidden_in_opac, 'Even with no rules, item should hide because of hidelostitems syspref' );

    # disable hidelostitems
    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );
    my $withdrawn = $item->withdrawn + 1; # make sure this attribute doesn't match

    $rules = { withdrawn => [$withdrawn], itype => [ $item->itype ] };

    ok( $item->hidden_in_opac({ rules => $rules }), 'Rule matching itype passed, should hide' );



    $schema->storage->txn_rollback;
};

subtest 'has_pending_hold() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $dbh = C4::Context->dbh;
    my $item  = $builder->build_sample_item({ itemlost => 0 });
    my $itemnumber = $item->itemnumber;

    $dbh->do("INSERT INTO tmp_holdsqueue (surname,borrowernumber,itemnumber) VALUES ('Clamp',42,$itemnumber)");
    ok( $item->has_pending_hold, "Yes, we have a pending hold");
    $dbh->do("DELETE FROM tmp_holdsqueue WHERE itemnumber=$itemnumber");
    ok( !$item->has_pending_hold, "We don't have a pending hold if nothing in the tmp_holdsqueue");

    $schema->storage->txn_rollback;
};

subtest "as_marc_field() tests" => sub {

    my $mss = C4::Biblio::GetMarcSubfieldStructure( '' );
    my ( $itemtag, $itemtagsubfield) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

    my @schema_columns = $schema->resultset('Item')->result_source->columns;
    my @mapped_columns = grep { exists $mss->{'items.'.$_} } @schema_columns;

    plan tests => 2 * (scalar @mapped_columns + 1) + 4;

    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item;
    # Make sure it has at least one undefined attribute
    $item->set({ replacementprice => undef })->store->discard_changes;

    # Tests with the mss parameter
    my $marc_field = $item->as_marc_field({ mss => $mss });

    is(
        $marc_field->tag,
        $itemtag,
        'Generated field set the right tag number'
    );

    foreach my $column ( @mapped_columns ) {
        my $tagsubfield = $mss->{ 'items.' . $column }[0]->{tagsubfield};
        is( $marc_field->subfield($tagsubfield),
            $item->$column, "Value is mapped correctly for column $column" );
    }

    # Tests without the mss parameter
    $marc_field = $item->as_marc_field();

    is(
        $marc_field->tag,
        $itemtag,
        'Generated field set the right tag number'
    );

    foreach my $column (@mapped_columns) {
        my $tagsubfield = $mss->{ 'items.' . $column }[0]->{tagsubfield};
        is( $marc_field->subfield($tagsubfield),
            $item->$column, "Value is mapped correctly for column $column" );
    }

    my $unmapped_subfield = Koha::MarcSubfieldStructure->new(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => 'X',
        }
    )->store;
    Koha::MarcSubfieldStructure->new(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => 'Y',
            kohafield     => '',
        }
    )->store;

    my @unlinked_subfields;
    push @unlinked_subfields, X => 'Something weird', Y => 'Something else';
    $item->more_subfields_xml( C4::Items::_get_unlinked_subfields_xml( \@unlinked_subfields ) )->store;

    Koha::Caches->get_instance->clear_from_cache( "MarcStructure-1-" );
    Koha::MarcSubfieldStructures->search(
        { frameworkcode => '', tagfield => $itemtag } )
      ->update( { display_order => \['FLOOR( 1 + RAND( ) * 10 )'] } );

    $marc_field = $item->as_marc_field;

    my $tagslib = C4::Biblio::GetMarcStructure(1, '');
    my @subfields = $marc_field->subfields;
    my $result = all { defined $_->[1] } @subfields;
    ok( $result, 'There are no undef subfields' );
    my @ordered_subfields = sort {
            $tagslib->{$itemtag}->{ $a->[0] }->{display_order}
        <=> $tagslib->{$itemtag}->{ $b->[0] }->{display_order}
    } @subfields;
    is_deeply(\@subfields, \@ordered_subfields);

    is( scalar $marc_field->subfield('X'), 'Something weird', 'more_subfield_xml is considered when kohafield is NULL' );
    is( scalar $marc_field->subfield('Y'), 'Something else', 'more_subfield_xml is considered when kohafield = ""' );

    $schema->storage->txn_rollback;
    Koha::Caches->get_instance->clear_from_cache( "MarcStructure-1-" );
};

subtest 'pickup_locations' => sub {
    plan tests => 66;

    $schema->storage->txn_begin;

    my $dbh = C4::Context->dbh;

    my $root1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1, branchcode => undef } } );
    my $root2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { ft_local_hold_group => 1, branchcode => undef } } );
    my $library1 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, } } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, } } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 0, } } );
    my $library4 = $builder->build_object( { class => 'Koha::Libraries', value => { pickup_location => 1, } } );
    my $group1_1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library1->branchcode } } );
    my $group1_2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root1->id, branchcode => $library2->branchcode } } );

    my $group2_1 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library3->branchcode } } );
    my $group2_2 = $builder->build_object( { class => 'Koha::Library::Groups', value => { parent_id => $root2->id, branchcode => $library4->branchcode } } );

    our @branchcodes = (
        $library1->branchcode, $library2->branchcode,
        $library3->branchcode, $library4->branchcode
    );

    my $item1 = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
            copynumber    => 1,
            ccode         => 'Gollum'
        }
    )->store;

    my $item3 = $builder->build_sample_item(
        {
            homebranch    => $library3->branchcode,
            holdingbranch => $library4->branchcode,
            copynumber    => 3,
            itype         => $item1->itype,
        }
    )->store;

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => $item1->itype,
            branchcode   => undef,
            rules        => {
                reservesallowed => 25,
            }
        }
    );


    my $patron1 = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library1->branchcode, firstname => '1' } } );
    my $patron4 = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library4->branchcode, firstname => '4' } } );

    my $results = {
        "1-1-from_home_library-any"               => 3,
        "1-1-from_home_library-holdgroup"         => 2,
        "1-1-from_home_library-patrongroup"       => 2,
        "1-1-from_home_library-homebranch"        => 1,
        "1-1-from_home_library-holdingbranch"     => 1,
        "1-1-from_any_library-any"                => 3,
        "1-1-from_any_library-holdgroup"          => 2,
        "1-1-from_any_library-patrongroup"        => 2,
        "1-1-from_any_library-homebranch"         => 1,
        "1-1-from_any_library-holdingbranch"      => 1,
        "1-1-from_local_hold_group-any"           => 3,
        "1-1-from_local_hold_group-holdgroup"     => 2,
        "1-1-from_local_hold_group-patrongroup"   => 2,
        "1-1-from_local_hold_group-homebranch"    => 1,
        "1-1-from_local_hold_group-holdingbranch" => 1,
        "1-4-from_home_library-any"               => 0,
        "1-4-from_home_library-holdgroup"         => 0,
        "1-4-from_home_library-patrongroup"       => 0,
        "1-4-from_home_library-homebranch"        => 0,
        "1-4-from_home_library-holdingbranch"     => 0,
        "1-4-from_any_library-any"                => 3,
        "1-4-from_any_library-holdgroup"          => 2,
        "1-4-from_any_library-patrongroup"        => 1,
        "1-4-from_any_library-homebranch"         => 1,
        "1-4-from_any_library-holdingbranch"      => 1,
        "1-4-from_local_hold_group-any"           => 0,
        "1-4-from_local_hold_group-holdgroup"     => 0,
        "1-4-from_local_hold_group-patrongroup"   => 0,
        "1-4-from_local_hold_group-homebranch"    => 0,
        "1-4-from_local_hold_group-holdingbranch" => 0,
        "3-1-from_home_library-any"               => 0,
        "3-1-from_home_library-holdgroup"         => 0,
        "3-1-from_home_library-patrongroup"       => 0,
        "3-1-from_home_library-homebranch"        => 0,
        "3-1-from_home_library-holdingbranch"     => 0,
        "3-1-from_any_library-any"                => 3,
        "3-1-from_any_library-holdgroup"          => 1,
        "3-1-from_any_library-patrongroup"        => 2,
        "3-1-from_any_library-homebranch"         => 0,
        "3-1-from_any_library-holdingbranch"      => 1,
        "3-1-from_local_hold_group-any"           => 0,
        "3-1-from_local_hold_group-holdgroup"     => 0,
        "3-1-from_local_hold_group-patrongroup"   => 0,
        "3-1-from_local_hold_group-homebranch"    => 0,
        "3-1-from_local_hold_group-holdingbranch" => 0,
        "3-4-from_home_library-any"               => 0,
        "3-4-from_home_library-holdgroup"         => 0,
        "3-4-from_home_library-patrongroup"       => 0,
        "3-4-from_home_library-homebranch"        => 0,
        "3-4-from_home_library-holdingbranch"     => 0,
        "3-4-from_any_library-any"                => 3,
        "3-4-from_any_library-holdgroup"          => 1,
        "3-4-from_any_library-patrongroup"        => 1,
        "3-4-from_any_library-homebranch"         => 0,
        "3-4-from_any_library-holdingbranch"      => 1,
        "3-4-from_local_hold_group-any"           => 3,
        "3-4-from_local_hold_group-holdgroup"     => 1,
        "3-4-from_local_hold_group-patrongroup"   => 1,
        "3-4-from_local_hold_group-homebranch"    => 0,
        "3-4-from_local_hold_group-holdingbranch" => 1
    };

    sub _doTest {
        my ( $item, $patron, $ha, $hfp, $results ) = @_;

        Koha::CirculationRules->set_rules(
            {
                branchcode => undef,
                itemtype   => undef,
                rules => {
                    holdallowed => $ha,
                    hold_fulfillment_policy => $hfp,
                    returnbranch => 'any'
                }
            }
        );
        my $ha_value =
          $ha eq 'from_local_hold_group' ? 'holdgroup'
          : (
            $ha eq 'from_any_library' ? 'any'
            : 'homebranch'
          );

        my @pl = map {
            my $pickup_location = $_;
            grep { $pickup_location->branchcode eq $_ } @branchcodes
        } $item->pickup_locations( { patron => $patron } )->as_list;

        ok(
            scalar(@pl) eq $results->{
                    $item->copynumber . '-'
                  . $patron->firstname . '-'
                  . $ha . '-'
                  . $hfp
            },
            'item'
              . $item->copynumber
              . ', patron'
              . $patron->firstname
              . ', holdallowed: '
              . $ha_value
              . ', hold_fulfillment_policy: '
              . $hfp
              . ' should return '
              . $results->{
                    $item->copynumber . '-'
                  . $patron->firstname . '-'
                  . $ha . '-'
                  . $hfp
              }
              . ' and returns '
              . scalar(@pl)
        );

    }


    foreach my $item ($item1, $item3) {
        foreach my $patron ($patron1, $patron4) {
            #holdallowed 1: homebranch, 2: any, 3: holdgroup
            foreach my $ha ('from_home_library', 'from_any_library', 'from_local_hold_group') {
                foreach my $hfp ('any', 'holdgroup', 'patrongroup', 'homebranch', 'holdingbranch') {
                    _doTest($item, $patron, $ha, $hfp, $results);
                }
            }
        }
    }

    # Now test that branchtransferlimits will further filter the pickup locations

    my $item_no_ccode = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
            itype         => $item1->itype,
        }
    )->store;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
    Koha::CirculationRules->set_rules(
        {
            branchcode => undef,
            itemtype   => $item1->itype,
            rules      => {
                holdallowed             => 'from_home_library',
                hold_fulfillment_policy => 1,
                returnbranch            => 'any'
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Item::Transfer::Limits',
            value => {
                toBranch   => $library1->branchcode,
                fromBranch => $library2->branchcode,
                itemtype   => $item1->itype,
                ccode      => undef,
            }
        }
    );

    my @pickup_locations = map {
        my $pickup_location = $_;
        grep { $pickup_location->branchcode eq $_ } @branchcodes
    } $item1->pickup_locations( { patron => $patron1 } )->as_list;

    is( scalar @pickup_locations, 3 - 1, "With a transfer limits we get back the libraries that are pickup locations minus 1 limited library");

    $builder->build_object(
        {
            class => 'Koha::Item::Transfer::Limits',
            value => {
                toBranch   => $library4->branchcode,
                fromBranch => $library2->branchcode,
                itemtype   => $item1->itype,
                ccode      => undef,
            }
        }
    );

    @pickup_locations = map {
        my $pickup_location = $_;
        grep { $pickup_location->branchcode eq $_ } @branchcodes
    } $item1->pickup_locations( { patron => $patron1 } )->as_list;

    is( scalar @pickup_locations, 3 - 2, "With 2 transfer limits we get back the libraries that are pickup locations minus 2 limited libraries");

    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'ccode');
    @pickup_locations = map {
        my $pickup_location = $_;
        grep { $pickup_location->branchcode eq $_ } @branchcodes
    } $item1->pickup_locations( { patron => $patron1 } )->as_list;
    is( scalar @pickup_locations, 3, "With no transfer limits of type ccode we get back the libraries that are pickup locations");

    @pickup_locations = map {
        my $pickup_location = $_;
        grep { $pickup_location->branchcode eq $_ } @branchcodes
    } $item_no_ccode->pickup_locations( { patron => $patron1 } )->as_list;
    is( scalar @pickup_locations, 3, "With no transfer limits of type ccode and an item with no ccode we get back the libraries that are pickup locations");

    $builder->build_object(
        {
            class => 'Koha::Item::Transfer::Limits',
            value => {
                toBranch   => $library2->branchcode,
                fromBranch => $library2->branchcode,
                itemtype   => undef,
                ccode      => $item1->ccode,
            }
        }
    );

    @pickup_locations = map {
        my $pickup_location = $_;
        grep { $pickup_location->branchcode eq $_ } @branchcodes
    } $item1->pickup_locations( { patron => $patron1 } )->as_list;
    is( scalar @pickup_locations, 3 - 1, "With a transfer limits we get back the libraries that are pickup locations minus 1 limited library");

    $builder->build_object(
        {
            class => 'Koha::Item::Transfer::Limits',
            value => {
                toBranch   => $library4->branchcode,
                fromBranch => $library2->branchcode,
                itemtype   => undef,
                ccode      => $item1->ccode,
            }
        }
    );

    @pickup_locations = map {
        my $pickup_location = $_;
        grep { $pickup_location->branchcode eq $_ } @branchcodes
    } $item1->pickup_locations( { patron => $patron1 } )->as_list;
    is( scalar @pickup_locations, 3 - 2, "With 2 transfer limits we get back the libraries that are pickup locations minus 2 limited libraries");

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 0);

    $schema->storage->txn_rollback;
};

subtest 'request_transfer' => sub {
    plan tests => 13;
    $schema->storage->txn_begin;

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item     = $builder->build_sample_item(
        {
            homebranch    => $library1->branchcode,
            holdingbranch => $library2->branchcode,
        }
    );

    # Mandatory fields tests
    throws_ok { $item->request_transfer( { to => $library1 } ) }
    'Koha::Exceptions::MissingParameter',
      'Exception thrown if `reason` parameter is missing';

    throws_ok { $item->request_transfer( { reason => 'Manual' } ) }
    'Koha::Exceptions::MissingParameter',
      'Exception thrown if `to` parameter is missing';

    # Successful request
    my $transfer = $item->request_transfer({ to => $library1, reason => 'Manual' });
    is( ref($transfer), 'Koha::Item::Transfer',
        'Koha::Item->request_transfer should return a Koha::Item::Transfer object'
    );
    my $original_transfer = $transfer->get_from_storage;

    # Transfer already in progress
    throws_ok { $item->request_transfer( { to => $library2, reason => 'Manual' } ) }
    'Koha::Exceptions::Item::Transfer::InQueue',
      'Exception thrown if transfer is already in progress';

    my $exception = $@;
    is( ref( $exception->transfer ),
        'Koha::Item::Transfer',
        'The exception contains the found Koha::Item::Transfer' );

    # Queue transfer
    my $queued_transfer = $item->request_transfer(
        { to => $library2, reason => 'Manual', enqueue => 1 } );
    is( ref($queued_transfer), 'Koha::Item::Transfer',
        'Koha::Item->request_transfer allowed when enqueue is set' );
    my $transfers = $item->get_transfers;
    is($transfers->count, 2, "There are now 2 live transfers in the queue");
    $transfer = $transfer->get_from_storage;
    is_deeply($transfer->unblessed, $original_transfer->unblessed, "Original transfer unchanged");
    $queued_transfer->datearrived(dt_from_string)->store();

    # Replace transfer
    my $replaced_transfer = $item->request_transfer(
        { to => $library2, reason => 'Manual', replace => 1 } );
    is( ref($replaced_transfer), 'Koha::Item::Transfer',
        'Koha::Item->request_transfer allowed when replace is set' );
    $original_transfer->discard_changes;
    ok($original_transfer->datecancelled, "Original transfer cancelled");
    $transfers = $item->get_transfers;
    is($transfers->count, 1, "There is only 1 live transfer in the queue");
    $replaced_transfer->datearrived(dt_from_string)->store();

    # BranchTransferLimits
    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');
    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $library2->branchcode,
        toBranch => $library1->branchcode,
        itemtype => $item->effective_itemtype,
    })->store;

    throws_ok { $item->request_transfer( { to => $library1, reason => 'Manual' } ) }
    'Koha::Exceptions::Item::Transfer::Limit',
      'Exception thrown if transfer is prevented by limits';

    my $forced_transfer = $item->request_transfer( { to => $library1, reason => 'Manual', ignore_limits => 1 } );
    is( ref($forced_transfer), 'Koha::Item::Transfer',
        'Koha::Item->request_transfer allowed when ignore_limits is set'
    );

    $schema->storage->txn_rollback;
};

subtest 'deletion' => sub {
    plan tests => 15;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();

    my $item = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
        }
    );
    is( $item->deleted_on, undef, 'deleted_on not set for new item' );

    my $deleted_item = $item->move_to_deleted;
    is( ref( $deleted_item ), 'Koha::Schema::Result::Deleteditem', 'Koha::Item->move_to_deleted should return the Deleted item' )
      ;    # FIXME This should be Koha::Deleted::Item
    is( t::lib::Dates::compare( $deleted_item->deleted_on, dt_from_string() ), 0 );

    is( Koha::Old::Items->search({itemnumber => $item->itemnumber})->count, 1, '->move_to_deleted must have moved the item to deleteditem' );
    $item = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
        }
    );
    $item->delete;
    is( Koha::Old::Items->search({itemnumber => $item->itemnumber})->count, 0, '->move_to_deleted must not have moved the item to deleteditem' );


    my $library   = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });
    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });

    my $patron = $builder->build_object({class => 'Koha::Patrons'});
    $item = $builder->build_sample_item({ library => $library->branchcode });

    # book_on_loan
    C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

    is(
        @{$item->safe_to_delete->messages}[0]->message,
        'book_on_loan',
        'Koha::Item->safe_to_delete reports item on loan',
    );

    is(
        @{$item->safe_to_delete->messages}[0]->message,
        'book_on_loan',
        'item that is on loan cannot be deleted',
    );

    ok(
        ! $item->safe_to_delete,
        'Koha::Item->safe_to_delete shows item NOT safe to delete'
    );

    AddReturn( $item->barcode, $library->branchcode );

    # not_same_branch
    t::lib::Mocks::mock_preference('IndependentBranches', 1);
    my $item_2 = $builder->build_sample_item({ library => $library_2->branchcode });

    is(
        @{$item_2->safe_to_delete->messages}[0]->message,
        'not_same_branch',
        'Koha::Item->safe_to_delete reports IndependentBranches restriction',
    );

    is(
        @{$item_2->safe_to_delete->messages}[0]->message,
        'not_same_branch',
        'IndependentBranches prevents deletion at another branch',
    );

    # linked_analytics

    { # codeblock to limit scope of $module->mock

        my $module = Test::MockModule->new('C4::Items');
        $module->mock( GetAnalyticsCount => sub { return 1 } );

        $item->discard_changes;
        is(
            @{$item->safe_to_delete->messages}[0]->message,
            'linked_analytics',
            'Koha::Item->safe_to_delete reports linked analytics',
        );

        is(
            @{$item->safe_to_delete->messages}[0]->message,
            'linked_analytics',
            'Linked analytics prevents deletion of item',
        );

    }

    ok(
        $item->safe_to_delete,
        'Koha::Item->safe_to_delete shows item safe to delete'
    );

    $item->safe_delete,

    my $test_item = Koha::Items->find( $item->itemnumber );

    is( $test_item, undef,
        "Koha::Item->safe_delete should delete item if safe_to_delete returns true"
    );

    subtest 'holds tests' => sub {

        plan tests => 9;

        # to avoid noise
        t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );

        $schema->storage->txn_begin;

        my $item = $builder->build_sample_item;

        my $processing     = $builder->build_object( { class => 'Koha::Holds', value => { itemnumber => $item->id, itemnumber => $item->id, found => 'P' } } );
        my $safe_to_delete = $item->safe_to_delete;

        ok( !$safe_to_delete, 'Cannot delete' );
        is(
            @{ $safe_to_delete->messages }[0]->message,
            'book_reserved',
            'Koha::Item->safe_to_delete reports a in processing hold blocks deletion'
        );

        $processing->delete;

        my $in_transit = $builder->build_object( { class => 'Koha::Holds', value => { itemnumber => $item->id, itemnumber => $item->id, found => 'T' } } );
        $safe_to_delete = $item->safe_to_delete;

        ok( !$safe_to_delete, 'Cannot delete' );
        is(
            @{ $safe_to_delete->messages }[0]->message,
            'book_reserved',
            'Koha::Item->safe_to_delete reports a in transit hold blocks deletion'
        );

        $in_transit->delete;

        my $waiting = $builder->build_object( { class => 'Koha::Holds', value => { itemnumber => $item->id, itemnumber => $item->id, found => 'W' } } );
        $safe_to_delete = $item->safe_to_delete;

        ok( !$safe_to_delete, 'Cannot delete' );
        is(
            @{ $safe_to_delete->messages }[0]->message,
            'book_reserved',
            'Koha::Item->safe_to_delete reports a waiting hold blocks deletion'
        );

        $waiting->delete;

        # Add am unfilled biblio-level hold to catch the 'last_item_for_hold' use case
        $builder->build_object( { class => 'Koha::Holds', value => { biblionumber => $item->biblionumber, itemnumber => undef, found => undef } } );

        $safe_to_delete = $item->safe_to_delete;

        ok( !$safe_to_delete );

        is(
            @{ $safe_to_delete->messages}[0]->message,
            'last_item_for_hold',
            'Item cannot be deleted if a biblio-level is placed on the biblio and there is only 1 item attached to the biblio'
        );

        my $extra_item = $builder->build_sample_item({ biblionumber => $item->biblionumber });

        ok( $item->safe_to_delete );

        $schema->storage->txn_rollback;
    };

    $schema->storage->txn_rollback;
};

subtest 'renewal_branchcode' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item();
    my $branch = $builder->build_object({ class => 'Koha::Libraries' });
    my $checkout = $builder->build_object({
        class => 'Koha::Checkouts',
        value => {
            itemnumber => $item->itemnumber,
        }
    });


    C4::Context->interface( 'intranet' );
    t::lib::Mocks::mock_userenv({ branchcode => $branch->branchcode });

    is( $item->renewal_branchcode, $branch->branchcode, "If interface not opac, we get the branch from context");
    is( $item->renewal_branchcode({ branch => "PANDA"}), $branch->branchcode, "If interface not opac, we get the branch from context even if we pass one in");
    C4::Context->set_userenv(51, 'userid4tests', undef, 'firstname', 'surname', undef, undef, 0, undef, undef, undef ); #mock userenv doesn't let us set null branch
    is( $item->renewal_branchcode({ branch => "PANDA"}), "PANDA", "If interface not opac, we get the branch we pass one in if context not set");

    C4::Context->interface( 'opac' );

    t::lib::Mocks::mock_preference('OpacRenewalBranch', undef);
    is( $item->renewal_branchcode, 'OPACRenew', "If interface opac and OpacRenewalBranch undef, we get OPACRenew");
    is( $item->renewal_branchcode({branch=>'COW'}), 'OPACRenew', "If interface opac and OpacRenewalBranch undef, we get OPACRenew even if branch passed");

    t::lib::Mocks::mock_preference('OpacRenewalBranch', 'none');
    is( $item->renewal_branchcode, '', "If interface opac and OpacRenewalBranch is none, we get blank string");
    is( $item->renewal_branchcode({branch=>'COW'}), '', "If interface opac and OpacRenewalBranch is none, we get blank string even if branch passed");

    t::lib::Mocks::mock_preference('OpacRenewalBranch', 'checkoutbranch');
    is( $item->renewal_branchcode, $checkout->branchcode, "If interface opac and OpacRenewalBranch set to checkoutbranch, we get branch of checkout");
    is( $item->renewal_branchcode({branch=>'MONKEY'}), $checkout->branchcode, "If interface opac and OpacRenewalBranch set to checkoutbranch, we get branch of checkout even if branch passed");

    t::lib::Mocks::mock_preference('OpacRenewalBranch','patronhomebranch');
    is( $item->renewal_branchcode, $checkout->patron->branchcode, "If interface opac and OpacRenewalBranch set to patronbranch, we get branch of patron");
    is( $item->renewal_branchcode({branch=>'TURKEY'}), $checkout->patron->branchcode, "If interface opac and OpacRenewalBranch set to patronbranch, we get branch of patron even if branch passed");

    t::lib::Mocks::mock_preference('OpacRenewalBranch','itemhomebranch');
    is( $item->renewal_branchcode, $item->homebranch, "If interface opac and OpacRenewalBranch set to itemhomebranch, we get homebranch of item");
    is( $item->renewal_branchcode({branch=>'MANATEE'}), $item->homebranch, "If interface opac and OpacRenewalBranch set to itemhomebranch, we get homebranch of item even if branch passed");

    $schema->storage->txn_rollback;
};

subtest 'Tests for itemtype' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $item = $builder->build_sample_item({ biblionumber => $biblio->biblionumber, itype => $itemtype->itemtype });

    t::lib::Mocks::mock_preference('item-level_itypes', 1);
    is( $item->itemtype->itemtype, $item->itype, 'Pref enabled' );
    t::lib::Mocks::mock_preference('item-level_itypes', 0);
    is( $item->itemtype->itemtype, $biblio->biblioitem->itemtype, 'Pref disabled' );

    $schema->storage->txn_rollback;
};

subtest 'get_transfers' => sub {
    plan tests => 16;
    $schema->storage->txn_begin;

    my $item = $builder->build_sample_item();

    my $transfers = $item->get_transfers();
    is(ref($transfers), 'Koha::Item::Transfers', 'Koha::Item->get_transfer should return a Koha::Item::Transfers object' );
    is($transfers->count, 0, 'When no transfers exist, the Koha::Item:Transfers object should be empty');

    my $library_to = $builder->build_object( { class => 'Koha::Libraries' } );

    my $transfer_1 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                frombranch    => $item->holdingbranch,
                tobranch      => $library_to->branchcode,
                reason        => 'Manual',
                datesent      => undef,
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );

    $transfers = $item->get_transfers();
    is($transfers->count, 1, 'When one transfer has been requested, the Koha::Item:Transfers object should contain one result');

    my $transfer_2 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                frombranch    => $item->holdingbranch,
                tobranch      => $library_to->branchcode,
                reason        => 'Manual',
                datesent      => undef,
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );

    my $transfer_3 = $builder->build_object(
        {
            class => 'Koha::Item::Transfers',
            value => {
                itemnumber    => $item->itemnumber,
                frombranch    => $item->holdingbranch,
                tobranch      => $library_to->branchcode,
                reason        => 'Manual',
                datesent      => undef,
                datearrived   => undef,
                datecancelled => undef,
                daterequested => \'NOW()'
            }
        }
    );

    $transfers = $item->get_transfers();
    is($transfers->count, 3, 'When there are multiple open transfer requests, the Koha::Item::Transfers object contains them all');
    my $result_1 = $transfers->next;
    my $result_2 = $transfers->next;
    my $result_3 = $transfers->next;
    is( $result_1->branchtransfer_id, $transfer_1->branchtransfer_id, 'Koha::Item->get_transfers returns the oldest transfer request first');
    is( $result_2->branchtransfer_id, $transfer_2->branchtransfer_id, 'Koha::Item->get_transfers returns the newer transfer request second');
    is( $result_3->branchtransfer_id, $transfer_3->branchtransfer_id, 'Koha::Item->get_transfers returns the newest transfer request last');

    $transfer_2->datesent(\'NOW()')->store;
    $transfers = $item->get_transfers();
    is($transfers->count, 3, 'When one transfer is set to in_transit, the Koha::Item::Transfers object still contains them all');
    $result_1 = $transfers->next;
    $result_2 = $transfers->next;
    $result_3 = $transfers->next;
    is( $result_1->branchtransfer_id, $transfer_2->branchtransfer_id, 'Koha::Item->get_transfers returns the active transfer request first');
    is( $result_2->branchtransfer_id, $transfer_1->branchtransfer_id, 'Koha::Item->get_transfers returns the other transfers oldest to newest');
    is( $result_3->branchtransfer_id, $transfer_3->branchtransfer_id, 'Koha::Item->get_transfers returns the other transfers oldest to newest');

    $transfer_2->datearrived(\'NOW()')->store;
    $transfers = $item->get_transfers();
    is($transfers->count, 2, 'Once a transfer is received, it no longer appears in the list from ->get_transfers()');
    $result_1 = $transfers->next;
    $result_2 = $transfers->next;
    is( $result_1->branchtransfer_id, $transfer_1->branchtransfer_id, 'Koha::Item->get_transfers returns the other transfers oldest to newest');
    is( $result_2->branchtransfer_id, $transfer_3->branchtransfer_id, 'Koha::Item->get_transfers returns the other transfers oldest to newest');

    $transfer_1->datecancelled(\'NOW()')->store;
    $transfers = $item->get_transfers();
    is($transfers->count, 1, 'Once a transfer is cancelled, it no longer appears in the list from ->get_transfers()');
    $result_1 = $transfers->next;
    is( $result_1->branchtransfer_id, $transfer_3->branchtransfer_id, 'Koha::Item->get_transfers returns the only transfer that remains');

    $schema->storage->txn_rollback;
};

subtest 'Tests for relationship between item and item_orders via aqorders_item' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    my $orders = $item->orders;
    is ($orders->count, 0, 'No order on this item yet');

    my $order_note = 'Order for ' . $item->itemnumber;

    my $aq_order1 = $builder->build_object({
        class => 'Koha::Acquisition::Orders',
        value  => {
            biblionumber => $biblio->biblionumber,
            order_internalnote => $order_note,
        },
    });
    my $aq_order2 = $builder->build_object({
        class => 'Koha::Acquisition::Orders',
        value  => {
            biblionumber => $biblio->biblionumber,
        },
    });
    my $aq_order_item1 = $builder->build({
        source => 'AqordersItem',
        value  => {
            ordernumber => $aq_order1->ordernumber,
            itemnumber => $item->itemnumber,
        },
    });

    $orders = $item->orders;
    is ($orders->count, 1, 'One order found by item with the relationship');
    is ($orders->next->order_internalnote, $order_note, 'Correct order found by item with the relationship');
};

subtest 'move_to_biblio() tests' => sub {
    plan tests => 16;

    $schema->storage->txn_begin;

    my $dbh = C4::Context->dbh;

    my $source_biblio = $builder->build_sample_biblio();
    my $target_biblio = $builder->build_sample_biblio();

    my $source_biblionumber = $source_biblio->biblionumber;
    my $target_biblionumber = $target_biblio->biblionumber;

    my $item1 = $builder->build_sample_item({ biblionumber => $source_biblionumber });
    my $item2 = $builder->build_sample_item({ biblionumber => $source_biblionumber });
    my $item3 = $builder->build_sample_item({ biblionumber => $source_biblionumber });

    my $itemnumber1 = $item1->itemnumber;
    my $itemnumber2 = $item2->itemnumber;

    my $library = $builder->build_object({ class => 'Koha::Libraries' });

    my $patron = $builder->build_object({
        class => 'Koha::Patrons',
        value => { branchcode => $library->branchcode }
    });
    my $borrowernumber = $patron->borrowernumber;

    my $aq_budget = $builder->build({
        source => 'Aqbudget',
        value  => {
            budget_notes => 'test',
        },
    });

    my $aq_order1 = $builder->build_object({
        class => 'Koha::Acquisition::Orders',
        value  => {
            biblionumber => $source_biblionumber,
            budget_id => $aq_budget->{budget_id},
        },
    });
    my $aq_order_item1 = $builder->build({
        source => 'AqordersItem',
        value  => {
            ordernumber => $aq_order1->ordernumber,
            itemnumber => $itemnumber1,
        },
    });
    my $aq_order2 = $builder->build_object({
        class => 'Koha::Acquisition::Orders',
        value  => {
            biblionumber => $source_biblionumber,
            budget_id => $aq_budget->{budget_id},
        },
    });
    my $aq_order_item2 = $builder->build({
        source => 'AqordersItem',
        value  => {
            ordernumber => $aq_order2->ordernumber,
            itemnumber => $itemnumber2,
        },
    });

    my $bib_level_hold = $builder->build_object({
        class => 'Koha::Holds',
        value  => {
            biblionumber => $source_biblionumber,
            itemnumber => undef,
        },
    });
    my $item_level_hold1 = $builder->build_object({
        class => 'Koha::Holds',
        value  => {
            biblionumber => $source_biblionumber,
            itemnumber => $itemnumber1,
        },
    });
    my $item_level_hold2 = $builder->build_object({
        class => 'Koha::Holds',
        value  => {
            biblionumber => $source_biblionumber,
            itemnumber => $itemnumber2,
        }
    });

    my $tmp_holdsqueue1 = $builder->build({
        source => 'TmpHoldsqueue',
        value  => {
            borrowernumber => $borrowernumber,
            biblionumber   => $source_biblionumber,
            itemnumber     => $itemnumber1,
        }
    });
    my $tmp_holdsqueue2 = $builder->build({
        source => 'TmpHoldsqueue',
        value  => {
            borrowernumber => $borrowernumber,
            biblionumber   => $source_biblionumber,
            itemnumber     => $itemnumber2,
        }
    });
    my $hold_fill_target1 = $builder->build({
        source => 'HoldFillTarget',
        value  => {
            borrowernumber     => $borrowernumber,
            biblionumber       => $source_biblionumber,
            itemnumber         => $itemnumber1,
        }
    });
    my $hold_fill_target2 = $builder->build({
        source => 'HoldFillTarget',
        value  => {
            borrowernumber     => $borrowernumber,
            biblionumber       => $source_biblionumber,
            itemnumber         => $itemnumber2,
        }
    });
    my $linktracker1 = $builder->build({
        source => 'Linktracker',
        value  => {
            borrowernumber     => $borrowernumber,
            biblionumber       => $source_biblionumber,
            itemnumber         => $itemnumber1,
        }
    });
    my $linktracker2 = $builder->build({
        source => 'Linktracker',
        value  => {
            borrowernumber     => $borrowernumber,
            biblionumber       => $source_biblionumber,
            itemnumber         => $itemnumber2,
        }
    });

    my $to_biblionumber_after_move = $item1->move_to_biblio($target_biblio);
    is($to_biblionumber_after_move, $target_biblionumber, 'move_to_biblio returns the target biblionumber if success');

    $to_biblionumber_after_move = $item1->move_to_biblio($target_biblio);
    is($to_biblionumber_after_move, undef, 'move_to_biblio returns undef if the move has failed. If called twice, the item is not attached to the first biblio anymore');

    my $get_item1 = Koha::Items->find( $item1->itemnumber );
    is($get_item1->biblionumber, $target_biblionumber, 'item1 is moved');
    my $get_item2 = Koha::Items->find( $item2->itemnumber );
    is($get_item2->biblionumber, $source_biblionumber, 'item2 is not moved');
    my $get_item3 = Koha::Items->find( $item3->itemnumber );
    is($get_item3->biblionumber, $source_biblionumber, 'item3 is not moved');

    $aq_order1->discard_changes;
    $aq_order2->discard_changes;
    is($aq_order1->biblionumber, $target_biblionumber, 'move_to_biblio moves aq_orders for item 1');
    is($aq_order2->biblionumber, $source_biblionumber, 'move_to_biblio does not move aq_orders for item 2');

    $bib_level_hold->discard_changes;
    $item_level_hold1->discard_changes;
    $item_level_hold2->discard_changes;
    is($bib_level_hold->biblionumber,   $source_biblionumber, 'move_to_biblio does not move the biblio-level hold');
    is($item_level_hold1->biblionumber, $target_biblionumber, 'move_to_biblio moves the item-level hold placed on item 1');
    is($item_level_hold2->biblionumber, $source_biblionumber, 'move_to_biblio does not move the item-level hold placed on item 2');

    my $get_tmp_holdsqueue1 = $schema->resultset('TmpHoldsqueue')->search({ itemnumber => $tmp_holdsqueue1->{itemnumber} })->single;
    my $get_tmp_holdsqueue2 = $schema->resultset('TmpHoldsqueue')->search({ itemnumber => $tmp_holdsqueue2->{itemnumber} })->single;
    is($get_tmp_holdsqueue1->biblionumber->biblionumber, $target_biblionumber, 'move_to_biblio moves tmp_holdsqueue for item 1');
    is($get_tmp_holdsqueue2->biblionumber->biblionumber, $source_biblionumber, 'move_to_biblio does not move tmp_holdsqueue for item 2');

    my $get_hold_fill_target1 = $schema->resultset('HoldFillTarget')->search({ itemnumber => $hold_fill_target1->{itemnumber} })->single;
    my $get_hold_fill_target2 = $schema->resultset('HoldFillTarget')->search({ itemnumber => $hold_fill_target2->{itemnumber} })->single;
    # Why does ->biblionumber return a Biblio object???
    is($get_hold_fill_target1->biblionumber->biblionumber, $target_biblionumber, 'move_to_biblio moves hold_fill_targets for item 1');
    is($get_hold_fill_target2->biblionumber->biblionumber, $source_biblionumber, 'move_to_biblio does not move hold_fill_targets for item 2');

    my $get_linktracker1 = $schema->resultset('Linktracker')->search({ itemnumber => $linktracker1->{itemnumber} })->single;
    my $get_linktracker2 = $schema->resultset('Linktracker')->search({ itemnumber => $linktracker2->{itemnumber} })->single;
    is($get_linktracker1->biblionumber->biblionumber, $target_biblionumber, 'move_to_biblio moves linktracker for item 1');
    is($get_linktracker2->biblionumber->biblionumber, $source_biblionumber, 'move_to_biblio does not move linktracker for item 2');

    $schema->storage->txn_rollback;
};

subtest 'columns_to_str' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache("MarcStructure-0-");
    $cache->clear_from_cache("MarcStructure-1-");
    $cache->clear_from_cache("MarcSubfieldStructure-");

    # Creating subfields 'é', 'è' that are not linked with a kohafield
    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield => $itemtag,
            tagsubfield => ['é', 'è'],
        }
    )->delete;    # In case it exist already

    # é is not linked with a AV
    # è is linked with AV branches
    Koha::MarcSubfieldStructure->new(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => 'é',
            kohafield     => undef,
            repeatable    => 1,
            defaultvalue  => 'ééé',
            tab           => 10,
        }
    )->store;
    Koha::MarcSubfieldStructure->new(
        {
            frameworkcode    => '',
            tagfield         => $itemtag,
            tagsubfield      => 'è',
            kohafield        => undef,
            repeatable       => 1,
            defaultvalue     => 'èèè',
            tab              => 10,
            authorised_value => 'branches',
        }
    )->store;

    my $biblio = $builder->build_sample_biblio({ frameworkcode => '' });
    my $item = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $lost_av = $builder->build_object({ class => 'Koha::AuthorisedValues', value => { category => 'LOST', authorised_value => '42' }});
    my $dateaccessioned = '2020-12-15';
    my $library = Koha::Libraries->search->next;
    my $branchcode = $library->branchcode;

    my $some_marc_xml = qq{<?xml version="1.0" encoding="UTF-8"?>
<collection
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
  xmlns="http://www.loc.gov/MARC21/slim">

<record>
  <leader>         a              </leader>
  <datafield tag="999" ind1=" " ind2=" ">
    <subfield code="é">value é</subfield>
    <subfield code="è">$branchcode</subfield>
  </datafield>
</record>

</collection>};

    $item->update(
        {
            itemlost           => $lost_av->authorised_value,
            dateaccessioned    => $dateaccessioned,
            more_subfields_xml => $some_marc_xml,
        }
    );

    $item = $item->get_from_storage;

    my $s = $item->columns_to_str;
    is( $s->{itemlost}, $lost_av->lib, 'Attributes linked with AV replaced with description' );
    is( $s->{dateaccessioned}, '2020-12-15', 'Date attributes iso formatted');
    is( $s->{'é'}, 'value é', 'subfield ok with more than a-Z');
    is( $s->{'è'}, $library->branchname );

    $cache->clear_from_cache("MarcStructure-0-");
    $cache->clear_from_cache("MarcStructure-1-");
    $cache->clear_from_cache("MarcSubfieldStructure-");

    $schema->storage->txn_rollback;

};

subtest 'strings_map() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");

    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache("MarcStructure-0-");
    $cache->clear_from_cache("MarcStructure-1-");
    $cache->clear_from_cache("MarcSubfieldStructure-");

    # Recreating subfields just to be sure tests will be ok
    # 1 => av (LOST)
    # 3 => no link
    # a => branches
    # y => itemtypes
    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => [ '1', '2', '3', 'a', 'y' ],
        }
    )->delete;    # In case it exist already

    Koha::MarcSubfieldStructure->new(
        {
            authorised_value => 'LOST',
            defaultvalue     => '',
            frameworkcode    => '',
            kohafield        => 'items.itemlost',
            repeatable       => 1,
            tab              => 10,
            tagfield         => $itemtag,
            tagsubfield      => '1',
        }
    )->store;
    Koha::MarcSubfieldStructure->new(
        {
            authorised_value => 'cn_source',
            defaultvalue     => '',
            frameworkcode    => '',
            kohafield        => 'items.cn_source',
            repeatable       => 1,
            tab              => 10,
            tagfield         => $itemtag,
            tagsubfield      => '2',
        }
    )->store;
    Koha::MarcSubfieldStructure->new(
        {
            authorised_value => '',
            defaultvalue     => '',
            frameworkcode    => '',
            kohafield        => 'items.materials',
            repeatable       => 1,
            tab              => 10,
            tagfield         => $itemtag,
            tagsubfield      => '3',
        }
    )->store;
    Koha::MarcSubfieldStructure->new(
        {
            authorised_value => 'branches',
            defaultvalue     => '',
            frameworkcode    => '',
            kohafield        => 'items.homebranch',
            repeatable       => 1,
            tab              => 10,
            tagfield         => $itemtag,
            tagsubfield      => 'a',
        }
    )->store;
    Koha::MarcSubfieldStructure->new(
        {
            authorised_value => 'itemtypes',
            defaultvalue     => '',
            frameworkcode    => '',
            kohafield        => 'items.itype',
            repeatable       => 1,
            tab              => 10,
            tagfield         => $itemtag,
            tagsubfield      => 'y',
        }
    )->store;

    my $itype   = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $biblio  = $builder->build_sample_biblio( { frameworkcode => '' } );
    my $item    = $builder->build_sample_item(
        {
            biblionumber => $biblio->id,
            library      => $library->id
        }
    );

    Koha::AuthorisedValues->search( { authorised_value => 3, category => 'LOST' } )->delete;
    my $lost_av = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 3,
                category         => 'LOST',
                lib              => 'internal description',
                lib_opac         => 'public description',
            }
        }
    );

    my $class_sort_rule  = $builder->build_object( { class => 'Koha::ClassSortRules', value => { sort_routine => 'Generic' } } );
    my $class_split_rule = $builder->build_object( { class => 'Koha::ClassSplitRules' } );
    my $class_source     = $builder->build_object(
        {
            class => 'Koha::ClassSources',
            value => {
                class_sort_rule  => $class_sort_rule->class_sort_rule,
                class_split_rule => $class_split_rule->class_split_rule,
            }
        }
    );

    $item->set(
        {
            cn_source => $class_source->id,
            itemlost  => $lost_av->authorised_value,
            itype     => $itype->itemtype,
            materials => 'Suff',
        }
    )->store->discard_changes;

    my $strings = $item->strings_map;

    subtest 'unmapped field tests' => sub {

        plan tests => 1;

        ok( !exists $strings->{materials}, "Unmapped field not present" );
    };

    subtest 'av handling' => sub {

        plan tests => 4;

        ok( exists $strings->{itemlost}, "'itemlost' entry exists" );
        is( $strings->{itemlost}->{str},      $lost_av->lib, "'str' set to av->lib" );
        is( $strings->{itemlost}->{type},     'av',          "'type' is 'av'" );
        is( $strings->{itemlost}->{category}, 'LOST',        "'category' exists and set to 'LOST'" );
    };

    subtest 'cn_source handling' => sub {

        plan tests => 3;

        ok( exists $strings->{cn_source}, "'cn_source' entry exists" );
        is( $strings->{cn_source}->{str},  $class_source->description,    "'str' set to \$class_source->description" );
        is( $strings->{cn_source}->{type}, 'call_number_source', "type is 'library'" );
    };

    subtest 'branches handling' => sub {

        plan tests => 3;

        ok( exists $strings->{homebranch}, "'homebranch' entry exists" );
        is( $strings->{homebranch}->{str},  $library->branchname, "'str' set to 'branchname'" );
        is( $strings->{homebranch}->{type}, 'library',            "type is 'library'" );
    };

    subtest 'itemtype handling' => sub {

        plan tests => 3;

        ok( exists $strings->{itype}, "'itype' entry exists" );
        is( $strings->{itype}->{str},  $itype->description, "'str' correctly set" );
        is( $strings->{itype}->{type}, 'item_type',         "'type' is 'item_type'" );
    };

    subtest 'public flag tests' => sub {

        plan tests => 4;

        $strings = $item->strings_map( { public => 1 } );

        ok( exists $strings->{itemlost}, "'itemlost' entry exists" );
        is( $strings->{itemlost}->{str},      $lost_av->lib_opac, "'str' set to av->lib" );
        is( $strings->{itemlost}->{type},     'av',               "'type' is 'av'" );
        is( $strings->{itemlost}->{category}, 'LOST',             "'category' exists and set to 'LOST'" );
    };

    $cache->clear_from_cache("MarcStructure-0-");
    $cache->clear_from_cache("MarcStructure-1-");
    $cache->clear_from_cache("MarcSubfieldStructure-");

    $schema->storage->txn_rollback;
};

subtest 'store() tests' => sub {

    plan tests => 3;

    subtest 'dateaccessioned handling' => sub {

        plan tests => 3;

        $schema->storage->txn_begin;

        my $item = $builder->build_sample_item;

        ok( defined $item->dateaccessioned, 'dateaccessioned is set' );

        # reset dateaccessioned on the DB
        $schema->resultset('Item')->find({ itemnumber => $item->id })->update({ dateaccessioned => undef });
        $item->discard_changes;

        ok( !defined $item->dateaccessioned );

        # update something
        $item->replacementprice(100)->store->discard_changes;

        ok( !defined $item->dateaccessioned, 'dateaccessioned not set on update if undefined' );

        $schema->storage->txn_rollback;
    };

    subtest '_set_found_trigger() tests' => sub {

        plan tests => 9;

        $schema->storage->txn_begin;

        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        my $item   = $builder->build_sample_item({ itemlost => 1, itemlost_on => dt_from_string() });

        # Add a lost item debit
        my $debit = $patron->account->add_debit(
            {
                amount    => 10,
                type      => 'LOST',
                item_id   => $item->id,
                interface => 'intranet',
            }
        );

        # Add a lost item processing fee
        my $processing_debit = $patron->account->add_debit(
            {
                amount    => 2,
                type      => 'PROCESSING',
                item_id   => $item->id,
                interface => 'intranet',
            }
        );

        my $lostreturn_policy = {
            lostreturn       => 'charge',
            processingreturn => 'refund'
        };

        my $mocked_circ_rules = Test::MockModule->new('Koha::CirculationRules');
        $mocked_circ_rules->mock( 'get_lostreturn_policy', sub { return $lostreturn_policy; } );

        # simulate it was found
        $item->set( { itemlost => 0 } )->store;

        my $messages = $item->object_messages;

        my $message_1 = $messages->[0];

        is( $message_1->type,    'info',          'type is correct' );
        is( $message_1->message, 'lost_refunded', 'message is correct' );

        # Find the refund credit
        my $credit = $debit->credits->next;

        is_deeply(
            $message_1->payload,
            { credit_id => $credit->id },
            'type is correct'
        );

        my $message_2 = $messages->[1];

        is( $message_2->type,    'info',        'type is correct' );
        is( $message_2->message, 'lost_charge', 'message is correct' );
        is( $message_2->payload, undef,         'no payload' );

        my $message_3 = $messages->[2];
        is( $message_3->message, 'processing_refunded', 'message is correct' );

        my $processing_credit = $processing_debit->credits->next;
        is_deeply(
            $message_3->payload,
            { credit_id => $processing_credit->id },
            'type is correct'
        );

        # Let's build a new item
        $item   = $builder->build_sample_item({ itemlost => 1, itemlost_on => dt_from_string() });
        $item->set( { itemlost => 0 } )->store;

        $messages = $item->object_messages;
        is( scalar @{$messages}, 0, 'This item has no history, no associated lost fines, presumed not lost by patron, no messages returned');

        $schema->storage->txn_rollback;
    };

    subtest 'holds_queue update tests' => sub {

        plan tests => 2;

        $schema->storage->txn_begin;

        my $biblio = $builder->build_sample_biblio;

        my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
        $mock->mock( 'enqueue', sub {
            my ( $self, $args ) = @_;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                '->store triggers a holds queue update for the related biblio'
            );
        } );

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

        # new item
        my $item = $builder->build_sample_item({ biblionumber => $biblio->id });

        # updated item
        $item->set({ reserves => 1 })->store;

        t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );
        # updated item
        $item->set({ reserves => 0 })->store;

        $schema->storage->txn_rollback;
    };
};

subtest 'Recalls tests' => sub {

    plan tests => 22;

    $schema->storage->txn_begin;

    my $item1 = $builder->build_sample_item;
    my $biblio = $item1->biblio;
    my $branchcode = $item1->holdingbranch;
    my $patron1 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $branchcode } });
    my $patron2 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $branchcode } });
    my $patron3 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $branchcode } });
    my $item2 = $builder->build_object(
        {   class => 'Koha::Items',
            value => { holdingbranch => $branchcode, homebranch => $branchcode, biblionumber => $biblio->biblionumber, itype => $item1->effective_itemtype }
        }
    );

    t::lib::Mocks::mock_userenv( { patron => $patron1 } );
    t::lib::Mocks::mock_preference('UseRecalls', 1);

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
            item_id           => $item1->itemnumber,
            expiration_date   => undef,
            item_level        => 1
        }
    )->store;

    is( $item1->recall->patron_id, $patron1->borrowernumber, 'Correctly returns most relevant recall' );

    $recall2->set_cancelled;

    t::lib::Mocks::mock_preference('UseRecalls', 0);
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall with UseRecalls disabled" );

    t::lib::Mocks::mock_preference("UseRecalls", 1);

    $item1->update({ notforloan => 1 });
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall that is not for loan" );
    $item1->update({ notforloan => 0, itemlost => 1 });
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall that is marked lost" );
    $item1->update({ itemlost => 0, withdrawn => 1 });
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall that is withdrawn" );
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall item if not checked out" );

    $item1->update({ withdrawn => 0 });
    C4::Circulation::AddIssue( $patron2->unblessed, $item1->barcode );

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
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if recalls_allowed = 0" );

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
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if patron has more existing recall(s) than recalls_allowed" );
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if patron has more existing recall(s) than recalls_per_record" );
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if patron has already recalled this item" );

    my $reserve_id = C4::Reserves::AddReserve({ branchcode => $branchcode, borrowernumber => $patron1->borrowernumber, biblionumber => $item1->biblionumber, itemnumber => $item1->itemnumber });
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall item if patron has already reserved it" );
    C4::Reserves::ModReserve({ rank => 'del', reserve_id => $reserve_id, branchcode => $branchcode, itemnumber => $item1->itemnumber, borrowernumber => $patron1->borrowernumber, biblionumber => $item1->biblionumber });

    $recall1->set_cancelled;
    is( $item1->can_be_recalled({ patron => $patron2 }), 0, "Can't recall if patron has already checked out an item attached to this biblio" );

    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if on_shelf_recalls = all and items are still available" );

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
    C4::Circulation::AddReturn( $item1->barcode, $branchcode );
    is( $item1->can_be_recalled({ patron => $patron1 }), 0, "Can't recall if no items are checked out" );

    C4::Circulation::AddIssue( $patron2->unblessed, $item1->barcode );
    is( $item1->can_be_recalled({ patron => $patron1 }), 1, "Can recall item" );

    $recall1 = Koha::Recall->new(
        {   patron_id         => $patron1->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => undef,
            expiration_date   => undef,
            item_level        => 0
        }
    )->store;

    # Patron2 has Item1 checked out. Patron1 has placed a biblio-level recall on Biblio1, so check if Item1 can fulfill Patron1's recall.

    Koha::CirculationRules->set_rules({
        branchcode => undef,
        categorycode => undef,
        itemtype => $item1->effective_itemtype,
        rules => {
            recalls_allowed => 0,
            recalls_per_record => 1,
            on_shelf_recalls => 'any',
        },
    });
    is( $item1->can_be_waiting_recall, 0, "Recalls not allowed for this itemtype" );

    Koha::CirculationRules->set_rules({
        branchcode => undef,
        categorycode => undef,
        itemtype => $item1->effective_itemtype,
        rules => {
            recalls_allowed => 1,
            recalls_per_record => 1,
            on_shelf_recalls => 'any',
        },
    });
    is( $item1->can_be_waiting_recall, 1, "Recalls are allowed for this itemtype" );

    # check_recalls tests

    $recall1 = Koha::Recall->new(
        {   patron_id         => $patron2->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => $item1->itemnumber,
            expiration_date   => undef,
            item_level        => 1
        }
    )->store;
    $recall2 = Koha::Recall->new(
        {   patron_id         => $patron1->borrowernumber,
            created_date      => \'NOW()',
            biblio_id         => $biblio->biblionumber,
            pickup_library_id => $branchcode,
            item_id           => undef,
            expiration_date   => undef,
            item_level        => 0
        }
    )->store;
    $recall2->set_waiting( { item => $item1 } );
    is( $item1->has_pending_recall, 1, 'Item has pending recall' );

    # return a waiting recall
    my $check_recall = $item1->check_recalls;
    is( $check_recall->patron_id, $patron1->borrowernumber, "Waiting recall is highest priority and returned" );

    $recall2->revert_waiting;

    is( $item1->has_pending_recall, 0, 'Item does not have pending recall' );

    # return recall based on recalldate
    $check_recall = $item1->check_recalls;
    is( $check_recall->patron_id, $patron1->borrowernumber, "No waiting recall, so oldest recall is returned" );

    $recall1->set_cancelled;

    # return a biblio-level recall
    $check_recall = $item1->check_recalls;
    is( $check_recall->patron_id, $patron1->borrowernumber, "Only remaining recall is returned" );

    $recall2->set_cancelled;

    $schema->storage->txn_rollback;
};

subtest 'Notforloan tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $item1 = $builder->build_sample_item;
    $item1->update({ notforloan => 0 });
    $item1->itemtype->notforloan(0);
    is ( $item1->is_notforloan, 0, 'Notforloan is correctly false by item status and item type');
    $item1->update({ notforloan => 1 });
    is ( $item1->is_notforloan, 1, 'Notforloan is correctly true by item status');
    $item1->update({ notforloan => 0 });
    $item1->itemtype->update({ notforloan => 1 });
    is ( $item1->is_notforloan, 1, 'Notforloan is correctly true by item type');

    $schema->storage->txn_rollback;
};

subtest 'item_group() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    is( $item_1->item_group, undef, 'Item 1 has no item group');
    is( $item_2->item_group, undef, 'Item 2 has no item group');

    my $item_group_1 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();
    my $item_group_2 = Koha::Biblio::ItemGroup->new( { biblio_id => $biblio->id } )->store();

    $item_group_1->add_item({ item_id => $item_1->id });
    $item_group_2->add_item({ item_id => $item_2->id });

    is( $item_1->item_group->id, $item_group_1->id, 'Got item group 1 correctly' );
    is( $item_2->item_group->id, $item_group_2->id, 'Got item group 2 correctly' );

    $schema->storage->txn_rollback;
};

subtest 'has_pending_recall() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $item    = $builder->build_sample_item;
    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });

    t::lib::Mocks::mock_userenv({ branchcode => $library->branchcode });
    t::lib::Mocks::mock_preference( 'UseRecalls', 1 );

    C4::Circulation::AddIssue( $patron->unblessed, $item->barcode );

    my ($recall) = Koha::Recalls->add_recall({ biblio => $item->biblio, item => $item, patron => $patron });

    ok( !$item->has_pending_recall, 'The item has no pending recalls' );

    $recall->status('waiting')->store;

    ok( $item->has_pending_recall, 'The item has a pending recall' );

    $schema->storage->txn_rollback;
};

subtest 'is_denied_renewal' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;

    my $library = $builder->build_object({ class => 'Koha::Libraries'});

    my $deny_book = $builder->build_object({ class => 'Koha::Items', value => {
        homebranch => $library->branchcode,
        withdrawn => 1,
        itype => 'HIDE',
        location => 'PROC',
        itemcallnumber => undef,
        itemnotes => "",
        }
    });

    my $allow_book = $builder->build_object({ class => 'Koha::Items', value => {
        homebranch => $library->branchcode,
        withdrawn => 0,
        itype => 'NOHIDE',
        location => 'NOPROC'
        }
    });

    my $idr_rules = "";
    C4::Context->set_preference('ItemsDeniedRenewal', $idr_rules);
    is( $deny_book->is_denied_renewal, 0, 'Renewal allowed when no rules' );

    $idr_rules="withdrawn: [1]";
    C4::Context->set_preference('ItemsDeniedRenewal', $idr_rules);
    is( $deny_book->is_denied_renewal, 1, 'Renewal blocked when 1 rules (withdrawn)' );
    is( $allow_book->is_denied_renewal, 0, 'Renewal allowed when 1 rules not matched (withdrawn)' );

    $idr_rules="withdrawn: [1]\nitype: [HIDE,INVISIBLE]";
    is( $deny_book->is_denied_renewal, 1, 'Renewal blocked when 2 rules matched (withdrawn, itype)' );
    is( $allow_book->is_denied_renewal, 0, 'Renewal allowed when 2 rules not matched (withdrawn, itype)' );

    $idr_rules="withdrawn: [1]\nitype: [HIDE,INVISIBLE]\nlocation: [PROC]";
    C4::Context->set_preference('ItemsDeniedRenewal', $idr_rules);
    is( $deny_book->is_denied_renewal, 1, 'Renewal blocked when 3 rules matched (withdrawn, itype, location)' );
    is( $allow_book->is_denied_renewal, 0, 'Renewal allowed when 3 rules not matched (withdrawn, itype, location)' );

    $idr_rules="itemcallnumber: [NULL]";
    C4::Context->set_preference('ItemsDeniedRenewal', $idr_rules);
    is( $deny_book->is_denied_renewal, 1, 'Renewal blocked for undef when NULL in pref' );

    $idr_rules="itemcallnumber: ['']";
    C4::Context->set_preference('ItemsDeniedRenewal', $idr_rules);
    is( $deny_book->is_denied_renewal, 0, 'Renewal not blocked for undef when "" in pref' );

    $idr_rules="itemnotes: [NULL]";
    C4::Context->set_preference('ItemsDeniedRenewal', $idr_rules);
    is( $deny_book->is_denied_renewal, 0, 'Renewal not blocked for "" when NULL in pref' );

    $idr_rules="itemnotes: ['']";
    C4::Context->set_preference('ItemsDeniedRenewal', $idr_rules);
    is( $deny_book->is_denied_renewal, 1, 'Renewal blocked for empty string when "" in pref' );

    $schema->storage->txn_rollback;
};
