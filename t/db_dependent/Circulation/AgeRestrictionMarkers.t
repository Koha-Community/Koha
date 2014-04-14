use Modern::Perl;
use Test::More tests => 4;

use C4::Context;
use C4::Circulation;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

C4::Context->set_preference( 'AgeRestrictionMarker', 'FSK|PEGI|Age|K' );

is ( C4::Circulation::GetAgeRestriction('FSK 16'), '16', 'FSK 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('PEGI 16'), '16', 'PEGI 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('Age 16'), '16', 'Age 16 returns 16' );
is ( C4::Circulation::GetAgeRestriction('K16'), '16', 'K16 returns 16' );

