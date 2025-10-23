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

use Test::More tests => 9;
use Test::Exception;
use Test::NoWarnings;
use Test::Warn;
use Test::MockModule;

use Koha::Encryption;
use Koha::File::Transports;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'scalar context and mutually exclusive authentication tests' => sub {
    plan tests => 10;

    $schema->storage->txn_begin;

    # Setup mock upload path for key file operations
    my $path = '/tmp/kohadev_test';
    t::lib::Mocks::mock_config( 'upload_path', $path );
    mkdir $path if !-d $path;

    # Mock Net::SFTP::Foreign to capture constructor parameters
    my %sftp_new_params;
    my $mock_sftp = Test::MockModule->new('Net::SFTP::Foreign');
    $mock_sftp->mock(
        'new',
        sub {
            my $class = shift;
            %sftp_new_params = @_;
            my $obj = bless { status => 0, error => undef }, $class;
            return $obj;
        }
    );
    my $undef;
    $mock_sftp->mock( 'error',  sub { return $undef; } );
    $mock_sftp->mock( 'status', sub { return 0; } );
    $mock_sftp->mock( 'cwd',    sub { return '/'; } );

    # Test 1: Transport with no password and no key - plain_text_password returns undef
    my $transport_no_auth = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => undef, key_file => undef }
        }
    );

    is(
        scalar $transport_no_auth->plain_text_password, undef,
        'plain_text_password returns undef in scalar context when no password'
    );

    # Test 2: Connection with no auth should pass password => undef (not empty list)
    $transport_no_auth->connect;
    ok( exists $sftp_new_params{password}, 'password key exists in connection params' );
    is( $sftp_new_params{password}, undef, 'password parameter is undef when no password set' );
    ok( !exists $sftp_new_params{key_path}, 'key_path is not set when no key file exists' );

    # Test 3: Transport with key only - should use key_path, not password
    # Must encrypt key_file since plain_text_key() will decrypt it
    my $encrypted_key      = Koha::Encryption->new->encrypt_hex('test_key_content');
    my $transport_key_only = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => undef, key_file => $encrypted_key }
        }
    );
    $transport_key_only->store;    # Trigger key file write
    $transport_key_only->discard_changes;

    %sftp_new_params = ();         # Clear params
    $transport_key_only->connect;
    ok( exists $sftp_new_params{key_path},  'key_path exists in connection params when key is set' );
    ok( !exists $sftp_new_params{password}, 'password is not set when using key-based auth' );

    # Test 4: Transport with password only - should use password, not key_path
    # Must encrypt password since plain_text_password() will decrypt it
    my $encrypted_pass      = Koha::Encryption->new->encrypt_hex('testpass');
    my $transport_pass_only = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => $encrypted_pass, key_file => undef }
        }
    );

    %sftp_new_params = ();    # Clear params
    $transport_pass_only->connect;
    ok( exists $sftp_new_params{password}, 'password exists in connection params when password is set' );
    is( $sftp_new_params{password}, 'testpass', 'password is correctly decrypted' );
    ok( !exists $sftp_new_params{key_path}, 'key_path is not set when using password auth' );

    # Test 5: Transport with both key and password - should prefer key
    my $encrypted_both_pass = Koha::Encryption->new->encrypt_hex('bothpass');
    my $encrypted_both_key  = Koha::Encryption->new->encrypt_hex('both_test_key');
    my $transport_both      = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => $encrypted_both_pass, key_file => $encrypted_both_key }
        }
    );
    $transport_both->store;    # Trigger key file write
    $transport_both->discard_changes;

    %sftp_new_params = ();     # Clear params
    $transport_both->connect;
    ok(
        exists $sftp_new_params{key_path} && !exists $sftp_new_params{password},
        'When both key and password exist, key_path is used and password is excluded'
    );

    # Cleanup
    unlink $transport_key_only->_locate_key_file if $transport_key_only->_locate_key_file;
    unlink $transport_both->_locate_key_file     if $transport_both->_locate_key_file;

    $schema->storage->txn_rollback;
};

subtest 'store() and _post_store_trigger() tests' => sub {
    plan tests => 2;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => 'testpass' }
        }
    );

    my $post_store_called = 0;
    no warnings 'redefine';
    local *Koha::File::Transport::SFTP::_post_store_trigger = sub {
        $post_store_called = 1;
    };

    lives_ok { $transport->store } 'store() should complete without error';
    is( $post_store_called, 1, '_post_store_trigger() should be called' );
};

subtest '_write_key_file() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport => 'sftp',
                password  => undef,
                key_file  => undef,
            }
        }
    );
    $transport->set( { key_file => '321test' } )->store();
    $transport->discard_changes;

    my $path = '/tmp/kohadev_test';
    t::lib::Mocks::mock_config( 'upload_path', $path );
    mkdir $path if !-d $path;

    my $first_test = $transport->_write_key_file;

    my $file        = $transport->_locate_key_file;
    my $second_test = ( -f $file );

    open( my $fh, '<', $transport->_locate_key_file );
    my $third_test = <$fh>;

    is( $first_test,  1,           'Writing key file should return 1' );
    is( $second_test, 1,           'Written key file should exist' );
    is( $third_test,  "321test\n", 'The contents of the key file should be 321test\n' );

    unlink $file;

    $schema->storage->txn_rollback;
};

subtest 'connect() tests' => sub {
    plan tests => 2;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'connect' );
    dies_ok { $transport->connect } 'connect() should die without proper setup';
};

subtest 'upload_file() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'upload_file' );
};

subtest 'download_file() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'download_file' );
};

subtest 'change_directory() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'change_directory' );
};

subtest 'list_files() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'list_files' );
};

1;
