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

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::BatchUpdateItem;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_derived_class() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $job_object = Koha::BackgroundJob->new();
    my $mapping = $job_object->type_to_class_mapping;

    # pick the first
    my $type = ( keys %{$mapping} )[0];

    my $job = $builder->build_object(
        {   class => 'Koha::BackgroundJobs',
            value => { type => $type, data => 'Foo' }
        }
    );

    my $derived = $job->_derived_class;

    is( ref($derived), $mapping->{$type}, 'Job object class is correct' );
    ok( $derived->in_storage, 'The object is correctly marked as in storage' );

    $derived->data('Bar')->store->discard_changes;
    $job->discard_changes;

    is_deeply( $job->unblessed, $derived->unblessed, '_derived_class object refers to the same DB object and can be manipulated as expected' );

    $schema->storage->txn_rollback;
};

subtest 'enqueue() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # FIXME: This all feels we need to do it better...
    my $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2 ] } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,           2,     'Two steps' );
    is( $job->status,         'new', 'Initial status set correctly' );
    is( $job->borrowernumber, undef, 'No userenv, borrowernumber undef' );

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_userenv( { patron => $patron } );

    $job_id = Koha::BackgroundJob::BatchUpdateItem->new->enqueue( { record_ids => [ 1, 2, 3 ] } );
    $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,           3,           'Three steps' );
    is( $job->status,         'new',       'Initial status set correctly' );
    is( $job->borrowernumber, $patron->id, 'No userenv, borrowernumber undef' );

    $schema->storage->txn_rollback;
};
