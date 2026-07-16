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

use Test::More tests => 4;
use Test::NoWarnings;
use File::Temp qw( tempdir );
use File::Spec;

use Koha::File::Transports;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'list_files() tests' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $tempdir      = tempdir( CLEANUP => 1 );
    my $download_dir = File::Spec->catdir( $tempdir, 'download' );
    mkdir $download_dir or die "Cannot create download_dir: $!";

    my $file_path = File::Spec->catfile( $download_dir, 'QUOTES_413514.CEQ' );
    open my $fh, '>', $file_path or die "Cannot create test file: $!";
    print $fh 'test content';
    close $fh;
    chmod 0644, $file_path;

    my $subdir_path = File::Spec->catdir( $download_dir, 'incoming' );
    mkdir $subdir_path or die "Cannot create subdir: $!";
    chmod 0755, $subdir_path;

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport          => 'local',
                download_directory => $download_dir,
            }
        }
    );

    can_ok( $transport, 'list_files' );

    my $files = $transport->list_files();
    is( ref($files),      'ARRAY', 'list_files() returns an arrayref' );
    is( scalar @{$files}, 2,       'both the file and the directory are returned' );

    my ($file_entry) = grep { $_->{filename} eq 'QUOTES_413514.CEQ' } @{$files};
    my ($dir_entry)  = grep { $_->{filename} eq 'incoming' } @{$files};

    ok( $file_entry, 'file entry is present' );
    is( $file_entry->{type},  'file', 'file entry has type "file"' );
    is( $file_entry->{perms}, '0644', 'file entry has expected octal perms' );

    ok( $dir_entry, 'directory entry is present' );
    is( $dir_entry->{type},  'directory', 'directory entry has type "directory"' );
    is( $dir_entry->{perms}, '0755',      'directory entry has expected octal perms' );

    $schema->storage->txn_rollback;
};

subtest 'current_directory() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $tempdir      = tempdir( CLEANUP => 1 );
    my $download_dir = File::Spec->catdir( $tempdir, 'download' );
    mkdir $download_dir or die "Cannot create download_dir: $!";

    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport          => 'local',
                download_directory => $download_dir,
            }
        }
    );

    can_ok( $transport, 'current_directory' );

    is(
        $transport->current_directory, $download_dir,
        'current_directory() falls back to the configured download_directory before any change_directory() call'
    );

    my $subdir_path = File::Spec->catdir( $download_dir, 'incoming' );
    mkdir $subdir_path or die "Cannot create subdir: $!";

    $transport->change_directory($subdir_path);
    is(
        $transport->current_directory, $subdir_path,
        "current_directory() reflects the most recent change_directory() call"
    );

    $schema->storage->txn_rollback;
};

subtest 'an unconfigured directory fails cleanly instead of falling back to "." (the Koha process cwd)' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $tempdir    = tempdir( CLEANUP => 1 );
    my $upload_dir = File::Spec->catdir( $tempdir, 'upload' );
    mkdir $upload_dir or die "Cannot create upload_dir: $!";

    # Only upload_directory is configured - download_directory is explicitly
    # unset (TestBuilder would otherwise auto-fill it with a random string),
    # as is any change_directory() override.
    my $transport = $builder->build_object(
        {
            class => 'Koha::File::Transports',
            value => {
                transport          => 'local',
                upload_directory   => $upload_dir,
                download_directory => undef,
            }
        }
    );

    my $files = $transport->list_files();
    is( $files, undef, 'list_files() fails when no download_directory is configured and no override is set' );

    my ($list_error) = grep { $_->type eq 'error' } @{ $transport->object_messages };
    ok( $list_error, 'list_files() records an error message' );
    like(
        $list_error->payload->{error}, qr/No download directory configured/,
        'error explains the directory is unconfigured, rather than silently listing an unrelated directory'
    );

    my $renamed = $transport->rename_file( 'a.txt', 'b.txt' );
    is( $renamed, undef, 'rename_file() fails the same way when no download_directory is configured' );

    my $tmp_upload_src = File::Spec->catfile( $tempdir, 'to_upload.txt' );
    open my $fh, '>', $tmp_upload_src or die "Cannot create test file: $!";
    print $fh 'content';
    close $fh;

    # upload_directory IS configured, so this direction should still work.
    my $uploaded = $transport->upload_file( $tmp_upload_src, 'to_upload.txt' );
    is( $uploaded, 1, 'upload_file() still succeeds when upload_directory is configured' );
    ok(
        -f File::Spec->catfile( $upload_dir, 'to_upload.txt' ),
        'the file was uploaded to the configured upload_directory'
    );

    # download_file() has no download_directory to fall back to either. Reset
    # {current_directory} first: the auto-managed upload_file() call above
    # left it pointing at upload_dir as a side effect (unrelated to this fix)
    # of _auto_change_directory() calling _change_directory() internally.
    $transport->{current_directory} = undef;
    my $downloaded = $transport->download_file( 'to_upload.txt', File::Spec->catfile( $tempdir, 'downloaded.txt' ) );
    is( $downloaded, undef, 'download_file() fails when no download_directory is configured' );

    my ($download_error) = grep { $_->type eq 'error' } reverse @{ $transport->object_messages };
    like(
        $download_error->payload->{error}, qr/No (?:download|upload) directory configured/,
        'download_file() also records a clear "not configured" error rather than falling back to "."'
    );

    $schema->storage->txn_rollback;
};

1;
