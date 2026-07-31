#!/usr/bin/perl

# Copyright 2024 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;

use Test::MockModule;
use Test::More tests => 3;

use t::lib::Mocks::Logger;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;
my $logger  = t::lib::Mocks::Logger->new;

use_ok('Koha::ImportBatch');

subtest 'Koha::ImportBatch->new_from_file tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $mocked_c4_importbatch = Test::MockModule->new('C4::ImportBatch');
    $mocked_c4_importbatch->mock(
        'RecordsFromMARCXMLFile',
        sub {
            return ( [ "marcxml error 1", "error 2" ], [] );
        }
    );

    Koha::ImportBatch->new_from_file( { record_type => 'biblio', format => 'MARCXML', filepath => 'none' } );
    $logger->warn_is(
        "The following error(s) occurred during MARCXML record import:\nERROR: marcxml error 1\nERROR: error 2",
        "Errors are being logged"
    );

    $mocked_c4_importbatch->mock(
        'RecordsFromISO2709File',
        sub {
            return ( [ "iso2709 error 1", "error 2" ], [] );
        }
    );

    Koha::ImportBatch->new_from_file( { record_type => 'biblio', format => 'ISO2709', filepath => 'none' } );
    $logger->warn_is(
        "The following error(s) occurred during ISO2709 record import:\nERROR: iso2709 error 1\nERROR: error 2",
        "Errors are being logged"
    );

    $mocked_c4_importbatch->mock(
        'RecordsFromISO2709File',
        sub {
            return ( [], [] );
        }
    );

    Koha::ImportBatch->new_from_file( { record_type => 'biblio', format => 'ISO2709', filepath => 'none' } );
    $logger->warn_is(
        "",
        "No Errors are being logged"
    );

    $schema->storage->txn_rollback;
};
