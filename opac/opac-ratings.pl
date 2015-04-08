#!/usr/bin/perl

# Copyright 2011 KohaAloha, NZ
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

=head1

A non-javascript method to add/modify a biblio's rating, called from opac-detail.pl

note: there is currently no 'delete rating' functionality in this script

=cut

use strict;
use warnings;
use CGI;
use CGI::Cookie;
use C4::Auth qw(:DEFAULT check_cookie_auth);
use C4::Context;
use C4::Output;
use C4::Dates qw(format_date);
use C4::Biblio;
use C4::Ratings;
use C4::Debug;

my $query = CGI->new();
my $a     = $query->Vars;
####  $a
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,        # auth required to add tags
        debug           => 0,
    }
);

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
