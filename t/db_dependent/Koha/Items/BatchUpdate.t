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
use Test::More tests=> 8;
use Test::Warn;
use utf8;

use Koha::Database;
use Koha::Caches;

use C4::Biblio;
use Koha::Item::Attributes;
use Koha::MarcSubfieldStructures;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

Koha::Caches->get_instance->clear_from_cache( "MarcStructure-1-" );

# 952 $x $é $y are not linked with a kohafield
# $952$x $é repeatable
# $952$t is not repeatable
# 952$z is linked with items.itemnotes and is repeatable
# 952$t is linked with items.copynumber and is not repeatable
setup_mss();

my $biblio = $builder->build_sample_biblio({ frameworkcode => '' });
my $item = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

my $items = Koha::Items->search({itemnumber => $item->itemnumber});

subtest 'MARC subfield linked with kohafield' => sub {
    plan tests => 9;

    $items->batch_update({
            new_values => {itemnotes => 'new note'}
        });
    $items->reset;

    $item = $item->get_from_storage;
    is( $item->itemnotes, 'new note' );
    is( $item->as_marc_field->subfield('t'), undef );

    is( $items->batch_update({
            new_values => {itemnotes=> 'another note'}
        })->count, 1, 'Can be chained');
    $items->reset;

    $items->batch_update({new_values => {itemnotes=> undef }})->reset;
    $item = $item->get_from_storage;
    is( $item->itemnotes, undef, "blank" );
    is( $item->as_marc_field->subfield('t'), undef, '' );

    $items->batch_update({new_values => {itemnotes=> 'new note', copynumber => 'new copynumber'}})->reset;
    $item = $item->get_from_storage;
    is( $item->itemnotes, 'new note', "multi" );
    is( $item->as_marc_field->subfield('z'), 'new note', '' );
    is( $item->copynumber, 'new copynumber', "multi" );
    is( $item->as_marc_field->subfield('t'), 'new copynumber', '' );
};

subtest 'More marc subfields (no linked)' => sub {
    plan tests => 1;

    $items->batch_update({new_values => {x => 'new xxx' }})->reset;
    is( $item->get_from_storage->as_marc_field->subfield('x'), 'new xxx' );
};

subtest 'repeatable' => sub {
    plan tests => 2;

    subtest 'linked' => sub {
        plan tests => 4;

        $items->batch_update({new_values => {itemnotes => 'new zzz 1|new zzz 2' }})->reset;
        is( $item->get_from_storage->itemnotes, 'new zzz 1|new zzz 2');
        is_deeply( [$item->get_from_storage->as_marc_field->subfield('z')], ['new zzz 1', 'new zzz 2'], 'z is repeatable' );

        $items->batch_update({new_values => {copynumber => 'new ttt 1|new ttt 2' }})->reset;
        is( $item->get_from_storage->copynumber, 'new ttt 1|new ttt 2');
        is_deeply( [$item->get_from_storage->as_marc_field->subfield('t')], ['new ttt 1|new ttt 2'], 't is not repeatable' );
    };

    subtest 'not linked' => sub {
        plan tests => 2;

        $items->batch_update({new_values => {x => 'new xxx 1|new xxx 2' }})->reset;
        is_deeply( [$item->get_from_storage->as_marc_field->subfield('x')], ['new xxx 1', 'new xxx 2'], 'i is repeatable' );

        $items->batch_update({new_values => {y => 'new yyy 1|new yyy 2' }})->reset;
        is_deeply( [$item->get_from_storage->as_marc_field->subfield('y')], ['new yyy 1|new yyy 2'], 'y is not repeatable' );
    };
};

subtest 'blank' => sub {
    plan tests => 5;

    $items->batch_update(
        {
            new_values => {
                itemnotes  => 'new notes 1|new notes 2',
                copynumber => 'new cn 1|new cn 2',
                x          => 'new xxx 1|new xxx 2',
                y          => 'new yyy 1|new yyy 2',

            }
        }
    )->reset;

    $items->batch_update(
        {
            new_values => {
                itemnotes  => undef,
                copynumber => undef,
                x          => undef,
            }
        }
    )->reset;

    $item = $item->get_from_storage;
    is( $item->itemnotes,                    undef );
    is( $item->copynumber,                   undef );
    is( $item->as_marc_field->subfield('x'), undef );
    is_deeply( [ $item->as_marc_field->subfield('y') ],
        ['new yyy 1|new yyy 2'] );

    $items->batch_update(
        {
            new_values => {
                y => undef,
            }
        }
    )->reset;

    is( $item->get_from_storage->more_subfields_xml, undef );

};

subtest 'regex' => sub {
    plan tests => 12;

    $items->batch_update(
        {
            new_values => {
                itemnotes  => 'new notes 1|new notes 2',
                copynumber => 'new cn 1|new cn 2',
                x          => 'new xxx 1|new xxx 2',
                y          => 'new yyy 1|new yyy 2',

            }
        }
    )->reset;

    my $re = {
        search    => 'new',
        replace   => 'awesome',
        modifiers => '',
    };
    $items->batch_update(
        {
            regex_mod =>
              { itemnotes => $re, copynumber => $re, x => $re, y => $re }
        }
    )->reset;
    $item = $item->get_from_storage;
    is( $item->itemnotes, 'awesome notes 1|new notes 2' );
    is_deeply(
        [ $item->as_marc_field->subfield('z') ],
        [ 'awesome notes 1', 'new notes 2' ],
        'z is repeatable'
    );

    is( $item->copynumber, 'awesome cn 1|new cn 2' );
    is_deeply( [ $item->as_marc_field->subfield('t') ],
        ['awesome cn 1|new cn 2'], 't is not repeatable' );

    is_deeply(
        [ $item->as_marc_field->subfield('x') ],
        [ 'awesome xxx 1', 'new xxx 2' ],
        'i is repeatable'
    );

    is_deeply(
        [ $item->as_marc_field->subfield('y') ],
        ['awesome yyy 1|new yyy 2'],
        'y is not repeatable'
    );

    $re = {
        search    => '(awesome)',
        replace   => '$1ness',
        modifiers => '',
    };
    $items->batch_update(
        {
            regex_mod =>
              { itemnotes => $re, copynumber => $re, x => $re, y => $re }
        }
    )->reset;
    $item = $item->get_from_storage;
    is( $item->itemnotes, 'awesomeness notes 1|new notes 2' );
    is_deeply(
        [ $item->as_marc_field->subfield('z') ],
        [ 'awesomeness notes 1', 'new notes 2' ],
        'z is repeatable'
    );

    is( $item->copynumber, 'awesomeness cn 1|new cn 2' );
    is_deeply( [ $item->as_marc_field->subfield('t') ],
        ['awesomeness cn 1|new cn 2'], 't is not repeatable' );

    is_deeply(
        [ $item->as_marc_field->subfield('x') ],
        [ 'awesomeness xxx 1', 'new xxx 2' ],
        'i is repeatable'
    );

    is_deeply(
        [ $item->as_marc_field->subfield('y') ],
        ['awesomeness yyy 1|new yyy 2'],
        'y is not repeatable'
    );
};

subtest 'encoding' => sub {
    plan tests => 1;

    $items->batch_update({
            new_values => { 'é' => 'new note é'}
        });
    $items->reset;

    $item = $item->get_from_storage;
    is( $item->as_marc_field->subfield('é'), 'new note é', );
};

subtest 'mark_items_returned' => sub {
    plan tests => 2;

    my $circ = Test::MockModule->new( 'C4::Circulation' );
    $circ->mock( 'MarkIssueReturned', sub {
        warn "MarkIssueReturned";
    });

    my $issue = $builder->build_object({class => 'Koha::Checkouts'});
    my $items = Koha::Items->search({ itemnumber => $issue->itemnumber });

    warning_is
        { $items->batch_update({new_values => {},mark_items_returned => 1}) }
        qq{MarkIssueReturned},
        "MarkIssueReturned called for item";

    $items->reset;

    warning_is
        { $items->batch_update({new_values => {},mark_items_returned => 0}) }
        qq{},
        "MarkIssueReturned not called for item";

};

subtest 'report' => sub {
    plan tests => 5;

    my $item_1 =
      $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );
    my $item_2 =
      $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

    my $items = Koha::Items->search(
        { itemnumber => [ $item_1->itemnumber, $item_2->itemnumber ] } );

    my ($report) = $items->batch_update(
        {
            new_values => { itemnotes => 'new note' }
        }
    );
    $items->reset;
    is_deeply(
        $report,
        {
            modified_itemnumbers =>
              [ $item_1->itemnumber, $item_2->itemnumber ],
            modified_fields => 2
        }
    );

    ($report) = $items->batch_update(
        {
            new_values => { itemnotes => 'new note', copynumber => 'new cn' }
        }
    );
    $items->reset;

    is_deeply(
        $report,
        {
            modified_itemnumbers =>
              [ $item_1->itemnumber, $item_2->itemnumber ],
            modified_fields => 2
        }
    );

    $item_1->get_from_storage->update( { itemnotes => 'not new note' } );
    ($report) = $items->batch_update(
        {
            new_values => { itemnotes => 'new note', copynumber => 'new cn' }
        }
    );
    $items->reset;

    is_deeply(
        $report,
        {
            modified_itemnumbers => [ $item_1->itemnumber ],
            modified_fields      => 1
        }
    );

    ($report) = $items->batch_update(
        {
            new_values => { x => 'new xxx', y => 'new yyy' }
        }
    );
    $items->reset;

    is_deeply(
        $report,
        {
            modified_itemnumbers =>
              [ $item_1->itemnumber, $item_2->itemnumber ],
            modified_fields => 4
        }
    );

    my $re = {
        search    => 'new',
        replace   => 'awesome',
        modifiers => '',
    };

    $item_2->get_from_storage->update( { itemnotes => 'awesome note' } );
    ($report) = $items->batch_update(
        {
            regex_mod =>
              { itemnotes => $re, copynumber => $re, x => $re, y => $re }
        }
    );
    $items->reset;

    is_deeply(
        $report,
        {
            modified_itemnumbers =>
              [ $item_1->itemnumber, $item_2->itemnumber ],
            modified_fields => 7
        }
    );

};

Koha::Caches->get_instance->clear_from_cache( "MarcStructure-1-" );

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
            tab           => 10,
        }
    )->store;

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => [ 'x', 'y' ]
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
