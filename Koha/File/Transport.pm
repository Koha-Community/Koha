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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use constant {
    DEFAULT_TIMEOUT   => 10,
    TEST_FILE_NAME    => '.koha_test_file',
    TEST_FILE_CONTENT => "Hello, world!\n",
};
use JSON            qw( decode_json encode_json );
use List::MoreUtils qw( any );

use Koha::Database;
use Koha::Exceptions::Object;
use Koha::Encryption;

use base qw(Koha::Object);

=head1 NAME

Koha::File::Transport - Base class for file transport handling

=head1 SYNOPSIS

    use Koha::File::Transports;

    # Create/retrieve a transport (polymorphic - returns SFTP/FTP/Local subclass)
    my $transport = Koha::File::Transports->find($id);

    # SIMPLIFIED API (recommended) - connection and directory management are automatic
    # Connections are established on-demand and directories are managed automatically

    # Example 1: Upload to custom path (connection happens automatically)
    $transport->upload_file('/local/file.txt', 'remote.txt', { path => '/custom/dir/' });

    # Example 2: Download using configured download_directory (auto-managed)
    $transport->download_file('remote.txt', '/local/file.txt');

    # Example 3: List files in custom directory (one-shot operation)
    my $files = $transport->list_files({ path => '/some/directory/' });

    # TRADITIONAL API - manual connection and directory management
    # Useful when you need fine-grained control or want to perform multiple
    # operations in the same directory without repeating the path

    $transport->connect();                          # Optional - will auto-connect if omitted
    $transport->change_directory('/work/dir/');     # Sets working directory
    $transport->upload_file('/local/1.txt', '1.txt');
    $transport->upload_file('/local/2.txt', '2.txt'); # Uses same directory
    my $files = $transport->list_files();           # Lists /work/dir/
    $transport->rename_file('1.txt', '1_old.txt');
    $transport->download_file('2.txt', '/local/2.txt');
    $transport->disconnect();                       # Optional - cleaned up automatically

    # HYBRID APPROACH - mixing both APIs
    # Once you explicitly set a directory, auto-management is disabled

    $transport->change_directory('/work/dir/');     # Explicit directory change
    $transport->upload_file('/local/file.txt', 'file.txt');  # Uses /work/dir/
    $transport->list_files();                       # Still uses /work/dir/
    # The configured upload_directory/download_directory won't be used anymore

=head1 DESCRIPTION

Base class providing common functionality for FTP/SFTP/Local file transport.

This class supports two distinct usage patterns:

=head2 Simplified API (Auto-Managing)

The simplified API automatically manages connections and directories:

=over 4

=item * B<Automatic Connection Management>

You never need to call connect() or disconnect(). Connections are established
on-demand when you call file operation methods and are automatically cleaned
up when the object is destroyed.

=item * B<Flexible Directory Management>

Each file operation (upload_file, download_file, list_files) accepts an optional
options hashref with a 'path' key to specify a custom directory for that operation:

    $transport->upload_file($local, $remote, { path => '/custom/dir/' });

If no path is provided, the transport uses its configured upload_directory
(for uploads) or download_directory (for downloads/listings).

=item * B<No State Maintained>

Each operation is independent. The transport doesn't remember which directory
you used in previous operations, making the API stateless and safe for
concurrent usage patterns.

=back

=head2 Traditional API (Explicit Control)

The traditional API provides manual control over connection and directory state:

=over 4

=item * B<Explicit Connection Control>

While connect() and disconnect() are still available and can be called explicitly,
they are entirely optional. The simplified API manages connections automatically.

=item * B<Stateful Directory Management>

Once you call change_directory() explicitly, the transport switches to "manual mode"
and remembers your working directory. Subsequent operations will use this directory
and automatic directory management is disabled:

    $transport->change_directory('/work/');
    $transport->upload_file($local, $remote);     # Uses /work/, not upload_directory
    $transport->list_files();                     # Lists /work/, not download_directory

=item * B<Session-Based Operations>

This is useful when you need to perform multiple operations in the same directory
without repeating the path parameter each time.

=back

=head2 How It Works

The implementation uses a C<_user_set_directory> flag to track which mode is active:

=over 4

=item * When you call change_directory() explicitly, the flag is set to true

=item * When the flag is true, auto-directory management is disabled

=item * When the flag is false (default), operations use their path option or fall back to configured directories

=item * The flag is reset to false when a new connection is established

=back

This design allows you to mix both approaches in the same codebase, choosing
the right pattern for each use case.

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

    my @config_fields  = (qw(host port user_name password key_file upload_directory download_directory));
    my $changed_config = ( !$self->in_storage || any { $self->_result->is_column_changed($_) } @config_fields ) ? 1 : 0;

    # Store
    $self->SUPER::store;

    # Subclass triggers
    my $subclass_map = {
        'sftp'  => 'Koha::File::Transport::SFTP',
        'ftp'   => 'Koha::File::Transport::FTP',
        'local' => 'Koha::File::Transport::Local',
    };
    my $subclass = $subclass_map->{ $self->transport } || 'Koha::File::Transport';
    $self = $subclass->_new_from_dbic( $self->_result );
    $self->_post_store_trigger;

    # Enqueue a connection test
    if ($changed_config) {
        require Koha::BackgroundJob::TestTransport;
        Koha::BackgroundJob::TestTransport->new->enqueue( { transport_id => $self->id } );
    }

    # Return the updated object including the encrypt_sensitive_data
    return $self;
}

=head3 _ensure_connected

    $transport->_ensure_connected();

Internal method that ensures a connection exists, connecting if needed.
Returns true if connected, false if connection failed.

=cut

sub _ensure_connected {
    my ($self) = @_;

    # Check if already connected (transport-specific)
    return 1 if $self->_is_connected();

    # Attempt to connect (which will reset directory state)
    return $self->connect();
}

=head3 _is_connected

    my $connected = $transport->_is_connected();

Internal method to check if transport is currently connected.
Must be implemented by subclasses.

=cut

sub _is_connected {
    my ($self) = @_;
    die "Subclass must implement _is_connected";
}

=head3 _auto_change_directory

    $transport->_auto_change_directory($dir_type, $custom_path);

Internal method that automatically changes to the appropriate directory.
$dir_type is 'upload' or 'download', $custom_path is optional override.

=cut

sub _auto_change_directory {
    my ( $self, $dir_type, $custom_path ) = @_;

    my $target_dir;
    if ($custom_path) {
        $target_dir = $custom_path;
    } elsif ( $dir_type eq 'upload' ) {
        $target_dir = $self->upload_directory;
    } elsif ( $dir_type eq 'download' ) {
        $target_dir = $self->download_directory;
    }

    return 1 unless $target_dir;    # No directory to change to

    # Call the internal _change_directory directly to avoid setting the flag
    # Only explicit user calls to change_directory() should set the flag
    return $self->_change_directory($target_dir);
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
    delete @{$json}{qw(password key_file)};                                    # Remove sensitive data
    $json->{status} = $self->status ? decode_json( $self->status ) : undef;    # Decode json status

    return $json;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::File::Transport object
on the API.

=cut

sub to_api_mapping {
    return { id => 'file_transport_id' };
}

=head3 test_connection

    $transport->test_connection

Method to test the connection for the configuration of the current file server

=cut

sub test_connection {
    my ($self) = @_;

    $self->connect or return;

    for my $dir_type (qw(download upload)) {
        my $field = "${dir_type}_directory";
        my $dir   = $self->$field;
        $dir ||= undef;

        $self->change_directory(undef) or next;
        $self->change_directory($dir)  or next;
        $self->list_files()            or next;
    }

    my $return   = 1;
    my $messages = $self->object_messages;
    for my $message ( @{$messages} ) {
        $return = 0 if $message->type eq 'error';
    }

    return $return;
}

=head2 Subclass methods

Interface methods that must be implemented by subclasses

=head3 connect

    my $success = $transport->connect();

Establishes a connection to the remote server.

B<Note:> Calling this method is entirely optional. All file operations
(upload_file, download_file, list_files, etc.) automatically establish
a connection if one doesn't already exist. You only need to call this
explicitly if you want to verify connectivity before performing operations.

B<Returns:> True on success, undef on failure. Check object_messages() for details.

=cut

sub connect {
    my ($self) = @_;

    # Reset directory state on new connection
    $self->{_user_set_directory} = 0;

    return $self->_connect();
}

=head3 _connect

    my $success = $transport->_connect();

Internal method that performs the protocol-specific connection operation.
Must be implemented by subclasses. Called by connect() after resetting
directory state.

=cut

sub _connect {
    my ($self) = @_;
    die "Subclass must implement _connect";
}

=head3 upload_file

    # Signature:
    my $success = $transport->upload_file($local_file, $remote_file, \%options);

Uploads a file to the remote server. Automatically establishes a connection if needed.

B<Parameters:>

=over 4

=item * C<$local_file> - Path to local file to upload (required)

=item * C<$remote_file> - Remote filename (not a path, just the filename) (required)

=item * C<\%options> - Optional hashref with keys:

=over 4

=item * C<path> - Directory path to upload to. If provided, uses this directory
for this operation only (simplified API). If omitted, behavior depends on whether
change_directory() has been called explicitly (see DESCRIPTION).

=back

=back

B<Usage Patterns:>

    # Pattern 1: Simplified API with custom path
    $transport->upload_file('/tmp/data.csv', 'data.csv', { path => '/uploads/' });

    # Pattern 2: Simplified API with configured upload_directory
    $transport->upload_file('/tmp/data.csv', 'data.csv');

    # Pattern 3: Traditional API with explicit directory
    $transport->change_directory('/uploads/');
    $transport->upload_file('/tmp/data.csv', 'data.csv');

B<Returns:> True on success, undef on failure. Check object_messages() for details.

=cut

sub upload_file {
    my ( $self, $local_file, $remote_file, $options ) = @_;

    return unless $self->_ensure_connected();

    # Only auto-change directory if:
    # 1. Options provided with custom path (simplified API), OR
    # 2. No explicit directory set by user AND default upload_directory exists (traditional API)
    if ( $options && $options->{path} ) {

        # Simplified API - use custom path
        return unless $self->_auto_change_directory( 'upload', $options->{path} );
    } elsif ( !$self->{_user_set_directory} ) {

        # Traditional API - use default directory only if user hasn't set one
        return unless $self->_auto_change_directory( 'upload', undef );
    }

    return $self->_upload_file( $local_file, $remote_file );
}

=head3 _upload_file

    $transport->_upload_file($local_file, $remote_file);

Internal method that performs the protocol-specific upload operation.
Must be implemented by subclasses. Called by upload_file after connection
and directory management.

=cut

sub _upload_file {
    my ($self) = @_;
    die "Subclass must implement _upload_file";
}

=head3 download_file

    # Signature:
    my $success = $transport->download_file($remote_file, $local_file, \%options);

Downloads a file from the remote server. Automatically establishes a connection if needed.

B<Parameters:>

=over 4

=item * C<$remote_file> - Remote filename (not a path, just the filename) (required)

=item * C<$local_file> - Path where the downloaded file should be saved (required)

=item * C<\%options> - Optional hashref with keys:

=over 4

=item * C<path> - Directory path to download from. If provided, uses this directory
for this operation only (simplified API). If omitted, behavior depends on whether
change_directory() has been called explicitly (see DESCRIPTION).

=back

=back

B<Usage Patterns:>

    # Pattern 1: Simplified API with custom path
    $transport->download_file('data.csv', '/tmp/data.csv', { path => '/downloads/' });

    # Pattern 2: Simplified API with configured download_directory
    $transport->download_file('data.csv', '/tmp/data.csv');

    # Pattern 3: Traditional API with explicit directory
    $transport->change_directory('/downloads/');
    $transport->download_file('data.csv', '/tmp/data.csv');

B<Returns:> True on success, undef on failure. Check object_messages() for details.

=cut

sub download_file {
    my ( $self, $remote_file, $local_file, $options ) = @_;

    return unless $self->_ensure_connected();

    # Only auto-change directory if:
    # 1. Options provided with custom path (simplified API), OR
    # 2. No explicit directory set by user AND default download_directory exists (traditional API)
    if ( $options && $options->{path} ) {

        # Simplified API - use custom path
        return unless $self->_auto_change_directory( 'download', $options->{path} );
    } elsif ( !$self->{_user_set_directory} ) {

        # Traditional API - use default directory only if user hasn't set one
        return unless $self->_auto_change_directory( 'download', undef );
    }

    return $self->_download_file( $remote_file, $local_file );
}

=head3 _download_file

    $transport->_download_file($remote_file, $local_file);

Internal method that performs the protocol-specific download operation.
Must be implemented by subclasses. Called by download_file after connection
and directory management.

=cut

sub _download_file {
    my ($self) = @_;
    die "Subclass must implement _download_file";
}

=head3 rename_file

    my $success = $transport->rename_file($old_name, $new_name);

Method for renaming a file on the current file server

=cut

sub rename_file {
    my ( $self, $old_name, $new_name ) = @_;

    return unless $self->_ensure_connected();

    return $self->_rename_file( $old_name, $new_name );
}

=head3 _rename_file

    $transport->_rename_file($old_name, $new_name);

Internal method that performs the protocol-specific file rename operation.
Must be implemented by subclasses. Called by rename_file after connection
verification.

=cut

sub _rename_file {
    my ($self) = @_;
    die "Subclass must implement _rename_file";
}

=head3 list_files

    # Signature:
    my $files = $transport->list_files(\%options);

Lists files in a directory on the remote server. Automatically establishes a connection if needed.

B<Parameters:>

=over 4

=item * C<\%options> - Optional hashref with keys:

=over 4

=item * C<path> - Directory path to list files from. If provided, uses this directory
for this operation only (simplified API). If omitted, behavior depends on whether
change_directory() has been called explicitly (see DESCRIPTION).

=back

=back

B<Usage Patterns:>

    # Pattern 1: Simplified API with custom path
    my $files = $transport->list_files({ path => '/incoming/' });

    # Pattern 2: Simplified API with configured download_directory
    my $files = $transport->list_files();

    # Pattern 3: Traditional API with explicit directory
    $transport->change_directory('/incoming/');
    my $files = $transport->list_files();

B<Returns:> Arrayref of hashrefs on success, undef on failure. Each hashref contains
file metadata (filename, size, permissions, etc.). The exact structure varies by
transport type but always includes a 'filename' key.

=cut

sub list_files {
    my ( $self, $options ) = @_;

    return unless $self->_ensure_connected();

    # Only auto-change directory if:
    # 1. Options provided with custom path (simplified API), OR
    # 2. No explicit directory set by user AND default download_directory exists (traditional API)
    if ( $options && $options->{path} ) {

        # Simplified API - use custom path
        return unless $self->_auto_change_directory( 'download', $options->{path} );
    } elsif ( !$self->{_user_set_directory} ) {

        # Traditional API - use default directory only if user hasn't set one
        return unless $self->_auto_change_directory( 'download', undef );
    }

    return $self->_list_files();
}

=head3 _list_files

    my $files = $transport->_list_files();

Internal method that performs the protocol-specific file listing operation.
Must be implemented by subclasses. Called by list_files after connection
and directory management.

=cut

sub _list_files {
    my ($self) = @_;
    die "Subclass must implement _list_files";
}

=head3 disconnect

    $transport->disconnect();

Closes the connection to the remote server.

B<Note:> Calling this method is entirely optional. Connections are automatically
cleaned up when the transport object is destroyed (goes out of scope). You only
need to call this explicitly if you want to free resources before the object
is destroyed, such as in long-running processes.

B<Returns:> True on success, undef on failure.

=cut

sub disconnect {
    my ($self) = @_;

    # Reset directory state when disconnecting
    $self->{_user_set_directory} = 0;

    return $self->_disconnect();
}

=head3 _disconnect

    $transport->_disconnect();

Internal method that performs the protocol-specific disconnection operation.
Must be implemented by subclasses. Called by disconnect() after resetting
directory state.

=cut

sub _disconnect {
    my ($self) = @_;
    die "Subclass must implement _disconnect";
}

=head3 change_directory

    my $success = $transport->change_directory($path);

Changes the current working directory on the remote server.

B<Important:> Calling this method explicitly switches the transport to "manual mode"
and disables automatic directory management. After calling this method, all subsequent
file operations will use this directory (or relative paths from it) until you call
change_directory() again or create a new connection.

B<Parameters:>

=over 4

=item * C<$path> - Directory path to change to (required)

=back

B<Example:>

    # After calling change_directory explicitly:
    $transport->change_directory('/work/dir/');
    $transport->upload_file($local, $remote);  # Uses /work/dir/, not upload_directory
    $transport->list_files();                  # Lists /work/dir/, not download_directory

B<Returns:> True on success, undef on failure. Check object_messages() for details.

=cut

sub change_directory {
    my ( $self, $path ) = @_;

    # Mark that user has explicitly set a directory
    # This prevents auto-directory management from interfering
    $self->{_user_set_directory} = 1;

    return $self->_change_directory($path);
}

=head3 _change_directory

    my $success = $transport->_change_directory($path);

Internal method that performs the protocol-specific directory change operation.
Must be implemented by subclasses. Called by change_directory() after setting
the _user_set_directory flag.

=cut

sub _change_directory {
    my ($self) = @_;
    die "Subclass must implement _change_directory";
}

=head3 _post_store_trigger

    $server->_post_store_trigger;

Method triggered by parent store to allow local additions to the store call

=cut

sub _post_store_trigger {
    my ($self) = @_;

    #Subclass may implement a _post_store_trigger as required
    return $self;
}

=head2 Internal methods

=head3 _encrypt_sensitive_data

Handle encryption of sensitive data

=cut

sub _encrypt_sensitive_data {
    my ($self) = @_;
    my $encryption = Koha::Encryption->new;

    # Only encrypt if the value has changed ($self->_result->is_column_changed from Koha::Object)
    if ( ( !$self->in_storage || $self->_result->is_column_changed('password') ) && $self->password ) {
        $self->password( $encryption->encrypt_hex( $self->password ) );
    }

    if ( ( !$self->in_storage || $self->_result->is_column_changed('key_file') ) && $self->key_file ) {
        $self->key_file( $encryption->encrypt_hex( _dos2unix( $self->key_file ) ) );
    }

    return;
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
    return 'FileTransport';
}

1;
