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

use File::Temp;
use File::Path qw/make_path/;
use MARC::Record;
use Test::More tests => 4;
use Test::Warn;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;
use Koha::Libraries;
use Koha::ItemTypes;

BEGIN {
    use_ok('C4::XSLT', qw( buildKohaItemsNamespace ));
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Tests moved from t' => sub {
    plan tests => 8;
    $schema->storage->txn_begin;

    my $dir = File::Temp->newdir();
    my @themes = ('prog', 'test');
    my @langs = ('en', 'es-ES');

    # create temporary files to be tested later
    foreach my $theme (@themes) {
        foreach my $lang (@langs) {
            make_path("$dir/$theme/$lang/xslt");
            open my $fh, '>', "$dir/$theme/$lang/xslt/my_file.xslt";
            print $fh "Theme $theme, language $lang";
            close $fh;
        }
    }

    sub find_and_slurp {
        my ($dir, $theme, $lang) = @_;

        my $filename = C4::XSLT::_get_best_default_xslt_filename($dir, $theme, $lang, 'my_file.xslt');
        open my $fh, '<', $filename;
        my $str = <$fh>;
        close $fh;
        return $str;
    }

    # These tests verify that we're finding the right XSLT file when present,
    # and falling back to the right XSLT file when an exact match is not present.
    is(find_and_slurp($dir, 'test', 'en'   ), 'Theme test, language en',    'Found test/en');
    is(find_and_slurp($dir, 'test', 'es-ES'), 'Theme test, language es-ES', 'Found test/es-ES');
    is(find_and_slurp($dir, 'prog', 'en',  ), 'Theme prog, language en',    'Found test/en');
    is(find_and_slurp($dir, 'prog', 'es-ES'), 'Theme prog, language es-ES', 'Found test/es-ES');
    is(find_and_slurp($dir, 'test', 'fr-FR'), 'Theme test, language en',    'Fell back to test/en for test/fr-FR');
    is(find_and_slurp($dir, 'nope', 'es-ES'), 'Theme prog, language es-ES', 'Fell back to prog/es-ES for nope/es-ES');
    is(find_and_slurp($dir, 'nope', 'fr-FR'), 'Theme prog, language en',    'Fell back to prog/en for nope/fr-FR');

    my $matching_string = q{<syspref name="singleBranchMode">0</syspref>};
    my $sysprefs_xml = C4::XSLT::get_xslt_sysprefs();
    ok( $sysprefs_xml =~ m/$matching_string/, 'singleBranchMode has a value of 0');

    $schema->storage->txn_rollback;
};

subtest 'buildKohaItemsNamespace status tests' => sub {
    plan tests => 18;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '1|2');
    t::lib::Mocks::mock_preference( 'OPACResultsLibrary', 'holdingbranch' );
    t::lib::Mocks::mock_preference( 'OPACResultsMaxItems', '2' );

    my $itype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $holdinglibrary = $builder->build_object({ class => 'Koha::Libraries' });
    my $item = $builder->build_sample_item({ itype => $itype->itemtype });
    $item->holdingbranch( $holdinglibrary->branchcode )->store;
    $item->biblioitem->itemtype($itemtype->itemtype)->store;

    my $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>available</status>},"Item is available when no other status applied");

    # notforloan
    {
        t::lib::Mocks::mock_preference('item-level_itypes', 0);
        $item->notforloan(0)->store;
        Koha::ItemTypes->find($item->itype)->notforloan(0)->store;
        Koha::ItemTypes->find($item->biblioitem->itemtype)->notforloan(1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reference</status>},"reference if positive itype notforloan value");

        t::lib::Mocks::mock_preference('item-level_itypes', 1);
        Koha::ItemTypes->find($item->itype)->notforloan(1)->store;
        Koha::ItemTypes->find($item->biblioitem->itemtype)->notforloan(0)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reference</status>},"reference if positive itemtype notforloan value");
        Koha::ItemTypes->find($item->itype)->notforloan(0)->store;

        my $substatus = Koha::AuthorisedValues->search({ category => 'NOT_LOAN', authorised_value => -1 })->next->lib;
        $item->notforloan(-1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reallynotforloan</status>},"reallynotforloan if negative notforloan value");
        like($xml,qr{<substatus>$substatus</substatus>},"substatus set if negative notforloan value");

        $item->notforloan(1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reference</status>},"reference if positive notforloan value");

        # But now make status notforloan==1 count under Not available
        t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '2');
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reallynotforloan</status>},"reallynotforloan when we change Reference_NFL_Statuses");
        t::lib::Mocks::mock_preference('Reference_NFL_Statuses', q{}); # empty, same effect
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reallynotforloan</status>},"reallynotforloan when we empty Reference_NFL_Statuses");
        t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '1|2');
    }

    $item->onloan('2001-01-01')->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like( $xml, qr/<status>other<\/status>/, "Checked out is part of other statuses" );
    like($xml,qr{<substatus>Checked out</substatus>},"Checked out status takes precedence over Not for loan");

    $item->withdrawn(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>Withdrawn</substatus>},"Withdrawn status takes precedence over Checked out");

    $item->itemlost(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>Lost</substatus>},"Lost status takes precedence over Withdrawn");

    $item->damaged(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>Damaged</substatus>},"Damaged status takes precedence over Lost");

    $builder->build({ source => "Branchtransfer", value => {
        itemnumber  => $item->itemnumber,
        datearrived => undef,
        datecancelled => undef,
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>In transit</substatus>},"In-transit status takes precedence over Damaged");

    my $hold = $builder->build_object({ class => 'Koha::Holds', value => {
        biblionumber => $item->biblionumber,
        itemnumber   => $item->itemnumber,
        found        => 'W',
        priority     => 0,
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>Hold waiting</substatus>},"Waiting status takes precedence over In transit (holds)");
    $hold->cancel;

    $builder->build({ source => "TmpHoldsqueue", value => {
        itemnumber => $item->itemnumber
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>Pending hold</substatus>},"Pending status takes precedence over all");
    my $library_name = $holdinglibrary->branchname;
    like($xml,qr{<resultbranch>${library_name}</resultbranch>}, "Found resultbranch / holding branch" );

    t::lib::Mocks::mock_preference('UseRecalls', 1);
    my $recall = $builder->build_object(
        {
            class => 'Koha::Recalls',
            value => {
                biblio_id         => $item->biblionumber,
                item_id           => $item->itemnumber,
                pickup_library_id => $item->holdingbranch,
                item_level        => 1,
            }
        }
    );
    $recall->set_waiting;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<substatus>Recall waiting</substatus>},"Waiting status takes precedence over In transit (recalls)");
    t::lib::Mocks::mock_preference('UseRecalls', 0);

    $schema->storage->txn_rollback;
};

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

    ## Test passing items_rs only
    my $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, undef, $items_rs );

    my $library_1_name = $library_1->branchname;
    my $library_2_name = $library_2->branchname;
    my $library_3_name = $library_3->branchname;

    like(   $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );

    t::lib::Mocks::mock_preference('OpacHiddenItems', 'biblionumber: ['.$biblio2->biblionumber.']');
    my $hid_rs = $biblio->items->search({ "me.itemnumber" => { '!=' => $item_3->itemnumber } })->filter_by_visible_in_opac();
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, undef, $hid_rs );
    like(   $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );

    ## Test passing one item in hidden_items and items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber ], $items_rs->reset );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );

    ## Test passing both items in hidden_items and items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber, $item_2->itemnumber ], $items_rs->reset );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );
    is( $xml, '<items xmlns="http://www.koha-community.org/items"></items>', 'Empty XML' );

    ## Test passing both items in hidden_items and no items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber, $item_2->itemnumber, $item_3->itemnumber ] );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 not present in the XML' );
    unlike( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 not present in the XML' );
    is( $xml, '<items xmlns="http://www.koha-community.org/items"></items>', 'Empty XML' );

    ## Test passing one item in hidden_items and items_rs
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber, [ $item_1->itemnumber ] );

    unlike( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 not present in the XML' );
    like(   $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    like(   $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 present in the XML' );

    ## Test not passing any param
    $xml = C4::XSLT::buildKohaItemsNamespace( $biblio->biblionumber );

    like( $xml, qr{<homebranch>$library_1_name</homebranch>}, '$item_1 present in the XML' );
    like( $xml, qr{<homebranch>$library_2_name</homebranch>}, '$item_2 present in the XML' );
    like( $xml, qr{<homebranch>$library_3_name</homebranch>}, '$item_3 present in the XML' );

    $schema->storage->txn_rollback;
};
