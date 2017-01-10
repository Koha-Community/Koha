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

use C4::Koha;
use Koha::UploadedFile;

use parent qw(Koha::Objects);

=head1 NAME

Koha::UploadedFiles - Koha::Objects class for uploaded files

=head1 SYNOPSIS

    use Koha::UploadedFiles;

    # get one upload
    my $upload01 = Koha::UploadedFiles->find( $id );

    # get some uploads
    my @uploads = Koha::UploadedFiles->search_term({ term => '.mrc' });

    # delete all uploads
    Koha::UploadedFiles->delete;

=head1 DESCRIPTION

Allows regular CRUD operations on uploaded_files via Koha::Objects / DBIx.

The delete method also takes care of deleting files. The search_term method
provides a wrapper around search to look for a term in multiple columns.

=head1 METHODS

=head2 INSTANCE METHODS

=head3 delete

Delete uploaded files.
Returns true if no errors occur. (So, false may mean partial success.)

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
    return $err==0;
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

=head3 getCategories

getCategories returns a list of upload category codes and names

=cut

sub getCategories {
    my ( $class ) = @_;
    my $cats = C4::Koha::GetAuthorisedValues('UPLOAD');
    [ map {{ code => $_->{authorised_value}, name => $_->{lib} }} @$cats ];
}

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
