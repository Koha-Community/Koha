#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use File::Basename;
use Test::NoWarnings;
use Test::More tests => 5;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

BEGIN {
    # Mock pluginsdir before loading Plugins module
    my $path = dirname(__FILE__) . '/../../../lib/plugins';
    t::lib::Mocks::mock_config( 'pluginsdir', $path );

    use_ok('Koha::Plugins');
    use_ok('Koha::Plugins::Handler');
    use_ok('Koha::Plugin::Test');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_config( 'enable_plugins', 1 );

subtest 'ill_table_actions hook' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $plugins = Koha::Plugins->new;
    $plugins->InstallPlugins;

    my $table_actions = Koha::ILL::Request->get_staff_table_actions;

    is_deeply(
        $table_actions,
        [
            {
                button_class                  => 'btn btn-default btn-sm',
                button_link                   => '/cgi-bin/koha/ill/ill-requests.pl?op=illview&amp;illrequest_id=',
                append_column_data_to_link    => 1,
                button_link_translatable_text => 'ill_manage'
            },
            {
                button_link_text           => 'Test text',
                append_column_data_to_link => 1,
                button_class               => 'test class',
                button_link                => 'test link'
            }
        ],
        'get_staff_table_actions() should return core action plus a custom plugin actions'
    );

    Koha::Plugins::Methods->delete;
    $schema->storage->txn_rollback;
};
