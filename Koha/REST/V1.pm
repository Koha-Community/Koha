package Koha::REST::V1;

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
use Mojo::Base 'Mojolicious';

use C4::Auth qw( check_cookie_auth get_session haspermission );
use C4::Context;
use Koha::Account::Lines;
use Koha::Issues;
use Koha::Holds;
use Koha::OldIssues;
use Koha::Patrons;

sub startup {
    my $self = shift;

    # Force charset=utf8 in Content-Type header for JSON responses
    $self->types->type(json => 'application/json; charset=utf8');

    my $secret_passphrase = C4::Context->config('api_secret_passphrase');
    if ($secret_passphrase) {
        $self->secrets([$secret_passphrase]);
    }

    $self->plugin(Swagger2 => {
        url => $self->home->rel_file("api/v1/swagger/swagger.min.json"),
    });
}

=head3 authenticate_api_request

Validates authentication and allows access if authorization is not required or
if authorization is required and user has required permissions to access.

This subroutine is called before every request to API.

=cut

sub authenticate_api_request {
    my ($next, $c, $action_spec) = @_;

    my ($session, $user);
    my $cookie = $c->cookie('CGISESSID');
    # Mojo doesn't use %ENV the way CGI apps do
    # Manually pass the remote_address to check_auth_cookie
    my $remote_addr = $c->tx->remote_address;
    my ($status, $sessionID) = check_cookie_auth(
                                            $cookie, undef,
                                            { remote_addr => $remote_addr });
    if ($status eq "ok") {
        $session = get_session($sessionID);
        $user = Koha::Patrons->find($session->param('number'));
        $c->stash('koha.user' => $user);
    }
    else {
        return $c->render_swagger(
            { error => "Authentication failure." },
            {},
            401
        ) if $cookie and $action_spec->{'x-koha-authorization'};
    }

    return $next->($c) unless $action_spec->{'x-koha-authorization'};
    unless ($user) {
        return $c->render_swagger({ error => "Authentication required." },{},401);
    }

    my $authorization = $action_spec->{'x-koha-authorization'};
    return $next->($c) if allow_owner($c, $authorization, $user);
    return $next->($c) if allow_guarantor($c, $authorization, $user);

    my $permissions = $authorization->{'permissions'};
    return $next->($c) if C4::Auth::haspermission($user->userid, $permissions);
    return $c->render_swagger(
        { error => "Authorization failure. Missing required permission(s).",
          required_permissions => $permissions },
        {},
        403
    );
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
    foreach my $guarantee (@{$guarantees}) {
        return 1 if check_object_ownership($c, $guarantee);
    }
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
    my ($c, $user) = @_;

    return if not $c or not $user;

    my $parameters = {
        accountlines_id => \&_object_ownership_by_accountlines_id,
        borrowernumber  => \&_object_ownership_by_borrowernumber,
        checkout_id     => \&_object_ownership_by_checkout_id,
        reserve_id      => \&_object_ownership_by_reserve_id,
    };

    foreach my $param (keys $parameters) {
        my $check_ownership = $parameters->{$param};
        if ($c->stash($param)) {
            return &$check_ownership($c, $user, $c->stash($param));
        }
        elsif ($c->param($param)) {
            return &$check_ownership($c, $user, $c->param($param));
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

First, attempts to find a Koha::Issue-object by C<$issue_id>. If we find one,
compare its borrowernumber to currently logged in C<$user>. However, if an issue
is not found, attempt to find a Koha::OldIssue-object instead and compare its
borrowernumber to currently logged in C<$user>.

=cut

sub _object_ownership_by_checkout_id {
    my ($c, $user, $issue_id) = @_;

    my $issue = Koha::Issues->find($issue_id);
    $issue = Koha::OldIssues->find($issue_id) unless $issue;
    return $issue && $issue->borrowernumber
            && $user->borrowernumber == $issue->borrowernumber;
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

1;
