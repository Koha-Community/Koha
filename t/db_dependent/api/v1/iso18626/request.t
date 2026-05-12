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

use Test::MockModule;
use Test::MockObject;
use Test::Mojo;
use Test::Warn;

use MIME::Base64 qw(encode_base64);
use JSON         qw(encode_json);

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::AuthorisedValueCategories;
use Koha::ILL::ISO18626::Requests;
use Koha::DateUtils qw( format_sqldatetime );

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
t::lib::Mocks::mock_preference( 'ILLModule',     1 );

my $t = Test::Mojo->new('Koha::REST::V1');

subtest 'list() tests' => sub {

    plan tests => 29;

    $schema->storage->txn_begin;

    # create an authorized user
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $requestXml = <<'XML';
        <request xmlns="https://example.com/ill/request">
        <header>
          <requestingAgencyRequestId>XYZ</requestingAgencyRequestId>
          <timestamp>2023-03-15 14:30:00</timestamp>
          <requestingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>req_agency_value</agencyIdValue>
          </requestingAgencyId>
        </header>
        <bibliographicInfo>
          <title>This is an optional title</title>
        </bibliographicInfo>
      </request>
XML

    #FIXME: This error message should be something like "Expected content-type application/xml"
    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        $requestXml
        )
        ->status_is(400)
        ->json_is( '/errors' => [ { path => '/message', message => 'Expected object - got string.' } ] );

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $requestXml
    )->status_is(400)->content_like(
        qr{<errorValue>/request/serviceInfo: object, required</errorValue>},
        'serviceInfo missing'
    )->content_like(
        qr{<messageStatus>ERROR</messageStatus>},
        'messageStatus is ERROR'
    );

    my $bad_auth_requestXml = <<'XML';
        <request xmlns="https://example.com/ill/request">
        <header>
          <requestingAgencyRequestId>XYZ</requestingAgencyRequestId>
          <timestamp>2023-03-15 14:30:00</timestamp>
          <requestingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>req_agency_value</agencyIdValue>
          </requestingAgencyId>
        </header>
        <bibliographicInfo>
          <title>This is an optional title</title>
        </bibliographicInfo>
        <serviceInfo>
          <serviceType>Copy</serviceType>
        </serviceInfo>
      </request>
XML

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $bad_auth_requestXml
    )->status_is(400)->content_like(
        qr{<timestamp>[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z</timestamp>},
        'timestamp is present'
    )->content_like(
        qr{<errorValue>AuthenticationFailed</errorValue>},
        'error value is authentication failed'
    );
    my $supplyingAgencyMessageConfirmationXml = <<'XML';
        <supplyingAgencyMessageConfirmation xmlns="https://example.com/ill/request">
          <confirmationHeader>
            <timestamp>2023-01-01T00:00:00Z</timestamp>
          </confirmationHeader>
        </supplyingAgencyMessageConfirmation>
XML

    my $mock_ua_response = Test::MockObject->new();
    $mock_ua_response->mock( 'is_success',      sub { return 1; } );
    $mock_ua_response->mock( 'decoded_content', sub { return $supplyingAgencyMessageConfirmationXml; } );
    $mock_ua_response->mock( 'status_line',     sub { return '200 OK'; } );

    my $mock_ua = Test::MockModule->new('LWP::UserAgent');
    $mock_ua->mock( 'post', sub { return $mock_ua_response; } );

    my $requesting_agency = $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::RequestingAgencies',
            value =>
                { account_id => 'asd', securityCode => 'asds', callback_endpoint => 'https://localhost/ill/callback' }
        }
    );

    my $authenticated_requestXml = <<'XML';
        <request xmlns="https://example.com/ill/request">
        <header>
          <requestingAgencyAuthentication>
            <accountId>asd</accountId>
            <securityCode>asds</securityCode>
          </requestingAgencyAuthentication>
          <requestingAgencyRequestId>XYZ</requestingAgencyRequestId>
          <timestamp>2023-03-15 14:30:00</timestamp>
          <requestingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>req_agency_value</agencyIdValue>
          </requestingAgencyId>
        </header>
        <bibliographicInfo>
          <title>This is an optional title</title>
        </bibliographicInfo>
        <serviceInfo>
          <serviceType>Copy</serviceType>
        </serviceInfo>
      </request>
XML

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $authenticated_requestXml
    )->status_is(201)->content_like(
        qr{<timestamp>[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z</timestamp>},
        'timestamp is present'
    )->content_like(
        qr{<messageStatus>OK</messageStatus>},
        'messageStatus is OK'
    );

    my $last_request = Koha::ILL::ISO18626::Requests->search(
        {},
        { order_by => { -desc => 'iso18626_request_id' }, rows => 1 }
    )->single;

    $t->patch_ok( "//$userid:$password@/api/v1/ill/iso18626_requests/"
            . $last_request->iso18626_request_id => json => { status => 'Loaned' } )->status_is(200);

    my $requestingAgencyMessagexml = '
    <requestingAgencyMessage xmlns="https://example.com/ill/request">
        <header>
          <requestingAgencyAuthentication>
            <accountId>asd</accountId>
            <securityCode>asds</securityCode>
          </requestingAgencyAuthentication>
          <requestingAgencyRequestId>1</requestingAgencyRequestId>
          <supplyingAgencyRequestId>%s</supplyingAgencyRequestId>
          <timestamp>2023-03-15 14:30:00</timestamp>
          <requestingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>req_agency_value</agencyIdValue>
          </requestingAgencyId>
          <supplyingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>sup_agency_value</agencyIdValue>
          </supplyingAgencyId>
        </header>
        <action>%s</action>
      </requestingAgencyMessage>';

    my $invalid_action_requestingAgencyMessagexml =
        sprintf( $requestingAgencyMessagexml, $last_request->iso18626_request_id, 'InvalidAction' );

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $invalid_action_requestingAgencyMessagexml
    )->status_is(400)->content_like(
        qr{<errorType>BadlyFormedMessage</errorType>},
        'invalid action error as expected'
    );

    my $unsupported_action_requestingAgencyMessagexml =
        sprintf( $requestingAgencyMessagexml, $last_request->iso18626_request_id, 'ShippedForward' );
    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $unsupported_action_requestingAgencyMessagexml
    )->status_is(400)->content_like(
        qr{<errorType>UnsupportedActionType</errorType>},
        'unsupported action error as expected'
    );

    my $good_requestingAgencyMessagexml =
        sprintf( $requestingAgencyMessagexml, $last_request->iso18626_request_id, 'StatusRequest' );

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $good_requestingAgencyMessagexml
    )->status_is(201)->content_like(
        qr{<messageStatus>OK</messageStatus>},
        'message is okay'
    );

    my $nonexistent_supplyingAgency_requestingAgencyMessagexml =
        sprintf( $requestingAgencyMessagexml, $last_request->iso18626_request_id, 'StatusRequest' );

    $last_request->delete;

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $nonexistent_supplyingAgency_requestingAgencyMessagexml
    )->status_is(400)->content_like(
        qr{<errorType>UnrecognizedDataValue</errorType>},
        'Cant find this supplyingAgencyRequestId'
    );

    $schema->storage->txn_rollback;
};

subtest 'edit() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $request = $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::Requests',
            value => { status => 'RequestReceived' }
        }
    );

    my $mock_request = Test::MockModule->new('Koha::ILL::ISO18626::Request');
    $mock_request->mock( 'progress_request', sub { return 0 } );

    $t->patch_ok(
        "//$userid:$password@/api/v1/ill/iso18626_requests/" . $request->iso18626_request_id =>
            json => { status => 'ExpectToSupply' }
        )->status_is(500)
        ->json_is( '/error' => 'Request could not be progressed' );

    $schema->storage->txn_rollback;
};

subtest 'send_message() tests' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**22 }    # 22 => ill
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    # Test: no callback_endpoint defined on requesting agency
    $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::RequestingAgencies',
            value => { account_id => 'no_callback_test', securityCode => 'test_secret_1', callback_endpoint => '' }
        }
    );

    my $request_no_callback_xml = <<'XML';
        <request xmlns="https://example.com/ill/request">
        <header>
          <requestingAgencyAuthentication>
            <accountId>no_callback_test</accountId>
            <securityCode>test_secret_1</securityCode>
          </requestingAgencyAuthentication>
          <requestingAgencyRequestId>XYZ</requestingAgencyRequestId>
          <timestamp>2023-03-15 14:30:00</timestamp>
          <requestingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>req_agency_value</agencyIdValue>
          </requestingAgencyId>
        </header>
        <bibliographicInfo>
          <title>Test request - no callback</title>
        </bibliographicInfo>
        <serviceInfo>
          <serviceType>Copy</serviceType>
        </serviceInfo>
      </request>
XML

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $request_no_callback_xml
    )->status_is(201)->content_like(
        qr{<messageStatus>OK</messageStatus>},
        'request created successfully'
    );

    my $request_no_callback = Koha::ILL::ISO18626::Requests->search(
        {},
        { order_by => { -desc => 'iso18626_request_id' }, rows => 1 }
    )->single;

    warning_like {
        $t->patch_ok( "//$userid:$password@/api/v1/ill/iso18626_requests/"
                . $request_no_callback->iso18626_request_id => json => { status => 'Loaned' } )->status_is(200);
    }
    qr/ISO18626: Cannot send message/, 'warns when requesting agency has no callback_endpoint';

    # Test: callback_endpoint defined but HTTP request fails
    $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::RequestingAgencies',
            value => {
                account_id        => 'bad_endpoint_test',
                securityCode      => 'test_secret_2',
                callback_endpoint => 'https://localhost/ill/callback'
            }
        }
    );

    my $mock_fail_response = Test::MockObject->new();
    $mock_fail_response->mock( 'is_success',      sub { return 0; } );
    $mock_fail_response->mock( 'status_line',     sub { return '500 Internal Server Error'; } );
    $mock_fail_response->mock( 'decoded_content', sub { return 'Internal Server Error'; } );

    my $mock_ua_fail = Test::MockModule->new('LWP::UserAgent');
    $mock_ua_fail->mock( 'post', sub { return $mock_fail_response; } );

    my $request_bad_endpoint_xml = <<'XML';
        <request xmlns="https://example.com/ill/request">
        <header>
          <requestingAgencyAuthentication>
            <accountId>bad_endpoint_test</accountId>
            <securityCode>test_secret_2</securityCode>
          </requestingAgencyAuthentication>
          <requestingAgencyRequestId>XYZ</requestingAgencyRequestId>
          <timestamp>2023-03-15 14:30:00</timestamp>
          <requestingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>req_agency_value</agencyIdValue>
          </requestingAgencyId>
        </header>
        <bibliographicInfo>
          <title>Test request - bad endpoint</title>
        </bibliographicInfo>
        <serviceInfo>
          <serviceType>Copy</serviceType>
        </serviceInfo>
      </request>
XML

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $request_bad_endpoint_xml
    )->status_is(201)->content_like(
        qr{<messageStatus>OK</messageStatus>},
        'request created successfully'
    );

    my $request_bad_endpoint = Koha::ILL::ISO18626::Requests->search(
        {},
        { order_by => { -desc => 'iso18626_request_id' }, rows => 1 }
    )->single;

    warning_like {
        $t->patch_ok( "//$userid:$password@/api/v1/ill/iso18626_requests/"
                . $request_bad_endpoint->iso18626_request_id => json => { status => 'Loaned' } )->status_is(200);
    }
    qr/ISO18626: HTTP Request Failed/, 'warns when HTTP request to callback_endpoint fails';

    # Test: callback_endpoint is set but is not a valid URL
    $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::RequestingAgencies',
            value => {
                account_id        => 'invalid_url_test',
                securityCode      => 'test_secret_3',
                callback_endpoint => 'not-a-valid-url'
            }
        }
    );

    my $request_invalid_url_xml = <<'XML';
        <request xmlns="https://example.com/ill/request">
        <header>
          <requestingAgencyAuthentication>
            <accountId>invalid_url_test</accountId>
            <securityCode>test_secret_3</securityCode>
          </requestingAgencyAuthentication>
          <requestingAgencyRequestId>XYZ</requestingAgencyRequestId>
          <timestamp>2023-03-15 14:30:00</timestamp>
          <requestingAgencyId>
            <agencyIdType>ISIL</agencyIdType>
            <agencyIdValue>req_agency_value</agencyIdValue>
          </requestingAgencyId>
        </header>
        <bibliographicInfo>
          <title>Test request - invalid url</title>
        </bibliographicInfo>
        <serviceInfo>
          <serviceType>Copy</serviceType>
        </serviceInfo>
      </request>
XML

    $t->post_ok(
        "//$userid:$password@/api/v1/public/ill/iso18626",
        { 'Content-Type' => 'application/xml' },
        $request_invalid_url_xml
    )->status_is(201)->content_like(
        qr{<messageStatus>OK</messageStatus>},
        'request created successfully'
    );

    my $request_invalid_url = Koha::ILL::ISO18626::Requests->search(
        {},
        { order_by => { -desc => 'iso18626_request_id' }, rows => 1 }
    )->single;

    warning_like {
        $t->patch_ok( "//$userid:$password@/api/v1/ill/iso18626_requests/"
                . $request_invalid_url->iso18626_request_id => json => { status => 'Loaned' } )->status_is(200);
    }
    qr/ISO18626: HTTP Request Failed/, 'warns when callback_endpoint is not a valid URL';

    $schema->storage->txn_rollback;
};

