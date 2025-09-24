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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;

use Test::NoWarnings;
use Test::More tests => 6;

use open qw/ :std :utf8 /;

use t::lib::Mocks;
use Test::MockModule;

use MARC::Record;
use MARC::Field;
use utf8;
use C4::AuthoritiesMarc qw/ AddAuthority /;

BEGIN {
    use_ok( 'C4::Heading', qw( field valid_heading_subfield ) );
}

subtest "MARC21 tests" => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    ok( C4::Heading::valid_heading_subfield( '100',  'a' ), '100a valid for bib' );
    ok( !C4::Heading::valid_heading_subfield( '100', 'e' ), '100e not valid for bib' );

    ok( C4::Heading::valid_heading_subfield( '100', 'a', 1 ), '100a valid for authority' );

    ok( C4::Heading::valid_heading_subfield( '110',  'a' ), '110a valid for bib' );
    ok( !C4::Heading::valid_heading_subfield( '110', 'e' ), '110e not valid for bib' );

    ok( C4::Heading::valid_heading_subfield( '600',  'a' ), '600a valid for bib' );
    ok( !C4::Heading::valid_heading_subfield( '600', 'e' ), '600e not valid for bib' );

    ok( !C4::Heading::valid_heading_subfield( '012', 'a' ), '012a invalid field for bib' );
};

subtest "UNIMARC tests" => sub {
    plan tests => 7;

    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

    ok( C4::Heading::valid_heading_subfield( '100',  'a' ), '100a valid for bib' );
    ok( !C4::Heading::valid_heading_subfield( '100', 'i' ), '100i not valid fir bib' );

    ok( C4::Heading::valid_heading_subfield( '110',  'a' ), '110a valid for bib' );
    ok( !C4::Heading::valid_heading_subfield( '110', 'i' ), '110i not valid for bib' );

    ok( C4::Heading::valid_heading_subfield( '600',  'a' ), '600a valid for bib' );
    ok( !C4::Heading::valid_heading_subfield( '600', 'i' ), '600i not valid for bib' );

    ok( !C4::Heading::valid_heading_subfield( '012', 'a' ), '012a invalid field for bib' );
};

subtest "_search tests" => sub {

    plan tests => 11;

    t::lib::Mocks::mock_preference( 'marcflavour',  'MARC21' );
    t::lib::Mocks::mock_preference( 'SearchEngine', 'Elasticsearch' );

    # NOTE: We are testing solely against ES here to make the assumptions simpler while testing
    # C4/Headings code specifically. The actual query building and searching code should
    # be covered in other test files
    my $search = Test::MockModule->new('Koha::SearchEngine::Elasticsearch::Search');

    $search->mock(
        'search_auth_compat',
        sub {
            my $self         = shift;
            my $search_query = shift;
            return ( $search_query, 1 );
        }
    );

    t::lib::Mocks::mock_preference( 'LinkerConsiderThesaurus', '0' );

    my $field          = MARC::Field->new( '650', ' ', '0', a => 'Uncles', x => 'Fiction' );
    my $heading        = C4::Heading->new_from_field($field);
    my ($search_query) = $heading->_search('match-heading');
    my $terms          = $search_query->{query}->{bool}->{must};
    my $expected_terms = [
        { term => { 'match-heading.ci_raw' => 'Uncles generalsubdiv Fiction' } },
    ];
    is_deeply(
        $terms, $expected_terms,
        "Search formed only using heading content, not thesaurus, when LinkerConsiderThesaurus disabled"
    );

    t::lib::Mocks::mock_preference( 'LinkerConsiderThesaurus', '1' );

    $field   = MARC::Field->new( '650', ' ', '0', a => 'Uncles', x => 'Fiction' );
    $heading = C4::Heading->new_from_field($field);
    ($search_query) = $heading->_search('match-heading');
    $terms          = $search_query->{query}->{bool}->{must};
    $expected_terms = [
        { term => { 'match-heading.ci_raw'             => 'Uncles generalsubdiv Fiction' } },
        { term => { 'subject-heading-thesaurus.ci_raw' => 'a' } },
    ];
    is_deeply( $terms, $expected_terms, "Search formed as expected for a subject with second indicator 0" );

    $field   = MARC::Field->new( '650', ' ', '3', a => 'Uncles', x => 'Fiction' );
    $heading = C4::Heading->new_from_field($field);
    ($search_query) = $heading->_search('match-heading');
    $terms          = $search_query->{query}->{bool}->{must};
    $expected_terms = [
        { term => { 'match-heading.ci_raw'             => 'Uncles generalsubdiv Fiction' } },
        { term => { 'subject-heading-thesaurus.ci_raw' => 'd' } },
    ];
    is_deeply( $terms, $expected_terms, "Search formed as expected with second indicator 3" );

    $field   = MARC::Field->new( '650', ' ', '7', a => 'Uncles', x => 'Fiction', 2 => 'special_sauce' );
    $heading = C4::Heading->new_from_field($field);
    ($search_query) = $heading->_search('match-heading');
    $terms          = $search_query->{query}->{bool}->{must};
    $expected_terms = [
        { term => { 'match-heading.ci_raw'             => 'Uncles generalsubdiv Fiction' } },
        { term => { 'subject-heading-thesaurus.ci_raw' => 'special_sauce' } },
    ];
    is_deeply( $terms, $expected_terms, "Search formed as expected with second indicator 7 and subfield 2" );

    $field   = MARC::Field->new( '650', ' ', '4', a => 'Uncles', x => 'Fiction' );
    $heading = C4::Heading->new_from_field($field);
    ($search_query) = $heading->_search('match-heading');
    $terms          = $search_query->{query}->{bool}->{must};
    $expected_terms = [
        { term => { 'match-heading.ci_raw'             => 'Uncles generalsubdiv Fiction' } },
        { term => { 'subject-heading-thesaurus.ci_raw' => '|' } },
    ];
    is_deeply( $terms, $expected_terms, "Search looks for thesaurus '|' when second indicator 4" );

    $field   = MARC::Field->new( '100', ' ', '', a => 'Yankovic, Al', d => '1959-,' );
    $heading = C4::Heading->new_from_field($field);
    ($search_query) = $heading->_search('match-heading');
    $terms          = $search_query->{query}->{bool}->{must};
    $expected_terms = [
        { term => { 'match-heading.ci_raw' => 'Yankovic, Al 1959' } },
    ];
    is_deeply(
        $terms, $expected_terms,
        "Search formed as expected for a non-subject field with single punctuation mark"
    );

    $field   = MARC::Field->new( '100', ' ', '', a => 'Yankovic, Al', d => '1959-,', e => '[author]' );
    $heading = C4::Heading->new_from_field($field);
    ($search_query) = $heading->_search('match-heading');
    $terms          = $search_query->{query}->{bool}->{must};
    $expected_terms = [
        { term => { 'match-heading.ci_raw' => 'Yankovic, Al 1959' } },
    ];
    is_deeply(
        $terms, $expected_terms,
        "Search formed as expected for a non-subject field with double punctuation, hyphen+comma"
    );

    $field   = MARC::Field->new( '100', ' ', '', a => 'Tolkien, J.R.R.,', e => '[author]' );
    $heading = C4::Heading->new_from_field($field);
    ($search_query) = $heading->_search('match-heading');
    $terms          = $search_query->{query}->{bool}->{must};
    $expected_terms = [
        { term => { 'match-heading.ci_raw' => 'Tolkien, J.R.R' } },
    ];
    is_deeply(
        $terms, $expected_terms,
        "Search formed as expected for a non-subject field with double punctuation, period+comma "
    );

    # Special case where thesaurus defined in subfield 2 should also match record with no thesaurus
    # In the ES index an auth rec. without 040 $f, so 'z' from 008/11 is present in subject-heading-thesaurus
    my $expected_authid = 12345;
    $search->mock(
        'search_auth_compat',
        sub {
            my $self         = shift;
            my $search_query = shift;
            if ( scalar @{ $search_query->{query}->{bool}->{must} } == 2 ) {
                if ( $search_query->{query}->{bool}->{must}[1]->{term}->{'subject-heading-thesaurus.ci_raw'} eq
                    'special_sauce' )
                {
                    # no record with 'special_sauce'
                    return ( [], 0 );
                } elsif (
                    $search_query->{query}->{bool}->{must}[1]->{term}->{'subject-heading-thesaurus.ci_raw'} eq 'z' )
                {
                    # for 'notdefined' we return the only record with 008/11 = 'z'
                    return ( [ { authid => $expected_authid } ], 1 );
                } else {

                    # other cases - nothing
                    return ( [], 0 );
                }
            } elsif ( scalar @{ $search_query->{query}->{bool}->{must} } == 1 ) {
                return ['no thesaurus checking at all'];
            }
        }
    );
    $field   = MARC::Field->new( '650', ' ', '7', a => 'Uncles', x => 'Fiction', 2 => 'special_sauce' );
    $heading = C4::Heading->new_from_field($field);
    my ($matched_auths) = $heading->_search('match-heading');
    my $expected_result = [ { authid => $expected_authid } ];
    is_deeply(
        $matched_auths, $expected_result,
        "When thesaurus in subfield 2, we should search again for notdefined (008_11 = z) and get a result"
    );

    # In the ES index an auth rec. with 040 $f 'special_sauce', so 'z' from 008/11 not present in subject-heading-thesaurus
    $search->mock(
        'search_auth_compat',
        sub {
            my $self         = shift;
            my $search_query = shift;
            if ( scalar @{ $search_query->{query}->{bool}->{must} } == 2 ) {
                if ( $search_query->{query}->{bool}->{must}[1]->{term}->{'subject-heading-thesaurus.ci_raw'} eq
                    'special_sauce' )
                {
                    # no record with 'special_sauce'
                    return ( [ { authid => $expected_authid } ], 1 );
                } elsif (
                    $search_query->{query}->{bool}->{must}[1]->{term}->{'subject-heading-thesaurus.ci_raw'} eq 'z' )
                {
                    # for 'notdefined' we return the only record with 008/11 = 'z'
                    return ( [], 0 );
                } else {

                    # other cases - nothing
                    return ( [], 0 );
                }
            } elsif ( scalar @{ $search_query->{query}->{bool}->{must} } == 1 ) {
                return ['no thesaurus checking at all'];
            }
        }
    );

    # Special case continued: but it should not match an authority record with a different thesaurus
    # defined in 040 $f
    $field   = MARC::Field->new( '650', ' ', '7', a => 'Uncles', x => 'Fiction', 2 => 'special_sauce_2' );
    $heading = C4::Heading->new_from_field($field);

    ($matched_auths) = $heading->_search('match-heading');
    $expected_result = [];
    is_deeply(
        $matched_auths, $expected_result,
        'When thesaurus in subfield 2, and nothing is found, we search again for notdefined (008_11 = z), and get no results because 040 $f with different value exists in the auth rec.'
    );

    # When LinkerConsiderThesaurus off, no attantion is being paid on the thesaurus
    t::lib::Mocks::mock_preference( 'LinkerConsiderThesaurus', '0' );

    ($matched_auths) = $heading->_search('match-heading');
    $expected_result = ['no thesaurus checking at all'];
    is_deeply(
        $matched_auths, $expected_result,
        "When thesaurus in subfield 2, and nothing is found, we don't search again if LinkerConsiderThesaurus disabled"
    );
};

subtest "authorities exact match tests" => sub {

    plan tests => 3;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    my $schema = Koha::Database->new->schema;
    $schema->storage->txn_begin;

    my $authrec1 = MARC::Record->new;
    $authrec1->leader('     nz  a22     o  4500');
    $authrec1->insert_fields_ordered( MARC::Field->new( '100', '1', ' ', a => 'Rakowski, Albin', x => 'poetry' ) );
    my $authid1 = AddAuthority( $authrec1, undef, 'PERSO_NAME', { skip_record_index => 1 } );

    my $authrec2 = MARC::Record->new;
    $authrec2->leader('     nz  a22     o  4500');
    $authrec2->insert_fields_ordered( MARC::Field->new( '100', '1', ' ', a => 'Rąkowski, Albin', x => 'poetry' ) );
    my $authid2 = AddAuthority( $authrec2, undef, 'PERSO_NAME', { skip_record_index => 1 } );

    my $heading = Test::MockModule->new('C4::Heading');
    $heading->mock(
        '_search',
        sub {
            my $self = shift;
            return ( [ { authid => $authid1 }, { authid => $authid2 } ], 2 );
        }
    );

    my $biblio_field   = MARC::Field->new( '600', '1', '1', a => 'Rakowski, Albin', x => 'poetry' );
    my $biblio_heading = C4::Heading->new_from_field($biblio_field);

    t::lib::Mocks::mock_preference( 'LinkerConsiderDiacritics', '0' );

    my $authorities = $biblio_heading->authorities(1);
    is_deeply(
        $authorities, [ { authid => $authid1 }, { authid => $authid2 } ],
        "Authorities diacritics filter off - two authids returned for authority search 'Rakowski' from biblio 600 field 'Rakowski'"
    );

    t::lib::Mocks::mock_preference( 'LinkerConsiderDiacritics', '1' );

    $authorities = $biblio_heading->authorities(1);
    is_deeply(
        $authorities, [ { authid => $authid1 } ],
        "Authorities filter OK - remained authority 'Rakowski' for biblio 'Rakowski'"
    );

    my $authrec3 = MARC::Record->new;
    $authrec3->leader('     nz  a22     o  4500');
    $authrec3->insert_fields_ordered( MARC::Field->new( '100', '1', ' ', a => 'Bruckner, Karl' ) );
    my $authid3 = AddAuthority( $authrec3, undef, 'PERSO_NAME', { skip_record_index => 1 } );

    $heading->mock(
        '_search',
        sub {
            my $self = shift;
            return ( [ { authid => $authid3 } ], 1 );
        }
    );

    $biblio_field   = MARC::Field->new( '700', '1', ' ', a => 'Brückner, Karl' );
    $biblio_heading = C4::Heading->new_from_field($biblio_field);

    $authorities = $biblio_heading->authorities(1);
    is_deeply( $authorities, [], "Authorities filter OK - 'Brückner' not matched with 'Bruckner'" );

    $schema->storage->txn_rollback;

};
