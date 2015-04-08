package C4::Images;

# Copyright (C) 2011 C & P Bibliography Services
# Jared Camins-Esakov <jcamins@cpbibliograpy.com>
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
use 5.010;

use C4::Context;
use GD;

use vars qw($debug $noimage $VERSION @ISA @EXPORT);

BEGIN {

    # set the version for version checking
    $VERSION = 3.07.00.049;
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      &PutImage
      &RetrieveImage
      &ListImagesForBiblio
      &DelImage
    );
    $debug = $ENV{KOHA_DEBUG} || $ENV{DEBUG} || 0;

    $noimage = pack( "H*",
            '47494638396101000100800000FFFFFF'
          . '00000021F90401000000002C00000000'
          . '010001000002024401003B' );
}

=head2 PutImage

    PutImage($biblionumber, $srcimage, $replace);

Stores binary image data and thumbnail in database, optionally replacing existing images for the given biblio.

=cut

sub PutImage {
    my ( $biblionumber, $srcimage, $replace ) = @_;

    return -1 unless defined($srcimage);

    if ($replace) {
        foreach ( ListImagesForBiblio($biblionumber) ) {
            DelImage($_);
        }
    }

    my $dbh = C4::Context->dbh;
    my $query =
"INSERT INTO biblioimages (biblionumber, mimetype, imagefile, thumbnail) VALUES (?,?,?,?);";
    my $sth = $dbh->prepare($query);

    my $mimetype = 'image/png'
      ; # GD autodetects three basic image formats: PNG, JPEG, XPM; we will convert all to PNG which is lossless...

    # Check the pixel size of the image we are about to import...
    my $thumbnail = _scale_image( $srcimage, 140, 200 )
      ;    # MAX pixel dims are 140 X 200 for thumbnail...
    my $fullsize = _scale_image( $srcimage, 600, 800 )
      ;    # MAX pixel dims are 600 X 800 for full-size image...
    $debug and warn "thumbnail is " . length($thumbnail) . " bytes.";

    $sth->execute( $biblionumber, $mimetype, $fullsize->png(),
        $thumbnail->png() );
    my $dberror = $sth->errstr;
    warn "Error returned inserting $biblionumber.$mimetype." if $sth->errstr;
    undef $thumbnail;
    undef $fullsize;
    return $dberror;
}

=head2 RetrieveImage
    my ($imagedata, $error) = RetrieveImage($imagenumber);

Retrieves the specified image.

=cut

sub RetrieveImage {
    my ($imagenumber) = @_;

    my $dbh = C4::Context->dbh;
    my $query =
'SELECT mimetype, imagefile, thumbnail FROM biblioimages WHERE imagenumber = ?';
    my $sth = $dbh->prepare($query);
    $sth->execute($imagenumber);
    my $imagedata = $sth->fetchrow_hashref;
    if ( !$imagedata ) {
        $imagedata->{'thumbnail'} = $noimage;
        $imagedata->{'imagefile'} = $noimage;
    }
    if ( $sth->err ) {
        warn "Database error!" if $debug;
    }
    return $imagedata;
}

=head2 ListImagesForBiblio
    my (@images) = ListImagesForBiblio($biblionumber);

Gets a list of all images associated with a particular biblio.

=cut

sub ListImagesForBiblio {
    my ($biblionumber) = @_;

    my @imagenumbers;
    my $dbh   = C4::Context->dbh;
    my $query = 'SELECT imagenumber FROM biblioimages WHERE biblionumber = ?';
    my $sth   = $dbh->prepare($query);
    $sth->execute($biblionumber);
    while ( my $row = $sth->fetchrow_hashref ) {
        push @imagenumbers, $row->{'imagenumber'};
    }
    return @imagenumbers;
}

=head2 DelImage

    my ($dberror) = DelImage($imagenumber);

Removes the image with the supplied imagenumber.

=cut

sub DelImage {
    my ($imagenumber) = @_;
    warn "Imagenumber passed to DelImage is $imagenumber" if $debug;
    my $dbh   = C4::Context->dbh;
    my $query = "DELETE FROM biblioimages WHERE imagenumber = ?;";
    my $sth   = $dbh->prepare($query);
    $sth->execute($imagenumber);
    my $dberror = $sth->errstr;
    warn "Database error!" if $sth->errstr;
    return $dberror;
}

sub _scale_image {
    my ( $image, $maxwidth, $maxheight ) = @_;
    my ( $width, $height ) = $image->getBounds();
    $debug and warn "image is $width pix X $height pix.";
    if ( $width > $maxwidth || $height > $maxheight ) {

#        $debug and warn "$filename exceeds the maximum pixel dimensions of $maxwidth X $maxheight. Resizing...";
        my $percent_reduce;  # Percent we will reduce the image dimensions by...
        if ( $width > $maxwidth ) {
            $percent_reduce =
              sprintf( "%.5f", ( $maxwidth / $width ) )
              ;    # If the width is oversize, scale based on width overage...
        }
        else {
            $percent_reduce =
              sprintf( "%.5f", ( $maxheight / $height ) )
              ;    # otherwise scale based on height overage.
        }
        my $width_reduce  = sprintf( "%.0f", ( $width * $percent_reduce ) );
        my $height_reduce = sprintf( "%.0f", ( $height * $percent_reduce ) );
        $debug
          and warn "Reducing image by "
          . ( $percent_reduce * 100 )
          . "\% or to $width_reduce pix X $height_reduce pix";
        my $newimage = GD::Image->new( $width_reduce, $height_reduce, 1 )
          ;        #'1' creates true color image...
        $newimage->copyResampled( $image, 0, 0, 0, 0, $width_reduce,
            $height_reduce, $width, $height );
        return $newimage;
    }
    else {
        return $image;
    }
}

=head2 NoImage

    C4::Images->NoImage;

Returns the gif to be used when there is no image matching the request, and
its mimetype (image/gif).

=cut

sub NoImage {
    return $noimage, 'image/gif';
}

1;
