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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Members;
use CGI qw ( -utf8 );
use CGI::Cookie;  # need to check cookies before having CGI parse the POST request
use C4::Auth qw(:DEFAULT check_cookie_auth);
use Koha::Patron::Images;

my $query = new CGI;

unless (C4::Context->preference('OPACpatronimages')) {
    print $query->header(status => '403 Forbidden - displaying patron images in the OPAC not enabled');
    exit;
}

my $needed_flags;
my %cookies = CGI::Cookie->fetch;
my $sessid = $cookies{'CGISESSID'}->value;
my ($auth_status, $auth_sessid) = check_cookie_auth($sessid, $needed_flags);
my $borrowernumber = C4::Context->userenv->{'number'};

my $patron_image = Koha::Patron::Images->find($borrowernumber);

if ($patron_image) {
    print $query->header(
        -type           => $patron_image->mimetype,
        -Content_Length => length( $patron_image->imagefile )
      ),
      $patron_image->imagefile;
} else {
    print $query->header(status => '404 patron image not found');
}
