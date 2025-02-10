#!/usr/bin/perl

# Copyright 2024 ByWater Solutions
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
use JSON qw( encode_json );

use Koha::Database;
use Koha::SearchFilters;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $original_count      = Koha::SearchFilters->search->count();
my $original_count_opac = Koha::SearchFilters->search( { opac => 1 } )->count();

my $search_filter = Koha::SearchFilter->new(
    {
        name         => "Test",
        query        => q|{"operands":["programming","internet"],"operators":["OR"],"indexes":["su","su"]}|,
        limits       => q|{"limits":[]}|,
        opac         => 1,
        staff_client => 1
    }
)->store;

is( Koha::SearchFilters->search()->count(), $original_count + 1, "New filter is added" );
is(
    Koha::SearchFilters->search( { opac => 1 } )->count(), $original_count_opac + 1,
    "Searching by opac returns the filter if set"
);
$search_filter->opac(0)->store();
is(
    Koha::SearchFilters->search( { opac => 1 } )->count(), $original_count_opac,
    "Searching by opac doesn't return the filter if not set"
);

subtest 'expand_filter tests' => sub {

    plan tests => 4;

    my $search_filter = Koha::SearchFilter->new(
        {
            name         => "Test",
            query        => q|{"operands":["programming","internet"],"operators":["OR"],"indexes":["su","su"]}|,
            limits       => q|{"limits":["mc-itype,phr:BK","fic:0"]}|,
            opac         => 1,
            staff_client => 1
        }
    )->store;

    my ( $limits, $query_limit ) = $search_filter->expand_filter();

    is_deeply( $limits, [ 'mc-itype,phr:BK', 'fic:0' ], "Limit from filter is correctly expanded" );
    is( $query_limit, '(su=(programming) OR su=(internet))', "Query from filter is correctly expanded and grouped" );

    my $empty_query = {
        indexes   => [ ("kw") x 3 ],
        operands  => [ ("") x 3 ],
        operators => [],
    };
    $search_filter = Koha::SearchFilter->new(
        {
            name         => "Test",
            query        => encode_json($empty_query),
            limits       => q|{"limits":["mc-itype,phr:BK","fic:0"]}|,
            opac         => 1,
            staff_client => 1
        }
    )->store;

    ( $limits, $query_limit ) = $search_filter->expand_filter();

    is_deeply( $limits, [ 'mc-itype,phr:BK', 'fic:0' ], "Limit from filter is correctly expanded" );
    is( $query_limit, '', "Empty query does not generate anything" );

};

$schema->storage->txn_rollback;
