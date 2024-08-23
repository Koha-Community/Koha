package Koha::REST::Plugin::Auth::IdP;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Plugin';

use Koha::Exceptions;
use Koha::Exceptions::Auth;
use Koha::Patrons;

use C4::Auth qw(create_basic_session);

use CGI;
use List::MoreUtils qw(any);

=head1 NAME

Koha::REST::Plugin::Auth::IdP

=head1 API

=head2 Helper methods

=cut

=head2 register

Missing POD for register.

=cut

sub register {
    my ( $self, $app ) = @_;

=head3 auth.register

    my $patron = $c->auth->register(
        {
            data      => $patron_data,
            domain    => $domain,
            interface => $interface
        }
    );

This helper creates a new I<Koha::Patron> using the (already) mapped data
provided in the I<data> attribute.

A check is done on the passed I<interface> and I<domain> to validate
the provider is configured to allow auto registration.

Valid values for B<interface> are I<opac> and I<staff>. An exception will be thrown
if other values or none are passed.

=cut

    $app->helper(
        'auth.register' => sub {
            my ( $c, $params ) = @_;
            my $data      = $params->{data};
            my $domain    = $params->{domain};
            my $interface = $params->{interface};

            Koha::Exceptions::MissingParameter->throw( parameter => 'interface' )
                unless $interface;

            Koha::Exceptions::BadParameter->throw( parameter => 'interface' )
                unless any { $interface eq $_ } qw{ opac staff };

            if (   $interface eq 'opac' && !$domain->auto_register_opac
                || $interface eq 'staff' && !$domain->auto_register_staff )
            {
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
            my ( $c, $params ) = @_;
            my $patron    = $params->{patron};
            my $interface = $params->{interface};
            my $provider  = $params->{provider};

            my $session = C4::Auth::create_basic_session( { patron => $patron, interface => $interface } );
            $session->param( 'idp_code', $provider );

            return $session->id;
        }
    );
}

1;
