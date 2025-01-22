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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

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

=head3 store

    $server->store;

Overloaded store method that ensures key_file also gets written to the filesystem.

=cut

sub store {
    my ($self) = @_;

    $self->SUPER::store;
    $self->discard_changes;
    $self->_write_key_file;

    return $self;
}

=head3 connect

    my $success = $self->connect;

Start the SFTP transport connect, returns true on success or undefined on failure.

=cut

sub connect {
    my ($self) = @_;

    $self->{connection} = Net::SFTP::Foreign->new(
        host     => $self->host,
        port     => $self->port,
        user     => $self->user_name,
        password => $self->plain_text_password,
        key_path => $self->_locate_key_file,
        timeout  => $self->DEFAULT_TIMEOUT,
        more     => [qw(-o StrictHostKeyChecking=no)],
    );
    $self->{connection}->die_on_error("SFTP failure for remote host");

    return $self->_abort_operation() if ( $self->{connection}->error );

    $self->add_message(
        {
            message => $self->{connection}->status,
            type    => 'success',
            payload => { detail => '' }
        }
    );

    return 1;
}

=head3 upload_file

    my $success =  $transport->upload_file($fh);

Passed a filehandle, this will upload the file to the current directory of the server connection.

Returns true on success or undefined on failure.

=cut

sub upload_file {
    my ( $self, $local_file, $remote_file ) = @_;

    my $logger = Koha::Logger->get_logger();

    $self->{connection}->put( $local_file, $remote_file ) or return $self->_abort_operation();

    $self->add_message(
        {
            message => $self->{connection}->status,
            type    => 'success',
            payload => { detail => '' }
        }
    );

    return 1;
}

=head3 download_file

    my $success =  $transport->download_file($filename);

Passed a filename, this will download the file from the current directory of the server connection.

Returns true on success or undefined on failure.

=cut

sub download_file {
    my ( $self, $remote_file, $local_file ) = @_;

    $self->{connection}->get( $remote_file, $local_file ) or return $self->_abort_operation();

    $self->add_message(
        {
            message => $self->{connection}->status,
            type    => 'success',
            payload => { detail => '' }
        }
    );

    return 1;
}

=head3 change_directory

    my $success = $server->change_directory($directory);

Passed a directory name, this will change the current directory of the server connection.

Returns true on success or undefined on failure.

=cut

sub change_directory {
    my ( $self, $remote_directory ) = @_;

    $self->{connection}->setcwd($remote_directory) or return $self->_abort_operation();

    $self->add_message(
        {
            message => $self->{connection}->status,
            type    => 'success',
            payload => { detail => '' }
        }
    );

    return 1;
}

=head3 list_files

    my @files = $server->list_files;

Returns an array of filenames found in the current directory of the server connection.

=cut

sub list_files {
    my ($self) = @_;

    my $file_list = $self->{connection}->ls or return $self->_abort_operation();

    $self->add_message(
        {
            message => $self->{connection}->status,
            type    => 'success',
            payload => { detail => '' }
        }
    );

    return $file_list;
}

=head2 Internal methods

=head3 _write_key_file

    my $success = $server->_write_key_file;

Writes the keyfile from the db into a file.

Returns 1 on success, undef on failure.

=cut

sub _write_key_file {
    my ($self) = @_;

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
    my ($self) = @_;

    $self->add_message(
        {
            message => $self->{connection}->error,
            type    => 'error',
            payload => { detail => $self->{connection} ? $self->{connection}->status : '' }
        }
    );

    if ( $self->{connection} ) {
        $self->{connection}->abort;
    }

    return;
}

1;
