#!/usr/bin/env perl

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

use Test::NoWarnings;
use Test::More tests => 5;
use Test::Exception;

use File::Basename qw( dirname );
use XML::LibXML;

use Koha::ILL::ISO18626;

my $iso18626_namespace = 'http://illtransactions.org/2013/iso18626';

subtest 'xml_with_envelope() tests' => sub {

    plan tests => 7;

    my $xml =
        Koha::ILL::ISO18626::xml_with_envelope(
        { requestConfirmation => { confirmationHeader => { messageStatus => 'OK' } } } );

    my $root = XML::LibXML->load_xml( string => $xml )->documentElement;
    is( $root->localName,    'ISO18626Message',   'Message is wrapped in an ISO18626Message element' );
    is( $root->namespaceURI, $iso18626_namespace, 'ISO18626Message is in the ISO 18626 namespace' );
    is(
        $root->getAttributeNS( $iso18626_namespace, 'version' ), '2021-3',
        'version attribute is set and namespace-qualified'
    );

    my ($message) = grep { $_->nodeType == 1 } $root->childNodes;
    is( $message->localName,    'requestConfirmation', 'Message type is the child of ISO18626Message' );
    is( $message->namespaceURI, $iso18626_namespace,   'Message type is in the ISO 18626 namespace' );

    my ($status) = $root->getElementsByTagNameNS( $iso18626_namespace, 'messageStatus' );
    ok( $status, 'Nested elements are in the ISO 18626 namespace' );
    is( $status->textContent, 'OK', 'Nested element value is kept' );
};

subtest 'xml_with_envelope() element order tests' => sub {

    plan tests => 6;

    my $children = sub {
        my ($element) = @_;
        return [ map { $_->localName } $element->findnodes('./*') ];
    };

    my $xml = Koha::ILL::ISO18626::xml_with_envelope(
        {
            supplyingAgencyMessage => {
                undefinedB   => 'b',
                undefinedA   => 'a',
                shippingInfo => { courierName      => 'DHL' },
                statusInfo   => { lastChange       => '2026-09-30T00:00:00Z', status => 'Loaned' },
                retryInfo    => { retryAfter       => '2026-10-30T00:00:00Z' },
                messageInfo  => { reasonForMessage => 'StatusChange' },
                header       => {
                    supplyingAgencyRequestId  => '2',
                    requestingAgencyRequestId => '1',
                    timestamp                 => '2026-09-30T00:00:00Z',
                    requestingAgencyId        => { agencyIdValue => 'Y', agencyIdType => 'ISIL' },
                    supplyingAgencyId         => { agencyIdValue => 'X', agencyIdType => 'ISIL' },
                },
            }
        }
    );
    my ($message) = XML::LibXML->load_xml( string => $xml )->documentElement->findnodes('./*');
    my %element = map { $_->localName => $_ } $message->findnodes('./*');

    is_deeply(
        $children->($message), [qw( header messageInfo statusInfo retryInfo shippingInfo undefinedA undefinedB )],
        'Message children follow the schema order, elements the schema does not define come last sorted by name'
    );
    is_deeply(
        $children->( $element{header} ),
        [qw( supplyingAgencyId requestingAgencyId timestamp requestingAgencyRequestId supplyingAgencyRequestId )],
        'header children follow the schema order'
    );
    is_deeply(
        $children->( ( $element{header}->findnodes('./*') )[0] ), [qw( agencyIdType agencyIdValue )],
        'Nested children follow the schema order'
    );

    $xml = Koha::ILL::ISO18626::xml_with_envelope(
        {
            requestConfirmation => {
                errorData => [
                    { errorValue => 'first',  errorType => 'BadlyFormedMessage' },
                    { errorValue => 'second', errorType => 'UnrecognizedDataValue' },
                ],
                confirmationHeader => { messageStatus => 'ERROR', timestamp => '2026-09-30T00:00:00Z' },
            }
        }
    );
    ($message) = XML::LibXML->load_xml( string => $xml )->documentElement->findnodes('./*');
    my @error_data = grep { $_->localName eq 'errorData' } $message->findnodes('./*');

    is_deeply(
        $children->($message), [qw( confirmationHeader errorData errorData )],
        'Repeated elements follow the schema order'
    );
    is_deeply(
        [ map { $_->findvalue('./*[local-name()="errorValue"]') } @error_data ], [qw( first second )],
        'Repeated elements keep their order'
    );
    is_deeply(
        $children->( $error_data[0] ), [qw( errorType errorValue )],
        'Repeated element children follow the schema order'
    );
};

subtest 'xml_with_envelope() schema validation tests' => sub {

    plan tests => 6;

    my $schema =
        XML::LibXML::Schema->new( location => dirname(__FILE__) . '/../../data/iso18626/ISO-18626-2021-3.xsd' );

    my $timestamp            = '2026-09-30T00:00:00Z';
    my $supplying_agency_id  = { agencyIdValue => 'X', agencyIdType => 'ISIL' };
    my $requesting_agency_id = { agencyIdValue => 'Y', agencyIdType => 'ISIL' };
    my $confirmation_header  = {
        messageStatus             => 'OK',
        timestampReceived         => $timestamp,
        requestingAgencyRequestId => '1',
        timestamp                 => $timestamp,
        requestingAgencyId        => $requesting_agency_id,
        supplyingAgencyId         => $supplying_agency_id,
    };

    my $messages = {
        request => {
            billingInfo => { billingName => 'Library Y', paymentMethod => 'Invoice' },
            patronInfo  => { givenName   => 'Jane', surname => 'Doe', patronId => '42' },
            serviceInfo => {
                note           => 'A note',
                needBeforeDate => $timestamp,
                serviceLevel   => 'Normal',
                serviceType    => 'Loan',
                requestType    => 'New',
            },
            publicationInfo   => { publicationDate => '2001', publisher => 'Publisher' },
            bibliographicInfo => {
                bibliographicItemId => {
                    bibliographicItemIdentifier     => '9780000000000',
                    bibliographicItemIdentifierCode => 'ISBN',
                },
                edition => '2nd',
                author  => 'Author',
                title   => 'Title',
            },
            header => {
                requestingAgencyRequestId => '1',
                timestamp                 => $timestamp,
                requestingAgencyId        => $requesting_agency_id,
                supplyingAgencyId         => $supplying_agency_id,
            },
        },
        requestConfirmation => {
            errorData => [
                { errorValue => 'first',  errorType => 'BadlyFormedMessage' },
                { errorValue => 'second', errorType => 'UnrecognisedDataValue' },
            ],
            confirmationHeader => { %$confirmation_header, messageStatus => 'ERROR' },
        },
        supplyingAgencyMessage => {
            returnInfo   => { name       => 'Library X', returnAgencyId => $supplying_agency_id },
            shippingInfo => { trackingId => 'T1',        courierName    => 'DHL' },
            deliveryInfo =>
                { itemFormat => 'Printed', deliveryMethod => 'Mail', itemId => 'I1', dateSent => $timestamp },
            statusInfo  => { lastChange => $timestamp, dueDate => $timestamp, status => 'Loaned' },
            messageInfo => { note => 'A note', reasonForMessage => 'StatusChange' },
            header      => {
                supplyingAgencyRequestId  => '2',
                requestingAgencyRequestId => '1',
                timestamp                 => $timestamp,
                requestingAgencyId        => $requesting_agency_id,
                supplyingAgencyId         => $supplying_agency_id,
            },
        },
        supplyingAgencyMessageConfirmation => {
            reasonForMessage   => 'StatusChange',
            confirmationHeader => $confirmation_header,
        },
        requestingAgencyMessage => {
            note   => 'A note',
            action => 'Received',
            header => {
                supplyingAgencyRequestId  => '2',
                requestingAgencyRequestId => '1',
                timestamp                 => $timestamp,
                requestingAgencyId        => $requesting_agency_id,
                supplyingAgencyId         => $supplying_agency_id,
            },
        },
        requestingAgencyMessageConfirmation => {
            action             => 'Received',
            confirmationHeader => $confirmation_header,
        },
    };

    foreach my $type ( sort keys %$messages ) {
        my $xml = Koha::ILL::ISO18626::xml_with_envelope( { $type => $messages->{$type} } );
        lives_ok { $schema->validate( XML::LibXML->load_xml( string => $xml ) ) }
        "$type validates against the ISO 18626 schema";
    }
};

subtest 'message_without_envelope() tests' => sub {

    plan tests => 2;

    my $message = { requestConfirmation => { confirmationHeader => { messageStatus => 'OK' } } };

    is_deeply(
        Koha::ILL::ISO18626::message_without_envelope( { ISO18626Message => $message } ), $message,
        'Message wrapped in ISO18626Message is unwrapped'
    );
    is_deeply(
        Koha::ILL::ISO18626::message_without_envelope($message), $message,
        'Unwrapped message is returned as it is (backwards compatibility)'
    );
};
