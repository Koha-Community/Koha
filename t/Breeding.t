#!/usr/bin/perl
#
# Copyright 2025 Rijksmuseum, Koha Development Team
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
use Data::Dumper qw(Dumper);
use MARC::Field;
use MARC::Record;
use Test::More tests => 3;
use Test::NoWarnings;

use t::lib::Mocks;

use C4::Breeding;

subtest '_extract_positions' => sub {
    plan tests => 5;
    my ( $data, $spec );

    $data = '0123456789';
    is( C4::Breeding::_extract_positions( $data, $spec ), $data, 'Output without spec' );
    $spec = 'p2';
    is( C4::Breeding::_extract_positions( $data, $spec ), '[2]2', 'Output for specific position' );
    $spec = 'p3-5';
    is( C4::Breeding::_extract_positions( $data, $spec ), '[3-5]345', 'Output for range' );
    $spec = 'p5-3';
    is( scalar C4::Breeding::_extract_positions( $data, $spec ), undef, 'Bad range' );
    $spec = 'p20-21';
    is( scalar C4::Breeding::_extract_positions( $data, $spec ), undef, 'Position outside string' );
};

subtest '_add_custom_field_rowdata' => sub {
    plan tests => 6;
    my ( $row, $pref );

    my $record = MARC::Record->new;
    $record->leader('0123456789');
    $record->append_fields(
        MARC::Field->new( '008', 'ABCD' ),
        MARC::Field->new( '100', '', '', a => 'Author', b => '100b' ),
        MARC::Field->new( '245', '', '', a => '245a',   b => '245b1', b => '245b2', c => '245c' ),
    );

    $row = {};
    C4::Breeding::_add_custom_field_rowdata( $row, $record, $pref );
    is( @{ $row->{addnumberfields} }, 0, 'No additional fields when pref is undef' );

    $row  = {};
    $pref = '000p7-9, 008, 100, 100$a, 245$bc, 300$d';    # 100$a should be ignored (double entry)
    C4::Breeding::_add_custom_field_rowdata( $row, $record, $pref );
    is( @{ $row->{addnumberfields} }, 4, '4 fields expected' );
    is_deeply( $row->{'000'}, ['[7-9]789'],                          'Check leader' );
    is_deeply( $row->{'008'}, ['ABCD'],                              'Check full 008' );
    is_deeply( $row->{'100'}, [ '[a]Author', '[b]100b' ],            'Results for first 100 in pref' );
    is_deeply( $row->{'245'}, [ '[b]245b1', '[b]245b2', '[c]245c' ], 'Results for 245$bc' );
};
