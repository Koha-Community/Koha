package Koha::App::Plugin::CSRF;

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

Koha::App::Plugin::CSRF

=head1 SYNOPSIS

    $app->plugin('CSRF');

=head1 DESCRIPTION

Enables CSRF protection in a Mojolicious app

=cut

use Modern::Perl;

use Mojo::Base 'Mojolicious::Plugin';

use Mojo::Message::Response;

use Koha::Token;

=head1 METHODS

=head2 register

Called by Mojolicious when the plugin is loaded.

Defines an `around_action` hook that will return a 403 response if CSRF token
is missing or invalid.

This verification occurs only for HTTP methods POST, PUT, DELETE and PATCH.

If CGISESSID cookie is missing, it means that we are not authenticated or we
are authenticated to the API by another method (HTTP basic or OAuth2). In this
case, no verification is done.

=cut

sub register {
    my ( $self, $app, $conf ) = @_;

    $app->hook(
        around_action => sub {
            my ( $next, $c, $action, $last ) = @_;

            my $method = $c->req->method;
            if ( $method eq 'GET' || $method eq 'HEAD' || $method eq 'OPTIONS' || $method eq 'TRACE' ) {
                my $op = $c->req->param('op');
                if ( $op && $op =~ /^cud-/ ) {
                    return $c->reply->exception('Wrong HTTP method')->rendered(400);
                }
            } else {
                if ( $c->cookie('CGISESSID') && !$self->is_csrf_valid( $c->req ) ) {
                    return $c->reply->exception('Wrong CSRF token')->rendered(403);
                }
            }

            return $next->();
        }
    );
}

=head2 is_csrf_valid

Checks if a CSRF token exists and is valid

    $is_valid = $plugin->is_csrf_valid($req)

C<$req> must be a Mojo::Message::Request object

=cut

sub is_csrf_valid {
    my ( $self, $req ) = @_;

    my $csrf_token = $req->param('csrf_token') || $req->headers->header('CSRF-TOKEN');
    my $cookie     = $req->cookie('CGISESSID');
    if ( $csrf_token && $cookie ) {
        my $session_id = $cookie->value;

        return Koha::Token->new->check_csrf( { session_id => $session_id, token => $csrf_token } );
    }

    return 0;
}

1;
