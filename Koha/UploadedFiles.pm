package Koha::UploadedFiles;

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

#use Koha::Database;
use Koha::UploadedFile;

use parent qw(Koha::Objects);

=head1 NAME

Koha::UploadedFiles - Koha::Objects class for uploaded files

=head1 SYNOPSIS

use Koha::UploadedFiles;

=head1 DESCRIPTION

Description

=head1 METHODS

=head2 INSTANCE METHODS

=head3 delete, delete_errors

Delete uploaded files.
Returns true if no errors occur.
Delete_errors returns the number of errors when deleting files.

Parameter keep_file may be used to delete records, but keep files.

=cut

sub delete {
    my ( $self, $params ) = @_;
    # We use the individual delete on each resultset record
    my $err = 0;
    while( my $row = $self->_resultset->next ) {
        my $kohaobj = Koha::UploadedFile->_new_from_dbic( $row );
        $err++ if !$kohaobj->delete( $params );
    }
    $self->{delete_errors} = $err;
    return $err==0;
}

sub delete_errors {
    my ( $self ) = @_;
    return $self->{delete_errors};
}

=head3 search_term

Search_term allows you to pass a term to search in filename and hashvalue.
If you do not pass include_private, only public records are returned.

Is only a wrapper around Koha::Objects search. Has similar return value.

=cut

sub search_term {
    my ( $self, $params ) = @_;
    my $term = $params->{term} // '';
    my %public = ();
    if( !$params->{include_private} ) {
        %public = ( public => 1 );
    }
    return $self->search(
        [ { filename => { like => '%'.$term.'%' }, %public },
          { hashvalue => { like => '%'.$params->{term}.'%' }, %public } ],
        { order_by => { -asc => 'id' }},
    );
}

=head2 CLASS METHODS

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'UploadedFile';
}

=head3 object_class

Returns name of corresponding Koha object class

=cut

sub object_class {
    return 'Koha::UploadedFile';
}

=head1 AUTHOR

Marcel de Rooy (Rijksmuseum)

Koha Development Team

=cut

1;
