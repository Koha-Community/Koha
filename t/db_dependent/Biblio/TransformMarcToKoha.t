#!/usr/bin/perl

# Tests for C4::Biblio::TransformMarcToKoha

# Copyright 2017 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 5;
use MARC::Record;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Caches;
use Koha::MarcSubfieldStructures;
use C4::Biblio qw( TransformMarcToKoha );

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Create a few mappings
# Note: TransformMarcToKoha wants a table name (biblio, biblioitems or items)
Koha::MarcSubfieldStructures->search( { frameworkcode => '', tagfield => [ '300', '500' ] } )->delete;
Koha::MarcSubfieldStructure->new(
    { frameworkcode => '', tagfield => '300', tagsubfield => 'a', kohafield => 'biblio.field1' } )->store;
Koha::MarcSubfieldStructure->new(
    { frameworkcode => '', tagfield => '300', tagsubfield => 'b', kohafield => 'biblio.field2' } )->store;
Koha::MarcSubfieldStructure->new(
    { frameworkcode => '', tagfield => '500', tagsubfield => 'a', kohafield => 'biblio.field3' } )->store;
Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-");

subtest 'Test a few mappings' => sub {
    plan tests => 6;

    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '300', '', '', a => 'a1',    b => 'b1' ),
        MARC::Field->new( '300', '', '', a => 'a2',    b => 'b2' ),
        MARC::Field->new( '500', '', '', a => 'note1', a => 'note2' ),
    );
    my $result = C4::Biblio::TransformMarcToKoha( { record => $marc } );

    # Note: TransformMarcToKoha stripped the table prefix biblio.
    is( keys %{$result},   3,               'Found all three mappings' );
    is( $result->{field1}, 'a1 | a2',       'Check field1 results' );
    is( $result->{field2}, 'b1 | b2',       'Check field2 results' );
    is( $result->{field3}, 'note1 | note2', 'Check field3 results' );

    is_deeply(
        C4::Biblio::TransformMarcToKoha( { record => $marc, kohafields => ['biblio.field1'] } ),
        { field1 => 'a1 | a2' }, 'TransformMarcToKoha returns biblio.field1 if kohafields specified'
    );
    is_deeply(
        C4::Biblio::TransformMarcToKoha( { record => $marc, kohafields => ['field4'] } ),
        {}, 'TransformMarcToKoha returns empty hashref on unknown kohafields'
    );

};

subtest 'Multiple mappings for one kohafield' => sub {
    plan tests => 4;

    # Add another mapping to field1
    Koha::MarcSubfieldStructures->search( { frameworkcode => '', tagfield => '510' } )->delete;
    Koha::MarcSubfieldStructure->new(
        { frameworkcode => '', tagfield => '510', tagsubfield => 'a', kohafield => 'biblio.field1' } )->store;
    Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-");

    my $marc = MARC::Record->new;
    $marc->append_fields( MARC::Field->new( '300', '', '', a => '3a' ) );
    my $result = C4::Biblio::TransformMarcToKoha( { record => $marc } );
    is_deeply( $result, { field1 => '3a' }, 'Simple start' );
    $marc->append_fields( MARC::Field->new( '510', '', '', a => '' ) );
    $result = C4::Biblio::TransformMarcToKoha( { record => $marc } );
    is_deeply( $result, { field1 => '3a' }, 'An empty 510a makes no difference' );
    $marc->append_fields( MARC::Field->new( '510', '', '', a => '51' ) );
    $result = C4::Biblio::TransformMarcToKoha( { record => $marc } );
    is_deeply( $result, { field1 => '3a | 51' }, 'Got 300a and 510a' );

    is_deeply(
        C4::Biblio::TransformMarcToKoha( { kohafields => ['biblio.field1'], record => $marc } ),
        { 'field1' => '3a | 51' }, 'TransformMarcToKoha returns biblio.field1 when kohafields specified'
    );
};

subtest 'Testing _adjust_pubyear' => sub {
    plan tests => 18;

    is( C4::Biblio::_adjust_pubyear('2004 c2000 2007'), 2000,  'First cYEAR' );
    is( C4::Biblio::_adjust_pubyear('2004 2000 2007'),  2004,  'First year' );
    is( C4::Biblio::_adjust_pubyear('18xx 1900'),       1900,  '1900 has priority over 18xx' );
    is( C4::Biblio::_adjust_pubyear('18xx'),            1800,  '18xx on its own' );
    is( C4::Biblio::_adjust_pubyear('197X'),            1970,  '197X on its own' );
    is( C4::Biblio::_adjust_pubyear('1...'),            1000,  '1... on its own' );
    is( C4::Biblio::_adjust_pubyear('12?? 13xx'),       1200,  '12?? first' );
    is( C4::Biblio::_adjust_pubyear('12? 1x'),          1200,  '12? first' );
    is( C4::Biblio::_adjust_pubyear('198-'),            1980,  '198-' );
    is( C4::Biblio::_adjust_pubyear('19--'),            1900,  '19--' );
    is( C4::Biblio::_adjust_pubyear('19-'),             1900,  '19-' );
    is( C4::Biblio::_adjust_pubyear('1-'),              1000,  '1-' );
    is( C4::Biblio::_adjust_pubyear('2xxx'),            2000,  '2xxx' );
    is( C4::Biblio::_adjust_pubyear('2xx'),             2000,  '2xx' );
    is( C4::Biblio::_adjust_pubyear('2x'),              2000,  '2x' );
    is( C4::Biblio::_adjust_pubyear('198-?'),           1980,  '198-?' );
    is( C4::Biblio::_adjust_pubyear('1981-'),           1981,  'Date range returns first date' );
    is( C4::Biblio::_adjust_pubyear('broken'),          undef, 'Non-matching data' );
};

subtest 'Test repeatable subfields' => sub {
    plan tests => 5;

    # Make 510x repeatable and 510y not
    Koha::MarcSubfieldStructures->search( { frameworkcode => '', tagfield => '510' } )->delete;
    Koha::MarcSubfieldStructure->new(
        { frameworkcode => '', tagfield => '510', tagsubfield => 'x', kohafield => 'items.test', repeatable => 1 } )
        ->store;
    Koha::MarcSubfieldStructure->new(
        { frameworkcode => '', tagfield => '510', tagsubfield => 'y', kohafield => 'items.norepeat', repeatable => 0 } )
        ->store;
    Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-");

    my $marc = MARC::Record->new;
    $marc->append_fields( MARC::Field->new( '510', '', '', x => '1', x => '2', y => '3 | 4', y => '5' ) )
        ;    # actually, we should only have one $y (BZ 24652)
    my $result = C4::Biblio::TransformMarcToKoha( { record => $marc } );
    is( $result->{test},     '1 | 2',     'Check 510x for two values' );
    is( $result->{norepeat}, '3 | 4 | 5', 'Check 510y too' );

    Koha::MarcSubfieldStructure->new(
        { frameworkcode => '', tagfield => '510', tagsubfield => 'a', kohafield => 'biblio.field1' } )->store;
    Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-");
    $marc->append_fields( MARC::Field->new( '510', '', '', a => '1' ) )
        ;    # actually, we should only have one $y (BZ 24652)

    $result = C4::Biblio::TransformMarcToKoha( { record => $marc, limit_table => 'no_items' } );
    is( $result->{test},     undef, 'Item field not returned when "no_items" passed' );
    is( $result->{norepeat}, undef, 'Item field not returned when "no_items" passed' );
    is( $result->{field1},   1,     'Biblio field returned when "no_items" passed' );
};

# Cleanup
Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-");
$schema->storage->txn_rollback;
