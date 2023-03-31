#!/usr/bin/perl

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
use Test::More tests => 9;
use Data::Dumper qw( Dumper );
use utf8;

use List::MoreUtils qw( uniq );

use Koha::Libraries;
use Koha::MarcSubfieldStructures;
use Koha::UI::Form::Builder::Item;
use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

my $cache = Koha::Caches->get_instance();
$cache->clear_from_cache("MarcStructure-0-");
$cache->clear_from_cache("MarcStructure-1-");
$cache->clear_from_cache("MarcSubfieldStructure-");

# 952 $x $é are not linked with a kohafield
# $952$x $é repeatable
# $952$t is not repeatable
# 952$z is linked with items.itemnotes and is repeatable
# 952$t is linked with items.copynumber and is not repeatable
setup_mss();

subtest 'authorised values' => sub {
    #plan tests => 1;

    my $biblio = $builder->build_sample_biblio({ value => {frameworkcode => ''}});

    # FIXME Later in this script we are comparing itemtypes, ordered by their description.
    # MySQL and Perl don't sort _ identically.
    # If you have one itemtype BK and another one B_K, MySQL will sort B_K first when Perl will sort it last
    my @itemtypes = Koha::ItemTypes->search->as_list;
    for my $itemtype ( @itemtypes ) {
        my $d = $itemtype->description;
        $d =~ s|_||g;
        $itemtype->description($d)->store;
    }

    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form;

    my @display_orders = uniq map { $_->{display_order} } @$subfields;
    is_deeply( \@display_orders, [sort {$a <=> $b} @display_orders], 'subfields are sorted by display order' );

    subtest 'normal AV' => sub {
        plan tests => 2;
        my ($subfield) =
          grep { $_->{kohafield} eq 'items.notforloan' } @$subfields;
        my $avs = Koha::AuthorisedValues->search( { category => 'NOT_LOAN' } );

        is_deeply(
            $subfield->{marc_value}->{values},
            [
                "",
                map    { $_->authorised_value }
                  sort { $a->lib cmp $b->lib }
                  $avs->as_list
            ],
            'AVs are sorted by lib and en empty option is created first'
        );
        is_deeply(
            $subfield->{marc_value}->{labels},
            {
                map    { $_->authorised_value => $_->lib }
                  sort { $a->lib cmp $b->lib }
                  $avs->as_list
            }
        );
    };

    subtest 'cn_source' => sub {
        plan tests => 2;
        my ( $subfield ) = grep { $_->{kohafield} eq 'items.cn_source' } @$subfields;
        is_deeply( $subfield->{marc_value}->{values}, [ '', 'ddc', 'lcc' ] );
        is_deeply(
            $subfield->{marc_value}->{labels},
            {
                ddc => "Dewey Decimal Classification",
                lcc => "Library of Congress Classification",
            }
        );
    };
    subtest 'branches' => sub {
        plan tests => 2;
        my ( $subfield ) = grep { $_->{kohafield} eq 'items.homebranch' } @$subfields;
        my $libraries = Koha::Libraries->search({}, { order_by => 'branchname' });
        is_deeply(
            $subfield->{marc_value}->{values},
            [ $libraries->get_column('branchcode') ]
        );
        is_deeply(
            $subfield->{marc_value}->{labels},
            { map { $_->branchcode => $_->branchname } $libraries->as_list }
        );
    };

    subtest 'itemtypes' => sub {
        plan tests => 2;
        my ($subfield) = grep { $_->{kohafield} eq 'items.itype' } @$subfields;
        my @itemtypes = Koha::ItemTypes->search->as_list;

        my $expected = [
            "",
            map    { $_->itemtype }
              # We need to sort using uc or perl won't be case insensitive
              sort { uc($a->translated_description) cmp uc($b->translated_description) }
              @itemtypes
        ];
        is_deeply(
            $subfield->{marc_value}->{values},
            $expected,
            "Item types should be sorted by description and an empty entry should be shown"
        );

        is_deeply( $subfield->{marc_value}->{labels},
            { map { $_->itemtype => $_->description } @itemtypes},
            'Labels should be correctly displayed'
        );
    };
};

subtest 'prefill_with_default_values' => sub {
    plan tests => 3;

    my $biblio = $builder->build_sample_biblio({ value => {frameworkcode => ''}});
    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form;


    my ($subfield) = grep { $_->{subfield} eq 'é' } @$subfields;
    is( $subfield->{marc_value}->{value}, '', 'no default value if prefill_with_default_values not passed' );

    $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form({ prefill_with_default_values => 1 });


    ($subfield) = grep { $_->{subfield} eq 'é' } @$subfields;
    is( $subfield->{marc_value}->{value}, 'ééé', 'default value should be set if prefill_with_default_values passed');

    # Do the same for an existing item; we do not expect the defaultvalue to popup
    my $item = $builder->build_sample_item;
    $subfields = Koha::UI::Form::Builder::Item->new({
        biblionumber => $biblio->biblionumber,
        item => $item->unblessed,
    })->edit_form({ prefill_with_default_values => 1 });
    ($subfield) = grep { $_->{subfield} eq 'é' } @$subfields;
    is( $subfield->{marc_value}->{value}, q{}, 'default value not applied to existing item');

};

subtest 'subfields_to_prefill' => sub {
    plan tests => 2;

    my $biblio = $builder->build_sample_biblio({ value => {frameworkcode => ''}});

    my $more_subfields_xml = Koha::Item::Attributes->new({ "é" => "prefill é" })->to_marcxml;
    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber, item => {more_subfields_xml => $more_subfields_xml}})->edit_form({subfields_to_prefill => ['é']});
    my ($subfield) = grep { $_->{subfield} eq 'é' } @$subfields;
    is( $subfield->{marc_value}->{value}, 'prefill é', 'Not mapped subfield prefilled if needed' );

    $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber, item => {itemnotes => 'prefill z'}})->edit_form({subfields_to_prefill => ['z']});
    ($subfield) = grep { $_->{subfield} eq 'z' } @$subfields;
    is( $subfield->{marc_value}->{value}, 'prefill z', 'Mapped subfield prefilled if needed');
};

subtest 'branchcode' => sub {
    plan tests => 2;

    my $biblio = $builder->build_sample_biblio({ value => {frameworkcode => ''}});
    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form;

    my ( $subfield ) = grep { $_->{kohafield} eq 'items.homebranch' } @$subfields;
    is( $subfield->{marc_value}->{default}, '', 'no library preselected if no branchcode passed');

    $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form({ branchcode => $library->branchcode });

    ( $subfield ) = grep { $_->{kohafield} eq 'items.homebranch' } @$subfields;
    is( $subfield->{marc_value}->{default}, $library->branchcode, 'the correct library should be preselected if branchcode is passed');
};

subtest 'default_branches_empty' => sub {
    plan tests => 2;

    my $biblio = $builder->build_sample_biblio({ value => {frameworkcode => ''}});
    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form;

    my ( $subfield ) = grep { $_->{kohafield} eq 'items.homebranch' } @$subfields;
    isnt( $subfield->{marc_value}->{values}->[0], "", 'No empty option for branches' );

    $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form({ default_branches_empty => 1 });

    ( $subfield ) = grep { $_->{kohafield} eq 'items.homebranch' } @$subfields;
    is( $subfield->{marc_value}->{values}->[0], "", 'empty option for branches if default_branches_empty passed' );
};

subtest 'kohafields_to_ignore' => sub {
    plan tests => 2;

    my $biblio =
      $builder->build_sample_biblio( { value => { frameworkcode => '' } } );
    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form;

    my ($subfield) = grep { $_->{kohafield} eq 'items.barcode' } @$subfields;
    isnt( $subfield, undef, 'barcode subfield should be in the subfield list' );

    $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )
      ->edit_form( { kohafields_to_ignore => ['items.barcode'] } );

    ($subfield) = grep { $_->{kohafield} eq 'items.barcode' } @$subfields;
    is( $subfield, undef,
        'barcode subfield should have not been built if passed to kohafields_to_ignore'
    );
};

subtest 'subfields_to_allow & ignore_not_allowed_subfields' => sub {
    plan tests => 6;

    my ( $tag_cn, $subtag_cn ) = C4::Biblio::GetMarcFromKohaField("items.itemcallnumber");
    my ( $tag_notes, $subtag_notes ) = C4::Biblio::GetMarcFromKohaField("items.itemnotes");
    my $biblio = $builder->build_sample_biblio( { value => { frameworkcode => '' } } );
    my $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form(
            {
                subfields_to_allow => [
                    sprintf( '%s$%s', $tag_cn,    $subtag_cn ),
                    sprintf( '%s$%s', $tag_notes, $subtag_notes )
                ]
            }
        );

    isnt( scalar(@$subfields), 2, "There are more than the 2 subfields we allowed" );
    my ($subfield) = grep { $_->{kohafield} eq 'items.itemcallnumber' } @$subfields;
    is( $subfield->{marc_value}->{readonly}, undef, "subfields to allowed are not marked as readonly" );
    ($subfield) = grep { $_->{kohafield} eq 'items.copynumber' } @$subfields;
    isnt( $subfield->{marc_value}->{readonly}, 1, "subfields that are not in the allow list are marked as readonly" );

    $subfields =
      Koha::UI::Form::Builder::Item->new(
        { biblionumber => $biblio->biblionumber } )->edit_form(
            {
                subfields_to_allow => [
                    sprintf( '%s$%s', $tag_cn,    $subtag_cn ),
                    sprintf( '%s$%s', $tag_notes, $subtag_notes )
                ],
                ignore_not_allowed_subfields => 1,
            }
        );

    is( scalar(@$subfields), 2, "With ignore_not_allowed_subfields, only the subfields to ignore are returned" );
    ($subfield) =
      grep { $_->{kohafield} eq 'items.itemcallnumber' } @$subfields;
    is( $subfield->{marc_value}->{readonly}, undef, "subfields to allowed are not marked as readonly" );
    ($subfield) = grep { $_->{kohafield} eq 'items.copynumber' } @$subfields;
    is( $subfield, undef, "subfield that is not in the allow list is not returned" );
};

subtest 'ignore_invisible_subfields' => sub {
    plan tests => 2;

    my $biblio =
      $builder->build_sample_biblio( { value => { frameworkcode => '' } } );
    my $item = $builder->build_sample_item(
        {
            issues => 42,
        }
    );

    # items.issues is mapped with 952$l
    my $subfields = Koha::UI::Form::Builder::Item->new(
        {
            biblionumber => $biblio->biblionumber,
            item         => $item->unblessed,
        }
    )->edit_form;
    ( my $subfield ) = grep { $_->{subfield} eq 'l' } @$subfields;
    is( $subfield->{marc_value}->{value}, 42, 'items.issues copied' );

    $subfields = Koha::UI::Form::Builder::Item->new(
        {
            biblionumber => $biblio->biblionumber,
            item         => $item->unblessed,
        }
    )->edit_form(
        {
            ignore_invisible_subfields => 1
        }
    );
    ($subfield) = grep { $_->{subfield} eq 'l' } @$subfields;
    is( $subfield->{marc_value}->{value},
        undef, 'items.issues not copied if ignore_invisible_subfields is passed' );
};

subtest 'Fix subfill_with_default_values - no biblionumber passed' => sub {
    plan tests => 1;

    t::lib::Mocks::mock_preference('itemcallnumber', '082ab,092ab');
    my $item = $builder->build_sample_item;
    my $subfields = Koha::UI::Form::Builder::Item->new(
        {
            item         => $item->unblessed,
        }
    )->edit_form({ prefill_with_default_values => 1 });
    pass();
};

$cache->clear_from_cache("MarcStructure-0-");
$cache->clear_from_cache("MarcStructure-1-");
$cache->clear_from_cache("MarcSubfieldStructure-");

sub setup_mss {

    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield => $itemtag,
            tagsubfield => 'é',
        }
    )->delete;    # In case it exist already

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

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => [ 'x' ]
        }
    )->update( { kohafield => undef } );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield => $itemtag,
            tagsubfield => [ 'x', 'é' ],
        }
    )->update( { repeatable => 1 } );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield => $itemtag,
            tagsubfield => ['t'],
        }
    )->update( { repeatable => 0 } );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield => $itemtag,
            tagsubfield => ['l'],
        }
    )->update( { hidden => -4 } );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield => $itemtag,
            tagsubfield => ['z'],
        }
    )->update( { kohafield => 'items.itemnotes', repeatable => 1 } );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield => $itemtag,
        }
    )->update( { display_order => \['FLOOR( 1 + RAND( ) * 10 )'] } );
}
