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
use Test::Exception;

use Koha::Database;
use Koha::SearchEngine::Elasticsearch::QueryBuilder

subtest 'build_authorities_query_compat() tests' => sub {

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
            is( $query->{query}->{bool}->{should}[0]->{match}->{_all},
                $search_term);
        } else {
            is( $query->{query}->{bool}->{should}[0]->{match}->{$koha_to_index_name->{$koha_name}},
                $search_term);
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
    is($query->{query}->{bool}->{should}[0]->{match}->{'Heading'}, "Hamilton","Expected search is populated");
    is( scalar @{ $query->{query}->{bool}->{should} }, 1,"Only defined search is populated");

    @values[2] = 'Jefferson';
    $query = $builder->build_authorities_query_compat( \@marclist, undef,
                    undef, \@operator , \@values, 'AUTH_TYPE', 'asc' );
    is($query->{query}->{bool}->{should}[0]->{match}->{'Heading'}, "Hamilton","First index searched as expected");
    is($query->{query}->{bool}->{should}[1]->{match}->{'Match'}, "Jefferson","Second index searched when populated");
    is( scalar @{ $query->{query}->{bool}->{should} }, 2,"Only defined searches are populated");


};
