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
use Test::More tests => 4;

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
