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
use Test::More tests => 7;

use t::lib::Mocks;

use C4::Circulation;

t::lib::Mocks::mock_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

is ( C4::Circulation::GetAgeRestriction('FSK 16'), '16', 'FSK 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('PEGI 16'), '16', 'PEGI 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('PEGI16'), '16', 'PEGI16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('Age 16'), '16', 'Age 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('K16'), '16', 'K16 returns 16' );

subtest 'Patron tests - 15 years old' => sub {
    plan tests => 5;
    ##Testing age restriction for a borrower.
    my $now = DateTime->now();
    my $borrower = {};
    C4::Members::SetAge( $borrower, '0015-00-00' );
    TestPatron($borrower,0);
};

subtest 'Patron tests - 15 years old (Time Zone shifts)' => sub {
    my $CheckTimeFake = eval { require Time::Fake; 1; } || 0;
    SKIP: {
        skip "Install Time::Fake to regression test for Bug 14362.", 115 if $CheckTimeFake!=1;
        # 115 regression tests = 5 tests (see TestPatron) for 23 timezones.
        plan tests => 115;
        my $offset = 1;
        # <24 hours in a day.
        while ($offset<24) {
            Time::Fake->offset("+${offset}h");

            ##Testing age restriction for a borrower.
            my $now = DateTime->now();
            my $borrower = {};
            C4::Members::SetAge( $borrower, '0015-00-00' );
            TestPatron($borrower,$offset);

            $offset++;
        }
    }
};

# The Patron tests
sub TestPatron {
    my ($borrower,$offset) = @_;

    my ($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('FSK 16', $borrower);
    is ( ($daysToAgeRestriction > 0), 1, "FSK 16 blocked for a 15 year old - $offset hours" );
    ($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('PEGI 15', $borrower);
    is ( ($daysToAgeRestriction <= 0), 1, "PEGI 15 allowed for a 15 year old - $offset hours" );
    ($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('PEGI14', $borrower);
    is ( ($daysToAgeRestriction <= 0), 1, "PEGI14 allowed for a 15 year old - $offset hours" );
    ($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('Age 10', $borrower);
    is ( ($daysToAgeRestriction <= 0), 1, "Age 10 allowed for a 15 year old - $offset hours" );
    ($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('K18', $borrower);
    is ( ($daysToAgeRestriction > 0), 1, "K18 blocked for a 15 year old - $offset hours" );
    return;
}
