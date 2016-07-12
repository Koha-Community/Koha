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

=head1 DESCRIPTION

A script that takes an ajax json query, and then inserts or modifies a star-rating.

=cut

use strict;
use warnings;

use CGI qw ( -utf8 );
use CGI::Cookie;  # need to check cookies before having CGI parse the POST request

use C4::Auth qw(:DEFAULT check_cookie_auth);
use C4::Context;
use C4::Debug;
use C4::Output qw(:html :ajax pagination_bar);
use C4::Ratings;

use Koha::Ratings;

use JSON;

my $is_ajax = is_ajax();

my ( $query, $auth_status );
if ($is_ajax) {
    ( $query, $auth_status ) = &ajax_auth_cgi( {} );
}
else {
    $query = CGI->new();
}

my $biblionumber     = $query->param('biblionumber');
my $rating_value     = $query->param('rating_value');
my $rating_old_value = $query->param('rating_old_value');

my ( $template, $loggedinuser, $cookie );
if ($is_ajax) {
    $loggedinuser = C4::Context->userenv->{'number'};
}
else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "opac-detail.tt",
            query           => $query,
            type            => "opac",
            authnotrequired => 0,                    # auth required to add tags
            debug           => 1,
        }
    );
}

my $rating;
$rating_value //= '';

if ( $rating_value eq '' ) {
    Koha::Ratings->find( { biblionumber => $biblionumber, borrowernumber => $loggedinuser } )->delete;
    $rating = Koha::Ratings->search({ biblionumber => $biblionumber })->get_rating;
}

elsif ( $rating_value and !$rating_old_value ) {
    $rating = Koha::Rating->new( { biblionumber => $biblionumber, borrowernumber => $loggedinuser, rating_value => $rating_value, })->store;
}

elsif ( $rating_value ne $rating_old_value ) {
    $rating = Koha::Ratings->find( { biblionumber => $biblionumber, borrowernumber => $loggedinuser })->rating_value($rating_value)->store;
}

my %js_reply = (
    rating_total   => $rating->{'rating_total'},
    rating_avg     => $rating->{'rating_avg'},
    rating_avg_int => $rating->{'rating_avg_int'},
    rating_value   => $rating->{'rating_value'},
    auth_status    => $auth_status,

);

my $json_reply = JSON->new->encode( \%js_reply );

#### $rating
#### %js_reply
#### $json_reply

output_ajax_with_http_headers( $query, $json_reply );
exit;

# a ratings specific ajax return sub, returns CGI object, and an 'auth_success' value
sub ajax_auth_cgi {
    my $needed_flags = shift;
    my %cookies      = CGI::Cookie->fetch;
    my $input        = CGI->new;
    my $sessid = $cookies{'CGISESSID'}->value || $input->param('CGISESSID');
    my ( $auth_status, $auth_sessid ) =
      check_cookie_auth( $sessid, $needed_flags );
    return $input, $auth_status;
}
