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

use C4::Biblio;
use Test::More;
use Test::MockModule;
use Test::Warn;
use t::lib::Mocks;
use t::lib::TestBuilder;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 4;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

# Mock the DB connexion and C4::Context
use Test::DBIx::Class;

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
    is( $query_cgi, "query_cgi&op=operator&idx=index&q=original_operand",
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
    is( $query, "query AND parsed_operand",
        "\$query built correctly (no operator)");
    is( $query_cgi, "query_cgi&op=AND&idx=index&q=original_operand",
        "\$query_cgi built correctly (no operator)");
    is( $query_desc, "query_desc AND index_plus original_operand",
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
    is( $query, "query  parsed_operand",
        "\$query built correctly (no previous operand)");
    is( $query_cgi, "query_cgi&idx=index&q=original_operand",
        "\$query_cgi built correctly (no previous operand)");
    is( $query_desc, "query_desc  index_plus original_operand",
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
    is( $query_cgi, "query_cgi&op=operator&q=original_operand",
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
    is( $query_cgi, "query_cgi&op=operator&idx=index&q=original_operand",
        "\$query_cgi built correctly (no index_plus passed)");
    is( $query_desc, "query_desc operator  original_operand",
        "\$query_desc build correctly (no index_plus passed)");
    is( $previous_operand, "previous_operand",
        "\$query build correctly (no index_plus passed)");

};

subtest "searchResults PassItemMarcToXSLT test" => sub {

    plan tests => 2;

    t::lib::Mocks::mock_preference('OPACXSLTResultsDisplay','default');
    t::lib::Mocks::mock_preference('marcflavour','MARC21');
    my $mock_xslt = Test::MockModule->new("C4::Search");
    $mock_xslt->mock( XSLTParse4Display => sub {
        my $params = shift;
        my $record = $params->{record};
        warn $record->field('952') ? "Item here" : "No item";
        return;
    });

    my $builder = t::lib::TestBuilder->new;

    my $item = $builder->build_sample_item();
    my $record = $item->biblio->metadata->record({ embed_items => 1 });

    t::lib::Mocks::mock_preference('PassItemMarcToXSLT','1');

    warnings_like { C4::Search::searchResults({ interface => "opac" },"test",1,1,0,0,[ $record->as_xml_record ] ,undef) }
        [qr/Item here/],
        "Item field returned from default XSLT if pref set";

    t::lib::Mocks::mock_preference('PassItemMarcToXSLT','0');

    warnings_like { C4::Search::searchResults({ interface => "opac" },"test",1,1,0,0,[ $record->as_xml_record ] ,undef) }
        [qr/No item/],
        "Item field returned from default XSLT if pref set";

}
