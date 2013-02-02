#!/usr/bin/perl

# Copyright (C) 2013 Horowhenua Library Trust
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use warnings;
use strict;
use Test::More tests => 1;
use File::Find;

my @files;
find(
    sub {
        open my $fh, $_ or die "Could not open $_: $!";
        my @lines = sort grep /\_\(\'/, <$fh>;
        push @files, { name => "$_", lines => \@lines } if @lines;
    },
    ( "./koha-tmpl/opac-tmpl/prog/en", "./koha-tmpl/intranet-tmpl/prog/en" )
);

ok( !@files, "Files do not contain single quotes _(' " )
  or diag(
    "Files list: \n",
    join( "\n",
        map { $_->{name} . ': ' . join( ', ', @{ $_->{lines} } ) } @files )
  );

