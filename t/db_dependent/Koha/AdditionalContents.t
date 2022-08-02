#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::More tests => 6;
use Test::Exception;

use Koha::AdditionalContents;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Koha::AdditionalContents basic test' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library = $builder->build({ source => 'Branch'});
    my $nb_of_news = Koha::AdditionalContents->search->count;
    my $new_news_item_1 = Koha::AdditionalContent->new(
        {
            category   => 'news',
            code       => 'news_1',
            location   => 'staff_only',
            branchcode => $library->{branchcode},
            title      => 'a news',
            content    => 'content for news 1',
        }
    )->store;
    my $new_news_item_2 = Koha::AdditionalContent->new(
        {
            category   => 'news',
            code       => 'news_2',
            location   => 'staff_only',
            branchcode => $library->{branchcode},
            title      => 'another news',
            content    => 'content for news 2',
        }
    )->store;

    like( $new_news_item_1->idnew, qr|^\d+$|, 'Adding a new news_item should have set the idnew');
    is( Koha::AdditionalContents->search->count, $nb_of_news + 2, 'The 2 news should have been added' );

    my $retrieved_news_item_1 = Koha::AdditionalContents->find( $new_news_item_1->idnew );
    is( $retrieved_news_item_1->title, $new_news_item_1->title, 'Find a news_item by id should return the correct news_item' );
    is( $retrieved_news_item_1->content, $new_news_item_1->content, 'The content method return the content of the news');

    $retrieved_news_item_1->delete;
    is( Koha::AdditionalContents->search->count, $nb_of_news + 1, 'Delete should have deleted the news_item' );

    $schema->storage->txn_rollback;
};

subtest '->is_expired' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $today = dt_from_string;
    my $yesterday = dt_from_string->add( days => -1 );
    my $tomorrow = dt_from_string->add( days => 1 );
    my $new_today = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $today,
        }
    });
    my $new_expired = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $yesterday,
        }
    });
    my $new_not_expired = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $tomorrow,
        }
    });

    ok($new_expired->is_expired, 'Expired new is expired');
    ok(!$new_not_expired->is_expired, 'Not expired new is not expired');
    ok(!$new_today->is_expired, 'Today expiration date means the new is not expired');

    $schema->storage->txn_rollback;
};

subtest '->library' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $library = $builder->build_object({ class => 'Koha::Libraries' });

    my $new_with_library = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            branchcode => $library->branchcode
        }
    });
    my $new_without_library = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            branchcode => undef
        }
    });

    ok($new_with_library->library, 'News item with library have library relation');
    is($new_with_library->library->branchcode, $library->branchcode, 'The library linked with new item is right');

    ok(!$new_without_library->library, 'New item without library does not have library relation');

    $schema->storage->txn_rollback;
};

subtest '->author' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $news_item = $builder->build_object({ class => 'Koha::AdditionalContents' });
    my $author = $news_item->author;
    is( ref($author), 'Koha::Patron', 'Koha::AdditionalContent->author returns a Koha::Patron object' );

    $author->delete;

    $news_item = Koha::AdditionalContents->find($news_item->idnew);
    is( ref($news_item), 'Koha::AdditionalContent', 'News are not deleted alongwith the author' );
    is( $news_item->author, undef, '->author returns undef is the author has been deleted' );

    $schema->storage->txn_rollback;
};

subtest '->search_for_display' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    Koha::AdditionalContents->search->delete;

    my $today = dt_from_string;
    my $yesterday = dt_from_string->add( days => -1 );
    my $tomorrow = dt_from_string->add( days => 1 );
    my $library1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library2 = $builder->build_object({ class => 'Koha::Libraries' });

    my $new_expired = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $yesterday,
            published_on => $today,
            category => 'news',
            location => 'staff_and_opac',
            lang => 'default',
            branchcode => undef,
            number => 1,
        }
    });
    my $new_not_expired = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $tomorrow,
            published_on => $today,
            category => 'news',
            location => 'staff_and_opac',
            lang => 'default',
            branchcode => undef,
            number => 2,
        }
    });
    my $new_not_active = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $tomorrow,
            published_on => $tomorrow,
            category => 'news',
            location => 'staff_and_opac',
            lang => 'default',
            branchcode => undef,
            number => 3,
        }
    });
    my $new_slip= $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $tomorrow,
            published_on => $today,
            category => 'news',
            location => 'staff_only',
            lang => 'default',
            branchcode => $library1->branchcode,
            number => 4,
        }
    });
    my $new_intra = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $tomorrow,
            published_on => $today,
            category => 'news',
            location => 'staff_only',
            lang => 'default',
            branchcode => $library2->branchcode,
            number => 5,
        }
    });
    my $new_intra2 = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            expirationdate => $tomorrow,
            published_on => $today,
            category => 'news',
            location => 'staff_only',
            lang => 'default',
            branchcode => undef,
            number => 5,
        }
    });

    my $news = Koha::AdditionalContents->search_for_display({ location => 'staff_only' });
    is($news->count, 1, "There is 1 news for all staff");

    $news = Koha::AdditionalContents->search_for_display(
        { location => 'staff_only', library_id => $library1->branchcode } );
    is( $news->count, 2, "There are 2 news for staff at library1" );

    $news = Koha::AdditionalContents->search_for_display({ location => 'opac_only' });
    is($news->count, 0, "There are 0 news for OPAC only");

    $news = Koha::AdditionalContents->search_for_display({ location => 'staff_and_opac' });
    is($news->count, 1, "There is 1 news for all staff and all OPAC ");

    # TODO We should add more tests here

    $schema->storage->txn_rollback;
};

subtest 'find_best_match' => sub {
    plan tests => 3;
    $schema->storage->txn_begin;

    my $library01 = $builder->build_object({ class => 'Koha::Libraries' });
    my $html01 = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => { category => 'html_customizations', location => 'test_best_match', branchcode => undef, lang => 'default' },
    });
    my $params = { category => 'html_customizations', location => 'test_best_match', lang => 'nl-NL' };
    is( Koha::AdditionalContents->find_best_match($params)->idnew, $html01->idnew, 'Found all branches, lang default' );

    my $html02 = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => { category => 'html_customizations', location => 'test_best_match', branchcode => undef, lang => 'nl-NL' },
    });
    is( Koha::AdditionalContents->find_best_match($params)->idnew, $html02->idnew, 'Found all branches, lang nl-NL' );

    $params->{ library_id } = $library01->id;
    $html02->branchcode( $library01->id )->store;
    is( Koha::AdditionalContents->find_best_match($params)->idnew, $html02->idnew, 'Found library01, lang nl-NL' );

    # Note: find_best_match is tested further via $libary->opac_info; see t/db_dependent/Koha/Library.t

    $schema->storage->txn_rollback;
}
