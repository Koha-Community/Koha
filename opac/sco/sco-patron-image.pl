#!/usr/bin/perl
#
# Copyright 2009 LibLime
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
use C4::Service;
use C4::Members;
use Koha::Patron::Images;
use Koha::Patrons;
use Koha::Token;

my ( $query, $response ) = C4::Service->init( self_check => 'self_checkout_module' );

unless (C4::Context->preference('WebBasedSelfCheck')) {
    print $query->header(status => '403 Forbidden - web-based self-check not enabled');
    exit;
}
unless (C4::Context->preference('ShowPatronImageInWebBasedSelfCheck')) {
    print $query->header(status => '403 Forbidden - displaying patron images in self-check not enabled');
    exit;
}

my ($borrowernumber) = C4::Service->require_params('borrowernumber');
my ($csrf_token) = C4::Service->require_params('csrf_token');

my $patron = Koha::Patrons->find( $borrowernumber );
my $patron_image = $patron->image;

if ($patron_image) {

    unless (
        Koha::Token->new->check_csrf(
            {
                session_id => scalar $query->cookie('CGISESSID')
                  . $patron->cardnumber,
                id => $patron->userid,
                token => $csrf_token,
            }
        )
      )
    {

        print $query->header(-type => 'text/plain', -status => '403 Forbidden');
        exit;
    }
    print $query->header(
        -type           => $patron_image->mimetype,
        -Content_Length => length( $patron_image->imagefile )
      ),
      $patron_image->imagefile;
} else {
    print $query->header(status => '404 patron image not found');
}
