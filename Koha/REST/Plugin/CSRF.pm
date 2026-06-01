package Koha::REST::Plugin::CSRF;

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

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Token;

=head1 NAME

Koha::REST::Plugin::CSRF - CSRF protection for cookie-authenticated REST API requests

=head1 DESCRIPTION

This plugin enforces CSRF token validation for state-changing requests
(POST, PUT, DELETE, PATCH) when the request is authenticated via a session
cookie (CGISESSID). Requests using OAuth2 or HTTP Basic Auth are not affected.

=head1 API

=head2 Mojolicious::Plugin methods

=head3 register

=cut

sub register {
    my ( $self, $app, $conf ) = @_;

    my %safe_methods = map { $_ => 1 } qw(GET HEAD OPTIONS);

    $app->hook(
        before_dispatch => sub {
            my ($c) = @_;

            # Only check state-changing methods
            return if $safe_methods{ uc( $c->req->method ) };

            # Only enforce for cookie-authenticated requests
            my $session_cookie = $c->req->cookie('CGISESSID');
            return unless $session_cookie;

            my $session_id = $session_cookie->value;
            return unless $session_id;

            # Validate CSRF token from header
            my $csrf_token = $c->req->headers->header('CSRF-TOKEN');

            unless ( $csrf_token
                && Koha::Token->new->check_csrf( { session_id => $session_id, token => $csrf_token } ) )
            {
                $c->render(
                    status => 403,
                    json   => { error => 'Wrong CSRF token' },
                );
                return;
            }
        }
    );
}

1;
