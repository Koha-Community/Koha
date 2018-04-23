#!/usr/bin/perl
#
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

use Test::More tests => 2;
use C4::Context;
use Test::Exception;
use Test::More tests => 3;

use Koha::Database;
use Koha::SearchEngine::Elasticsearch::QueryBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest 'build_authorities_query_compat() tests' => sub {
    plan tests => 37;

    my $qb;

    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => 'authorities' }),
        'Creating new query builder object for authorities'
    );

    my $koha_to_index_name = $Koha::SearchEngine::Elasticsearch::QueryBuilder::koha_to_index_name;
    my $search_term = 'a';
    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' ) {
            is( $query->{query}->{bool}->{must}[0]->{wildcard}->{"_all.phrase"},
                "*a*");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{wildcard}->{$koha_to_index_name->{$koha_name}.".phrase"},
                "*a*");
        }
    }

    $search_term = 'Donald Duck';
    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' ) {
            is( $query->{query}->{bool}->{must}[0]->{wildcard}->{"_all.phrase"},
                "*donald*");
            is( $query->{query}->{bool}->{must}[1]->{wildcard}->{"_all.phrase"},
                "*duck*");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{wildcard}->{$koha_to_index_name->{$koha_name}.".phrase"},
                "*donald*");
            is( $query->{query}->{bool}->{must}[1]->{wildcard}->{$koha_to_index_name->{$koha_name}.".phrase"},
                "*duck*");
        }
    }

    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['is'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' ) {
            is( $query->{query}->{bool}->{must}[0]->{term}->{"_all.phrase"},
                "donald duck");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{term}->{$koha_to_index_name->{$koha_name}.".phrase"},
                "donald duck");
        }
    }

    foreach my $koha_name ( keys %{ $koha_to_index_name } ) {
        my $query = $qb->build_authorities_query_compat( [ $koha_name ],  undef, undef, ['start'], [$search_term], 'AUTH_TYPE', 'asc' );
        if ( $koha_name eq 'all' ) {
            is( $query->{query}->{bool}->{must}[0]->{prefix}->{"_all.lc_raw"},
                "donald duck");
        } else {
            is( $query->{query}->{bool}->{must}[0]->{prefix}->{$koha_to_index_name->{$koha_name}.".lc_raw"},
                "donald duck");
        }
    }

    # Failing case
    throws_ok {
        $qb->build_authorities_query_compat( [ 'tomas' ],  undef, undef, ['contains'], [$search_term], 'AUTH_TYPE', 'asc' );
    }
    'Koha::Exceptions::WrongParameter',
        'Exception thrown on invalid value in the marclist param';
};

subtest 'build query from form subtests' => sub {
    plan tests => 5;

    my $builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => 'authorities' }),
    #when searching for authorities from a record the form returns marclist with blanks for unentered terms
    my @marclist = ('mainmainentry','mainentry','match', 'all');
    my @values   = ( undef,         'Hamilton',  undef,   undef);
    my @operator = ( 'contains', 'contains', 'contains', 'contains');

    my $query = $builder->build_authorities_query_compat( \@marclist, undef,
                    undef, \@operator , \@values, 'AUTH_TYPE', 'asc' );
    is($query->{query}->{bool}->{must}[0]->{wildcard}->{'Heading.phrase'}, "*hamilton*","Expected search is populated");
    is( scalar @{ $query->{query}->{bool}->{must} }, 1,"Only defined search is populated");

    @values[2] = 'Jefferson';
    $query = $builder->build_authorities_query_compat( \@marclist, undef,
                    undef, \@operator , \@values, 'AUTH_TYPE', 'asc' );
    is($query->{query}->{bool}->{must}[0]->{wildcard}->{'Heading.phrase'}, "*hamilton*","First index searched as expected");
    is($query->{query}->{bool}->{must}[1]->{wildcard}->{'Match.phrase'}, "*jefferson*","Second index searched when populated");
    is( scalar @{ $query->{query}->{bool}->{must} }, 2,"Only defined searches are populated");


};

subtest 'build_query with weighted fields tests' => sub {
    plan tests => 4;

    my $builder = Koha::SearchEngine::Elasticsearch::QueryBuilder->new( { index => 'mydb' } );
    my $db_builder = t::lib::TestBuilder->new();

    Koha::SearchFields->search({})->delete;

    $db_builder->build({
        source => 'SearchField',
        value => {
            name    => 'acqdate',
            label   => 'acqdate',
            weight  => undef
        }
    });

    $db_builder->build({
        source => 'SearchField',
        value => {
            name    => 'title',
            label   => 'title',
            weight  => 25
        }
    });

    $db_builder->build({
        source => 'SearchField',
        value => {
            name    => 'subject',
            label   => 'subject',
            weight  => 15
        }
    });

    my ( undef, $query ) = $builder->build_query_compat( undef, ['title:"donald duck"'], undef, undef,
    undef, undef, undef, { weighted_fields => 1 });

    my $fields = $query->{query}{query_string}{fields};

    is(scalar(@$fields), 3, 'Search is done on 3 fields');
    is($fields->[0], '_all', 'First search field is _all');
    is($fields->[1], 'title^25', 'Second search field is title');
    is($fields->[2], 'subject^15', 'Third search field is subject');
};

$schema->storage->txn_rollback;
