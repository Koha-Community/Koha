package Koha::Auth::Challenge::RESTV1;

# Copyright 2015 Vaara-kirjastot
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
use DateTime::Format::HTTP;
use DateTime;

use Koha::Patrons;

use base qw(Koha::Auth::Challenge);

use Koha::Exception::LoginFailed;
use Koha::Exception::BadParameter;
use Koha::Exception::Parse;

=head challenge

    my $borrower = Koha::Auth::Challenge::RESTV1::challenge();

For authentication to succeed, the client have to send 2 HTTP
headers:
 - X-Koha-Date: the standard HTTP Date header complying to RFC 1123, simply wrapped to X-Koha-Date,
                since the w3-specification forbids setting the Date-header from javascript.
 - Authorization: the standard HTTP Authorization header, see below for how it is constructed.

=head2 HTTP Request example

GET /api/v1/borrowers/12 HTTP/1.1
Host: api.yourkohadomain.fi
X-Koha-Date: Mon, 26 Mar 2007 19:37:58 +0000
Authorization: Koha admin69:frJIUN8DYpKDtOLCwo//yllqDzg=

=head2 Constructing the Authorization header

-You brand the authorization header with "Koha"
-Then you give the userid/cardnumber of the user authenticating.
-Then the hashed signature.

The signature is a HMAC-SHA256-HEX hash of several elements of the request,
separated by spaces:
 - HTTP method (uppercase)
 - userid/cardnumber
 - X-Koha-Date-header
Signed with the Borrowers API key

The server then tries to rebuild the signature with each of the user's API keys.
If one matches the received signature, then authentication is almost OK.

To avoid requests to be replayed, the last request's X-Koha-Date-header is stored
in database and the authentication succeeds only if the stored Date
is lesser than the X-Koha-Date-header.

=head2 Constructing the signature example

Signature = HMAC-SHA256-HEX("HTTPS" + " " +
                            "/api/v1/borrowers/12?howdoyoudo=voodoo" + " " +
                            "admin69" + " " +
                            "760818212" + " " +
                            "frJIUN8DYpKDtOLCwo//yllqDzg="
                           );

=head

@PARAM1 HASHRef of Header name => values
@PARAM2 String, upper case request method name, eg. HTTP or HTTPS
@PARAM3 String the request uri
@RETURNS Koha::Patron if authentication succeeded.
@THROWS Koha::Exception::LoginFailed, if API key signature verification failed
@THROWS Koha::Exception::BadParameter
@THROWS Koha::Exception::UnknownObject, if we cannot find a Borrower with the given input.
=cut

sub challenge {
    my ($headers, $method, $uri) = @_;

    my $req_dt;
    eval {
        $req_dt = DateTime::Format::HTTP->parse_datetime( $headers->{'X-Koha-Date'} ); #Returns DateTime
    };
    if (not($req_dt) || $@) {
        Koha::Exception::BadParameter->throw(error => "X-Koha-Date HTTP-header [".$headers->{'X-Koha-Date'}."] is not well formed. It needs to be of RFC 1123 -date format, eg. 'X-Koha-Date: Wed, 09 Feb 1994 22:23:32 +0200'");
    }

    my $authorizationHeader = $headers->{'Authorization'};
    my ($req_username, $req_signature);
    if ($authorizationHeader =~ /^Koha (\S+?):(\w+)$/) {
        $req_username = $1;
        $req_signature = $2;
    }
    else {
        Koha::Exception::BadParameter->throw(error => "Authorization HTTP-header is not well formed. It needs to be of format 'Authorization: Koha userid:signature'");
    }

    my $borrower = Koha::Patrons->cast($req_username);

    my @apikeys = Koha::ApiKeys->search({
        borrowernumber => $borrower->borrowernumber,
        active => 1,
    });
    Koha::Exception::LoginFailed->throw(error => "User has no API keys. Please add one using the Staff interface or OPAC.") unless @apikeys;

    my $matchingApiKey;
    foreach my $apikey (@apikeys) {
        my $signature = makeSignature($method, $req_username, $headers->{'X-Koha-Date'}, $apikey);

        if ($signature eq $req_signature) {
            $matchingApiKey = $apikey;
            last();
        }
    }

    unless ($matchingApiKey) {
        Koha::Exception::LoginFailed->throw(error => "API key authentication failed.");
    }

    #Checking for message replay abuses or change control using ETAG shouldn't be done here, since we need to make valid request more often than every second.
    #unless ($matchingApiKey->last_request_time < $req_dt->epoch()) {
    #    Koha::Exception::BadParameter->throw(error => "X-Koha-Date HTTP-header is stale, expected later date than '".DateTime::Format::HTTP->format_datetime($req_dt)."'");
    #}

    $matchingApiKey->set({last_request_time => $req_dt->epoch()});
    $matchingApiKey->store();

    return $borrower;
}

sub makeSignature {
    my ($method, $userid, $headerXKohaDate, $apiKey) = @_;

    my $message = join(' ', uc($method), $userid, $headerXKohaDate);
    my $digest = Digest::SHA::hmac_sha256_hex($message, $apiKey->api_key);

    if ($ENV{KOHA_REST_API_DEBUG} > 2) {
        my @cc = caller(1);
        print "\n".$cc[3]."\nMAKESIGNATURE $method, $userid, $headerXKohaDate, ".$apiKey->api_key.", DIGEST $digest\n";
    }

    return $digest;
}

=head prepareAuthenticationHeaders
@PARAM1 Koha::Patron, to authenticate
@PARAM2 DateTime, OPTIONAL, the timestamp of the HTTP request
@PARAM3 HTTP verb, 'get', 'post', 'patch', 'put', ...
@RETURNS HASHRef of authentication HTTP header names and their values. {
            "X-Koha-Date" => "Mon, 26 Mar 2007 19:37:58 +0000",
            "Authorization" => "Koha admin69:frJIUN8DYpKDtOLCwo//yllqDzg=",
        }
=cut

sub prepareAuthenticationHeaders {
    my ($borrower, $dateTime, $method) = @_;
    $borrower = Koha::Patrons->cast($borrower);

    my $headerXKohaDate = DateTime::Format::HTTP->format_datetime(
                                                ($dateTime || DateTime->now( time_zone => C4::Context->tz() ))
                          );
    my $headerAuthorization = "Koha ".$borrower->userid.":".makeSignature($method, $borrower->userid, $headerXKohaDate, $borrower->getApiKey('active'));
    return {'X-Koha-Date' => $headerXKohaDate,
            'Authorization' => $headerAuthorization};
}

1;
