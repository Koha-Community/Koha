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
use Time::Local qw( timegm );
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

=head3 _current_directory

    my $path = $self->_current_directory;

Internal method that returns the FTP connection's current working directory.

Net::FTP's own C<cwd()> method is a mutator: called with no argument it
defaults to "/" and issues a real C<CWD /> command, changing the connection's
directory as a side effect and returning a boolean rather than a path. The
read-only equivalent is C<pwd()>, which sends PWD and parses the path out of
the response without navigating anywhere.

=cut

sub _current_directory {
    my ($self) = @_;

    return $self->{connection}->pwd;
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
Each hashref contains: filename, longname, size, perms, mtime, type.

The listing is obtained with MLSD (RFC 3659), whose machine-readable output
is locale- and platform-independent and gives us the filename unambiguously
(the pathname is the entire text after the "facts" and a single space, so
filenames containing spaces are handled correctly). Servers that do not
support MLSD fall back to NLST, which returns bare filenames only.

This mirrors what Net::FTP does internally for rmdir(). Net::FTP 3.x exposes
no public MLSD method, so we drive it through its _list_cmd() helper - the
same private method that backs the public ls()/dir() and that Net::FTP's own
rmdir() uses for MLSD. That interface has been stable for many releases.

The hashref shape is kept consistent with the SFTP and Local transports so
that consumers of list_files() (including out-of-tree ones) can rely on the
same structure regardless of transport type.

=cut

sub _list_files {
    my ($self) = @_;
    my $operation = "list";

    my @file_list;

    # Prefer MLSD: machine-readable, no locale/format guessing. Net::FTP has
    # no public MLSD method, so use its internal _list_cmd() (as its own
    # rmdir() does). Returns an arrayref of "facts filename" lines, or undef.
    my $mlsd = $self->{connection}->_list_cmd("MLSD");

    if ( $mlsd && @{$mlsd} ) {
        foreach my $line ( @{$mlsd} ) {

            # Each line is "fact1=val;fact2=val;...; pathname"; the pathname is
            # everything after the facts and the single separating space.
            next unless $line =~ /^(.*?;)\s(.+)$/;
            my ( $facts_str, $filename ) = ( $1, $2 );

            my %fact =
                map { my ( $k, $v ) = split /=/, $_, 2; ( lc($k) => $v ) }
                grep { length } split /;/, $facts_str;

            # Skip only the current/parent directory pseudo-entries; real
            # subdirectories (type=dir) are now included like Local and SFTP.
            next if ( $fact{type} // q{} ) =~ /^(?:cdir|pdir)$/i;

            my $type =
                  ( $fact{type} // q{} ) eq 'file' ? 'file'
                : ( $fact{type} // q{} ) eq 'dir'  ? 'directory'
                :                                    'other';

            my $perms = $self->_perms_from_mlsd_facts( \%fact, $type );
            push @file_list, {
                filename => $filename,
                longname => $line,
                size     => $fact{size},
                perms    => $perms,
                mtime    => $self->_mtime_from_mlsd_fact( $fact{modify} ),
                type     => $type,
            };
        }
    } else {

        # Fallback for servers without MLSD: NLST returns bare filenames
        # only, so probe each entry with SIZE/MDTM (both plain Net::FTP
        # methods) to recover size, mtime and a best-effort type. A
        # permission-denied file would be misclassified as a directory here
        # (SIZE failing is the only signal available) - a rare, accepted
        # limitation of this legacy fallback path. perms stays undef: there
        # is no way to get Unix permission bits without MLSD/UNIX.mode.
        my $names = $self->{connection}->ls or return $self->_abort_operation($operation);
        foreach my $name ( grep { !/^[.]{1,2}$/ } @{$names} ) {
            my $size = $self->{connection}->size($name);
            push @file_list, {
                filename => $name,
                longname => undef,
                size     => $size,
                perms    => undef,
                mtime    => $self->{connection}->mdtm($name),
                type     => defined $size ? 'file' : 'directory',
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

=head3 _perms_from_mlsd_facts

    my $perms = $self->_perms_from_mlsd_facts( \%fact, $type );

Converts MLSD facts into the same C<"%04o"> Unix permission-bits string used
by the Local and SFTP transports.

Prefers the C<UNIX.mode> vendor-extension fact (exact Unix octal
permissions) when the server provides it. Otherwise approximates from the
RFC 3659 C<perm> fact, which describes only what the connected user is
allowed to do (append/create/delete/rename/list/mkdir/read/write/etc.), not
a real owner/group/other split - the resulting triad is mirrored across
owner/group/other since that distinction isn't available. Returns undef if
neither fact is present.

=cut

sub _perms_from_mlsd_facts {
    my ( $self, $fact, $type ) = @_;

    if ( defined $fact->{'unix.mode'} ) {
        return sprintf( "%04o", oct( $fact->{'unix.mode'} ) & oct('07777') );
    }

    my $perm = $fact->{perm};
    return unless defined $perm;

    my $bits = 0;
    $bits |= 4 if $perm                         =~ /r/;
    $bits |= 2 if $perm                         =~ /[wa]/;
    $bits |= 1 if $type eq 'directory' && $perm =~ /e/;

    return sprintf( "%04o", ( $bits << 6 ) | ( $bits << 3 ) | $bits );
}

=head3 _mtime_from_mlsd_fact

    my $mtime = $self->_mtime_from_mlsd_fact( $fact->{modify} );

Converts an MLSD C<modify> fact (RFC 3659 C<YYYYMMDDHHMMSS[.sss]> format,
always UTC) into a Unix epoch timestamp. Returns undef if the fact is
missing or doesn't match the expected format.

=cut

sub _mtime_from_mlsd_fact {
    my ( $self, $modify ) = @_;

    return unless defined $modify;
    return unless $modify =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})/;

    return eval { timegm( $6, $5, $4, $3, $2 - 1, $1 ) };
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

=head3 _abort_operation

    return $self->_abort_operation($operation);

Records an error message for the named operation, aborts any in-progress
transfer on the current connection and returns nothing, so callers can
C<return $self-E<gt>_abort_operation($operation)> on failure.

=cut

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
