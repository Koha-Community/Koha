#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;

use C4::Context;
use Koha::Caches;
use Koha::Database;
use Koha::MarcSubfieldStructures;
use Koha::Template::Plugin::AdditionalContents;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

subtest 'get' => sub {
    plan tests => 2;

    my $additional_contents = Koha::Template::Plugin::AdditionalContents->get({ category => 'news', location => ['opac_only', 'staff_and_opac'], lang => 'default', library => '%' });
    my $before_count = $additional_contents ? $additional_contents->{content}->count() : 0;
    $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            category   => 'news',
            location   => 'opac_only',
            lang       => 'default',
            branchcode => undef
        }
    });
    $additional_contents = Koha::Template::Plugin::AdditionalContents->get({ category => 'news', location => ['opac_only', 'staff_and_opac'], lang => 'default' });
    is( $additional_contents->{content}->count, $before_count + 1, "We get the additional one we added");

    $additional_contents = Koha::Template::Plugin::AdditionalContents->get({ category => 'news', location => ['opac_only', 'staff_and_opac'], lang => 'default', blocktitle => 'blockhead' });

    is( $additional_contents->{blocktitle}, 'blockhead', "Block title is passed through");


};

subtest 'get_opac_news_by_id' => sub {

    plan tests => 4;

    my $news_item = $builder->build_object({
        class => 'Koha::AdditionalContents',
        value => {
            category => 'news',
            location => 'opac_only'
        }
    });

   my $fetched_news = Koha::Template::Plugin::AdditionalContents->get_opac_news_by_id({ news_id => $news_item->id });
   is( $fetched_news->{content}->next->content, $news_item->content, "Correct news fetched for opac location" );

   $news_item->location('staff_and_opac')->store();
   $fetched_news = Koha::Template::Plugin::AdditionalContents->get_opac_news_by_id({ news_id => $news_item->id });
   is( $fetched_news->{content}->next->content, $news_item->content, "Correct news fetched for oac and staff location" );

   $news_item->location('staff_only')->store();
   $fetched_news = Koha::Template::Plugin::AdditionalContents->get_opac_news_by_id({ news_id => $news_item->id });
   is( $fetched_news, 0, "News item not fetched when location is staff_only" );

   $news_item->location('opac_only')->category('HtmlCustomizations')->store();
   $fetched_news = Koha::Template::Plugin::AdditionalContents->get_opac_news_by_id({ news_id => $news_item->id });
   is( $fetched_news, 0, "News not fetched from a different category" );



};

$schema->storage->txn_rollback;
