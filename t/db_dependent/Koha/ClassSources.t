#!/usr/bin/perl

# Copyright 2017 Koha Development team
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

use Koha::Database;

use Koha::ClassSources;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $class_sort_1 = $builder->build({ source=>'ClassSortRule' });
my $class_sort_2 = $builder->build({ source=>'ClassSortRule' });
my $nb_of_class_sources = Koha::ClassSources->search->count;
my $new_cs_1 = Koha::ClassSource->new({
    cn_source => 'source_1',
    description => 'a_test_1',
    used => '1',
    class_sort_rule => $class_sort_1->{class_sort_rule},#'sort_rule_1',
})->store;
my $new_cs_2 = Koha::ClassSource->new({
    cn_source => 'source_2',
    description => 'a_test_2',
    used => '0',
    class_sort_rule => $class_sort_2->{class_sort_rule},#'sort_rule_1',
})->store;

is( $new_cs_1->cn_source, 'source_1', 'Adding a new classification should have set the cn_source');
is( Koha::ClassSources->search->count, $nb_of_class_sources + 2, 'The 2 classifcations should have been added' );

my $retrieved_cs_1 = Koha::ClassSources->find( $new_cs_1->cn_source );
is( $retrieved_cs_1->description, $new_cs_1->description, 'Find a source by cn_source should return the correct source' );

$retrieved_cs_1->delete;
is( Koha::ClassSources->search->count, $nb_of_class_sources + 1, 'Delete should have deleted the classification' );

$schema->storage->txn_rollback;
