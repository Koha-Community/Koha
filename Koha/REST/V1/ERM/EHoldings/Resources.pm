package Koha::REST::V1::ERM::EHoldings::Resources;

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

use Koha::ERM::EHoldings::Resources;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $resources_set = Koha::ERM::EHoldings::Resources->new;
        my $resources = $c->objects->search( $resources_set );
        return $c->render( status => 200, openapi => $resources );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EHoldings::Resource object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $resource_id = $c->validation->param('resource_id');
        my $resource = $c->objects->find( Koha::ERM::EHoldings::Resources->search, $resource_id );

        unless ($resource ) {
            return $c->render(
                status  => 404,
                openapi => { error => "eHolding title not found" }
            );
        }

        return $c->render(
            status  => 200,
            openapi => $resource,
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::ERM::EHoldings::Resource object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                my $resource = Koha::ERM::EHoldings::Resource->new_from_api($body)->store;

                $c->res->headers->location($c->req->url->to_string . '/' . $resource->resource_id);
                return $c->render(
                    status  => 201,
                    openapi => $resource->to_api
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::ERM::EHoldings::Resource->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::ERM::EHoldings::Resource object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $resource_id = $c->validation->param('resource_id');
    my $resource = Koha::ERM::EHoldings::Resources->find( $resource_id );

    unless ($resource) {
        return $c->render(
            status  => 404,
            openapi => { error => "eHolding title not found" }
        );
    }

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->validation->param('body');

                $resource->set_from_api($body)->store;

                $c->res->headers->location($c->req->url->to_string . '/' . $resource->resource_id);
                return $c->render(
                    status  => 200,
                    openapi => $resource->to_api
                );
            }
        );
    }
    catch {
        my $to_api_mapping = Koha::ERM::EHoldings::Resource->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
        }

        $c->unhandled_exception($_);
    };
};

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $resource = Koha::ERM::EHoldings::Resources->find( $c->validation->param('resource_id') );
    unless ($resource) {
        return $c->render(
            status  => 404,
            openapi => { error => "eHolding title not found" }
        );
    }

    return try {
        $resource->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
