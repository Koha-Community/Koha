#!/usr/bin/perl

# Tests for C4::Biblio::TransformMarcToKoha, TransformMarcToKohaOneField

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
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 3;
use MARC::Record;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Caches;
use Koha::MarcSubfieldStructures;
use C4::Biblio;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Create a few mappings
# Note: TransformMarcToKoha wants a table name (biblio, biblioitems or items)
Koha::MarcSubfieldStructures->search({ frameworkcode => '', tagfield => [ '300', '500' ] })->delete;
Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '300', tagsubfield => 'a', kohafield => 'biblio.field1' })->store;
Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '300', tagsubfield => 'b', kohafield => 'biblio.field2' })->store;
Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '500', tagsubfield => 'a', kohafield => 'biblio.field3' })->store;
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

subtest 'Test a few mappings' => sub {
    plan tests => 7;

    my $marc = MARC::Record->new;
    $marc->append_fields(
        MARC::Field->new( '300', '', '', a => 'a1', b => 'b1' ),
        MARC::Field->new( '300', '', '', a => 'a2', b => 'b2' ),
        MARC::Field->new( '500', '', '', a => 'note1', a => 'note2' ),
    );
    my $result = C4::Biblio::TransformMarcToKoha( $marc );
        # Note: TransformMarcToKoha stripped the table prefix biblio.
    is( keys %{$result}, 3, 'Found all three mappings' );
    is( $result->{field1}, 'a1 | a2', 'Check field1 results' );
    is( $result->{field2}, 'b1 | b2', 'Check field2 results' );
    is( $result->{field3}, 'note1 | note2', 'Check field3 results' );

    is( C4::Biblio::TransformMarcToKohaOneField( 'biblio.field1', $marc ),
        $result->{field1}, 'TransformMarcToKohaOneField returns biblio.field1');
    is( C4::Biblio::TransformMarcToKohaOneField( 'field4', $marc ),
        undef, 'TransformMarcToKohaOneField returns undef' );

    # Bug 19096 Default is authoritative now
    # Test passing another framework
    # CAUTION: This parameter of TransformMarcToKoha will be removed later
    my $new_fw = t::lib::TestBuilder->new->build({source => 'BiblioFramework'});
    $result = C4::Biblio::TransformMarcToKoha($marc, $new_fw->{frameworkcode});
    is( keys %{$result}, 3, 'Still found all three mappings' );
};

subtest 'Multiple mappings for one kohafield' => sub {
    plan tests => 4;

    # Add another mapping to field1
    Koha::MarcSubfieldStructures->search({ frameworkcode => '', tagfield => '510' })->delete;
    Koha::MarcSubfieldStructure->new({ frameworkcode => '', tagfield => '510', tagsubfield => 'a', kohafield => 'biblio.field1' })->store;
    Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );

    my $marc = MARC::Record->new;
    $marc->append_fields( MARC::Field->new( '300', '', '', a => '3a' ) );
    my $result = C4::Biblio::TransformMarcToKoha( $marc );
    is_deeply( $result, { field1 => '3a' }, 'Simple start' );
    $marc->append_fields( MARC::Field->new( '510', '', '', a => '' ) );
    $result = C4::Biblio::TransformMarcToKoha( $marc );
    is_deeply( $result, { field1 => '3a' }, 'An empty 510a makes no difference' );
    $marc->append_fields( MARC::Field->new( '510', '', '', a => '51' ) );
    $result = C4::Biblio::TransformMarcToKoha( $marc );
    is_deeply( $result, { field1 => '3a | 51' }, 'Got 300a and 510a' );

    is( C4::Biblio::TransformMarcToKohaOneField( 'biblio.field1', $marc ),
        '3a | 51', 'TransformMarcToKohaOneField returns biblio.field1' );
};

subtest 'Testing _adjust_pubyear' => sub {
    plan tests => 8;

    is( C4::Biblio::_adjust_pubyear('2004 c2000 2007'), 2000, 'First cYEAR' );
    is( C4::Biblio::_adjust_pubyear('2004 2000 2007'), 2004, 'First year' );
    is( C4::Biblio::_adjust_pubyear('18xx 1900'), 1900, '1900 has priority over 18xx' );
    is( C4::Biblio::_adjust_pubyear('18xx'), 1800, '18xx on its own' );
    is( C4::Biblio::_adjust_pubyear('197X'), 1970, '197X on its own' );
    is( C4::Biblio::_adjust_pubyear('1...'), 1000, '1... on its own' );
    is( C4::Biblio::_adjust_pubyear('12?? 13xx'), 1200, '12?? first' );
    is( C4::Biblio::_adjust_pubyear('12? 1x'), '12? 1x', 'Too short' );
};

# Cleanup
Koha::Caches->get_instance->clear_from_cache( "MarcSubfieldStructure-" );
$schema->storage->txn_rollback;
