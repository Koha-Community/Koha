#!/usr/bin/perl

# Copyright 2011 KohaAloha, NZ
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1

A non-javascript method to add/modify a biblio's rating, called from opac-detail.pl

note: there is currently no 'delete rating' functionality in this script

=cut

use strict;
use warnings;
use CGI qw ( -utf8 );
use CGI::Cookie;

use C4::Auth;
use C4::Context;
use C4::Ratings;
use C4::Debug;

my $query = CGI->new();

# auth required to add ratings
my ($userid, $cookie, $sessionID) = checkauth( $query, 0, {}, 'opac' );
my $loggedinuser = C4::Context->userenv->{'number'};

my $biblionumber     = $query->param('biblionumber');
my $rating_old_value = $query->param('rating_value');
my $rating_value     = $query->param('rating');
my $rating;

if ( !$rating_old_value ) {
    $rating = AddRating( $biblionumber, $loggedinuser, $rating_value );
}
else {
    $rating = ModRating( $biblionumber, $loggedinuser, $rating_value );
}
print $query->redirect(
    "/cgi-bin/koha/opac-detail.pl?biblionumber=$biblionumber");
