#!/usr/bin/perl

#
# Copyright 2020 Prosentient Systems
#
# This file is part of Koha.
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use strict;
use warnings;
use Test::NoWarnings;
use Test::More tests => 12;
use Test::Warn;

use t::lib::Mocks;
use_ok("Koha::Middleware::RealIP");

my ( $remote_address, $x_forwarded_for_header, $address );

subtest "No X-Forwarded-For header" => sub {
    plan tests => 1;
    $remote_address         = "1.1.1.1";
    $x_forwarded_for_header = "";
    $address                = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is( $address, '1.1.1.1', "There is no X-Forwarded-For header, so just use the remote address" );
};

subtest "No configuration" => sub {
    plan tests => 1;
    $remote_address         = "2.2.2.2";
    $x_forwarded_for_header = "1.1.1.1";
    $address                = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is(
        $address, '2.2.2.2',
        "No trusted proxies available, so don't trust 2.2.2.2 as a proxy, instead use it as the remote address"
    );
};

subtest "Bad configuration" => sub {
    plan tests => 4;
    $remote_address         = "1.1.1.1";
    $x_forwarded_for_header = "2.2.2.2,3.3.3.3";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', 'bad configuration' );
    warnings_are {
        $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    }
    [ "could not parse bad", "could not parse configuration" ], "Warn on misconfigured koha_trusted_proxies";
    is( $address, '1.1.1.1', "koha_trusted_proxies is misconfigured so ignore the X-Forwarded-For header" );

    $remote_address         = "1.1.1.1";
    $x_forwarded_for_header = "2.2.2.2";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', 'bad 1.1.1.1' );
    warning_is {
        $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    }
    "could not parse bad", "Warn on partially misconfigured koha_trusted_proxies";
    is(
        $address, '2.2.2.2',
        "koha_trusted_proxies contains an invalid value but still includes one correct value, which is relevant, so use X-Forwarded-For header"
    );
};

subtest "Fail proxy isn't trusted" => sub {
    plan tests => 1;
    $remote_address         = "2.2.2.2";
    $x_forwarded_for_header = "1.1.1.1";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', '3.3.3.3' );
    $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is( $address, '2.2.2.2', "The 2.2.2.2 proxy isn't in our trusted list, so use it as the remote address" );
};

subtest "The most recent proxy is trusted but the proxy before it is not trusted" => sub {
    plan tests => 1;
    $remote_address         = "3.3.3.3";
    $x_forwarded_for_header = "1.1.1.1, 2.2.2.2";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', '3.3.3.3' );
    $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is( $address, '2.2.2.2', "We trust 3.3.3.3, but we don't trust 2.2.2.2, so use 2.2.2.2 as the remote address" );
};

subtest "Success one proxy" => sub {
    plan tests => 1;
    $remote_address         = "2.2.2.2";
    $x_forwarded_for_header = "1.1.1.1";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', '2.2.2.2' );
    $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is(
        $address, '1.1.1.1',
        "Trust proxy (2.2.2.2), so use the client IP from the X-Forwarded-For header for the remote address"
    );
};

subtest "Success multiple proxies" => sub {
    plan tests => 1;
    $remote_address         = "2.2.2.2";
    $x_forwarded_for_header = "1.1.1.1,3.3.3.3";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', '2.2.2.2 3.3.3.3' );
    $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is(
        $address, '1.1.1.1',
        "Trust multiple proxies (2.2.2.2 and 3.3.3.3), so use the X-Forwaded-For <client> portion for the remote address"
    );
};

subtest "Test alternative configuration styles" => sub {
    plan tests => 2;
    $remote_address         = "2.2.2.2";
    $x_forwarded_for_header = "1.1.1.1";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', '2.2.2.0/24' );
    $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is(
        $address, '1.1.1.1',
        "Trust proxy (2.2.2.2) using CIDR notation, so use the X-Forwarded-For header for the remote address"
    );

    $remote_address         = "2.2.2.2";
    $x_forwarded_for_header = "1.1.1.1";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', '2.2.2.0:255.255.255.0' );
    $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is(
        $address, '1.1.1.1',
        "Trust proxy (2.2.2.2) using an IP address and netmask separated by a colon, so use the X-Forwarded-For header for the remote address"
    );
};

subtest "Client IP is properly processed even if it is in koha_trusted_proxies" => sub {
    $remote_address         = "1.1.1.2";
    $x_forwarded_for_header = "1.1.1.1";
    t::lib::Mocks::mock_config( 'koha_trusted_proxies', '1.1.1.0/24' );
    $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
    is(
        $address, '1.1.1.1',
        "The X-Forwarded-For value matches the koha_trusted_proxies, but there is no proxy specified"
    );
    done_testing(1);
};

subtest "IPv6 support" => sub {
    my ( $remote_address, $x_forwarded_for_header, $address );
    require Net::Netmask;
    if ( Net::Netmask->VERSION < 1.9104 ) {
        $remote_address         = "2001:db8:1234:5678:abcd:1234:abcd:1234";
        $x_forwarded_for_header = "2.2.2.2";
        t::lib::Mocks::mock_config( 'koha_trusted_proxies', '2001:db8:1234:5678::/64' );

        warning_is {
            $address = Koha::Middleware::RealIP::get_real_ip(
                $remote_address,
                $x_forwarded_for_header
            );
        }
        "could not parse 2001:db8:1234:5678::/64",
            "Warn on IPv6 koha_trusted_proxies";
        is(
            $address,
            '2001:db8:1234:5678:abcd:1234:abcd:1234',
            "Unable to parse IPv6 address for trusted proxy, so ignore the X-Forwarded-For header"
        );
        done_testing(2);
    } else {
        $remote_address         = "2001:db8:1234:5678:abcd:1234:abcd:1234";
        $x_forwarded_for_header = "2.2.2.2";
        t::lib::Mocks::mock_config( 'koha_trusted_proxies', '2001:db8:1234:5678::/64' );

        $address = Koha::Middleware::RealIP::get_real_ip( $remote_address, $x_forwarded_for_header );
        is(
            $address, '2.2.2.2',
            "Trust proxy (2001:db8:1234:5678:abcd:1234:abcd:1234) using IPv6 CIDR notation, so use the X-Forwarded-For header for the remote address"
        );
        done_testing(1);
    }
};
