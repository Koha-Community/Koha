#!/usr/bin/perl

# Copyright 2025 Koha Development Team
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

use Test::More;
use File::Find;
use File::Slurp;
use Test::NoWarnings;
use Koha::Devel::Files;

# Test for Bug 40292: Prevent SQL syntax error when upgrading to 25.05 on MariaDB 10.3
# This test ensures that database revision files don't use SQL syntax that is incompatible
# with older MariaDB versions (specifically MariaDB 10.3)

my $dev_files   = Koha::Devel::Files->new;
my @dbrev_files = $dev_files->ls_dbrev_files;

plan tests => scalar @dbrev_files + 1;

foreach my $file (@dbrev_files) {
    my $content = read_file($file);

    # Check for incompatible RENAME COLUMN syntax
    # MariaDB 10.3 doesn't support "RENAME COLUMN old_name TO new_name"
    # but does support "CHANGE COLUMN old_name new_name datatype"
    my $has_incompatible_syntax = 0;
    my @problem_lines;

    my @lines = split /\n/, $content;
    for my $line_num ( 0 .. $#lines ) {
        my $line = $lines[$line_num];

        # Look for RENAME COLUMN syntax (case insensitive)
        # This regex matches: RENAME COLUMN old_name TO new_name
        if ( $line =~ /\bRENAME\s+COLUMN\s+\w+\s+TO\s+\w+/i ) {
            $has_incompatible_syntax = 1;
            push @problem_lines, sprintf( "Line %d: %s", $line_num + 1, $line );
        }
    }

    if ($has_incompatible_syntax) {
        fail("$file contains incompatible RENAME COLUMN syntax");
        diag("Found incompatible SQL syntax in $file:");
        diag($_) for @problem_lines;
        diag("Use 'CHANGE COLUMN old_name new_name datatype' instead of 'RENAME COLUMN old_name TO new_name'");
        diag("This syntax is required for MariaDB 10.3 compatibility (Bug 40292)");
    } else {
        pass("$file uses compatible SQL syntax");
    }
}
