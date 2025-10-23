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

use Test::More tests => 7;
use Test::Exception;
use Test::NoWarnings;
use Test::Warn;
use Test::MockModule;

use Koha::File::Transports;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'scalar context in authentication tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Test 1: Transport with no password - plain_text_password should return undef in scalar context
    my $transport_no_pass = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => undef }
        }
    );

    # Mock Net::FTP to verify parameters passed to login()
    my $login_called = 0;
    my @login_params;
    my $mock_ftp = Test::MockModule->new('Net::FTP');
    $mock_ftp->mock(
        'new',
        sub {
            my $class = shift;
            return bless {}, $class;
        }
    );
    $mock_ftp->mock(
        'login',
        sub {
            $login_called = 1;
            @login_params = @_;
            return 1;
        }
    );
    $mock_ftp->mock( 'quit',    sub { return 1; } );
    $mock_ftp->mock( 'abort',   sub { return 1; } );
    $mock_ftp->mock( 'status',  sub { return 0; } );
    $mock_ftp->mock( 'message', sub { return ''; } );

    # Test that plain_text_password returns undef when no password set
    is(
        scalar $transport_no_pass->plain_text_password, undef,
        'plain_text_password returns undef in scalar context when no password'
    );

    # Test 2: Attempt connection with no password - should pass undef not empty list
    $transport_no_pass->connect;
    is( $login_called,        1,     'login was called' );
    is( scalar @login_params, 3,     'login called with correct number of parameters (self, user, password)' );
    is( $login_params[2],     undef, 'password parameter is undef, not empty list' );

    # Clean up connection to avoid warnings in DESTROY
    $transport_no_pass->{connection} = undef;

    $schema->storage->txn_rollback;
};

subtest 'connect() tests' => sub {
    plan tests => 1;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'connect' );
};

subtest 'upload_file() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'upload_file' );
};

subtest 'download_file() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'download_file' );
};

subtest 'change_directory() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'change_directory' );
};

subtest 'list_files() tests' => sub {
    plan tests => 1;
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'ftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'list_files' );
};

1;
