package Koha::REST::V1::Preservation::Processings;

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

use Koha::Preservation::Processings;

use Scalar::Util qw( blessed );
use Try::Tiny;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $processings_set = Koha::Preservation::Processings->new;
        my $processings     = $c->objects->search($processings_set);
        return $c->render( status => 200, openapi => $processings );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::Preservation::Processing object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $processing_id = $c->param('processing_id');
        my $processing    = $c->objects->find( Koha::Preservation::Processings->search, $processing_id );

        return $c->render_resource_not_found("Processing")
            unless $processing;

        return $c->render(
            status  => 200,
            openapi => $processing
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::Preservation::Processing object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $attributes = delete $body->{attributes} // [];

                my $processing = Koha::Preservation::Processing->new_from_api($body)->store;
                $processing->attributes($attributes);

                $c->res->headers->location( $c->req->url->to_string . '/' . $processing->processing_id );
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($processing),
                );
            }
        );
    } catch {

        my $to_api_mapping = Koha::Preservation::Processing->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            } elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::Preservation::Processing object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $processing_id = $c->param('processing_id');
    my $processing    = Koha::Preservation::Processings->find($processing_id);

    return $c->render_resource_not_found("Processing")
        unless $processing;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $attributes = delete $body->{attributes} // [];

                $processing->set_from_api($body)->store;
                $processing->attributes($attributes);

                $c->res->headers->location( $c->req->url->to_string . '/' . $processing->processing_id );
                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($processing),
                );
            }
        );
    } catch {
        my $to_api_mapping = Koha::Preservation::Processing->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->broken_fk } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Given " . $to_api_mapping->{ $_->parameter } . " does not exist" }
                );
            } elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $processing_id = $c->param('processing_id');
    my $processing    = Koha::Preservation::Processings->find($processing_id);

    return $c->render_resource_not_found("Processing")
        unless $processing;

    unless ( $processing->can_be_deleted ) {
        return $c->render(
            status  => 409,
            openapi => { error => "Processing is already used" },
        );
    }
    return try {
        $processing->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
