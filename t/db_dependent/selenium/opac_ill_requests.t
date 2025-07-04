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
use Test::More tests => 1;

use C4::Biblio qw(DelBiblio);

use C4::Context;
use Koha::AuthUtils;
use t::lib::Mocks;
use t::lib::Selenium;
use t::lib::TestBuilder;

our $builder                             = t::lib::TestBuilder->new;
our $ILLOpacUnauthenticatedRequest_value = C4::Context->preference('ILLOpacUnauthenticatedRequest');
our $ILLModule_value                     = C4::Context->preference('ILLModule');

SKIP: {
    eval { require Selenium::Remote::Driver; };
    skip "Selenium::Remote::Driver is needed for selenium tests.", 3 if $@;

    our $s      = t::lib::Selenium->new;
    our $driver = $s->driver;

    subtest 'unauthenticated ill request' => sub {
        plan tests => 2;

        subtest 'ILLOpacUnauthenticatedRequest enabled' => sub {
            plan tests => 4;

            C4::Context->set_preference( 'ILLOpacUnauthenticatedRequest', 1 );
            C4::Context->set_preference( 'ILLModule',                     1 );

            $driver->get( $s->opac_base_url . "opac-search.pl?q=music" );

            like(
                $driver->get_title, qr(Results of search for 'music'),
                'Correctly in search results page'
            );

            # Get the second li, the first one is "Make a purchase suggestion"
            is(
                $driver->find_element('//div[@class="suggestion"]/ul/li[2]')->get_text,
                'Make an interlibrary loan request',
                'Placing an ILL request through the OPAC is allowed',
            );

            # Clicking on the search results page link works
            $driver->find_element('//div[@class="suggestion"]/ul/li[2]/a')->click;
            is(
                $driver->find_element('(//nav[@id="breadcrumbs"]/ol/li)[last()]')->get_text,
                'New interlibrary loan request',
                'Correctly on the create new request OPAC page'
            );

            # Visiting the create request page directly works
            $driver->get( $s->opac_base_url . "opac-illrequests.pl?op=create" );
            is(
                $driver->find_element('(//nav[@id="breadcrumbs"]/ol/li)[last()]')->get_text,
                'New interlibrary loan request',
                'Correctly on the create new request OPAC page'
            );

        };

        subtest 'ILLOpacUnauthenticatedRequest disabled' => sub {
            plan tests => 3;

            C4::Context->set_preference( 'ILLOpacUnauthenticatedRequest', 0 );
            C4::Context->set_preference( 'ILLModule',                     1 );

            $driver->get( $s->opac_base_url . "opac-search.pl?q=music" );

            like(
                $driver->get_title, qr(Results of search for 'music'),
                'Correctly in search results page'
            );

            my $link_exists = $driver->find_elements('//div[@class="suggestion"]/ul/li');

            is(
                scalar @{$link_exists},
                2,
                'Search page - Place ILL request link should be present. '
            );

            # Visiting the create request page directly does not work
            $driver->get( $s->opac_base_url . "opac-illrequests.pl?op=create" );
            is(
                $driver->find_element('(//nav[@id="breadcrumbs"]/ol/li)[last()]')->get_text,
                'Log in to your account',
                'Correctly on the log in page'
            );

        };
    };

    $driver->quit();
}

END {
    C4::Context->set_preference( 'ILLOpacUnauthenticatedRequest', $ILLOpacUnauthenticatedRequest_value );
    C4::Context->set_preference( 'ILLModule',                     $ILLModule_value );
}
