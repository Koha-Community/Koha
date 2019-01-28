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

use C4::Auth qw(checkpw_internal);

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

=head3 set_public

Controller method that sets a patron's password, for unprivileged users

=cut

sub set_public {

    my $c = shift->openapi->valid_input or return;

    my $body      = $c->validation->param('body');
    my $patron_id = $c->validation->param('patron_id');

    unless ( C4::Context->preference('OpacPasswordChange') ) {
        return $c->render(
            status  => 403,
            openapi => { error => "Configuration prevents password changes by unprivileged users" }
        );
    }

    my $user = $c->stash('koha.user');

    unless ( $user->borrowernumber == $patron_id ) {
        return $c->render(
            status  => 403,
            openapi => {
                error => "Changing other patron's password is forbidden"
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
        my $dbh = C4::Context->dbh;
        unless ( checkpw_internal($dbh, $user->userid, $old_password ) ) {
            Koha::Exceptions::Authorization::Unauthorized->throw("Invalid password");
        }

        ## Change password
        $user->set_password({ password => $password });

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
