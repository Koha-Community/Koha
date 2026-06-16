#!/usr/bin/perl

# This file is part of Koha.
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
use Test::More tests => 7;

use Koha::BackgroundJob::PatronImport;
use Koha::BackgroundJobs;
use Koha::Database;
use Koha::Patrons;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $csv = "surname,branchcode,categorycode\nSmith,CPL,PT\nJones,CPL,PT\n";

    my $job_id = Koha::BackgroundJob::PatronImport->new->enqueue(
        {
            file_content => $csv,
            matchpoint   => 'cardnumber',
        }
    );
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->status, 'new',           'Initial status is new' );
    is( $job->queue,  'long_tasks',    'Uses the long_tasks queue' );
    is( $job->size,   2,               'job_size equals number of data lines' );
    is( $job->type,   'patron_import', 'job_type is patron_import' );

    my $csv_no_newline = "surname,branchcode,categorycode\nSmith,CPL,PT\nJones,CPL,PT";
    my $job_id2        = Koha::BackgroundJob::PatronImport->new->enqueue(
        {
            file_content => $csv_no_newline,
            matchpoint   => 'cardnumber',
        }
    );
    my $job2 = Koha::BackgroundJobs->find($job_id2)->_derived_class;
    is( $job2->size, 2, 'job_size correct for CSV without trailing newline' );

    $schema->storage->txn_rollback;
};

subtest 'process() tests' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'A' } } );

    my $branchcode   = $library->branchcode;
    my $categorycode = $category->categorycode;

    my $csv = join(
        "\n",
        "cardnumber,surname,branchcode,categorycode",
        "TEST001,Smith,$branchcode,$categorycode",
        "TEST002,Jones,$branchcode,$categorycode",
        ""
    );

    my $job_id = Koha::BackgroundJob::PatronImport->new->enqueue(
        {
            file_content         => $csv,
            matchpoint           => 'cardnumber',
            overwrite_cardnumber => 0,
            defaults             => {},
            preserve_fields      => [],
        }
    );

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->status, 'finished', 'Job finishes successfully' );

    my $data = $job->decoded_data;
    is( $data->{imported},      2, 'Two patrons imported' );
    is( $data->{overwritten},   0, 'No patrons overwritten' );
    is( $data->{already_in_db}, 0, 'No patrons already in db' );
    is( $data->{invalid},       0, 'No invalid rows' );
    is( $data->{total},         2, 'Total count is correct' );
    ok( !exists $data->{file_content}, 'file_content cleared from stored data' );
    is(
        Koha::Patrons->search( { cardnumber => { '-in' => [ 'TEST001', 'TEST002' ] } } )->count,
        2, 'Patrons exist in the database'
    );

    $schema->storage->txn_rollback;
};

subtest 'process() with errors' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'A' } } );

    my $branchcode   = $library->branchcode;
    my $categorycode = $category->categorycode;

    my $csv = join(
        "\n",
        "cardnumber,surname,branchcode,categorycode",
        "ERR001,Smith,INVALID_BRANCH,$categorycode",    # bad branchcode
        "ERR002,Jones,$branchcode,INVALID_CAT",         # bad categorycode
        ""
    );

    my $job_id = Koha::BackgroundJob::PatronImport->new->enqueue(
        {
            file_content         => $csv,
            matchpoint           => 'cardnumber',
            overwrite_cardnumber => 0,
            defaults             => {},
            preserve_fields      => [],
        }
    );

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->status, 'finished', 'Job finishes even with errors' );

    my $data = $job->decoded_data;
    is( $data->{imported},           0, 'No patrons imported' );
    is( $data->{invalid},            2, 'Two invalid rows recorded' );
    is( scalar @{ $data->{errors} }, 2, 'All errors stored (no 25-error cap)' );

    $schema->storage->txn_rollback;
};

subtest 'process() already_in_db and overwritten' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'A' } } );

    my $branchcode   = $library->branchcode;
    my $categorycode = $category->categorycode;

    my $csv = join(
        "\n",
        "cardnumber,surname,branchcode,categorycode",
        "DUP001,Smith,$branchcode,$categorycode",
        "DUP002,Jones,$branchcode,$categorycode",
        ""
    );

    my %base_args = (
        file_content    => $csv,
        matchpoint      => 'cardnumber',
        defaults        => {},
        preserve_fields => [],
    );

    # First import creates the patrons
    my $job_id = Koha::BackgroundJob::PatronImport->new->enqueue( { %base_args, overwrite_cardnumber => 0 } );
    my $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );

    # Second import with overwrite disabled — both should be already_in_db
    $job_id = Koha::BackgroundJob::PatronImport->new->enqueue( { %base_args, overwrite_cardnumber => 0 } );
    $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );
    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    my $data = $job->decoded_data;
    is( $data->{already_in_db}, 2, 'Both patrons counted as already_in_db when overwrite disabled' );
    is( $data->{imported},      0, 'No patrons imported on duplicate run' );

    # Third import with overwrite enabled — both should be overwritten
    $job_id = Koha::BackgroundJob::PatronImport->new->enqueue( { %base_args, overwrite_cardnumber => 1 } );
    $job    = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );
    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    $data = $job->decoded_data;
    is( $data->{overwritten},   2, 'Both patrons overwritten when overwrite enabled' );
    is( $data->{already_in_db}, 0, 'No patrons counted as already_in_db when overwrite enabled' );

    $schema->storage->txn_rollback;
};

subtest 'process() with patron list creation' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron   = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'A' } } );

    t::lib::Mocks::mock_userenv( { patron => $patron } );

    my $branchcode   = $library->branchcode;
    my $categorycode = $category->categorycode;

    my $csv = join(
        "\n",
        "cardnumber,surname,branchcode,categorycode",
        "LIST001,Smith,$branchcode,$categorycode",
        "LIST002,Jones,$branchcode,$categorycode",
        ""
    );

    my $job_id = Koha::BackgroundJob::PatronImport->new->enqueue(
        {
            file_content         => $csv,
            matchpoint           => 'cardnumber',
            overwrite_cardnumber => 0,
            defaults             => {},
            preserve_fields      => [],
            createpatronlist     => 1,
            patronlistname       => 'Test import list',
        }
    );

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->process( $job->json->decode( $job->data ) );
    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    my $data = $job->decoded_data;
    is( $data->{patron_list_name}, 'Test import list', 'Patron list name stored in job data' );

    my $list = $schema->resultset('PatronList')->find( { name => 'Test import list' } );
    ok( $list, 'Patron list created in database' );
    is( $list->patron_list_patrons->count, 2, 'Both imported patrons added to the list' );

    $schema->storage->txn_rollback;
};

subtest 'process() with cancelled job' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories', value => { category_type => 'A' } } );

    my $branchcode   = $library->branchcode;
    my $categorycode = $category->categorycode;

    my $csv = join(
        "\n",
        "cardnumber,surname,branchcode,categorycode",
        "CAN001,Smith,$branchcode,$categorycode",
        "CAN002,Jones,$branchcode,$categorycode",
        ""
    );

    my $job_id = Koha::BackgroundJob::PatronImport->new->enqueue(
        {
            file_content         => $csv,
            matchpoint           => 'cardnumber',
            overwrite_cardnumber => 0,
            defaults             => {},
            preserve_fields      => [],
        }
    );

    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    $job->status('cancelled')->store;
    $job->process( $job->json->decode( $job->data ) );

    $job = Koha::BackgroundJobs->find($job_id)->_derived_class;
    is( $job->status, 'cancelled', 'Cancelled job status unchanged after process()' );
    is(
        Koha::Patrons->search( { cardnumber => { '-in' => [ 'CAN001', 'CAN002' ] } } )->count,
        0, 'No patrons created for a cancelled job'
    );

    $schema->storage->txn_rollback;
};
