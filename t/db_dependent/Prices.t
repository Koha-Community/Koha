#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 1;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;
use Koha::Number::Price;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

subtest 'Tests from t' => sub {
    plan tests => 12;

    t::lib::Mocks::mock_preference( 'TaxRates', '0.02|0.05|0.196' );
    my $bookseller_module = Test::MockModule->new('Koha::Acquisition::Bookseller');

    my ( @booksellers, @baskets, @biblios );
    my @names = ( '0 0', '0 1', '1 0', '1 1' );
    foreach my $i ( 1..4 ) {
        push @booksellers, $builder->build_object(
            {
                class => 'Koha::Acquisition::Booksellers',
                value =>
                    { name => $names[ $i - 1 ], listincgst => $i < 3 ? 0 : 1, invoiceincgst => $i % 2 == 0 ? 1 : 0 }
            }
        );
        push @baskets, $builder->build_object(
            {
                class => 'Koha::Acquisition::Baskets',
                value =>
                    { basketname => $names[ $i - 1 ], booksellerid => $booksellers[$i-1]->id }
            }
        );
        push @biblios,  $builder->build_sample_biblio;
    }

    my ( $basketno_0_0, $basketno_0_1, $basketno_1_0, $basketno_1_1 ) = map { $_->id } @baskets;
    my ( $invoiceid_0_0, $invoiceid_1_1 );
    my $today;

    for my $currency_format ( qw( US FR ) ) {
        t::lib::Mocks::mock_preference( 'CurrencyFormat', $currency_format );
        subtest 'Configuration 1: 0 0 (Vendor List prices do not include tax / Invoice prices do not include tax)' => sub {
            plan tests => 8;

            my $biblionumber_0_0 = $biblios[0]->id;

            my $order_0_0 = Koha::Acquisition::Order->new({
                biblionumber     => $biblionumber_0_0,
                quantity         => 2,
                listprice        => 82,
                unitprice        => 73.80,
                quantityreceived => 2,
                basketno         => $basketno_0_0,
                invoiceid        => $invoiceid_0_0,
                rrp              => 82.00,
                ecost            => 73.80,
                tax_rate_on_ordering  => 0.0500,
                tax_rate_on_receiving => 0.0500,
                discount         => 10,
                datereceived     => $today
            });
            $order_0_0->populate_with_prices_for_ordering();

            compare(
                {
                    got      => $order_0_0->rrp_tax_included,
                    expected => 86.10,
                    conf     => '0 0',
                    field    => 'rrp_tax_included'
                }
            );
            compare(
                {
                    got      => $order_0_0->rrp_tax_excluded,
                    expected => 82.00,
                    conf     => '0 0',
                    field    => 'rrp_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_0_0->ecost_tax_included,
                    expected => 77.49,
                    conf     => '0 0',
                    field    => 'ecost_tax_included'
                }
            );
            compare(
                {
                    got      => $order_0_0->ecost_tax_excluded,
                    expected => 73.80,
                    conf     => '0 0',
                    field    => 'ecost_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_0_0->tax_value_on_ordering,
                    expected => 7.38,
                    conf     => '0 0',
                    field    => 'tax_value'
                }
            );

            $order_0_0->populate_with_prices_for_receiving();

            compare(
                {
                    got      => $order_0_0->unitprice_tax_included,
                    expected => 77.49,
                    conf     => '0 0',
                    field    => 'unitprice_tax_included'
                }
            );
            compare(
                {
                    got      => $order_0_0->unitprice_tax_excluded,
                    expected => 73.80,
                    conf     => '0 0',
                    field    => 'unitprice_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_0_0->tax_value_on_receiving,
                    expected => 7.38,
                    conf     => '0 0',
                    field    => 'tax_value'
                }
            );
        };

        subtest 'Configuration 1: 1 1 (Vendor List prices do include tax / Invoice prices include tax)' => sub {
            plan tests => 11;

            my $biblionumber_1_1 = $biblios[3]->id;
            my $order_1_1        = Koha::Acquisition::Order->new({
                biblionumber     => $biblionumber_1_1,
                quantity         => 2,
                listprice        => 82,
                unitprice        => 73.80,
                quantityreceived => 2,
                basketno         => $basketno_1_1,
                invoiceid        => $invoiceid_1_1,
                rrp              => 82.00,
                ecost            => 73.80,
                tax_rate_on_ordering  => 0.0500,
                tax_rate_on_receiving => 0.0500,
                discount         => 10,
                datereceived     => $today
            });

            $order_1_1->populate_with_prices_for_ordering();

            compare(
                {
                    got      => $order_1_1->rrp_tax_included,
                    expected => 82.00,
                    conf     => '1 1',
                    field    => 'rrp_tax_included'
                }
            );
            compare(
                {
                    got      => $order_1_1->rrp_tax_excluded,
                    expected => 78.10,
                    conf     => '1 1',
                    field    => 'rrp_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_1_1->ecost_tax_included,
                    expected => 73.80,
                    conf     => '1 1',
                    field    => 'ecost_tax_included'
                }
            );
            compare(
                {
                    got      => $order_1_1->ecost_tax_excluded,
                    expected => 70.29,
                    conf     => '1 1',
                    field    => 'ecost_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_1_1->tax_value_on_ordering,
                    expected => 7.03,
                    conf     => '1 1',
                    field    => 'tax_value'
                }
            );

            $order_1_1->populate_with_prices_for_receiving();

            compare(
                {
                    got      => $order_1_1->unitprice_tax_included,
                    expected => 73.80,
                    conf     => '1 1',
                    field    => 'unitprice_tax_included'
                }
            );
            compare(
                {
                    got      => $order_1_1->unitprice_tax_excluded,
                    expected => 70.29,
                    conf     => '1 1',
                    field    => 'unitprice_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_1_1->tax_value_on_receiving,
                    expected => 7.03,
                    conf     => '1 1',
                    field    => 'tax_value'
                }
            );

            # When unitprice is 0.00
            # Koha::Acquisition::Order::populate_with_prices_for_ordering() falls
            # back to using ecost_tax_included and ecost_tax_excluded
            $order_1_1        = Koha::Acquisition::Order->new({
                biblionumber     => $biblionumber_1_1,
                quantity         => 1,
                listprice        => 10,
                unitprice        => '0.00',
                quantityreceived => 1,
                basketno         => $basketno_1_1,
                invoiceid        => $invoiceid_1_1,
                rrp              => 10.00,
                ecost            => 10.00,
                tax_rate_on_ordering  => 0.1500,
                tax_rate_on_receiving => 0.1500,
                discount         => 0,
                datereceived     => $today
            });

            $order_1_1->populate_with_prices_for_ordering();

            compare(
                {
                    got      => $order_1_1->ecost_tax_included,
                    expected => 10.00,
                    conf     => '1 1',
                    field    => 'ecost_tax_included'
                }
            );
            compare(
                {
                    got      => $order_1_1->ecost_tax_excluded,
                    expected => 8.70,
                    conf     => '1 1',
                    field    => 'ecost_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_1_1->tax_value_on_ordering,
                    expected => 1.30,
                    conf     => '1 1',
                    field    => 'tax_value'
                }
            );
        };

        subtest 'Configuration 1: 1 0 (Vendor List prices include tax / Invoice prices do not include tax)' => sub {
            plan tests => 9;

            my $biblionumber_1_0 = $biblios[2]->id;
            my $order_1_0 = Koha::Acquisition::Order->new({
                biblionumber     => $biblionumber_1_0,
                quantity         => 2,
                listprice        => 82,
                unitprice        => 0,
                quantityreceived => 2,
                basketno         => $basketno_1_0,
                invoiceid        => $invoiceid_1_1,
                rrp              => 82.00,
                ecost            => 73.80,
                tax_rate_on_ordering  => 0.0500,
                tax_rate_on_receiving => 0.0500,
                discount         => 10,
                datereceived     => $today
            });

            $order_1_0->populate_with_prices_for_ordering();

            compare(
                {
                    got      => $order_1_0->rrp_tax_included,
                    expected => 82,
                    conf     => '1 0',
                    field    => 'rrp_tax_included'
                }
            );
            compare(
                {
                    got      => $order_1_0->rrp_tax_excluded,
                    expected => 78.10,
                    conf     => '1 0',
                    field    => 'rrp_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_1_0->ecost_tax_included,
                    expected => 73.80,
                    conf     => '1 0',
                    field    => 'ecost_tax_included'
                }
            );
            compare(
                {
                    got      => $order_1_0->ecost_tax_excluded,
                    expected => 70.29,
                    conf     => '1 0',
                    field    => 'ecost_tax_excluded'
                }
            );
            # If we order with unitprice = 0, tax is calculated from the ecost
            # (note that in addorder.pl and addorderiso2709 the unitprice may/will be set to the ecost
            compare(
                {
                    got      => $order_1_0->tax_value_on_ordering,
                    expected => 7.03,
                    conf     => '1 0',
                    field    => 'tax_value'
                }
            );
            $order_1_0->unitprice(70.29);
            $order_1_0->populate_with_prices_for_ordering();

            # If a unitprice is provided at ordering, we calculate the tax from that
            compare(
                {
                    got      => $order_1_0->tax_value_on_ordering,
                    expected => 6.69,
                    conf     => '1 0',
                    field    => 'tax_value'
                }
            );

            $order_1_0->populate_with_prices_for_receiving();

            compare(
                {
                    got      => $order_1_0->unitprice_tax_included,
                    expected => 73.80,
                    conf     => '1 0',
                    field    => 'unitprice_tax_included'
                }
            );
            compare(
                {
                    got      => $order_1_0->unitprice_tax_excluded,
                    expected => 70.29,
                    conf     => '1 0',
                    field    => 'unitprice_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_1_0->tax_value_on_receiving,
                    expected => 7.03,
                    conf     => '1 0',
                    field    => 'tax_value'
                }
            );
        };

        subtest 'Configuration 1: 0 1 (Vendor List prices do not include tax / Invoice prices include tax)' => sub {
            plan tests => 9;

            my $biblionumber_0_1 = $biblios[1]->id;
            my $order_0_1 = Koha::Acquisition::Order->new({
                biblionumber     => $biblionumber_0_1,
                quantity         => 2,
                listprice        => 82,
                unitprice        => 0,
                quantityreceived => 2,
                basketno         => $basketno_0_1,
                invoiceid        => $invoiceid_1_1,
                rrp              => 82.00,
                ecost            => 73.80,
                tax_rate_on_ordering  => 0.0500,
                tax_rate_on_receiving => 0.0500,
                discount         => 10,
                datereceived     => $today
            });

            $order_0_1->populate_with_prices_for_ordering();

            compare(
                {
                    got      => $order_0_1->rrp_tax_included,
                    expected => 86.10,
                    conf     => '0 1',
                    field    => 'rrp_tax_included'
                }
            );
            compare(
                {
                    got      => $order_0_1->rrp_tax_excluded,
                    expected => 82.00,
                    conf     => '0 1',
                    field    => 'rrp_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_0_1->ecost_tax_included,
                    expected => 77.49,
                    conf     => '0 1',
                    field    => 'ecost_tax_included'
                }
            );
            compare(
                {
                    got      => $order_0_1->ecost_tax_excluded,
                    expected => 73.80,
                    conf     => '0 1',
                    field    => 'ecost_tax_excluded'
                }
            );
            # If we order with unitprice = 0, tax is calculated from the ecost
            # (note that in addorder.pl and addorderiso2709 the unitprice may/will be set to the ecost
            compare(
                {
                    got      => $order_0_1->tax_value_on_ordering,
                    expected => 7.38,
                    conf     => '0 1',
                    field    => 'tax_value'
                }
            );
            $order_0_1->unitprice(77.490000);
            $order_0_1->populate_with_prices_for_ordering();

            # If a unitprice is provided at ordering, we calculate the tax from that
            compare(
                {
                    got      => $order_0_1->tax_value_on_ordering,
                    expected => 7.75,
                    conf     => '0 1',
                    field    => 'tax_value'
                }
            );
            $order_0_1->populate_with_prices_for_receiving();

            compare(
                {
                    got      => $order_0_1->unitprice_tax_included,
                    expected => 77.49,
                    conf     => '0 1',
                    field    => 'unitprice_tax_included'
                }
            );
            compare(
                {
                    got      => $order_0_1->unitprice_tax_excluded,
                    expected => 73.80,
                    conf     => '0 1',
                    field    => 'unitprice_tax_excluded'
                }
            );
            compare(
                {
                    got      => $order_0_1->tax_value_on_receiving,
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
    for my $currency_format (qw( US FR )) {
        t::lib::Mocks::mock_preference( 'CurrencyFormat', $currency_format );
        is(
            Koha::Number::Price->new(1234567)->format_for_editing, '1234567.00',
            'format_for_editing should return unformated integer part with 2 decimals'
        );
        is(
            Koha::Number::Price->new(1234567.89)->format_for_editing, '1234567.89',
            'format_for_editing should return unformated integer part with 2 decimals'
        );
    }
};

$schema->storage->txn_rollback;
