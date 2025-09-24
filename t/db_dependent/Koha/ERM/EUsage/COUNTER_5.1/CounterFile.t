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
use Test::More tests => 3;

use Koha::Database;
use Koha::ERM::EUsage::CounterFile;

use JSON           qw( decode_json );
use File::Basename qw( dirname );
use File::Slurp;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::MockModule;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

my $sushi_response_file_TR_J1       = dirname(__FILE__) . "/../../../../data/erm/eusage/COUNTER_5.1/TR_J1.json";
my $sushi_counter_51_response_TR_J1 = read_file($sushi_response_file_TR_J1);
my $sushi_counter_report_TR_J1 =
    Koha::ERM::EUsage::SushiCounter->new( { response => decode_json($sushi_counter_51_response_TR_J1) } );

subtest 'store' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = Koha::Patrons->search()->last;
    t::lib::Mocks::mock_userenv( { number => $patron->borrowernumber } );    # Is superlibrarian

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );
    $usage_data_provider->{report_type} = 'TR_J1';

    my $now_time = POSIX::strftime( "%Y%m%d%H%M%S", localtime );

    my $counter_file = Koha::ERM::EUsage::CounterFile->new(
        {
            usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
            file_content           => $sushi_counter_report_TR_J1->get_COUNTER_from_SUSHI,
            date_uploaded          => $now_time,
            filename               => $usage_data_provider->name . "_" . $usage_data_provider->{report_type},
        }
    )->store;

    # UsageTitles are added on CounterFile->store
    my $titles_rs = Koha::ERM::EUsage::UsageTitles->search(
        { usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id } );

    # MonthlyUsages are added on CounterFile->store
    my $mus_rs = Koha::ERM::EUsage::MonthlyUsages->search(
        { usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id } );

    # YearlyUsages are added on CounterFile->store
    my $yus_rs = Koha::ERM::EUsage::YearlyUsages->search(
        { usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id } );

    is( $titles_rs->count, 2,  '2 titles were added' );
    is( $mus_rs->count,    10, '10 monthly usages were added' );
    is( $yus_rs->count,    4,  '4 yearly usages were added' );

    $schema->storage->txn_rollback;

    #TODO: Test yop
    #TODO: acccess_type

};

subtest '_get_rows_from_COUNTER_file' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );
    $usage_data_provider->{report_type} = 'TR_J1';

    my $now_time = POSIX::strftime( "%Y%m%d%H%M%S", localtime );

    my $counter_file = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::CounterFiles',
            value => {
                usage_data_provider_id => $usage_data_provider->erm_usage_data_provider_id,
                file_content           => $sushi_counter_report_TR_J1->get_COUNTER_from_SUSHI,
                date_uploaded          => $now_time,
                filename               => $usage_data_provider->name . "_" . $usage_data_provider->{report_type},
            }
        }
    );

    my $counter_file_rows = $counter_file->_get_rows_from_COUNTER_file;

    is( ref $counter_file_rows, 'ARRAY', '_get_rows_from_COUNTER_file returns array' );
    is(
        scalar @{$counter_file_rows}, 4,
        '_get_rows_from_COUNTER_file returns correct number of rows'
    );
    is(
        @{$counter_file_rows}[0]->{Title}, 'Education and Training',
        'first and second report row is about the same title'
    );
    is(
        @{$counter_file_rows}[1]->{Title}, 'Education and Training',
        'first and second report row is about the same title'
    );

    $schema->storage->txn_rollback;

};
