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

use Test::More tests => 3;

BEGIN { use_ok('Koha::Cron') }

use C4::Context;

my $userenv = C4::Context->userenv;
is_deeply(
    $userenv,
    {
        'surname'       => 'CRON',
        'id'            => undef,
        'flags'         => undef,
        'cardnumber'    => undef,
        'firstname'     => 'CRON',
        'branchname'    => undef,
        'branchprinter' => undef,
        'emailaddress'  => undef,
        'number'        => undef,
        'shibboleth'    => undef,
        'branch'        => undef
    },
    "Context userenv set correctly"
);

my $interface = C4::Context->interface;
is($interface, 'cron', "Context interface set correctly");

1;
