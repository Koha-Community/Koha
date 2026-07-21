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

use Test::More tests => 8;
use Test::Exception;
use Test::NoWarnings;
use Test::Warn;

use Net::SFTP::Foreign::Attributes;
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
    plan tests => 12;

    $schema->storage->txn_begin;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => { transport => 'sftp', password => 'testpass' }
        }
    );

    can_ok( $transport, 'list_files' );

    # Net::SFTP::Foreign::ls() returns an arrayref of hashes, each with
    # filename, longname and an 'a' key holding a
    # Net::SFTP::Foreign::Attributes object - the fields we need to flatten
    # out into the same flat hash shape used by the FTP and Local transports.
    my $file_attrs = Net::SFTP::Foreign::Attributes->new;
    $file_attrs->set_size(1234);
    $file_attrs->set_perm( oct('100644') );
    $file_attrs->set_amtime( 1700000000, 1700000100 );

    my $dir_attrs = Net::SFTP::Foreign::Attributes->new;
    $dir_attrs->set_perm( oct('040755') );

    # Some SFTP servers include '.' and '..' pseudo-entries in their
    # SSH_FXP_READDIR response - Net::SFTP::Foreign::ls() does not filter
    # them out by default, so Koha must do it itself, matching the FTP and
    # Local transports.
    my @sftp_ls_output = (
        {
            filename => '.',
            longname => 'drwxr-xr-x 2 kohauser kohauser 4096 Nov 14 22:15 .',
            a        => $dir_attrs,
        },
        {
            filename => '..',
            longname => 'drwxr-xr-x 2 kohauser kohauser 4096 Nov 14 22:15 ..',
            a        => $dir_attrs,
        },
        {
            filename => 'QUOTES_413514.CEQ',
            longname => '-rw-r--r-- 1 kohauser kohauser 1234 Nov 14 22:15 QUOTES_413514.CEQ',
            a        => $file_attrs,
        },
        {
            filename => 'incoming',
            longname => 'drwxr-xr-x 2 kohauser kohauser 4096 Nov 14 22:15 incoming',
            a        => $dir_attrs,
        },
    );

    my $undef;
    my $mock_sftp = Test::MockModule->new('Net::SFTP::Foreign');
    $mock_sftp->mock( 'ls',     sub { return [@sftp_ls_output]; } );
    $mock_sftp->mock( 'error',  sub { return $undef; } );
    $mock_sftp->mock( 'status', sub { return 0; } );
    $mock_sftp->mock( 'cwd',    sub { return '/incoming/'; } );

    # Pretend we are already connected so list_files() skips (re)connection
    $transport->{connection}          = bless {}, 'Net::SFTP::Foreign';
    $transport->{_user_set_directory} = 1;

    my $files = $transport->list_files();

    is( ref($files),      'ARRAY', 'list_files() returns an arrayref' );
    is( scalar @{$files}, 2,       'both the file and the directory are returned' );

    my ($file) = grep { $_->{filename} eq 'QUOTES_413514.CEQ' } @{$files};
    my ($dir)  = grep { $_->{filename} eq 'incoming' } @{$files};

    is( ref( $file->{a} ), '',         'nested Attributes object is not present in the returned hashref' );
    is( $file->{size},     1234,       'size is flattened out of the Attributes object' );
    is( $file->{mtime},    1700000100, 'mtime is flattened out of the Attributes object' );
    is( $file->{perms},    '0644',     'perms is flattened out of the Attributes object' );
    is( $file->{type},     'file',     'regular file gets type "file"' );

    ok( $dir, 'directory entry is present in the listing' );
    is( $dir->{type},  'directory', 'directory gets type "directory"' );
    is( $dir->{perms}, '0755',      'directory perms are flattened too' );

    ok(
        !( grep { $_->{filename} =~ /^\.\.?$/ } @{$files} ),
        "'.' and '..' entries are excluded from the listing"
    );

    $transport->{connection} = undef;

    $schema->storage->txn_rollback;
};

1;
