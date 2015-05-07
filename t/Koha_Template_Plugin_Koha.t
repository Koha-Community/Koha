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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 3;
use Test::MockModule;

use String::Random;

# Test the plugin is usable
use_ok( 'Koha::Template::Plugin::Koha' );
ok( my $cache = Koha::Template::Plugin::Koha->new() );

subtest "Koha::Template::Plugin::Koha::Version tests" => sub {

    plan tests => 2;

    # Variables for mocking Koha::version()
    my $major;
    my $minor;
    my $maintenance;
    my $development;

    # Mock Koha::version()
    my $koha = new Test::MockModule('Koha');
    $koha->mock( 'version', sub {
        return "$major.$minor.$maintenance.$development";
    });

    my $rnd = new String::Random;
    # development version test
    $major       = $rnd->randregex('\d');
    $minor       = $rnd->randregex('\d\d');
    $maintenance = $rnd->randregex('\d\d');
    $development = $rnd->randregex('\d\d\d');
    my $version = "$major.$minor.$maintenance.$development";
    my $res = Koha::Template::Plugin::Koha::Version( $version );
    is_deeply( $res, {
        major       => $major,
        release     => $major . "." . $minor,
        maintenance => $major . "." . $minor . "." . $maintenance,
        development => $development
    }, "Correct development version");


    # maintenance release test
    $major       = $rnd->randregex('\d');
    $minor       = $rnd->randregex('\d\d');
    $maintenance = $rnd->randregex('\d\d');
    $development = "000";
    $version = "$major.$minor.$maintenance.$development";
    $res = Koha::Template::Plugin::Koha::Version( $version );
    is_deeply( $res, {
        major       => $major,
        release     => $major . "." . $minor,
        maintenance => $major . "." . $minor . "." . $maintenance,
        development => undef
    }, "Correct maintenance version");

};

1;
