#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2013 Horowhenua Library Trust
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
use File::Slurp qw( read_file );

my @files;

# OPAC
push @files, `git ls-files 'koha-tmpl/opac-tmpl/bootstrap/en/*.tt'`;
push @files, `git ls-files 'koha-tmpl/opac-tmpl/bootstrap/en/*.inc'`;

# Staff
push @files, `git ls-files 'koha-tmpl/intranet-tmpl/prog/en/*.tt'`;
push @files, `git ls-files 'koha-tmpl/intranet-tmpl/prog/en/*.inc'`;

my @errors;
for my $file ( @files ) {
    chomp $file;
    my @lines = sort grep /\_\(\'/, read_file($file);
    push @errors, { name => $file, lines => \@lines } if @lines;
}

ok( !@errors, "Files do not contain single quotes _(' " )
  or diag(
    "Files list: \n",
    join( "\n",
        map { $_->{name} . ': ' . join( ', ', @{ $_->{lines} } ) } @errors )
  );
