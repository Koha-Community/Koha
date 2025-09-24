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
use Test::More tests => 5;
use Test::MockModule;
use t::lib::Mocks;

use String::Random;

# Test the plugin is usable
use_ok('Koha::Template::Plugin::Koha');
ok( my $cache = Koha::Template::Plugin::Koha->new() );

subtest "Koha::Template::Plugin::Koha::Version tests" => sub {

    plan tests => 2;

    # Variables for mocking Koha::version()
    my $major;
    my $minor;
    my $maintenance;
    my $development;

    # Mock Koha::version()
    my $koha = Test::MockModule->new('Koha');
    $koha->mock(
        'version',
        sub {
            return "$major.$minor.$maintenance.$development";
        }
    );

    my $rnd = String::Random->new;

    # development version test
    $major       = $rnd->randregex('\d');
    $minor       = $rnd->randregex('\d\d');
    $maintenance = $rnd->randregex('\d\d');
    $development = $rnd->randregex('\d\d\d');
    my $version = "$major.$minor.$maintenance.$development";
    my $res     = Koha::Template::Plugin::Koha::Version($version);
    is_deeply(
        $res,
        {
            major       => $major,
            minor       => $minor,
            release     => $major . "." . $minor,
            maintenance => $major . "." . $minor . "." . $maintenance,
            development => $development
        },
        "Correct development version"
    );

    # maintenance release test
    $major       = $rnd->randregex('\d');
    $minor       = $rnd->randregex('\d\d');
    $maintenance = $rnd->randregex('\d\d');
    $development = "000";
    $version     = "$major.$minor.$maintenance.$development";
    $res         = Koha::Template::Plugin::Koha::Version($version);
    is_deeply(
        $res,
        {
            major       => $major,
            minor       => $minor,
            release     => $major . "." . $minor,
            maintenance => $major . "." . $minor . "." . $maintenance,
            development => undef
        },
        "Correct maintenance version"
    );

};

subtest "Koha::Template::Plugin::Koha::CSVDelimiter tests" => sub {

    plan tests => 8;

    my $plugin = Koha::Template::Plugin::Koha->new();

    t::lib::Mocks::mock_preference( 'CSVDelimiter', '' );
    is( $plugin->CSVDelimiter(), ',', "CSVDelimiter() returns comma when preference is empty string" );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', undef );
    is( $plugin->CSVDelimiter(), ',', "CSVDelimiter() returns comma when preference is undefined" );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', ';' );
    is( $plugin->CSVDelimiter(), ';', "CSVDelimiter() returns preference value when preference is not tabulation" );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', 'tabulation' );
    is( $plugin->CSVDelimiter(), "\t", "CSVDelimiter() returns \\t when preference is tabulation" );

    t::lib::Mocks::mock_preference( 'CSVDelimiter', '#' );
    is( $plugin->CSVDelimiter(undef), '#', "CSVDelimiter(arg) returns preference value when arg is undefined" );
    is( $plugin->CSVDelimiter(''),    '#', "CSVDelimiter(arg) returns preference value when arg is empty string" );
    is( $plugin->CSVDelimiter(','),   ',', "CSVDelimiter(arg) returns arg value when arg is not tabulation" );
    is( $plugin->CSVDelimiter('tabulation'), "\t", "CSVDelimiter(arg) returns \\t value when arg is tabulation" );
};
