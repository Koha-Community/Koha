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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 7;
use Test::Exception;
use Test::Warn;

use Koha::SFTP::Servers;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'to_api() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $sftp_server = $builder->build_object( { class => 'Koha::SFTP::Servers' } );

    ok( !exists $sftp_server->to_api->{password}, 'Password is not part of the API representation' );
    ok( !exists $sftp_server->to_api->{key_file}, 'Key file is not part of the API representation' );

    $schema->storage->txn_rollback;
};

subtest 'update_password() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $sftp_server = $builder->build_object( { class => 'Koha::SFTP::Servers' } );
    $sftp_server->update_password('test123');

    ok( $sftp_server->password ne 'test123', 'Password should not be in plain text' );
    is( length( $sftp_server->password ), 64, 'Password has should be 64 characters long' );

    $schema->storage->txn_rollback;
};

subtest 'update_key_file() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $sftp_server = $builder->build_object( { class => 'Koha::SFTP::Servers' } );
    $sftp_server->update_key_file('321tset');

    ok( $sftp_server->key_file ne 'test123', 'Password should not be in plain text' );
    is( length( $sftp_server->key_file ), 64, 'Password has should be 64 characters long' );

    $schema->storage->txn_rollback;
};

subtest 'update_status() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $sftp_server        = $builder->build_object( { class => 'Koha::SFTP::Servers' } );
    my $sftp_server_status = 'tests_ok';

    $sftp_server->set(
        {
            password => 'somepass',
            key_file => 'somekey',
        }
    )->store;

    isnt( $sftp_server_status, $sftp_server->status, 'Status should not by tests_ok' );

    $sftp_server->update_status($sftp_server_status);

    is( $sftp_server_status, $sftp_server->status, 'Status should be tests_ok' );

    $schema->storage->txn_rollback;

};

subtest 'plain_text_password() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $sftp_server = $builder->build_object( { class => 'Koha::SFTP::Servers' } );

    $sftp_server->update_password('test123');

    my $sftp_server_plain_text_password = $sftp_server->plain_text_password;

    isnt( $sftp_server_plain_text_password, $sftp_server->password, 'Password and password hash shouldn\'t match' );
    is( $sftp_server_plain_text_password, 'test123', 'Password should be in plain text' );

    $schema->storage->txn_rollback;
};

subtest 'plain_text_key() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $sftp_server = $builder->build_object( { class => 'Koha::SFTP::Servers' } );

    $sftp_server->update_key_file('321tset');

    my $sftp_server_plain_text_key = $sftp_server->plain_text_key;

    isnt( $sftp_server_plain_text_key, $sftp_server->key_file, 'Key file and key file hash shouldn\'t match' );
    is( $sftp_server_plain_text_key, "321tset\n", 'Key file should be in plain text' );

    $schema->storage->txn_rollback;
};

subtest 'write_key_file() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $sftp_server = $builder->build_object( { class => 'Koha::SFTP::Servers' } );

    $sftp_server->update_key_file('321tset');

    my $path = '/tmp/kohadev_test';
    t::lib::Mocks::mock_config( 'upload_path', $path );
    mkdir $path if !-d $path;

    my $first_test = $sftp_server->write_key_file;

    my $file        = $sftp_server->locate_key_file;
    my $second_test = ( -f $file );

    open( my $fh, '<', $sftp_server->locate_key_file );
    my $third_test = <$fh>;

    is( $first_test,  1,           'Writing key file should return 1' );
    is( $second_test, 1,           'Written key file should exist' );
    is( $third_test,  "321tset\n", 'The contents of the key file should be 321tset\n' );

    unlink $file;

    $schema->storage->txn_rollback;
};
