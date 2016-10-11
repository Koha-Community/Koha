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

use C4::Auth qw( haspermission );
use Koha::City;
use Koha::Cities;

use Try::Tiny;

sub list {
    my ( $c, $args, $cb ) = @_;

    my $cities;

    return try {
        $cities =
          Koha::Cities->search( $c->req->query_params->to_hash )->unblessed;
        return $c->$cb( $cities, 200 );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->$cb( { error => $_->{msg} }, 500 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs." }, 500 );
        }
    };
}

sub get {
    my ( $c, $args, $cb ) = @_;

    my $city = Koha::Cities->find( $args->{cityid} );
    unless ($city) {
        return $c->$cb( { error => "City not found" }, 404 );
    }

    return $c->$cb( $city->unblessed, 200 );
}

sub add {
    my ( $c, $args, $cb ) = @_;

    my $city = Koha::City->new( $c->req->json );

    return try {
        $city->store;
        return $c->$cb( $city->unblessed, 200 );
    }
    catch {
        if ( $_->isa('DBIx::Class::Exception') ) {
            return $c->$cb( { error => $_->msg }, 500 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs." }, 500 );
        }
    };
}

sub update {
    my ( $c, $args, $cb ) = @_;

    my $city;

    return try {
        $city = Koha::Cities->find( $args->{cityid} );
        while ( my ( $k, $v ) = each %{ $c->req->json } ) {
            $city->$k($v);
        }
        $city->store;
        return $c->$cb( $city->unblessed, 200 );
    }
    catch {
        if ( not defined $city ) {
            return $c->$cb( { error => "Object not found" }, 404 );
        }
        elsif ( $_->isa('Koha::Exceptions::Object') ) {
            return $c->$cb( { error => $_->message }, 500 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs." }, 500 );
        }
    };

}

sub delete {
    my ( $c, $args, $cb ) = @_;

    my $city;

    return try {
        $city = Koha::Cities->find( $args->{cityid} );
        $city->delete;
        return $c->$cb( "", 200 );
    }
    catch {
        if ( not defined $city ) {
            return $c->$cb( { error => "Object not found" }, 404 );
        }
        elsif ( $_->isa('DBIx::Class::Exception') ) {
            return $c->$cb( { error => $_->msg }, 500 );
        }
        else {
            return $c->$cb(
                { error => "Something went wrong, check the logs." }, 500 );
        }
    };

}

1;
