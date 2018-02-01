use Modern::Perl;

use C4::Context;

use Test::More tests => 3;
use t::lib::Mocks;

$ENV{TZ} = q{};
t::lib::Mocks::mock_config( 'timezone', q{} );
is( C4::Context->timezone, 'local',
    'Got local timezone with no env or config timezone set' );

$ENV{TZ} = 'Antarctica/Macquarie';
is(
    C4::Context->timezone,
    'Antarctica/Macquarie',
    'Got correct timezone using ENV, overrides local time'
);

t::lib::Mocks::mock_config( 'timezone', 'Antarctica/South_Pole' );
is(
    C4::Context->timezone,
    'Antarctica/South_Pole',
    'Got correct timezone using config, overrides env'
);
