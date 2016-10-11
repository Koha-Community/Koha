#!/usr/bin/perl
#
# Copyright 2008 Foundations Bible College & Seminary Inc.
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
use C4::Auth qw( check_api_auth );
use C4::Context;
use C4::Members;
use Koha::Patron::Images;

$|=1;

my $DEBUG = 0;
my $query = new CGI;
my $borrowernumber;

=head1 NAME

patronimage.pl - Script for retrieving and formatting Koha patron images for display

=head1 SYNOPSIS

<img src="patronimage.pl?borrowernumber= />

=head1 DESCRIPTION

This script, when called from within HTML and passed a valid patron borrowernumber, will retrieve the image data associated with that borrowernumber if one exists, format it in proper HTML format and pass it back to be displayed.

=cut

my ($status, $cookie, $sessionID) = check_api_auth($query, { catalogue => 1 } );

unless ( $status eq 'ok' ) {
    print $query->header(-type => 'text/plain', -status => '403 Forbidden');
    exit 0;
}



if ($query->param('borrowernumber')) {
    $borrowernumber = $query->param('borrowernumber');
} else {
    $borrowernumber = shift;
}


warn "Borrowernumber passed in: $borrowernumber" if $DEBUG;

my $patron_image = Koha::Patron::Images->find($borrowernumber);

# NOTE: Never dump the contents of $imagedata->{'patronimage'} via a warn to a log or nasty
# things will result... you have been warned!

if ($patron_image) {
    print $query->header (-type => $patron_image->mimetype, -'Cache-Control' => 'no-store', -Content_Length => length ($patron_image->imagefile)), $patron_image->imagefile;
    exit;
} else {
    warn "No image exists for $borrowernumber";
    exit;
}

exit;

=head1 AUTHOR

Chris Nighswonger cnighswonger <at> foundations <dot> edu

=cut
