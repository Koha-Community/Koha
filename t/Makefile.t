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
use Test::More tests => 3;
use File::Slurp;

my @files = `git ls-tree HEAD|tr -s '\t' ' '|cut -d' ' -f4`;
ok( @files > 0, 'We should test something' );

my $MakeFile = read_file('Makefile.PL');
my @MakeFile = split "\n", $MakeFile;

my @ignored = qw(
    .editorconfig
    .gitignore
    .mailmap
    .perlcriticrc
    .proverc
    .proverc.dist
    .stylelintrc.json
    LICENSE
    README.md
    SECURITY.md
    README.robots
    debian
    install-CPAN.pl
    koha_perl_deps.pl
);

my @not_mapped;
for my $file (@files) {
    chomp $file;
    unless ( grep { /$file/ } @MakeFile or grep { /$file/ } @ignored ) {
        push @not_mapped, $file;
    }
}

is( @not_mapped, 0, 'All directories should be mapped' . ( @not_mapped ? ': ' . join ',', @not_mapped : '' ) );
