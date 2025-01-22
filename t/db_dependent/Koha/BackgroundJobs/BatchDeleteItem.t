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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockModule;

use JSON qw( encode_json );

use Koha::Database;
use Koha::BackgroundJob::BatchDeleteItem;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest "process() tests" => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;
    my $item_1 = $builder->build_sample_item( { biblionumber => $biblio->id } );
    my $item_2 = $builder->build_sample_item( { biblionumber => $biblio->id } );

    my $counter = 0;

    my $mock_holds_queue_job = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock_holds_queue_job->mock(
        'enqueue',
        sub {
            $counter++;
        }
    );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    my $job = Koha::BackgroundJob::BatchDeleteItem->new(
        {
            status         => 'new',
            size           => 2,
            borrowernumber => undef,
            type           => 'batch_item_record_deletion',
            data           => encode_json {
                record_ids     => [ $item_1->id, $item_2->id ],
                delete_biblios => 1,
            }
        }
    );

    $job->process(
        {
            record_ids     => [ $item_1->id, $item_2->id ],
            delete_biblios => 1,
        }
    );

    is( $counter, 1, 'Holds queue update is enqueued only once' );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    $biblio = $builder->build_sample_biblio;
    my $item = $builder->build_sample_item( { biblionumber => $biblio->id } );

    $job = Koha::BackgroundJob::BatchDeleteItem->new(
        {
            status         => 'new',
            size           => 2,
            borrowernumber => undef,
            type           => 'batch_item_record_deletion',
            data           => encode_json {
                record_ids     => [ $item->id ],
                delete_biblios => 1,
            }
        }
    );

    $job->process(
        {
            record_ids     => [ $item->id ],
            delete_biblios => 1,
        }
    );

    is( $counter, 1, 'Counter untouched with RealTimeHoldsQueue disabled' );

    $schema->storage->txn_rollback;
};
