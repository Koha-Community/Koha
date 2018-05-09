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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use utf8;
use DateTime;
use Carp;
use English qw{ -no_match_vars };
use Net::FTP;
use Net::SFTP::Foreign;
use File::Slurp;
use File::Copy;
use File::Basename qw( fileparse );
use Koha::UploadedFile;
use Koha::Database;
use Encode qw( from_to );

sub new {
    my ( $class, $account_id ) = @_;
    my $database = Koha::Database->new();
    my $schema   = $database->schema();
    my $acct     = $schema->resultset('VendorEdiAccount')->find($account_id);
    my $self     = {
        account     => $acct,
        schema      => $schema,
        working_dir => Koha::UploadedFile->temporary_directory,    #temporary work directory
        transfer_date => DateTime->now( time_zone => 'local' ),
    };

    bless $self, $class;
    return $self;
}

sub working_directory {
    my ( $self, $new_value ) = @_;
    if ($new_value) {
        $self->{working_directory} = $new_value;
    }
    return $self->{working_directory};
}

sub download_messages {
    my ( $self, $message_type ) = @_;
    $self->{message_type} = $message_type;

    my @retrieved_files;

    if ( $self->{account}->transport eq 'SFTP' ) {
        @retrieved_files = $self->sftp_download();
    }
    elsif ( $self->{account}->transport eq 'FILE' ) {
        @retrieved_files = $self->file_download();
    }
    else {    # assume FTP
        @retrieved_files = $self->ftp_download();
    }
    return @retrieved_files;
}

sub upload_messages {
    my ( $self, @messages ) = @_;
    if (@messages) {
        if ( $self->{account}->transport eq 'SFTP' ) {
            $self->sftp_upload(@messages);
        }
        elsif ( $self->{account}->transport eq 'FILE' ) {
            $self->file_upload(@messages);
        }
        else {    # assume FTP
            $self->ftp_upload(@messages);
        }
    }
    return;
}

sub file_download {
    my $self = shift;
    my @downloaded_files;

    my $file_ext = _get_file_ext( $self->{message_type} );

    my $dir = $self->{account}->download_directory;   # makes code more readable
         # C = ready to retrieve E = Edifact
    my $msg_hash = $self->message_hash();
    if ( opendir my $dh, $dir ) {
        my @file_list = readdir $dh;
        closedir $dh;
        foreach my $filename (@file_list) {

            if ( $filename =~ m/[.]$file_ext$/ ) {
                if ( copy( "$dir/$filename", $self->{working_dir} ) ) {
                }
                else {
                    carp "copy of $filename failed";
                    next;
                }
                push @downloaded_files, $filename;
                my $processed_name = $filename;
                substr $processed_name, -3, 1, 'E';
                move( "$dir/$filename", "$dir/$processed_name" );
            }
        }
        $self->ingest( $msg_hash, @downloaded_files );
    }
    else {
        carp "Cannot open $dir";
        return;
    }
    return @downloaded_files;
}

sub sftp_download {
    my $self = shift;

    my $file_ext = _get_file_ext( $self->{message_type} );

    # C = ready to retrieve E = Edifact
    my $msg_hash = $self->message_hash();
    my @downloaded_files;
    my $sftp = Net::SFTP::Foreign->new(
        host     => $self->{account}->host,
        user     => $self->{account}->username,
        password => $self->{account}->password,
        timeout  => 10,
    );
    if ( $sftp->error ) {
        return $self->_abort_download( undef,
            'Unable to connect to remote host: ' . $sftp->error );
    }
    $sftp->setcwd( $self->{account}->download_directory )
      or return $self->_abort_download( $sftp,
        "Cannot change remote dir : $sftp->error" );
    my $file_list = $sftp->ls()
      or return $self->_abort_download( $sftp,
        "cannot get file list from server: $sftp->error" );
    foreach my $file ( @{$file_list} ) {
        my $filename = $file->{filename};

        if ( $filename =~ m/[.]$file_ext$/ ) {
            $sftp->get( $filename, "$self->{working_dir}/$filename" );
            if ( $sftp->error ) {
                $self->_abort_download( $sftp,
                    "Error retrieving $filename: $sftp->error" );
                last;
            }
            push @downloaded_files, $filename;
            my $processed_name = $filename;
            substr $processed_name, -3, 1, 'E';

            #$sftp->atomic_rename( $filename, $processed_name );
            my $ret = $sftp->rename( $filename, $processed_name );
            if ( !$ret ) {
                $self->_abort_download( $sftp,
                    "Error renaming $filename: $sftp->error" );
                last;
            }

        }
    }
    $sftp->disconnect;
    $self->ingest( $msg_hash, @downloaded_files );

    return @downloaded_files;
}

sub ingest {
    my ( $self, $msg_hash, @downloaded_files ) = @_;
    foreach my $f (@downloaded_files) {
        $msg_hash->{filename} = $f;
        my $file_content =
          read_file( "$self->{working_dir}/$f", binmode => ':raw' );
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

sub ftp_download {
    my $self = shift;

    my $file_ext = _get_file_ext( $self->{message_type} );

    # C = ready to retrieve E = Edifact

    my $msg_hash = $self->message_hash();
    my @downloaded_files;
    my $ftp = Net::FTP->new(
        $self->{account}->host,
        Timeout => 10,
        Passive => 1
      )
      or return $self->_abort_download( undef,
        "Cannot connect to $self->{account}->host: $EVAL_ERROR" );
    $ftp->login( $self->{account}->username, $self->{account}->password )
      or return $self->_abort_download( $ftp, "Cannot login: $ftp->message()" );
    $ftp->cwd( $self->{account}->download_directory )
      or return $self->_abort_download( $ftp,
        "Cannot change remote dir : $ftp->message()" );
    my $file_list = $ftp->ls()
      or
      return $self->_abort_download( $ftp, 'cannot get file list from server' );

    foreach my $filename ( @{$file_list} ) {

        if ( $filename =~ m/[.]$file_ext$/ ) {

            if ( !$ftp->get( $filename, "$self->{working_dir}/$filename" ) ) {
                $self->_abort_download( $ftp,
                    "Error retrieving $filename: $ftp->message" );
                last;
            }

            push @downloaded_files, $filename;
            my $processed_name = $filename;
            substr $processed_name, -3, 1, 'E';
            $ftp->rename( $filename, $processed_name );
        }
    }
    $ftp->quit;

    $self->ingest( $msg_hash, @downloaded_files );

    return @downloaded_files;
}

sub ftp_upload {
    my ( $self, @messages ) = @_;
    my $ftp = Net::FTP->new(
        $self->{account}->host,
        Timeout => 10,
        Passive => 1
      )
      or return $self->_abort_download( undef,
        "Cannot connect to $self->{account}->host: $EVAL_ERROR" );
    $ftp->login( $self->{account}->username, $self->{account}->password )
      or return $self->_abort_download( $ftp, "Cannot login: $ftp->message()" );
    $ftp->cwd( $self->{account}->upload_directory )
      or return $self->_abort_download( $ftp,
        "Cannot change remote dir : $ftp->message()" );
    foreach my $m (@messages) {
        my $content = $m->raw_msg;
        if ($content) {
            open my $fh, '<', \$content;
            if ( $ftp->put( $fh, $m->filename ) ) {
                close $fh;
                $m->transfer_date( $self->{transfer_date} );
                $m->status('sent');
                $m->update;
            }
            else {
                # error in transfer

            }
        }
    }

    $ftp->quit;
    return;
}

sub sftp_upload {
    my ( $self, @messages ) = @_;
    my $sftp = Net::SFTP::Foreign->new(
        host     => $self->{account}->host,
        user     => $self->{account}->username,
        password => $self->{account}->password,
        timeout  => 10,
    );
    $sftp->die_on_error("Cannot ssh to $self->{account}->host");
    $sftp->setcwd( $self->{account}->upload_directory )
      or return $self->_abort_download( $sftp,
        "Cannot change remote dir : $sftp->error" );
    foreach my $m (@messages) {
        my $content = $m->raw_msg;
        if ($content) {
            open my $fh, '<', \$content;
            if ( $sftp->put( $fh, $m->filename ) ) {
                close $fh;
                $m->transfer_date( $self->{transfer_date} );
                $m->status('sent');
                $m->update;
            }
            else {
                # error in transfer

            }
        }
    }

    # sftp will be closed on object destructor
    return;
}

sub file_upload {
    my ( $self, @messages ) = @_;
    my $dir = $self->{account}->upload_directory;
    if ( -d $dir ) {
        foreach my $m (@messages) {
            my $content = $m->raw_msg;
            if ($content) {
                my $filename     = $m->filename;
                my $new_filename = "$dir/$filename";
                if ( open my $fh, '>', $new_filename ) {
                    print {$fh} $content;
                    close $fh;
                    $m->transfer_date( $self->{transfer_date} );
                    $m->status('sent');
                    $m->update;
                }
                else {
                    carp "Could not transfer $m->filename : $ERRNO";
                    next;
                }
            }
        }
    }
    else {
        carp "Upload directory $dir does not exist";
    }
    return;
}

sub _abort_download {
    my ( $self, $handle, $log_message ) = @_;

    my $a = $self->{account}->description;

    if ($handle) {
        $handle->abort();
    }
    $log_message .= ": $a";
    carp $log_message;

    #returns undef i.e. an empty array
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

Module that handles Edifact download and upload transport
currently can use sftp or ftp
Or FILE to access a local directory (useful for testing)


=head1 METHODS

=head2 new

    Creates an object of Edifact::Transport requires to be passed the id
    identifying the relevant edi vendor account

=head2 working_directory

    getter and setter for the working_directory attribute

=head2 download_messages

    called with the message type to download will perform the download
    using the appropriate transport method

=head2 upload_messages

   passed an array of messages will upload them to the supplier site

=head2 sftp_download

   called by download_messages to perform the download using SFTP

=head2 ingest

   loads downloaded files into the database

=head2 ftp_download

   called by download_messages to perform the download using FTP

=head2 ftp_upload

  called by upload_messages to perform the upload using ftp

=head2 sftp_upload

  called by upload_messages to perform the upload using sftp

=head2 _abort_download

   internal routine to halt operation on error and supply a stacktrace

=head2 _get_file_ext

   internal method returning standard suffix for file names
   according to message type

=head2 set_transport_direct

  sets the direct ingest flag so that the object reads files from
  the local file system useful in debugging

=head1 AUTHOR

   Colin Campbell <colin.campbell@ptfs-europe.com>


=head1 COPYRIGHT

   Copyright 2014,2015 PTFS-Europe Ltd
   This program is free software, You may redistribute it under
   under the terms of the GNU General Public License


=cut
