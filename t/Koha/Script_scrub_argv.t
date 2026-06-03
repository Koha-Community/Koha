#!/usr/bin/perl

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
use Test::More tests => 8;

BEGIN { use_ok('Koha::Script') }

# _scrub_argv is a package function; call it directly.

subtest '--flag value form: sensitive flag value is redacted' => sub {
    plan tests => 4;

    my @out = Koha::Script::_scrub_argv( '--password', 'secret123' );
    is( $out[0], '--password', 'flag name is preserved' );
    is( $out[1], '[REDACTED]', 'value is redacted' );

    @out = Koha::Script::_scrub_argv( '--userid', 'admin', '--password', 'secret' );
    is( $out[1], 'admin',      'non-sensitive value is not redacted' );
    is( $out[3], '[REDACTED]', 'sensitive value in mixed list is redacted' );
};

subtest '--flag=value form: sensitive flag value is redacted' => sub {
    plan tests => 2;

    my @out = Koha::Script::_scrub_argv('--password=secret123');
    is( scalar @out, 1,                       'single element returned' );
    is( $out[0],     '--password=[REDACTED]', '--flag=value form redacted correctly' );
};

subtest 'non-sensitive flags are not affected' => sub {
    plan tests => 3;

    my @in  = ( '--userid', 'admin', '--verbose', '--confirm' );
    my @out = Koha::Script::_scrub_argv(@in);
    is_deeply( \@out, \@in, 'non-sensitive args pass through unchanged' );

    @out = Koha::Script::_scrub_argv('--output=report.csv');
    is( $out[0], '--output=report.csv', 'non-sensitive --flag=value unchanged' );

    @out = Koha::Script::_scrub_argv();
    is( scalar @out, 0, 'empty input returns empty list' );
};

subtest 'case-insensitive matching' => sub {
    plan tests => 2;

    my @out = Koha::Script::_scrub_argv( '--Password', 'secret' );
    is( $out[1], '[REDACTED]', 'Password (mixed case) is redacted' );

    @out = Koha::Script::_scrub_argv('--PASSWORD=s3cr3t');
    is( $out[0], '--PASSWORD=[REDACTED]', 'PASSWORD (upper case) in --flag=value form is redacted' );
};

subtest 'token and secret patterns are redacted' => sub {
    plan tests => 4;

    my @out = Koha::Script::_scrub_argv( '--token', 'abc123' );
    is( $out[1], '[REDACTED]', 'token value redacted' );

    @out = Koha::Script::_scrub_argv( '--secret', 'abc123' );
    is( $out[1], '[REDACTED]', 'secret value redacted' );

    @out = Koha::Script::_scrub_argv('--apikey=abc123');
    is( $out[0], '--apikey=[REDACTED]', 'apikey in --flag=value form redacted' );

    @out = Koha::Script::_scrub_argv( '--api_key', 'abc123' );
    is( $out[1], '[REDACTED]', 'api_key value redacted' );
};

subtest 'flag immediately followed by another flag is not swallowed' => sub {
    plan tests => 3;

    my @out = Koha::Script::_scrub_argv( '--password', '--verbose' );
    is( scalar @out, 2,            'both args preserved' );
    is( $out[0],     '--password', 'flag name preserved' );
    is( $out[1],     '--verbose',  'next flag not treated as value' );
};

1;
