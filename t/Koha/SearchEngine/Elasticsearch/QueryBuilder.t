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

use Test::More tests => 3;

use Koha::SearchEngine::Elasticsearch::QueryBuilder;

subtest '_truncate_terms() tests' => sub {
    plan tests => 7;

    my $qb;
    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX }),
        'Creating a new QueryBuilder object'
    );

    my $res = $qb->_truncate_terms('donald');
    is_deeply($res, 'donald*', 'single search term returned correctly');

    $res = $qb->_truncate_terms('donald duck');
    is_deeply($res, 'donald* duck*', 'two search terms returned correctly');

    $res = $qb->_truncate_terms(' donald   duck ');
    is_deeply($res, 'donald* duck*', 'two search terms surrounded by spaces returned correctly');

    $res = $qb->_truncate_terms('"donald duck"');
    is_deeply($res, '"donald duck"', 'quoted search term returned correctly');

    $res = $qb->_truncate_terms('"donald, duck"');
    is_deeply($res, '"donald, duck"', 'quoted search term with comma returned correctly');

    $res = $qb->_truncate_terms(' "donald   duck" ');
    is_deeply($res, '"donald   duck"', 'quoted search terms surrounded by spaces correctly');
};

subtest '_split_query() tests' => sub {
    plan tests => 7;

    my $qb;
    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX }),
        'Creating a new QueryBuilder object'
    );

    my @res = $qb->_split_query('donald');
    my @exp = 'donald';
    is_deeply(\@res, \@exp, 'single search term returned correctly');

    @res = $qb->_split_query('donald duck');
    @exp = ('donald', 'duck');
    is_deeply(\@res, \@exp, 'two search terms returned correctly');

    @res = $qb->_split_query(' donald   duck ');
    @exp = ('donald', 'duck');
    is_deeply(\@res, \@exp, 'two search terms surrounded by spaces returned correctly');

    @res = $qb->_split_query('"donald duck"');
    @exp = ( '"donald duck"' );
    is_deeply(\@res, \@exp, 'quoted search term returned correctly');

    @res = $qb->_split_query('"donald, duck"');
    @exp = ( '"donald, duck"' );
    is_deeply(\@res, \@exp, 'quoted search term with comma returned correctly');

    @res = $qb->_split_query(' "donald   duck" ');
    @exp = ( '"donald   duck"' );
    is_deeply(\@res, \@exp, 'quoted search terms surrounded by spaces correctly');
};

subtest '_clean_search_term() tests' => sub {
    plan tests => 10;

    my $qb;
    ok(
        $qb = Koha::SearchEngine::Elasticsearch::QueryBuilder->new({ 'index' => $Koha::SearchEngine::Elasticsearch::BIBLIOS_INDEX }),
        'Creating a new QueryBuilder object'
    );

    my $res = $qb->_clean_search_term('an=123');
    is($res, 'koha-auth-number:123', 'equals sign replaced with colon');

    $res = $qb->_clean_search_term('"balanced quotes"');
    is($res, '"balanced quotes"', 'balanced quotes returned correctly');

    $res = $qb->_clean_search_term('unbalanced quotes"');
    is($res, 'unbalanced quotes ', 'unbalanced quotes removed');

    $res = $qb->_clean_search_term('"unbalanced "quotes"');
    is($res, ' unbalanced  quotes ', 'unbalanced quotes removed');

    $res = $qb->_clean_search_term('test : query');
    is($res, 'test query', 'dangling colon removed');

    $res = $qb->_clean_search_term('test :: query');
    is($res, 'test query', 'dangling double colon removed');

    $res = $qb->_clean_search_term('test "another : query"');
    is($res, 'test "another : query"', 'quoted dangling colon not removed');

    $res = $qb->_clean_search_term('test {another part}');
    is($res, 'test "another part"', 'curly brackets replaced correctly');

    $res = $qb->_clean_search_term('test {another part');
    is($res, 'test  another part', 'unbalanced curly brackets replaced correctly');
};

1;
