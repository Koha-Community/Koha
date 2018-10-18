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
use C4::Context;

my $dbh = C4::Context->dbh;
my $sql_mode = $dbh->selectrow_array(q|SELECT @@SQL_MODE|);
like( $sql_mode, qr{STRICT_TRANS_TABLES}, 'Strict SQL modes must be turned on for tests' );
