use Modern::Perl;
use Test::More tests => 5;

use t::lib::Mocks;

use C4::Circulation;

t::lib::Mocks::mock_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

is ( C4::Circulation::GetAgeRestriction('FSK 16'), '16', 'FSK 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('PEGI 16'), '16', 'PEGI 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('PEGI16'), '16', 'PEGI16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('Age 16'), '16', 'Age 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('K16'), '16', 'K16 returns 16' );

