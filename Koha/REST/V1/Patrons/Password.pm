package Koha::REST::V1::Patrons::Password;

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

use C4::Auth qw(checkpw_internal);

use Koha::Patrons;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Patrons::Password

=head1 API

=head2 Methods

=head3 set

Controller method that sets a patron's password, permission driven

=cut

sub set {

    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );
    my $body   = $c->req->json;

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
        if ( blessed $_ and $_->isa('Koha::Exceptions::Password') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "$_" }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 set_public

Controller method that sets a patron's password, for unprivileged users

=cut

sub set_public {

    my $c = shift->openapi->valid_input or return;

    my $body      = $c->req->json;
    my $patron_id = $c->param('patron_id');

    my $user = $c->stash('koha.user');

    unless ( $user->borrowernumber == $patron_id ) {
        return $c->render(
            status  => 403,
            openapi => {
                error => "Changing other patron's password is forbidden"
            }
        );
    }

    unless ( $user->category->effective_change_password ) {
        return $c->render(
            status  => 403,
            openapi => {
                error => "Changing password is forbidden"
            }
        );
    }

    my $old_password = $body->{old_password};
    my $password     = $body->{password};
    my $password_2   = $body->{password_repeated};

    unless ( $password eq $password_2 ) {
        return $c->render( status => 400, openapi => { error => "Passwords don't match" } );
    }

    return try {
        unless ( checkpw_internal($user->userid, $old_password ) ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Invalid password" }
            );
        }

        ## Change password
        $user->set_password({ password => $password });

        return $c->render( status => 200, openapi => "" );
    }
    catch {
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
