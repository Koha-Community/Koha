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

use C4::Auth qw( check_cookie_auth get_session );
use C4::Context;
use Koha::Patrons;

sub startup {
    my $self = shift;

    my $route = $self->routes->under->to(
        cb => sub {
            my $c = shift;
            # Mojo doesn't use %ENV the way CGI apps do
            # Manually pass the remote_address to check_auth_cookie
            my $remote_addr = $c->tx->remote_address;
            my ($status, $sessionID) = check_cookie_auth(
                                            $c->cookie('CGISESSID'), undef,
                                            { remote_addr => $remote_addr });

            if ($status eq "ok") {
                my $session = get_session($sessionID);
                my $user = Koha::Patrons->find($session->param('number'));
                $c->stash('koha.user' => $user);
            }

            return 1;
        }
    );

    # Force charset=utf8 in Content-Type header for JSON responses
    $self->types->type(json => 'application/json; charset=utf8');

    my $secret_passphrase = C4::Context->config('api_secret_passphrase');
    if ($secret_passphrase) {
        $self->secrets([$secret_passphrase]);
    }

    $self->plugin(Swagger2 => {
        route => $route,
        url => $self->home->rel_file("api/v1/swagger.json"),
    });
}

1;
