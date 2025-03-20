use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 38;

use Test::MockModule;
use t::lib::Mocks;

# Number formatting depends by default on system environment
# See http://search.cpan.org/~wrw/Number-Format/Format.pm
use POSIX qw(setlocale LC_NUMERIC);

use Koha::Acquisition::Currencies;
my $budget_module = Test::MockModule->new('Koha::Acquisition::Currencies');
my $currency;
$budget_module->mock( 'get_active', sub { return $currency; } );
use_ok('Koha::Number::Price');

my $orig_locale = setlocale(LC_NUMERIC);
my $format      = {
    p_cs_precedes => 1,    # Force to place the symbol at the beginning
};

is( Koha::Number::Price->new->format($format), '0.00', 'There is no currency defined yet, do not explode!' );

t::lib::Mocks::mock_preference( 'CurrencyFormat', 'US' );
$currency = Koha::Acquisition::Currency->new(
    {
        currency       => 'USD',
        symbol         => '$',
        rate           => 1,
        active         => 1,
        p_sep_by_space => 0, # Force to not add a space between the symbol and the number. This is the default behaviour
    }
);

is( Koha::Number::Price->new->format($format),    '0.00', 'US: format 0' );
is( Koha::Number::Price->new(3)->format($format), '3.00', 'US: format 3' );
is(
    Koha::Number::Price->new(1234567890)->format($format),
    '1,234,567,890.00', 'US: format 1234567890'
);

is( Koha::Number::Price->new(100000000000000)->format, '100000000000000', 'Numbers too big are not formatted' );
is(
    Koha::Number::Price->new(-100000000000000)->format, '-100000000000000',
    'Negative numbers too big are not formatted'
);

is(
    Koha::Number::Price->new->format( { %$format, with_symbol => 1 } ),
    '$0.00', 'US: format 0 with symbol'
);
is(
    Koha::Number::Price->new(3)->format( { %$format, with_symbol => 1 } ),
    '$3.00', 'US: format 3 with symbol'
);
is(
    Koha::Number::Price->new(1234567890)->format( { %$format, with_symbol => 1 }, 'US: format 1234567890 with symbol' ),
    '$1,234,567,890.00'
);

$currency->p_sep_by_space(1);
is(
    Koha::Number::Price->new(3)->format( { %$format, with_symbol => 1 } ),
    '$ 3.00', 'US: format 3 with symbol and a space'
);

is( Koha::Number::Price->new->unformat,    '0', 'US: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'US: unformat 3' );
is(
    Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'US: unformat 1234567890'
);

SKIP: {
    # Bug 18900 - Check params are not from system environment
    setlocale( LC_NUMERIC, "fr_FR.UTF-8" );
    my $current_locale = setlocale(LC_NUMERIC);

    skip "fr_FR.UTF-8 locale required for tests and missing", 2
        unless $current_locale eq 'fr_FR.UTF-8';

    is(
        Koha::Number::Price->new(12345678.9)->format( { %$format, with_symbol => 1 } ),
        '$ 12,345,678.90', 'US: format 12,345,678.90 with symbol'
    );
    is(
        Koha::Number::Price->new('12,345,678.90')->unformat,
        '12345678.9', 'US: unformat 12345678.9'
    );
    setlocale( LC_NUMERIC, $orig_locale );
}

t::lib::Mocks::mock_preference( 'CurrencyFormat', 'FR' );
$currency = Koha::Acquisition::Currency->new(
    {
        currency => 'EUR',
        symbol   => '€',
        rate     => 1,
        active   => 1,
    }
);

# Actually,the price formatting for France is 3,00€
# How put the symbol at the end with Number::Format?
is( Koha::Number::Price->new->format($format),    '0,00', 'FR: format 0' );
is( Koha::Number::Price->new(3)->format($format), '3,00', 'FR: format 3' );
is(
    Koha::Number::Price->new(1234567890)->format($format),
    '1 234 567 890,00',
    'FR: format 1234567890'
);
is(
    Koha::Number::Price->new->format( { %$format, with_symbol => 1 } ),
    '€0,00', 'FR: format 0 with symbol'
);
is(
    Koha::Number::Price->new(3)->format( { %$format, with_symbol => 1 } ),
    '€3,00', 'FR: format 3 with symbol'
);
is(
    Koha::Number::Price->new(1234567890)->format( { %$format, with_symbol => 1 }, 'FR: format 123567890 with symbol' ),
    '€1 234 567 890,00'
);

is( Koha::Number::Price->new->unformat,    '0', 'FR: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'FR: unformat 3' );
is(
    Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'FR: unformat 1234567890'
);

# Price formatting for Switzerland: 1'234'567.89
t::lib::Mocks::mock_preference( 'CurrencyFormat', 'CH' );
$currency = Koha::Acquisition::Currency->new(
    {
        currency => 'nnn',
        symbol   => 'CHF',
        rate     => 1,
        active   => 1,
    }
);

is( Koha::Number::Price->new->format($format),    '0.00', 'CH: format 0' );
is( Koha::Number::Price->new(3)->format($format), '3.00', 'CH: format 3' );
is(
    Koha::Number::Price->new(1234567890)->format($format),
    '1\'234\'567\'890.00',
    'CHF: format 1234567890'
);
is(
    Koha::Number::Price->new->format( { %$format, with_symbol => 1 } ),
    'CHF0.00', 'CH: format 0 with symbol'
);
is(
    Koha::Number::Price->new(3)->format( { %$format, with_symbol => 1 } ),
    'CHF3.00', 'CH: format 3 with symbol'
);
is(
    Koha::Number::Price->new(1234567890)->format( { %$format, with_symbol => 1 }, 'CH: format 123567890 with symbol' ),
    'CHF1\'234\'567\'890.00'
);

is( Koha::Number::Price->new->unformat,    '0', 'CHF: unformat 0' );
is( Koha::Number::Price->new(3)->unformat, '3', 'CHF: unformat 3' );
is(
    Koha::Number::Price->new(1234567890)->unformat,
    '1234567890', 'CHF: unformat 1234567890'
);

# Rounding
is( Koha::Number::Price->new(17.955)->round, '17.96', 'Round 17.955' );

subtest 'Changes for format' => sub {    # See also bug 18736
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'CurrencyFormat', 'US' );

    is( Koha::Number::Price->new(-2.125)->format, "-2.13", "Check negative value" );
    my $large_number = 2**53;                                     # MAX_INT
    my $price        = Koha::Number::Price->new($large_number);
    is( $price->format, $price->value, 'Format ' . $price->value . ' returns value' );
    like(
        Koha::Number::Price->new( 2**53 / 100 )->format,
        qr/\d\.\d{2}$/, 'This price still seems to be formatted'
    );

    # Note that the comparison with MAX_INT is already subject to rounding
};

subtest 'Changes for default currency symbol position' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'CurrencyFormat', 'FR' );
    $currency = Koha::Acquisition::Currency->new(
        {
            currency       => 'PLN',
            symbol         => 'zł',
            rate           => 1,
            active         => 1,
            p_sep_by_space => 1,
            p_cs_precedes  => 1,
        }
    );
    is(
        Koha::Number::Price->new('123456.78')->format( { with_symbol => 1 } ),
        'zł 123 456,78',
        'PLN: format 123 456,78 with symbol before'
    );
    $currency->p_cs_precedes(0);
    is(
        Koha::Number::Price->new('123456.78')->format( { with_symbol => 1 } ),
        '123 456,78 zł',
        'PLN: format 123 456,78 with symbol after'
    );
};
