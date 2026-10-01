package Koha::ILL::ISO18626;

# Copyright PTFS Europe 2025
#
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

use JSON           qw( encode_json decode_json );
use File::Basename qw( dirname );
use XML::LibXML;

use Koha::ILL::ISO18626::RequestingAgencies;
use Koha::DateUtils qw( dt_from_string );
use Koha::REST::V1;

use constant ISO18626_NAMESPACE => 'http://illtransactions.org/2013/iso18626';
use constant ISO18626_VERSION   => '2021-3';

=head1 NAME

Koha::ILL::ISO18626 - Koha ILL ISO18626 class

=cut

=head2 Class methods

=head3 is_invalid

=cut

sub is_invalid {
    my ( $definition, $json ) = @_;

    my $spec_file = dirname(__FILE__) . "/../../api/v1/swagger/swagger_bundle.json";
    if ( !-f $spec_file ) {
        $spec_file = dirname(__FILE__) . "/../../api/v1/swagger/swagger.yaml";
    }

    my $schema = JSON::Validator::Schema::OpenAPIv2->new($spec_file);

    $schema->resolve( $schema->data->{definitions}->{$definition} );
    my @errors = $schema->validate($json);

    my @formatted_errors;
    for my $error (@errors) {
        my @details        = @{ $error->{details} };
        my $mapped_details = join( ', ', map { "$_" } @details );

        push @formatted_errors,
            { errorValue => $error->{path} . ': ' . $mapped_details, errorType => 'BadlyFormedMessage' };
    }

    return \@formatted_errors if @formatted_errors;
    return 0;
}

=head2 is_auth_ok

    my $is_auth_ok = is_auth_ok($json);

Checks the validity of the requestingAgencyAuthentication against the database.
Returns the Koha::ILL::ISO18626::RequestingAgency object if a matching accountId and securityCode are found, 0 otherwise.

=cut

sub is_auth_ok {
    my ( $messageType, $json ) = @_;

    my $accountId    = $json->{$messageType}->{header}->{requestingAgencyAuthentication}->{accountId};
    my $securityCode = $json->{$messageType}->{header}->{requestingAgencyAuthentication}->{securityCode};

    my $requesting_agency =
        Koha::ILL::ISO18626::RequestingAgencies->find( { account_id => $accountId, securityCode => $securityCode } );

    return $requesting_agency if $requesting_agency;
    return 0;
}

=head3 confirmation_response

This function returns an openapi ISO18626 message confirmation response based on the ISO18626 messages's type and body.
e.g. If the message_type is request, it returns a requestConfirmation message

It does not verify if:
  - The message type is valid.
  - The message is valid.
These things should be done beforehand

=cut

sub confirmation_response {
    my ( $message_type, $body, $requesting_agency ) = @_;

    my $json                      = JSON::decode_json($body);
    my $confirmation_message_type = $message_type . 'Confirmation';
    my ( $iso18626_request, $response, $action );

    if ( $message_type eq 'request' ) {
        #
        # Handle incoming request message
        #
        my $request = {
            supplyingAgencyId             => $json->{request}->{header}->{supplyingAgencyId},
            iso18626_requesting_agency_id => $requesting_agency->iso18626_requesting_agency_id,
            requestingAgencyRequestId     => $json->{request}->{header}->{requestingAgencyRequestId},
            service_type                  => $json->{request}->{serviceInfo}->{serviceType},
            _json_payload                 => $json
        };

        $iso18626_request = Koha::ILL::ISO18626::Request->new($request)->store();
        $iso18626_request->add_message( { type => $message_type, message => $body } );

        #
        # Prepare outgoing requestConfirmation response
        #
        $response = {
            $confirmation_message_type => {
                confirmationHeader => {
                    timestamp         => _now_utc_str(),
                    timestampReceived => _now_utc_str(),
                    messageStatus     => 'OK',
                }
            }
        };
    } elsif ( $message_type eq 'requestingAgencyMessage' ) {
        #
        # Handle incoming requestingAgencyMessage message
        #
        my $supplyingAgencyRequestId =
            $json->{requestingAgencyMessage}->{header}->{supplyingAgencyRequestId};
        $iso18626_request = Koha::ILL::ISO18626::Requests->find($supplyingAgencyRequestId);

        return {
            status  => 400,
            openapi => error_response(
                $confirmation_message_type,
                [
                    {
                        errorValue => "supplyingAgencyRequestId: " . $supplyingAgencyRequestId,
                        errorType  => "UnrecognizedDataValue"
                    }
                ]
            )
        } unless $iso18626_request;
        $action = $json->{$message_type}->{action};
        my $requestingAgencyMessage = $iso18626_request->add_message( { type => $message_type, message => $body } );

        # Verify if the provided action is supported
        my $supported_action_types = supported_action_types($iso18626_request);
        return {
            status  => 400,
            openapi => error_response(
                $confirmation_message_type,
                [
                    {
                        errorValue => "action: " . $json->{$message_type}->{action},
                        errorType  => "UnsupportedActionType"
                    }
                ]
            )
            }
            unless ( grep { $_ eq $json->{$message_type}->{action} } @$supported_action_types );

        #
        # Do the things that need to be done depending on the action
        #

        if ( $action eq 'Cancel' || $action eq 'Renew' ) {
            $iso18626_request->pending_requesting_agency_action($action)->store();
        }

        # TODO: Only send out supplyingAgencyMessage if $action == statusRequest (?)
        #$iso18626_request->progress_request( 'requestingAgency', { message => $requestingAgencyMessage } ); #TODO: Rethink this but good enough for now

        #
        # Prepare outgoing requestingAgencyMessageConfirmation response
        #
        $response = {
            $confirmation_message_type => {
                confirmationHeader => {
                    timestamp         => _now_utc_str(),
                    timestampReceived => _now_utc_str(),
                    messageStatus     => 'OK',
                },
                action => $json->{$message_type}->{action},
            }
        };
    }

    #TODO: Handle supplyingAgencyMessage ?
    # IF a supplyingAgencyMessage is received, it means this Koha is acting as a requesting agency and we need to handle Koha::ILL::Request instead of Koha::ILL::ISO18626::Request (?)

    # Ensure the produced confirmation message is ISO18626 conformant
    my $validation_errors = is_invalid( $confirmation_message_type, $response );
    if ($validation_errors) {
        return {
            status  => 400,
            openapi => error_response(
                $confirmation_message_type,
                $validation_errors
            )
        };
    }

    # All good, save the message and return the response
    $iso18626_request->add_message(
        {
            type      => $confirmation_message_type,
            message   => JSON::encode_json($response),
            timestamp => \"NOW() + INTERVAL 1 SECOND",
        }
    );
    return { status => 201, openapi => $response };

}

=head3 _now_utc_str

=cut

sub _now_utc_str {
    return dt_from_string( undef, undef, 'UTC' )->strftime('%Y-%m-%dT%H:%M:%SZ');
}

=head3 error_response

=cut

sub error_response {
    my ( $message_type, $error_data ) = @_;

    return {
        $message_type => {
            confirmationHeader => {
                timestamp         => _now_utc_str(),
                timestampReceived => _now_utc_str(),
                messageStatus     => 'ERROR',
            },
            errorData => $error_data,
        }
    };
}

=head3 message_types

=cut

sub message_types {
    return [
        'request',
        'requestConfirmation',
        'requestingAgencyMessage',
        'requestingAgencyMessageConfirmation',
        'supplyingAgencyMessage',
        'supplyingAgencyMessageConfirmation'
    ];
}

=head3 xml_with_envelope

    my $xml = Koha::ILL::ISO18626::xml_with_envelope($message);

C<$message> is an ISO 18626 message, e.g. C<< { request => { ... } } >>.
Returns it as an XML string wrapped in the C<ISO18626Message> envelope.

=cut

sub xml_with_envelope {
    my ($message) = @_;

    my $doc     = XML::LibXML->load_xml( string => Koha::REST::V1::to_xml($message) );
    my $content = $doc->documentElement;

    my $envelope = $doc->createElementNS( ISO18626_NAMESPACE, 'ISO18626Message' );
    $envelope->setAttributeNS( ISO18626_NAMESPACE, 'ill:version', ISO18626_VERSION );
    $doc->setDocumentElement($envelope);
    $envelope->appendChild($content);

    return $doc->toString;
}

=head3 message_without_envelope

    my $message = Koha::ILL::ISO18626::message_without_envelope( $parsed_xml );

Returns the message contained in an C<ISO18626Message> envelope, from the structure
returned by C<Koha::REST::V1::parse_xml>. For backwards compatibility with Koha versions
that did not use the envelope, an unwrapped message is returned as it is.

=cut

sub message_without_envelope {
    my ($parsed_xml) = @_;

    my $message;
    if ( exists $parsed_xml->{ISO18626Message} ) {
        $message = $parsed_xml->{ISO18626Message};
    } else {

        # Backwards compatibility: message sent without the ISO18626Message envelope
        $message = $parsed_xml;
    }

    return $message;
}

=head3 supported_action_types

    Returns an array of supported action types for a given ISO18626 request.
    Returns an empty array if the request has already been completed.

=cut

sub supported_action_types {
    my ($iso18626_request) = @_;

    return []
        if $iso18626_request->status =~ /^(?:Cancelled|CopyCompleted|CompletedWithoutReturn|LoanCompleted|Unfilled)$/;

    return [
        'StatusRequest',
        'Received',
        'Cancel',
        'ShippedReturn',

        # TODO: Uncomment these once implemented
        #'Renew',
        #'HoldReturn',
        #'ShippedForward',
        #'Notification',
        #'Lost',
    ];
}

1;
