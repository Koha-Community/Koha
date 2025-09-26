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
use Test::More tests => 10;
use t::lib::Mocks;

use C4::Auth qw();

use_ok('Koha::Auth::Identity::Referer');

subtest 'Typical staff success' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'staffClientBaseURL', 'http://mystaffadmin' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://mystaffadmin/cgi-bin/koha/catalogue/search.pl?q=test',
            interface => 'staff',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, '/cgi-bin/koha/catalogue/search.pl?q=test', 'Correct staff referer processed' );

    $session->delete;
    $session->flush;
};

subtest 'External staff referrers do not get saved' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'staffClientBaseURL', 'http://mystaffadmin' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://externalreferer',
            interface => 'staff',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, undef, 'Bad referrers do not get stored' );

    $session->delete;
    $session->flush;
};

subtest 'Staff logout referer does not lead to loop' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'staffClientBaseURL', 'http://mystaffadmin' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://mystaffadmin/cgi-bin/koha/mainpage.pl?logout.x=1',
            interface => 'staff',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, '/cgi-bin/koha/mainpage.pl', 'Staff logout URL does not lead to loop' );

    $session->delete;
    $session->flush;
};

subtest 'Typical OPAC success' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'http://myopac' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://myopac/cgi-bin/koha/opac-detail.pl?biblionumber=999',
            interface => 'opac',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, '/cgi-bin/koha/opac-detail.pl?biblionumber=999', 'Correct OPAC referer processed' );

    $session->delete;
    $session->flush;
};

subtest 'OPAC logout referer does not lead to loop' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'http://myopac' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://myopac/cgi-bin/koha/opac-main.pl?logout.x=1',
            interface => 'opac',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, undef, 'OPAC logout URL does not lead to loop' );

    $session->delete;
    $session->flush;
};

subtest 'Do not save referer to OPAC root' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'http://myopac' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://myopac',
            interface => 'opac',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, undef, 'Do not save referer to OPAC root' );

    $session->delete;
    $session->flush;
};

subtest 'Do not save referer to OPAC root (ie opac-main.pl)' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'http://myopac' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://myopac/cgi-bin/koha/opac-main.pl',
            interface => 'opac',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, undef, 'Do not save referer to OPAC root (ie opac-main.pl)' );

    $session->delete;
    $session->flush;
};

subtest 'External OPAC referrers do not get saved' => sub {
    plan tests => 1;
    my $session = C4::Auth::get_session("");

    t::lib::Mocks::mock_preference( 'OPACBaseURL', 'http://myopac' );

    Koha::Auth::Identity::Referer->store_referer(
        {
            referer   => 'http://externalreferer',
            interface => 'opac',
            session   => $session,
        }
    );

    my $target_uri = Koha::Auth::Identity::Referer->get_referer(
        {
            session => $session,
        }
    );

    is( $target_uri, undef, 'Bad referrers do not get stored' );

    $session->delete;
    $session->flush;
};
