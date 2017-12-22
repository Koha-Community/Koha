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

use Test::More tests => 2;
use Test::MockModule;
use Test::Warn;

use Carp;

my $parsing_result = 'ok';

my $xml_simple = Test::MockModule->new('XML::Simple');
$xml_simple->mock(
    XMLin => sub {
        if ( $parsing_result eq 'error' ) {
            croak "Something";
        } else {
            return "XML data";
        }
    }
);

use_ok('Koha::Config');

subtest 'read_from_file() tests' => sub {

    plan tests => 4;

    is( Koha::Config->read_from_file(undef), undef,
        "Undef parameter makes function return undef");

    $parsing_result = 'ok';

    my $result = Koha::Config->read_from_file("SomeFile.xml");
    is( $result, 'XML data', 'File read correctly' );

    $parsing_result = 'error';

    $result = eval {Koha::Config->read_from_file("SomeFile.xml")};
    like( $@, qr{.*Error reading file.*}, 'File failing to read raises warning');
    is( $result, undef, 'Returns undef on error confition' );
};

