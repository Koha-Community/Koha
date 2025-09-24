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
use Test::More tests => 4;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::BatchUpdateBiblio;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    # FIXME: Should be an exception
    my $job_id = Koha::BackgroundJob::BatchUpdateBiblio->new->enqueue();
    is( $job_id, undef, 'Nothing enqueued if missing params' );

    # FIXME: Should be an exception
    $job_id = Koha::BackgroundJob::BatchUpdateBiblio->new->enqueue( { record_ids => undef } );
    is( $job_id, undef, "Nothing enqueued if missing 'mmtid' param" );

    my $record_ids = [ 1, 2 ];

    $job_id = Koha::BackgroundJob::BatchUpdateBiblio->new->enqueue( { record_ids => $record_ids, mmtid => 'thing' } );
    my $job = Koha::BackgroundJobs->find($job_id)->_derived_class;

    is( $job->size,   scalar @{$record_ids}, 'Size is correct' );
    is( $job->status, 'new',                 'Initial status set correctly' );
    is( $job->queue,  'long_tasks',          'BatchUpdateItem should use the long_tasks queue' );

    $schema->storage->txn_rollback;
};

subtest 'marc_record_contains_item_data tests' => sub {
    plan tests => 6;

    # Mock the MARC21 flavor preference
    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    # Test with no item fields
    my $record = MARC::Record->new();
    is(
        Koha::BackgroundJob::BatchUpdateBiblio::marc_record_contains_item_data($record), 0,
        'Returns 0 with no item fields'
    );

    # Test with one item field
    $record->append_fields( MARC::Field->new( '952', ' ', ' ', 'a' => 'test' ) );
    is(
        Koha::BackgroundJob::BatchUpdateBiblio::marc_record_contains_item_data($record), 1,
        'Returns 1 with one item field'
    );

    # Test with multiple item fields
    $record->append_fields( MARC::Field->new( '952', ' ', ' ', 'a' => 'test2' ) );
    is(
        Koha::BackgroundJob::BatchUpdateBiblio::marc_record_contains_item_data($record), 2,
        'Returns 2 with two item fields'
    );

    # Mock the UNIMARC flavor preference
    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );

    # Test with no item fields
    $record = MARC::Record->new();
    is(
        Koha::BackgroundJob::BatchUpdateBiblio::marc_record_contains_item_data($record), 0,
        'Returns 0 with no item fields'
    );

    # Test with one item field
    $record->append_fields( MARC::Field->new( '995', ' ', ' ', 'a' => 'test' ) );
    is(
        Koha::BackgroundJob::BatchUpdateBiblio::marc_record_contains_item_data($record), 1,
        'Returns 1 with one item field'
    );

    # Test with multiple item fields
    $record->append_fields( MARC::Field->new( '995', ' ', ' ', 'a' => 'test2' ) );
    is(
        Koha::BackgroundJob::BatchUpdateBiblio::marc_record_contains_item_data($record), 2,
        'Returns 2 with two item fields'
    );
};

subtest 'can_add_item_from_marc_record tests' => sub {
    plan tests => 7;
    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    # Set item-level_itypes preference for testing
    t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );

    # Tests for can_add_item_from_marc_record with all fields
    subtest 'can_add_item_from_marc_record with all fields' => sub {
        plan tests => 2;

        my $record = MARC::Record->new();
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'a' => 'CENTRAL',    # homebranch
                'b' => 'CENTRAL',    # holdingbranch
                'y' => 'BOOK'        # itype
            )
        );

        my ( $result, $error ) = Koha::BackgroundJob::BatchUpdateBiblio::can_add_item_from_marc_record($record);
        is( $result, 1,     'Returns 1 when all required fields exist' );
        is( $error,  undef, 'No error message when successful' );
    };

    # Test missing holdingbranch
    subtest 'can_add_item_from_marc_record missing holdingbranch' => sub {
        plan tests => 2;

        my $record = MARC::Record->new();
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'a'  => 'CENTRAL',    # homebranch
                'y'  => 'BOOK'        # itype
                                      # No 'b' for holdingbranch
            )
        );

        my ( $result, $error ) = Koha::BackgroundJob::BatchUpdateBiblio::can_add_item_from_marc_record($record);
        is( $result, 0,                                 'Returns 0 when holdingbranch is missing' );
        is( $error,  'No holdingbranch subfield found', 'Correct error message for missing holdingbranch' );
    };

    # Test missing homebranch
    subtest 'can_add_item_from_marc_record missing homebranch' => sub {
        plan tests => 2;

        my $record = MARC::Record->new();
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'b'  => 'CENTRAL',    # holdingbranch
                'y'  => 'BOOK'        # itype
                                      # No 'a' for homebranch
            )
        );

        my ( $result, $error ) = Koha::BackgroundJob::BatchUpdateBiblio::can_add_item_from_marc_record($record);
        is( $result, 0,                              'Returns 0 when homebranch is missing' );
        is( $error,  'No homebranch subfield found', 'Correct error message for missing homebranch' );
    };

    # Test missing itemtype
    subtest 'can_add_item_from_marc_record missing itemtype' => sub {
        plan tests => 2;

        my $record = MARC::Record->new();
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'a'  => 'CENTRAL',    # homebranch
                'b'  => 'CENTRAL'     # holdingbranch
                                      # No 'y' for itemtype
            )
        );

        my ( $result, $error ) = Koha::BackgroundJob::BatchUpdateBiblio::can_add_item_from_marc_record($record);
        is( $result, 0,                            'Returns 0 when itemtype is missing' );
        is( $error,  'No itemtype subfield found', 'Correct error message for missing itemtype' );
    };

    # Test with bib-level itemtypes
    subtest 'can_add_item_from_marc_record with bib-level itemtypes' => sub {
        plan tests => 2;

        # Change preference to use bib-level itemtypes
        t::lib::Mocks::mock_preference( 'item-level_itypes', 0 );

        my $record = MARC::Record->new();
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'a' => 'CENTRAL',    # homebranch
                'b' => 'CENTRAL',    # holdingbranch
            )
        );

        $record->append_fields(
            MARC::Field->new(
                '942', ' ', ' ',
                'c' => 'BOOK',       # itemtype
            )
        );

        my ( $result, $error ) = Koha::BackgroundJob::BatchUpdateBiblio::can_add_item_from_marc_record($record);
        is( $result, 1,     'Returns 1 when using bib-level itemtypes' );
        is( $error,  undef, 'No error message when successful' );

        # Reset to item-level itemtypes
        t::lib::Mocks::mock_preference( 'item-level_itypes', 1 );
    };

    # Test with multiple item fields
    subtest 'can_add_item_from_marc_record with multiple item fields' => sub {
        plan tests => 2;

        my $record = MARC::Record->new();

        # First field missing itemtype
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'a'  => 'CENTRAL',    # homebranch
                'b'  => 'CENTRAL'     # holdingbranch
                                      # No itemtype
            )
        );

        # Second field is complete
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'a' => 'EAST',        # homebranch
                'b' => 'EAST',        # holdingbranch
                'y' => 'DVD'          # itemtype
            )
        );

        my ( $result, $error ) = Koha::BackgroundJob::BatchUpdateBiblio::can_add_item_from_marc_record($record);
        is( $result, 1,     'Returns 1 when at least one item field is complete' );
        is( $error,  undef, 'No error message when successful' );
    };

    # Test mixed valid/invalid fields
    subtest 'can_add_item_from_marc_record with mix of valid/invalid fields' => sub {
        plan tests => 2;

        my $record = MARC::Record->new();

        # Add a non-item field that shouldn't be considered
        $record->append_fields(
            MARC::Field->new(
                '245', '1', '0',
                'a' => 'Title',
                'b' => 'Subtitle'
            )
        );

        # Add a valid item field
        $record->append_fields(
            MARC::Field->new(
                '952', ' ', ' ',
                'a' => 'CENTRAL',    # homebranch
                'b' => 'CENTRAL',    # holdingbranch
                'y' => 'BOOK'        # itemtype
            )
        );

        my ( $result, $error ) = Koha::BackgroundJob::BatchUpdateBiblio::can_add_item_from_marc_record($record);
        is( $result, 1,     'Returns 1 with mix of item and non-item fields' );
        is( $error,  undef, 'No error message when successful' );
    };

    $schema->storage->txn_rollback;
};
