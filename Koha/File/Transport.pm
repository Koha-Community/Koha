package Koha::File::Transport;

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
use constant {
    DEFAULT_TIMEOUT   => 10,
    TEST_FILE_NAME    => '.koha_test_file',
    TEST_FILE_CONTENT => "Hello, world!\n",
};

use Koha::Database;
use Koha::Exceptions::Object;
use Koha::Encryption;

use base qw(Koha::Object);

=head1 NAME

Koha::File::Transport - Base class for file transport handling

=head1 DESCRIPTION

Base class providing common functionality for FTP/SFTP file transport.

=cut

=head1 API

=head2 Class methods

=head3 store

    $server->store;

Overloaded store method that ensures directory paths end with a forward slash.

=cut

sub store {
    my ($self) = @_;

    # Encrypt sensitive data if changed
    $self->_encrypt_sensitive_data();

    # Normalize directory paths
    for my $dir_field (qw(download_directory upload_directory)) {
        my $dir = $self->$dir_field;
        next                            unless $dir && $dir ne '';
        $self->$dir_field( $dir . '/' ) unless substr( $dir, -1 ) eq '/';
    }

    # Store
    $self->SUPER::store;

    # Return the updated object including the encrypt_sensitive_data
    return $self->discard_changes;
}

=head3 plain_text_password

    my $password = $server->plain_text_password;

Returns the decrypted plaintext password.

=cut

sub plain_text_password {
    my ($self) = @_;
    return unless $self->password;
    return Koha::Encryption->new->decrypt_hex( $self->password );
}

=head3 plain_text_key

    my $key = $server->plain_text_key;

Returns the decrypted plaintext key file.

=cut

sub plain_text_key {
    my ($self) = @_;
    return unless $self->key_file;
    return Koha::Encryption->new->decrypt_hex( $self->key_file ) . "\n";
}

=head3 to_api

    my $json = $transport->to_api;

Returns a JSON representation of the object suitable for API output,
excluding sensitive data.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $json = $self->SUPER::to_api($params) or return;
    delete @{$json}{qw(password key_file)};    # Remove sensitive data

    return $json;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::File::Transport object
on the API.

=cut

sub to_api_mapping {
    return { id => 'sftp_server_id' };
}

=head3 test_connection

    $transport->test_connection

Method to test the connection for the configuration of the current file server

=cut

sub test_connection {
    my ($self) = @_;

    $self->connect or return;

    for my $dir_type (qw(download upload)) {
        my $dir = $self->{"${dir_type}_directory"};
        next if $dir eq '';

        $self->change_directory($dir) or return;
        $self->list_files()           or return;
    }

    return 1;
}

=head2 Subclass methods

Interface methods that must be implemented by subclasses

=head3 connect

    $transport->connect();

Method for connecting the current transport to the file server

=cut

sub connect {
    my ($self) = @_;
    die "Subclass must implement connect";
}

=head3 upload_file

    $transport->upload_file($file);

Method for uploading a file to the current file server

=cut

sub upload_file {
    my ( $self, $local_file, $remote_file ) = @_;
    die "Subclass must implement upload_file";
}

=head3 download_file

    $transport->download_file($file);

Method for downloading a file from the current file server

=cut

sub download_file {
    my ( $self, $remote_file, $local_file ) = @_;
    die "Subclass must implement download_file";
}

=head3 change_directory

    my $files = $transport->change_directory($path);

Method for changing the current directory on the connected file server

=cut

sub change_directory {
    my ( $self, $path ) = @_;
    die "Subclass must implement change_directory";
}

=head3 list_files

    my $files = $transport->list_files($path);

Method for listing files in the current directory of the connected file server

=cut

sub list_files {
    my ( $self, $path ) = @_;
    die "Subclass must implement list_files";
}

=head2 Internal methods

=head3 _encrypt_sensitive_data

Handle encryption of sensitive data

=cut

sub _encrypt_sensitive_data {
    my ($self) = @_;
    my $encryption = Koha::Encryption->new;

    # Only encrypt if the value has changed (is_changed from Koha::Object)
    if ( ( !$self->in_storage || $self->is_changed('password') ) && $self->password ) {
        $self->password( $encryption->encrypt_hex( $self->password ) );
    }

    if ( ( !$self->in_storage || $self->is_changed('key_file') ) && $self->key_file ) {
        $self->key_file( $encryption->encrypt_hex( _dos2unix( $self->key_file ) ) );
    }
}

=head3 _dos2unix

Return a CR-free string from an input

=cut

sub _dos2unix {
    my $dosStr = shift;

    return $dosStr =~ s/\015\012/\012/gr;
}

=head3 _type

Return type of Object relating to Schema Result

=cut

sub _type {
    return 'SftpServer';
}

1;
