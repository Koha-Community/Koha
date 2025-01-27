package Koha::CoverImage;

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

use GD;

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::CoverImage - Koha CoverImage Object class

=head1 API

=head2 Class methods

=head3 new

my $cover_image = Koha::CoverImage->new(
    {
        biblionumber => $biblionumber,
        itemnumber   => $itemnumber,
        src_image    => $image,
        mimetype     => $mimetype,
    }
);

biblionumber and/or itemnumber must be passed, otherwise the image will not be
linked to anything.

src_image must contain the GD image, the fullsize and thumbnail images will be generated
and stored in the database.

=cut

sub new {
    my ( $class, $params ) = @_;

    my $src_image = delete $params->{src_image};

    if ($src_image) {
        ;    # GD autodetects three basic image formats: PNG, JPEG, XPM; we will convert all to PNG which is lossless...

        # Check the pixel size of the image we are about to import...
        my $thumbnail = $class->_scale_image( $src_image, 140, 200 );    # MAX pixel dims are 140 X 200 for thumbnail...
        my $fullsize =
            $class->_scale_image( $src_image, 600, 800 );    # MAX pixel dims are 600 X 800 for full-size image...

        $params->{mimetype}  = 'image/png';
        $params->{imagefile} = $fullsize->png();
        $params->{thumbnail} = $thumbnail->png();
    }

    return $class->SUPER::new($params);
}

sub _scale_image {
    my ( $self, $image, $maxwidth, $maxheight ) = @_;
    my ( $width, $height ) = $image->getBounds();
    if ( $width > $maxwidth || $height > $maxheight ) {

        my $percent_reduce;    # Percent we will reduce the image dimensions by...
        if ( $width > $maxwidth ) {
            $percent_reduce =
                sprintf( "%.5f", ( $maxwidth / $width ) );   # If the width is oversize, scale based on width overage...
        } else {
            $percent_reduce = sprintf( "%.5f", ( $maxheight / $height ) );    # otherwise scale based on height overage.
        }
        my $width_reduce  = sprintf( "%.0f", ( $width * $percent_reduce ) );
        my $height_reduce = sprintf( "%.0f", ( $height * $percent_reduce ) );
        my $newimage      = GD::Image->new( $width_reduce, $height_reduce, 1 );    #'1' creates true color image...
        $newimage->copyResampled(
            $image, 0, 0, 0, 0, $width_reduce,
            $height_reduce, $width, $height
        );
        return $newimage;
    } else {
        return $image;
    }
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'CoverImage';
}

1;
