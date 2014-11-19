#!/usr/bin/perl

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
use t::lib::Mocks;

# Mock the DB connexion and C4::Context
my $context =  t::lib::Mocks::mock_dbh;

use_ok('C4::Search');
can_ok('C4::Search',
    qw/_build_initial_query/);

subtest "_build_initial_query tests" => sub {

    plan tests => 20;

    my ($query,$query_cgi,$query_desc,$previous_operand);
    # all params have values
    my $params = {
        query            => "query",
        query_cgi        => "query_cgi",
        query_desc       => "query_desc",
        operator         => "operator",
        parsed_operand   => "parsed_operand",
        original_operand => "original_operand",
        index            => "index",
        index_plus       => "index_plus",
        indexes_set      => "indexes_set",
        previous_operand => "previous_operand"
    };

    ($query,$query_cgi,$query_desc,$previous_operand) =
        C4::Search::_build_initial_query($params);
    is( $query, "query operator parsed_operand",
        "\$query built correctly");
    is( $query_cgi, "query_cgi&op=%20operator%20&idx=index&q=original_operand",
        "\$query_cgi built correctly");
    is( $query_desc, "query_desc operator index_plus original_operand",
        "\$query_desc build correctly");
    is( $previous_operand, "previous_operand",
        "\$query build correctly");

    # no operator
    $params = {
        query            => "query",
        query_cgi        => "query_cgi",
        query_desc       => "query_desc",
        operator         => undef,
        parsed_operand   => "parsed_operand",
        original_operand => "original_operand",
        index            => "index",
        index_plus       => "index_plus",
        indexes_set      => "indexes_set",
        previous_operand => "previous_operand"
    };

    ($query,$query_cgi,$query_desc,$previous_operand) =
        C4::Search::_build_initial_query($params);
    is( $query, "query and parsed_operand",
        "\$query built correctly (no operator)");
    is( $query_cgi, "query_cgi&op=%20and%20&idx=index&q=original_operand",
        "\$query_cgi built correctly (no operator)");
    is( $query_desc, "query_desc and index_plus original_operand",
        "\$query_desc build correctly (no operator)");
    is( $previous_operand, "previous_operand",
        "\$query build correctly (no operator)");

    # no previous operand
    $params = {
        query            => "query",
        query_cgi        => "query_cgi",
        query_desc       => "query_desc",
        operator         => "operator",
        parsed_operand   => "parsed_operand",
        original_operand => "original_operand",
        index            => "index",
        index_plus       => "index_plus",
        indexes_set      => "indexes_set",
        previous_operand => undef
    };

    ($query,$query_cgi,$query_desc,$previous_operand) =
        C4::Search::_build_initial_query($params);
    is( $query, "queryparsed_operand",
        "\$query built correctly (no previous operand)");
    is( $query_cgi, "query_cgi&idx=index&q=original_operand",
        "\$query_cgi built correctly (no previous operand)");
    is( $query_desc, "query_descindex_plus original_operand",
        "\$query_desc build correctly (no previous operand)");
    is( $previous_operand, 1,
        "\$query build correctly (no previous operand)");

    # no index passed
    $params = {
        query            => "query",
        query_cgi        => "query_cgi",
        query_desc       => "query_desc",
        operator         => "operator",
        parsed_operand   => "parsed_operand",
        original_operand => "original_operand",
        index            => undef,
        index_plus       => "index_plus",
        indexes_set      => "indexes_set",
        previous_operand => "previous_operand"
    };

    ($query,$query_cgi,$query_desc,$previous_operand) =
        C4::Search::_build_initial_query($params);
    is( $query, "query operator parsed_operand",
        "\$query built correctly (no index passed)");
    is( $query_cgi, "query_cgi&op=%20operator%20&q=original_operand",
        "\$query_cgi built correctly (no index passed)");
    is( $query_desc, "query_desc operator index_plus original_operand",
        "\$query_desc build correctly (no index passed)");
    is( $previous_operand, "previous_operand",
        "\$query build correctly (no index passed)");

    # no index_plus passed
    $params = {
        query            => "query",
        query_cgi        => "query_cgi",
        query_desc       => "query_desc",
        operator         => "operator",
        parsed_operand   => "parsed_operand",
        original_operand => "original_operand",
        index            => "index",
        index_plus       => undef,
        indexes_set      => "indexes_set",
        previous_operand => "previous_operand"
    };

    ($query,$query_cgi,$query_desc,$previous_operand) =
        C4::Search::_build_initial_query($params);
    is( $query, "query operator parsed_operand",
        "\$query built correctly (no index_plus passed)");
    is( $query_cgi, "query_cgi&op=%20operator%20&idx=index&q=original_operand",
        "\$query_cgi built correctly (no index_plus passed)");
    is( $query_desc, "query_desc operator  original_operand",
        "\$query_desc build correctly (no index_plus passed)");
    is( $previous_operand, "previous_operand",
        "\$query build correctly (no index_plus passed)");

};


1;
