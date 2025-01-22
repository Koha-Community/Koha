#!/usr/bin/perl

# Copyright 2022 Koha Development team
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
use Test::More tests => 4;
use Test::MockModule;
use JSON qw( encode_json decode_json );

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::StageMARCForImport;
use Koha::BackgroundJob::MARCImportCommitBatch;
use Koha::BackgroundJob::MARCImportRevertBatch;
use Koha::Import::Records;
use Koha::Exception;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

my $biblio = $builder->build_sample_biblio;
my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
my $import_batch_id;

subtest 'StageMARCForImport' => sub {

    plan tests => 4;

    my $job = Koha::BackgroundJob::StageMARCForImport->new(
        {
            status         => 'new',
            size           => 1,
            borrowernumber => $patron->borrowernumber,
            type           => 'stage_marc_for_import',
        }
    )->store;
    $job = Koha::BackgroundJobs->find( $job->id );
    $job->process(
        {
            job_id      => $job->id,
            record_type => 'biblio',
            encoding    => 'UTF-8',
            format      => 'ISO2709',
            filepath    => 't/db_dependent/data/marc21/zebraexport/biblio/exported_records',
            filename    => 'some_records',
            parse_items => 1,
        }
    );

    my $report = decode_json( $job->get_from_storage->data )->{report};
    is( $report->{num_items},     138 );
    is( $report->{staged},        178 );
    is( $report->{total},         179 );
    is( $report->{import_errors}, 1 );
    $import_batch_id = $report->{import_batch_id};

};

subtest 'MARCImportCommitBatch' => sub {

    plan tests => 2;

    my $job = Koha::BackgroundJob::MARCImportCommitBatch->new(
        {
            status         => 'new',
            size           => 1,
            borrowernumber => $patron->borrowernumber,
            type           => 'marc_import_commit_batch'
        }
    )->store;
    $job = Koha::BackgroundJobs->find( $job->id );
    $job->process(
        {
            job_id          => $job->id,
            import_batch_id => $import_batch_id,
            frameworkcode   => q{},
        }
    );

    my $report = decode_json( $job->get_from_storage->data )->{report};
    is( $report->{num_added},       178 );
    is( $report->{num_items_added}, 138 );

};

subtest 'MARCImportRevertBatch' => sub {

    plan tests => 2;

    my $job = Koha::BackgroundJob::MARCImportRevertBatch->new(
        {
            status         => 'new',
            size           => 1,
            borrowernumber => $patron->borrowernumber,
            type           => 'marc_import_revert_batch'
        }
    )->store;
    $job = Koha::BackgroundJobs->find( $job->id );
    $job->process(
        {
            job_id          => $job->id,
            import_batch_id => $import_batch_id,
        }
    );

    my $report = decode_json( $job->get_from_storage->data )->{report};
    is( $report->{num_deleted},       178 );
    is( $report->{num_items_deleted}, 138 );

};

$schema->storage->txn_rollback;
