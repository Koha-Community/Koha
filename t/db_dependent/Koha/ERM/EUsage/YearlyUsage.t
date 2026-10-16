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
use Test::Exception;

use Koha::Database;
use Koha::ERM::EUsage::MonthlyUsage;
use Koha::ERM::EUsage::YearlyUsage;
use Koha::ERM::EUsage::YearlyUsages;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'rebuild sums monthly usage per year' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $title       = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageTitles' } );
    my $other_title = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageTitles' } );

    my $common = {
        title_id               => $title->title_id,
        usage_data_provider_id => $title->usage_data_provider_id,
        report_type            => 'TR_J1',
    };

    my @monthly_usages = (
        { year => 2023, month => 1, usage_count => 5,  metric_type => 'Total_Item_Requests' },
        { year => 2023, month => 2, usage_count => 7,  metric_type => 'Total_Item_Requests' },
        { year => 2023, month => 1, usage_count => 3,  metric_type => 'Unique_Item_Requests' },
        { year => 2024, month => 1, usage_count => 11, metric_type => 'Total_Item_Requests' },
    );
    Koha::ERM::EUsage::MonthlyUsage->new( { %{$common}, %{$_} } )->store for @monthly_usages;

    # A row for another title must not be summed into this title
    Koha::ERM::EUsage::MonthlyUsage->new(
        {
            title_id               => $other_title->title_id,
            usage_data_provider_id => $other_title->usage_data_provider_id,
            report_type            => 'TR_J1',
            year                   => 2023,
            month                  => 1,
            usage_count            => 100,
            metric_type            => 'Total_Item_Requests',
        }
    )->store;

    is(
        Koha::ERM::EUsage::YearlyUsages->search( { title_id => $title->title_id } )->count, 0,
        'Storing monthly usage does not write yearly usage'
    );

    Koha::ERM::EUsage::YearlyUsages->rebuild( { usage_data_provider_id => $title->usage_data_provider_id } );
    Koha::ERM::EUsage::YearlyUsages->rebuild( { usage_data_provider_id => $other_title->usage_data_provider_id } );

    my $yearly_usages = Koha::ERM::EUsage::YearlyUsages->search(
        { title_id => $title->title_id },
        { order_by => [ 'year', 'metric_type' ] }
    );
    is( $yearly_usages->count, 3, 'One yearly row per year and metric type' );

    my ( $total_2023, $unique_2023, $total_2024 ) = $yearly_usages->as_list;

    is( $total_2023->year,        2023,                  'First row is 2023' );
    is( $total_2023->metric_type, 'Total_Item_Requests', 'First row is Total_Item_Requests' );
    is( $total_2023->totalcount,  12,                    'Two months of 2023 are summed' );
    is( $total_2023->report_type, 'TR_J1',               'report_type is carried through' );

    is( $unique_2023->totalcount, 3,    'Unique_Item_Requests is summed separately' );
    is( $total_2024->year,        2024, 'Third row is 2024' );
    is( $total_2024->totalcount,  11,   'A single month gives its own total' );

    is( $title->yearly_usages->count, 3, 'UsageObject->yearly_usages reads the table' );

    my $api = $total_2023->to_api;
    is( $api->{yearly_usage_summary_id}, $total_2023->yearly_usage_summary_id, 'Table exposes a primary key' );

    $schema->storage->txn_rollback;
};

subtest 'YearlyUsage is read-only' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    throws_ok {
        Koha::ERM::EUsage::YearlyUsage->new( { year => 2023, totalcount => 1 } )->store;
    }
    'Koha::Exception', 'store throws';

    my $title = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageTitles' } );
    Koha::ERM::EUsage::MonthlyUsage->new(
        {
            title_id               => $title->title_id,
            usage_data_provider_id => $title->usage_data_provider_id,
            report_type            => 'TR_J1',
            year                   => 2023,
            month                  => 1,
            usage_count            => 1,
            metric_type            => 'Total_Item_Requests',
        }
    )->store;
    Koha::ERM::EUsage::YearlyUsages->rebuild( { usage_data_provider_id => $title->usage_data_provider_id } );
    my $yearly_usage = Koha::ERM::EUsage::YearlyUsages->search( { title_id => $title->title_id } )->next;

    throws_ok { $yearly_usage->delete } 'Koha::Exception', 'delete throws';

    $schema->storage->txn_rollback;
};

subtest 'rebuild follows the monthly usage' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $title    = $builder->build_object( { class => 'Koha::ERM::EUsage::UsageTitles' } );
    my $platform = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsagePlatforms',
            value => { usage_data_provider_id => $title->usage_data_provider_id },
        }
    );
    my $provider_id = $title->usage_data_provider_id;

    my $store_month = sub {
        my ( $object_key, $object, $month, $count ) = @_;
        return Koha::ERM::EUsage::MonthlyUsage->new(
            {
                $object_key            => $object,
                usage_data_provider_id => $provider_id,
                report_type            => 'TR_J1',
                year                   => 2023,
                month                  => $month,
                usage_count            => $count,
                metric_type            => 'Total_Item_Requests',
            }
        )->store;
    };

    my $january = $store_month->( title_id => $title->title_id, 1, 5 );
    $store_month->( title_id => $title->title_id, 2, 7 );

    # The key columns of a platform row are NULL for the title, database and item
    $store_month->( platform_id => $platform->platform_id, 1, 2 );

    my %filter = ( usage_data_provider_id => $provider_id, report_type => 'TR_J1', year => 2023 );
    is( Koha::ERM::EUsage::YearlyUsages->rebuild( \%filter ), 2, 'Two rows are written' );

    my $title_total    = sub { Koha::ERM::EUsage::YearlyUsages->search( { title_id    => $title->title_id } ) };
    my $platform_total = sub { Koha::ERM::EUsage::YearlyUsages->search( { platform_id => $platform->platform_id } ) };

    is( $title_total->()->count,               1,  'One row for the title' );
    is( $title_total->()->next->totalcount,    12, 'The months are summed' );
    is( $platform_total->()->count,            1,  'One row for the platform' );
    is( $platform_total->()->next->totalcount, 2,  'The platform total is its own' );

    Koha::ERM::EUsage::YearlyUsages->rebuild( \%filter );
    is(
        Koha::ERM::EUsage::YearlyUsages->search( { usage_data_provider_id => $provider_id } )->count,
        2, 'A second rebuild does not duplicate rows, NULL key columns included'
    );

    $january->usage_count(10)->store;
    Koha::ERM::EUsage::YearlyUsages->rebuild( \%filter );
    is( $title_total->()->count,            1,  'A changed month does not add a row' );
    is( $title_total->()->next->totalcount, 17, 'A changed month changes the total' );

    $january->delete;
    Koha::ERM::EUsage::YearlyUsages->rebuild( \%filter );
    is( $title_total->()->next->totalcount, 7, 'A removed month changes the total' );

    my $other_year = Koha::ERM::EUsage::YearlyUsages->rebuild( { %filter, year => 2024 } );
    is( $other_year,             0, 'Another year has no usage' );
    is( $title_total->()->count, 1, 'Another year is not touched' );

    my $other_report_type = Koha::ERM::EUsage::YearlyUsages->rebuild( { %filter, report_type => 'TR_B1' } );
    is( $other_report_type,      0, 'Another report type has no usage' );
    is( $title_total->()->count, 1, 'Another report type is not touched' );

    $schema->storage->txn_rollback;
};
