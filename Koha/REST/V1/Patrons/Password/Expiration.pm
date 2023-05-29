package Koha::REST::V1::Patrons::Password::Expiration;

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

use Koha::Patrons;
use Koha::DateUtils qw(dt_from_string);

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Patrons::Password::Expiration

=head1 API

=head2 Methods

=head3 set

Controller method that sets a patron's password expiration

=cut

sub set {

    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ($patron) {
        return $c->render( status => 404, openapi => { error => "Patron not found." } );
    }

    my $body = $c->req->json;

    my $password_expiration_date   = $body->{expiration_date} // "";

    return try {
        my $pw_expiration_dt = dt_from_string($password_expiration_date);
        $patron->password_expiration_date( $pw_expiration_dt)->store();
        return $c->render( status => 200, openapi => "" );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
