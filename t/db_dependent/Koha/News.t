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

use Test::More tests => 4;

use Koha::NewsItem;
use Koha::News;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $library = $builder->build({ source => 'Branch'});
my $nb_of_news = Koha::News->search->count;
my $new_news_item_1 = Koha::NewsItem->new({
    branchcode => $library->{branchcode},
    title => 'a news',
})->store;
my $new_news_item_2 = Koha::NewsItem->new({
    branchcode => $library->{branchcode},
    title => 'another news',
})->store;

like( $new_news_item_1->idnew, qr|^\d+$|, 'Adding a new news_item should have set the idnew');
is( Koha::News->search->count, $nb_of_news + 2, 'The 2 news should have been added' );

my $retrieved_news_item_1 = Koha::News->find( $new_news_item_1->idnew );
is( $retrieved_news_item_1->title, $new_news_item_1->title, 'Find a news_item by id should return the correct news_item' );

$retrieved_news_item_1->delete;
is( Koha::News->search->count, $nb_of_news + 1, 'Delete should have deleted the news_item' );

$schema->storage->txn_rollback;

1;
