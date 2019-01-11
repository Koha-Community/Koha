package Koha::REST::V1::Library;

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
use Koha::Libraries;

use Scalar::Util qw( blessed );

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Library - Koha REST API for handling libraries (V1)

=head1 API

=head2 Methods

=cut

=head3 list

Controller function that handles listing Koha::Library objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $libraries_set = Koha::Libraries->new;
        my $libraries     = $c->objects->search( $libraries_set, \&_to_model, \&_to_api );
        return $c->render( status => 200, openapi => $libraries );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }
        return $c->render(
            status  => 500,
            openapi => { error => "$_" }
        );
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Library

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $library_id = $c->validation->param('library_id');
    my $library = Koha::Libraries->find( $library_id );

    unless ($library) {
        return $c->render( status  => 404,
                           openapi => { error => "Library not found" } );
    }

    return $c->render( status => 200, openapi => _to_api( $library->TO_JSON ) );
}

=head3 add

Controller function that handles adding a new Koha::Library object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $library = Koha::Library->new( _to_model( $c->validation->param('body') ) );
        $library->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $library->branchcode );
        return $c->render( status => 201, openapi => _to_api( $library->TO_JSON ) );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }
        if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
            return $c->render(
                status  => 409,
                openapi => { error => $_->error, conflict => $_->duplicate_id }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "$_" }
            );
        }
    };
}

=head3 update

Controller function that handles updating a Koha::Library object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $library = Koha::Libraries->find( $c->validation->param('library_id') );

    if ( not defined $library ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Library not found" }
        );
    }

    return try {
        my $params = $c->req->json;
        $library->set( _to_model($params) );
        $library->store();
        return $c->render( status => 200, openapi => _to_api($library->TO_JSON) );
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }

        return $c->render(
            status  => 500,
            openapi => { error => "$_" }
        );
    };
}

=head3 delete

Controller function that handles deleting a Koha::Library object

=cut

sub delete {

    my $c = shift->openapi->valid_input or return;

    my $library = Koha::Libraries->find( $c->validation->param( 'library_id' ) );

    if ( not defined $library ) {
        return $c->render( status => 404, openapi => { error => "Library not found" } );
    }

    return try {
        $library->delete;
        return $c->render( status => 204, openapi => '');
    }
    catch {
        unless ( blessed $_ && $_->can('rethrow') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }

        return $c->render(
            status  => 500,
            openapi => { error => "$_" }
        );
    };
}

=head3 _to_api

Helper function that maps a hashref of Koha::Library attributes into REST api
attribute names.

=cut

sub _to_api {
    my $library = shift;

    # Rename attributes
    foreach my $column ( keys %{ $Koha::REST::V1::Library::to_api_mapping } ) {
        my $mapped_column = $Koha::REST::V1::Library::to_api_mapping->{$column};
        if (    exists $library->{ $column }
             && defined $mapped_column )
        {
            # key /= undef
            $library->{ $mapped_column } = delete $library->{ $column };
        }
        elsif (    exists $library->{ $column }
                && !defined $mapped_column )
        {
            # key == undef => to be deleted
            delete $library->{ $column };
        }
    }

    return $library;
}

=head3 _to_model

Helper function that maps REST api objects into Koha::Library
attribute names.

=cut

sub _to_model {
    my $library = shift;

    foreach my $attribute ( keys %{ $Koha::REST::V1::Library::to_model_mapping } ) {
        my $mapped_attribute = $Koha::REST::V1::Library::to_model_mapping->{$attribute};
        if (    exists $library->{ $attribute }
             && defined $mapped_attribute )
        {
            # key /= undef
            $library->{ $mapped_attribute } = delete $library->{ $attribute };
        }
        elsif (    exists $library->{ $attribute }
                && !defined $mapped_attribute )
        {
            # key == undef => to be deleted
            delete $library->{ $attribute };
        }
    }

    if ( exists $library->{pickup_location} ) {
        $library->{pickup_location} = ( $library->{pickup_location} ) ? 1 : 0;
    }

    return $library;
}


=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    branchcode       => 'library_id',
    branchname       => 'name',
    branchaddress1   => 'address1',
    branchaddress2   => 'address2',
    branchaddress3   => 'address3',
    branchzip        => 'postal_code',
    branchcity       => 'city',
    branchstate      => 'state',
    branchcountry    => 'country',
    branchphone      => 'phone',
    branchfax        => 'fax',
    branchemail      => 'email',
    branchreplyto    => 'reply_to_email',
    branchreturnpath => 'return_path_email',
    branchurl        => 'url',
    issuing          => undef,
    branchip         => 'ip',
    branchprinter    => undef,
    branchnotes      => 'notes',
    marcorgcode      => 'marc_org_code',
};

=head3 $to_model_mapping

=cut

our $to_model_mapping = {
    library_id        => 'branchcode',
    name              => 'branchname',
    address1          => 'branchaddress1',
    address2          => 'branchaddress2',
    address3          => 'branchaddress3',
    postal_code       => 'branchzip',
    city              => 'branchcity',
    state             => 'branchstate',
    country           => 'branchcountry',
    phone             => 'branchphone',
    fax               => 'branchfax',
    email             => 'branchemail',
    reply_to_email    => 'branchreplyto',
    return_path_email => 'branchreturnpath',
    url               => 'branchurl',
    ip                => 'branchip',
    notes             => 'branchnotes',
    marc_org_code     => 'marcorgcode',
};

1;
