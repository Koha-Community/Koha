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
use Test::More tests => 3;

use Koha::ERM::EUsage::UsageDataProvider;
use Koha::Database;
use Test::MockModule;
use Test::MockObject;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_build_url_query' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $service_url  = 'https://service_url.com';
    my $api_key      = 'APIKEY';
    my $requestor_id = 'REQID123';
    my $customer_id  = 'ID123';
    my $name         = 'TestProvider';

    my $usage_data_provider = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => {
                service_url => $service_url, api_key => $api_key, requestor_id     => $requestor_id,
                customer_id => $customer_id, name    => $name,    service_platform => undef
            }
        }
    );

    $usage_data_provider->{report_type} = 'TR_J1';
    $usage_data_provider->{begin_date}  = '2023-08-01';
    $usage_data_provider->{end_date}    = '2023-09-30';

    is(
        $usage_data_provider->_build_url_query,
        $service_url
            . '/reports/'
            . lc( $usage_data_provider->{report_type} )
            . '?customer_id='
            . $customer_id
            . '&requestor_id='
            . $requestor_id
            . '&api_key='
            . $api_key
            . '&begin_date='
            . substr( $usage_data_provider->{begin_date}, 0, 7 )
            . '&end_date='
            . substr( $usage_data_provider->{end_date}, 0, 7 )
    );

    my $test_platform = 'www.whatever.com';

    my $usage_data_provider_with_platform = $builder->build_object(
        {
            class => 'Koha::ERM::EUsage::UsageDataProviders',
            value => {
                service_url => $service_url, api_key => $api_key, requestor_id     => $requestor_id,
                customer_id => $customer_id, name    => $name,    service_platform => $test_platform
            }
        }
    );

    $usage_data_provider_with_platform->{report_type} = 'TR_J1';
    $usage_data_provider_with_platform->{begin_date}  = '2023-08-01';
    $usage_data_provider_with_platform->{end_date}    = '2023-09-30';

    is(
        $usage_data_provider_with_platform->_build_url_query,
        $service_url
            . '/reports/'
            . lc( $usage_data_provider->{report_type} )
            . '?customer_id='
            . $customer_id
            . '&requestor_id='
            . $requestor_id
            . '&api_key='
            . $api_key
            . '&begin_date='
            . substr( $usage_data_provider->{begin_date}, 0, 7 )
            . '&end_date='
            . substr( $usage_data_provider->{end_date}, 0, 7 )
            . '&platform='
            . $test_platform
    );

    $schema->storage->txn_rollback;

};

subtest 'test_connection() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $ua = Test::MockModule->new('LWP::UserAgent');
    $ua->mock(
        'simple_request',
        sub {
            my $response = Test::MockObject->new();

            $response->mock(
                'code',
                sub {
                    return 200;
                }
            );
            $response->mock(
                'is_error',
                sub {
                    return 0;
                }
            );
            $response->mock(
                'is_redirect',
                sub {
                    return 0;
                }
            );
            $response->mock(
                'decoded_content',
                sub {
                    return
                        '{"Description":"COUNTER Usage Reports for Test platform.","ServiceActive":true,"RegistryURL":"https://www.whatever.com"}';
                }
            );
            $response->{_rc} = 200;
            return $response;
        }
    );

    my $usage_data_provider = $builder->build_object(
        { class => 'Koha::ERM::EUsage::UsageDataProviders', value => { name => 'TestProvider' } } );

    is( $usage_data_provider->test_connection, 1 );

    $schema->storage->txn_rollback;
};
