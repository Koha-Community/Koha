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

use Net::SFTP::Foreign;
use Try::Tiny;

use base qw(Koha::File::Transport);

=head1 NAME

Koha::File::Transport::SFTP - SFTP implementation of file transport

=cut

sub connect {
    my ($self) = @_;

    $self->{connection} = Net::SFTP::Foreign->new(
        host     => $self->host,
        user     => $self->user_name,
        password => $self->plain_text_password,
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
