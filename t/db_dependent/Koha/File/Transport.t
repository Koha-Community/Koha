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

use Test::More tests => 6;
use Test::Exception;
use Test::NoWarnings;
use Test::Warn;
use Test::MockModule;
use JSON qw( decode_json );

use Koha::File::Transports;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'store() tests' => sub {
    plan tests => 6;
    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport          => 'ftp',
                password           => undef,
                key_file           => undef,
                download_directory => undef,
                upload_directory   => undef
            }
        }
    );

    subtest 'Test store with empty directories' => sub {
        plan tests => 2;

        $transport->set( { download_directory => '', upload_directory => '' } )->store();

        is( $transport->download_directory, '', 'Empty download directory remains empty' );
        is( $transport->upload_directory,   '', 'Empty upload directory remains empty' );
    };

    subtest 'Test store with directories missing trailing slash' => sub {
        plan tests => 2;

        $transport->set( { download_directory => '/tmp/download', upload_directory => '/tmp/upload' } )->store();

        is( $transport->download_directory, '/tmp/download/', 'Added trailing slash to download directory' );
        is( $transport->upload_directory,   '/tmp/upload/',   'Added trailing slash to upload directory' );
    };

    subtest 'Test store with directories having trailing slash' => sub {
        plan tests => 2;

        $transport->set( { download_directory => '/tmp/download/', upload_directory => '/tmp/upload/' } )->store();

        is( $transport->download_directory, '/tmp/download/', 'Kept existing trailing slash in download directory' );
        is( $transport->upload_directory,   '/tmp/upload/',   'Kept existing trailing slash in upload directory' );
    };

    subtest 'Test store with mixed trailing slashes' => sub {
        plan tests => 2;

        $transport->set( { download_directory => '/tmp/download', upload_directory => '/tmp/upload/' } )->store();

        is( $transport->download_directory, '/tmp/download/', 'Added missing trailing slash to download directory' );
        is( $transport->upload_directory,   '/tmp/upload/',   'Kept existing trailing slash in upload directory' );
    };

    subtest 'Test store with undefined directories' => sub {
        plan tests => 2;

        $transport->set( { download_directory => undef, upload_directory => undef } )->store();

        is( $transport->download_directory, undef, 'Undefined download directory remains undefined' );
        is( $transport->upload_directory,   undef, 'Undefined upload directory remains undefined' );
    };

    subtest 'Test encryption of sensitive data' => sub {
        plan tests => 2;

        $transport->set( { password => "test123", key_file => "test321" } )->store();

        isnt( $transport->password,         "test123", 'Password is encrypted on store' );
        isnt( $transport->upload_directory, "test321", 'Key file is encrypted on store' );

    };

    $schema->storage->txn_rollback;
};

subtest 'to_api() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object( { class => 'Koha::File::Transports', value => { status => undef } } );

    ok( !exists $transport->to_api->{password}, 'Password is not part of the API representation' );
    ok( !exists $transport->to_api->{key_file}, 'Key file is not part of the API representation' );

    $schema->storage->txn_rollback;
};

subtest 'plain_text_password() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'ftp',
                password  => undef,
                key_file  => undef,
            }
        }
    );
    $transport->password('test123')->store();

    my $transport_plain_text_password = $transport->plain_text_password;

    isnt( $transport_plain_text_password, $transport->password, 'Password and password hash shouldn\'t match' );
    is( $transport_plain_text_password, 'test123', 'Password should be in plain text' );

    $schema->storage->txn_rollback;
};

subtest 'plain_text_key() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'ftp',
                password  => undef,
                key_file  => undef
            }
        }
    );
    $transport->key_file("test321")->store();

    my $transport_plain_text_key = $transport->plain_text_key;

    isnt( $transport_plain_text_key, $transport->key_file, 'Key file and key file hash shouldn\'t match' );
    is( $transport_plain_text_key, "test321\n", 'Key file should be in plain text' );

    $schema->storage->txn_rollback;
};

subtest '_record_error() tests' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my @warnings;
    my $logger_module = Test::MockModule->new('Koha::Logger');
    $logger_module->mock(
        'warn',
        sub {
            shift;
            push @warnings, "@_";
        }
    );

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'local' }
        }
    );

    # Simulate a prior successful step before the failure, as would happen
    # during a real multi-step operation (e.g. an EDI download loop
    # downloading several files before one fails).
    $transport->add_message( { message => 'connection', type => 'success', payload => { status => 'connected' } } );

    $transport->_record_error( 'download', { error => 'File not found', path => '/missing/file.txt' } );

    my $reloaded         = Koha::File::Transports->find( $transport->id );
    my $persisted_status = decode_json( $reloaded->status );

    is( $persisted_status->{status}, 'errors', 'status is "errors"' );
    is(
        scalar @{ $persisted_status->{operations} }, 2,
        'the full trace is persisted: the prior success plus the failure, not just the failure alone'
    );
    is( $persisted_status->{operations}[0]{status}, 'success',  'the prior successful operation is recorded first' );
    is( $persisted_status->{operations}[1]{status}, 'error',    'the failing operation is recorded last' );
    is( $persisted_status->{operations}[1]{code},   'download', 'the failing operation code is recorded correctly' );

    ok(
        ( grep { /download/ && /File not found/ } @warnings ),
        '_record_error() logs the failure, including the operation and error, via Koha::Logger at warn level'
    );

    $schema->storage->txn_rollback;
};

1;
