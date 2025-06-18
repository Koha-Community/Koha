#!/usr/bin/perl
#
# Copyright 2009 LibLime
# Parts copyright 2012 Athens County Public Libraries
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Members;
use CGI qw ( -utf8 );
use CGI::Cookie;    # need to check cookies before having CGI parse the POST request
use C4::Auth qw( check_cookie_auth );
use Koha::Patron::Images;

my $query = CGI->new;

unless ( C4::Context->preference('OPACpatronimages') ) {
    print $query->header( status => '403 Forbidden - displaying patron images in the OPAC not enabled' );
    exit;
}

my ($auth_status) = check_cookie_auth( $query->cookie('CGISESSID') );
if ( $auth_status ne 'ok' ) {
    print CGI::header( '-status' => '401' );
    exit 0;
}

my $userenv      = C4::Context->userenv;
my $patron_image = $userenv ? Koha::Patron::Images->find( $userenv->{number} ) : undef;

if ($patron_image) {
    print $query->header(
        -type           => $patron_image->mimetype,
        -Content_Length => length( $patron_image->imagefile )
        ),
        $patron_image->imagefile;
} else {
    print $query->header( status => '404 patron image not found' );
}
