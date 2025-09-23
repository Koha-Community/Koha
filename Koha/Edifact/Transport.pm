package Koha::Edifact::Transport;

# Copyright 2014,2015 PTFS-Europe Ltd
#
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

use utf8;

use Carp        qw( carp );
use Encode      qw( from_to );
use File::Slurp qw( read_file );

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::File::Transports;

sub new {
    my ( $class, $account_id ) = @_;
    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $acct     = $schema->resultset('VendorEdiAccount')->find($account_id);

    # Get the file transport if configured
    my $file_transport = $acct->file_transport_id ? Koha::File::Transports->find( $acct->file_transport_id ) : undef;

    my $self = {
        account        => $acct,
        schema         => $schema,
        file_transport => $file_transport,
        working_dir    => C4::Context::temporary_directory,    #temporary work directory
        transfer_date  => dt_from_string(),
    };

    bless $self, $class;
    return $self;
}

sub working_directory {
    my ( $self, $new_value ) = @_;
    if ($new_value) {
        $self->{working_dir} = $new_value;
    }
    return $self->{working_dir};
}

sub download_messages {
    my ( $self, $message_type ) = @_;
    $self->{message_type} = $message_type;

    unless ( $self->{file_transport} ) {
        carp "No file transport configured for EDI account " . $self->{account}->id;
        return;
    }

    my $file_ext = _get_file_ext( $self->{message_type} );
    my $msg_hash = $self->message_hash();
    my @downloaded_files;

    # Connect to the transport
    unless ( $self->{file_transport}->connect() ) {
        carp "Failed to connect to file transport: " . $self->{file_transport}->id;
        return;
    }

    # Change to download directory
    my $download_dir = $self->{file_transport}->download_directory;
    if ( $download_dir && !$self->{file_transport}->change_directory($download_dir) ) {
        carp "Failed to change to download directory: $download_dir";
        return;
    }

    # Get file list
    my $file_list = $self->{file_transport}->list_files();
    unless ($file_list) {
        carp "Failed to get file list from transport";
        return;
    }

    # Process files matching our criteria
    foreach my $file ( @{$file_list} ) {
        my $filename = $file->{filename};

        if ( $filename =~ m/[.]$file_ext$/ ) {
            my $local_file = "$self->{working_dir}/$filename";

            # Download the file
            if ( $self->{file_transport}->download_file( $filename, $local_file ) ) {
                push @downloaded_files, $filename;

                # Rename file on server to mark as processed (EDI-specific behavior)
                my $processed_name = $filename;
                substr $processed_name, -3, 1, 'E';

                # Mark file as processed using the transport's rename functionality
                $self->{file_transport}->rename_file( $filename, $processed_name );
            } else {
                carp "Failed to download file: $filename";
            }
        }
    }

    # Ingest downloaded files
    $self->ingest( $msg_hash, @downloaded_files );

    # Clean up connection
    $self->{file_transport}->disconnect();

    return @downloaded_files;
}

sub upload_messages {
    my ( $self, @messages ) = @_;

    unless (@messages) {
        return;
    }

    unless ( $self->{file_transport} ) {
        carp "No file transport configured for EDI account " . $self->{account}->id;
        return;
    }

    # Connect to the transport
    unless ( $self->{file_transport}->connect() ) {
        carp "Failed to connect to file transport: " . $self->{file_transport}->id;
        return;
    }

    # Change to upload directory
    my $upload_dir = $self->{file_transport}->upload_directory;
    if ( $upload_dir && !$self->{file_transport}->change_directory($upload_dir) ) {
        carp "Failed to change to upload directory: $upload_dir";
        return;
    }

    foreach my $m (@messages) {
        my $content = $m->raw_msg;
        if ($content) {

            # Create temporary file for upload
            my $temp_file = "$self->{working_dir}/" . $m->filename;

            if ( open my $fh, '>', $temp_file ) {
                print {$fh} $content;
                close $fh;

                # Upload the file
                if ( $self->{file_transport}->upload_file( $temp_file, $m->filename ) ) {
                    $m->transfer_date( $self->{transfer_date} );
                    $m->status('sent');
                    $m->update;
                } else {
                    carp "Failed to upload file: " . $m->filename;
                }

                # Clean up temp file
                unlink $temp_file;
            } else {
                carp "Could not create temporary file for upload: " . $m->filename;
            }
        }
    }

    # Clean up connection
    $self->{file_transport}->disconnect();

    return;
}

sub ingest {
    my ( $self, $msg_hash, @downloaded_files ) = @_;
    foreach my $f (@downloaded_files) {

        # Check file has not been downloaded already
        my $existing_file = $self->{schema}->resultset('EdifactMessage')->find( { filename => $f, } );
        if ($existing_file) {
            carp "skipping ingest of $f : filename exists";
            next;
        }

        $msg_hash->{filename} = $f;
        my $file_content = read_file( "$self->{working_dir}/$f", binmode => ':raw' );
        if ( !defined $file_content ) {
            carp "Unable to read download file $f";
            next;
        }
        from_to( $file_content, 'iso-8859-1', 'utf8' );
        $msg_hash->{raw_msg} = $file_content;
        $self->{schema}->resultset('EdifactMessage')->create($msg_hash);
    }
    return;
}

sub _get_file_ext {
    my $type = shift;

    # Extension format
    # 1st char Status C = Ready For pickup A = Completed E = Extracted
    # 2nd Char Standard E = Edifact
    # 3rd Char Type of message
    my %file_types = (
        QUOTE   => 'CEQ',
        INVOICE => 'CEI',
        ORDRSP  => 'CEA',
        ALL     => 'CE.',
    );
    if ( exists $file_types{$type} ) {
        return $file_types{$type};
    }
    return 'XXXX';    # non matching type
}

sub message_hash {
    my $self = shift;
    my $msg  = {
        message_type  => $self->{message_type},
        vendor_id     => $self->{account}->vendor_id,
        edi_acct      => $self->{account}->id,
        status        => 'new',
        deleted       => 0,
        transfer_date => $self->{transfer_date}->ymd(),
    };

    return $msg;
}

1;
__END__

=head1 NAME

Koha::Edifact::Transport

=head1 SYNOPSIS

my $download = Koha::Edifact::Transport->new( $vendor_edi_account_id );
$downlowd->download_messages('QUOTE');


=head1 DESCRIPTION

Module that handles Edifact download and upload transport using the modern
Koha::File::Transport system. Supports SFTP, FTP, and local directory
operations through a unified interface.

=head1 METHODS

=head2 new

    Creates an object of Edifact::Transport requires to be passed the id
    identifying the relevant edi vendor account. The account must have a
    file_transport_id configured to use the modern transport system.

=head2 working_directory

    getter and setter for the working_directory attribute

=head2 download_messages

    called with the message type to download will perform the download
    using the configured file transport

=head2 upload_messages

   passed an array of messages will upload them to the supplier site
   using the configured file transport


=head2 ingest

   loads downloaded files into the database

=head2 _get_file_ext

   internal method returning standard suffix for file names
   according to message type

=head2 message_hash

   creates the message hash structure for storing in the database

=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>


=head1 COPYRIGHT

   Copyright 2014,2015 PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License


=cut
