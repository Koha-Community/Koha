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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Biblio::Metadata::Extractor;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

subtest 'new() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    throws_ok { Koha::Biblio::Metadata::Extractor->new; }
    'Koha::Exceptions::MissingParameter',
        'Exception if no parameter';

    my $biblio = $builder->build_sample_biblio;

    my $extractor = Koha::Biblio::Metadata::Extractor->new( { biblio => $biblio } );
    is( ref($extractor), 'Koha::Biblio::Metadata::Extractor::MARC::UNIMARC' );

    my $record = $biblio->metadata->record;
    $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );
    is( ref($extractor), 'Koha::Biblio::Metadata::Extractor::MARC::UNIMARC' );

    $schema->storage->txn_rollback;

};

subtest 'get_normalized_upc() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new( '072', '1', ' ', a => "9-123345345X" ) );

    my $extractor = Koha::Biblio::Metadata::Extractor->new( { metadata => $record } );
    is( $extractor->get_normalized_upc, '9123345345X' );

    $record = MARC::Record->new();
    $record->append_fields( MARC::Field->new( '072', ' ', ' ', a => "9-123345345X" ) );

    is( $extractor->get_normalized_upc($record), '9123345345X', 'Indicator has no effect' );

    $schema->storage->txn_rollback;

};
