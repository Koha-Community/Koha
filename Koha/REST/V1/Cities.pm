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

use Koha::City;
use Koha::Cities;

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $cities;
    my $filter;
    my $args = $c->req->params->to_hash;

    for my $filter_param ( keys %$args ) {
        $filter->{$filter_param} = { LIKE => $args->{$filter_param} . "%" };
    }

    return try {
        $cities = Koha::Cities->search($filter);
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

sub get {
    my $c = shift->openapi->valid_input or return;

    my $city = Koha::Cities->find( $c->validation->param('cityid') );
    unless ($city) {
        return $c->render( status  => 404,
                           openapi => { error => "City not found" } );
    }

    return $c->render( status => 200, openapi => $city );
}

sub add {
    my $c = shift->openapi->valid_input or return;

    my $city = Koha::City->new( $c->validation->param('body') );

    return try {
        $city->store;
        return $c->render( status => 200, openapi => $city );
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

sub update {
    my $c = shift->openapi->valid_input or return;

    my $city;

    return try {
        $city = Koha::Cities->find( $c->validation->param('cityid') );
        my $params = $c->req->json;
        $city->set( $params );
        $city->store();
        return $c->render( status => 200, openapi => $city );
    }
    catch {
        if ( not defined $city ) {
            return $c->render( status  => 404,
                               openapi => { error => "Object not found" } );
        }
        elsif ( $_->isa('Koha::Exceptions::Object') ) {
            return $c->render( status  => 500,
                               openapi => { error => $_->message } );
        }
        else {
            return $c->render( status => 500,
                openapi => { error => "Something went wrong, check the logs."} );
        }
    };

}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $city;

    return try {
        $city = Koha::Cities->find( $c->validation->param('cityid') );
        $city->delete;
        return $c->render( status => 200, openapi => "" );
    }
    catch {
        if ( not defined $city ) {
            return $c->render( status  => 404,
                               openapi => { error => "Object not found" } );
        }
        elsif ( $_->isa('DBIx::Class::Exception') ) {
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
