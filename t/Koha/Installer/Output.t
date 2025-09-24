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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 9;

use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

# Set up a temporary file for testing output
my $temp_file = "test_output.log";
open my $fh, '>', $temp_file or die "Cannot open $temp_file: $!";

# Redirect output to the temporary file
my $old_fh = select $fh;

# Test the output functions
say_warning( $fh, "Testing warning message" );
say_failure( $fh, "Testing failure message" );
say_success( $fh, "Testing success message" );
say_info( $fh, "Testing info message" );

# Restore the previous output filehandle
select $old_fh;

# Close the temporary file
close $fh;

# Read the contents of the temporary file for testing
open my $test_fh, '<', $temp_file or die "Cannot open $temp_file: $!";
my @lines = <$test_fh>;
close $test_fh;

# Test the output content
like( $lines[0], qr/\e\[\d+mTesting warning message\e\[0m/, "Warning message output with ANSI color code" );
like( $lines[1], qr/\e\[\d+mTesting failure message\e\[0m/, "Failure message output with ANSI color code" );
like( $lines[2], qr/\e\[\d+mTesting success message\e\[0m/, "Success message output with ANSI color code" );
like( $lines[3], qr/\e\[\d+mTesting info message\e\[0m/,    "Info message output with ANSI color code" );

# Remove the temporary file
unlink $temp_file;

# Next, test with no filehandler (letting say send to STDOUT by default)

# Redirect STDOUT to a variable - we don't actually want to print to the console for testing
my $temp_out;
open my $oldout, qw{>&}, "STDOUT";
close STDOUT;
open STDOUT, '>:encoding(utf8)', \$temp_out;

say_warning( undef, "Testing warning message with no fh" );
say_failure( undef, "Testing failure message with no fh" );
say_success( undef, "Testing success message with no fh" );
say_info( undef, "Testing info message with no fh" );

# Return STDOUT to previous state
close STDOUT;
open STDOUT, ">&", $oldout;

# Split the contents of $temp_out into an array for testing
my @nofh_lines = split( "\n", $temp_out );

# Test the output content
like(
    $nofh_lines[0], qr/\e\[\d+mTesting warning message with no fh\e\[0m/,
    "Warning message with no fh output with ANSI color code"
);
like(
    $nofh_lines[1], qr/\e\[\d+mTesting failure message with no fh\e\[0m/,
    "Failure message with no fh output with ANSI color code"
);
like(
    $nofh_lines[2], qr/\e\[\d+mTesting success message with no fh\e\[0m/,
    "Success message with no fh output with ANSI color code"
);
like(
    $nofh_lines[3], qr/\e\[\d+mTesting info message with no fh\e\[0m/,
    "Info message with no fh output with ANSI color code"
);
