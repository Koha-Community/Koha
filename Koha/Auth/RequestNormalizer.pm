package Koha::Auth::RequestNormalizer;

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

use Scalar::Util qw(blessed);


=head normalizeCGI

Takes a CGI-object and finds the authentication markers from it.
@PARAM1 CGI-object.
@PARAM2 ARRAYRef, authentication headers that should be extracted for authentication
@PARAM3 ARRAYRef, authentication POST parameters that should be extracted for authentication
@PARAM4 ARRAYRef, authentication cookies that should be extracted for authentication
@RETURNS List of : HASHRef of headers required for authentication, or undef
                   HASHRef of POST parameters required for authentication, or undef
                   HASHRef of the authenticaton cookie name => value, or undef
=cut

sub normalizeCGI {
    my ($controller, $authenticationHeaders, $authenticationPOSTparams, $authenticationCookies) = @_;

    my ($headers, $postParams, $cookies) = ({}, {}, {});
    foreach my $authHeader (@$authenticationHeaders) {
        if (my $val = $controller->http($authHeader)) {
            $headers->{$authHeader} = $val;
        }
    }
    foreach my $authParam (@$authenticationPOSTparams) {
        if (my $val = $controller->param($authParam)) {
            $postParams->{$authParam} = $val;
        }
    }
    foreach my $authCookie (@$authenticationCookies) {
        if (my $val = $controller->cookie($authCookie)) {
            $cookies->{$authCookie} = $val;
        }
    }

    my $method = $1 if ($ENV{SERVER_PROTOCOL} =~ /^(.+?)\//);

    my @originIps = ($ENV{'REMOTE_ADDR'});

    my $requestAuthElements = { #Collect the authentication elements here.
        headers => $headers,
        postParams => $postParams,
        cookies => $cookies,
        originIps => \@originIps,
        method => $method,
        url => $ENV{REQUEST_URI},
    };
    return $requestAuthElements;
}

=head normalizeMojolicious

Takes a Mojolicious::Controller-object and finds the authentication markers from it.
@PARAM1 Mojolicious::Controller-object.
@PARAM2-4 See normalizeCGI()
@RETURNS HASHRef of the request's authentication elements marked for extraction, eg:
        {
            headers => { X-Koha-Signature => '32rFrFw3iojsev34AS',
                         X-Koha-Username => 'pavlov'},
            POSTparams => { password => '1234',
                            userid => 'pavlov'},
            cookies => { CGISESSID => '233FADFEV3as1asS' },
            method => 'https',
            url => '/borrower/12/holds'
        }
=cut

sub normalizeMojolicious {
    my ($controller, $authenticationHeaders, $authenticationPOSTparams, $authenticationCookies) = @_;

    my $request = $controller->req();
    my ($headers, $postParams, $cookies) = ({}, {}, {});
    my $headersHash = $request->headers()->to_hash();
    foreach my $authHeader (@$authenticationHeaders) {
        if (my $val = $headersHash->{$authHeader}) {
            $headers->{$authHeader} = $val;
        }
    }
    foreach my $authParam (@$authenticationPOSTparams) {
        if (my $val = $request->param($authParam)) {
            $postParams->{$authParam} = $val;
        }
    }

    my $requestCookies = $request->cookies;
    if (scalar(@$requestCookies)) {
        foreach my $authCookieName (@$authenticationCookies) {
            foreach my $requestCookie (@$requestCookies) {
                if ($authCookieName eq $requestCookie->name) {
                    $cookies->{$authCookieName} = $requestCookie->value;
                }
            }
        }
    }

    my @originIps = ($controller->tx->original_remote_address());
    push @originIps, $request->headers()->header('X-Forwarded-For') if $request->headers()->header('X-Forwarded-For');

    my $requestAuthElements = { #Collect the authentication elements here.
        headers => $headers,
        postParams => $postParams,
        cookies => $cookies,
        originIps => \@originIps,
        method => $controller->req->method,
        url => '/' . $controller->req->url->path_query,
    };
    return $requestAuthElements;
}

=head getSessionCookie

@PARAM1 CGI- or Mojolicious::Controller-object, this is used to identify which web framework to use.
@PARAM2 CGI::Session.
@RETURNS a Mojolicious cookie or a CGI::Cookie.
=cut

sub getSessionCookie {
    my ($controller, $session) = @_;

    my $cookie = {
            name     => 'CGISESSID',
            value    => $session->id,
    };
    my $cookieOk;

    if (blessed($controller)) {
        if ($controller->isa('CGI')) {
            $cookie->{HttpOnly} = 1;
            $cookieOk = $controller->cookie( $cookie );
        }
        elsif ($controller->isa('Mojolicious::Controller')) {
            my $cooksreq = $controller->req->cookies;
            my $cooksres = $controller->res->cookies;
            foreach my $c (@{$controller->res->cookies}) {

                if ($c->name eq 'CGISESSID') {
                    $c->value($cookie->{value});
                    $cookieOk = $c;
                }
            }
        }
    }
    #No auth cookie, so we must make one :)
    unless ($cookieOk) {
        $controller->res->cookies($cookie);
        my $cooks = $controller->res->cookies();
        foreach my $c (@$cooks) {
            if ($c->name eq 'CGISESSID') {
                $cookieOk = $c;
                last;
            }
        }
    }
    return $cookieOk;
}

1;