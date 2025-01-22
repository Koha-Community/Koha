package Koha::SFTP::Server;

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

use Koha::Database;
use Koha::Exceptions::Object;
use Koha::Encryption;
use Koha::Logger;
use Koha::SFTP::Servers;

use Try::Tiny qw( catch try );
use Mojo::JSON;
use Net::SFTP::Foreign;
use Net::FTP;
use File::Spec;
use IO::File;

use base qw(Koha::Object);

=head1 NAME

Koha::SFTP::Server - Koha SFTP Server Object class

=head1 API

=head2 Class methods

=head3 store

    $server->store;

Overloaded store method that ensures directory paths end with a forward slash.

=cut

sub store {
    my ($self) = @_;

    for my $dir_field (qw( download_directory upload_directory )) {
        my $dir = $self->$dir_field;
        next unless $dir && $dir ne '';

        $self->$dir_field( $dir . '/' ) unless substr( $dir, -1 ) eq '/';
    }

    return $self->SUPER::store;
}

=head3 to_api

    my $json = $sftp_server->to_api;

Returns a JSON representation of the object suitable for API output,
excluding sensitive data.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $json_sftp = $self->SUPER::to_api($params) or return;
    delete $json_sftp->{password};
    delete $json_sftp->{key_file};

    return $json_sftp;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::SFTP::Server object
on the API.

=cut

sub to_api_mapping {
    return { id => 'sftp_server_id' };
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

=head3 write_key_file

    my $success = $server->write_key_file;

Writes the keyfile from the db into a file.

Returns 1 on success, undef on failure.

=cut

sub write_key_file {
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

=head3 locate_key_file

    my $path = $server->locate_key_file;

Returns the keyfile's path if it exists, undef otherwise.

=cut

sub locate_key_file {
    my ($self) = @_;

    my $upload_path = C4::Context->config('upload_path') or return;
    my $key_file    = File::Spec->catfile(
        $upload_path,
        'ssh_keys',
        'id_ssh_' . $self->id
    );

    return ( -f $key_file ) ? $key_file : undef;
}

=head3 update_password

    my $success = $server->update_password;

Update the server's encrypted password.

=cut

sub update_password {
    my ( $self, $value ) = @_;
    return unless defined $value;

    $self->password( Koha::Encryption->new->encrypt_hex($value) );
    return $self->SUPER::store;
}

=head3 update_key_file

    my $success = $server->update_key_file($new_key_file);

Update the server's encrypted key file.

=cut

sub update_key_file {
    my ( $self, $value ) = @_;
    return unless defined $value;

    $self->key_file( Koha::Encryption->new->encrypt_hex( _dos2unix($value) ) );
    return $self->SUPER::store;
}

=head3 update_status

    my $success = $server->update_status($new_status);

Update the server's status

=cut

sub update_status {
    my ( $self, $value ) = @_;
    return unless defined $value;

    return $self->set( { status => $value } )->store;
}

=head3 test_conn

    my ($success, $results) = $server->test_conn;

Tests connection to the server. Returns success flag and detailed test results.

=cut

sub test_conn {
    my ($self) = @_;
    my $default_result = {
        passed => Mojo::JSON->false,
        err    => undef,
        msg    => undef,
    };
    my $sftp_test_results;

    if ( $self->transport eq 'sftp' ) {
        $sftp_test_results->{'1_sftp_conn'} = {%$default_result};
        my $sftp = Net::SFTP::Foreign->new(
            host     => $self->host,
            user     => $self->user_name,
            password => $self->plain_text_password,
            key_path => $self->locate_key_file,
            port     => $self->port,
            timeout  => 10,
            more     => [
                qw(-vv),
                qw(-o StrictHostKeyChecking=no),
            ],
        );
        unless ( $sftp->error ) {
            $sftp_test_results->{'1_sftp_conn'}->{'passed'} = Mojo::JSON->true;
            $sftp_test_results->{'1_sftp_conn'}->{'msg'}    = $sftp->status;
        } else {
            $sftp_test_results->{'1_sftp_conn'}->{'err'} = $sftp->error;
        }

        unless ( $sftp->error ) {
            unless ( $self->download_directory eq '' ) {
                $sftp_test_results->{'2a_sftp_cwd_dl'} = {%$default_result};
                $sftp->setcwd( $self->download_directory );
                unless ( $sftp->error ) {
                    $sftp_test_results->{'2a_sftp_cwd_dl'}->{'passed'} = Mojo::JSON->true;
                    $sftp_test_results->{'2a_sftp_cwd_dl'}->{'msg'}    = $sftp->status;
                } else {
                    $sftp_test_results->{'2a_sftp_cwd_dl'}->{'err'} = $sftp->error;
                }
            }

            $sftp_test_results->{'2b_sftp_ls_dl'} = {%$default_result};
            $sftp->ls();
            unless ( $sftp->error ) {
                $sftp_test_results->{'2b_sftp_ls_dl'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'2b_sftp_ls_dl'}->{'msg'}    = $sftp->status;
            } else {
                $sftp_test_results->{'2b_sftp_ls_dl'}->{'err'} = $sftp->error;
            }

            unless ( $self->upload_directory eq '' ) {
                $sftp_test_results->{'2c_sftp_cwd_ul'} = {%$default_result};
                $sftp->setcwd( $self->upload_directory );
                unless ( $sftp->error ) {
                    $sftp_test_results->{'2c_sftp_cwd_ul'}->{'passed'} = Mojo::JSON->true;
                    $sftp_test_results->{'2c_sftp_cwd_ul'}->{'msg'}    = $sftp->status;
                } else {
                    $sftp_test_results->{'2c_sftp_cwd_ul'}->{'err'} = $sftp->error;
                }
            }

            $sftp_test_results->{'2d_sftp_ls_ul'} = {%$default_result};
            $sftp->ls( $self->upload_directory );
            unless ( $sftp->error ) {
                $sftp_test_results->{'2d_sftp_ls_ul'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'2d_sftp_ls_ul'}->{'msg'}    = $sftp->status;
            } else {
                $sftp_test_results->{'2d_sftp_ls_ul'}->{'err'} = $sftp->error;
            }

            $sftp_test_results->{'3_sftp_write'} = {%$default_result};
            open my $fh, '<', \"Hello, world!\n";
            close $fh if ( $sftp->put( $fh, $self->upload_directory . '.koha_test_file' ) );
            unless ( $sftp->error ) {
                $sftp_test_results->{'3_sftp_write'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'3_sftp_write'}->{'msg'}    = $sftp->status;
            } else {
                $sftp_test_results->{'3_sftp_write'}->{'err'} = $sftp->error;
            }

            $sftp_test_results->{'4_sftp_del'} = {%$default_result};
            $sftp->remove( $self->upload_directory . '.koha_test_file' );
            unless ( $sftp->error ) {
                $sftp_test_results->{'4_sftp_del'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'4_sftp_del'}->{'msg'}    = $sftp->status;
            } else {
                $sftp_test_results->{'4_sftp_del'}->{'err'} = $sftp->error;
            }
        }
    } elsif ( $self->transport eq 'ftp' ) {
        $sftp_test_results->{'1_ftp_conn'} = {%$default_result};
        my $ftp = Net::FTP->new(
            $self->host,
            Port    => $self->port,
            Timeout => 10,
            Passive => ( scalar $self->passive ) ? 1 : 0,
        );
        if ($ftp) {
            $sftp_test_results->{'1_ftp_conn'}->{'passed'} = Mojo::JSON->true;
            $sftp_test_results->{'1_ftp_conn'}->{'msg'}    = $ftp->message;
        } else {
            $sftp_test_results->{'1_ftp_conn'}->{'err'} = 'cannot connect to ' . $self->host . ': ' . $@;
        }

        if ($ftp) {
            $sftp_test_results->{'2_ftp_login'} = {%$default_result};
            my $login = $ftp->login(
                $self->user_name,
                $self->plain_text_password,
            );
            if ($login) {
                $sftp_test_results->{'2_ftp_login'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'2_ftp_login'}->{'msg'}    = $ftp->message;
            } else {
                $sftp_test_results->{'2_ftp_login'}->{'err'} = $ftp->message;
            }

            unless ( $self->download_directory eq '' ) {
                $sftp_test_results->{'3a_ftp_cwd_dl'} = {%$default_result};
                my $cwd_dl = $ftp->cwd( $self->download_directory );
                if ($cwd_dl) {
                    $sftp_test_results->{'3a_ftp_cwd_dl'}->{'passed'} = Mojo::JSON->true;
                    $sftp_test_results->{'3a_ftp_cwd_dl'}->{'msg'}    = $ftp->message;
                } else {
                    $sftp_test_results->{'3a_ftp_cwd_dl'}->{'err'} = $ftp->message;
                }
            }

            $sftp_test_results->{'3b_ftp_ls_dl'} = {%$default_result};
            my $ls_dl = $ftp->ls();
            if ($ls_dl) {
                $sftp_test_results->{'3b_ftp_ls_dl'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'3b_ftp_ls_dl'}->{'msg'}    = $ftp->message;
            } else {
                $sftp_test_results->{'3b_ftp_ls_dl'}->{'err'} = $ftp->message;
            }

            unless ( $self->upload_directory eq '' ) {
                $sftp_test_results->{'3c_ftp_cwd_ul'} = {%$default_result};
                my $cwd_ul = $ftp->cwd( $self->upload_directory );
                if ($cwd_ul) {
                    $sftp_test_results->{'3c_ftp_cwd_ul'}->{'passed'} = Mojo::JSON->true;
                    $sftp_test_results->{'3c_ftp_cwd_ul'}->{'msg'}    = $ftp->message;
                } else {
                    $sftp_test_results->{'3c_ftp_cwd_ul'}->{'err'} = $ftp->message;
                }
            }

            $sftp_test_results->{'3d_ftp_ls_ul'} = {%$default_result};
            my $ls_ul = $ftp->ls();
            if ($ls_ul) {
                $sftp_test_results->{'3d_ftp_ls_ul'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'3d_ftp_ls_ul'}->{'msg'}    = $ftp->message;
            } else {
                $sftp_test_results->{'3d_ftp_ls_ul'}->{'err'} = $ftp->message;
            }

            $sftp_test_results->{'4_ftp_write'} = {%$default_result};
            open my $fh, '<', \"Hello, world!\n";
            close $fh if ( my $put = $ftp->put( $fh, $self->upload_directory . '.koha_test_file' ) );
            if ($put) {
                $sftp_test_results->{'4_ftp_write'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'4_ftp_write'}->{'msg'}    = $ftp->message;
            } else {
                $sftp_test_results->{'4_ftp_write'}->{'err'} = $ftp->message;
            }

            $sftp_test_results->{'5_ftp_del'} = {%$default_result};
            my $delete = $ftp->delete( $self->upload_directory . '.koha_test_file' );
            if ($delete) {
                $sftp_test_results->{'5_ftp_del'}->{'passed'} = Mojo::JSON->true;
                $sftp_test_results->{'5_ftp_del'}->{'msg'}    = $ftp->message;
            } else {
                $sftp_test_results->{'5_ftp_del'}->{'err'} = $ftp->message;
            }
        }
    }

    #    $self->update_status('tests_ok');
    #    foreach my $val ( values %$sftp_test_results ) {
    #        if ( defined $val->{'err'} ) {
    #            $self->update_status('tests_failed');
    #        }
    #    }

    return ( 1, $sftp_test_results );
}

=head2 Internal methods

=head3 _dos2unix

Return a CR-free string from an input

=cut

sub _dos2unix {
    my $dosStr = shift;

    return $dosStr =~ s/\015\012/\012/gr;
}

=head3 _type

Return type of Object relating to Schema ResultSet

=cut

sub _type {
    return 'SftpServer';
}

1;
