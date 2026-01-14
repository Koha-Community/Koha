#!/usr/bin/perl

# Copyright 2026 Theke Solutions
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

use Modern::Perl;

use Test::More tests => 8;
use Test::Warn;
use Test::NoWarnings;

use t::lib::Mocks;

use C4::Context;

BEGIN {
    use_ok('Koha::CSV');
}

subtest 'new() tests' => sub {
    plan tests => 5;

    my $csv = Koha::CSV->new();
    isa_ok( $csv, 'Koha::CSV', 'Object created' );
    is( $csv->binary,       1,       'binary defaults to 1' );
    is( $csv->formula,      'empty', 'formula defaults to empty' );
    is( $csv->always_quote, 0,       'always_quote defaults to 0' );
    is( $csv->eol,          "\n",    'eol defaults to newline' );
};

subtest 'new() with CSVDelimiter preference tests' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'CSVDelimiter', ',' );
    my $csv = Koha::CSV->new();
    is( $csv->sep_char, ',', 'Uses comma from preference' );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', ';' );
    $csv = Koha::CSV->new();
    is( $csv->sep_char, ';', 'Uses semicolon from preference' );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', 'tabulation' );
    $csv = Koha::CSV->new();
    is( $csv->sep_char, "\t", 'Converts tabulation to tab character' );
};

subtest 'new() with overrides tests' => sub {
    plan tests => 3;

    my $csv = Koha::CSV->new(
        {
            sep_char     => '|',
            always_quote => 1,
            eol          => "\r\n",
        }
    );

    is( $csv->sep_char,     '|',    'sep_char overridden' );
    is( $csv->always_quote, 1,      'always_quote overridden' );
    is( $csv->eol,          "\r\n", 'eol overridden' );
};

subtest 'add_row() tests' => sub {
    plan tests => 4;

    t::lib::Mocks::mock_preference( 'CSVDelimiter', ',' );
    my $csv = Koha::CSV->new();

    # Test with array
    my $line = $csv->add_row( 'Title', 'Author', 'Year' );
    is( $line, "Title,Author,Year\n", 'add_row with array' );

    # Test with arrayref
    $line = $csv->add_row( [ 'Book 1', 'Smith, John', '2024' ] );
    is( $line, "\"Book 1\",\"Smith, John\",2024\n", 'add_row with arrayref and quoted field' );

    # Test with special characters
    $line = $csv->add_row( [ 'Title with "quotes"', 'Normal', 'Value' ] );
    is( $line, "\"Title with \"\"quotes\"\"\",Normal,Value\n", 'add_row with quotes escaped' );

    # Test with empty fields
    $line = $csv->add_row( [ 'Field1', '', 'Field3' ] );
    is( $line, "Field1,,Field3\n", 'add_row with empty field' );
};

subtest 'combine() and string() tests' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'CSVDelimiter', ',' );
    my $csv = Koha::CSV->new();

    my $status = $csv->combine( 'A', 'B', 'C' );
    ok( $status, 'combine returns true on success' );

    my $line = $csv->string();
    is( $line, "A,B,C\n", 'string returns combined line' );

    # Test with always_quote
    $csv = Koha::CSV->new( { always_quote => 1 } );
    $csv->combine( 'A', 'B', 'C' );
    $line = $csv->string();
    is( $line, "\"A\",\"B\",\"C\"\n", 'always_quote wraps all fields' );
};

subtest 'print() tests' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'CSVDelimiter', ',' );
    my $csv = Koha::CSV->new();

    # Create temp file
    my $output = '';
    open my $fh, '>', \$output or die "Cannot open string as file: $!";

    my $status = $csv->print( $fh, [ 'Header1', 'Header2', 'Header3' ] );
    ok( $status, 'print returns true on success' );

    $csv->print( $fh, [ 'Value1', 'Value2', 'Value3' ] );
    close $fh;

    is(
        $output,
        "Header1,Header2,Header3\nValue1,Value2,Value3\n",
        'print writes correct CSV to filehandle'
    );
};
