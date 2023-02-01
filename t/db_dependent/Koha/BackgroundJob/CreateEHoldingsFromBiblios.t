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
use Koha::BackgroundJob::CreateEHoldingsFromBiblios;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    # FIXME: Should be an exception
    my $job_id =
      Koha::BackgroundJob::CreateEHoldingsFromBiblios->new->enqueue();
    is( $job_id, undef, 'Nothing enqueued if missing params' );

    # FIXME: Should be an exception
    $job_id = Koha::BackgroundJob::CreateEHoldingsFromBiblios->new->enqueue(
        { record_ids => undef } );
    is( $job_id, undef, "Nothing enqueued if missing 'package_id' param" );

    $schema->storage->txn_rollback;
};

subtest 'process' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    my $package =
      Koha::ERM::EHoldings::Package->new( { name => 'a package' } )->store;

    my $job = Koha::BackgroundJob::CreateEHoldingsFromBiblios->new(
        {
            status => 'new',
            type   => 'create_eholdings_from_biblios',
            size   => 1,
        }
    )->store;
    $job = Koha::BackgroundJobs->find( $job->id );
    my $data = {
        record_ids => [ $biblio->biblionumber ],
        package_id => $package->package_id,
    };
    my $json = $job->json->encode($data);
    $job->data($json)->store;
    $job->process($data);
    is( $job->report->{total_success}, 1 );

    $schema->storage->txn_rollback;
};
