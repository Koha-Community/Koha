package Koha::REST::V1::ILL::Batches;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::ILL::Batches;
use Koha::ILL::Batch::Statuses;
use Koha::ILL::Requests;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::ILL::Batches

=head2 Operations

=head3 list

Return a list of available ILL batches

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        return $c->render(
            status  => 200,
            openapi => $c->objects->search( Koha::ILL::Batches->new )
        );
    } catch {
        warn "$_";
        $c->unhandled_exception($_);
    };
}

=head3 get

Get one batch

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $ill_batch = $c->objects->find( Koha::ILL::Batches->new, $c->param('ill_batch_id') );

        return $c->render_resource_not_found("ILL batch")
            unless $ill_batch;

        return $c->render(
            status  => 200,
            openapi => $ill_batch
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Add a new batch

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;

    my $patron = Koha::Patrons->find( { cardnumber => $body->{cardnumber} } );

    return $c->render_resource_not_found("Patron")
        unless $patron;

    delete $body->{cardnumber};
    $body->{patron_id} = $patron->id;

    return try {
        my $batch = Koha::ILL::Batch->new_from_api($body);
        $batch->create_and_log;

        $c->res->headers->location( $c->req->url->to_string . '/' . $batch->id );

        my $ill_batch = $c->objects->find( Koha::ILL::Batches->new, $batch->id );

        return $c->render(
            status  => 201,
            openapi => $ill_batch
        );
    } catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => "A batch named " . $body->{name} . " already exists" }
                );
            }
        }
        $c->unhandled_exception($_);
    };
}

=head3 update

Update a batch

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $batch = Koha::ILL::Batches->find( $c->param('ill_batch_id') );

    return $c->render_resource_not_found("ILL batch")
        unless $batch;

    my $params = $c->req->json;
    delete $params->{cardnumber};

    return try {
        $batch->update_and_log($params);

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($batch),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Delete a batch

=cut

sub delete {

    my $c = shift->openapi->valid_input or return;

    my $batch = Koha::ILL::Batches->find( $c->param('ill_batch_id') );

    return $c->render_resource_not_found("ILL batch")
        unless $batch;

    return try {
        $batch->delete_and_log;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
