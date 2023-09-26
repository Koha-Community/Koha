#!/usr/bin/perl

# Copyright 2020 Koha Development Team
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
use Test::More;
plan tests => 1;

use File::Spec;
use File::Slurp qw( read_file );
use Data::Dumper;

my $curdir = File::Spec->curdir();
my @dirs = `git ls-tree -d --name-only HEAD`;
my $makefile = read_file("$curdir/Makefile.PL");
my @missing;
for my $d ( sort @dirs ) {
    chomp $d;
    next if $d =~ /^debian$/;
    next if $makefile =~ m{'\./$d('|\/)}xms;
    push @missing, $d;
}

is( scalar @missing, 0, 'All directories must be listed in Makefile.PL' ) or diag Dumper \@missing;
