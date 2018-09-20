#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright (C) 2018  Mark Tompsett
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More tests => 3;
use t::lib::Mocks;

use_ok( 'C4::Acquisition' );

subtest 'Tests for get_rounding_sql' => sub {

    plan tests => 2;

    my $value = '3.141592';

    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{} );
    my $no_rounding_result = C4::Acquisition::get_rounding_sql($value);
    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{nearest_cent} );
    my $rounding_result = C4::Acquisition::get_rounding_sql($value);

    ok( $no_rounding_result eq $value, "Value ($value) not to be rounded" );
    ok( $rounding_result =~ /CAST/,    "Value ($value) will be rounded" );

};

subtest 'Test for get_rounded_price' => sub {

    plan tests => 6;

    my $exact_price      = 3.14;
    my $up_price         = 3.145592;
    my $down_price       = 3.141592;
    my $round_up_price   = sprintf( '%0.2f', $up_price );
    my $round_down_price = sprintf( '%0.2f', $down_price );

    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{} );
    my $not_rounded_result1 = C4::Acquisition::get_rounded_price($exact_price);
    my $not_rounded_result2 = C4::Acquisition::get_rounded_price($up_price);
    my $not_rounded_result3 = C4::Acquisition::get_rounded_price($down_price);
    t::lib::Mocks::mock_preference( 'OrderPriceRounding', q{nearest_cent} );
    my $rounded_result1 = C4::Acquisition::get_rounded_price($exact_price);
    my $rounded_result2 = C4::Acquisition::get_rounded_price($up_price);
    my $rounded_result3 = C4::Acquisition::get_rounded_price($down_price);

    is( $not_rounded_result1, $exact_price,      "Price ($exact_price) was correctly not rounded ($not_rounded_result1)" );
    is( $not_rounded_result2, $up_price,         "Price ($up_price) was correctly not rounded ($not_rounded_result2)" );
    is( $not_rounded_result3, $down_price,       "Price ($down_price) was correctly not rounded ($not_rounded_result3)" );
    is( $rounded_result1,     $exact_price,      "Price ($exact_price) was correctly rounded ($rounded_result1)" );
    is( $rounded_result2,     $round_up_price,   "Price ($up_price) was correctly rounded ($rounded_result2)" );
    is( $rounded_result3,     $round_down_price, "Price ($down_price) was correctly rounded ($rounded_result3)" );

};
