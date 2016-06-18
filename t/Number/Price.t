use Modern::Perl;

use Test::More tests => 28;

use Test::MockModule;
use t::lib::Mocks;

use Koha::Acquisition::Currencies;
my $budget_module = Test::MockModule->new('Koha::Acquisition::Currencies');
my $currency;
$budget_module->mock( 'get_active', sub { return $currency; } );
use_ok('Koha::Number::Price');

my $format = {
    p_cs_precedes => 1, # Force to place the symbol at the beginning
    p_sep_by_space => 0, # Force to not add a space between the symbol and the number
};
t::lib::Mocks::mock_preference( 'CurrencyFormat', 'US' );
$currency = Koha::Acquisition::Currency->new({
    currency => 'USD',
    symbol   => '$',
    rate     => 1,
    active   => 1,
});

is( Koha::Number::Price->new->format( $format ),    '0.00', 'US: format 0' );
is( Koha::Number::Price->new(3)->format( $format ), '3.00', 'US: format 3' );
is( Koha::Number::Price->new(1234567890)->format( $format ),
    '1,234,567,890.00', 'US: format 1234567890' );

# FIXME This should be display symbol, but it was the case before the creation of this module
is( Koha::Number::Price->new->format( { %$format, with_symbol => 1 } ),
    '0.00', 'US: format 0 with symbol' );
is( Koha::Number::Price->new(3)->format( { %$format, with_symbol => 1 } ),
    '3.00', 'US: format 3 with symbol' );
is(
    Koha::Number::Price->new(1234567890)
      ->format( { %$format, with_symbol => 1 }, 'US: format 1234567890 with symbol' ),
    '1,234,567,890.00'
);

is( Koha::Number::Price->new->unformat,    '0', 'US: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'US: unformat 3' );
is( Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'US: unformat 1234567890' );

t::lib::Mocks::mock_preference( 'CurrencyFormat', 'FR' );
$currency = Koha::Acquisition::Currency->new({
    currency => 'EUR',
    symbol   => '€',
    rate     => 1,
    active   => 1,
});

# Actually,the price formating for France is 3,00€
# How put the symbol at the end with Number::Format?
is( Koha::Number::Price->new->format( $format ),    '0,00', 'FR: format 0' );
is( Koha::Number::Price->new(3)->format( $format ), '3,00', 'FR: format 3' );
is(
    Koha::Number::Price->new(1234567890)->format( $format ),
    '1 234 567 890,00',
    'FR: format 1234567890'
);
is( Koha::Number::Price->new->format( { %$format, with_symbol => 1 } ),
    '€0,00', 'FR: format 0 with symbol' );
is( Koha::Number::Price->new(3)->format( { %$format, with_symbol => 1 } ),
    '€3,00', 'FR: format 3 with symbol' );
is(
    Koha::Number::Price->new(1234567890)
      ->format( { %$format, with_symbol => 1 }, 'FR: format 123567890 with symbol' ),
    '€1 234 567 890,00'
);

is( Koha::Number::Price->new->unformat,    '0', 'FR: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'FR: unformat 3' );
is( Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'FR: unformat 1234567890' );

# Price formatting for Switzerland: 1'234'567.89
t::lib::Mocks::mock_preference( 'CurrencyFormat', 'CH' );
$currency = Koha::Acquisition::Currency->new({
    currency => 'nnn',
    symbol   => 'CHF',
    rate     => 1,
    active   => 1,
});

is( Koha::Number::Price->new->format( $format ),    '0.00', 'CH: format 0' );
is( Koha::Number::Price->new(3)->format( $format ), '3.00', 'CH: format 3' );
is(
    Koha::Number::Price->new(1234567890)->format( $format ),
    '1\'234\'567\'890.00',
    'CHF: format 1234567890'
);
is( Koha::Number::Price->new->format( { %$format, with_symbol => 1 } ),
    'CHF0.00', 'CH: format 0 with symbol' );
is( Koha::Number::Price->new(3)->format( { %$format, with_symbol => 1 } ),
    'CHF3.00', 'CH: format 3 with symbol' );
is(
    Koha::Number::Price->new(1234567890)
      ->format( { %$format, with_symbol => 1 }, 'CH: format 123567890 with symbol' ),
    'CHF1\'234\'567\'890.00'
);

is( Koha::Number::Price->new->unformat,    '0', 'CHF: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'CHF: unformat 3' );
is( Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'CHF: unformat 1234567890' );
