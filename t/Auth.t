# This file is part of Koha.
#
# Copyright (C) 2017 Nicholas van Oudtshoorn
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
use Test::NoWarnings;
use Test::More tests => 13;
use Test::Warn;

use C4::Auth qw( in_iprange );

$ENV{REMOTE_ADDR} = '192.168.1.30';

ok( in_iprange("192.168.1.30"),              'simple single ip matching remote ip' );
ok( !in_iprange("192.168.1.31"),             'simple single ip not match remote ip' );
ok( in_iprange("192.168.1.1/24"),            'simple ip range/24 with remote ip in it' );
ok( !in_iprange("192.168.2.1/24"),           'simple ip range/24 with remote ip not in it' );
ok( in_iprange("192.168.2.1/16"),            'simple ip range/16 with remote ip in it' );
ok( !in_iprange("192.168.1.10-30"),          'invalidly represented IP range with remote ip in it' );
ok( in_iprange("192.168.1.10-192.168.1.30"), 'validly represented ip range with remote ip in it' );
ok(
    in_iprange("127.0.0.1 192.168.1.30 192.168.2.10-192.168.2.25"),
    'multiple ips and ranges, including the remote ip'
);
ok(
    !in_iprange("127.0.0.1 8.8.8.8 192.168.2.1/24 192.168.3.1/24 192.168.1.1-192.168.1.29"),
    "multiple ip and ip ranges, with the remote ip in none of them"
);
ok( in_iprange(""),               "blank list given, no preference set - implies everything goes through." );
ok( in_iprange(),                 "no list given, no preference set - implies everything goes through." );
ok( in_iprange("192.168.1.1/36"), 'simple invalid ip range/36 with remote ip in it' );
