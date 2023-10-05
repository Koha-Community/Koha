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

use Test::More tests => 3;
use Test::Exception;
use Test::MockModule;

use MARC::Record;

use Koha::Biblio::Metadata::Extractor;

subtest 'new() tests' => sub {

    plan tests => 1;

    my $extractor = Koha::Biblio::Metadata::Extractor->new;
    is( ref($extractor), 'Koha::Biblio::Metadata::Extractor' );
};

subtest 'get_extractor() tests' => sub {

    plan tests => 8;

    my $extractor = Koha::Biblio::Metadata::Extractor->new;

    foreach my $schema (qw{ MARC21 UNIMARC }) {
        my $specific_extractor = $extractor->get_extractor( { schema => $schema } );
        is(
            ref($specific_extractor), "Koha::Biblio::Metadata::Extractor::MARC::$schema",
            "Returns the right extractor library for schema ($schema)"
        );
        ok( exists $extractor->{extractors}->{$schema}, "Extractor for $schema cached" );
    }

    throws_ok { $extractor->get_extractor }
    'Koha::Exceptions::MissingParameter',
        'Exception if no schema parameter';

    like(
        "$@", qr{A required parameter is missing' with parameter => schema},
        'Exception correctly details missing parameter'
    );

    throws_ok { $extractor->get_extractor( { schema => 'POTATO' } ) }
    'Koha::Exceptions::WrongParameter',
        'Exception if the passed schema is not supported';

    like(
        "$@", qr{'Parameter has wrong value or type' with name => schema, value => POTATO},
        'Exception correctly details incorrect parameter value'
    );
};

subtest 'get_normalized_upc() tests' => sub {

    plan tests => 6;

    my $extractor = Koha::Biblio::Metadata::Extractor->new;

    my $record = MARC::Record->new();

    my $mock_marc21 = Test::MockModule->new('Koha::Biblio::Metadata::Extractor::MARC::MARC21');
    $mock_marc21->mock( 'get_normalized_upc', sub { return 'MARC21' } );

    my $mock_unimarc = Test::MockModule->new('Koha::Biblio::Metadata::Extractor::MARC::UNIMARC');
    $mock_unimarc->mock( 'get_normalized_upc', sub { return 'UNIMARC' } );

    foreach my $schema (qw{ MARC21 UNIMARC }) {
        is(
            $extractor->get_normalized_upc( { record => $record, schema => $schema } ), $schema,
            "Library for handling $schema called"
        );
        ok( exists $extractor->{extractors}->{$schema}, "Extractor for $schema cached" );
    }

    throws_ok { $extractor->get_normalized_upc() }
    'Koha::Exceptions::MissingParameter',
        'Exception if no record parameter';

    like(
        "$@", qr{A required parameter is missing' with parameter => record},
        'Exception correctly details missing parameter'
    );
};
