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
use Test::More tests => 2;
use Test::NoWarnings;

use Array::Utils qw( array_minus );

my @t_files = qx{git grep --files-without-match "Test::NoWarnings" 't/*.t' 'xt/*.t'};
chomp for @t_files;

my @exceptions = (

    # Cannot be removed
    "t/00-testcritic.t",

    # bug 40382
    "t/db_dependent/Koha/CoverImages.t",

    # bug 40442
    "t/db_dependent/Koha/MarcOrder.t",

    # bug 40375
    "t/db_dependent/XISBN.t",

    # bug 40443
    "t/db_dependent/cronjobs/advance_notices_digest.t",

    # Cannot be removed
    "xt/author/podcorrectness.t",

    # bug 40449
    "xt/author/valid-templates.t",
);

@t_files = array_minus( @t_files, @exceptions );
is( scalar(@t_files), 0, "All Perl test files should contain Test::NoWarnings" )
    or diag( sprintf "The following test files should use Test::NoWarnings:\n\t%s", join "\n\t", @t_files );
