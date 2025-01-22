#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2015 Koha Development Team
# Copyright (C) 2015  Mark Tompsett (Time Zone Shifts)
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

use DateTime;
use Koha::DateUtils qw( dt_from_string );
use Test::NoWarnings;
use Test::More tests => 7;
use Test::Warn;

use t::lib::Mocks;

use C4::Circulation qw( GetAgeRestriction );

t::lib::Mocks::mock_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

is( C4::Circulation::GetAgeRestriction('FSK 16'),  '16', 'FSK 16 returns 16' );
is( C4::Circulation::GetAgeRestriction('PEGI 16'), '16', 'PEGI 16 returns 16' );
is( C4::Circulation::GetAgeRestriction('PEGI16'),  '16', 'PEGI16 returns 16' );
is( C4::Circulation::GetAgeRestriction('Age 16'),  '16', 'Age 16 returns 16' );
is( C4::Circulation::GetAgeRestriction('K16'),     '16', 'K16 returns 16' );

subtest 'No age restriction' => sub {
    plan tests => 1;

    warning_is {
        C4::Circulation::GetAgeRestriction();
    }
    undef, "No warning if GetAgeRestriction is called without restriction";

};

