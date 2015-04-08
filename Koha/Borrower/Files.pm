package Koha::Borrower::Files;

# Copyright 2012 Kyle M Hall
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

use vars qw($VERSION);

use C4::Context;
use C4::Output;
use C4::Dates;
use C4::Debug;

BEGIN {

    # set the version for version checking
    $VERSION = 0.01;
}

=head1 NAME

Koha::Borrower::Files - Module for managing borrower files

=head1 METHODS

=over

=cut

sub new {
    my ( $class, %args ) = @_;
    my $self = bless( {}, $class );

    $self->{'borrowernumber'} = $args{'borrowernumber'};

    return $self;
}

=item GetFilesInfo()

    my $bf = Koha::Borrower::Files->new( borrowernumber => $borrowernumber );
    my $files_hashref = $bf->GetFilesInfo

=cut

sub GetFilesInfo {
    my $self = shift;

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT
            file_id,
            file_name,
            file_type,
            file_description,
            date_uploaded
        FROM borrower_files
        WHERE borrowernumber = ?
        ORDER BY file_name, date_uploaded
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $self->{'borrowernumber'} );
    return $sth->fetchall_arrayref( {} );
}

=item AddFile()

    my $bf = Koha::Borrower::Files->new( borrowernumber => $borrowernumber );
    $bh->AddFile( name => $filename, type => $mimetype,
                  description => $description, content => $content );

=cut

sub AddFile {
    my ( $self, %args ) = @_;

    my $name        = $args{'name'};
    my $type        = $args{'type'};
    my $description = $args{'description'};
    my $content     = $args{'content'};

    return unless ( $name && $content );

    my $dbh   = C4::Context->dbh;
    my $query = "
        INSERT INTO borrower_files ( borrowernumber, file_name, file_type, file_description, file_content )
        VALUES ( ?,?,?,?,? )
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $self->{'borrowernumber'},
        $name, $type, $description, $content );
}

=item GetFile()

    my $bf = Koha::Borrower::Files->new( borrowernumber => $borrowernumber );
    my $file = $bh->GetFile( file_id => $file_id );

=cut

sub GetFile {
    my ( $self, %args ) = @_;

    my $file_id = $args{'id'};

    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT * FROM borrower_files WHERE file_id = ? AND borrowernumber = ?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $file_id, $self->{'borrowernumber'} );
    return $sth->fetchrow_hashref();
}

=item DelFile()

    my $bf = Koha::Borrower::Files->new( borrowernumber => $borrowernumber );
    $bh->DelFile( file_id => $file_id );

=cut

sub DelFile {
    my ( $self, %args ) = @_;

    my $file_id = $args{'id'};

    my $dbh   = C4::Context->dbh;
    my $query = "
        DELETE FROM borrower_files WHERE file_id = ? AND borrowernumber = ?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $file_id, $self->{'borrowernumber'} );
}

1;
__END__

=back

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
