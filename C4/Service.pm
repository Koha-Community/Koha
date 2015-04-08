package C4::Service;
#
# Copyright 2008 LibLime
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

=head1 NAME

C4::Service - functions for JSON webservices.

=head1 SYNOPSIS

my ( $query, $response) = C4::Service->init( { circulate => 1 } );
my ( $borrowernumber) = C4::Service->require_params( 'borrowernumber' );

C4::Service->return_error( 'internal', 'Frobnication failed', frobnicator => 'foo' );

$response->param( frobnicated => 'You' );

C4::Service->return_success( $response );

=head1 DESCRIPTION

This module packages several useful functions for JSON webservices.

=cut

use strict;
use warnings;

use CGI;
use C4::Auth qw( check_api_auth );
use C4::Output qw( :ajax );
use C4::Output::JSONStream;
use JSON;

our $debug;

BEGIN {
    $debug = $ENV{DEBUG} || 0;
}

our ( $query, $cookie );

=head1 METHODS

=head2 init

   our ( $query, $response ) = C4::Service->init( %needed_flags );

Initialize the service and check for the permissions in C<%needed_flags>.

Also, check that the user is authorized and has a current session, and return an
'auth' error if not.

init() returns a C<CGI> object and a C<C4::Output::JSONStream>. The latter can
be used for both flat scripts and those that use dispatch(), and should be
passed to C<return_success()>.

=cut

sub init {
    my ( $class, %needed_flags ) = @_;

    our $query = new CGI;

    my ( $status, $cookie_, $sessionID ) = check_api_auth( $query, \%needed_flags );

    our $cookie = $cookie_; # I have no desire to offend the Perl scoping gods

    $class->return_error( 'auth', $status ) if ( $status ne 'ok' );

    return ( $query, new C4::Output::JSONStream );
}

=head2 return_error

    C4::Service->return_error( $type, $error, %flags );

Exit the script with HTTP status 400, and return a JSON error object.

C<$type> should be a short, lower case code for the generic type of error (such
as 'auth' or 'input').

C<$error> should be a more specific code giving information on the error. If
multiple errors of the same type occurred, they should be joined by '|'; i.e.,
'expired|different_ip'. Information in C<$error> does not need to be
human-readable, as its formatting should be handled by the client.

Any additional information to be given in the response should be passed as
param => value pairs.

=cut

sub return_error {
    my ( $class, $type, $error, %flags ) = @_;

    my $response = new C4::Output::JSONStream;

    $response->param( message => $error ) if ( $error );
    $response->param( type => $type, %flags );

    output_with_http_headers $query, $cookie, $response->output, 'json', '400 Bad Request';
    exit;
}

=head2 return_multi

    C4::Service->return_multi( \@responses, %flags );

return_multi is similar to return_success or return_error, but allows you to
return different statuses for several requests sent at once (using HTTP status
"207 Multi-Status", much like WebDAV). The toplevel hashref (turned into the
JSON response) looks something like this:

    { multi => JSON::true, responses => \@responses, %flags }

Each element of @responses should be either a plain hashref or an arrayref. If
it is a hashref, it is sent to the browser as-is. If it is an arrayref, it is
assumed to be in the same form as the arguments to return_error, and is turned
into an error structure.

All key-value pairs %flags are, as stated above, put into the returned JSON
structure verbatim.

=cut

sub return_multi {
    my ( $class, $responses, @flags ) = @_;

    my $response = new C4::Output::JSONStream;

    if ( !@$responses ) {
        $class->return_success( $response );
    } else {
        my @responses_formatted;

        foreach my $response ( @$responses ) {
            if ( ref( $response ) eq 'ARRAY' ) {
                my ($type, $error, @error_flags) = @$response;

                push @responses_formatted, { is_error => JSON::true, type => $type, message => $error, @error_flags };
            } else {
                push @responses_formatted, $response;
            }
        }

        $response->param( 'multi' => JSON::true, responses => \@responses_formatted, @flags );
        output_with_http_headers $query, $cookie, $response->output, 'json', '207 Multi-Status';
    }

    exit;
}

=head2 return_success

    C4::Service->return_success( $response );

Print out the information in the C<C4::Output::JSONStream> C<$response>, then
exit with HTTP status 200.

=cut

sub return_success {
    my ( $class, $response ) = @_;

    output_with_http_headers $query, $cookie, $response->output, 'json';
}

=head2 require_params

    my @values = C4::Service->require_params( @params );

Check that each of of the parameters specified in @params was sent in the
request, then return their values in that order.

If a required parameter is not found, send a 'param' error to the browser.

=cut

sub require_params {
    my ( $class, @params ) = @_;

    my @values;

    for my $param ( @params ) {
        $class->return_error( 'params', "Missing '$param'" ) if ( !defined( $query->param( $param ) ) );
        push @values, $query->param( $param );
    }

    return @values;
}

=head2 dispatch

    C4::Service->dispatch(
        [ $path_regex, \@required_params, \&handler ],
        ...
    );

dispatch takes several array-refs, each one describing a 'route', to use the
Rails terminology.

$path_regex should be a string in regex-form, describing which methods and
paths this route handles. Each route is tested in order, from the top down, so
put more specific handlers first. Also, the regex is tested on the request
method, plus the path. For instance, you might use the route [ 'POST /', ... ]
to handle POST requests to your service.

Each named parameter in @required_params is tested for to make sure the route
matches, but does not raise an error if one is missing; it simply tests the next
route. If you would prefer to raise an error, instead use
C<C4::Service->require_params> inside your handler.

\&handler is called with each matched group in $path_regex in its arguments. For
example, if your service is accessed at the path /blah/123, and you call
C<dispatch> with the route [ 'GET /blah/(\\d+)', ... ], your handler will be called
with the argument '123'.

=cut

sub dispatch {
    my $class = shift;

    my $path_info = $query->path_info || '/';

    ROUTE: foreach my $route ( @_ ) {
        my ( $path, $params, $handler ) = @$route;

        next unless ( my @match = ( ($query->request_method . ' ' . $path_info)   =~ m,^$path$, ) );

        for my $param ( @$params ) {
            next ROUTE if ( !defined( $query->param ( $param ) ) );
        }

        $debug and warn "Using $path";
        $handler->( @match );
        return;
    }

    $class->return_error( 'no_handler', '' );
}

1;

__END__

=head1 AUTHORS

Koha Development Team

Jesse Weaver <jesse.weaver@liblime.com>
