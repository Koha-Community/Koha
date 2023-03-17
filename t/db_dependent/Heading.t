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

use strict;
use warnings;

use Test::More tests => 4;

use t::lib::Mocks;

BEGIN {
    use_ok('C4::Heading', qw( field valid_heading_subfield ));
}

subtest "MARC21 tests" => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');

    ok(C4::Heading::valid_heading_subfield('100', 'a'), '100a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('100', 'e'), '100e not valid for bib');

    ok(C4::Heading::valid_heading_subfield('100', 'a', 1), '100a valid for authority');

    ok(C4::Heading::valid_heading_subfield('110', 'a'), '110a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('110', 'e'), '110e not valid for bib');

    ok(C4::Heading::valid_heading_subfield('600', 'a'), '600a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('600', 'e'), '600e not valid for bib');

    ok(!C4::Heading::valid_heading_subfield('012', 'a'), '012a invalid field for bib');
};

subtest "UNIMARC tests" => sub {
    plan tests => 7;

    t::lib::Mocks::mock_preference('marcflavour', 'UNIMARC');

    ok(C4::Heading::valid_heading_subfield('100', 'a'), '100a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('100', 'i'), '100i not valid fir bib');

    ok(C4::Heading::valid_heading_subfield('110', 'a'), '110a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('110', 'i'), '110i not valid for bib');

    ok(C4::Heading::valid_heading_subfield('600', 'a'), '600a valid for bib');
    ok(!C4::Heading::valid_heading_subfield('600', 'i'), '600i not valid for bib');

    ok(!C4::Heading::valid_heading_subfield('012', 'a'), '012a invalid field for bib');
};

subtest "_search tests" => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
    t::lib::Mocks::mock_preference('SearchEngine', 'Elasticsearch');
    my $search = Test::MockModule->new('Koha::SearchEngine::Elasticsearch::Search');

    $search->mock(
        'search_auth_compat',
        sub {
            my $self         = shift;
            my $search_query = shift;
            return $search_query;
        }
    );

    my ( $field, $heading, $search_query, $terms );

    $field = MARC::Field->new( '100', ' ', '', a => 'Yankovic, Al', d => '1959-,' );
    $heading = C4::Heading->new_from_field($field);
    $search_query = $heading->_search( 'match-heading' );
    $terms = $search_query->{query}->{bool}->{must};
    is_deeply( $terms->[0], { term => { 'match-heading.ci_raw' => 'Yankovic, Al 1959' } }, "Search formed as expected for a non-subject field with single punctuation mark");


    $field = MARC::Field->new( '100', ' ', '', a => 'Yankovic, Al', d => '1959-,', e => '[author]' );
    $heading = C4::Heading->new_from_field($field);
    $search_query = $heading->_search( 'match-heading' );
    $terms = $search_query->{query}->{bool}->{must};
    is_deeply( $terms->[0], { term => { 'match-heading.ci_raw' => 'Yankovic, Al 1959' } }, "Search formed as expected for a non-subject field with double punctuation, hyphen+comma");

    $field = MARC::Field->new( '100', ' ', '', a => 'Tolkien, J.R.R.,', e => '[author]' );
    $heading = C4::Heading->new_from_field($field);
    $search_query = $heading->_search( 'match-heading' );
    $terms = $search_query->{query}->{bool}->{must};
    is_deeply( $terms->[0], { term => { 'match-heading.ci_raw' => 'Tolkien, J.R.R' } }, "Search formed as expected for a non-subject field with double punctuation, period+comma ");

};
