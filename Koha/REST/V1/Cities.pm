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

=head2 Class Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $cities_set = Koha::Cities->new;
        my $cities = $c->objects->search( $cities_set, \&_to_model, \&_to_api );
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

    return $c->render( status => 200, openapi => _to_api($city->TO_JSON) );
}

=head3 add

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $city = Koha::City->new( _to_model( $c->validation->param('body') ) );
        $city->store;
        return $c->render( status => 200, openapi => _to_api($city->TO_JSON) );
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
        my $params = $c->req->json;
        $city->set( _to_model($params) );
        $city->store();
        return $c->render( status => 200, openapi => _to_api($city->TO_JSON) );
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

=head3 _to_api

Helper function that maps a hashref of Koha::City attributes into REST api
attribute names.

=cut

sub _to_api {
    my $city    = shift;

    # Rename attributes
    foreach my $column ( keys %{ $Koha::REST::V1::Cities::to_api_mapping } ) {
        my $mapped_column = $Koha::REST::V1::Cities::to_api_mapping->{$column};
        if (    exists $city->{ $column }
             && defined $mapped_column )
        {
            # key /= undef
            $city->{ $mapped_column } = delete $city->{ $column };
        }
        elsif (    exists $city->{ $column }
                && !defined $mapped_column )
        {
            # key == undef => to be deleted
            delete $city->{ $column };
        }
    }

    return $city;
}

=head3 _to_model

Helper function that maps REST api objects into Koha::Cities
attribute names.

=cut

sub _to_model {
    my $city = shift;

    foreach my $attribute ( keys %{ $Koha::REST::V1::Cities::to_model_mapping } ) {
        my $mapped_attribute = $Koha::REST::V1::Cities::to_model_mapping->{$attribute};
        if (    exists $city->{ $attribute }
             && defined $mapped_attribute )
        {
            # key /= undef
            $city->{ $mapped_attribute } = delete $city->{ $attribute };
        }
        elsif (    exists $city->{ $attribute }
                && !defined $mapped_attribute )
        {
            # key == undef => to be deleted
            delete $city->{ $attribute };
        }
    }

    return $city;
}

=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    cityid       => 'city_id',
    city_country => 'country',
    city_name    => 'name',
    city_state   => 'state',
    city_zipcode => 'postal_code'
};

=head3 $to_model_mapping

=cut

our $to_model_mapping = {
    city_id     => 'cityid',
    country     => 'city_country',
    name        => 'city_name',
    postal_code => 'city_zipcode',
    state       => 'city_state'
};

1;
