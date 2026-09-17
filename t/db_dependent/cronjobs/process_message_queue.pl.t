#!/usr/bin/perl
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

use FindBin qw($Bin);
use Test::More tests => 3;
use Test::NoWarnings;

# Regression tests for bug 40934: the --code/--exclude-code mutual-exclusivity
# check must only fire when both options are given an actual value, not when
# one is passed bare (GetOptions' optional-value ':s' type leaves an empty
# string in the array in that case).

my $script = "$Bin/../../../misc/cronjobs/process_message_queue.pl";

# --where "1=0" keeps this a safe no-op: no message ever matches, so nothing
# is ever sent even though the script runs for real against the test database.
my $safe_run = "$^X $script --where '1=0'";

my $output = `$safe_run --code FOO --exclude-code BAR 2>&1`;
like(
    $output, qr/mutually exclusive/i,
    '--code and --exclude-code together are still rejected as mutually exclusive'
);

$output = `$safe_run -c --exclude-code DUEDGST 2>&1`;
unlike(
    $output, qr/mutually exclusive/i,
    'bare -c with --exclude-code is not falsely rejected as mutually exclusive (bug 40934)'
);
