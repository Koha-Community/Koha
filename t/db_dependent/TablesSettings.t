#!/usr/bin/perl;

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockModule;

use C4::Context;
use C4::Utils::DataTables::TablesSettings;
use Koha::Database;

my $schema = Koha::Database->new->schema;

my $yaml;
my $module = Test::MockModule->new('C4::Utils::DataTables::TablesSettings');
$module->mock(
    'get_yaml',
    sub { return $yaml; }
);

subtest 'update_columns, get_modules, get_columns, get_table_settings' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;
    my $dbh = C4::Context->dbh;

    $dbh->do(q|DELETE FROM columns_settings|);
    $dbh->do(q|DELETE FROM tables_settings|);

    $yaml = {
        modules => {
            admin => {
                currency => {
                    'currencies-table' => {
                        default_display_length    => 20,
                        default_sort_order        => 1,
                        default_save_state        => 1,
                        default_save_state_search => 0,
                        columns                   => [
                            {
                                columnname         => 'currency',
                                cannot_be_toggled  => '1',
                                cannot_be_modified => '1'
                            },
                            {
                                columnname         => 'rate',
                                cannot_be_toggled  => '1',
                                cannot_be_modified => '1'
                            },
                            { columnname => 'symbol' },
                            {
                                is_hidden  => '1',
                                columnname => 'iso_code'
                            },
                            { columnname => 'last_updated' },
                            { columnname => 'active' },
                            { columnname => 'actions' }
                        ]
                    }
                }
            },
        }
    };

    C4::Utils::DataTables::TablesSettings::update_columns(
        {
            columns => [
                {
                    module             => 'admin',
                    page               => 'currency',
                    tablename          => 'currencies-table',
                    columnname         => 'currency',
                    cannot_be_toggled  => 1,
                    cannot_be_modified => 1,
                },
                {
                    module             => 'admin',
                    page               => 'currency',
                    tablename          => 'currencies-table',
                    columnname         => 'rate',
                    cannot_be_toggled  => 1,
                    cannot_be_modified => 1,
                },
                {
                    module     => 'admin',
                    page       => 'currency',
                    tablename  => 'currencies-table',
                    columnname => 'symbol',
                },
                {
                    module     => 'admin',
                    page       => 'currency',
                    tablename  => 'currencies-table',
                    columnname => 'iso_code',
                    is_hidden  => 0,
                },
                {
                    module     => 'admin',
                    page       => 'currency',
                    tablename  => 'currencies-table',
                    columnname => 'last_updated',
                },
                {
                    module     => 'admin',
                    page       => 'currency',
                    tablename  => 'currencies-table',
                    columnname => 'active',
                    is_hidden  => 1,
                },
                {
                    module            => 'admin',
                    page              => 'currency',
                    tablename         => 'currencies-table',
                    columnname        => 'actions',
                    cannot_be_toggled => 1,
                },
            ]
        }
    );

    my $table_settings =
        C4::Utils::DataTables::TablesSettings::get_table_settings( 'admin', 'currency', 'currencies-table' );
    is_deeply(
        $table_settings,
        {
            default_display_length    => 20,
            default_sort_order        => 1,
            default_save_state        => 1,
            default_save_state_search => 0,
        }
    );

    # No changes to table settings
    C4::Utils::DataTables::TablesSettings::update_table_settings(
        {
            module                    => 'admin',
            page                      => 'currency',
            tablename                 => 'currencies-table',
            default_display_length    => 20,
            default_sort_order        => 1,
            default_save_state        => 1,
            default_save_state_search => 0,
        }
    );

    my $modules_expected = {
        'admin' => {
            'currency' => {
                'currencies-table' => {
                    default_display_length    => 20,
                    default_sort_order        => 1,
                    default_save_state        => 1,
                    default_save_state_search => 0,
                    columns                   => [
                        {
                            columnname         => 'currency',
                            cannot_be_toggled  => 1,
                            cannot_be_modified => 1,
                            is_hidden          => 0,
                        },
                        {
                            columnname         => 'rate',
                            cannot_be_toggled  => 1,
                            cannot_be_modified => 1,
                            is_hidden          => 0,
                        },
                        {
                            columnname         => 'symbol',
                            cannot_be_toggled  => 0,
                            cannot_be_modified => 0,
                            is_hidden          => 0,
                        },
                        {
                            columnname         => 'iso_code',
                            cannot_be_toggled  => 0,
                            cannot_be_modified => 0,
                            is_hidden          => 0,
                        },
                        {
                            columnname         => 'last_updated',
                            cannot_be_toggled  => 0,
                            cannot_be_modified => 0,
                            is_hidden          => 0,
                        },
                        {
                            columnname         => 'active',
                            cannot_be_toggled  => 0,
                            cannot_be_modified => 0,
                            is_hidden          => 1,
                        },
                        {
                            columnname         => 'actions',
                            cannot_be_toggled  => 1,
                            cannot_be_modified => 0,
                            is_hidden          => 0,
                        },
                    ]
                }
            }
        }
    };

    my $modules = C4::Utils::DataTables::TablesSettings::get_modules();

    is_deeply( $modules, $modules_expected, 'get_modules returns all values' );

    my $columns = C4::Utils::DataTables::TablesSettings::get_columns( 'admin', 'currency', 'currencies-table' );
    is_deeply( $modules->{admin}, $modules_expected->{admin} );

    $table_settings =
        C4::Utils::DataTables::TablesSettings::get_table_settings( 'admin', 'currency', 'currencies-table' );
    is_deeply(
        $table_settings,
        {
            default_display_length    => 20,
            default_sort_order        => 1,
            default_save_state        => 1,
            default_save_state_search => 0,
        }
    );

    # Changes to table settings
    my $new_table_settings = {
        default_display_length    => 42,
        default_sort_order        => 2,
        default_save_state        => 0,
        default_save_state_search => 0,
    };

    C4::Utils::DataTables::TablesSettings::update_table_settings(
        { module => 'admin', page => 'currency', tablename => 'currencies-table', %$new_table_settings } );

    $table_settings =
        C4::Utils::DataTables::TablesSettings::get_table_settings( 'admin', 'currency', 'currencies-table' );
    is_deeply(
        $table_settings,
        $new_table_settings,
    );
};
