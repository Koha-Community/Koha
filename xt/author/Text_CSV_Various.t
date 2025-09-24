#!/usr/bin/perl

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

#This test demonstrates why Koha uses the CSV parser and configuration
#it does.  Specifically, the test is for Unicode compliance in text
#parsing and data.  This test requires other modules that Koha doesn't
#actually use, in order to compare.  Therefore, running this test is not
#necessary to test your Koha installation.

use Modern::Perl;
use open OUT => ':encoding(UTF-8)', ':std';
use utf8;

use Test::More tests => 23;
use Test::NoWarnings;
use Text::CSV;
use Text::CSV_XS;
use File::Find;

sub pretty_line {
    my $max = 54;
    (@_) or return "#" x $max . "\n";
    my $phrase = "  " . shift() . "  ";
    my $half   = "#" x ( ( $max - length($phrase) ) / 2 );
    return $half . $phrase . $half . "\n";
}

my ( $csv, $bin, %parsers );

foreach (qw( Text::CSV Text::CSV_XS )) {
    ok( $csv = $_->new(),                  $_ . '->new()' );
    ok( $bin = $_->new( { binary => 1 } ), $_ . '->new({binary=>1})' );
    $csv and $parsers{$_} = $csv;
    $bin and $parsers{ $_ . " (binary)" } = $bin;
}

my $lines = [
    {
        description => "010D: LATIN SMALL LETTER C WITH CARON", character => 'č',
        line        => 'field1,second field,field3,do_we_have_a_č_problem?, f!fth field ,lastfield'
    },
    {
        description => "0117: LATIN SMALL LETTER E WITH DOT ABOVE", character => 'ė',
        line        => 'field1,second field,field3,do_we_have_a_ė_problem?, f!fth field ,lastfield'
    },
];

ok(
    scalar( keys %parsers ) > 0 && scalar(@$lines) > 0,
    sprintf "Testing %d lines with  %d parsers.",
    scalar(@$lines), scalar( keys %parsers )
);

foreach my $key ( sort keys %parsers ) {
    my $parser = $parsers{$key};
    print "Testing parser $key version " . ( $parser->version || '?' ) . "\n";
}

my $i = 0;
foreach my $line (@$lines) {
    print pretty_line( "Line " . ++$i );
    print pretty_line( $line->{description} . ': ' . $line->{character} );
    foreach my $key ( sort keys %parsers ) {
        my $parser = $parsers{$key};
        my ( $status, $count, @fields );
        $status = $parser->parse( $line->{line} );
        if ($status) {
            ok( $status, "parse ($key)" );
            @fields = $parser->fields;
            $count  = scalar(@fields);
            is( $count, 6, "Number of fields ($count of 6)" );
            my $j = 0;
            foreach my $f (@fields) {
                $j++;
                print "\t field $j: $f\n";
            }
        } else {
            ok( !$status, "parse ($key) fails as expected" );    #FIXME We never hit this line
        }
    }
}

# Test for CSV formula injection protection
subtest 'CSV formula injection protection' => sub {
    my @csv_files;
    my @violations;

    # Find all Perl files that might use Text::CSV
    find(
        sub {
            return unless -f $_ && /\.pm$/;
            my $file = $File::Find::name;

            # Skip test files and this test file itself
            return if $file =~ m{/t/} || $file =~ m{/xt/};

            open my $fh, '<', $_ or return;
            my $content = do { local $/; <$fh> };
            close $fh;

            # Look for actual Text::CSV usage (not just dependency declarations)
            my @csv_usages = $content =~ /(?:use\s+Text::CSV|Text::CSV(?:_XS|::Encoded)?(?:\s*->|\s*\.\s*)new)/g;
            return unless @csv_usages;

            # Skip if it's just dependency metadata (like in PerlModules.pm)
            return if $content =~ /'Text::CSV[^']*'\s*=>\s*{[^}]*(?:required|min_ver|cur_ver)/;

            push @csv_files, $file;

            # Find all Text::CSV->new() calls and check each one
            my @new_calls       = $content =~ /(Text::CSV(?:_XS|::Encoded)?(?:\s*->|\s*\.\s*)new\s*\([^)]*\))/g;
            my $has_unprotected = 0;

            for my $call (@new_calls) {

                # Check if this specific call has formula protection
                unless ( $call =~ /formula\s*=>\s*['"](?:empty|die|croak|diag)['"]/
                    || $call =~ /formula\s*=>\s*[1-5]/ )
                {
                    $has_unprotected = 1;
                    last;
                }
            }

            if ($has_unprotected) {
                push @violations, $file;
            }
        },
        'C4', 'Koha',
        'misc'
    );

    ok( scalar(@csv_files) > 0, "Found CSV usage in Koha modules" );

    if (@violations) {
        diag("Files using Text::CSV without formula protection:");
        diag("  $_") for @violations;
        diag("");
        diag("CSV formula injection protection is required for security.");
        diag("Add 'formula => \"empty\"' to Text::CSV constructor options.");
        diag("Valid formula modes: 'empty' (recommended), 'die', 'croak', 'diag', or numeric 1-5");
    }

    is( scalar(@violations), 0, "All Text::CSV usage includes formula injection protection" );
};
