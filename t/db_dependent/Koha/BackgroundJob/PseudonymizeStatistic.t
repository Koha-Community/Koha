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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::Exception;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::PseudonymizeStatistic;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item   = $builder->build_sample_item();

    throws_ok {
        Koha::BackgroundJob::PseudonymizeStatistic->new->enqueue()
    }
    'Koha::Exceptions::MissingParameter',
        "Exception thrown if 'statistic' param is missing";

    my $statistic = $builder->build_object(
        {
            class => 'Koha::Statistics',
            value => { type => 'issue', borrowernumber => $patron->id, itemnumber => $item->id }
        }
    );

    my $job_id = Koha::BackgroundJob::PseudonymizeStatistic->new->enqueue( { statistic => $statistic->unblessed } );

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,   1,         'Size is correct' );
    is( $job->status, 'new',     'Initial status set correctly' );
    is( $job->queue,  'default', 'PseudonymizeStatistic should use the default queue' );

    $schema->storage->txn_rollback;
};

subtest 'process() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_config( 'bcrypt_settings', '$2a$08$9lmorEKnwQloheaCLFIfje' );
    t::lib::Mocks::mock_preference( 'Pseudonymization',             1 );
    t::lib::Mocks::mock_preference( 'PseudonymizationPatronFields', 'branchcode,categorycode,sort1' );

    my $patron    = $builder->build_object( { class => 'Koha::Patrons' } );
    my $item      = $builder->build_sample_item();
    my $statistic = $builder->build_object(
        {
            class => 'Koha::Statistics',
            value => { type => 'issue', borrowernumber => $patron->id, itemnumber => $item->id }
        }
    );

    my $job_id = Koha::BackgroundJob::PseudonymizeStatistic->new->enqueue( { statistic => $statistic->unblessed } );
    my $pseudonymized_transactions_before = Koha::PseudonymizedTransactions->search()->count();
    my $job                               = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( { statistic => $statistic->unblessed } );
    my $pseudonymized_transactions_after = Koha::PseudonymizedTransactions->search()->count();
    is( $pseudonymized_transactions_after, $pseudonymized_transactions_before + 1, "Pseudonymized transaction added" );

    $job->discard_changes;
    is( $job->data, '{"data":""}', "Job data cleared after pseudonymization" );

    $schema->storage->txn_rollback;
};
