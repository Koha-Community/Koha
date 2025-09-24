#!/usr/bin/perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Exception;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    my $biblio_ids = [ 1, 2 ];

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );
    is(
        Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => $biblio_ids } ),
        undef, 'No result when pref is off'
    );
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    throws_ok { Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue() }
    'Koha::Exceptions::MissingParameter',
        "Exception thrown if 'biblio_ids' param is missing";

    like( "$@", qr/Missing biblio_ids parameter is mandatory/, 'Expected exception message' );

    my $job_id = Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => $biblio_ids } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,   scalar @{$biblio_ids}, 'Size is correct' );
    is( $job->status, 'new',                 'Initial status set correctly' );
    is( $job->queue,  'default',             'BatchUpdateItem should use the default queue' );

    $schema->storage->txn_rollback;
};
