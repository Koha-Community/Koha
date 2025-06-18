#!/usr/bin/perl

# script to handle redirect back from OverDrive auth endpoint

# Copyright 2015 Catalyst IT
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
use CGI qw ( -utf8 );
use URI;
use URI::Escape qw( uri_escape );
use Koha::Logger;
use Koha::ExternalContent::OverDrive;

my $logger = Koha::Logger->get( { interface => 'opac' } );
my $cgi    = CGI->new;

my ( $user, $cookie, $sessionID, $flags ) = checkauth( $cgi, 1, {}, 'opac' );
my ( $redirect_page, $error );
if ( $user && $sessionID ) {
    my $od = Koha::ExternalContent::OverDrive->new( { koha_session_id => $sessionID } );
    if ( my $auth_code = $cgi->param('code') ) {
        my $base_url = $cgi->url( -base => 1 );
        local $@;
        $redirect_page = eval { $od->auth_by_code( $auth_code, $base_url ) };
        if ($@) {
            $logger->error($@);
            $error = $od->error_message($@);
        }
    } else {
        $error = "Missing OverDrive auth code";
    }
    $redirect_page ||= $od->get_return_page_from_koha_session;
} else {
    $error = "User not logged in";
}
$redirect_page ||= "/cgi-bin/koha/opac-user.pl";
my $uri = URI->new($redirect_page);
$uri->query_form( $uri->query_form, overdrive_tab => 1, overdrive_error => uri_escape( $error || "" ) );
print $cgi->redirect($redirect_page);
