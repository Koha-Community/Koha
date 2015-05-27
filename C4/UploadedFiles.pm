package C4::UploadedFiles;

# This file is part of Koha.
#
# Copyright (C) 2011-2012 BibLibre
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

=head1 NAME

C4::UploadedFiles - Functions to deal with files uploaded with cataloging plugin upload.pl

=head1 SYNOPSIS

    use C4::UploadedFiles;

    my $filename = $cgi->param('uploaded_file');
    my $file = $cgi->upload('uploaded_file');
    my $dir = $input->param('dir');

    # upload file
    my $id = C4::UploadedFiles::UploadFile($filename, $dir, $file->handle);

    # retrieve file infos
    my $uploaded_file = C4::UploadedFiles::GetUploadedFile($id);

    # delete file
    C4::UploadedFiles::DelUploadedFile($id);

=head1 DESCRIPTION

This module provides basic functions for adding, retrieving and deleting files related to
cataloging plugin upload.pl.

It uses uploaded_files table.

It is not related to C4::UploadedFile

=head1 FUNCTIONS

=cut

use Modern::Perl;
use Digest::SHA;
use Fcntl;
use Encode;

use C4::Context;

sub _get_file_path {
    my ($id, $dirname, $filename) = @_;

    my $upload_path = C4::Context->config('upload_path');
    my $filepath = "$upload_path/$dirname/${id}_$filename";
    $filepath =~ s|/+|/|g;

    return $filepath;
}

=head2 GetUploadedFile

    my $file = C4::UploadedFiles::GetUploadedFile($id);

Returns a hashref containing infos on uploaded files.
Hash keys are:

=over 2

=item * id: id of the file (same as given in argument)

=item * filename: name of the file

=item * dir: directory where file is stored (relative to config variable 'upload_path')

=back

It returns undef if file is not found

=cut

sub GetUploadedFile {
    my ($id) = @_;

    return unless $id;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT id, filename, dir
        FROM uploaded_files
        WHERE id = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($id);
    my $file = $sth->fetchrow_hashref;
    if ($file) {
        $file->{filepath} = _get_file_path($file->{id}, $file->{dir},
            $file->{filename});
    }

    return $file;
}

=head2 UploadFile

    my $id = C4::UploadedFiles::UploadFile($filename, $dir, $io_handle);

Upload a new file and returns its id (its SHA-1 sum, actually).

Parameters:

=over 2

=item * $filename: name of the file

=item * $dir: directory where to store the file (path relative to config variable 'upload_path'

=item * $io_handle: valid IO::Handle object, can be retrieved with
$cgi->upload('uploaded_file')->handle;

=back

=cut

sub UploadFile {
    my ($filename, $dir, $handle) = @_;

    $filename = decode_utf8($filename);
    if($filename =~ m#(^|/)\.\.(/|$)# or $dir =~ m#(^|/)\.\.(/|$)#) {
        warn "Filename or dirname contains '..'. Aborting upload";
        return;
    }

    my $buffer;
    my $data = '';
    while($handle->read($buffer, 1024)) {
        $data .= $buffer;
    }
    $handle->close;

    my $sha = new Digest::SHA;
    $sha->add($data);
    $sha->add($filename);
    $sha->add($dir);
    my $id = $sha->hexdigest;

    # Test if this id already exist
    my $file = GetUploadedFile($id);
    if ($file) {
        return $file->{id};
    }

    my $file_path = _get_file_path($id, $dir, $filename);

    my $out_fh;
    # Create the file only if it doesn't exist
    unless( sysopen($out_fh, $file_path, O_WRONLY|O_CREAT|O_EXCL) ) {
        warn "Failed to open file '$file_path': $!";
        return;
    }

    print $out_fh $data;
    close $out_fh;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        INSERT INTO uploaded_files (id, filename, dir)
        VALUES (?,?, ?);
    };
    my $sth = $dbh->prepare($query);
    if($sth->execute($id, $filename, $dir)) {
        return $id;
    }

    return;
}

=head2 DanglingEntry

    C4::UploadedFiles::DanglingEntry($id,$isfileuploadurl);

Determine if a entry is dangling.

Returns: 2 == no db entry
         1 == no file
         0 == both a file and db entry.
        -1 == N/A (undef id / non-file-upload URL)

=cut

sub DanglingEntry {
    my ($id,$isfileuploadurl) = @_;
    my $retval;

    if (defined($id)) {
        my $file = GetUploadedFile($id);
        if($file) {
            my $file_path = $file->{filepath};
            my $file_deleted = 0;
            unless( -f $file_path ) {
                $retval = 1;
            } else {
                $retval = 0;
            }
        }
        else {
            if ( $isfileuploadurl ) {
                $retval = 2;
            }
            else {
                $retval = -1;
            }
        }
    }
    else {
        $retval = -1;
    }
    return $retval;
}

=head2 DelUploadedFile

    C4::UploadedFiles::DelUploadedFile($id);

Remove a previously uploaded file, given its id.

Returns: 1 == file deleted
         0 == file not deleted
         -1== no file to delete / no meaninful id passed

=cut

sub DelUploadedFile {
    my ($id) = @_;
    my $retval;

    if ($id) {
        my $file = GetUploadedFile($id);
        if($file) {
            my $file_path = $file->{filepath};
            my $file_deleted = 0;
            unless( -f $file_path ) {
                warn "Id $file->{id} is in database but not in filesystem, removing id from database";
                $file_deleted = 1;
            } else {
                if(unlink $file_path) {
                    $file_deleted = 1;
                }
            }

            unless($file_deleted) {
                warn "File $file_path cannot be deleted: $!";
            }

            my $dbh = C4::Context->dbh;
            my $query = qq{
                DELETE FROM uploaded_files
                WHERE id = ?
            };
            my $sth = $dbh->prepare($query);
            my $numrows = $sth->execute($id);
            # if either a DB entry or file was deleted,
            # then clearly we have a deletion.
            if ($numrows>0 || $file_deleted==1) {
                $retval = 1;
            }
            else {
                $retval = 0;
            }
        }
        else {
            warn "There was no file for id=($id)";
            $retval = -1;
        }
    }
    else {
        warn "DelUploadFile called with no id.";
        $retval = -1;
    }
    return $retval;
}

=head2 httpheaders

    httpheaders returns http headers for a retrievable upload
    Will be extended by report 14282

=cut

sub httpheaders {
    my $file= shift;
    return
        ( '-type' => 'application/octet-stream',
          '-attachment' => $file, );
}

1;
