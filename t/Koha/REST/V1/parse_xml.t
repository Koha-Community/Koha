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
use Test::More tests => 3;
use Test::MockModule;

use XML::LibXML;

use C4::Context;
use Koha::REST::V1;

my $spec_file = C4::Context->config('intranetdir') . '/api/v1/swagger/swagger.yaml';
my $root      = XML::LibXML->load_xml( string => '<patron><surname>Hall</surname></patron>' )->documentElement;

is_deeply( Koha::REST::V1::parse_xml( $root, $spec_file ), { patron => { surname => 'Hall' } }, 'XML is converted' );

# Resolving the spec is slow, it should only happen once per process
my $schema = Test::MockModule->new('JSON::Validator::Schema::OpenAPIv2');
$schema->mock( 'new', sub { die 'Spec resolved again' } );

is_deeply(
    Koha::REST::V1::parse_xml( $root, $spec_file ), { patron => { surname => 'Hall' } },
    'The resolved spec is reused'
);
