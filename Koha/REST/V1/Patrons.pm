package Koha::REST::V1::Patrons;

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

use C4::Members qw( AddMember ModMember );
use Koha::Patrons;

use Scalar::Util qw(blessed);
use Try::Tiny;

=head1 NAME

Koha::REST::V1::Patrons

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Patron objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $patrons_set = Koha::Patrons->new;
        my @patrons = $c->objects->search( $patrons_set )->as_list;
        return $c->render( status => 200, openapi => \@patrons );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status => 500,
                openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Patron object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $borrowernumber = $c->validation->param('borrowernumber');
    my $patron = Koha::Patrons->find($borrowernumber);

    unless ($patron) {
        return $c->render(status => 404, openapi => { error => "Patron not found." });
    }

    return $c->render(status => 200, openapi => $patron);
}

=head3 add

Controller function that handles adding a new Koha::Patron object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $body = _to_model($c->validation->param('body'));

        # TODO: Use AddMember until it has been moved to Koha-namespace
        my $borrowernumber = AddMember(%$body);
        my $patron         = Koha::Patrons->find($borrowernumber);

        return $c->render( status => 201, openapi => $patron );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => {
                    error => "Something went wrong, check Koha logs for details."
                }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Given " . $_->broken_fk . " does not exist" }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Given " . $_->parameter . " does not exist" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => {
                    error => "Something went wrong, check Koha logs for details."
                }
            );
        }
    };
}

=head3 update

Controller function that handles updating a Koha::Patron object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $patron_id = $c->validation->param('borrowernumber');
    my $patron    = Koha::Patrons->find( $patron_id );

    unless ($patron) {
         return $c->render(
             status  => 404,
             openapi => { error => "Patron not found" }
         );
     }

    return try {
        my $body = _to_model($c->validation->param('body'));

        ## TODO: Use ModMember until it has been moved to Koha-namespace
        # Add borrowernumber to $body, as required by ModMember
        $body->{borrowernumber} = $patron_id;

        if ( ModMember(%$body) ) {
            # Fetch the updated Koha::Patron object
            $patron->discard_changes;
            return $c->render( status => 200, openapi => $patron );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => {
                    error => 'Something went wrong, check Koha logs for details.'
                }
            );
        }
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => {
                    error => "Something went wrong, check Koha logs for details."
                }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
            return $c->render(
                status  => 400,
                openapi => { error => "Given " . $_->broken_fk . " does not exist" }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::MissingParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Missing mandatory parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => "Invalid parameter(s)",
                    parameters => $_->parameter
                }
            );
        }
        elsif ( $_->isa('Koha::Exceptions::NoChanges') ) {
            return $c->render(
                status  => 204,
                openapi => { error => "No changes have been made" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => {
                    error =>
                      "Something went wrong, check Koha logs for details."
                }
            );
        }
    };
}

=head3 delete

Controller function that handles deleting a Koha::Patron object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $patron;

    return try {
        $patron = Koha::Patrons->find( $c->validation->param('borrowernumber') );

        # check if loans, reservations, debarrment, etc. before deletion!
        my $res = $patron->delete;
        return $c->render( status => 200, openapi => {} );
    }
    catch {
        unless ($patron) {
            return $c->render(
                status  => 404,
                openapi => { error => "Patron not found" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => {
                    error =>
                      "Something went wrong, check Koha logs for details."
                }
            );
        }
    };
}

=head3 _to_model

Helper function that maps REST api objects into Koha::Patron
attribute names.

=cut

sub _to_model {
    my $params = shift;

    $params->{lost} = ($params->{lost}) ? 1 : 0;
    $params->{gonenoaddress} = ($params->{gonenoaddress}) ? 1 : 0;

    return $params;
}

1;
