package Koha::UploadedFiles;

# Copyright Rijksmuseum 2016
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

use Modern::Perl;

use C4::Koha qw( GetAuthorisedValues );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
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

Parameter keep_file may be used to delete records, but keep files.

Returns the number of deleted records, 0E0 or -1 (Unknown).
Please note that the number of deleted records is not automatically the same
as the number of files.

=cut

sub delete {
    my ( $self, $params ) = @_;
    $self = Koha::UploadedFiles->new if !ref($self);    # handle class call
                                                        # We use the individual delete on each resultset record
    my $rv = 0;
    while ( my $row = $self->next ) {
        my $deleted = eval { $row->delete($params) };
        $rv++ if $deleted && !$@;
    }
    return $rv == 0 ? "0E0" : $rv;
}

=head3 delete_temporary

Delete_temporary is called by cleanup_database and only removes temporary
uploads older than [pref UploadPurgeTemporaryFilesDays] days.
It is possible to override the pref with the override_pref parameter.

Return value: see delete.

=cut

sub delete_temporary {
    my ( $self, $params ) = @_;
    my $days = C4::Context->preference('UploadPurgeTemporaryFilesDays');
    if ( exists $params->{override_pref} ) {
        $days = $params->{override_pref};
    } elsif ( !defined($days) || $days eq '' ) {    # allow 0, not NULL or ""
        return "0E0";
    }
    my $dt = dt_from_string();
    $dt->subtract( days => $days );
    my $parser = Koha::Database->new->schema->storage->datetime_parser;
    return $self->search(
        {
            permanent => [ undef, 0 ],
            dtcreated => { '<' => $parser->format_datetime($dt) },
        }
    )->delete;
}

=head3 delete_missing

    $cnt = Koha::UploadedFiles->delete_missing();

    $cnt = Koha::UploadedFiles->delete_missing({ keep_record => 1 });

Deletes all records where the actual file is not found.

Supports a keep_record hash parameter to do a check only.

Return value: If you pass keep_record, it returns the number of records where
the file is not found, or 0E0. Otherwise it returns a number, 0E0 or -1 just
as delete does.

=cut

sub delete_missing {
    my ( $self, $params ) = @_;
    $self = Koha::UploadedFiles->new if !ref($self);    # handle class call
    my $rv = 0;
    while ( my $row = $self->next ) {
        my $file = $row->full_path;
        next if -e $file;
        if ( $params->{keep_record} ) {
            $rv++;
            next;
        }

        # We are passing keep_file since we already know that the file
        # is missing and we do not want to see the warning
        # Apply the same logic as in delete for the return value
        my $deleted = eval { $row->delete( { keep_file => 1 } ) };
        $rv++ if $deleted && !$@;
    }
    return $rv == 0 ? "0E0" : $rv;
}

=head3 search_term

Search_term allows you to pass a term to search in filename and hashvalue.
If you do not pass include_private, only public records are returned.

Is only a wrapper around Koha::Objects search. Has similar return value.

=cut

sub search_term {
    my ( $self, $params ) = @_;
    my $term   = $params->{term} // '';
    my %public = ();
    if ( !$params->{include_private} ) {
        %public = ( public => 1 );
    }
    return $self->search(
        [
            { filename  => { like => '%' . $term . '%' },           %public },
            { hashvalue => { like => '%' . $params->{term} . '%' }, %public }
        ],
        { order_by => { -asc => 'id' } },
    );
}

=head2 CLASS METHODS

=head3 getCategories

getCategories returns a list of upload category codes and names

=cut

sub getCategories {
    my ($class) = @_;
    my $cats = C4::Koha::GetAuthorisedValues('UPLOAD');
    [ map { { code => $_->{authorised_value}, name => $_->{lib} } } @$cats ];
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
