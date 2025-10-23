package Koha::File::Transport::FTP;

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
use Net::FTP;
use Try::Tiny;

use base qw(Koha::File::Transport);

=head1 NAME

Koha::File::Transport::FTP - FTP implementation of file transport

=head2 Class methods

=head3 _connect

    my $success = $self->_connect;

Start the FTP transport connect, returns true on success or undefined on failure.

=cut

sub _connect {
    my ($self) = @_;
    my $operation = "connection";

    $self->{connection} = Net::FTP->new(
        $self->host,
        Port    => $self->port,
        Timeout => $self->DEFAULT_TIMEOUT,
        Passive => $self->passive ? 1 : 0,
    ) or return $self->_abort_operation($operation);

    $self->{connection}->login( $self->user_name, scalar $self->plain_text_password )
        or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                status => 'connected',
                host   => $self->host,
                port   => $self->port
            }
        }
    );

    return 1;
}

=head3 _upload_file

Internal method that performs the FTP-specific upload operation.

Returns true on success or undefined on failure.

=cut

sub _upload_file {
    my ( $self, $local_file, $remote_file ) = @_;
    my $operation = "upload";

    $self->{connection}->put( $local_file, $remote_file )
        or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                local_file  => $local_file,
                remote_file => $remote_file
            }
        }
    );

    return 1;
}

=head3 _download_file

Internal method that performs the FTP-specific download operation.

Returns true on success or undefined on failure.

=cut

sub _download_file {
    my ( $self, $remote_file, $local_file ) = @_;
    my $operation = "download";

    $self->{connection}->get( $remote_file, $local_file )
        or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                remote_file => $remote_file,
                local_file  => $local_file
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
    my $operation = "change_directory";

    $self->{connection}->cwd($remote_directory) or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                directory => $remote_directory,
                pwd       => $self->{connection}->pwd
            }
        }
    );

    return 1;
}

=head3 _list_files

Internal method that performs the FTP-specific file listing operation.
Returns an array reference of hashrefs with file information.
Each hashref contains: filename, longname, size, perms.

=cut

sub _list_files {
    my ($self) = @_;
    my $operation = "list";

    # Get detailed listing using dir() for consistency with SFTP format
    my $detailed_list = $self->{connection}->dir or return $self->_abort_operation($operation);

    # Convert to hash format consistent with SFTP
    my @file_list;
    foreach my $line ( @{$detailed_list} ) {

        # Parse FTP dir output (similar to ls -l format)
        # Example: "-rw-r--r-- 1 user group 1234 Jan 01 12:00 filename.txt"
        if ( $line =~ /^([d\-rwx]+)\s+\S+\s+\S+\s+\S+\s+(\d+)\s+(.+?)\s+(.+)$/ ) {
            my ( $perms, $size, $date_part, $filename ) = ( $1, $2, $3, $4 );

            # Skip directories (start with 'd')
            next if $perms =~ /^d/;

            push @file_list, {
                filename => $filename,
                longname => $line,
                size     => $size,
                perms    => $perms
            };
        }
    }

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => {
                count => scalar @file_list,
                pwd   => $self->{connection}->pwd
            }
        }
    );

    return \@file_list;
}

=head3 _rename_file

Internal method that performs the FTP-specific file rename operation.

Returns true on success or undefined on failure.

=cut

sub _rename_file {
    my ( $self, $old_name, $new_name ) = @_;
    my $operation = "rename";

    $self->{connection}->rename( $old_name, $new_name ) or return $self->_abort_operation($operation);

    $self->add_message(
        {
            message => $operation,
            type    => 'success',
            payload => { detail => "$old_name -> $new_name" }
        }
    );

    return 1;
}

=head3 _disconnect

    $server->_disconnect();

Disconnects from the FTP server.

=cut

sub _disconnect {
    my ($self) = @_;

    if ( $self->{connection} ) {
        $self->{connection}->quit;
        $self->{connection} = undef;
    }

    return 1;
}

=head3 _is_connected

Internal method to check if transport is currently connected.

=cut

sub _is_connected {
    my ($self) = @_;

    return $self->{connection} && $self->{connection}->pwd();
}

sub _abort_operation {
    my ( $self, $operation ) = @_;

    $self->add_message(
        {
            message => $operation || 'operation',
            type    => 'error',
            payload => {
                detail => $self->{connection} ? $self->{connection}->status  : '',
                error  => $self->{connection} ? $self->{connection}->message : $@
            }
        }
    );

    if ( $self->{connection} ) {
        $self->{connection}->abort;
    }

    return;
}

=head3 DESTROY

Ensure proper cleanup of FTP connections

=cut

sub DESTROY {
    my ($self) = @_;

    # Clean up the FTP connection
    if ( $self->{connection} ) {
        $self->{connection}->quit;
    }
}

1;
