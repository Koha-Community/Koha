package Koha::File::Transport::SFTP;

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

use Koha::Logger;

use File::Spec;
use IO::File;
use Net::SFTP::Foreign;
use Try::Tiny;

use base qw(Koha::File::Transport);

=head1 NAME

Koha::File::Transport::SFTP - SFTP implementation of file transport

=head2 Class methods

=head3 _connect

    my $success = $self->_connect;

Start the SFTP transport connect, returns true on success or undefined on failure.

=cut

sub _connect {
    my ($self) = @_;
    my $operation = "connection";

    # String to capture STDERR output
    $self->{stderr_capture} = '';
    open my $stderr_fh, '>', \$self->{stderr_capture} or die "Can't open scalar as filehandle: $!";
    $self->{connection} = Net::SFTP::Foreign->new(
        host     => $self->host,
        port     => $self->port,
        user     => $self->user_name,
        password => $self->plain_text_password,
        $self->_locate_key_file ? ( key_path => $self->_locate_key_file ) : (),
        timeout   => $self->DEFAULT_TIMEOUT,
        stderr_fh => $stderr_fh,
        more      => [qw( -v -o StrictHostKeyChecking=no)],
    );
    $self->{stderr_fh} = $stderr_fh;

    return $self->_abort_operation($operation) if ( $self->{connection}->error );

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status => $self->{connection}->status,
                error  => $self->{connection}->error,
                path   => $self->{connection}->cwd
            }
        }
    );

    return 1;
}

=head3 _upload_file

Internal method that performs the SFTP-specific upload operation.

Returns true on success or undefined on failure.

=cut

sub _upload_file {
    my ( $self, $local_file, $remote_file ) = @_;
    my $operation = "upload";

    $self->{connection}->put( $local_file, $remote_file ) or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status => $self->{connection}->status,
                error  => $self->{connection}->error,
                path   => $self->{connection}->cwd
            }
        }
    );

    return 1;
}

=head3 _download_file

Internal method that performs the SFTP-specific download operation.

Returns true on success or undefined on failure.

=cut

sub _download_file {
    my ( $self, $remote_file, $local_file ) = @_;
    my $operation = 'download';

    $self->{connection}->get( $remote_file, $local_file ) or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status => $self->{connection}->status,
                error  => $self->{connection}->error,
                path   => $self->{connection}->cwd
            }
        }
    );

    return 1;
}

=head3 _change_directory

    my $success = $server->_change_directory($directory);

Passed a directory name, this will change the current directory of the server connection.

Returns true on success or undefined on failure.

=cut

sub _change_directory {
    my ( $self, $remote_directory ) = @_;
    my $operation = 'change_directory';

    $self->{connection}->setcwd($remote_directory) or return $self->_abort_operation( $operation, $remote_directory );

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status => $self->{connection}->status,
                error  => $self->{connection}->error,
                path   => $self->{connection}->cwd
            }
        }
    );

    return 1;
}

=head3 _list_files

Internal method that performs the SFTP-specific file listing operation.
Returns an array reference of hashrefs with file information.
Each hashref contains: filename, longname, a (attributes).

=cut

sub _list_files {
    my ($self) = @_;
    my $operation = "list";

    my $file_list = $self->{connection}->ls or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status => $self->{connection}->status,
                error  => $self->{connection}->error,
                path   => $self->{connection}->cwd
            }
        }
    );

    return $file_list;
}

=head3 _rename_file

Internal method that performs the SFTP-specific file rename operation.

Returns true on success or undefined on failure.

=cut

sub _rename_file {
    my ( $self, $old_name, $new_name ) = @_;
    my $operation = "rename";

    $self->{connection}->rename( $old_name, $new_name )
        or return $self->_abort_operation( $operation, "$old_name -> $new_name" );

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status => $self->{connection}->status,
                error  => $self->{connection}->error,
                path   => $self->{connection}->cwd,
                detail => "$old_name -> $new_name"
            }
        }
    );

    return 1;
}

=head3 _is_connected

Internal method to check if transport is currently connected.

=cut

sub _is_connected {
    my ($self) = @_;

    return $self->{connection} && !$self->{connection}->error;
}

=head3 _disconnect

    $server->_disconnect();

Disconnects from the SFTP server.

=cut

sub _disconnect {
    my ($self) = @_;

    if ( $self->{connection} ) {
        $self->{connection}->disconnect;
        $self->{connection} = undef;
    }

    return 1;
}

=head2 Internal methods

=head3 _post_store_trigger

    $server->post_store_trigger;

Local trigger run by the parent store method after storage.
Ensures key_file also gets written to the filesystem.

=cut

sub _post_store_trigger {
    my ($self) = @_;
    $self->_write_key_file;
    return $self;
}

=head3 _write_key_file

    my $success = $server->_write_key_file;

Writes the keyfile from the db into a file.

Returns 1 on success, undef on failure.

=cut

sub _write_key_file {
    my ($self) = @_;

    return unless $self->plain_text_key;

    my $upload_path = C4::Context->config('upload_path') or return;
    my $logger      = Koha::Logger->get;
    my $key_path    = File::Spec->catdir( $upload_path, 'ssh_keys' );
    my $key_file    = File::Spec->catfile( $key_path, 'id_ssh_' . $self->id );

    mkdir $key_path unless -d $key_path;
    unlink $key_file if -f $key_file;

    my $fh = IO::File->new( $key_file, 'w' ) or return;

    try {
        chmod 0600, $key_file if -f $key_file;
        print $fh $self->plain_text_key;
        close $fh or $logger->warn("Failed to close key file: $!");
        return 1;
    } catch {
        $logger->warn("Error writing key file: $_");
        close $fh;
        return;
    };
}

=head3 _locate_key_file

    my $path = $server->_locate_key_file;

Returns the keyfile's path if it exists, undef otherwise.

=cut

sub _locate_key_file {
    my ($self) = @_;

    my $upload_path = C4::Context->config('upload_path') or return;
    my $key_file    = File::Spec->catfile(
        $upload_path,
        'ssh_keys',
        'id_ssh_' . $self->id
    );

    return ( -f $key_file ) ? $key_file : undef;
}

=head3 _abort_operation

Helper method to abort the current operation and return.

=cut

sub _abort_operation {
    my ( $self, $operation, $path ) = @_;

    my $stderr = $self->{stderr_capture};
    $self->{stderr_capture} = '';

    my $payload = {
        status    => $self->{connection}->status,
        error     => $self->{connection}->error,
        path      => $path ? $path : $self->{connection}->cwd,
        error_raw => $stderr
    };

    $self->add_message(
        {
            message => $operation,
            type    => 'error',
            payload => $payload
        }
    );

    if ( $self->{connection} ) {
        $self->{connection}->abort;
    }

    my $status = {
        status     => 'errors',
        operations => [ { code => $operation, status => 'error', detail => $payload } ]
    };
    $self->set( { status => encode_json($status) } )->store();

    return;
}

=head3 DESTROY

Ensure proper cleanup of open filehandles

=cut

sub DESTROY {
    my ($self) = @_;

    # Clean up the SFTP connection
    if ( $self->{connection} ) {
        $self->{connection}->disconnect;
    }

    # Ensure the filehandle is closed properly
    if ( $self->{stderr_fh} ) {
        close $self->{stderr_fh} or warn "Failed to close STDERR filehandle: $!";
    }
}

1;
