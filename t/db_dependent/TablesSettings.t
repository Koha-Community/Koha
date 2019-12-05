#!/usr/bin/perl;

use Modern::Perl;
use Test::More tests => 3;
use Test::MockModule;

use C4::Context;
use C4::Utils::DataTables::TablesSettings;
use Koha::Database;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM columns_settings|);

my $module = new Test::MockModule('C4::Utils::DataTables::TablesSettings');
$module->mock(
    'get_yaml',
    sub {
        {
            modules => {
                admin => {
                    currency => {
                        'currencies-table' => {
                            default_display_length => 20,
                            default_sort_order => 1,
                            columns => [
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
                                {
                                    columnname => 'symbol'
                                },
                                {
                                    is_hidden  => '1',
                                    columnname => 'iso_code'
                                },
                                {
                                    columnname => 'last_updated'
                                },
                                {
                                    columnname => 'active'
                                },
                                {
                                    columnname => 'actions'
                                }
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
                default_display_length => 20,
                default_sort_order => 1,
                columns => [
                    {
                        columnname         => 'currency',
                        cannot_be_toggled  => 1,
                        cannot_be_modified => 1,
                        is_hidden  => 0,
                    },
                    {
                        columnname         => 'rate',
                        cannot_be_toggled  => 1,
                        cannot_be_modified => 1,
                        is_hidden  => 0,
                    },
                    {
                        columnname => 'symbol',
                        cannot_be_toggled  => 0,
                        cannot_be_modified => 0,
                        is_hidden  => 0,
                    },
                    {
                        columnname => 'iso_code',
                        cannot_be_toggled  => 0,
                        cannot_be_modified => 0,
                        is_hidden  => 0,
                    },
                    {
                        columnname => 'last_updated',
                        cannot_be_toggled  => 0,
                        cannot_be_modified => 0,
                        is_hidden  => 0,
                    },
                    {
                        columnname => 'active',
                        cannot_be_toggled  => 0,
                        cannot_be_modified => 0,
                        is_hidden  => 1,
                    },
                    {
                        columnname        => 'actions',
                        cannot_be_toggled => 1,
                        cannot_be_modified => 0,
                        is_hidden  => 0,
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
            my $columns =
              C4::Utils::DataTables::TablesSettings::get_columns( $m, $p, $t );
            is_deeply(
                $columns,
                $modules->{$m}{$p}{$t}{columns},
                "columns for $m>$p>$t"
            );
            my $table_settings =
              C4::Utils::DataTables::TablesSettings::get_table_settings( $m, $p, $t );
            is_deeply(
                {
                    default_display_length => $table_settings->{default_display_length},
                    default_sort_order     => $table_settings->{default_sort_order}
                },
                {
                    default_display_length => $modules->{$m}{$p}{$t}{default_display_length},
                    default_sort_order     => $modules->{$m}{$p}{$t}{default_sort_order},
                }
            );
        }
    }
}
