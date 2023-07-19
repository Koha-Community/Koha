package Koha::REST::V1::Auth::Password;

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

use C4::Auth qw/checkpw/;
use Koha::Patrons;

=head1 NAME

Koha::REST::V1::Auth::Password - Controller library for handling
validation of username and password.

Intended use case is authenticating Koha patrons in external
applications via Koha's REST API.

=head2 Operations

=head3 validate

Controller method that checks a patron's password

=cut

sub validate {
    my $c = shift->openapi->valid_input or return;

    my $body       = $c->req->json;
    my $identifier = $body->{identifier};
    my $userid     = $body->{userid};

    unless ( defined $identifier or defined $userid ) {
        return $c->render(
            status  => 400,
            openapi => { error => "Validation failed" },
        );
    }

    if ( defined $identifier and defined $userid ) {
        return $c->render(
            status  => 400,
            openapi => { error => "Bad request. Only one identifier attribute can be passed." },
        );
    }

    if ($userid) {
        return $c->render(
            status  => 400,
            openapi => { error => "Validation failed" },
        ) unless Koha::Patrons->find( { userid => $userid } );
    }

    $identifier //= $userid;

    my $password = $body->{password} // "";

    return try {
        my ( $status, $THE_cardnumber, $THE_userid ) = C4::Auth::checkpw( $identifier, $password );
        unless ($status) {
            return $c->render(
                status  => 400,
                openapi => { error => "Validation failed" }
            );
        }

        my $patron = Koha::Patrons->find( { cardnumber => $THE_cardnumber } );

        return $c->render(
            status  => 201,
            openapi => {
                cardnumber => $patron->cardnumber,
                patron_id  => $patron->id,
                userid     => $patron->userid,
            }
        );
    } catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Password') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "$_" }
            );
        }

        $c->unhandled_exception($_);
    };
}

1;
