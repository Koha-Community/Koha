#!/usr/bin/perl

# Copyright 2024 Koha Development team
#
# This file is part of Koha
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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Biblio::Metadata::Extractor;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'get_control_number() tests' => sub {

    plan tests => 8;

    foreach my $marcflavour (qw( MARC21 UNIMARC )) {
        t::lib::Mocks::mock_preference( 'marcflavour', $marcflavour );

        my $identifier = "123ASD";

        my $record    = MARC::Record->new();
        my $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );

        is( $extractor->get_control_number, q{}, 'Returns an empty string if no 001' );

        $record->append_fields( MARC::Field->new( '001', q{} ) );
        is( $extractor->get_control_number, q{}, 'Returns an empty string if 001 empty' );

        $record->field('001')->replace_with( MARC::Field->new( '001', undef ) );
        is( $extractor->get_control_number, q{}, 'Returns an empty string if 001 was built with undef' );

        $record->field('001')->replace_with( MARC::Field->new( '001', $identifier ) );
        is( $extractor->get_control_number, $identifier, 'Returns the right value' );
    }
};

subtest 'get_opac_suppression() tests' => sub {

    plan tests => 8;

    foreach my $marcflavour (qw( MARC21 UNIMARC )) {
        t::lib::Mocks::mock_preference( 'marcflavour', $marcflavour );

        my $record    = MARC::Record->new();
        my $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );

        is( $extractor->get_opac_suppression(), 0, 'If 942$n absent, then not suppressed' );

        $record->append_fields( MARC::Field->new( '942', q{}, q{}, n => '' ) );
        is( $extractor->get_opac_suppression(), 0, 'If 942$n has empty string, then not suppressed' );

        $record->field('942')->replace_with( MARC::Field->new( '942', q{}, q{}, n => 'potato' ) );
        is( $extractor->get_opac_suppression(), 1, 'If 942$n has something different than false, then suppressed' );

        $record->field('942')->replace_with( MARC::Field->new( '942', q{}, q{}, n => '1' ) );
        is( $extractor->get_opac_suppression(), 1, 'If 942$n is 1, then suppressed' );
    }
};
