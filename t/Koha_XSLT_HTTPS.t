#!/usr/bin/perl

# Copyright 2022 Rijksmuseum
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

use Modern::Perl;

use Test::Exception;
use Test::MockModule;
use Test::MockObject;
use Test::NoWarnings;
use Test::More tests => 2;

use Koha::XSLT::HTTPS;

subtest 'load' => sub {
    plan tests => 9;

    # Mock the LWP stuff
    my $lwp_object = Test::MockObject->new;
    my $response   = Test::MockObject->new;
    $response->mock( 'is_success', sub { return 0 } );
    $lwp_object->mock( 'get', sub { return $response; } );
    my $lwp_mod = Test::MockModule->new('LWP::UserAgent');
    $lwp_mod->mock( 'new', sub { return $lwp_object } );

    # Trivial bad input
    throws_ok { Koha::XSLT::HTTPS->load; } 'Koha::Exceptions::XSLT::MissingFilename', 'No filename';
    throws_ok { Koha::XSLT::HTTPS->load(q{}); } 'Koha::Exceptions::XSLT::MissingFilename', 'Empty filename';
    my $result = Koha::XSLT::HTTPS->load('filename.xsl');
    is( ref($result),               'HASH',         'Should return hash' );
    is( exists $result->{location}, 1,              'Hash key location found' );
    is( $result->{location},        'filename.xsl', 'Value for location key' );

    # Mock returns no success
    throws_ok { Koha::XSLT::HTTPS->load('https://myfavoritexsltsite.com/test1.xsl'); }
    'Koha::Exceptions::XSLT::FetchFailed', 'Fetch failed';

    # Mock returns 'code'
    $response->mock( 'is_success',      sub { return 1 } );
    $response->mock( 'decoded_content', sub { return 'supposed_xslt_code' } );
    $result = Koha::XSLT::HTTPS->load('https://myfavoritexsltsite.com/test2.xsl');
    is( ref($result),             'HASH',               'Should return hash' );
    is( exists $result->{string}, 1,                    'Hash key string found' );
    is( $result->{string},        'supposed_xslt_code', 'Value for string key' );
    }
