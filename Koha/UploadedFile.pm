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

#use Koha::Database;

use parent qw(Koha::Object);

=head1 NAME

Koha::UploadedFile - Koha::Object class for single uploaded file

=head1 SYNOPSIS

use Koha::UploadedFile;

=head1 DESCRIPTION

Description

=head1 METHODS

=head2 INSTANCE METHODS

=head3 delete

Delete uploaded file.
It deletes not only the record, but also the actual file.

Returns filename on successful delete or undef.

=cut

sub delete {
    my ( $self ) = @_;

    my $name = $self->filename;
    my $file = $self->full_path;

    if( !-e $file ) { # we will just delete the record
        warn "Removing record for $name within category ".
            $self->uploadcategorycode. ", but file was missing.";
        return $name if $self->SUPER::delete;
    } elsif( unlink($file) ) {
        return $name if $self->SUPER::delete;
    } else {
        warn "Problem while deleting: $file";
    }
    return; # something went wrong
}

=head3 full_path

Returns the fully qualified path name for an uploaded file.

=cut

sub full_path {
    my ( $self ) = @_;
    my $path = File::Spec->catfile(
        $self->permanent?
            $self->permanent_directory: $self->temporary_directory,
        $self->dir,
        $self->hashvalue. '_'. $self->filename,
    );
    return $path;
}

=head2 CLASS METHODS

=head3 root_directory

=cut

sub permanent_directory {
    my ( $class ) = @_;
    return C4::Context->config('upload_path');
}

=head3 tmp_directory

=cut

sub temporary_directory {
    my ( $class ) = @_;
    return File::Spec->tmpdir;
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
