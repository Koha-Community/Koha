package Koha::REST::V1::ILL::ISO18626::Requests;

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

use Koha::ILL::ISO18626::Requests;
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::ILL::ISO18626::Requests

=head2 Operations

=head3 list

Controller function that handles listing Koha::ILL::ISO18626::Request objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $reqs = $c->objects->search( Koha::ILL::ISO18626::Requests->new );
        return $c->render(
            status  => 200,
            openapi => $reqs,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a single Koha::ILL::ISO18626::Request object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $iso18626_request =
            $c->objects->find( Koha::ILL::ISO18626::Requests->search, $c->param('iso18626_request_id') );

        return $c->render_resource_not_found("Iso18626 request")
            unless $iso18626_request;

        return $c->render(
            status  => 200,
            openapi => $iso18626_request
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 edit

Controller function that handles editing a single Koha::ILL::ISO18626::Request object

=cut

sub edit {
    my $c = shift or return;

    my $request_id = $c->param('iso18626_request_id');
    my $request    = Koha::ILL::ISO18626::Requests->find($request_id);

    return try {
        my $body   = $c->req->json;
        my $status = $body->{status};

        my $result = $request->progress_request( 'supplyingAgency', $body );
        return $c->render( status => 500, json => { error => "Request could not be progressed" } )
            unless $result;

        return $c->render(
            status  => 200,
            openapi => $request->to_api
        );
    } catch {
        return $c->unhandled_exception($_);
    };
}

1;
