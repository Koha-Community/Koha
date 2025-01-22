#!/usr/bin/perl;

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 4;
use Test::MockModule;

use C4::Context;
use C4::Utils::DataTables::TablesSettings;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM columns_settings|);

my $module = Test::MockModule->new('C4::Utils::DataTables::TablesSettings');
$module->mock(
    'get_yaml',
    sub {
        {
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
    }
);

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

my $modules = C4::Utils::DataTables::TablesSettings::get_modules();

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

is_deeply( $modules, $modules_expected, 'get_modules returns all values' );

for my $m ( keys %$modules ) {
    for my $p ( keys %{ $modules->{$m} } ) {
        for my $t ( keys %{ $modules->{$m}{$p} } ) {
            my $columns = C4::Utils::DataTables::TablesSettings::get_columns( $m, $p, $t );

            # We do not store default_save_state and default_save_state_search in the yml file
            # Removing them before comparison
            delete $_->{default_save_state}        for @$columns;
            delete $_->{default_save_state_search} for @$columns;
            is_deeply(
                $columns,
                $modules->{$m}{$p}{$t}{columns},
                "columns for $m>$p>$t"
            );
            my $table_settings = C4::Utils::DataTables::TablesSettings::get_table_settings( $m, $p, $t );
            is_deeply(
                {
                    default_display_length    => $table_settings->{default_display_length},
                    default_sort_order        => $table_settings->{default_sort_order},
                    default_save_state        => $table_settings->{default_save_state},
                    default_save_state_search => $table_settings->{default_save_state_search},
                },
                {
                    default_display_length    => $modules->{$m}{$p}{$t}{default_display_length},
                    default_sort_order        => $modules->{$m}{$p}{$t}{default_sort_order},
                    default_save_state        => $modules->{$m}{$p}{$t}{default_save_state},
                    default_save_state_search => $modules->{$m}{$p}{$t}{default_save_state_search},
                }
            );
        }
    }
}
