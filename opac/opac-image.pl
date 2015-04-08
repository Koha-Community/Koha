#!/usr/bin/perl
#
# Copyright (C) 2011 C & P Bibliography Services
# Jared Camins-Esakov <jcamins@cpbibliograpy.com>
#
# based on patronimage.pl
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
#
#
#

use strict;
use warnings;

use CGI;
use C4::Context;
use C4::Images;

$| = 1;

my $DEBUG = 0;
my $data  = new CGI;
my $imagenumber;

=head1 NAME

opac-image.pl - Script for retrieving and formatting local cover images for display

=head1 SYNOPSIS

<img src="opac-image.pl?imagenumber=X" />
<img src="opac-image.pl?biblionumber=X" />
<img src="opac-image.pl?imagenumber=X&thumbnail=1" />
<img src="opac-image.pl?biblionumber=X&thumbnail=1" />

=head1 DESCRIPTION

This script, when called from within HTML and passed a valid imagenumber or
biblionumber, will retrieve the image data associated with that biblionumber
if one exists, format it in proper HTML format and pass it back to be displayed.
If the parameter thumbnail has been provided, a thumbnail will be returned
rather than the full-size image. When a biblionumber is provided rather than an
imagenumber, a random image is selected.

=cut

my ( $image, $mimetype ) = C4::Images->NoImage;
if ( C4::Context->preference("OPACLocalCoverImages") ) {
    if ( defined $data->param('imagenumber') ) {
        $imagenumber = $data->param('imagenumber');
    }
    elsif ( defined $data->param('biblionumber') ) {
        my @imagenumbers = ListImagesForBiblio( $data->param('biblionumber') );
        if (@imagenumbers) {
            $imagenumber = $imagenumbers[0];
        }
        else {
            warn "No images for this biblio" if $DEBUG;
        }
    }
    else {
        $imagenumber = shift;
    }

    if ($imagenumber) {
        warn "imagenumber passed in: $imagenumber" if $DEBUG;
        my $imagedata = RetrieveImage($imagenumber);
        if ($imagedata) {
            if ( $data->param('thumbnail') ) {
                $image = $imagedata->{'thumbnail'};
            }
            else {
                $image = $imagedata->{'imagefile'};
            }
            $mimetype = $imagedata->{'mimetype'};
        }
    }
}
print $data->header(
    -type            => $mimetype,
    -expires         => '+30m',
    -Content_Length  => length($image)
), $image;

=head1 AUTHOR

Chris Nighswonger cnighswonger <at> foundations <dot> edu

modified for local cover images by Koustubha Kale kmkale <at> anantcorp <dot> com

=cut
