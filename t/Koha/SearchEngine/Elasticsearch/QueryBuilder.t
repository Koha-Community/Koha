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

1;