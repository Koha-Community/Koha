package Koha::REST::V1::Patrons::Password;

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

use Koha::Patrons;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Patrons::Password

=head1 API

=head2 Methods

=head3 set

Controller method that sets a patron's password, permission driven

=cut

sub set {

    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->validation->param('patron_id') );
    my $body   = $c->validation->param('body');

    unless ($patron) {
        return $c->render( status => 404, openapi => { error => "Patron not found." } );
    }

    my $password   = $body->{password}   // "";
    my $password_2 = $body->{password_2} // "";

    unless ( $password eq $password_2 ) {
        return $c->render( status => 400, openapi => { error => "Passwords don't match" } );
    }

    return try {

        ## Change password
        $patron->set_password({ password => $password });

        return $c->render( status => 200, openapi => "" );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render( status => 500, openapi => { error => "$_" } );
        }

        # an exception was raised. return 400 with the stringified exception
        return $c->render( status => 400, openapi => { error => "$_" } );
    };
}

1;
