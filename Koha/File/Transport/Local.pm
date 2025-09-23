package Koha::File::Transport::Local;

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
use File::Copy qw( copy move );
use File::Spec;
use IO::Dir;

use base qw(Koha::File::Transport);

=head1 NAME

Koha::File::Transport::Local - Local file system implementation of file transport

=head2 Class methods

=head3 connect

    my $success = $self->connect;

Validates that the configured directories exist and have appropriate permissions.

=cut

sub connect {
    my ($self) = @_;
    my $operation = "connection";

    # Check download directory if configured
    if ( my $download_dir = $self->download_directory ) {
        unless ( -d $download_dir ) {
            $self->add_message(
                {
                    message => $operation,
                    type    => 'error',
                    payload => {
                        error => "Download directory does not exist: $download_dir",
                        path  => $download_dir
                    }
                }
            );
            return;
        }

        unless ( -r $download_dir ) {
            $self->add_message(
                {
                    message => $operation,
                    type    => 'error',
                    payload => {
                        error => "Download directory is not readable: $download_dir",
                        path  => $download_dir
                    }
                }
            );
            return;
        }
    }

    # Check upload directory if configured
    if ( my $upload_dir = $self->upload_directory ) {
        unless ( -d $upload_dir ) {
            $self->add_message(
                {
                    message => $operation,
                    type    => 'error',
                    payload => {
                        error => "Upload directory does not exist: $upload_dir",
                        path  => $upload_dir
                    }
                }
            );
            return;
        }

        unless ( -w $upload_dir ) {
            $self->add_message(
                {
                    message => $operation,
                    type    => 'error',
                    payload => {
                        error => "Upload directory is not writable: $upload_dir",
                        path  => $upload_dir
                    }
                }
            );
            return;
        }
    }

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status             => 'connected',
                download_directory => $self->download_directory,
                upload_directory   => $self->upload_directory
            }
        }
    );

    return 1;
}

=head3 upload_file

    my $success =  $transport->upload_file($local_file, $remote_file);

Copies a local file to the upload directory.

Returns true on success or undefined on failure.

=cut

sub upload_file {
    my ( $self, $local_file, $remote_file ) = @_;
    my $operation = "upload";

    my $upload_dir  = $self->upload_directory || $self->{current_directory} || '.';
    my $destination = File::Spec->catfile( $upload_dir, $remote_file );

    unless ( copy( $local_file, $destination ) ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => $!,
                    path  => $destination
                }
            }
        );
        return;
    }

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => { path => $destination }
        }
    );

    return 1;
}

=head3 download_file

    my $success =  $transport->download_file($remote_file, $local_file);

Copies a file from the download directory to a local file.

Returns true on success or undefined on failure.

=cut

sub download_file {
    my ( $self, $remote_file, $local_file ) = @_;
    my $operation = 'download';

    my $download_dir = $self->download_directory || $self->{current_directory} || '.';
    my $source       = File::Spec->catfile( $download_dir, $remote_file );

    unless ( -f $source ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => "File not found: $source",
                    path  => $source
                }
            }
        );
        return;
    }

    unless ( copy( $source, $local_file ) ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => $!,
                    path  => $source
                }
            }
        );
        return;
    }

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => { path => $source }
        }
    );

    return 1;
}

=head3 change_directory

    my $success = $server->change_directory($directory);

Sets the current working directory for file operations.

Returns true on success or undefined on failure.

=cut

sub change_directory {
    my ( $self, $remote_directory ) = @_;
    my $operation = 'change_directory';

    # For local file transport, we just track the current directory
    if ( $remote_directory && !-d $remote_directory ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => "Directory not found: $remote_directory",
                    path  => $remote_directory
                }
            }
        );
        return;
    }

    $self->{current_directory} = $remote_directory;

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => { path => $remote_directory }
        }
    );

    return 1;
}

=head3 list_files

    my @files = $server->list_files;

Returns an array of filenames found in the current directory.

=cut

sub list_files {
    my ($self) = @_;
    my $operation = "list";

    my $directory = $self->download_directory || $self->{current_directory} || '.';

    unless ( -d $directory ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => "Directory not found: $directory",
                    path  => $directory
                }
            }
        );
        return;
    }

    my $dir_handle = IO::Dir->new($directory);
    unless ($dir_handle) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => "Cannot open directory: $!",
                    path  => $directory
                }
            }
        );
        return;
    }

    my @files;
    while ( defined( my $file = $dir_handle->read ) ) {
        next if $file =~ /^\.\.?$/;                                 # Skip . and ..
        next unless -f File::Spec->catfile( $directory, $file );    # Only files
        push @files, $file;
    }
    $dir_handle->close;

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                path  => $directory,
                count => scalar @files
            }
        }
    );

    return \@files;
}

=head3 rename_file

    my $success = $server->rename_file($old_name, $new_name);

Renames a file in the current directory.

Returns true on success or undefined on failure.

=cut

sub rename_file {
    my ( $self, $old_name, $new_name ) = @_;
    my $operation = "rename";

    my $directory = $self->download_directory || $self->{current_directory} || '.';
    my $old_path  = File::Spec->catfile( $directory, $old_name );
    my $new_path  = File::Spec->catfile( $directory, $new_name );

    unless ( -f $old_path ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => "File not found: $old_path",
                    path  => $old_path
                }
            }
        );
        return;
    }

    unless ( move( $old_path, $new_path ) ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => {
                    error => $!,
                    path  => "$old_path -> $new_path"
                }
            }
        );
        return;
    }

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => { path => "$old_path -> $new_path" }
        }
    );

    return 1;
}

1;
