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
use Test::More tests => 8;
use Test::MockModule;
use Test::Warn;

use Koha::Database;
use Koha::BackgroundJobs;
use Koha::BackgroundJob::ImportKBARTFile;

use MIME::Base64 qw( encode_base64 );

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'enqueue' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    # FIXME: Should be an exception
    my $job_id = Koha::BackgroundJob::ImportKBARTFile->new->enqueue();
    is( $job_id, undef, 'Nothing enqueued if missing file param' );

    $schema->storage->txn_rollback;
};

subtest 'calculate_chunked_params_size' => sub {

    plan tests => 2;

    my $max_number_of_lines =
        Koha::BackgroundJob::ImportKBARTFile::calculate_chunked_params_size( 500000, 100000, 50000 );
    is( $max_number_of_lines, 7500, 'Number of lines calculated correctly' );
    my $max_number_of_lines2 =
        Koha::BackgroundJob::ImportKBARTFile::calculate_chunked_params_size( 400000, 100000, 60000 );
    is( $max_number_of_lines2, 11250, 'Number of lines calculated correctly' );
};

subtest 'format_title' => sub {

    plan tests => 4;

    my $title = {
        title_id       => 1,
        coverage_notes => 'Test notes'
    };

    my $formatted_title = Koha::BackgroundJob::ImportKBARTFile::format_title($title);

    is( $formatted_title->{external_id}, 1,            'external_id formatted correctly' );
    is( $formatted_title->{notes},       'Test notes', 'notes formatted correctly' );
    is( $title->{title_id},              undef,        'title_id has been deleted' );
    is( $title->{coverage_notes},        undef,        'coverage_notes has been deleted' );
};

subtest 'read_file' => sub {

    plan tests => 7;

    my $file = {
        filename     => 'Test_file.csv',
        file_content => encode_base64(
            'publication_title,print_identifier,online_identifier,date_first_issue_online,num_first_vol_online,num_first_issue_online,date_last_issue_online,num_last_vol_online,num_last_issue_online,title_url,first_author,title_id,embargo_info,coverage_depth,coverage_notes,publisher_name,publication_type,date_monograph_published_print,date_monograph_published_online,monograph_volume,monograph_edition,first_editor,parent_publication_title_id,preceding_publication_title_id,access_type
Nature Plants,,2055-0278,2015-01,1,1,,,,https://www.nature.com/nplants,,4aaa7,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P
Nature Astronomy,,2397-3366,2017-01,1,1,,,,https://www.nature.com/natastron,,4bbb0,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P'
        )
    };

    my ( $column_headers, $lines, $error ) = Koha::BackgroundJob::ImportKBARTFile::read_file($file);

    is( @{$column_headers},     25,                  '25 column headers found' );
    is( @{$column_headers}[0],  'publication_title', 'First header correctly extracted' );
    is( @{$column_headers}[10], 'first_author',      'Tenth header correctly extracted' );
    is( @{$lines},              2,                   'Two lines need processing' );
    is_deeply(
        @{$lines}[0],
        [
            'Nature Plants', '', '2055-0278', '2015-01',     '1', '1', '', '', '', 'https://www.nature.com/nplants', '',
            '4aaa7', '', 'fulltext', 'Hybrid (Open Choice)', 'Nature Publishing Group UK', 'serial', '', '', '', '',
            '',      '', '',         'P'
        ],
        'Line correctly identified'
    );
    is_deeply(
        @{$lines}[1],
        [
            'Nature Astronomy', '', '2397-3366', '2017-01', '1', '1', '', '', '', 'https://www.nature.com/natastron',
            '', '4bbb0', '', 'fulltext', 'Hybrid (Open Choice)', 'Nature Publishing Group UK', 'serial', '', '', '',
            '', '',      '', '',         'P'
        ],
        'Line correctly identified'
    );

    my $file2 = {
        filename     => 'Test_file2.csv',
        file_content => encode_base64(
            "publication_title,print_identifier,online_identifier,date_first_issue_online,num_first_vol_online,num_first_issue_online,date_last_issue_online,num_last_vol_online,num_last_issue_online,title_url,first_author,title_id,embargo_info,coverage_depth,coverage_notes,publisher_name,publication_type,date_monograph_published_print,date_monograph_published_online,monograph_volume,monograph_edition,first_editor,parent_publication_title_id,preceding_publication_title_id,access_type
Nature Plants,,2055-0278,2015-01,1,1,,,,https://www.nature.com/nplants,,4aaa7,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P,\"foo\"bar
Nature Astronomy,,2397-3366,2017-01,1,1,,,,https://www.nature.com/natastron,,4bbb0,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P"
        )
    };
    warning_is {
        Koha::BackgroundJob::ImportKBARTFile::read_file($file2);
    }
    '2023, EIQ - QUO character not allowed, 157', 'Error message correctly reported';
};

subtest 'create_title_hash_from_line_data' => sub {

    plan tests => 2;

    my $file = {
        filename     => 'Test_file.csv',
        file_content => encode_base64(
            'publication_title,print_identifier,online_identifier,date_first_issue_online,num_first_vol_online,num_first_issue_online,date_last_issue_online,num_last_vol_online,num_last_issue_online,title_url,first_author,title_id,embargo_info,coverage_depth,coverage_notes,publisher_name,publication_type,date_monograph_published_print,date_monograph_published_online,monograph_volume,monograph_edition,first_editor,parent_publication_title_id,preceding_publication_title_id,access_type
Nature Plants,,2055-0278,2015-01,1,1,,,,https://www.nature.com/nplants,,4aaa7,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P
Nature Astronomy,,2397-3366,2017-01,1,1,,,,https://www.nature.com/natastron,,4bbb0,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P'
        )
    };

    my ( $column_headers, $lines ) = Koha::BackgroundJob::ImportKBARTFile::read_file($file);
    my @invalid_columns;

    my $title_from_line1 = Koha::BackgroundJob::ImportKBARTFile::create_title_hash_from_line_data(
        @{$lines}[0], $column_headers,
        \@invalid_columns
    );
    my $title_from_line2 = Koha::BackgroundJob::ImportKBARTFile::create_title_hash_from_line_data(
        @{$lines}[1], $column_headers,
        \@invalid_columns
    );

    my $line1_match = {
        'coverage_depth'                  => 'fulltext',
        'date_monograph_published_print'  => '',
        'date_first_issue_online'         => '2015-01',
        'date_last_issue_online'          => '',
        'coverage_notes'                  => 'Hybrid (Open Choice)',
        'first_editor'                    => '',
        'date_monograph_published_online' => '',
        'preceding_publication_title_id'  => '',
        'num_last_issue_online'           => '',
        'embargo_info'                    => '',
        'access_type'                     => 'P',
        'num_first_issue_online'          => '1',
        'online_identifier'               => '2055-0278',
        'title_url'                       => 'https://www.nature.com/nplants',
        'monograph_volume'                => '',
        'first_author'                    => '',
        'parent_publication_title_id'     => '',
        'num_last_vol_online'             => '',
        'publication_title'               => 'Nature Plants',
        'num_first_vol_online'            => '1',
        'print_identifier'                => '',
        'publisher_name'                  => 'Nature Publishing Group UK',
        'title_id'                        => '4aaa7',
        'publication_type'                => 'serial',
        'monograph_edition'               => ''
    };
    my $line2_match = {
        'date_monograph_published_online' => '',
        'num_first_vol_online'            => '1',
        'num_last_issue_online'           => '',
        'preceding_publication_title_id'  => '',
        'title_url'                       => 'https://www.nature.com/natastron',
        'online_identifier'               => '2397-3366',
        'print_identifier'                => '',
        'num_last_vol_online'             => '',
        'embargo_info'                    => '',
        'parent_publication_title_id'     => '',
        'publisher_name'                  => 'Nature Publishing Group UK',
        'date_first_issue_online'         => '2017-01',
        'monograph_volume'                => '',
        'monograph_edition'               => '',
        'access_type'                     => 'P',
        'first_author'                    => '',
        'num_first_issue_online'          => '1',
        'first_editor'                    => '',
        'publication_title'               => 'Nature Astronomy',
        'date_monograph_published_print'  => '',
        'publication_type'                => 'serial',
        'title_id'                        => '4bbb0',
        'coverage_depth'                  => 'fulltext',
        'coverage_notes'                  => 'Hybrid (Open Choice)',
        'date_last_issue_online'          => ''
    };

    is_deeply( $title_from_line1, $line1_match, 'Title hash created correctly' );
    is_deeply( $title_from_line2, $line2_match, 'Title hash created correctly' );
};

subtest 'create_title_hash_from_line_data with invalid columns using csv' => sub {

    plan tests => 2;

    my $file = {
        filename     => 'Test_file.csv',
        file_content => encode_base64(
            'publication_title,print_identifier,online_identifier,date_first_issue_online,num_first_vol_online,num_first_issue_online,date_last_issue_online,num_last_vol_online,num_last_issue_online,title_url,first_author,title_id,embargo_info,coverage_depth,coverage_notes,publisher_name,publication_type,date_monograph_published_print,date_monograph_published_online,monograph_volume,monograph_edition,first_editor,parent_publication_title_id,preceding_publication_title_id,access_type,invalid_column
Nature Plants,,2055-0278,2015-01,1,1,,,,https://www.nature.com/nplants,,4aaa7,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P,invalid_column_data
Nature Astronomy,,2397-3366,2017-01,1,1,,,,https://www.nature.com/natastron,,4bbb0,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P,invalid_column_data'
        )
    };

    my ( $column_headers, $lines ) = Koha::BackgroundJob::ImportKBARTFile::read_file($file);
    my @invalid_columns = ('invalid_column');

    my $title_from_line1 = Koha::BackgroundJob::ImportKBARTFile::create_title_hash_from_line_data(
        @{$lines}[0], $column_headers,
        \@invalid_columns
    );
    my $title_from_line2 = Koha::BackgroundJob::ImportKBARTFile::create_title_hash_from_line_data(
        @{$lines}[1], $column_headers,
        \@invalid_columns
    );

    my $line1_match = {
        'coverage_depth'                  => 'fulltext',
        'date_monograph_published_print'  => '',
        'date_first_issue_online'         => '2015-01',
        'date_last_issue_online'          => '',
        'coverage_notes'                  => 'Hybrid (Open Choice)',
        'first_editor'                    => '',
        'date_monograph_published_online' => '',
        'preceding_publication_title_id'  => '',
        'num_last_issue_online'           => '',
        'embargo_info'                    => '',
        'access_type'                     => 'P',
        'num_first_issue_online'          => '1',
        'online_identifier'               => '2055-0278',
        'title_url'                       => 'https://www.nature.com/nplants',
        'monograph_volume'                => '',
        'first_author'                    => '',
        'parent_publication_title_id'     => '',
        'num_last_vol_online'             => '',
        'publication_title'               => 'Nature Plants',
        'num_first_vol_online'            => '1',
        'print_identifier'                => '',
        'publisher_name'                  => 'Nature Publishing Group UK',
        'title_id'                        => '4aaa7',
        'publication_type'                => 'serial',
        'monograph_edition'               => ''
    };
    my $line2_match = {
        'date_monograph_published_online' => '',
        'num_first_vol_online'            => '1',
        'num_last_issue_online'           => '',
        'preceding_publication_title_id'  => '',
        'title_url'                       => 'https://www.nature.com/natastron',
        'online_identifier'               => '2397-3366',
        'print_identifier'                => '',
        'num_last_vol_online'             => '',
        'embargo_info'                    => '',
        'parent_publication_title_id'     => '',
        'publisher_name'                  => 'Nature Publishing Group UK',
        'date_first_issue_online'         => '2017-01',
        'monograph_volume'                => '',
        'monograph_edition'               => '',
        'access_type'                     => 'P',
        'first_author'                    => '',
        'num_first_issue_online'          => '1',
        'first_editor'                    => '',
        'publication_title'               => 'Nature Astronomy',
        'date_monograph_published_print'  => '',
        'publication_type'                => 'serial',
        'title_id'                        => '4bbb0',
        'coverage_depth'                  => 'fulltext',
        'coverage_notes'                  => 'Hybrid (Open Choice)',
        'date_last_issue_online'          => ''
    };

    is_deeply( $title_from_line1, $line1_match, 'Title hash created correctly' );
    is_deeply( $title_from_line2, $line2_match, 'Title hash created correctly' );
};

subtest 'process' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    Koha::ERM::EHoldings::Packages->search->delete;
    my $ehpackage = $builder->build_object(
        {
            class => 'Koha::ERM::EHoldings::Packages',
            value => { external_id => undef }
        }
    );

    my $file = {
        filename     => 'Test_file.csv',
        file_content => encode_base64(
            'publication_title,print_identifier,online_identifier,date_first_issue_online,num_first_vol_online,num_first_issue_online,date_last_issue_online,num_last_vol_online,num_last_issue_online,title_url,first_author,title_id,embargo_info,coverage_depth,coverage_notes,publisher_name,publication_type,date_monograph_published_print,date_monograph_published_online,monograph_volume,monograph_edition,first_editor,parent_publication_title_id,preceding_publication_title_id,access_type
Nature Plants,,2055-0278,2015-01,1,1,,,,https://www.nature.com/nplants,,4aaa7,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P
Nature Astronomy,,2397-3366,2017-01,1,1,,,,https://www.nature.com/natastron,,4bbb0,,fulltext,Hybrid (Open Choice),Nature Publishing Group UK,serial,,,,,,,,P'
        )
    };

    my ( $column_headers, $rows, $error ) = Koha::BackgroundJob::ImportKBARTFile::read_file($file);
    my $data = {
        column_headers => $column_headers,
        rows           => $rows,
        package_id     => $ehpackage->package_id,
        file_name      => $file->{filename}
    };

    my $job = Koha::BackgroundJob::ImportKBARTFile->new(
        {
            status => 'new',
            type   => 'import_from_kbart_file',
            size   => 1,
        }
    )->store;
    $job = Koha::BackgroundJobs->find( $job->id );
    my $json = $job->json->encode($data);
    $job->data($json)->store;
    $job->process($data);

    is( $job->report->{titles_imported}, 2, 'Two titles successfully imported' );

    my $job2 = Koha::BackgroundJob::ImportKBARTFile->new(
        {
            status => 'new',
            type   => 'import_from_kbart_file',
            size   => 1,
        }
    )->store;
    $job2 = Koha::BackgroundJobs->find( $job2->id );
    $job2->data($json)->store;
    $job2->process($data);

    is( $job2->report->{duplicates_found}, 2, 'Two duplicates found, no titles should be imported' );
    is( $job2->report->{titles_imported},  0, 'No titles were imported' );
    is_deeply(
        $job2->messages,
        [
            {
                'type'          => 'warning',
                'title'         => 'Nature Plants',
                'code'          => 'title_already_exists',
                'error_message' => undef
            },
            {
                'error_message' => undef,
                'code'          => 'title_already_exists',
                'title'         => 'Nature Astronomy',
                'type'          => 'warning'
            }
        ],
        'Two duplicate messages added'
    );

    my $module = Test::MockModule->new('Koha::BackgroundJob::ImportKBARTFile');
    $module->mock(
        'create_title_hash_from_line_data',
        sub {
            my ( $row, $column_headers ) = @_;

            my %new_title;

            @new_title{ @{$column_headers} } = @$row;

            # If the file has been converted from CSV to TSV for import, then some titles containing commas will be enclosed in ""
            my $first_char = substr( $new_title{publication_title}, 0, 1 );
            my $last_char  = substr( $new_title{publication_title}, -1 );
            if ( $first_char eq '"' && $last_char eq '"' ) {
                $new_title{publication_title} =~ s/^"|"$//g;
            }

            $new_title{title_id}          = '12345' if $new_title{publication_title} eq 'Nature Plants';
            $new_title{publication_title} = ''      if $new_title{publication_title} eq 'Nature Plants';

            return \%new_title;
        }
    );

    my $job3 = Koha::BackgroundJob::ImportKBARTFile->new(
        {
            status => 'new',
            type   => 'import_from_kbart_file',
            size   => 1,
        }
    )->store;
    $job3 = Koha::BackgroundJobs->find( $job3->id );
    $job3->data($json)->store;
    $job3->process($data);

    is( $job3->report->{duplicates_found}, 1, 'One duplicate found' );
    is( $job3->report->{titles_imported},  0, 'No titles were imported' );
    is( $job3->report->{failed_imports},   1, 'One failure found' );
    is_deeply(
        $job3->messages,
        [
            {
                'type'     => 'error',
                'code'     => 'no_title_found',
                'title_id' => '12345',
                'title'    => '(Unknown)'
            },
            {
                'code'          => 'title_already_exists',
                'title'         => 'Nature Astronomy',
                'error_message' => undef,
                'type'          => 'warning'
            }
        ],
        'One duplicate message and one failure message for a missing title'
    );

    $module->mock(
        'create_title_hash_from_line_data',
        sub {
            my ( $row, $column_headers ) = @_;

            my %new_title;

            @new_title{ @{$column_headers} } = @$row;

            # If the file has been converted from CSV to TSV for import, then some titles containing commas will be enclosed in ""
            my $first_char = substr( $new_title{publication_title}, 0, 1 );
            my $last_char  = substr( $new_title{publication_title}, -1 );
            if ( $first_char eq '"' && $last_char eq '"' ) {
                $new_title{publication_title} =~ s/^"|"$//g;
            }

            $new_title{title_id}      = 'abcde' if $new_title{publication_title} eq 'Nature Plants';
            $new_title{unknown_field} = ''      if $new_title{publication_title} eq 'Nature Plants';

            return \%new_title;
        }
    );

    my $job4 = Koha::BackgroundJob::ImportKBARTFile->new(
        {
            status => 'new',
            type   => 'import_from_kbart_file',
            size   => 1,
        }
    )->store;
    $job4 = Koha::BackgroundJobs->find( $job4->id );
    $job4->data($json)->store;
    $job4->process($data);

    is( $job4->report->{duplicates_found}, 1, 'One duplicate found' );
    is( $job4->report->{titles_imported},  0, 'No titles were imported' );
    is( $job4->report->{failed_imports},   1, 'One failure found' );

    is(
        index( @{ $job4->messages }[0]->{error_message}, 'No such column \'unknown_field\'' ) > 0, 1,
        'Error message for an unknown column'
    );
    is( @{ $job4->messages }[1]->{code}, 'title_already_exists', 'Error message for a duplicate title' );

    $schema->storage->txn_rollback;
    }
