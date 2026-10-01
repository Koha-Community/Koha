package Koha::REST::V1::ILL::ISO18626;

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

use Koha::ILL::ISO18626;
use Koha::ILL::ISO18626::Request;
use Koha::ILL::ISO18626::Requests;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 message

    XSD schema used:
    https://illtransactions.org/schemas/ISO-18626-2021-3.xsd

=cut

sub message {
    my $c    = shift->openapi->valid_input or return;
    my $json = Koha::ILL::ISO18626::message_without_envelope( JSON::decode_json( $c->req->body ) );
    my $body = JSON::encode_json($json);
    my $response;

    return $c->render(
        status  => 403,
        openapi => { error => 'Server unavailable' }
    ) unless C4::Context->preference('ILLModule');

    # 1) Identify the ISO18626 message
    my ($messageType) = keys %$json;
    my $message_types = Koha::ILL::ISO18626::message_types;
    unless ( grep { $_ eq $messageType } @$message_types ) {
        return $c->render( status => 400, text => 'Invalid message type ' . $messageType );
    }

    # 2) Check for validation errors
    my $validation_errors = Koha::ILL::ISO18626::is_invalid( $messageType, $json );
    if ($validation_errors) {
        $response = Koha::ILL::ISO18626::error_response(
            $messageType . 'Confirmation',
            $validation_errors
        );
        $c->res->headers->content_type('application/xml; charset=UTF-8');
        return $c->render( status => 400, data => Koha::ILL::ISO18626::xml_with_envelope($response) );
    }

    # 3) Handle authentication
    my $requesting_agency = Koha::ILL::ISO18626::is_auth_ok( $messageType, $json );
    if ( !$requesting_agency ) {
        $response = Koha::ILL::ISO18626::error_response(
            $messageType . 'Confirmation',
            { errorValue => 'AuthenticationFailed', errorMessage => 'Invalid accountId or securityCode provided.' }
        );
        $c->res->headers->content_type('application/xml; charset=UTF-8');
        return $c->render( status => 400, data => Koha::ILL::ISO18626::xml_with_envelope($response) );
    }

    # 4) Handle confirmation response
    return try {
        Koha::Database->new->schema->txn_do(
            sub {
                my $response = Koha::ILL::ISO18626::confirmation_response( $messageType, $body, $requesting_agency );
                $c->res->headers->content_type('application/xml; charset=UTF-8');
                return $c->render(
                    status => $response->{status},
                    data   => Koha::ILL::ISO18626::xml_with_envelope( $response->{openapi} )
                );
            }
        );
    } catch {
        if ($_) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

1;
