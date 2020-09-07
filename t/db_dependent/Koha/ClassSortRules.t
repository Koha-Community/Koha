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

use Koha::ClassSortRules;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_class_sort_rules = Koha::ClassSortRules->search->count;
my $new_cs_1 = Koha::ClassSortRule->new({
    class_sort_rule => 'sort_rule1',
    description => 'a_sort_test_1',
    sort_routine => 'lcc',
})->store;
my $new_cs_2 = Koha::ClassSortRule->new({
    class_sort_rule => 'sort_rule2',
    description => 'a_sort_test_2',
    sort_routine => 'dewey',
})->store;

is( $new_cs_1->class_sort_rule, 'sort_rule1', 'Adding a new classification sort should have set the class_sort_rule');
is( Koha::ClassSortRules->search->count, $nb_of_class_sort_rules + 2, 'The 2 classification sorters should have been added' );

my $retrieved_cs_1 = Koha::ClassSortRules->find( $new_cs_1->class_sort_rule );
is( $retrieved_cs_1->description, $new_cs_1->description, 'Find a sorter by class_sort_rule should return the correct source' );

$retrieved_cs_1->delete;
is( Koha::ClassSortRules->search->count, $nb_of_class_sort_rules + 1, 'Delete should have deleted the sort' );

$schema->storage->txn_rollback;
