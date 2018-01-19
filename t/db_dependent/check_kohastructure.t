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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 1;
use File::Slurp;
use C4::Context;
my $content = read_file( C4::Context->config("intranetdir")
      . '/installer/data/mysql/kohastructure.sql' );
my @drop_stmt_missing;
my $ccc = $content;
while ( $content =~ m|CREATE TABLE `?([^`\n ]*)`?\s?\(\s*\n|g ) {
    my $match = $1;
    next if $match =~ m|^IF NOT EXISTS |;
    push @drop_stmt_missing, $match unless $ccc =~ m|DROP TABLE [^\n]*$match|;
}
is(
    @drop_stmt_missing,
    0,
    'DROP TABLE statements should exist for all tables'
      . (
        @drop_stmt_missing
        ? ' but missing for ' . join( ',', @drop_stmt_missing )
        : ''
      )
);
