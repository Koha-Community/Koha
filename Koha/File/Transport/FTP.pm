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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Net::FTP;
use Try::Tiny;

use base qw(Koha::File::Transport);

=head1 NAME

Koha::File::Transport::FTP - FTP implementation of file transport

=head2 Class methods

=head3 connect

    my $success = $self->connect;

Start the FTP transport connect, returns true on success or undefined on failure.

=cut

sub connect {
    my ($self) = @_;

    $self->{connection} = Net::FTP->new(
        $self->host,
        Port    => $self->port,
        Timeout => $self->DEFAULT_TIMEOUT,
        Passive => $self->passive ? 1 : 0,
    ) or return $self->_abort_operation();

    $self->{connection}->login( $self->user_name, $self->plain_text_password )
        or return $self->_abort_operation();

    $self->add_message(
        {
            message => "Connect succeeded",
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

    $self->{connection}->put( $local_file, $remote_file )
        or return $self->_abort_operation();

    $self->add_message(
        {
            message => "Upload succeeded",
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

    $self->{connection}->get( $remote_file, $local_file )
        or return $self->_abort_operation();

    $self->add_message(
        {
            message => "Download succeeded",
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

    $self->{connection}->cwd($remote_directory) or $self->_abort_operation();

    $self->add_message(
        {
            message => "Changed directory succeeded",
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
            message => "Listing files succeeded",
            type    => 'success',
            payload => { detail => '' }
        }
    );

    return $file_list;
}

sub _abort_operation {
    my ( $self, $message ) = @_;

    $self->add_message(
        {
            message => $self->{connection} ? $self->{connection}->message : $@,
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
