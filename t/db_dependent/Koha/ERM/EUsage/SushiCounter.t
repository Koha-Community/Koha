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
use Test::More tests => 19;

use Koha::ERM::EUsage::SushiCounter;
use Koha::Database;
use JSON           qw( decode_json );
use File::Basename qw( dirname );
use File::Slurp;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $sushi_response_file_TR_J1      = dirname(__FILE__) . "/../../../data/erm/eusage/TR_J1.json";
my $sushi_counter_5_response_TR_J1 = decode_json( read_file($sushi_response_file_TR_J1) );
my $sushi_counter_TR_J1 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_5_response_TR_J1 } );

subtest 'TR_J1 _COUNTER_report_header' => sub {

    plan tests => 37;

    my @report_header = $sushi_counter_TR_J1->_COUNTER_report_header;

    # Header row #1 - Report_Name
    is( $report_header[0][0], 'Report_Name',                          '1st row is report name' );
    is( $report_header[0][1], 'Journal Requests (Excluding OA_Gold)', '1st row is report name' );
    is( $report_header[0][2], undef,                                  '1st row is report name' );

    # Header row #2 - Report_ID
    is( $report_header[1][0], 'Report_ID', '2nd row is report name' );
    is( $report_header[1][1], 'TR_J1',     '2nd row is report name' );
    is( $report_header[1][2], undef,       '2nd row is report name' );

    # Header row #3 - Release
    is( $report_header[2][0], 'Release', '3rd row is counter release' );
    is( $report_header[2][1], '5',       '3rd row is counter release' );
    is( $report_header[2][2], undef,     '3rd row is counter release' );

    # Header row #4 - Institution_Name
    is( $report_header[3][0], 'Institution_Name', '4th row is institution name' );
    is( $report_header[3][1], 'Test Institution', '4th row is institution name' );
    is( $report_header[3][2], undef,              '4th row is institution name' );

    # Header row #5 - Institution_ID
    is( $report_header[4][0], 'Institution_ID',                                       '5th row is institution id' );
    is( $report_header[4][1], 'Proprietary:TInsti:EALTEST001; ISNI:0000000123456789', '5th row is institution id' );
    is( $report_header[4][2], undef,                                                  '5th row is institution id' );

    # Header row #6 - Metric_Types
    is( $report_header[5][0], 'Metric_Types',                              '6th row is metric types' );
    is( $report_header[5][1], 'Total_Item_Requests; Unique_Item_Requests', '6th row is metric types' );
    is( $report_header[5][2], undef,                                       '6th row is metric types' );

    # Header row #7 - Report_Filters
    is( $report_header[6][0], 'Report_Filters', '7th row is report filters' );
    is(
        $report_header[6][1],
        'End_Date:2022-09-30; Access_Method:Regular; Metric_Type:Total_Item_Requests|Unique_Item_Requests; Data_Type:Journal; Begin_Date:2021-09-01; Access_Type:Controlled',
        '7th row is report filters'
    );
    is( $report_header[6][2], undef, '7th row is report filters' );

    # Header row #8 - Report_Attributes
    is( $report_header[7][0], 'Report_Attributes', '8th row is report attributes' );
    is( $report_header[7][1], '',                  '8th row is report attributes' );
    is( $report_header[7][2], undef,               '8th row is report attributes' );

    # Header row #9 - Exceptions
    is( $report_header[8][0], 'Exceptions', '9th row is exceptions' );
    is( $report_header[8][1], '',           '9th row is exceptions' );
    is( $report_header[8][2], undef,        '9th row is exceptions' );

    # Header row #10 - Reporting_Period
    is( $report_header[9][0], 'Reporting_Period',                           '10th row is reporting period' );
    is( $report_header[9][1], 'Begin_Date=2021-09-01; End_Date=2022-09-30', '10th row is reporting period' );
    is( $report_header[9][2], undef,                                        '10th row is reporting period' );

    # Header row #11 - Created
    is( $report_header[10][0], 'Created',              '11th row is created' );
    is( $report_header[10][1], '2023-08-29T07:11:41Z', '11th row is created' );
    is( $report_header[10][2], undef,                  '11th row is created' );

    # Header row #12 - Created
    is( $report_header[11][0], 'Created_By',        '12th row is created by' );
    is( $report_header[11][1], 'Test Systems Inc.', '12th row is created by' );
    is( $report_header[11][2], undef,               '12th row is created by' );

    # Header row #13 - This needs to be empty
    is( $report_header[12][0], '', '13th row is empty' );
};

subtest 'TR_J1 _COUNTER_report_column_headings' => sub {

    plan tests => 19;

    my @report_column_headings = $sushi_counter_TR_J1->_COUNTER_report_column_headings;

    # Standard TR_J1 column headings
    is( $report_column_headings[0][0],  'Title',                  '1st column heading is title' );
    is( $report_column_headings[0][1],  'Publisher',              '2nd column heading is publisher' );
    is( $report_column_headings[0][2],  'Publisher_ID',           '3rd column heading is publisher ID' );
    is( $report_column_headings[0][3],  'Platform',               '4th column heading is platform' );
    is( $report_column_headings[0][4],  'DOI',                    '5th column heading is DOI' );
    is( $report_column_headings[0][5],  'Proprietary_ID',         '6th column heading is proprietary ID' );
    is( $report_column_headings[0][6],  'Print_ISSN',             '7th column heading is print ISSN' );
    is( $report_column_headings[0][7],  'Online_ISSN',            '8th column heading is online ISSN' );
    is( $report_column_headings[0][8],  'URI',                    '9th column heading is URI' );
    is( $report_column_headings[0][9],  'Metric_Type',            '10th column heading is metric type' );
    is( $report_column_headings[0][10], 'Reporting_Period_Total', '11th column heading is reporting period total' );

    # Months column headings
    is( $report_column_headings[0][11], 'Sep 2021', '12th column is month column heading' );
    is( $report_column_headings[0][12], 'Oct 2021', '13th column is month column heading' );
    is( $report_column_headings[0][13], 'Nov 2021', '14th column is month column heading' );
    is( $report_column_headings[0][14], 'Dec 2021', '15th column is month column heading' );
    is( $report_column_headings[0][15], 'Jan 2022', '16th column is month column heading' );
    is( $report_column_headings[0][16], 'Feb 2022', '17th column is month column heading' );

    # ... period is september 2021 to september 2022, i.e. 13 months
    is( $report_column_headings[0][23], 'Sep 2022', '23rd column is the last month column heading' );
    is( $report_column_headings[0][24], undef,      '24th column is empty, no more months' );
};

subtest 'TR_J1 _COUNTER_report_body' => sub {

    plan tests => 16;

    my @report_body = $sushi_counter_TR_J1->_COUNTER_report_body;

    # The same title is sequential but for different metric types
    is( $report_body[0][0], 'Education and Training', 'same title, different metric type' );
    is( $report_body[1][0], 'Education and Training', 'same title, different metric type' );
    is( $report_body[0][9], 'Total_Item_Requests',    'same title, different metric type' );
    is( $report_body[1][9], 'Unique_Item_Requests',   'same title, different metric type' );

    # The data is in the correct column
    is( $report_body[2][0],  'Test Journal',            '1st column is title' );
    is( $report_body[2][1],  'Test Publisher',          '2nd column is publisher' );
    is( $report_body[2][2],  '0000000123456789',        '3rd column heading is publisher ID' );
    is( $report_body[2][3],  'Unit Test Library',       '4th column is platform' );
    is( $report_body[2][4],  '10.1002/(ISSN)1111-2222', '5th column is DOI' );
    is( $report_body[2][5],  'TInsti:ABC1',             '6th column is proprietary ID' );
    is( $report_body[2][6],  '7777-8888',               '7th column is print ISSN' );
    is( $report_body[2][7],  '5555-6666',               '8th column is online ISSN' );
    is( $report_body[2][8],  '',                        '9th column is URI' );
    is( $report_body[2][9],  'Total_Item_Requests',     '10th column is metric type' );
    is( $report_body[2][10], 2,                         '11th column is reporting period total' );

    # The period total is the sum of all the month columns
    my $stats_total = 0;
    for ( my $i = 11 ; $i < 24 ; $i++ ) {
        $stats_total += $report_body[0][$i];
    }
    is(
        $report_body[0][10], $stats_total,
        'Reporting period total matches the sum of all the monthly usage statistics'
    );
};

my $sushi_response_file_TR_J2      = dirname(__FILE__) . "/../../../data/erm/eusage/TR_J2.json";
my $sushi_counter_5_response_TR_J2 = decode_json( read_file($sushi_response_file_TR_J2) );
my $sushi_counter_TR_J2 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_5_response_TR_J2 } );

subtest 'TR_J2 _COUNTER_report_header' => sub {

    plan tests => 37;

    my @report_header = $sushi_counter_TR_J2->_COUNTER_report_header;

    # Header row #1 - Report_Name
    is( $report_header[0][0], 'Report_Name',           '1st row is report name' );
    is( $report_header[0][1], 'Journal Access Denied', '1st row is report name' );
    is( $report_header[0][2], undef,                   '1st row is report name' );

    # Header row #2 - Report_ID
    is( $report_header[1][0], 'Report_ID', '2nd row is report name' );
    is( $report_header[1][1], 'TR_J2',     '2nd row is report name' );
    is( $report_header[1][2], undef,       '2nd row is report name' );

    # Header row #3 - Release
    is( $report_header[2][0], 'Release', '3rd row is counter release' );
    is( $report_header[2][1], '5',       '3rd row is counter release' );
    is( $report_header[2][2], undef,     '3rd row is counter release' );

    # Header row #4 - Institution_Name
    is( $report_header[3][0], 'Institution_Name', '4th row is institution name' );
    is( $report_header[3][1], 'Test Institution', '4th row is institution name' );
    is( $report_header[3][2], undef,              '4th row is institution name' );

    # Header row #5 - Institution_ID
    is( $report_header[4][0], 'Institution_ID',            '5th row is institution id' );
    is( $report_header[4][1], 'Proprietary:aaaa:99999999', '5th row is institution id' );
    is( $report_header[4][2], undef,                       '5th row is institution id' );

    # Header row #6 - Metric_Types
    is( $report_header[5][0], 'Metric_Types',               '6th row is metric types' );
    is( $report_header[5][1], 'Limit_Exceeded; No_License', '6th row is metric types' );
    is( $report_header[5][2], undef,                        '6th row is metric types' );

    # Header row #7 - Report_Filters
    is( $report_header[6][0], 'Report_Filters', '7th row is report filters' );
    is(
        $report_header[6][1],
        'Data_Type:Journal; End_Date:2023-09-30; Access_Method:Regular; Metric_Type:Limit_Exceeded|No_License; Begin_Date:2023-08-01',
        '7th row is report filters'
    );
    is( $report_header[6][2], undef, '7th row is report filters' );

    # Header row #8 - Report_Attributes
    is( $report_header[7][0], 'Report_Attributes', '8th row is report attributes' );
    is( $report_header[7][1], '',                  '8th row is report attributes' );
    is( $report_header[7][2], undef,               '8th row is report attributes' );

    # Header row #9 - Exceptions
    is( $report_header[8][0], 'Exceptions', '9th row is exceptions' );
    is( $report_header[8][1], '',           '9th row is exceptions' );
    is( $report_header[8][2], undef,        '9th row is exceptions' );

    # Header row #10 - Reporting_Period
    is( $report_header[9][0], 'Reporting_Period',                           '10th row is reporting period' );
    is( $report_header[9][1], 'Begin_Date=2023-08-01; End_Date=2023-09-30', '10th row is reporting period' );
    is( $report_header[9][2], undef,                                        '10th row is reporting period' );

    # Header row #11 - Created
    is( $report_header[10][0], 'Created',              '11th row is created' );
    is( $report_header[10][1], '2023-10-23T07:27:10Z', '11th row is created' );
    is( $report_header[10][2], undef,                  '11th row is created' );

    # Header row #12 - Created
    is( $report_header[11][0], 'Created_By',        '12th row is created by' );
    is( $report_header[11][1], 'Test Systems Inc.', '12th row is created by' );
    is( $report_header[11][2], undef,               '12th row is created by' );

    # Header row #13 - This needs to be empty
    is( $report_header[12][0], '', '13th row is empty' );
};

subtest 'TR_J2 _COUNTER_report_column_headings' => sub {

    plan tests => 14;

    my @report_column_headings = $sushi_counter_TR_J2->_COUNTER_report_column_headings;

    # Standard TR_J2 column headings
    is( $report_column_headings[0][0],  'Title',                  '1st column heading is title' );
    is( $report_column_headings[0][1],  'Publisher',              '2nd column heading is publisher' );
    is( $report_column_headings[0][2],  'Publisher_ID',           '3rd column heading is publisher ID' );
    is( $report_column_headings[0][3],  'Platform',               '4th column heading is platform' );
    is( $report_column_headings[0][4],  'DOI',                    '5th column heading is DOI' );
    is( $report_column_headings[0][5],  'Proprietary_ID',         '6th column heading is proprietary ID' );
    is( $report_column_headings[0][6],  'Print_ISSN',             '7th column heading is print ISSN' );
    is( $report_column_headings[0][7],  'Online_ISSN',            '8th column heading is online ISSN' );
    is( $report_column_headings[0][8],  'URI',                    '9th column heading is URI' );
    is( $report_column_headings[0][9],  'Metric_Type',            '10th column heading is metric type' );
    is( $report_column_headings[0][10], 'Reporting_Period_Total', '11th column heading is reporting period total' );

    # Months column headings
    is( $report_column_headings[0][11], 'Aug 2023', '12th column is month column heading' );
    is( $report_column_headings[0][12], 'Sep 2023', '13th column is the last month column heading' );
    is( $report_column_headings[0][13], undef,      '14th column is empty, no more months' );
};

subtest 'TR_J2 _COUNTER_report_body' => sub {

    plan tests => 16;

    my @report_body = $sushi_counter_TR_J2->_COUNTER_report_body;

    # The same title is sequential but for different metric types
    is( $report_body[0][0], 'ACS Applied Materials & Interfaces', 'different title, same metric type' );
    is( $report_body[1][0], 'ACS Chemical Biology',               'different title, same metric type' );
    is( $report_body[0][9], 'No_License', '1st title, same metric_type because there is only one' );
    is( $report_body[1][9], 'No_License', '2nd title, same metric_type because there is only one' );

    # The data is in the correct column
    is( $report_body[2][0],  'ACS Chemical Health & Safety', '1st column is title' );
    is( $report_body[2][1],  'Test Publisher',               '2nd column is publisher' );
    is( $report_body[2][2],  '',                             '3rd column heading is publisher ID' );
    is( $report_body[2][3],  'Unit Test Library',            '4th column is platform' );
    is( $report_body[2][4],  '10.1021/aaaac5',               '5th column is DOI' );
    is( $report_body[2][5],  'aaaa:aaaac5',                  '6th column is proprietary ID' );
    is( $report_body[2][6],  '',                             '7th column is print ISSN' );
    is( $report_body[2][7],  '1878-0504',                    '8th column is online ISSN' );
    is( $report_body[2][8],  '',                             '9th column is URI' );
    is( $report_body[2][9],  'No_License',                   '10th column is metric type' );
    is( $report_body[2][10], 2,                              '11th column is reporting period total' );

    # The period total is the sum of all the month columns
    my $stats_total = 0;
    for ( my $i = 11 ; $i < 13 ; $i++ ) {
        $stats_total += $report_body[0][$i];
    }
    is(
        $report_body[0][10], $stats_total,
        'Reporting period total matches the sum of all the monthly usage statistics'
    );
};

my $sushi_response_file_TR_J3      = dirname(__FILE__) . "/../../../data/erm/eusage/TR_J3.json";
my $sushi_counter_5_response_TR_J3 = decode_json( read_file($sushi_response_file_TR_J3) );
my $sushi_counter_TR_J3 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_5_response_TR_J3 } );

subtest 'TR_J3 _COUNTER_report_header' => sub {

    plan tests => 37;

    my @report_header = $sushi_counter_TR_J3->_COUNTER_report_header;

    # Header row #1 - Report_Name
    is( $report_header[0][0], 'Report_Name',                  '1st row is report name' );
    is( $report_header[0][1], 'Journal Usage by Access Type', '1st row is report name' );
    is( $report_header[0][2], undef,                          '1st row is report name' );

    # Header row #2 - Report_ID
    is( $report_header[1][0], 'Report_ID', '2nd row is report name' );
    is( $report_header[1][1], 'TR_J3',     '2nd row is report name' );
    is( $report_header[1][2], undef,       '2nd row is report name' );

    # Header row #3 - Release
    is( $report_header[2][0], 'Release', '3rd row is counter release' );
    is( $report_header[2][1], '5',       '3rd row is counter release' );
    is( $report_header[2][2], undef,     '3rd row is counter release' );

    # Header row #4 - Institution_Name
    is( $report_header[3][0], 'Institution_Name', '4th row is institution name' );
    is( $report_header[3][1], 'Test Institution', '4th row is institution name' );
    is( $report_header[3][2], undef,              '4th row is institution name' );

    # Header row #5 - Institution_ID
    is( $report_header[4][0], 'Institution_ID',            '5th row is institution id' );
    is( $report_header[4][1], 'Proprietary:aaaa:99999999', '5th row is institution id' );
    is( $report_header[4][2], undef,                       '5th row is institution id' );

    # Header row #6 - Metric_Types
    is( $report_header[5][0], 'Metric_Types', '6th row is metric types' );
    is(
        $report_header[5][1],
        'Total_Item_Investigations; Total_Item_Requests; Unique_Item_Investigations; Unique_Item_Requests',
        '6th row is metric types'
    );
    is( $report_header[5][2], undef, '6th row is metric types' );

    # Header row #7 - Report_Filters
    is( $report_header[6][0], 'Report_Filters', '7th row is report filters' );
    is(
        $report_header[6][1],
        'Metric_Type:Total_Item_Investigations|Total_Item_Requests|Unique_Item_Investigations|Unique_Item_Requests; Access_Method:Regular; End_Date:2023-09-30; Data_Type:Journal; Begin_Date:2023-08-01',
        '7th row is report filters'
    );
    is( $report_header[6][2], undef, '7th row is report filters' );

    # Header row #8 - Report_Attributes
    is( $report_header[7][0], 'Report_Attributes', '8th row is report attributes' );
    is( $report_header[7][1], '',                  '8th row is report attributes' );
    is( $report_header[7][2], undef,               '8th row is report attributes' );

    # Header row #9 - Exceptions
    is( $report_header[8][0], 'Exceptions', '9th row is exceptions' );
    is( $report_header[8][1], '',           '9th row is exceptions' );
    is( $report_header[8][2], undef,        '9th row is exceptions' );

    # Header row #10 - Reporting_Period
    is( $report_header[9][0], 'Reporting_Period',                           '10th row is reporting period' );
    is( $report_header[9][1], 'Begin_Date=2023-08-01; End_Date=2023-09-30', '10th row is reporting period' );
    is( $report_header[9][2], undef,                                        '10th row is reporting period' );

    # Header row #11 - Created
    is( $report_header[10][0], 'Created',              '11th row is created' );
    is( $report_header[10][1], '2023-10-23T07:59:08Z', '11th row is created' );
    is( $report_header[10][2], undef,                  '11th row is created' );

    # Header row #12 - Created
    is( $report_header[11][0], 'Created_By',        '12th row is created by' );
    is( $report_header[11][1], 'Test Systems Inc.', '12th row is created by' );
    is( $report_header[11][2], undef,               '12th row is created by' );

    # Header row #13 - This needs to be empty
    is( $report_header[12][0], '', '13th row is empty' );
};

subtest 'TR_J3 _COUNTER_report_column_headings' => sub {

    plan tests => 15;

    my @report_column_headings = $sushi_counter_TR_J3->_COUNTER_report_column_headings;

    # Standard TR_J3 column headings
    is( $report_column_headings[0][0],  'Title',                  '1st column heading is title' );
    is( $report_column_headings[0][1],  'Publisher',              '2nd column heading is publisher' );
    is( $report_column_headings[0][2],  'Publisher_ID',           '3rd column heading is publisher ID' );
    is( $report_column_headings[0][3],  'Platform',               '4th column heading is platform' );
    is( $report_column_headings[0][4],  'DOI',                    '5th column heading is DOI' );
    is( $report_column_headings[0][5],  'Proprietary_ID',         '6th column heading is proprietary ID' );
    is( $report_column_headings[0][6],  'Print_ISSN',             '7th column heading is print ISSN' );
    is( $report_column_headings[0][7],  'Online_ISSN',            '8th column heading is online ISSN' );
    is( $report_column_headings[0][8],  'URI',                    '9th column heading is URI' );
    is( $report_column_headings[0][9],  'Access_Type',            '10th column heading is access type' );
    is( $report_column_headings[0][10], 'Metric_Type',            '11th column heading is access type' );
    is( $report_column_headings[0][11], 'Reporting_Period_Total', '12th column heading is reporting period total' );

    # Months column headings
    is( $report_column_headings[0][12], 'Aug 2023', '12th column is month column heading' );
    is( $report_column_headings[0][13], 'Sep 2023', '13th column is the last month column heading' );
    is( $report_column_headings[0][24], undef,      '14th column is empty, no more months' );
};

subtest 'TR_J3 _COUNTER_report_body' => sub {

    plan tests => 25;

    my @report_body = $sushi_counter_TR_J3->_COUNTER_report_body;

    # The same title is sequential but for different metric types
    is( $report_body[0][0],  'TEST Applied Energy Materials', 'same title, different metric type' );
    is( $report_body[1][0],  'TEST Applied Energy Materials', 'same title, different metric type' );
    is( $report_body[2][0],  'TEST Applied Energy Materials', 'same title, different metric type' );
    is( $report_body[3][0],  'TEST Applied Energy Materials', 'same title, different metric type' );
    is( $report_body[0][9],  'OA_Gold',                       'same title, same access_type' );
    is( $report_body[1][9],  'OA_Gold',                       'same title, same access_type' );
    is( $report_body[2][9],  'OA_Gold',                       'same title, same access_type' );
    is( $report_body[3][9],  'OA_Gold',                       'same title, same access_type' );
    is( $report_body[0][10], 'Total_Item_Requests',           'same title, different metric type' );
    is( $report_body[1][10], 'Unique_Item_Requests',          'same title, different metric type' );
    is( $report_body[2][10], 'Unique_Item_Investigations',    'same title, different metric type' );
    is( $report_body[3][10], 'Total_Item_Investigations',     'same title, different metric type' );

    # The data is in the correct column
    is( $report_body[2][0],  'TEST Applied Energy Materials', '1st column is title' );
    is( $report_body[2][1],  'Test Publisher',                '2nd column is publisher' );
    is( $report_body[2][2],  '',                              '3rd column heading is publisher ID' );
    is( $report_body[2][3],  'TEST',                          '4th column is platform' );
    is( $report_body[2][4],  '10.1021/aaemcq',                '5th column is DOI' );
    is( $report_body[2][5],  'aaaa:aaemcq',                   '6th column is proprietary ID' );
    is( $report_body[2][6],  '',                              '7th column is print ISSN' );
    is( $report_body[2][7],  '2574-0962',                     '8th column is online ISSN' );
    is( $report_body[2][8],  '',                              '9th column is URI' );
    is( $report_body[2][9],  'OA_Gold',                       '10th column is access type' );
    is( $report_body[2][10], 'Unique_Item_Investigations',    '10th column is metric type' );
    is( $report_body[2][11], 3,                               '11th column is reporting period total' );

    # The period total is the sum of all the month columns
    my $stats_total = 0;
    for ( my $i = 12 ; $i < 14 ; $i++ ) {
        $stats_total += $report_body[0][$i];
    }
    is(
        $report_body[0][11], $stats_total,
        'Reporting period total matches the sum of all the monthly usage statistics'
    );
};

my $sushi_response_file_TR_J4      = dirname(__FILE__) . "/../../../data/erm/eusage/TR_J4.json";
my $sushi_counter_5_response_TR_J4 = decode_json( read_file($sushi_response_file_TR_J4) );
my $sushi_counter_TR_J4 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_5_response_TR_J4 } );

subtest 'TR_J4 _COUNTER_report_header' => sub {

    plan tests => 37;

    my @report_header = $sushi_counter_TR_J4->_COUNTER_report_header;

    # Header row #1 - Report_Name
    is( $report_header[0][0], 'Report_Name',                                 '1st row is report name' );
    is( $report_header[0][1], 'Journal Requests by YOP (Excluding OA_Gold)', '1st row is report name' );
    is( $report_header[0][2], undef,                                         '1st row is report name' );

    # Header row #2 - Report_ID
    is( $report_header[1][0], 'Report_ID', '2nd row is report name' );
    is( $report_header[1][1], 'TR_J4',     '2nd row is report name' );
    is( $report_header[1][2], undef,       '2nd row is report name' );

    # Header row #3 - Release
    is( $report_header[2][0], 'Release', '3rd row is counter release' );
    is( $report_header[2][1], '5',       '3rd row is counter release' );
    is( $report_header[2][2], undef,     '3rd row is counter release' );

    # Header row #4 - Institution_Name
    is( $report_header[3][0], 'Institution_Name', '4th row is institution name' );
    is( $report_header[3][1], 'Test Institution', '4th row is institution name' );
    is( $report_header[3][2], undef,              '4th row is institution name' );

    # Header row #5 - Institution_ID
    is( $report_header[4][0], 'Institution_ID',            '5th row is institution id' );
    is( $report_header[4][1], 'Proprietary:aaaa:99999999', '5th row is institution id' );
    is( $report_header[4][2], undef,                       '5th row is institution id' );

    # Header row #6 - Metric_Types
    is( $report_header[5][0], 'Metric_Types', '6th row is metric types' );
    is(
        $report_header[5][1],
        'Total_Item_Requests; Unique_Item_Requests',
        '6th row is metric types'
    );
    is( $report_header[5][2], undef, '6th row is metric types' );

    # Header row #7 - Report_Filters
    is( $report_header[6][0], 'Report_Filters', '7th row is report filters' );
    is(
        $report_header[6][1],
        'Metric_Type:Total_Item_Requests|Unique_Item_Requests; Access_Method:Regular; Begin_Date:2023-08-01; Access_Type:Controlled; End_Date:2023-09-30; Data_Type:Journal',
        '7th row is report filters'
    );
    is( $report_header[6][2], undef, '7th row is report filters' );

    # Header row #8 - Report_Attributes
    is( $report_header[7][0], 'Report_Attributes', '8th row is report attributes' );
    is( $report_header[7][1], '',                  '8th row is report attributes' );
    is( $report_header[7][2], undef,               '8th row is report attributes' );

    # Header row #9 - Exceptions
    is( $report_header[8][0], 'Exceptions', '9th row is exceptions' );
    is( $report_header[8][1], '',           '9th row is exceptions' );
    is( $report_header[8][2], undef,        '9th row is exceptions' );

    # Header row #10 - Reporting_Period
    is( $report_header[9][0], 'Reporting_Period',                           '10th row is reporting period' );
    is( $report_header[9][1], 'Begin_Date=2023-08-01; End_Date=2023-09-30', '10th row is reporting period' );
    is( $report_header[9][2], undef,                                        '10th row is reporting period' );

    # Header row #11 - Created
    is( $report_header[10][0], 'Created',              '11th row is created' );
    is( $report_header[10][1], '2023-10-23T08:41:45Z', '11th row is created' );
    is( $report_header[10][2], undef,                  '11th row is created' );

    # Header row #12 - Created
    is( $report_header[11][0], 'Created_By',        '12th row is created by' );
    is( $report_header[11][1], 'Test Systems Inc.', '12th row is created by' );
    is( $report_header[11][2], undef,               '12th row is created by' );

    # Header row #13 - This needs to be empty
    is( $report_header[12][0], '', '13th row is empty' );
};

subtest 'TR_J4 _COUNTER_report_column_headings' => sub {

    plan tests => 15;

    my @report_column_headings = $sushi_counter_TR_J4->_COUNTER_report_column_headings;

    # Standard TR_J4 column headings
    is( $report_column_headings[0][0],  'Title',                  '1st column heading is title' );
    is( $report_column_headings[0][1],  'Publisher',              '2nd column heading is publisher' );
    is( $report_column_headings[0][2],  'Publisher_ID',           '3rd column heading is publisher ID' );
    is( $report_column_headings[0][3],  'Platform',               '4th column heading is platform' );
    is( $report_column_headings[0][4],  'DOI',                    '5th column heading is DOI' );
    is( $report_column_headings[0][5],  'Proprietary_ID',         '6th column heading is proprietary ID' );
    is( $report_column_headings[0][6],  'Print_ISSN',             '7th column heading is print ISSN' );
    is( $report_column_headings[0][7],  'Online_ISSN',            '8th column heading is online ISSN' );
    is( $report_column_headings[0][8],  'URI',                    '9th column heading is URI' );
    is( $report_column_headings[0][9],  'YOP',                    '10th column heading is yop' );
    is( $report_column_headings[0][10], 'Metric_Type',            '11th column heading is metric type' );
    is( $report_column_headings[0][11], 'Reporting_Period_Total', '12th column heading is reporting period total' );

    # Months column headings
    is( $report_column_headings[0][12], 'Aug 2023', '13th column is month column heading' );
    is( $report_column_headings[0][13], 'Sep 2023', '14th column is the last month column heading' );
    is( $report_column_headings[0][14], undef,      '15th column is empty, no more months' );
};

subtest 'TR_J4 _COUNTER_report_body' => sub {

    plan tests => 25;

    my @report_body = $sushi_counter_TR_J4->_COUNTER_report_body;

    # The same title is sequential but for different metric types
    is( $report_body[0][0],  'TEST Infectious Diseases', 'same title, different metric type' );
    is( $report_body[1][0],  'TEST Infectious Diseases', 'same title, different metric type' );
    is( $report_body[2][0],  'TEST Infectious Diseases', 'same title, different metric type' );
    is( $report_body[3][0],  'TEST Infectious Diseases', 'same title, different metric type' );
    is( $report_body[0][10], 'Unique_Item_Requests',     '1st title, same yop' );
    is( $report_body[1][10], 'Total_Item_Requests',      '1st title, same yop' );
    is( $report_body[2][10], 'Unique_Item_Requests',     '1st title, same yop' );
    is( $report_body[3][10], 'Total_Item_Requests',      '1st title, same yop' );
    is( $report_body[0][9],  '2021',                     '1st title, yop' );
    is( $report_body[1][9],  '2021',                     '1st title, yop' );
    is( $report_body[2][9],  '2022',                     '1st title,yop' );
    is( $report_body[3][9],  '2022',                     '1st title, yop' );

    # The data is in the correct column
    is( $report_body[2][0],  'TEST Infectious Diseases', '1st column is title' );
    is( $report_body[2][1],  'Test Publisher',           '2nd column is publisher' );
    is( $report_body[2][2],  '',                         '3rd column heading is publisher ID' );
    is( $report_body[2][3],  'TEST',                     '4th column is platform' );
    is( $report_body[2][4],  '10.1021/aidcbc',           '5th column is DOI' );
    is( $report_body[2][5],  'aaaa:aidcbc',              '6th column is proprietary ID' );
    is( $report_body[2][6],  '',                         '7th column is print ISSN' );
    is( $report_body[2][7],  '2373-8227',                '8th column is online ISSN' );
    is( $report_body[2][8],  '',                         '9th column is URI' );
    is( $report_body[2][9],  '2022',                     '10th column is yop' );
    is( $report_body[2][10], 'Unique_Item_Requests',     '10th column is metric type' );
    is( $report_body[2][11], 1,                          '11th column is reporting period total' );

    # The period total is the sum of all the month columns
    my $stats_total = 0;
    for ( my $i = 12 ; $i < 14 ; $i++ ) {
        $stats_total += $report_body[0][$i];
    }
    is(
        $report_body[0][11], $stats_total,
        'Reporting period total matches the sum of all the monthly usage statistics'
    );
};

my $sushi_response_file_TR_B3      = dirname(__FILE__) . "/../../../data/erm/eusage/TR_B3.json";
my $sushi_counter_5_response_TR_B3 = decode_json( read_file($sushi_response_file_TR_B3) );
my $sushi_counter_TR_B3 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_5_response_TR_B3 } );

subtest 'TR_B3 _COUNTER_report_header' => sub {

    plan tests => 37;

    my @report_header = $sushi_counter_TR_B3->_COUNTER_report_header;

    # Header row #1 - Report_Name
    is( $report_header[0][0], 'Report_Name',               '1st row is report name' );
    is( $report_header[0][1], 'Book Usage by Access Type', '1st row is report name' );
    is( $report_header[0][2], undef,                       '1st row is report name' );

    # Header row #2 - Report_ID
    is( $report_header[1][0], 'Report_ID', '2nd row is report name' );
    is( $report_header[1][1], 'TR_B3',     '2nd row is report name' );
    is( $report_header[1][2], undef,       '2nd row is report name' );

    # Header row #3 - Release
    is( $report_header[2][0], 'Release', '3rd row is counter release' );
    is( $report_header[2][1], '5',       '3rd row is counter release' );
    is( $report_header[2][2], undef,     '3rd row is counter release' );

    # Header row #4 - Institution_Name
    is( $report_header[3][0], 'Institution_Name', '4th row is institution name' );
    is( $report_header[3][1], 'Test Institution', '4th row is institution name' );
    is( $report_header[3][2], undef,              '4th row is institution name' );

    # Header row #5 - Institution_ID
    is( $report_header[4][0], 'Institution_ID',                  '5th row is institution id' );
    is( $report_header[4][1], 'Proprietary:SN:TEST_CUSTOMER_ID', '5th row is institution id' );
    is( $report_header[4][2], undef,                             '5th row is institution id' );

    # Header row #6 - Metric_Types
    is( $report_header[5][0], 'Metric_Types', '6th row is metric types' );
    is(
        $report_header[5][1],
        'Total_Item_Investigations; Total_Item_Requests; Unique_Item_Investigations; Unique_Item_Requests; Unique_Title_Investigations; Unique_Title_Requests',
        '6th row is metric types'
    );
    is( $report_header[5][2], undef, '6th row is metric types' );

    # Header row #7 - Report_Filters
    is( $report_header[6][0], 'Report_Filters', '7th row is report filters' );
    is(
        $report_header[6][1],
        'Data_Type:Book; Access_Method:Regular; Metric_Type:Total_Item_Investigations|Total_Item_Requests|Unique_Item_Investigations|Unique_Item_Requests|Unique_Title_Investigations|Unique_Title_Requests; Begin_Date:2023-07-01; End_Date:2023-08-31',
        '7th row is report filters'
    );
    is( $report_header[6][2], undef, '7th row is report filters' );

    # Header row #8 - Report_Attributes
    is( $report_header[7][0], 'Report_Attributes', '8th row is report attributes' );
    is( $report_header[7][1], '',                  '8th row is report attributes' );
    is( $report_header[7][2], undef,               '8th row is report attributes' );

    # Header row #9 - Exceptions
    is( $report_header[8][0], 'Exceptions', '9th row is exceptions' );
    is( $report_header[8][1], '',           '9th row is exceptions' );
    is( $report_header[8][2], undef,        '9th row is exceptions' );

    # Header row #10 - Reporting_Period
    is( $report_header[9][0], 'Reporting_Period',                           '10th row is reporting period' );
    is( $report_header[9][1], 'Begin_Date=2023-07-01; End_Date=2023-08-31', '10th row is reporting period' );
    is( $report_header[9][2], undef,                                        '10th row is reporting period' );

    # Header row #11 - Created
    is( $report_header[10][0], 'Created',              '11th row is created' );
    is( $report_header[10][1], '2023-10-26T14:43:51Z', '11th row is created' );
    is( $report_header[10][2], undef,                  '11th row is created' );

    # Header row #12 - Created
    is( $report_header[11][0], 'Created_By',        '12th row is created by' );
    is( $report_header[11][1], 'Test Systems Inc.', '12th row is created by' );
    is( $report_header[11][2], undef,               '12th row is created by' );

    # Header row #13 - This needs to be empty
    is( $report_header[12][0], '', '13th row is empty' );
};

subtest 'TR_B3 _COUNTER_report_column_headings' => sub {

    plan tests => 17;

    my @report_column_headings = $sushi_counter_TR_B3->_COUNTER_report_column_headings;

    # Standard TR_J4 column headings
    is( $report_column_headings[0][0],  'Title',                  '1st column heading is title' );
    is( $report_column_headings[0][1],  'Publisher',              '2nd column heading is publisher' );
    is( $report_column_headings[0][2],  'Publisher_ID',           '3rd column heading is publisher ID' );
    is( $report_column_headings[0][3],  'Platform',               '4th column heading is platform' );
    is( $report_column_headings[0][4],  'DOI',                    '5th column heading is DOI' );
    is( $report_column_headings[0][5],  'Proprietary_ID',         '6th column heading is proprietary ID' );
    is( $report_column_headings[0][6],  'ISBN',                   '7th column heading is ISBN' );
    is( $report_column_headings[0][7],  'Print_ISSN',             '8th column heading is print ISSN' );
    is( $report_column_headings[0][8],  'Online_ISSN',            '9th column heading is online ISSN' );
    is( $report_column_headings[0][9],  'URI',                    '10th column heading is URI' );
    is( $report_column_headings[0][10], 'YOP',                    '11th column heading is yop' );
    is( $report_column_headings[0][11], 'Access_Type',            '12th column heading is access type' );
    is( $report_column_headings[0][12], 'Metric_Type',            '13th column heading is metric type' );
    is( $report_column_headings[0][13], 'Reporting_Period_Total', '14th column heading is reporting period total' );

    # Months column headings
    is( $report_column_headings[0][14], 'Jul 2023', '15th column is month column heading' );
    is( $report_column_headings[0][15], 'Aug 2023', '16th column is the last month column heading' );
    is( $report_column_headings[0][16], undef,      '17th column is empty, no more months' );
};

subtest 'TR_B3 _COUNTER_report_body' => sub {

    plan tests => 51;

    my @report_body = $sushi_counter_TR_B3->_COUNTER_report_body;

    # The same title is sequential but for different metric types
    is(
        $report_body[0][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[1][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[2][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[3][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[4][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[5][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[6][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[7][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is(
        $report_body[8][0], 'Insect Cell Culture: Fundamental and Applied Aspects',
        'same title, different metric type'
    );
    is( $report_body[0][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[1][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[2][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[3][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[4][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[5][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[6][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[7][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[8][11], 'Controlled',                  '9 rows for 1st title' );
    is( $report_body[0][12], 'Unique_Item_Investigations',  '1st title, metric type' );
    is( $report_body[1][12], 'Unique_Title_Investigations', '1st title, metric type' );
    is( $report_body[2][12], 'Total_Item_Investigations',   '1st title, metric type' );
    is( $report_body[3][12], 'Unique_Item_Requests',        '1st title, metric type' );
    is( $report_body[4][12], 'Total_Item_Requests',         '1st title, metric type' );
    is( $report_body[5][12], 'Unique_Item_Investigations',  '1st title, metric type' );
    is( $report_body[6][12], 'Unique_Title_Investigations', '1st title, metric type' );
    is( $report_body[7][12], 'Total_Item_Investigations',   '1st title, metric type' );
    is( $report_body[8][12], 'Unique_Title_Requests',       '1st title, metric type' );
    is( $report_body[0][10], '1996',                        '1st title, yop' );
    is( $report_body[1][10], '1996',                        '1st title, yop' );
    is( $report_body[2][10], '1996',                        '1st title,yop' );
    is( $report_body[3][10], '2002',                        '1st title, 2nd yop has 6 metric types' );
    is( $report_body[4][10], '2002',                        '1st title, 2nd yop has 6 metric types' );
    is( $report_body[5][10], '2002',                        '1st title, 2nd yop has 6 metric types' );
    is( $report_body[6][10], '2002',                        '1st title, 2nd yop has 6 metric types' );
    is( $report_body[7][10], '2002',                        '1st title, 2nd yop has 6 metric types' );
    is( $report_body[8][10], '2002',                        '1st title, 2nd yop has 6 metric types' );

    # The data is in the correct column
    is( $report_body[2][0],  'Insect Cell Culture: Fundamental and Applied Aspects', '1st column is title' );
    is( $report_body[2][1],  'Test Publisher',                                       '2nd column is publisher' );
    is( $report_body[2][2],  '',                          '3rd column heading is publisher ID' );
    is( $report_body[2][3],  'Test Platform',             '4th column is platform' );
    is( $report_body[2][4],  '10.1007/0-306-46850-6',     '5th column is DOI' );
    is( $report_body[2][5],  'aaaa:aidcbc',               '6th column is proprietary ID' );
    is( $report_body[2][6],  '978-0-306-46850-6',         '7th column is ISBN' );
    is( $report_body[2][7],  '1386-2928',                 '8th column is print ISSN' );
    is( $report_body[2][8],  '',                          '9th column is online ISSN' );
    is( $report_body[2][9],  '',                          '10th column is URI' );
    is( $report_body[2][10], '1996',                      '11th column is yop' );
    is( $report_body[2][11], 'Controlled',                '12th column is access type' );
    is( $report_body[2][12], 'Total_Item_Investigations', '13th column is metric type' );
    is( $report_body[2][13], 1,                           '14th column is reporting period total' );

    # The period total is the sum of all the month columns
    my $stats_total = 0;
    for ( my $i = 14 ; $i < 16 ; $i++ ) {
        $stats_total += $report_body[0][$i];
    }
    is(
        $report_body[0][14], $stats_total,
        'Reporting period total matches the sum of all the monthly usage statistics'
    );
};

my $sushi_response_file_TR_B2      = dirname(__FILE__) . "/../../../data/erm/eusage/TR_B2.json";
my $sushi_counter_5_response_TR_B2 = decode_json( read_file($sushi_response_file_TR_B2) );
my $sushi_counter_TR_B2 = Koha::ERM::EUsage::SushiCounter->new( { response => $sushi_counter_5_response_TR_B2 } );

subtest 'TR_B2 _COUNTER_report_header' => sub {

    plan tests => 37;

    my @report_header = $sushi_counter_TR_B2->_COUNTER_report_header;

    # Header row #1 - Report_Name
    is( $report_header[0][0], 'Report_Name',        '1st row is report name' );
    is( $report_header[0][1], 'Book Access Denied', '1st row is report name' );
    is( $report_header[0][2], undef,                '1st row is report name' );

    # Header row #2 - Report_ID
    is( $report_header[1][0], 'Report_ID', '2nd row is report name' );
    is( $report_header[1][1], 'TR_B2',     '2nd row is report name' );
    is( $report_header[1][2], undef,       '2nd row is report name' );

    # Header row #3 - Release
    is( $report_header[2][0], 'Release', '3rd row is counter release' );
    is( $report_header[2][1], '5',       '3rd row is counter release' );
    is( $report_header[2][2], undef,     '3rd row is counter release' );

    # Header row #4 - Institution_Name
    is( $report_header[3][0], 'Institution_Name', '4th row is institution name' );
    is( $report_header[3][1], 'Test Institution', '4th row is institution name' );
    is( $report_header[3][2], undef,              '4th row is institution name' );

    # Header row #5 - Institution_ID
    is( $report_header[4][0], 'Institution_ID',                  '5th row is institution id' );
    is( $report_header[4][1], 'Proprietary:SN:TEST_CUSTOMER_ID', '5th row is institution id' );
    is( $report_header[4][2], undef,                             '5th row is institution id' );

    # Header row #6 - Metric_Types
    is( $report_header[5][0], 'Metric_Types', '6th row is metric types' );
    is(
        $report_header[5][1],
        'Limit_Exceeded; No_License',
        '6th row is metric types'
    );
    is( $report_header[5][2], undef, '6th row is metric types' );

    # Header row #7 - Report_Filters
    is( $report_header[6][0], 'Report_Filters', '7th row is report filters' );
    is(
        $report_header[6][1],
        'Data_Type:Book; Access_Method:Regular; Metric_Type:Limit_Exceeded|No_License; Begin_Date:2022-11-01; End_Date:2022-12-31',
        '7th row is report filters'
    );
    is( $report_header[6][2], undef, '7th row is report filters' );

    # Header row #8 - Report_Attributes
    is( $report_header[7][0], 'Report_Attributes', '8th row is report attributes' );
    is( $report_header[7][1], '',                  '8th row is report attributes' );
    is( $report_header[7][2], undef,               '8th row is report attributes' );

    # Header row #9 - Exceptions
    is( $report_header[8][0], 'Exceptions', '9th row is exceptions' );
    is( $report_header[8][1], '',           '9th row is exceptions' );
    is( $report_header[8][2], undef,        '9th row is exceptions' );

    # Header row #10 - Reporting_Period
    is( $report_header[9][0], 'Reporting_Period',                           '10th row is reporting period' );
    is( $report_header[9][1], 'Begin_Date=2022-11-01; End_Date=2022-12-31', '10th row is reporting period' );
    is( $report_header[9][2], undef,                                        '10th row is reporting period' );

    # Header row #11 - Created
    is( $report_header[10][0], 'Created',              '11th row is created' );
    is( $report_header[10][1], '2023-11-28T12:53:04Z', '11th row is created' );
    is( $report_header[10][2], undef,                  '11th row is created' );

    # Header row #12 - Created
    is( $report_header[11][0], 'Created_By',        '12th row is created by' );
    is( $report_header[11][1], 'Test Systems Inc.', '12th row is created by' );
    is( $report_header[11][2], undef,               '12th row is created by' );

    # Header row #13 - This needs to be empty
    is( $report_header[12][0], '', '13th row is empty' );
};

subtest 'TR_B2 _COUNTER_report_column_headings' => sub {

    plan tests => 16;

    my @report_column_headings = $sushi_counter_TR_B2->_COUNTER_report_column_headings;

    # Standard TR_J4 column headings
    is( $report_column_headings[0][0],  'Title',                  '1st column heading is title' );
    is( $report_column_headings[0][1],  'Publisher',              '2nd column heading is publisher' );
    is( $report_column_headings[0][2],  'Publisher_ID',           '3rd column heading is publisher ID' );
    is( $report_column_headings[0][3],  'Platform',               '4th column heading is platform' );
    is( $report_column_headings[0][4],  'DOI',                    '5th column heading is DOI' );
    is( $report_column_headings[0][5],  'Proprietary_ID',         '6th column heading is proprietary ID' );
    is( $report_column_headings[0][6],  'ISBN',                   '7th column heading is ISBN' );
    is( $report_column_headings[0][7],  'Print_ISSN',             '8th column heading is print ISSN' );
    is( $report_column_headings[0][8],  'Online_ISSN',            '9th column heading is online ISSN' );
    is( $report_column_headings[0][9],  'URI',                    '10th column heading is URI' );
    is( $report_column_headings[0][10], 'YOP',                    '11th column heading is yop' );
    is( $report_column_headings[0][11], 'Metric_Type',            '12th column heading is metric type' );
    is( $report_column_headings[0][12], 'Reporting_Period_Total', '13th column heading is reporting period total' );

    # Months column headings
    is( $report_column_headings[0][13], 'Nov 2022', '14th column is month column heading' );
    is( $report_column_headings[0][14], 'Dec 2022', '15th column is the last month column heading' );
    is( $report_column_headings[0][15], undef,      '16th column is empty, no more months' );
};

subtest 'TR_B2 _COUNTER_report_body' => sub {

    plan tests => 18;

    my @report_body = $sushi_counter_TR_B2->_COUNTER_report_body;

    # The same title is sequential but for different metric types
    is(
        $report_body[0][0], 'Handbook of Nuclear Engineering',
        'different title, only one metric type'
    );
    is(
        $report_body[1][0], 'Human Resource Management in International Firms',
        'different title, only one metric type'
    );
    is( $report_body[0][11], 'No_License', '1 rows for 1st title, metric type' );
    is( $report_body[1][11], 'No_License', '1 rows for 2nd title, metric type' );

    # The data is in the correct column
    is( $report_body[2][0],  'Understanding Disability',  '1st column is title' );
    is( $report_body[2][1],  'Test Publisher E',          '2nd column is publisher' );
    is( $report_body[2][2],  '',                          '3rd column heading is publisher ID' );
    is( $report_body[2][3],  'Test Platform',             '4th column is platform' );
    is( $report_body[2][4],  '10.1007/978-1-349-24269-6', '5th column is DOI' );
    is( $report_body[2][5],  'SN:TEST/978-1-349-24269-6', '6th column is proprietary ID' );
    is( $report_body[2][6],  '978-1-349-24269-6',         '7th column is ISBN' );
    is( $report_body[2][7],  '',                          '8th column is print ISSN' );
    is( $report_body[2][8],  '',                          '9th column is online ISSN' );
    is( $report_body[2][9],  '',                          '10th column is URI' );
    is( $report_body[2][10], '1996',                      '11th column is yop' );
    is( $report_body[2][11], 'No_License',                '12th column is access type' );
    is( $report_body[2][12], 1,                           '13th column is reporting period total' );

    # The period total is the sum of all the month columns
    my $stats_total = 0;
    for ( my $i = 13 ; $i < 15 ; $i++ ) {
        $stats_total += $report_body[0][$i];
    }
    is(
        $report_body[0][13], $stats_total,
        'Reporting period total matches the sum of all the monthly usage statistics'
    );
};
