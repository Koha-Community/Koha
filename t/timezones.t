use Modern::Perl;

use C4::Context;
use Koha::Config;

use Test::NoWarnings;
use Test::More tests => 6;
use Test::Warn;
use t::lib::Mocks;

$ENV{TZ} = q{};
t::lib::Mocks::mock_config( 'timezone', q{} );
my $config = Koha::Config->get_instance;
is(
    $config->timezone, 'local',
    'Got local timezone with no env or config timezone set'
);

$ENV{TZ} = 'Antarctica/Macquarie';
is(
    $config->timezone,
    'Antarctica/Macquarie',
    'Got correct timezone using ENV, overrides local time'
);

t::lib::Mocks::mock_config( 'timezone', 'Antarctica/South_Pole' );
is(
    $config->timezone,
    'Antarctica/South_Pole',
    'Got correct timezone using config, overrides env'
);

t::lib::Mocks::mock_config( 'timezone', 'Your/Timezone' );
warning_is {
    is( $config->timezone, 'local', 'Invalid timezone falls back to local' );
}
'Invalid timezone in koha-conf.xml (Your/Timezone)',
    'Invalid timezone raises a warning';
