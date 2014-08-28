use Modern::Perl;

use Test::More tests => 19;

use Test::MockModule;
use t::lib::Mocks;

use C4::Budgets;
my $budget_module = Test::MockModule->new('C4::Budgets');
my $currency;
$budget_module->mock( 'GetCurrency', sub { return $currency; } );
use_ok('Koha::Number::Price');

t::lib::Mocks::mock_preference( 'CurrencyFormat', 'US' );
$currency = {
    currency => 'USD',
    symbol   => '$',
    rate     => 1,
    active   => 1,
};

is( Koha::Number::Price->new->format,    '0.00', 'US: format 0' );
is( Koha::Number::Price->new(3)->format, '3.00', 'US: format 3' );
is( Koha::Number::Price->new(1234567890)->format,
    '1,234,567,890.00', 'US: format 1234567890' );

# FIXME This should be display symbol, but it was the case before the creation of this module
is( Koha::Number::Price->new->format( { with_symbol => 1 } ),
    '0.00', 'US: format 0 with symbol' );
is( Koha::Number::Price->new(3)->format( { with_symbol => 1 } ),
    '3.00', 'US: format 3 with symbol' );
is(
    Koha::Number::Price->new(1234567890)
      ->format( { with_symbol => 1 }, 'US: format 1234567890 with symbol' ),
    '1,234,567,890.00'
);

is( Koha::Number::Price->new->unformat,    '0', 'US: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'US: unformat 3' );
is( Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'US: unformat 1234567890' );

t::lib::Mocks::mock_preference( 'CurrencyFormat', 'FR' );
$currency = {
    currency => 'EUR',
    symbol   => '€',
    rate     => 1,
    active   => 1,
};

# Actually,the price formating for France is 3,00€
# How put the symbol at the end with Number::Format?
is( Koha::Number::Price->new->format,    '0,00', 'FR: format 0' );
is( Koha::Number::Price->new(3)->format, '3,00', 'FR: format 3' );
is(
    Koha::Number::Price->new(1234567890)->format,
    '1 234 567 890,00',
    'FR: format 1234567890'
);
is( Koha::Number::Price->new->format( { with_symbol => 1 } ),
    '€0,00', 'FR: format 0 with symbol' );
is( Koha::Number::Price->new(3)->format( { with_symbol => 1 } ),
    '€3,00', 'FR: format 3 with symbol' );
is(
    Koha::Number::Price->new(1234567890)
      ->format( { with_symbol => 1 }, 'FR: format 123567890 with symbol' ),
    '€1 234 567 890,00'
);

is( Koha::Number::Price->new->unformat,    '0', 'FR: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'FR: unformat 3' );
is( Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'FR: unformat 1234567890' );
