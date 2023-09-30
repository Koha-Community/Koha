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

use Test::More tests => 2;
use Test::MockModule;
use Test::Warn;
use t::lib::Mocks;

use C4::Search;

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

    my $xml_record = q{
<record
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    xmlns="http://www.loc.gov/MARC21/slim">

  <leader>00144    a2200073   4500</leader>
  <datafield tag="245" ind1=" " ind2=" ">
    <subfield code="a">Some boring read</subfield>
  </datafield>
  <datafield tag="100" ind1=" " ind2=" ">
    <subfield code="a">Some boring author</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">gOlAIZMF</subfield>
  </datafield>
  <datafield tag="952" ind1=" " ind2=" ">
    <subfield code="0">0</subfield>
    <subfield code="1">0</subfield>
    <subfield code="4">0</subfield>
    <subfield code="7">0</subfield>
    <subfield code="9">1117</subfield>
    <subfield code="a">D6C8Pj</subfield>
    <subfield code="b">D6C8Pj</subfield>
    <subfield code="d">2023-03-31</subfield>
    <subfield code="l">0</subfield>
    <subfield code="p">g57ad1Zn3NOYZ</subfield>
    <subfield code="r">2023-03-31</subfield>
    <subfield code="w">2023-03-31</subfield>
    <subfield code="y">gOlAIZMF</subfield>
  </datafield>
  <datafield tag="999" ind1=" " ind2=" ">
    <subfield code="c">553</subfield>
    <subfield code="d">553</subfield>
  </datafield>
</record>
};
    t::lib::Mocks::mock_preference('PassItemMarcToXSLT','1');

    # The routine uses a count of items in DB to determine if record should be hidden.
    # Our item is not in the DB, so we avoid hiding the record which would
    # mean we don't call XSLTParse4Display.
    # Also ensure item is not hidden
    t::lib::Mocks::mock_preference('OpacHiddenItems','');
    t::lib::Mocks::mock_preference('OpacHiddenItemsHidesRecord','0');

    warnings_like { C4::Search::searchResults({ interface => "opac" },"test",1,1,0,0,[ $xml_record ] ,undef) }
        [qr/Item here/],
        "Item field returned from default XSLT if pref set";

    t::lib::Mocks::mock_preference('PassItemMarcToXSLT','0');

    warnings_like { C4::Search::searchResults({ interface => "opac" },"test",1,1,0,0,[ $xml_record ] ,undef) }
        [qr/No item/],
        "Item field returned from default XSLT if pref set";

}
