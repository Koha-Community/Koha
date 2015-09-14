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
        ) if $cookie and $action_spec->{'x-koha-permission'};
    }

    if ($action_spec->{'x-koha-permission'}) {
        return $c->render_swagger(
            { error => "Authentication required." },
            {},
            401
        ) unless $user;

        if (C4::Auth::haspermission($user->userid, $action_spec->{'x-koha-permission'})) {
            return $next->($c);
        }
        else {
            return $c->render_swagger(
                { error => "Authorization failure. Missing required permission(s)." },
                {},
                403
            );
        }
    }
    else {
        return $next->($c);
    }
}

1;
