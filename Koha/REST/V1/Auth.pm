package Koha::REST::V1::Auth;

# Copyright Koha-Suomi Oy 2017
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use CGI;

use C4::Auth qw( check_cookie_auth get_session haspermission );

use Koha::Account::Lines;
use Koha::Auth;
use Koha::Checkouts;
use Koha::Holds;
use Koha::Notice::Messages;
use Koha::Old::Checkouts;
use Koha::Patrons;

use Koha::Exceptions;
use Koha::Exceptions::Authentication;
use Koha::Exceptions::Authorization;

use Scalar::Util qw( blessed );
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Auth

=head2 Operations

=head3 under

This subroutine is called before every request to API.

=cut

sub under {
    my $c = shift->openapi->valid_input or return;;

    my $status = 0;
    try {

        $status = authenticate_api_request($c);

    } catch {
        unless (blessed($_)) {
            return $c->render(
                status => 500,
                json => { error => 'Something went wrong, check the logs.' }
            );
        }
        if ($_->isa('Koha::Exceptions::UnderMaintenance')) {
            return $c->render(status => 503, json => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Authentication::SessionExpired')) {
            return $c->render(status => 401, json => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Authentication::Required')) {
            return $c->render(status => 401, json => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::Authentication')) {
            return $c->render(status => 500, json => { error => $_->error });
        }
        elsif ($_->isa('Koha::Exceptions::BadParameter')) {
            return $c->render(status => 400, json => $_->error );
        }
        elsif ($_->isa('Koha::Exceptions::Authorization::Unauthorized')) {
            return $c->render(status => 403, json => {
                error => $_->error,
                required_permissions => $_->required_permissions,
            });
        }
        elsif ($_->isa('Koha::Exceptions')) {
            return $c->render(status => 500, json => { error => $_->error });
        }
        Koha::Exceptions::rethrow_exception($_);
    };

    return $status;
}

sub login {
    my $c = shift->openapi->valid_input or return;;

    my $userid = $c->validation->param('userid') ||
                 $c->validation->param('cardnumber');
    my $password = $c->validation->param('password');
    my $patron;

    $ENV{'REMOTE_ADDR'} = $c->tx->remote_address;

    return $c->render( status => 400, openapi => {
        error => "Either userid or cardnumber is required "
                             ."- neither given." }) unless ($userid);

    my $cgi = CGI->new;
    $cgi->param(userid => $userid);
    $cgi->param(password => $password);
    my ($status, $cookie, $sessionid) = C4::Auth::check_api_auth($cgi);

    return $c->render( status => 401, openapi => { error => "Login failed." }) if $status eq "failed";
    return $c->render( status => 401, openapi => { error => "Session expired." }) if $status eq "expired";
    return $c->render( status => 503, openapi => { error => "Database is under maintenance." }) if $status eq "maintenance";
    return $c->render( status => 401, openapi => { error => "Login failed." }) unless $status eq "ok";

    $patron = Koha::Patrons->find({ userid => $userid }) unless $patron;
    $patron = Koha::Patrons->find({ cardnumber => $userid }) unless $patron;

    if ($patron && $patron->lost) {
        return $c->render( status => 403, openapi => { error =>
                "Patron's card has been marked as 'lost'. Access forbidden." });
    }

    my $session = _swaggerize_session($sessionid, $patron);

    $c->cookie(CGISESSID => $sessionid, { path => "/" });

    return $c->render( status => 201, openapi => $session);
}

sub logout {
    my $c = shift->openapi->valid_input or return;;

    my $json = $c->req->json;
    my $sessionid = exists $json->{sessionid} ? $json->{sessionid} : undef;
    $sessionid = $c->cookie('CGISESSID') unless $sessionid;

    my ($status, $sid) = C4::Auth::check_cookie_auth($sessionid);
    unless ($status eq "ok") {
        return $c->render( status  => 401,
                           openapi => { error => "Invalid session id."});
    }

    $c->cookie(CGISESSID => $sessionid, { path => "/", expires => 1 });

    my $session = C4::Auth::get_session($sessionid);
    $session->delete;
    $session->flush;
    return $c->render( status => 200, openapi => {});
}

=head3 get_api_session

Checks whether the given sessionid is valid at the time. If a valid session is
found, a minimal subset of borrower's info is returned for the SSO-scheme.

=cut

sub get_api_session {
    my $c = shift->openapi->valid_input or return;

    my $sessionId = $c->req->json->{sessionid};
    my $session = C4::Auth::get_session($sessionId);

    # If the returned session equals the given session, accept it as a valid
    # session and return it.
    # Otherwise, destroy the created session.
    if ($sessionId eq $session->id()) {

        # See if the given session is timed out
        if (Koha::Auth::Challenge::Cookie::isSessionExpired($session)) {
            return $c->render( status => 401, openapi => {
                error => "Koha's session expired."} );
        }

        my $patron = Koha::Patrons->find($session->param('number'));
        unless ($patron) {
            return $c->render( status => 404, openapi => {
                error => "Patron not found"} );
        }

        return $c->render(
            status => 200,
            openapi => _swaggerize_session($sessionId, $patron)
        );
    }
    else {
        $session->delete();
        $session->flush();
        return $c->render( status => 404, openapi => {
            error => "Bad session id"} );
    }
}

sub _swaggerize_session {
    my ($sessionid, $patron) = @_;

    return unless ref($patron) eq 'Koha::Patron';

    my $rawPermissions = C4::Auth::haspermission($patron->userid); # defaults to all permissions
    my @permissions;

    # delete all empty permissions
    while ( my ($key, $val) = each %{$rawPermissions} ) {
        push @permissions, $key if $val;
    }

    return {
        borrowernumber => 0+$patron->borrowernumber,
        firstname => $patron->firstname,
        surname  => $patron->surname,
        email     => $patron->email,
        sessionid => $sessionid,
        permissions => \@permissions,
    };
}

=head3 authenticate_api_request

Validates authentication and allows access if authorization is not required or
if authorization is required and user has required permissions to access.

=cut

sub authenticate_api_request {
    my ( $c ) = @_;

    my $spec = $c->openapi->spec;
    my $authorization = $spec->{'x-koha-authorization'};
    my $user;
    if ($c->req->headers->header('Authorization')) {
        ($user, undef) = _header_auth($c, $authorization);
        $c->stash('koha.user', $user);
    } else {
        ($user, undef) = _cookie_auth($c, $authorization);
    }

    # We do not need any authorization
    unless ($authorization) {
        # Check the parameters
        validate_query_parameters( $c, $spec );
        return 1;
    }

    my $permissions = $authorization->{'permissions'};
    # Check if the user is authorized
    my ($owner_access, $guarantor_access, $guarantee_access);
    if ( $user && ( haspermission($user->userid, $permissions)
        or $owner_access = allow_owner($c, $authorization, $user)
        or $guarantor_access = allow_guarantor($c, $authorization, $user)
        or $guarantee_access = allow_guarantee($c, $authorization, $user) ) ) {

        Koha::Exceptions::Authorization::Unauthorized->throw(
            error => "Patron's card has been marked as 'lost'. Access forbidden."
        ) if $user && $user->lost;

        validate_query_parameters( $c, $spec );

        # Store information on owner/guarantor access
        $c->stash('is_owner_access', 1) if $owner_access;
        $c->stash('is_guarantor_access', 1) if $guarantor_access;
        $c->stash('is_guarantee_access', 1) if $guarantee_access;

        # Everything is ok
        return 1;
    }

    unless ($user) {
        Koha::Exceptions::Authentication::Required->throw(
            error => 'Unknown authenticated user. Perhaps you have an anonymous'
                    .' session?'
        );
    }

    Koha::Exceptions::Authorization::Unauthorized->throw(
        error => "Authorization failure. Missing required permission(s).",
        required_permissions => $permissions,
    );
}
sub validate_query_parameters {
    my ( $c, $action_spec ) = @_;

    # Check for malformed query parameters
    my @errors;
    my %valid_parameters = map { ( $_->{in} eq 'query' ) ? ( $_->{name} => 1 ) : () } @{ $action_spec->{parameters} };
    my $existing_params = $c->req->query_params->to_hash;
    for my $param ( keys %{$existing_params} ) {
        push @errors, { path => "/query/" . $param, message => 'Malformed query string' } unless exists $valid_parameters{$param};
    }

    Koha::Exceptions::BadParameter->throw(
        error => \@errors
    ) if @errors;
}


sub _cookie_auth {
    my ($c, $authorization) = @_;

    my $json = $c->req->json;
    my $cookie = exists $json->{sessionid} ? $json->{sessionid} : undef;
    $cookie = $c->cookie('CGISESSID') unless $cookie;
    my $user;
    # Mojo doesn't use %ENV the way CGI apps do
    # Manually pass the remote_address to check_auth_cookie
    my $remote_addr = $c->tx->remote_address;
    my ($status, $sessionID) = check_cookie_auth(
                                            $cookie, undef,
                                            { remote_addr => $remote_addr });
    my $session;
    if ($status eq "ok") {
        $session = get_session($sessionID);
        $user = Koha::Patrons->find($session->param('number'));
        if ($session->param('number') eq '0') {
            Koha::Exceptions::Authentication::Required->throw(
                error => 'Please do not use the API as the database '
                        .'administrative user. This could cause problems!'
            );
        }
        $c->stash('koha.user' => $user);
    }
    elsif ($status eq "maintenance") {
        Koha::Exceptions::UnderMaintenance->throw(
            error => 'System is under maintenance.'
        );
    }
    elsif ($status eq "expired" and $authorization) {
        Koha::Exceptions::Authentication::SessionExpired->throw(
            error => 'Session has been expired.'
        );
    }
    elsif ($status eq "failed" and $authorization) {
        Koha::Exceptions::Authentication::Required->throw(
            error => 'Authentication failure.'
        );
    }
    elsif ($authorization) {
        Koha::Exceptions::Authentication->throw(
            error => 'Unexpected authentication status.'
        );
    }

    return ($user, $cookie);
}

sub _header_auth {
    my ($c, $authorization) = @_;

    try {
        return Koha::Auth::authenticate(
            $c, $authorization->{'permissions'},
            { authnotrequired => defined $authorization ? 0 : 1 }
        );
    }
    catch {
        my $e = $_;
        die $e unless blessed($e);

        if (
            $e->isa('Koha::Exception::LoginFailed') ||
            $e->isa('Koha::Exception::UnknownObject')
        ) {
            Koha::Exceptions::Authentication::Required->throw(
                error => $e->error
            );
        }
        elsif ($e->isa('Koha::Exception::NoPermission')) {
            Koha::Exceptions::Authorization::Unauthorized->throw(
                error => $e->error,
                required_permissions => $authorization->{'permissions'},
            );
        }
        elsif ($e->isa('Koha::Exception::BadParameter')) {
            Koha::Exceptions::BadParameter->throw(
                error => $e->error
            );
        }
        elsif ($e->isa('Koha::Exception::VersionMismatch') ||
               $e->isa('Koha::Exception::BadSystemPreference') ||
               $e->isa('Koha::Exception::ServiceTemporarilyUnavailable')
        ){
            Koha::Exceptions::UnderMaintenance->throw(
                error => $e->error
            );
        }
        else {
            $e->rethrow();
        }
    };
}

=head3 allow_owner

Allows access to object for its owner.

There are endpoints that should allow access for the object owner even if they
do not have the required permission, e.g. access an own reserve. This can be
achieved by defining the operation as follows:

"/holds/{reserve_id}": {
    "get": {
        ...,
        "x-koha-authorization": {
            "allow-owner": true,
            "permissions": {
                "borrowers": "1"
            }
        }
    }
}

=cut

sub allow_owner {
    my ($c, $authorization, $user) = @_;

    return unless $authorization->{'allow-owner'};

    return check_object_ownership($c, $user) if $user and $c;
}

=head3 allow_guarantor

Same as "allow_owner", but checks if the object is owned by one of C<$user>'s
guarantees.

=cut

sub allow_guarantor {
    my ($c, $authorization, $user) = @_;

    if (!$c || !$user || !$authorization || !$authorization->{'allow-guarantor'}){
        return;
    }

    my $guarantees = $user->guarantees->as_list;
    unless (@$guarantees) {
        # Allow access to /api/v1/patrons?guarantorid=XXX when $user's
        # borrowernumber is XXX and user has no guarantees. This lets us return an
        # empty array instead of HTTP 403.
        if ($c->req->url->path =~
            /^(\/?api\/v1\/patrons|\/?api\/v1\/app\.pl\/api\/v1\/patrons)/ &&
           defined $c->req->query_params->to_hash->{guarantorid} &&
           $c->req->query_params->to_hash->{guarantorid} eq $user->borrowernumber)
        {
            return 1;
        }
    }
    foreach my $guarantee (@{$guarantees}) {
        return 1 if check_object_ownership($c, $guarantee, {
            guarantorid => \&_object_ownership_by_guarantorid
        });
    }
}

=head3 allow_guarantee

Same as "allow_guarantor", but checks if the object is owned by C<$user>'s
guarantor.

=cut

sub allow_guarantee {
    my ($c, $authorization, $user) = @_;

    if (!$c || !$user || !$authorization || !$authorization->{'allow-guarantee'}){
        return;
    }

    my $guarantor = Koha::Patrons->find($user->guarantorid);
    return unless $guarantor;
    return 1 if check_object_ownership($c, $guarantor, {
        guarantorid => \&_object_ownership_by_borrowernumber
    });
}

=head3 check_object_ownership

Determines ownership of an object from request parameters.

As introducing an endpoint that allows access for object's owner; if the
parameter that will be used to determine ownership is not already inside
$parameters, add a new subroutine that checks the ownership and extend
$parameters to contain a key with parameter_name and a value of a subref to
the subroutine that you created.

=cut

sub check_object_ownership {
    my ($c, $user, $additional_checks) = @_;

    return if not $c or not $user;

    my $parameters = {
        accountlines_id => \&_object_ownership_by_accountlines_id,
        borrowernumber  => \&_object_ownership_by_borrowernumber,
        checkout_id     => \&_object_ownership_by_checkout_id,
        reserve_id      => \&_object_ownership_by_reserve_id,
        message_id      => \&_object_ownership_by_message_id,
        suggestionid    => \&_object_ownership_by_suggestionid,
        suggestedby     => \&_object_ownership_by_suggestedby,
    };
    foreach my $check (keys %$additional_checks) {
        $parameters->{$check} = $additional_checks->{$check};
    }

    foreach my $param ( keys %{ $parameters } ) {
        my $check_ownership = $parameters->{$param};
        if ($c->stash($param)) {
            return &$check_ownership($c, $user, $c->stash($param));
        }
        elsif ($c->param($param)) {
            return &$check_ownership($c, $user, $c->param($param));
        }
        elsif ($c->match->stack->[-1]->{$param}) {
            return &$check_ownership($c, $user, $c->match->stack->[-1]->{$param});
        }
        elsif ($c->req->json && $c->req->json->{$param}) {
            return 1 if &$check_ownership($c, $user, $c->req->json->{$param});
        }
    }
}

=head3 _object_ownership_by_accountlines_id

Finds a Koha::Account::Line-object by C<$accountlines_id> and checks if it
belongs to C<$user>.

=cut

sub _object_ownership_by_accountlines_id {
    my ($c, $user, $accountlines_id) = @_;

    my $accountline = Koha::Account::Lines->find($accountlines_id);
    return $accountline && $user->borrowernumber == $accountline->borrowernumber;
}

=head3 _object_ownership_by_borrowernumber

Compares C<$borrowernumber> to currently logged in C<$user>.

=cut

sub _object_ownership_by_borrowernumber {
    my ($c, $user, $borrowernumber) = @_;

    return $user->borrowernumber == $borrowernumber;
}

=head3 _object_ownership_by_checkout_id

First, attempts to find a Koha::Checkout-object by C<$issue_id>. If we find one,
compare its borrowernumber to currently logged in C<$user>. However, if an issue
is not found, attempt to find a Koha::Old::Checkout-object instead and compare its
borrowernumber to currently logged in C<$user>.

=cut

sub _object_ownership_by_checkout_id {
    my ($c, $user, $issue_id) = @_;

    my $issue = Koha::Checkouts->find($issue_id);
    $issue = Koha::Old::Checkouts->find($issue_id) unless $issue;
    return $issue && $issue->borrowernumber
            && $user->borrowernumber == $issue->borrowernumber;
}

=head3 _object_ownership_by_guarantorid

Compares C<$borrowernumber> to currently logged in C<$user>'s guarantorid.

=cut

sub _object_ownership_by_guarantorid {
    my ($c, $user, $borrowernumber) = @_;

    return $user->guarantorid == $borrowernumber;
}

=head3 _object_ownership_by_message_id

Finds a Koha::Notice::Message-object by C<$message_id> and checks if it
belongs to C<$user>.

=cut

sub _object_ownership_by_message_id {
    my ($c, $user, $message_id) = @_;

    my $message = Koha::Notice::Messages->find($message_id);
    return $message && $user->borrowernumber == $message->borrowernumber;
}

=head3 _object_ownership_by_reserve_id

Finds a Koha::Hold-object by C<$reserve_id> and checks if it
belongs to C<$user>.

TODO: Also compare against old_reserves

=cut

sub _object_ownership_by_reserve_id {
    my ($c, $user, $reserve_id) = @_;

    my $reserve = Koha::Holds->find($reserve_id);
    return $reserve && $user->borrowernumber == $reserve->borrowernumber;
}

=head3 _object_ownership_by_suggestedby

Compares C<$suggetedby> to currently logged in C<$user>'s borrowernumber.

=cut

sub _object_ownership_by_suggestedby {
    my ($c, $user, $suggestedby) = @_;

    return $user->borrowernumber == $suggestedby;
}

=head3 _object_ownership_by_suggestionid

Finds a Koha::Suggestion-object by C<$suggestionid> and checks if it
belongs to C<$user>.

=cut

sub _object_ownership_by_suggestionid {
    my ($c, $user, $suggestionid) = @_;

    my $suggestion = Koha::Suggestions->find($suggestionid);
    return $suggestion && $user->borrowernumber == $suggestion->suggestedby;
}

1;
