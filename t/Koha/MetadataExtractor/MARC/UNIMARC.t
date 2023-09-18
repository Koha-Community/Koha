#!/usr/bin/perl

# Copyright 2023 Koha Development team
#
# This file is part of Koha
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
use Test::Exception;

use MARC::Record;

use Koha::MetadataExtractor::MARC::UNIMARC;

subtest 'new() tests' => sub {

    plan tests => 1;

    my $extractor = Koha::MetadataExtractor::MARC::UNIMARC->new;
    is( ref($extractor), 'Koha::MetadataExtractor::MARC::UNIMARC' );
};

subtest 'get_normalized_upc() tests' => sub {

    plan tests => 6;

    my $extractor = Koha::MetadataExtractor::MARC::UNIMARC->new;

    my $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new( '072', '1', ' ', a => "9-123345345X" ) );

    is( $extractor->get_normalized_upc($record), '9123345345X' );

    $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new( '072', ' ', ' ', a => "9-123345345X" ) );

    is( $extractor->get_normalized_upc($record), '9123345345X', 'Indicator has no effect' );

    throws_ok { $extractor->get_normalized_upc() }
    'Koha::Exceptions::MissingParameter',
        'Exception if no parameter';

    like( "$@", qr{A required parameter is missing' with parameter => record} );

    throws_ok { $extractor->get_normalized_upc("Some string") }
    'Koha::Exceptions::WrongParameter',
        'Exception if no parameter';

    like( "$@", qr{Parameter has wrong value or type} );
};
