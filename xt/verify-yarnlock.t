#!/usr/bin/perl

# Copyright (C) 2024 KohaAloha Ltd.
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

# This file tests that Koha's yarn.lock file is updated with the
# packages.json file. If this test fails, the likely solution is to run
# 'yarn install' to generate an updated yarn.lock file, then
# 'git commit ./yarn.lock'.

use Modern::Perl;
use Test::More tests => 2;
use Test::NoWarnings;

my $rc;

# if KTD dirs exists?
if ( -d "/usr/local/share/.cache/yarn" and -d "/kohadevbox/node_modules" ) {

    # we use KTD's existing .cache/yarn and node_modules dirs
    $rc = system("yarn check  --modules-folder /kohadevbox/node_modules  --cache-dir /usr/local/share/.cache/yarn");

} else {

    # else, we just use yarn's currently set dirs
    $rc = system("yarn check");

}

# yarn returns a 256 value for this specific lockfile error,
#  but we assume any non-zero value is bad
is( $rc, 0, "verify yarn.lock file is updated correctly" );
