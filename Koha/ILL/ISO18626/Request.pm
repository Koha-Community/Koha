package Koha::ILL::ISO18626::Request;

# Copyright Open Fifth 2026
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

use Koha::ILL::ISO18626::Messages;
use Koha::REST::V1;
use XML::LibXML;
use JSON           qw( encode_json decode_json );
use File::Basename qw( dirname );
use LWP::UserAgent;

use Koha::Biblios;
use Koha::ILL::ISO18626::RequestingAgency;
use Koha::DateUtils qw( dt_from_string );

use base qw(Koha::Object);

=head1 NAME

Koha::ILL::ISO18626::Request - Koha ILL ISO18626 request Object class

=cut

=head2 Internal methods

=head3 new

Intercept the 'new' I<Koha::Object> lifecycle method
If a supplierUniqueRecordId exists in the request payload, the
corresponding bib record is linked to this request on creation

=cut

sub new {
    my ( $class, $params ) = @_;

    my $json = delete $params->{_json_payload};
    if ( $json && $json->{request}->{bibliographicInfo}->{supplierUniqueRecordId} ) {
        my $supplierUniqueRecordId = $json->{request}->{bibliographicInfo}->{supplierUniqueRecordId};

        my $biblio = Koha::Biblios->find($supplierUniqueRecordId);
        $params->{biblio_id} = $biblio->biblionumber if $biblio;
    }

    my $self = $class->SUPER::new($params);
    return $self;
}

=head3 add_message

Add the I<Koha::ILL::ISO18626::Message> to this ISO18626 request

=cut

sub add_message {
    my ( $self, $params ) = @_;

    my $type    = $params->{type};
    my $message = $params->{message};

    if ( ref $message eq 'HASH' ) {
        $message = encode_json($message);
    }

    my %row = ( type => $type, content => $message );
    $row{timestamp} = $params->{timestamp} if $params->{timestamp};

    return $self->_result->add_to_iso18626_messages( \%row );
}

=head3 messages

Return the I<Koha::ILL::ISO18626::Messages> for this ISO18626 request

=cut

sub messages {
    my ($self) = @_;
    my $messages = $self->_result->iso18626_messages->search(
        {},
        { order_by => { -desc => 'timestamp' } }
    );
    return Koha::ILL::ISO18626::Messages->_new_from_dbic($messages);
}

=head3 send_message

Send an ISO18626 message payload to the requesting agency's callback endpoint.
Expects C<$message> as a Perl hashref, which is converted to XML before sending.

=cut

sub send_message {
    my ( $self, $type, $message ) = @_;

    $self->add_message( { type => $type, message => $message } );

    my $requesting_agency = $self->requesting_agency;
    if ( !$requesting_agency ) {
        warn sprintf(
            "ISO18626: Cannot send message. No requesting agency linked to request %s",
            $self->iso18626_request_id
        );
        return 0;
    }

    if ( !$requesting_agency->callback_endpoint ) {
        warn sprintf(
            "ISO18626: Cannot send message. Requesting agency %s has no callback_endpoint defined.",
            $requesting_agency->id
        );
        return 0;
    }

    my $xml_payload;
    eval { $xml_payload = Koha::REST::V1::to_xml($message); };
    if ($@) {
        warn sprintf( "ISO18626: Failed to convert message to XML for request %s: %s", $self->iso18626_request_id, $@ );
        return 0;
    }

    my $ua = LWP::UserAgent->new(
        agent   => 'Koha ' . $Koha::VERSION,
        timeout => 10,
    );

    my $response = $ua->post(
        $requesting_agency->callback_endpoint,
        'Content-Type' => 'application/xml',
        Content        => $xml_payload,
    );

    if ( $response->is_success ) {
        my $content = $response->decoded_content;

        if ($content) {
            my $parser = XML::LibXML->new();
            my $doc;
            eval { $doc = $parser->parse_string($content); };

            if ( $@ || !$doc ) {
                warn sprintf(
                    "ISO18626: Could not parse XML confirmation from %s for request %s. Error: %s",
                    $requesting_agency->callback_endpoint,
                    $self->iso18626_request_id,
                    $@
                );
            } else {
                my $root = $doc->documentElement();
                my $parsed_json;
                eval {
                    my $spec_file = dirname(__FILE__) . "/../../../api/v1/swagger/swagger_bundle.json";
                    if ( !-f $spec_file ) {
                        $spec_file = dirname(__FILE__) . "/../../../api/v1/swagger/swagger.yaml";
                    }
                    $parsed_json = Koha::REST::V1::parse_xml( $root, $spec_file );
                };

                if ($@) {
                    warn sprintf(
                        "ISO18626: Failed to convert XML to JSON for confirmation on request %s. Error: %s",
                        $self->iso18626_request_id,
                        $@
                    );
                } else {
                    my $confirmation_type = $type . 'Confirmation';
                    $self->add_message( { type => $confirmation_type, message => $parsed_json } );
                }
            }
        } else {
            warn sprintf(
                "ISO18626: HTTP request for %s on request %s was successful but returned an empty body.",
                $type,
                $self->iso18626_request_id
            );
        }

        return 1;
    }

    # If we reach this point, the HTTP request failed
    warn sprintf(
        "ISO18626: HTTP Request Failed. Could not send %s to %s. Status: %s. Body: %s",
        $type,
        $requesting_agency->callback_endpoint,
        $response->status_line,
        $response->decoded_content || 'No content provided'
    );
    return 0;
}

=head3 requesting_agency

Returns the associated Koha::ILL::ISO18626::RequestingAgency object.

=cut

sub requesting_agency {
    my ($self) = @_;
    my $ra_rs = $self->_result->iso18626_requesting_agency;
    return unless $ra_rs;
    return Koha::ILL::ISO18626::RequestingAgency->_new_from_dbic($ra_rs);
}

=head3 hold

    my $hold = $iso18626_request->hold();

Method that returns the related I<Koha::Hold>

=cut

sub hold {
    my ($self) = @_;
    my $hold_rs = $self->_result->hold;
    return unless $hold_rs;
    return Koha::Hold->_new_from_dbic($hold_rs);
}

=head3 get_checkout

Returns the related Koha::Checkout obj for this ISO18626 request

=cut

sub get_checkout {
    my ($self) = @_;
    my $rs = $self->_result->issue;
    return unless $rs;
    return Koha::Checkout->_new_from_dbic($rs);
}

=head3 progress_request

Progress the request by sending a message to the requesting agency with the status of the request.

Params:
    - actor: supplyingAgency or requestingAgency
    - params: may contain status, messageInfoNote, message

=cut

sub progress_request {
    my ( $self, $actor, $params ) = @_;

    return unless $actor;

    my $resulting_status = $self->status;
    my $old_status       = $self->status;
    my $new_status       = $params->{status};

    my $reasonForMessage     = 'RequestResponse';
    my $messageInfoNote      = $params->{messageInfoNote} // undef;
    my $answerYesNo          = $params->{answerYesNo}     // undef;
    my $expectedDeliveryDate = _format_iso_payload_date_param( $params->{expectedDeliveryDate} );
    my $reasonUnfilled       = $params->{reasonUnfilled} // undef;
    my $reasonRetry          = $params->{reasonRetry}    // undef;

    my $courierName =
        (      $params->{courierName}
            && $params->{reasonRetry} eq 'ReqDelMethodNotSupp'
            && $params->{deliveryMethod}
            && grep { $_ eq 'Courier' } @{ $params->{deliveryMethod} } ) ? $params->{courierName} : undef;
    my $deliveryMethod = $params->{deliveryMethod}
        && $params->{reasonRetry} eq 'ReqDelMethodNotSupp' ? $params->{deliveryMethod} : undef;
    my $edition =
        $params->{edition} && $params->{reasonRetry} eq 'ReqEditionNotPossible' ? $params->{edition} : undef;
    my $itemFormat =
        $params->{itemFormat} && $params->{reasonRetry} eq 'ReqFormatNotPossible' ? $params->{itemFormat} : undef;
    my $loanCondition = $params->{loanCondition}
        && $params->{reasonRetry} eq 'MustMeetLoanCondition' ? $params->{loanCondition} : undef;
    my $offeredCostsCurrencyCode = $params->{offeredCostsCurrencyCode}
        && $params->{reasonRetry} eq 'CostExceedsMaxCost' ? $params->{offeredCostsCurrencyCode} : undef;
    my $offeredCostsMonetaryValue = $params->{offeredCostsMonetaryValue}
        && $params->{reasonRetry} eq 'CostExceedsMaxCost' ? $params->{offeredCostsMonetaryValue} : undef;
    my $paymentMethod =
          $params->{paymentMethod} && $params->{reasonRetry} eq 'ReqPayMethodNotSupported'
        ? $params->{paymentMethod}
        : undef;
    my $retryBefore  = $params->{retryBefore} && $new_status eq 'RetryPossible' ? $params->{retryBefore} : undef;
    my $retryAfter   = $params->{retryAfter}  && $new_status eq 'RetryPossible' ? $params->{retryAfter}  : undef;
    my $serviceLevel = $params->{serviceLevel}
        && $params->{reasonRetry} eq 'ReqServLevelNotSupp' ? $params->{serviceLevel} : undef;
    my $serviceType =
        $params->{serviceType} && $params->{reasonRetry} eq 'ReqServTypeNotPossible' ? $params->{serviceType} : undef;
    my $volume = $params->{volume} && $params->{reasonRetry} eq 'MultiVolAvail' ? $params->{volume} : undef;

    if ( $actor eq 'requestingAgency' ) {
        return unless $params->{message};

        my $message      = $params->{message};
        my $json_message = JSON::decode_json( $message->content );

        my $requesting_agency_action = $json_message->{requestingAgencyMessage}->{action};

        if ( $requesting_agency_action eq 'StatusRequest' ) {
            $reasonForMessage = 'StatusRequestResponse';
        } elsif ( $requesting_agency_action eq 'Received' ) {
            return;
        }
    } elsif ( $actor eq 'supplyingAgency' ) {
        return unless $new_status;

        $resulting_status = $new_status if $actor eq 'supplyingAgency';

        if ( $resulting_status ne $old_status ) {
            $reasonForMessage = 'StatusChange';
        }

        if ( $new_status eq 'Cancelled' ) {
            $reasonForMessage = 'CancelResponse';
            $resulting_status = $old_status unless $answerYesNo eq 'Y';
            $self->pending_requesting_agency_action(undef)->store;
        }

        #TODO: Handle other statuses
        # elsif ( $new_status eq 'Renew' ) { #Handle 'renew', it's not a status
        #     $reasonForMessage = 'RenewResponse';
        #     $answerYesNo      = $params->{answerYesNo};
        #     $resulting_status = ?????;
        # }

    } else {
        return;
    }

    my $check_out      = $self->get_checkout;
    my $check_out_item = $self->get_checkout ? $self->get_checkout->item : undef;

    my $json = {
        supplyingAgencyMessage => {
            header => {
                supplyingAgencyId => {
                    agencyIdType  => 'ISIL',
                    agencyIdValue => 'sup_agency_value',
                },
                requestingAgencyRequestId => $self->requestingAgencyRequestId,
                supplyingAgencyRequestId  => $self->iso18626_request_id,
                timestamp                 => _format_iso_payload_date_param('now'),
                requestingAgencyId        => {
                    agencyIdType  => 'ISIL',
                    agencyIdValue => 'req_agency_value',
                },
            },
            messageInfo => {
                reasonForMessage => $reasonForMessage,
                $answerYesNo     ? ( answerYesNo => $answerYesNo )     : (),
                $messageInfoNote ? ( note        => $messageInfoNote ) : (),
                $reasonUnfilled && $resulting_status eq 'Unfilled'      ? ( reasonUnfilled => $reasonUnfilled ) : (),
                $reasonRetry    && $resulting_status eq 'RetryPossible' ? ( reasonRetry    => $reasonRetry )    : (),
            },
            statusInfo => {
                status => $resulting_status,
                $expectedDeliveryDate ? ( expectedDeliveryDate => $expectedDeliveryDate ) : (),
                $check_out            ? ( dueDate              => $check_out->date_due )  : (),
                lastChange => $self->updated_on,
            },
            $resulting_status eq 'RetryPossible'
            ? (
                retryInfo => {
                    $loanCondition  ? ( loanCondition  => $loanCondition )          : (),
                    $edition        ? ( edition        => [ split /,/, $edition ] ) : (),
                    $itemFormat     ? ( itemFormat     => $itemFormat )             : (),
                    $volume         ? ( volume         => [ split /,/, $volume ] )  : (),
                    $serviceType    ? ( serviceType    => $serviceType )            : (),
                    $serviceLevel   ? ( serviceLevel   => $serviceLevel )           : (),
                    $deliveryMethod ? ( deliveryMethod => $deliveryMethod )         : (),
                    $courierName    ? ( courierName    => $courierName )            : (),
                    $offeredCostsMonetaryValue && $offeredCostsCurrencyCode
                    ? (
                        offeredCosts => [
                            { currencyCode => $offeredCostsCurrencyCode, monetaryValue => $offeredCostsMonetaryValue }
                        ]
                        )
                    : (),
                    $paymentMethod ? ( paymentMethod => $paymentMethod ) : (),
                    $retryBefore   ? ( retryBefore   => $retryBefore )   : (),
                    $retryAfter    ? ( retryAfter    => $retryAfter )    : (),
                }
                )
            : (),
            ( $resulting_status eq 'Loaned' && $check_out_item )
            ? (
                deliveryInfo => {
                    dateSent => $check_out->issuedate,
                    itemId   => $check_out_item->barcode,

                    #itemFormat  => ['PaperCopy'],    # TODO: Implement: Must come from payload (only needed if specified by RA?)
                    serviceType => 'Loan',

                    #deliveryMethod => 'Email',       # TODO: Implement: Must come from payload (only needed if specified by RA?)
                    #paymentMethod  => 'BankTransfer' # TODO: Implement: Must come from payload (only needed if specified by RA?)
                }
                )
            : (),

            # TODO: Implement shippingInfo
            # shippingInfo => {
            #     courierName         => 'DHL',
            #     trackingId          => [ '123', 'abc' ],
            #     insurance           => 'N',
            #     insuranceThirdParty => 'N',
            #     thirdPartyName      => 'Some name, if insuranceThirdParty',
            #     insuranceCosts      => [ { currencyCode => 'EUR', monetaryValue => '50.00' } ]
            # }
        },
    };

    my $spec_file = dirname(__FILE__) . "/../../../api/v1/swagger/swagger_bundle.json";
    if ( !-f $spec_file ) {
        $spec_file = dirname(__FILE__) . "/../../../api/v1/swagger/swagger.yaml";
    }

    my $schema = JSON::Validator::Schema::OpenAPIv2->new($spec_file);
    $schema->resolve( $schema->data->{definitions}->{supplyingAgencyMessage} );
    my @errors = $schema->validate($json);

    if (@errors) {
        warn sprintf(
            "ISO18626: Schema validation failed for request %s: %s",
            $self->iso18626_request_id,
            join( ', ', map { "$_" } @errors )
        );
        return 0;
    }
    $self->status($resulting_status)->store;
    $self->send_message( 'supplyingAgencyMessage', $json );
    return 1;
}

=head2 _format_iso_payload_date_param

Normalizes a date string to C<YYYY-MM-DD HH:MM:SS>

=cut

sub _format_iso_payload_date_param {
    my ($date_str) = @_;
    return unless $date_str;

    my $dt = eval { $date_str eq 'now' ? dt_from_string() : dt_from_string($date_str) };
    return $dt ? $dt->strftime('%Y-%m-%d %H:%M:%S') : $date_str;
}

=head3 _type

=cut

sub _type {
    return 'Iso18626Request';
}

1;
