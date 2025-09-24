#!/usr/bin/perl

# This file is part of Koha.
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
use Test::More tests => 5;
use C4::Context;
use t::lib::Mocks;

my $dbh      = C4::Context->dbh;
my $sql_mode = $dbh->selectrow_array(q|SELECT @@SQL_MODE|);
like( $sql_mode, qr{STRICT_TRANS_TABLES}, 'Strict SQL modes must be turned on for tests' );

is( $dbh->{RaiseError}, 1, 'RaiseError must be turned on for tests' );

subtest 'db_scheme2dbi' => sub {
    plan tests => 4;

    is( Koha::Database::db_scheme2dbi('mysql'), 'mysql', 'ask for mysql, get mysql' );
    is( Koha::Database::db_scheme2dbi('Pg'),    'Pg',    'ask for Pg, get Pg' );
    is( Koha::Database::db_scheme2dbi('xxx'),   'mysql', 'ask for unsupported DBMS, get mysql' );
    is( Koha::Database::db_scheme2dbi(),        'mysql', 'ask for nothing, get mysql' );
};

subtest 'generate_dsn' => sub {
    plan tests => 6;

    my $config = Koha::Config->get_instance;

    t::lib::Mocks::mock_config( 'database',  'koha' );
    t::lib::Mocks::mock_config( 'hostname',  'localhost' );
    t::lib::Mocks::mock_config( 'port',      '3306' );
    t::lib::Mocks::mock_config( 'db_scheme', 'mysql' );
    t::lib::Mocks::mock_config( 'tls',       'no' );

    is(
        Koha::Database::generate_dsn($config),
        'dbi:mysql:database=koha;host=localhost;port=3306',
        'DSN string for MySQL configuration without TLS.'
    );

    t::lib::Mocks::mock_config( 'tls', 'yes' );
    is(
        Koha::Database::generate_dsn($config),
        'dbi:mysql:database=koha;host=localhost;port=3306;mysql_ssl=1',
        'DSN string for MySQL configuration with TLS without client key, client cert and ca file.'
    );

    t::lib::Mocks::mock_config( 'key', '/path/to/client-key.pem' );
    is(
        Koha::Database::generate_dsn($config),
        'dbi:mysql:database=koha;host=localhost;port=3306;mysql_ssl=1;mysql_ssl_client_key=/path/to/client-key.pem',
        'DSN string for MySQL configuration with TLS and client key.'
    );

    t::lib::Mocks::mock_config( 'cert', '/path/to/client-cert.pem' );
    is(
        Koha::Database::generate_dsn($config),
        'dbi:mysql:database=koha;host=localhost;port=3306;mysql_ssl=1;mysql_ssl_client_key=/path/to/client-key.pem;mysql_ssl_client_cert=/path/to/client-cert.pem',
        'DSN string for MySQL configuration with TLS, client key and client cert.'
    );

    t::lib::Mocks::mock_config( 'ca', '/path/to/ca.pem' );
    is(
        Koha::Database::generate_dsn($config),
        'dbi:mysql:database=koha;host=localhost;port=3306;mysql_ssl=1;mysql_ssl_client_key=/path/to/client-key.pem;mysql_ssl_client_cert=/path/to/client-cert.pem;mysql_ssl_ca_file=/path/to/ca.pem',
        'DSN string for MySQL configuration with TLS with client key, client cert and ca file.'
    );

    t::lib::Mocks::mock_config( 'key',  '__DB_TLS_CLIENT_KEY__' );
    t::lib::Mocks::mock_config( 'cert', '__DB_TLS_CLIENT_CERTIFICATE__' );

    is(
        Koha::Database::generate_dsn($config),
        'dbi:mysql:database=koha;host=localhost;port=3306;mysql_ssl=1;mysql_ssl_ca_file=/path/to/ca.pem',
        'DSN string for MySQL configuration with TLS with ca file.'
    );
};
