#!/usr/bin/perl

# Script to find files that probably should not be executed.
#
# Copyright 2010 Catalyst IT Ltd
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
use File::Find;
use Data::Dumper;
use Test::More tests => 1;

my @files;

sub wanted {
    my $name = $File::Find::name;

    # Ignore files in .git, blib and node_modules
    return if $name =~ m[^\./(.git|blib|node_modules)];

    # Ignore directories
    return if -d $name;    # Skip dir

    # Search for missing x in svc, xt and t
    if (   $name =~ m[^\./(svc|xt)] && $name !~ m[\./xt/(perltidyrc|fix-old-fsf-address\.exclude)]
        || $name =~ m[^\./t/.*\.t$] )
    {
        push @files, $name unless -x $name;
    }

    # Search for missing x for .pl and .sh
    if ( $name =~ m[\.(pl|sh)$] ) {
        push @files, $name unless -x $name;
    }

    # Search for extra x flag for .pm
    if ( $name =~ m[\.pm$] ) {
        push @files, $name if -x $name;
    }
}
find( { wanted => \&wanted, no_chdir => 1 }, '.' );
is( @files, 0 ) or diag( Dumper @files );
