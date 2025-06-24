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

use Test::NoWarnings;
use Test::More tests => 2;

use Koha::Manual;

subtest 'VueJS components' => sub {

    my $tests = {
        q{http://localhost:8081/cgi-bin/koha/erm/agreements} =>
            q{https://koha-community.org/manual/25.05/en/html/erm.html#agreements},
        q{/koha/erm/agreements}     => q{https://koha-community.org/manual/25.05/en/html/erm.html#agreements},
        q{/koha/erm/agreements/add} =>
            q{https://koha-community.org/manual/25.05/en/html/erm.html#create-an-agreement-record},
        q{/koha/erm/agreements/edit/1} =>
            q{https://koha-community.org/manual/25.05/en/html/erm.html#create-an-agreement-record},
        q{/koha/erm/agreements?by_expired=true&max_expiration_date=2025-06-24} =>
            q{https://koha-community.org/manual/25.05/en/html/erm.html#agreements},
    };

    plan tests => scalar keys %$tests;

    my $language = 'en';
    while ( my ( $refer, $expected ) = each(%$tests) ) {
        is(
            Koha::Manual::get_url( $refer, $language ), $expected,
            sprintf( "%s should link to %s", $refer, $expected )
        );
    }
};
