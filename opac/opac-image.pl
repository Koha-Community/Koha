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

use Modern::Perl;

use CGI qw ( -utf8 );
use C4::Context;
use Koha::Biblios;
use Koha::CoverImages;

$| = 1;

my $input = CGI->new;
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

my ( $image );
if ( C4::Context->preference("OPACLocalCoverImages") ) {
    my $imagenumber = $input->param('imagenumber');
    my $biblionumber = $input->param('biblionumber');
    if ( defined $imagenumber ) {
        $imagenumber = $input->param('imagenumber');
        $image = Koha::CoverImages->find($imagenumber);
        unless ($image) {
            print $input->redirect("/cgi-bin/koha/errors/404.pl");
            exit;
        }
    }
    elsif ( defined $biblionumber ) {
        my $biblio = Koha::Biblios->find($biblionumber);
        unless ($biblio) {
            print $input->redirect("/cgi-bin/koha/errors/404.pl");
            exit;
        }
        my $cover_images = $biblio->cover_images;
        if ( $cover_images->count ) {
            $image = $cover_images->next;
        }
    }
}

$image ||= Koha::CoverImages->no_image;

my $image_data =
    $input->param('thumbnail')
  ? $image->thumbnail
  : $image->imagefile;

print $input->header(
    -type            => $image->mimetype,
    -expires         => '+30m',
    -Content_Length  => length($image_data)
), $image_data;

=head1 AUTHOR

Chris Nighswonger cnighswonger <at> foundations <dot> edu

modified for local cover images by Koustubha Kale kmkale <at> anantcorp <dot> com

=cut
