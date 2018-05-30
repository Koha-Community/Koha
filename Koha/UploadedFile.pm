package Koha::UploadedFile;

# Copyright Rijksmuseum 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use File::Spec;

use parent qw(Koha::Object);

=head1 NAME

Koha::UploadedFile - Koha::Object class for single uploaded file

=head1 SYNOPSIS

    use Koha::UploadedFile;

    # store record in uploaded_files
    my $upload = Koha::UploadedFile->new({ [columns and values] });

    # get a file handle on an uploaded_file
    my $fh = $upload->file_handle;

    # get full path
    my $path = $upload->full_path;

    # delete uploaded file
    $upload->delete;

=head1 DESCRIPTION

Allows regular CRUD operations on uploaded_files via Koha::Object / DBIx.

The delete method also takes care of deleting files. The full_path method
returns a fully qualified path for an upload.

Additional methods include: file_handle, httpheaders.

=head1 METHODS

=head2 INSTANCE METHODS

=head3 delete

Delete uploaded file.
It deletes not only the record, but also the actual file (unless you pass
the keep_file parameter).

Returns number of deleted records (1 or 0E0), or -1 for unknown.
Please keep in mind that a deleted record does not automatically imply a
deleted file; a warning may have been raised.
(TODO: Use exceptions.)

=cut

sub delete {
    my ( $self, $params ) = @_;

    my $name = $self->filename;
    my $file = $self->full_path;

    my $retval = $self->SUPER::delete;
    if( !defined($retval) ) { # undef is Unknown (-1)
        $retval = -1;
    } elsif( $retval eq '0' ) { # 0 => 0E0
        $retval = "0E0";
    } elsif( $retval !~ /^(0E0|1)$/ ) { # Unknown too
        $retval = -1;
    }
    return $retval if $params->{keep_file};

    if( ! -e $file ) {
        warn "Removing record for $name within category ".
            $self->uploadcategorycode. ", but file was missing.";
    } elsif( ! unlink($file) ) {
        warn "Problem while deleting: $file";
    }
    return $retval;
}

=head3 full_path

Returns the fully qualified path name for an uploaded file.

=cut

sub full_path {
    my ( $self ) = @_;
    my $path = File::Spec->catfile(
        $self->permanent
            ? $self->permanent_directory
            : C4::Context->temporary_directory,
        $self->dir,
        $self->hashvalue. '_'. $self->filename,
    );
    return $path;
}

=head3 file_handle

Returns a file handle for an uploaded file.

=cut

sub file_handle {
    my ( $self ) = @_;
    $self->{_file_handle} = IO::File->new( $self->full_path, "r" );
    return if !$self->{_file_handle};
    $self->{_file_handle}->binmode;
    return $self->{_file_handle};
}

=head3 httpheaders

httpheaders returns http headers for a retrievable upload.

Will be extended by report 14282

=cut

sub httpheaders {
    my ( $self ) = @_;
    if( $self->filename =~ /\.pdf$/ ) {
        return (
            '-type'       => 'application/pdf',
            'Content-Disposition' => 'inline; filename='.$self->filename,
        );
    } else {
        return (
            '-type'       => 'application/octet-stream',
            '-attachment' => $self->filename,
        );
    }
}

=head2 CLASS METHODS

=head3 permanent_directory

Returns root directory for permanent storage

=cut

sub permanent_directory {
    my ( $class ) = @_;
    return C4::Context->config('upload_path');
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'UploadedFile';
}

=head1 AUTHOR

Marcel de Rooy (Rijksmuseum)

Koha Development Team

=cut

1;
