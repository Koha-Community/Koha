package Koha::Misc::Files;

# This file is part of Koha.
#
# Copyright 2012 Kyle M Hall
# Copyright 2014 Jacek Ablewicz
# Based on Koha/Borrower/Files.pm by Kyle M Hall
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

use C4::Context;
use C4::Output;

=head1 NAME

Koha::Misc::Files - module for managing miscellaneous files associated
with records from arbitrary tables

=head1 SYNOPSIS

use Koha::Misc::Files;

my $mf = Koha::Misc::Files->new( tabletag => $tablename,
    recordid => $recordnumber );

=head1 FUNCTIONS

=over

=item new()

my $mf = Koha::Misc::Files->new( tabletag => $tablename,
    recordid => $recordnumber );

Creates new Koha::Misc::Files object. Such object is essentially
a pair: in typical usage scenario, 'tabletag' parameter will be
a database table name, and 'recordid' an unique record ID number
from this table. However, this method does accept an arbitrary
string as 'tabletag', and an arbitrary integer as 'recordid'.

Particular Koha::Misc::Files object can have one or more file records
(actuall file contents + various file metadata) associated with it.

In case of an error (wrong parameter format) it returns undef.

=cut

sub new {
    my ( $class, %args ) = @_;

    my $recid = $args{'recordid'};
    my $tag   = $args{'tabletag'};
    ( defined($tag) && $tag ne '' && defined($recid) && $recid =~ /^\d+$/ )
      || return ();

    my $self = bless( {}, $class );

    $self->{'table_tag'} = $tag;
    $self->{'record_id'} = '' . ( 0 + $recid );

    return $self;
}

=item GetFilesInfo()

my $files_descriptions = $mf->GetFilesInfo();

This method returns a reference to an array of hashes
containing files metadata (file_id, file_name, file_type,
file_description, file_size, date_uploaded) for all file records
associated with given $mf object, or an empty arrayref if there are
no such records yet.

In case of an error it returns undef.

=cut

sub GetFilesInfo {
    my $self = shift;

    my $dbh   = C4::Context->dbh;
    my $query = '
        SELECT
            file_id,
            file_name,
            file_type,
            file_description,
            date_uploaded,
            LENGTH(file_content) AS file_size
        FROM misc_files
        WHERE table_tag = ? AND record_id = ?
        ORDER BY file_name, date_uploaded
    ';
    my $sth = $dbh->prepare($query);
    $sth->execute( $self->{'table_tag'}, $self->{'record_id'} );
    return $sth->fetchall_arrayref( {} );
}

=item AddFile()

$mf->AddFile( name => $filename, type => $mimetype,
    description => $description, content => $content );

Adds a new file (we want to store for / associate with a given
object) to the database. Parameters 'name' and 'content' are mandatory.
Note: this method would (silently) fail if there is no 'name' given
or if the 'content' provided is empty.

=cut

sub AddFile {
    my ( $self, %args ) = @_;

    my $name        = $args{'name'};
    my $type        = $args{'type'} // '';
    my $description = $args{'description'};
    my $content     = $args{'content'};

    return unless ( defined($name) && $name ne '' && defined($content) && $content ne '' );

    my $dbh   = C4::Context->dbh;
    my $query = '
        INSERT INTO misc_files ( table_tag, record_id, file_name, file_type, file_description, file_content )
        VALUES ( ?,?,?,?,?,? )
    ';
    my $sth = $dbh->prepare($query);
    $sth->execute( $self->{'table_tag'}, $self->{'record_id'}, $name, $type,
        $description, $content );
}

=item GetFile()

my $file = $mf->GetFile( id => $file_id );

For an individual, specific file ID this method returns a hashref
containing all metadata (file_id, table_tag, record_id, file_name,
file_type, file_description, file_content, date_uploaded), plus
an actuall contents of a file (in 'file_content'). In typical usage
scenarios, for a given $mf object, specific file IDs have to be
obtained first by GetFilesInfo() call.

Returns undef in case when file ID specified as 'id' parameter was not
found in the database.

=cut

sub GetFile {
    my ( $self, %args ) = @_;

    my $file_id = $args{'id'};

    my $dbh   = C4::Context->dbh;
    my $query = '
        SELECT * FROM misc_files WHERE file_id = ? AND table_tag = ? AND record_id = ?
    ';
    my $sth = $dbh->prepare($query);
    $sth->execute( $file_id, $self->{'table_tag'}, $self->{'record_id'} );
    return $sth->fetchrow_hashref();
}

=item DelFile()

$mf->DelFile( id => $file_id );

Deletes specific, individual file record (file contents and metadata)
from the database.

=cut

sub DelFile {
    my ( $self, %args ) = @_;

    my $file_id = $args{'id'};

    my $dbh   = C4::Context->dbh;
    my $query = '
        DELETE FROM misc_files WHERE file_id = ? AND table_tag = ? AND record_id = ?
    ';
    my $sth = $dbh->prepare($query);
    $sth->execute( $file_id, $self->{'table_tag'}, $self->{'record_id'} );
}

=item DelAllFiles()

$mf->DelAllFiles();

Deletes all file records associated with (stored for) a given $mf object.

=cut

sub DelAllFiles {
    my ($self) = @_;

    my $dbh   = C4::Context->dbh;
    my $query = '
        DELETE FROM misc_files WHERE table_tag = ? AND record_id = ?
    ';
    my $sth = $dbh->prepare($query);
    $sth->execute( $self->{'table_tag'}, $self->{'record_id'} );
}

=item MergeFileRecIds()

$mf->MergeFileRecIds(@ids_to_be_merged);

This method re-associates all individuall file records associated with
some "parent" records IDs (provided in @ids_to_be_merged) with the given
single $mf object (which would be treated as a "parent" destination).

This a helper method; typically it needs to be called only in cases when
some "parent" records are being merged in the (external) 'tablename'
table.

=cut

sub MergeFileRecIds {
    my ( $self, @ids_to_merge ) = @_;

    my $dst_recid = $self->{'record_id'};
    @ids_to_merge = map { ( $dst_recid == $_ ) ? () : ($_); } @ids_to_merge;
    @ids_to_merge > 0 || return ();

    my $dbh   = C4::Context->dbh;
    my $query = '
        UPDATE misc_files SET record_id = ?
        WHERE table_tag = ? AND record_id = ?
    ';
    my $sth = $dbh->prepare($query);

    for my $src_recid (@ids_to_merge) {
        $sth->execute( $dst_recid, $self->{'table_tag'}, $src_recid );
    }
}

1;

__END__

=back

=head1 SEE ALSO

Koha::Patron::Files

=head1 AUTHOR

Kyle M Hall E<lt>kyle.m.hall@gmail.comE<gt>,
Jacek Ablewicz E<lt>ablewicz@gmail.comE<gt>

=cut
