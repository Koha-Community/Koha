package Koha::REST::V1::Cities;

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

use Koha::Cities;

use Try::Tiny;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $cities_set = Koha::Cities->new;
        my $cities = $c->objects->search( $cities_set );
        return $c->render( status => 200, openapi => $cities );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };

}

=head3 get

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $city = Koha::Cities->find( $c->validation->param('city_id') );
    unless ($city) {
        return $c->render( status  => 404,
                           openapi => { error => "City not found" } );
    }

    return $c->render( status => 200, openapi => $city->to_api );
}

=head3 add

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $city = Koha::City->new_from_api( $c->validation->param('body') );
        $city->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $city->cityid );
        return $c->render(
            status  => 201,
            openapi => $city->to_api
        );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render(
                status  => 500,
                openapi => { error => $_->{msg} }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check the logs." }
            );
        }
    };
}

=head3 update

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $city = Koha::Cities->find( $c->validation->param('city_id') );

    if ( not defined $city ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    return try {
        $city->set_from_api( $c->validation->param('body') );
        $city->store();
        return $c->render( status => 200, openapi => $city->to_api );
    }
    catch {
        if ( $_->isa('Koha::Exceptions::Object') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->message } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $city = Koha::Cities->find( $c->validation->param('city_id') );
    if ( not defined $city ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    return try {
        $city->delete;
        return $c->render( status => 200, openapi => "" );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->{msg} } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };
}

1;
