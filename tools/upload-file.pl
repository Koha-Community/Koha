#!/usr/bin/perl

# Copyright (C) 2007 LibLime
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

use CGI qw ( -utf8 );
use CGI::Cookie;
use Encode;
use JSON;
use URI::Escape;

use C4::Context;
use C4::Auth qw/check_cookie_auth haspermission/;
use Koha::Upload;

# upload-file.pl must authenticate the user
# before processing the POST request,
# and quickly bounce if the user is
# not authorized.  Consequently, unlike
# most of the other CGI scripts, upload-file.pl
# requires that the session cookie already
# has been created.

my %cookies = CGI::Cookie->fetch;
my $sid = $cookies{'CGISESSID'}->value;
my ( $auth_status, $sessionID ) = check_cookie_auth( $sid );
my $uid = C4::Auth::get_session($sid)->param('id');
my $allowed = Koha::Upload->allows_add_by( $uid );

if( $auth_status ne 'ok' || !$allowed ) {
    send_reply( 'denied' );
    exit 0;
}

my $upload = Koha::Upload->new( upload_pars($ENV{QUERY_STRING}) );
if( !$upload || !$upload->cgi || !$upload->count ) {
    # not one upload succeeded
    send_reply( 'failed', undef, $upload? $upload->err: undef );
} else {
    # in case of multiple uploads, at least one got through
    send_reply( 'done', $upload->result, $upload->err );
}
exit 0;

sub send_reply {    # response will be sent back as JSON
    my ( $upload_status, $data, $error ) = @_;
    my $reply = CGI->new("");
    print $reply->header( -type => 'text/html', -charset => 'UTF-8' );
    print JSON::encode_json({
        status => $upload_status,
        fileid => $data,
        errors => $error,
   });
}

sub upload_pars { # this sub parses QUERY_STRING in order to build the
                  # parameter hash for Koha::Upload
    my ( $qstr ) = @_;
    $qstr = Encode::decode_utf8( uri_unescape( $qstr ) );
    # category could include a utf8 character
    my $rv = {};
    foreach my $p ( qw[public category temp] ) {
        if( $qstr =~ /(^|&)$p=(\w+)(&|$)/ ) {
            $rv->{$p} = $2;
        }
    }
    return $rv;
}
