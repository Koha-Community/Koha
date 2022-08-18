package Koha::REST::Plugin::Auth;

# Copyright Theke Solutions 2022
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

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Exceptions;
use Koha::Exceptions::Auth;
use Koha::Patron;

use C4::Auth;

use CGI;

=head1 NAME

Koha::REST::Plugin::Auth

=head1 API

=head2 Helper methods

=cut

sub register {
    my ( $self, $app ) = @_;

=head3 auth.register

    my $patron = $c->auth->register(
        {   data      => $patron_data,
            domain    => $domain,
            interface => $interface
        }
    );

If no patron passed, creates a new I<Koha::Patron> if the provider is configured
to do so for the domain.

=cut

    $app->helper(
        'auth.register' => sub {
            my ( $c, $params ) = @_;
            my $data = $params->{data};
            my $domain = $params->{domain};
            my $interface = $params->{interface};

            unless ( $interface eq 'opac' && $domain->auto_register ) {
                Koha::Exceptions::Auth::Unauthorized->throw( code => 401 );
            }

            return Koha::Patron->new($data)->store;
        }
    );

=head3 auth.session

    my ( $status, $cookie, $session_id ) = $c->auth->session( $patron );

Generates a new session.

=cut

    $app->helper(
        'auth.session' => sub {
            my ( $c, $patron ) = @_;
            my $userid     = $patron->userid;
            my $cardnumber = $patron->cardnumber;
            my $cgi        = CGI->new;

            $cgi->param( userid            => $userid );
            $cgi->param( cardnumber        => $cardnumber );
            $cgi->param( auth_client_login => 1 );

            my ( $status, $cookie, $session_id ) = C4::Auth::check_api_auth($cgi);

            Koha::Exceptions::UnderMaintenance->throw( code => 503 )
              if $status eq "maintenance";

            Koha::Exceptions::Auth::CannotCreateSession->throw( code => 500 )
              unless $status eq "ok";

            return ( $status, $cookie, $session_id );
        }
    );
}

1;
