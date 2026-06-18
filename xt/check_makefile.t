#!/usr/bin/perl

# Copyright 2026 Koha Development Team
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
use Test::More tests => 3;
use Test::NoWarnings;

use File::Spec;
use File::Slurp qw( read_file );
use Data::Dumper;

subtest 'All files should be mapped in Makefile.pl' => sub {
    plan tests => 2;
    my @files = `git ls-tree --name-only HEAD`;
    ok( @files > 0, 'We should test something' );
    my @MakeFile = read_file('Makefile.PL');
    my @ignored  = qw(
        .editorconfig
        .gitignore
        .mailmap
        .nvmrc
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
        unless ( grep { /$file/ } @MakeFile or grep { $_ eq $file } @ignored ) {
            push @not_mapped, $file;
        }
    }

    is( @not_mapped, 0, 'All directories should be mapped' . ( @not_mapped ? ': ' . join ',', @not_mapped : '' ) );

};

subtest 'All CSS files should be mapped' => sub {
    plan tests => 2;

    my @css_files =
        `git ls-tree --name-only HEAD koha-tmpl/intranet-tmpl/prog/css/src/ koha-tmpl/opac-tmpl/bootstrap/css/src/`;
    ok( @css_files > 0, 'We should test something' );
    my @MakeFile = read_file('Makefile.PL');

    my @not_mapped;
    for my $file (@css_files) {
        chomp $file;
        next if $file =~ m{/_[^/]*};
        my $css = $file;
        $css =~ s#/css/src/(.*).scss$#/css/$1.css#;
        unless ( grep { /$css/ } @MakeFile ) {
            push @not_mapped, $css;
        }
    }

    is( @not_mapped, 0, 'All directories should be mapped' . ( @not_mapped ? ': ' . join ',', @not_mapped : '' ) );
};
