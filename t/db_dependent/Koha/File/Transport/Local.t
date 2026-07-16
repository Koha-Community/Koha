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

use Test::More tests => 3;
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

1;
