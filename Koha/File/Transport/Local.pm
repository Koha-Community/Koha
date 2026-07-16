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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use File::Copy qw( copy move );
use File::Spec;
use IO::Dir;
use Fcntl qw( S_ISDIR S_ISREG );

use base qw(Koha::File::Transport);

=head1 NAME

Koha::File::Transport::Local - Local file system implementation of file transport

=head2 Class methods

=head3 _connect

    my $success = $self->_connect;

Validates that the configured directories exist and have appropriate permissions.

=cut

sub _connect {
    my ($self) = @_;
    my $operation = "connection";

    # Check download directory if configured
    if ( my $download_dir = $self->download_directory ) {
        unless ( -d $download_dir ) {
            return $self->_abort_operation(
                $operation,
                {
                    error => "Download directory does not exist: $download_dir",
                    path  => $download_dir
                }
            );
        }

        unless ( -r $download_dir ) {
            return $self->_abort_operation(
                $operation,
                {
                    error => "Download directory is not readable: $download_dir",
                    path  => $download_dir
                }
            );
        }
    }

    # Check upload directory if configured
    if ( my $upload_dir = $self->upload_directory ) {
        unless ( -d $upload_dir ) {
            return $self->_abort_operation(
                $operation,
                {
                    error => "Upload directory does not exist: $upload_dir",
                    path  => $upload_dir
                }
            );
        }

        unless ( -w $upload_dir ) {
            return $self->_abort_operation(
                $operation,
                {
                    error => "Upload directory is not writable: $upload_dir",
                    path  => $upload_dir
                }
            );
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

=head3 _working_directory

    my $directory = $self->_working_directory('download_directory');

Returns the directory a Local operation should act in: the directory most
recently set via change_directory(), falling back to the given configured
directory field (C<download_directory> or C<upload_directory>).

Returns undef if neither is set. Callers must not fall back to '.' -
that's the Koha process's own working directory, which has no relation to
any configured transport location and would silently list/act on whatever
directory the process happens to be running in (e.g. the Koha install
root) instead of failing cleanly.

=cut

sub _working_directory {
    my ( $self, $configured_field ) = @_;

    return $self->{current_directory} || $self->$configured_field;
}

=head3 _upload_file

Internal method that performs the local file system upload operation.

Returns true on success or undefined on failure.

=cut

sub _upload_file {
    my ( $self, $local_file, $remote_file ) = @_;
    my $operation = "upload";

    my $upload_dir = $self->_working_directory('upload_directory');
    unless ( defined $upload_dir ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => { error => 'No upload directory configured or set via change_directory()' }
            }
        );
        return;
    }

    my $destination = File::Spec->catfile( $upload_dir, $remote_file );

    unless ( copy( $local_file, $destination ) ) {
        return $self->_abort_operation(
            $operation,
            {
                error => $!,
                path  => $destination
            }
        );
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

=head3 _download_file

Internal method that performs the local file system download operation.

Returns true on success or undefined on failure.

=cut

sub _download_file {
    my ( $self, $remote_file, $local_file ) = @_;
    my $operation = 'download';

    my $download_dir = $self->_working_directory('download_directory');
    unless ( defined $download_dir ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => { error => 'No download directory configured or set via change_directory()' }
            }
        );
        return;
    }

    my $source = File::Spec->catfile( $download_dir, $remote_file );

    unless ( -f $source ) {
        return $self->_abort_operation(
            $operation,
            {
                error => "File not found: $source",
                path  => $source
            }
        );
    }

    unless ( copy( $source, $local_file ) ) {
        return $self->_abort_operation(
            $operation,
            {
                error => $!,
                path  => $source
            }
        );
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

=head3 _change_directory

    my $success = $server->_change_directory($directory);

Sets the current working directory for file operations.

Returns true on success or undefined on failure.

=cut

sub _change_directory {
    my ( $self, $remote_directory ) = @_;
    my $operation = 'change_directory';

    # For local file transport, we just track the current directory
    if ( $remote_directory && !-d $remote_directory ) {
        return $self->_abort_operation(
            $operation,
            {
                error => "Directory not found: $remote_directory",
                path  => $remote_directory
            }
        );
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

=head3 _current_directory

    my $path = $self->_current_directory;

Internal method that returns the local transport's current working
directory: the directory most recently set via change_directory(), falling
back to the configured download_directory, then to '.'.

=cut

sub _current_directory {
    my ($self) = @_;

    return $self->{current_directory} || $self->download_directory || '.';
}

=head3 _list_files

Internal method that performs the local file system file listing operation.
Returns an array reference of hashrefs with file information.
Each hashref contains: filename, longname, size, perms, mtime, type.

=cut

sub _list_files {
    my ($self) = @_;
    my $operation = "list";

    my $directory = $self->_working_directory('download_directory');
    unless ( defined $directory ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => { error => 'No download directory configured or set via change_directory()' }
            }
        );
        return;
    }

    unless ( -d $directory ) {
        return $self->_abort_operation(
            $operation,
            {
                error => "Directory not found: $directory",
                path  => $directory
            }
        );
    }

    my $dir_handle = IO::Dir->new($directory);
    unless ($dir_handle) {
        return $self->_abort_operation(
            $operation,
            {
                error => "Cannot open directory: $!",
                path  => $directory
            }
        );
    }

    my @files;
    while ( defined( my $file = $dir_handle->read ) ) {
        next if $file =~ /^\.\.?$/;    # Skip . and ..
        my $full_path = File::Spec->catfile( $directory, $file );

        # Get file stats for consistency with the SFTP/FTP format
        my @stat = stat($full_path);
        next unless @stat;             # Skip entries we can't stat (e.g. broken symlinks)

        my $size  = $stat[7] || 0;
        my $mtime = $stat[9] || 0;
        my $mode  = $stat[2] || 0;

        my $type =
              S_ISDIR($mode) ? 'directory'
            : S_ISREG($mode) ? 'file'
            :                  'other';

        # Create permissions string (simplified)
        my $perms = sprintf( "%04o", $mode & oct('07777') );

        push @files, {
            filename => $file,
            longname => sprintf( "%s %8d %s %s", $perms, $size, scalar( localtime($mtime) ), $file ),
            size     => $size,
            perms    => $perms,
            mtime    => $mtime,
            type     => $type,
        };
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

=head3 _rename_file

Internal method that performs the local file system file rename operation.

Returns true on success or undefined on failure.

=cut

sub _rename_file {
    my ( $self, $old_name, $new_name ) = @_;
    my $operation = "rename";

    my $directory = $self->_working_directory('download_directory');
    unless ( defined $directory ) {
        $self->add_message(
            {
                message => $operation,
                type    => 'error',
                payload => { error => 'No download directory configured or set via change_directory()' }
            }
        );
        return;
    }

    my $old_path = File::Spec->catfile( $directory, $old_name );
    my $new_path = File::Spec->catfile( $directory, $new_name );

    unless ( -f $old_path ) {
        return $self->_abort_operation(
            $operation,
            {
                error => "File not found: $old_path",
                path  => $old_path
            }
        );
    }

    unless ( move( $old_path, $new_path ) ) {
        return $self->_abort_operation(
            $operation,
            {
                error => $!,
                path  => "$old_path -> $new_path"
            }
        );
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

=head3 _abort_operation

    return $self->_abort_operation( $operation, \%payload );

Records an error message for the named operation, persisting a status
snapshot via the shared _record_error() (see Koha::File::Transport), and
returns nothing, so callers can
C<return $self-E<gt>_abort_operation($operation, \%payload)> on failure.

Unlike FTP/SFTP there is no live connection to abort here - this purely
records the failure, but does so the same way as the other two backends so
a Local transport's displayed status reflects real usage too.

=cut

sub _abort_operation {
    my ( $self, $operation, $payload ) = @_;

    $self->_record_error( $operation, $payload );

    return;
}

=head3 _is_connected

Internal method to check if transport is currently connected.
For local transport, always returns true as local filesystem is always accessible.

=cut

sub _is_connected {
    my ($self) = @_;

    return 1;    # Local filesystem is always "connected"
}

=head3 _disconnect

    $server->_disconnect();

For local transport, this is a no-op as there are no connections to close.

=cut

sub _disconnect {
    my ($self) = @_;

    # No-op for local transport
    return 1;
}

1;
