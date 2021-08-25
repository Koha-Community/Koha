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

use MARC::Record;
use Test::More tests => 4;
use Test::Warn;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::Libraries;
use Koha::ItemTypes;

BEGIN {
    use_ok('C4::XSLT', qw( transformMARCXML4XSLT getAuthorisedValues4MARCSubfields buildKohaItemsNamespace ));
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

subtest 'transformMARCXML4XSLT tests' => sub {
    plan tests => 8;
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itemtype_2 = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $branch = $builder->build_object({ class => 'Koha::Libraries' });
    my $branch_2 = $builder->build_object({ class => 'Koha::Libraries' });
    $itemtype_2->delete;
    $branch_2->delete;

    my $branches = { map { $_->branchcode => $_->branchname } Koha::Libraries->search({}, { order_by => 'branchname' })->as_list };
    my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search_with_localization->unblessed } };
    my $auth_val = $builder->build_object({ class => 'Koha::AuthorisedValues' });
    my $av = {
        942 => { 'n' => { category => "SUPPRESS", SUPPRESS => { 1 => 'banana' } } },
        952 => {
            'a' => { category => $auth_val->category, $auth_val->category => {
                $auth_val->authorised_value => $auth_val->unblessed
            }},
            'b' => { category => $auth_val->category, $auth_val->category => {
                $auth_val->authorised_value => $auth_val->unblessed
            }},
            'c' => { category => "branches" },
            'd' => { category => "itemtypes" }
        }
    };
    my $record = MARC::Record->new();
    my $suppress_field = MARC::Field->new( 942, ' ', ' ', n => '1' );
    my $mapped_field = MARC::Field->new( 952, ' ', ' ',
        a => $auth_val->authorised_value,
        b => "POTATO",
        c => $branch->branchcode,
        d => $itemtype->itemtype
    );
    $record->append_fields( ($suppress_field, $mapped_field ) );
    C4::XSLT::transformMARCXML4XSLT( 3, $record, 0, $branches, $itemtypes, $av );
    is($record->subfield( '942', 'n' ),1,'942$n is not transformed');
    is($record->subfield( '952', 'a' ),$auth_val->lib,'952$a is transformed when value found');
    is($record->subfield( '952', 'b' ),'POTATO','952$b is not transformed when value not found');
    is($record->subfield( '952', 'c' ),$branch->branchname,'952$c is transformed when valid branchcode');
    is($record->subfield( '952', 'd' ),$itemtype->translated_description,'952$d is transformed when valid itemtype');

    $av->{952}->{a}->{$auth_val->category}->{$auth_val->authorised_value}->{lib} = "";
    $record->field(952)->update( a => $auth_val->authorised_value, c => $branch_2->branchcode, d => $itemtype_2->itemtype );
    C4::XSLT::transformMARCXML4XSLT( 3, $record, $branches, $itemtypes, $av );
    is($record->subfield( '952', 'a' ),$auth_val->authorised_value,'952$a is not transformed when value found but blank');
    is($record->subfield( '952', 'c' ),$branch_2->branchcode,'952$c is returned unaltered invalid branchcode');
    is($record->subfield( '952', 'd' ),$itemtype_2->itemtype,'952$d is returned unaltered when invalid itemtype');


};

subtest 'buildKohaItemsNamespace status tests' => sub {
    plan tests => 17;

    t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '1|2');
    t::lib::Mocks::mock_preference( 'OPACResultsLibrary', 'holdingbranch' );
    t::lib::Mocks::mock_preference( 'OPACResultsMaxItems', '2' );

    my $itype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $holdinglibrary = $builder->build_object({ class => 'Koha::Libraries' });
    my $item = $builder->build_sample_item({ itype => $itype->itemtype });
    $item->holdingbranch( $holdinglibrary->branchcode )->store;
    $item->biblioitem->itemtype($itemtype->itemtype)->store;

    my $branches = { map { $_->branchcode => $_->branchname } Koha::Libraries->search({}, { order_by => 'branchname' })->as_list };
    my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search->unblessed } };
    my $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, undef, $branches, $itemtypes);
    like($xml,qr{<status>available</status>},"Item is available when no other status applied");

    # notforloan
    {
        t::lib::Mocks::mock_preference('item-level_itypes', 0);
        $item->notforloan(0)->store;
        Koha::ItemTypes->find($item->itype)->notforloan(0)->store;
        Koha::ItemTypes->find($item->biblioitem->itemtype)->notforloan(1)->store;
        $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search->unblessed } };
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
        like($xml,qr{<status>reference</status>},"reference if positive itype notforloan value");

        t::lib::Mocks::mock_preference('item-level_itypes', 1);
        Koha::ItemTypes->find($item->itype)->notforloan(1)->store;
        Koha::ItemTypes->find($item->biblioitem->itemtype)->notforloan(0)->store;
        $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search->unblessed } };
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
        like($xml,qr{<status>reference</status>},"reference if positive itemtype notforloan value");
        Koha::ItemTypes->find($item->itype)->notforloan(0)->store;

        my $substatus = Koha::AuthorisedValues->search({ category => 'NOT_LOAN', authorised_value => -1 })->next->lib;
        $item->notforloan(-1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
        like($xml,qr{<status>reallynotforloan</status>},"reallynotforloan if negative notforloan value");
        like($xml,qr{<substatus>$substatus</substatus>},"substatus set if negative notforloan value");

        $item->notforloan(1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
        like($xml,qr{<status>reference</status>},"reference if positive notforloan value");

        # But now make status notforloan==1 count under Not available
        t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '2');
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
        like($xml,qr{<status>reallynotforloan</status>},"reallynotforloan when we change Reference_NFL_Statuses");
        t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '1|2');
    }

    $item->onloan('2001-01-01')->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
    like( $xml, qr/<status>other<\/status>/, "Checked out is part of other statuses" );
    like($xml,qr{<substatus>Checked out</substatus>},"Checked out status takes precedence over Not for loan");

    $item->withdrawn(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
    like($xml,qr{<substatus>Withdrawn</substatus>},"Withdrawn status takes precedence over Checked out");

    $item->itemlost(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
    like($xml,qr{<substatus>Lost</substatus>},"Lost status takes precedence over Withdrawn");

    $item->damaged(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
    like($xml,qr{<substatus>Damaged</substatus>},"Damaged status takes precedence over Lost");

    $builder->build({ source => "Branchtransfer", value => {
        itemnumber  => $item->itemnumber,
        datearrived => undef,
        datecancelled => undef,
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
    like($xml,qr{<substatus>In transit</substatus>},"In-transit status takes precedence over Damaged");

    my $hold = $builder->build_object({ class => 'Koha::Holds', value => {
        biblionumber => $item->biblionumber,
        itemnumber   => $item->itemnumber,
        found        => 'W',
        priority     => 0,
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
    like($xml,qr{<substatus>Hold waiting</substatus>},"Waiting status takes precedence over In transit");
    $hold->cancel;

    $builder->build({ source => "TmpHoldsqueue", value => {
        itemnumber => $item->itemnumber
        }
    });

    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[], undef, $branches, $itemtypes);
    like($xml,qr{<substatus>Pending hold</substatus>},"Pending status takes precedence over all");
    my $library_name = $holdinglibrary->branchname;
    like($xml,qr{<resultbranch>${library_name}</resultbranch>}, "Found resultbranch / holding branch" );

    t::lib::Mocks::mock_preference('UseRecalls', 1);
    my $recall = $builder->build_object({ class => 'Koha::Recalls', value => {
        biblionumber    => $item->biblionumber,
        itemnumber      => $item->itemnumber,
        branchcode      => $item->holdingbranch,
    }});
    $recall->set_waiting;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>Recall waiting</substatus>},"Waiting status takes precedence over In transit (recalls)");
    t::lib::Mocks::mock_preference('UseRecalls', 0);

};

$schema->storage->txn_rollback;

subtest 'buildKohaItemsNamespace() including/omitting items tests' => sub {

    plan tests => 23;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    my $biblio2 = $builder->build_sample_biblio;

    # Have two known libraries for testing purposes
    my $library_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_3 = $builder->build_object({ class => 'Koha::Libraries' });

    my $item_1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber, library => $library_1->id });
    my $item_2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber, library => $library_2->id });
    my $item_3 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber, library => $library_3->id });

    my $items_rs = $biblio->items->search({ "me.itemnumber" => { '!=' => $item_3->itemnumber } });

    my $branches = { map { $_->branchcode => $_->branchname } Koha::Libraries->search({}, { order_by => 'branchname' })->as_list };
    my $itemtypes = { map { $_->{itemtype} => $_ } @{ Koha::ItemTypes->search->unblessed } };

    ## Test passing items_rs only
    my $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, undef, $items_rs, $branches, $itemtypes );

    my $library_1_name = $library_1->branchname;
    my $library_2_name = $library_2->branchname;
    my $library_3_name = $library_3->branchname;

    like(   $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );

    t::lib::Mocks::mock_preference('OpacHiddenItems', 'biblionumber: ['.$biblio2->biblionumber.']');
    my $hid_rs = $biblio->items->search({ "me.itemnumber" => { '!=' => $item_3->itemnumber } })->filter_by_visible_in_opac();
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, undef, $hid_rs, $branches, $itemtypes );
    like(   $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );

    ## Test passing one item in hidden_items and items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber ], $items_rs->reset, $branches, $itemtypes );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );

    ## Test passing both items in hidden_items and items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber, $item_2->itemnumber ], $items_rs->reset, $branches, $itemtypes );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );
    is( $xml, '<items xmlns="http://www.koha-community.org/items"></items>', 'Empty XML' );

    ## Test passing both items in hidden_items and no items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber, $item_2->itemnumber, $item_3->itemnumber ], $branches, $itemtypes );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );
    is( $xml, '<items xmlns="http://www.koha-community.org/items"></items>', 'Empty XML' );

    ## Test passing one item in hidden_items and items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber ], undef, $branches, $itemtypes );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    like(   $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 present in the XML' );

    ## Test not passing any param
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, undef, undef, $branches, $itemtypes );

    like( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 present in the XML' );
    like( $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    like( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 present in the XML' );

    $schema->storage->txn_rollback;
};
