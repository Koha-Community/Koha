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
use Test::More tests => 3;

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
        $root->getAttributeNS( $iso18626_namespace, 'version' ), '1.2',
        'version attribute is set and namespace-qualified'
    );

    my ($message) = grep { $_->nodeType == 1 } $root->childNodes;
    is( $message->localName,    'requestConfirmation', 'Message type is the child of ISO18626Message' );
    is( $message->namespaceURI, $iso18626_namespace,   'Message type is in the ISO 18626 namespace' );

    my ($status) = $root->getElementsByTagNameNS( $iso18626_namespace, 'messageStatus' );
    ok( $status, 'Nested elements are in the ISO 18626 namespace' );
    is( $status->textContent, 'OK', 'Nested element value is kept' );
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
