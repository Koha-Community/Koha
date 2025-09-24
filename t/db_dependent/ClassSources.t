#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (c) 2024
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
use Test::More tests => 5;
use t::lib::TestBuilder;

use Koha::ClassSortRules;
use Koha::ClassSources;

BEGIN {
    use_ok( 'C4::ClassSource', qw( GetClassSources GetClassSource GetClassSortRule ) );
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'GetClassSources' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $class_rule = $builder->build(
        {
            source => 'ClassSortRule',
            value  => { sort_routine => "LCC" }
        }
    );
    my $class_source_1 = $builder->build(
        {
            source => 'ClassSource',
            value  => {
                class_sort_rule => $class_rule->{class_sort_rule},
            }
        }
    );
    my $source_code = $class_source_1->{cn_source};

    Koha::Cache::Memory::Lite->flush();

    my $class_sources = GetClassSources();
    is_deeply( $class_sources->{$source_code}, $class_source_1, "The retrieved version, from the DB, is the same" );

    # Now we add a new one, but expect the old to be cached (same request)
    my $class_source_2 = $builder->build(
        {
            source => 'ClassSource',
            value  => {
                class_sort_rule => $class_rule->{class_sort_rule},
            }
        }
    );
    $source_code = $class_source_2->{cn_source};

    my $class_sources_cached = GetClassSources();
    is_deeply(
        $class_sources, $class_sources_cached,
        "We have a cached version, so we won't have the new one we added"
    );
    is( $class_sources_cached->{$source_code}, undef, "New value not present" );

    # Now we clear the cache, i.e. pretend we're a new request
    Koha::Cache::Memory::Lite->flush();

    $class_sources = GetClassSources();
    is( $class_sources_cached->{$source_code}, undef, "New value now present after cache cleared" );
    $class_sources_cached = GetClassSources();
    is_deeply( $class_sources, $class_sources_cached, "New cached version does match the updated fresh version" );

    $schema->storage->txn_rollback;

};

subtest 'GetClassSource' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $class_rule = $builder->build(
        {
            source => 'ClassSortRule',
            value  => { sort_routine => "LCC" }
        }
    );
    my $class_source_1 = $builder->build(
        {
            source => 'ClassSource',
            value  => {
                class_sort_rule => $class_rule->{class_sort_rule},
            }
        }
    );
    my $source_code = $class_source_1->{cn_source};

    Koha::Cache::Memory::Lite->flush();
    my $class_source_db = GetClassSource($source_code);
    is_deeply( $class_source_db, $class_source_1, "The retrieved version, from the DB, is the same" );

    my $class_source_object = Koha::ClassSources->find($source_code);
    $class_source_object->description("We changed the thing")->store();

    my $class_source_cache = GetClassSource($source_code);
    is(
        $class_source_cache->{description}, $class_source_db->{description},
        "Still have old description in cache (same request)"
    );

    Koha::Cache::Memory::Lite->flush();                 # New request, that's the gimmick
    $class_source_db = GetClassSource($source_code);    # Refetch from DB to populate cache
    is( $class_source_db->{description}, "We changed the thing", "DB request got update value" );
    $class_source_cache = GetClassSource($source_code);
    is( $class_source_cache->{description}, $class_source_db->{description}, "Now both get the correct value" );

    $schema->storage->txn_rollback;

};

subtest 'GetClassSortRule' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $class_rule_1 = $builder->build(
        {
            source => 'ClassSortRule',
            value  => { sort_routine => "LCC" }
        }
    );
    my $sort_rule = $class_rule_1->{class_sort_rule};

    Koha::Cache::Memory::Lite->flush();
    my $class_sort_rule_db = GetClassSortRule($sort_rule);
    is_deeply( $class_sort_rule_db, $class_rule_1, "The retrieved version, from the DB, is the same" );

    my $class_source_object = Koha::ClassSortRules->find($sort_rule);
    $class_source_object->sort_routine('Dewey')->store();

    my $class_sort_rule_cache = GetClassSortRule($sort_rule);
    is_deeply( $class_sort_rule_cache, $class_sort_rule_db, "Still have old sort rule in cache (same request)" );

    Koha::Cache::Memory::Lite->flush();                    # New request, that's the gimmick
    $class_sort_rule_db = GetClassSortRule($sort_rule);    # Refetch from DB to populate cache
    is_deeply( $class_sort_rule_db, $class_source_object->unblessed, "DB request got updated value" );
    $class_sort_rule_cache = GetClassSortRule($sort_rule);
    is_deeply( $class_sort_rule_cache, $class_sort_rule_db, "Now both get the correct value" );

    $schema->storage->txn_rollback;

};
