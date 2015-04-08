package C4::UploadedFile;

# Copyright (C) 2007 LibLime
# Galen Charlton <galen.charlton@liblime.com>
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
#use warnings; FIXME - Bug 2505
use C4::Context;
use C4::Auth qw/get_session/;
use IO::File;

use vars qw($VERSION);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
}

=head1 NAME

C4::UploadedFile - manage files uploaded by the user
for later processing.

=head1 SYNOPSIS

 # create and store data
 my $uploaded_file = C4::UploadedFile->new($sessionID);
 my $fileID = $uploaded_file->id();
 $uploaded_file->name('c:\temp\file.mrc');
 $uploaded_file->max_size(1024);
 while ($have_more_data) {
    $uploaded_file->stash($data, $bytes_read);
 }
 $uploaded_file->done();

 # check status of current file upload
 my $progress = C4::UploadedFile->upload_progress($sessionID);

 # get file handle for reading uploaded file
 my $uploaded_file = C4::UploadedFile->fetch($fileID);
 my $fh = $uploaded_file->fh();


Stores files uploaded by the user from their web browser.  The
uploaded files are temporary and at present are not guaranteed
to survive beyond the life of the user's session.

This module allows for tracking the progress of the file
currently being uploaded.

TODO: implement secure persistant storage of uploaded files.

=cut

=head1 METHODS

=cut

=head2 new

  my $uploaded_file = C4::UploadedFile->new($sessionID);

Creates a new object to represent the uploaded file.  Requires
the current session ID.

=cut

sub new {
    my $class = shift;
    my $sessionID = shift;

    my $self = {};

    $self->{'sessionID'} = $sessionID;
    $self->{'fileID'} = Digest::MD5::md5_hex(Digest::MD5::md5_hex(time().{}.rand().{}.$$));
    # FIXME - make staging area configurable
    my $TEMPROOT = "/tmp";
    my $OUTPUTDIR = "$TEMPROOT/$sessionID";
    mkdir $OUTPUTDIR;
    my $tmp_file_name = "$OUTPUTDIR/$self->{'fileID'}";
    my $fh = new IO::File $tmp_file_name, "w";
    unless (defined $fh) {
        return undef;
    }
    $fh->binmode(); # Windows compatibility
    $self->{'fh'} = $fh;
    $self->{'tmp_file_name'} = $tmp_file_name;
    $self->{'max_size'} = 0;
    $self->{'progress'} = 0;
    $self->{'name'} = '';

    bless $self, $class;
    $self->_serialize();

    my $session = get_session($sessionID);
    $session->param('current_upload', $self->{'fileID'});
    $session->flush();

    return $self;

}

sub _serialize {
    my $self = shift;

    my $prefix = "upload_" . $self->{'fileID'};
    my $session = get_session($self->{'sessionID'});

    # temporarily take file handle out of structure
    my $fh = $self->{'fh'};
    delete $self->{'fh'};
    $session->param($prefix, $self);
    $session->flush();
    $self->{'fh'} =$fh;
}

=head2 id

  my $fileID = $uploaded_file->id();

=cut

sub id {
    my $self = shift;
    return $self->{'fileID'};
}

=head2 name

  my $name = $uploaded_file->name();
  $uploaded_file->name($name);

Accessor method for the name by which the file is to be known.

=cut

sub name {
    my $self = shift;
    if (@_) {
        $self->{'name'} = shift;
        $self->_serialize();
    } else {
        return $self->{'name'};
    }
}

=head2 filename

  my $filename = $uploaded_file->filename();

Accessor method for the name by which the file is to be known.

=cut

sub filename {
    my $self = shift;
    if (@_) {
        $self->{'tmp_file_name'} = shift;
        $self->_serialize();
    } else {
        return $self->{'tmp_file_name'};
    }
}

=head2 max_size

  my $max_size = $uploaded_file->max_size();
  $uploaded_file->max_size($max_size);

Accessor method for the maximum size of the uploaded file.

=cut

sub max_size {
    my $self = shift;
    @_ ? $self->{'max_size'} = shift : $self->{'max_size'};
}

=head2 stash

  $uploaded_file->stash($dataref, $bytes_read);

Write C<$dataref> to the temporary file.  C<$bytes_read> represents
the number of bytes (out of C<$max_size>) transmitted so far.

=cut

sub stash {
    my $self = shift;
    my $dataref = shift;
    my $bytes_read = shift;

    my $fh = $self->{'fh'};
    print $fh $$dataref;

    my $percentage = int(($bytes_read / $self->{'max_size'}) * 100);
    if ($percentage > $self->{'progress'}) {
        $self->{'progress'} = $percentage;
        $self->_serialize();
    }
}

=head2 done

  $uploaded_file->done();

Indicates that all of the bytes have been uploaded.

=cut

sub done {
    my $self = shift;
    $self->{'progress'} = 'done';
    $self->{'fh'}->close();
    $self->_serialize();
}

=head2 upload_progress

  my $upload_progress = C4::UploadFile->upload_progress($sessionID);

Returns (as an integer from 0 to 100) the percentage
progress of the current file upload.

=cut

sub upload_progress {
    my ($class, $sessionID) = shift;

    my $session = get_session($sessionID);

    my $fileID = $session->param('current_upload');

    my $reported_progress = 0;
    if (defined $fileID and $fileID ne "") {
        my $file = C4::UploadedFile->fetch($sessionID, $fileID);
        my $progress = $file->{'progress'};
        if (defined $progress) {
            if ($progress eq "done") {
                $reported_progress = 100;
            } else {
                $reported_progress = $progress;
            }
        }
    }
    return $reported_progress;
}

=head2 fetch

  my $uploaded_file = C4::UploadedFile->fetch($sessionID, $fileID);

Retrieves an uploaded file object from the current session.

=cut

sub fetch {
    my $class = shift;
    my $sessionID = shift;
    my $fileID = shift;

    my $session = get_session($sessionID);
    my $prefix = "upload_$fileID";
    my $self = $session->param($prefix);
    my $fh = new IO::File $self->{'tmp_file_name'}, "r";
    $self->{'fh'} = $fh;

    bless $self, $class;
    return $self;
}

=head2 fh

  my $fh = $uploaded_file->fh();

Returns an IO::File handle to read the uploaded file.

=cut

sub fh {
    my $self = shift;
    return $self->{'fh'};
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut
