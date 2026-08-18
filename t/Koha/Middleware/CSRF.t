#!/usr/bin/perl

#
# Copyright 2026 ByWater Solutions
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

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;

use HTTP::Request::Common qw( GET POST );
use Plack::Builder;
use Plack::Request;
use Plack::Test;

use_ok("Koha::Middleware::CSRF");

my $inner_app = sub {
    my ($env) = @_;
    return [ 200, [ 'Content-Type' => 'text/plain' ], [ $env->{PATH_INFO} ] ];
};

# The OPAC and intranet enable this middleware inside a mount, so the path the
# middleware sees has the mount prefix already stripped ( a request for
# /opac/ilsdi.pl reaches it with a PATH_INFO of /ilsdi.pl )
my $app = builder {
    mount '/opac' => builder {
        enable "+Koha::Middleware::CSRF";
        $inner_app;
    };
};

subtest 'POSTs without a CSRF token are rejected' => sub {
    plan tests => 3;

    test_psgi $app, sub {
        my ($cb) = @_;

        my @warnings;
        local $SIG{__WARN__} = sub { push @warnings, @_ };

        my $res = $cb->( POST '/opac/opac-user.pl' );
        is( $res->code, 403, 'POST with no csrf_token is answered with a 403' );
        like( $res->content, qr/Wrong CSRF token/, 'response body says why' );
        like(
            $warnings[0],
            qr/No CSRF token passed for POST/,
            'the rejection is logged'
        );
    };
};

subtest 'GET requests are not subject to CSRF' => sub {
    plan tests => 2;

    test_psgi $app, sub {
        my ($cb) = @_;

        my $res = $cb->( GET '/opac/opac-account-pay-return.pl?payment_method=Foo' );
        is( $res->code, 200, 'GET reaches the application' );
        is(
            $res->content,
            '/opac-account-pay-return.pl',
            'the mount prefix is stripped from the path the middleware matches on'
        );
    };
};

subtest 'excepted paths are not subject to CSRF' => sub {
    plan tests => 2;

    test_psgi $app, sub {
        my ($cb) = @_;

        my $res = $cb->( POST '/opac/ilsdi.pl' );
        is( $res->code, 200, 'POST to ilsdi.pl reaches the application' );

        $res = $cb->( POST '/opac/opac-account-pay-return.pl?payment_method=Foo' );
        is(
            $res->code, 200,
            'POST to opac-account-pay-return.pl reaches the application - payment processors cannot obtain a CSRF token'
        );
    };
};
