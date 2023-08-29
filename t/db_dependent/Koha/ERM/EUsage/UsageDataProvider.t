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

use Test::More tests => 1;

use Koha::ERM::EUsage::UsageDataProvider;
use Koha::Database;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest '_build_url_query' => sub {

    plan tests => 1;

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
                service_url => $service_url, api_key => $api_key, requestor_id => $requestor_id,
                customer_id => $customer_id, name    => $name
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

    $schema->storage->txn_rollback;

};
