#!/usr/bin/perl

#
# Copyright 2023 Prosentient Systems
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use Test::More tests => 2;
use Test::Warn;

use t::lib::Mocks;
use_ok("Koha::Middleware::SetEnv");
use Plack::Builder;
use Plack::Util;

subtest 'Test $env integrity' => sub {
    plan tests => 2;

    my $app = sub {
        my $resp = [
            200,
            [
                'Content-Type',
                'text/plain',
                'Content-Length',
                12
            ],
            ['Koha is cool']
        ];
        return $resp;
    };
    my $env               = {};
    my $correct_hash_addr = "$env";
    my @ref_to_test       = ();

    $app = builder {
        enable sub {
            my $app = shift;
            sub {
                my $env = shift;
                push( @ref_to_test, "$env" );

                # do preprocessing
                my $res = $app->($env);

                # do postprocessing
                return $res;
            };
        };
        enable "+Koha::Middleware::SetEnv";
        enable sub {
            my $app = shift;
            sub {
                my $env = shift;
                push( @ref_to_test, "$env" );

                # do preprocessing
                my $res = $app->($env);

                # do postprocessing
                return $res;
            };
        };
        $app;
    };

    my $res = Plack::Util::run_app( $app, $env );
    is( $correct_hash_addr, $ref_to_test[0], "First hash ref address correct before middleware applied" );
    is( $correct_hash_addr, $ref_to_test[1], "Second hash ref address correct after middleware applied" );
};
