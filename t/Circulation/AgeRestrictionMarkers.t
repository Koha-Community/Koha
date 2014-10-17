#!/usr/bin/perl

use Modern::Perl;
use DateTime;
use Test::More tests => 10;

use t::lib::Mocks;

use C4::Circulation;

t::lib::Mocks::mock_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

is ( C4::Circulation::GetAgeRestriction('FSK 16'), '16', 'FSK 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('PEGI 16'), '16', 'PEGI 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('PEGI16'), '16', 'PEGI16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('Age 16'), '16', 'Age 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('K16'), '16', 'K16 returns 16' );


##Testing age restriction for a borrower.
my $now = DateTime->now();
my $borrower = {};
C4::Members::SetAge( $borrower, '0015-00-00' );

my ($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('FSK 16', $borrower);
is ( ($daysToAgeRestriction > 0), 1, 'FSK 16 blocked for a 15 year old' );
($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('PEGI 15', $borrower);
is ( ($daysToAgeRestriction <= 0), 1, 'PEGI 15 allowed for a 15 year old' );
($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('PEGI14', $borrower);
is ( ($daysToAgeRestriction <= 0), 1, 'PEGI14 allowed for a 15 year old' );
($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('Age 10', $borrower);
is ( ($daysToAgeRestriction <= 0), 1, 'Age 10 allowed for a 15 year old' );
($restriction_age, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction('K18', $borrower);
is ( ($daysToAgeRestriction > 0), 1, 'K18 blocked for a 15 year old' );