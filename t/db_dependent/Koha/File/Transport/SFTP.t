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

use Test::More tests => 8;
use Test::Exception;
use Test::NoWarnings;
use Test::Warn;

use Koha::File::Transports;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

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
