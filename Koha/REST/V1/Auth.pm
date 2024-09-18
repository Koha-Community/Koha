package Koha::REST::V1::Auth;

# Copyright Koha-Suomi Oy 2017
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

use Mojo::Base 'Mojolicious::Controller';

use C4::Auth qw( check_cookie_auth checkpw_internal get_session haspermission );
use C4::Context;

use Koha::ApiKeys;
use Koha::Account::Lines;
use Koha::Checkouts;
use Koha::Holds;
use Koha::Libraries;
use Koha::OAuth;
use Koha::OAuthAccessTokens;
use Koha::Old::Checkouts;
use Koha::Patrons;

use Koha::Exceptions;
use Koha::Exceptions::Authentication;
use Koha::Exceptions::Authorization;

use MIME::Base64 qw( decode_base64 );
use Module::Load::Conditional;
use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

=head1 NAME

Koha::REST::V1::Auth

=head2 Operations

=head3 under

This subroutine is called before every request to API.

=cut

sub under {
    my ($c) = @_;

    my $status = 0;

    try {

        # /api/v1/{namespace}
        my $namespace = $c->req->url->to_abs->path->[2] // '';

        my $is_public = 0;    # By default routes are not public
        my $is_plugin = 0;

        if ( $namespace eq 'public' ) {
            $is_public = 1;
        } elsif ( $namespace eq 'contrib' ) {
            $is_plugin = 1;
        }

        if ($is_public) {
            Koha::Exceptions::UnderMaintenance->throw('Under maintenance')
                if C4::Context->preference('OPACMaintenance');
            Koha::Exceptions::Authorization->throw(
                "Configuration prevents the usage of this endpoint by unprivileged users")
                if !C4::Context->preference('RESTPublicAPI');
        }

        if (   $c->req->url->to_abs->path =~ m#^/api/v1/oauth/#
            || $c->req->url->to_abs->path =~ m#^/api/v1/public/oauth/# )
        {
            # Requesting OAuth endpoints shouldn't go through the API authentication chain
            $status = 1;
        } elsif ( $namespace eq '' or $namespace eq '.html' ) {
            $status = 1;
        } else {
            $status = authenticate_api_request( $c, { is_public => $is_public, is_plugin => $is_plugin } );
        }

    } catch {
        unless ( blessed($_) ) {
            $c->unhandled_exception($_);
        }
        if ( $_->isa('Koha::Exceptions::UnderMaintenance') ) {
            return $c->render( status => 503, json => { error => $_->error } );
        } elsif ( $_->isa('Koha::Exceptions::Authentication::SessionExpired') ) {
            return $c->render( status => 401, json => { error => $_->error } );
        } elsif ( $_->isa('Koha::Exceptions::Authentication::Required') ) {
            return $c->render( status => 401, json => { error => $_->error } );
        } elsif ( $_->isa('Koha::Exceptions::Authentication') ) {
            return $c->render( status => 401, json => { error => $_->error } );
        } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render( status => 400, json => $_->error );
        } elsif ( $_->isa('Koha::Exceptions::Authorization::Unauthorized') ) {
            return $c->render(
                status => 403,
                json   => {
                    error                => $_->error,
                    required_permissions => $_->required_permissions,
                }
            );
        } elsif ( $_->isa('Koha::Exceptions::Authorization') ) {
            return $c->render( status => 403, json => { error => $_->error } );
        } elsif ( $_->isa('Koha::Exceptions') ) {
            return $c->render( status => 500, json => { error => $_->error } );
        } else {
            $c->unhandled_exception($_);
        }
    };

    return $status;
}

=head3 authenticate_api_request

Validates authentication and allows access if authorization is not required or
if authorization is required and user has required permissions to access.

=cut

sub authenticate_api_request {
    my ( $c, $params ) = @_;

    my $user;

    $c->stash( 'is_public' => 1 )
        if $params->{is_public};

    # The following supports retrieval of spec with Mojolicious::Plugin::OpenAPI@1.17 and later (first one)
    # and older versions (second one).
    # TODO: remove the latter 'openapi.op_spec' if minimum version is bumped to at least 1.17.
    my $spec = $c->openapi->spec || $c->match->endpoint->pattern->defaults->{'openapi.op_spec'};

    $c->stash_embed( { spec => $spec } );
    $c->stash_overrides();

    my $cookie_auth = 0;

    my $authorization = $spec->{'x-koha-authorization'};

    my $authorization_header = $c->req->headers->authorization;

    if ( $authorization_header and $authorization_header =~ /^Bearer / ) {

        # attempt to use OAuth2 authentication
        if ( !Module::Load::Conditional::can_load( modules => { 'Net::OAuth2::AuthorizationServer' => undef } ) ) {
            Koha::Exceptions::Authorization::Unauthorized->throw( error => 'Authentication failure.' );
        } else {
            require Net::OAuth2::AuthorizationServer;
        }

        my $server = Net::OAuth2::AuthorizationServer->new;
        my $grant  = $server->client_credentials_grant(Koha::OAuth::config);
        my ( $type, $token ) = split / /, $authorization_header;
        my ( $valid_token, $error ) = $grant->verify_access_token(
            access_token => $token,
        );

        if ($valid_token) {
            my $patron_id = Koha::ApiKeys->find( $valid_token->{client_id} )->patron_id;
            $user = Koha::Patrons->find($patron_id);
        } else {

            # If we have "Authorization: Bearer" header and oauth authentication
            # failed, do not try other authentication means
            Koha::Exceptions::Authentication::Required->throw( error => 'Authentication failure.' );
        }
    } elsif ( $authorization_header and $authorization_header =~ /^Basic / ) {
        unless ( C4::Context->preference('RESTBasicAuth') ) {
            Koha::Exceptions::Authentication::Required->throw( error => 'Basic authentication disabled' );
        }
        $user = $c->_basic_auth($authorization_header);
        unless ($user) {

            # If we have "Authorization: Basic" header and authentication
            # failed, do not try other authentication means
            Koha::Exceptions::Authentication::Required->throw( error => 'Authentication failure.' );
        }
    } else {

        my $cookie = $c->cookie('CGISESSID');

        # Mojo doesn't use %ENV the way CGI apps do
        # Manually pass the remote_address to check_auth_cookie
        my $remote_addr = $c->tx->remote_address;
        my ( $status, $session ) = check_cookie_auth(
            $cookie, undef,
            { remote_addr => $remote_addr }
        );

        if ( $c->req->url->to_abs->path eq '/api/v1/auth/otp/token_delivery' ) {
            if ( $status eq 'additional-auth-needed' ) {
                $user        = Koha::Patrons->find( $session->param('number') );
                $cookie_auth = 1;
            } elsif ( $status eq 'ok' ) {
                Koha::Exceptions::Authentication->throw( error => 'Cannot request a new token.' );
            } else {
                Koha::Exceptions::Authentication::Required->throw( error => 'Authentication failure.' );
            }
        } elsif ( $c->req->url->to_abs->path eq '/api/v1/auth/two-factor/registration'
            || $c->req->url->to_abs->path eq '/api/v1/auth/two-factor/registration/verification' )
        {

            if ( $status eq 'setup-additional-auth-needed' ) {
                $user        = Koha::Patrons->find( $session->param('number') );
                $cookie_auth = 1;
            } elsif ( $status eq 'ok' ) {
                $user = Koha::Patrons->find( $session->param('number') );
                if ( $user->auth_method ne 'password' ) {

                    # If the user already enabled 2FA they don't need to register again
                    Koha::Exceptions::Authentication->throw( error => 'Cannot request this route.' );
                }
                $cookie_auth = 1;
            } else {
                Koha::Exceptions::Authentication::Required->throw( error => 'Authentication failure.' );
            }

        } else {
            if ( $status eq "ok" ) {
                $user        = Koha::Patrons->find( $session->param('number') );
                $cookie_auth = 1;
            } elsif ( $status eq "anon" ) {
                $cookie_auth = 1;
            } elsif ( $status eq "additional-auth-needed" ) {
            } elsif ( $status eq "maintenance" ) {
                Koha::Exceptions::UnderMaintenance->throw( error => 'System is under maintenance.' );
            } elsif ( $status eq "expired" and $authorization ) {
                Koha::Exceptions::Authentication::SessionExpired->throw( error => 'Session has been expired.' );
            } elsif ( $status eq "failed" and $authorization ) {
                Koha::Exceptions::Authentication::Required->throw( error => 'Authentication failure.' );
            } elsif ($authorization) {
                Koha::Exceptions::Authentication->throw( error => 'Unexpected authentication status.' );
            }
        }
    }

    $c->stash( 'koha.user' => $user );
    C4::Context->interface('api');

    if ( $user and !$cookie_auth ) {    # cookie-auth sets this and more, don't mess with that
        $c->_set_userenv($user);
    }

    if (
        !$authorization
        and (
            $params->{is_public} and ( C4::Context->preference('RESTPublicAnonymousRequests')
                or $user )
            or $params->{is_plugin}
        )
        )
    {
        # We do not need any authorization
        # Check the parameters
        validate_query_parameters( $c, $spec );
        return 1;
    } else {

        # We are required authorization, there needs
        # to be an identified user
        Koha::Exceptions::Authentication::Required->throw( error => 'Authentication failure.' )
            unless $user;
    }

    my $permissions = $authorization->{'permissions'};

    # Check if the user is authorized
    if ( ( defined($permissions) and haspermission( $user->userid, $permissions ) ) ) {

        validate_query_parameters( $c, $spec );

        # Everything is ok
        return 1;
    }

    Koha::Exceptions::Authorization::Unauthorized->throw(
        error                => "Authorization failure. Missing required permission(s).",
        required_permissions => $permissions,
    );
}

=head3 validate_query_parameters

Validates the query parameters against the spec.

=cut

sub validate_query_parameters {
    my ( $c, $action_spec ) = @_;

    # Check for malformed query parameters
    my @errors;
    my %valid_parameters = map { ( $_->{in} eq 'query' ) ? ( $_->{name} => 1 ) : () } @{ $action_spec->{parameters} };
    my $existing_params  = $c->req->query_params->to_hash;
    for my $param ( keys %{$existing_params} ) {
        push @errors, { path => "/query/" . $param, message => 'Malformed query string' }
            unless exists $valid_parameters{$param};
    }

    push @errors, { path => "/query/_per_page", message => 'Invalid value: 0' }
        if exists $existing_params->{_per_page} && $existing_params->{_per_page} == 0;

    Koha::Exceptions::BadParameter->throw( error => \@errors ) if @errors;
}

=head3 _basic_auth

Internal method that performs Basic authentication.

=cut

sub _basic_auth {
    my ( $c, $authorization_header ) = @_;

    my ( $type, $credentials ) = split / /, $authorization_header;

    unless ($credentials) {
        Koha::Exceptions::Authentication::Required->throw( error => 'Authentication failure.' );
    }

    my $decoded_credentials = decode_base64($credentials);
    my ( $identifier, $password ) = split( /:/, $decoded_credentials, 2 );

    my $patron = Koha::Patrons->find( { userid => $identifier } );
    $patron //= Koha::Patrons->find( { cardnumber => $identifier } );

    unless ( checkpw_internal( $identifier, $password ) ) {
        Koha::Exceptions::Authorization::Unauthorized->throw( error => 'Invalid password' );
    }

    if ( $patron->password_expired ) {
        Koha::Exceptions::Authorization::Unauthorized->throw( error => 'Password has expired' );
    }

    return $patron;
}

=head3 _set_userenv

    $c->_set_userenv( $patron );

Internal method that sets C4::Context->userenv

=cut

sub _set_userenv {
    my ( $c, $patron ) = @_;

    my $passed_library_id = $c->req->headers->header('x-koha-library');
    my $THE_library;

    if ($passed_library_id) {
        $THE_library = Koha::Libraries->find($passed_library_id);
        Koha::Exceptions::Authorization::Unauthorized->throw(
            "Unauthorized attempt to set library to $passed_library_id")
            unless $THE_library and $patron->can_log_into($THE_library);
    } else {
        $THE_library = $patron->library;
    }

    C4::Context->set_userenv(
        $patron->borrowernumber,     # number,
        $patron->userid,             # userid,
        $patron->cardnumber,         # cardnumber
        $patron->firstname,          # firstname
        $patron->surname,            # surname
        $THE_library->branchcode,    # branch
        $THE_library->branchname,    # branchname
        $patron->flags,              # flags,
        $patron->email,              # emailaddress
    );

    return $c;
}

1;
