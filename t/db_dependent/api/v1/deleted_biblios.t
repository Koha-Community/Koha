#!/usr/bin/env perl

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

use utf8;
use Encode;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::MockModule;
use Test::Mojo;
use Test::Warn;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Mojo::JSON qw(encode_json);

use C4::Auth;
use C4::Biblio      qw( DelBiblio );
use C4::Circulation qw( AddIssue AddReturn );

use Koha::Biblios;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Checkouts;
use Koha::Old::Checkouts;

use Mojo::JSON qw(encode_json);

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'get() tests' => sub {

    plan tests => 22;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    my $biblio = $builder->build_sample_biblio(
        {
            title  => 'The unbearable lightness of being',
            author => 'Milan Kundera'
        }
    );

    my $formatted = $biblio->metadata->record->as_formatted;
    DelBiblio( $biblio->id );

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/" . $biblio->biblionumber )->status_is(403);

    $patron->flags(4)->store;

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/"
            . $biblio->biblionumber => { Accept => 'application/weird+format' } )->status_is(400);

    $t->get_ok(
        "//$userid:$password@/api/v1/deleted/biblios/" . $biblio->biblionumber => { Accept => 'application/json' } )
        ->status_is(200)->json_is( '/title', 'The unbearable lightness of being' )
        ->json_is( '/author', 'Milan Kundera' );

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/"
            . $biblio->biblionumber => { Accept => 'application/marcxml+xml' } )->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/"
            . $biblio->biblionumber => { Accept => 'application/marc-in-json' } )->status_is(200);

    $t->get_ok(
        "//$userid:$password@/api/v1/deleted/biblios/" . $biblio->biblionumber => { Accept => 'application/marc' } )
        ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/" . $biblio->biblionumber => { Accept => 'text/plain' } )
        ->status_is(200)->content_is($formatted);

    my $biblio_exist = $builder->build_sample_biblio();
    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/"
            . $biblio_exist->biblionumber => { Accept => 'application/marc' } )->status_is(404)
        ->json_is( '/error', 'Bibliographic record not found' );

    subtest 'marc-in-json encoding tests' => sub {

        plan tests => 3;

        my $title_with_diacritics = "L'insoutenable légèreté de l'être";

        my $biblio = $builder->build_sample_biblio(
            {
                title  => $title_with_diacritics,
                author => "Milan Kundera"
            }
        );

        DelBiblio( $biblio->id );

        my $result = $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/"
                . $biblio->biblionumber => { Accept => 'application/marc-in-json' } )->status_is(200)->tx->res->body;

        my $encoded_title = Encode::encode( "UTF-8", $title_with_diacritics );

        like( $result, qr/\Q$encoded_title/, "The title is not double encoded" );
    };

    subtest 'marcxml encoding tests' => sub {
        plan tests => 3;

        my $marcflavour = C4::Context->preference('marcflavour');
        t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

        my $title_with_diacritics = "L'insoutenable légèreté de l'être";

        my $biblio = $builder->build_sample_biblio(
            {
                title  => $title_with_diacritics,
                author => "Milan Kundera"
            }
        );

        my $record = $biblio->metadata->record;
        $record->leader('     nam         3  4500');
        $biblio->metadata->metadata( $record->as_xml_record('UNIMARC') );
        $biblio->metadata->store;

        DelBiblio( $biblio->id );

        my $result = $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios/"
                . $biblio->biblionumber => { Accept => 'application/marcxml+xml' } )->status_is(200)->tx->res->body;

        my $encoded_title = Encode::encode( "UTF-8", $title_with_diacritics );

        like( $result, qr/\Q$encoded_title/, "The title is not double encoded" );
        t::lib::Mocks::mock_preference( 'marcflavour', $marcflavour );
    };

    $schema->storage->txn_rollback;
};

subtest 'list() tests' => sub {

    plan tests => 21;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $password = 'thePassword123';
    $patron->set_password( { password => $password, skip_validation => 1 } );
    $patron->discard_changes;
    my $userid = $patron->userid;

    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

    my $title_with_diacritics = "L'insoutenable légèreté de l'être";
    my $biblio                = $builder->build_sample_biblio(
        {
            title  => $title_with_diacritics,
            author => "Milan Kundera",
        }
    );

    my $record = $biblio->metadata->record;
    $record->leader('     nam         3  4500');
    $biblio->metadata->metadata( $record->as_xml_record('UNIMARC') )->store;

    my $biblio_id_1 = $biblio->id;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    my $biblio_id_2 = $builder->build_sample_biblio->id;

    DelBiblio($biblio_id_1);
    DelBiblio($biblio_id_2);

    my $query = encode_json( [ { biblio_id => $biblio_id_1 }, { biblio_id => $biblio_id_2 } ] );

    $t->get_ok("//$userid:$password@/api/v1/deleted/biblios?q=$query")->status_is(403);

    $patron->flags(4)->store;

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios?q=$query" => { Accept => 'application/weird+format' } )
        ->status_is(400);

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios?q=$query" => { Accept => 'application/json' } )
        ->status_is(200);

    my $result =
        $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios?q=$query" => { Accept => 'application/marcxml+xml' } )
        ->status_is(200)->tx->res->body;

    my $encoded_title = Encode::encode( "UTF-8", $title_with_diacritics );
    like( $result, qr/\Q$encoded_title/, "The title is not double encoded" );

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios?q=$query" => { Accept => 'application/marc-in-json' } )
        ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios?q=$query" => { Accept => 'application/marc' } )
        ->status_is(200);

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios?q=$query" => { Accept => 'text/plain' } )->status_is(200);

    my $old_biblio_1 = Koha::Old::Biblios->find($biblio_id_1);
    my $old_biblio_2 = Koha::Old::Biblios->find($biblio_id_2);

    $old_biblio_1->set( { timestamp => dt_from_string('2024-12-12T17:33:57+00:00') } )->store();
    $old_biblio_2->set( { timestamp => dt_from_string('2024-12-11T17:33:57+00:00') } )->store();

    $query = encode_json(
        {
            "-and" => [
                { 'me.deleted_on' => { '>=' => '2024-12-12T00:00:00+00:00' } },
                [
                    { biblio_id => $old_biblio_1->id },
                    { biblio_id => $old_biblio_2->id },
                ]
            ]
        }
    );

    $t->get_ok( "//$userid:$password@/api/v1/deleted/biblios?q=$query" => { Accept => 'application/json' } )
        ->status_is(200)->json_is( '/0/biblio_id' => $old_biblio_1->id )->json_is( '/1/biblio_id' => undef );

    # DELETE any biblio with ISBN = TOMAS
    Koha::Biblios->search( { 'biblioitem.isbn' => 'TOMAS' }, { join => ['biblioitem'] } )->delete;

    my $isbn_query   = encode_json( { isbn => 'TOMAS' } );
    my $tomas_biblio = $builder->build_sample_biblio( { isbn => 'TOMAS' } );
    DelBiblio( $tomas_biblio->id );
    $t->get_ok( "//$userid:$password@/api/v1/biblios?q=$isbn_query" => { Accept => 'text/plain' } )->status_is(200);

    $schema->storage->txn_rollback;
};
