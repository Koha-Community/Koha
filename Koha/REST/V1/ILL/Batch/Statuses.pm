package Koha::REST::V1::ILL::Batch::Statuses;

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

use Koha::ILL::Batch::Statuses;

=head1 NAME

Koha::REST::V1::ILL::Batch::Statuses

=head2 Operations

=head3 list

Return a list of available ILL batch statuses

=cut

sub list {
    my $c = shift->openapi->valid_input;

    my @statuses = Koha::ILL::Batch::Statuses->search()->as_list;

    return $c->render( status => 200, openapi => \@statuses );
}

=head3 get

Get one batch statuses

=cut

sub get {
    my $c = shift->openapi->valid_input;

    my $status_code = $c->param('ill_batchstatus_code');

    my $status = Koha::ILL::Batch::Statuses->find( { code => $status_code } );

    return $c->render_resource_not_found("ILL batch status")
        unless $status;

    return $c->render(
        status  => 200,
        openapi => { %{ $status->unblessed } }
    );
}

=head3 add

Add a new batch status

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;

    my $status = Koha::ILL::Batch::Status->new($body);

    return try {
        my $return = $status->create_and_log;
        if ( $return && $return->{error} ) {
            return $c->render(
                status  => 500,
                openapi => $return
            );
        } else {
            $c->res->headers->location( $c->req->url->to_string . '/' . $status->code );
            return $c->render(
                status  => 201,
                openapi => $status
            );
        }
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

Update a batch status

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $status = Koha::ILL::Batch::Statuses->find( { code => $c->param('ill_batchstatus_code') } );

    return $c->render_resource_not_found("ILL batch status")
        unless $status;

    my $params = $c->req->json;

    return try {

        # Only permit updating of name
        $status->update_and_log( { name => $params->{name} } );

        return $c->render(
            status  => 200,
            openapi => $status
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Delete a batch status

=cut

sub delete {

    my $c = shift->openapi->valid_input or return;

    my $status = Koha::ILL::Batch::Statuses->find( { code => $c->param('ill_batchstatus_code') } );

    return $c->render_resource_not_found("ILL batch status")
        unless $status;

    if ( $status->is_system ) {
        return $c->render(
            status  => 400,
            openapi => { errors => [ { message => "ILL batch status cannot be deleted" } ] }
        );
    }

    return try {
        $status->delete_and_log;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
