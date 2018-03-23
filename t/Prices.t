use Modern::Perl;
use Test::More;
use Test::MockModule;

use t::lib::Mocks;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 16;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use_ok('C4::Acquisition');
use_ok('C4::Context');
use_ok('Koha::Number::Price');

t::lib::Mocks::mock_preference( 'gist', '0.02|0.05|0.196' );

use Test::DBIx::Class;

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );
Koha::Database::flush_schema_cache();

fixtures_ok [
    Currency => [
        [ qw/ currency symbol rate active / ],
        [ 'my_cur', '€', 1, 1, ],
    ],
    Aqbookseller => [
        [ qw/ id name listincgst invoiceincgst / ],
        [ 1, '0 0', 0, 0 ],
        [ 2, '0 1', 0, 1 ],
        [ 3, '1 0', 1, 0 ],
        [ 4, '1 1', 1, 1 ],
    ],
], 'add currency fixtures';

my $bookseller_module = Test::MockModule->new('Koha::Acquisition::Bookseller');

my ( $basketno_0_0,  $basketno_1_1,  $basketno_1_0,  $basketno_0_1 );
my ( $invoiceid_0_0, $invoiceid_1_1, $invoiceid_1_0, $invoiceid_0_1 );
my $today;

for my $currency_format ( qw( US FR ) ) {
    t::lib::Mocks::mock_preference( 'CurrencyFormat', $currency_format );
    subtest 'Configuration 1: 0 0' => sub {
        plan tests => 8;

        my $biblionumber_0_0 = 42;

        my $order_0_0 = {
            biblionumber     => $biblionumber_0_0,
            quantity         => 2,
            listprice        => 82.000000,
            unitprice        => 73.80000,
            quantityreceived => 2,
            basketno         => $basketno_0_0,
            invoiceid        => $invoiceid_0_0,
            rrp              => 82.00,
            ecost            => 73.80,
            tax_rate         => 0.0500,
            discount         => 10.0000,
            datereceived     => $today
        };
        $order_0_0 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_0_0,
                booksellerid => 1,
                ordering     => 1,
            }
        );

        compare(
            {
                got      => $order_0_0->{rrp_tax_included},
                expected => 86.10,
                conf     => '0 0',
                field    => 'rrp_tax_included'
            }
        );
        compare(
            {
                got      => $order_0_0->{rrp_tax_excluded},
                expected => 82.00,
                conf     => '0 0',
                field    => 'rrp_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_0_0->{ecost_tax_included},
                expected => 77.49,
                conf     => '0 0',
                field    => 'ecost_tax_included'
            }
        );
        compare(
            {
                got      => $order_0_0->{ecost_tax_excluded},
                expected => 73.80,
                conf     => '0 0',
                field    => 'ecost_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_0_0->{tax_value_on_ordering},
                expected => 7.38,
                conf     => '0 0',
                field    => 'tax_value'
            }
        );

        $order_0_0 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_0_0,
                booksellerid => 1,
                receiving    => 1,
            }
        );

        compare(
            {
                got      => $order_0_0->{unitprice_tax_included},
                expected => 77.49,
                conf     => '0 0',
                field    => 'unitprice_tax_included'
            }
        );
        compare(
            {
                got      => $order_0_0->{unitprice_tax_excluded},
                expected => 73.80,
                conf     => '0 0',
                field    => 'unitprice_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_0_0->{tax_value_on_receiving},
                expected => 7.38,
                conf     => '0 0',
                field    => 'tax_value'
            }
        );
    };

    subtest 'Configuration 1: 1 1' => sub {
        plan tests => 8;

        my $biblionumber_1_1 = 43;
        my $order_1_1        = {
            biblionumber     => $biblionumber_1_1,
            quantity         => 2,
            listprice        => 82.000000,
            unitprice        => 73.800000,
            quantityreceived => 2,
            basketno         => $basketno_1_1,
            invoiceid        => $invoiceid_1_1,
            rrp              => 82.00,
            ecost            => 73.80,
            tax_rate         => 0.0500,
            discount         => 10.0000,
            datereceived     => $today
        };

        $order_1_1 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_1_1,
                booksellerid => 4,
                ordering     => 1,
            }
        );

        compare(
            {
                got      => $order_1_1->{rrp_tax_included},
                expected => 82.00,
                conf     => '1 1',
                field    => 'rrp_tax_included'
            }
        );
        compare(
            {
                got      => $order_1_1->{rrp_tax_excluded},
                expected => 78.10,
                conf     => '1 1',
                field    => 'rrp_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_1_1->{ecost_tax_included},
                expected => 73.80,
                conf     => '1 1',
                field    => 'ecost_tax_included'
            }
        );
        compare(
            {
                got      => $order_1_1->{ecost_tax_excluded},
                expected => 70.29,
                conf     => '1 1',
                field    => 'ecost_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_1_1->{tax_value_on_ordering},
                expected => 7.03,
                conf     => '1 1',
                field    => 'tax_value'
            }
        );

        $order_1_1 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_1_1,
                booksellerid => 4,
                receiving    => 1,
            }
        );

        compare(
            {
                got      => $order_1_1->{unitprice_tax_included},
                expected => 73.80,
                conf     => '1 1',
                field    => 'unitprice_tax_included'
            }
        );
        compare(
            {
                got      => $order_1_1->{unitprice_tax_excluded},
                expected => 70.29,
                conf     => '1 1',
                field    => 'unitprice_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_1_1->{tax_value_on_receiving},
                expected => 7.03,
                conf     => '1 1',
                field    => 'tax_value'
            }
        );
    };

    subtest 'Configuration 1: 1 0' => sub {
        plan tests => 8;

        my $biblionumber_1_0 = 44;
        my $order_1_0        = {
            biblionumber     => $biblionumber_1_0,
            quantity         => 2,
            listprice        => 82.000000,
            unitprice        => 70.290000,
            quantityreceived => 2,
            basketno         => $basketno_1_1,
            invoiceid        => $invoiceid_1_1,
            rrp              => 82.00,
            ecost            => 73.80,
            tax_rate         => 0.0500,
            discount         => 10.0000,
            datereceived     => $today
        };

        $order_1_0 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_1_0,
                booksellerid => 3,
                ordering     => 1,
            }
        );

        compare(
            {
                got      => $order_1_0->{rrp_tax_included},
                expected => 82,
                conf     => '1 0',
                field    => 'rrp_tax_included'
            }
        );
        compare(
            {
                got      => $order_1_0->{rrp_tax_excluded},
                expected => 78.10,
                conf     => '1 0',
                field    => 'rrp_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_1_0->{ecost_tax_included},
                expected => 73.80,
                conf     => '1 0',
                field    => 'ecost_tax_included'
            }
        );
        compare(
            {
                got      => $order_1_0->{ecost_tax_excluded},
                expected => 70.29,
                conf     => '1 0',
                field    => 'ecost_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_1_0->{tax_value_on_ordering},
                expected => 7.03,
                conf     => '1 0',
                field    => 'tax_value'
            }
        );

        $order_1_0 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_1_0,
                booksellerid => 3,
                receiving    => 1,
            }
        );

        compare(
            {
                got      => $order_1_0->{unitprice_tax_included},
                expected => 73.80,
                conf     => '1 0',
                field    => 'unitprice_tax_included'
            }
        );
        compare(
            {
                got      => $order_1_0->{unitprice_tax_excluded},
                expected => 70.29,
                conf     => '1 0',
                field    => 'unitprice_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_1_0->{tax_value_on_receiving},
                expected => 7.03,
                conf     => '1 0',
                field    => 'tax_value'
            }
        );
    };

    subtest 'Configuration 1: 0 1' => sub {
        plan tests => 8;

        my $biblionumber_0_1 = 45;
        my $order_0_1        = {
            biblionumber     => $biblionumber_0_1,
            quantity         => 2,
            listprice        => 82.000000,
            unitprice        => 77.490000,
            quantityreceived => 2,
            basketno         => $basketno_1_1,
            invoiceid        => $invoiceid_1_1,
            rrp              => 82.00,
            ecost            => 73.80,
            tax_rate         => 0.0500,
            discount         => 10.0000,
            datereceived     => $today
        };

        $order_0_1 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_0_1,
                booksellerid => 2,
                ordering     => 1,
            }
        );

        compare(
            {
                got      => $order_0_1->{rrp_tax_included},
                expected => 86.10,
                conf     => '0 1',
                field    => 'rrp_tax_included'
            }
        );
        compare(
            {
                got      => $order_0_1->{rrp_tax_excluded},
                expected => 82.00,
                conf     => '0 1',
                field    => 'rrp_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_0_1->{ecost_tax_included},
                expected => 77.49,
                conf     => '0 1',
                field    => 'ecost_tax_included'
            }
        );
        compare(
            {
                got      => $order_0_1->{ecost_tax_excluded},
                expected => 73.80,
                conf     => '0 1',
                field    => 'ecost_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_0_1->{tax_value_on_ordering},
                expected => 7.38,
                conf     => '0 1',
                field    => 'tax_value'
            }
        );

        $order_0_1 = C4::Acquisition::populate_order_with_prices(
            {
                order        => $order_0_1,
                booksellerid => 2,
                receiving    => 1,
            }
        );

        compare(
            {
                got      => $order_0_1->{unitprice_tax_included},
                expected => 77.49,
                conf     => '0 1',
                field    => 'unitprice_tax_included'
            }
        );
        compare(
            {
                got      => $order_0_1->{unitprice_tax_excluded},
                expected => 73.80,
                conf     => '0 1',
                field    => 'unitprice_tax_excluded'
            }
        );
        compare(
            {
                got      => $order_0_1->{tax_value_on_receiving},
                expected => 7.38,
                conf     => '0 1',
                field    => 'tax_value'
            }
        );
    };
}

sub compare {
    my ($params) = @_;
    is(
        Koha::Number::Price->new( $params->{got} )->format,
        Koha::Number::Price->new( $params->{expected} )->format,
"configuration $params->{conf}: $params->{field} should be correctly calculated"
    );
}

# format_for_editing
for my $currency_format ( qw( US FR ) ) {
    t::lib::Mocks::mock_preference( 'CurrencyFormat', $currency_format );
    is( Koha::Number::Price->new( 1234567 )->format_for_editing, '1234567.00', 'format_for_editing should return unformated integer part with 2 decimals' );
    is( Koha::Number::Price->new( 1234567.89 )->format_for_editing, '1234567.89', 'format_for_editing should return unformated integer part with 2 decimals' );
}
