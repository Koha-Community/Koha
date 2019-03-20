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

use Test::More tests => 5;
use Test::Exception;

use Koha::News;
use Koha::Database;
use Koha::DateUtils;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Koha::News basic test' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $library = $builder->build({ source => 'Branch'});
    my $nb_of_news = Koha::News->search->count;
    my $new_news_item_1 = Koha::NewsItem->new({
        branchcode => $library->{branchcode},
        title => 'a news',
        content => 'content for news 1',
    })->store;
    my $new_news_item_2 = Koha::NewsItem->new({
        branchcode => $library->{branchcode},
        title => 'another news',
        content => 'content for news 2',
    })->store;

    like( $new_news_item_1->idnew, qr|^\d+$|, 'Adding a new news_item should have set the idnew');
    is( Koha::News->search->count, $nb_of_news + 2, 'The 2 news should have been added' );

    my $retrieved_news_item_1 = Koha::News->find( $new_news_item_1->idnew );
    is( $retrieved_news_item_1->title, $new_news_item_1->title, 'Find a news_item by id should return the correct news_item' );
    is( $retrieved_news_item_1->content, $new_news_item_1->content, 'The content method return the content of the news');

    $retrieved_news_item_1->delete;
    is( Koha::News->search->count, $nb_of_news + 1, 'Delete should have deleted the news_item' );

    $schema->storage->txn_rollback;
};

subtest '->is_expired' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $today = dt_from_string;
    my $yesterday = dt_from_string->add( days => -1 );
    my $tommorow = dt_from_string->add( days => 1 );
    my $new_today = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $today,
        }
    });
    my $new_expired = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $yesterday,
        }
    });
    my $new_not_expired = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $tommorow,
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
        class => 'Koha::News',
        value => {
            branchcode => $library->branchcode
        }
    });
    my $new_without_library = $builder->build_object({
        class => 'Koha::News',
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

    my $news_item = $builder->build_object({ class => 'Koha::News' });
    my $author = $news_item->author;
    is( ref($author), 'Koha::Patron', 'Koha::NewsItem->author returns a Koha::Patron object' );

    $author->delete;

    $news_item = Koha::News->find($news_item->idnew);
    is( ref($news_item), 'Koha::NewsItem', 'News are not deleted alongwith the author' );
    is( $news_item->author, undef, '->author returns undef is the author has been deleted' );
};

subtest '->search_for_display' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    Koha::News->search->delete;

    my $today = dt_from_string;
    my $yesterday = dt_from_string->add( days => -1 );
    my $tommorow = dt_from_string->add( days => 1 );
    my $library1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library2 = $builder->build_object({ class => 'Koha::Libraries' });

    my $new_expired = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $yesterday,
            timestamp => $today,
            lang => '',
            branchcode => undef,
            number => 1,
        }
    });
    my $new_not_expired = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $tommorow,
            timestamp => $today,
            lang => '',
            branchcode => undef,
            number => 2,
        }
    });
    my $new_not_active = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $tommorow,
            timestamp => $tommorow,
            lang => '',
            branchcode => undef,
            number => 3,
        }
    });
    my $new_slip= $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $tommorow,
            timestamp => $today,
            lang => 'slip',
            branchcode => $library1->branchcode,
            number => 4,
        }
    });
    my $new_intra = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $tommorow,
            timestamp => $today,
            lang => 'koha',
            branchcode => $library2->branchcode,
            number => 5,
        }
    });
    my $new_intra2 = $builder->build_object({
        class => 'Koha::News',
        value => {
            expirationdate => $tommorow,
            timestamp => $today,
            lang => 'koha',
            branchcode => undef,
            number => 5,
        }
    });
    my $news = Koha::News->search_for_display;

    is($news->count, 4, 'Active and not expired news');
    is($news->next->number, 2, 'News items are returned in correct order');

    $news = Koha::News->search_for_display({ type => 'slip'});
    is($news->count, 2, 'Slip and all type returned');

    $news = Koha::News->search_for_display({ type => 'koha'});
    is($news->count, 3, 'Intranet and all');

    $new_not_expired->lang('OpacNavRight_en')->store;
    $news = Koha::News->search_for_display({ type => 'OpacNavRight', lang => 'en'});
    is($news->count, 1, 'OpacNavRight');
    is($news->next->idnew, $new_not_expired->idnew, 'Returned the right new item');

    $new_intra->lang('')->store;
    $news = Koha::News->search_for_display({ type => 'opac', lang => 'en'});
    is($news->count, 1, 'Only all type is returned');
    $new_not_expired->lang('en')->store;
    $news = Koha::News->search_for_display({ type => 'opac', lang => 'en'});
    is($news->count, 2, 'Opac en and all is returned');

    $news = Koha::News->search_for_display({ library_id => $library1->branchcode });
    is($news->count, 3, 'Filtering by library returns right number of news items');

    $news = Koha::News->search_for_display({ library_id => $library2->branchcode});
    is($news->count, 3, 'Filtering by library returns right number of news items');

    $new_intra->branchcode($library1->branchcode)->store;
    $news = Koha::News->search_for_display({ library_id => $library2->branchcode});
    is($news->count, 2, 'Filtering by library returns right number of news items');

    throws_ok { Koha::News->search_for_display({type => 'opac'}) } 'Koha::Exceptions::BadParameter',
        'Exception raised when type is opac and no language given';

    $schema->storage->txn_rollback;
};
