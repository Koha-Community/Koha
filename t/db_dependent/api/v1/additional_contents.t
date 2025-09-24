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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::AdditionalContents;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $t = Test::Mojo->new('Koha::REST::V1');
t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );

subtest 'anonymous access' => sub {
    plan tests => 17;

    $schema->storage->txn_begin;

    Koha::AdditionalContents->search->delete;

    my $today     = dt_from_string;
    my $yesterday = dt_from_string->add( days => -1 );
    my $tomorrow  = dt_from_string->add( days => 1 );
    my $res;

    $builder->build_object(
        {
            class => 'Koha::AdditionalContents',
            value => {
                expirationdate => $tomorrow,
                published_on   => $tomorrow,
                category       => 'news',
                location       => 'staff_and_opac',
                branchcode     => undef,
                number         => 3,
            }
        }
    );

    t::lib::Mocks::mock_preference( 'RESTPublicAnonymousRequests', 1 );

    $res = $t->get_ok("/api/v1/public/additional_contents")->status_is(200)->tx->res->json;

    is( scalar @{$res}, 0, 'The only additional content is not active and not public' );

    my $public_additional_contents = $builder->build_object(
        {
            class => 'Koha::AdditionalContents',
            value => {
                expirationdate => $tomorrow,
                published_on   => $yesterday,
                category       => 'news',
                location       => 'staff_and_opac',
                branchcode     => undef,
                number         => 3,
            }
        }
    );

    $builder->build_object(
        {
            class => 'Koha::AdditionalContentsLocalizations',
            value => {
                additional_content_id => $public_additional_contents->id,
                lang                  => 'pt-PT',
            }
        }
    );

    $builder->build_object(
        {
            class => 'Koha::AdditionalContentsLocalizations',
            value => {
                additional_content_id => $public_additional_contents->id,
                lang                  => 'es-ES',
            }
        }
    );

    $res = $t->get_ok("/api/v1/public/additional_contents")->status_is(200)->tx->res->json;

    is( scalar @{$res}, 1, 'There is now one active and public additional content' );

    $t->get_ok( "/api/v1/public/additional_contents" => { 'x-koha-embed' => 'translated_contents' } )->status_is(200)
        ->json_is(
        '/0' => {
            %{ $public_additional_contents->to_api( { public => 1 } ) },
            translated_contents => $public_additional_contents->translated_contents->to_api( { public => 1 } )
        }
        );

    my $second_public_additional_contents = $builder->build_object(
        {
            class => 'Koha::AdditionalContents',
            value => {
                expirationdate => $tomorrow,
                published_on   => $yesterday,
                category       => 'news',
                location       => 'staff_and_opac',
                branchcode     => undef,
                number         => 3,
            }
        }
    );

    $builder->build_object(
        {
            class => 'Koha::AdditionalContentsLocalizations',
            value => {
                additional_content_id => $second_public_additional_contents->id,
                lang                  => 'fr-FR',
            }
        }
    );

    $t->get_ok( "/api/v1/public/additional_contents?q={\"translated_contents.lang\": \"pt-PT\"}" =>
            { 'x-koha-embed' => 'translated_contents' } )->status_is(200)->json_is(
        '/0' => {
            %{ $public_additional_contents->to_api( { public => 1 } ) },
            translated_contents => $public_additional_contents->translated_contents->to_api( { public => 1 } )
        }
    )->json_hasnt('/1');

    $t->get_ok( "/api/v1/public/additional_contents?q={\"translated_contents.lang\": \"fr-FR\"}" =>
            { 'x-koha-embed' => 'translated_contents' } )->status_is(200)->json_is(
        '/0' => {
            %{ $second_public_additional_contents->to_api( { public => 1 } ) },
            translated_contents => $second_public_additional_contents->translated_contents->to_api( { public => 1 } )
        }
    )->json_hasnt('/1');

    $schema->storage->txn_rollback;

};
