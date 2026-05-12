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
use Test::More tests => 6;
use Test::MockModule;
use Test::MockObject;

use C4::Circulation qw( AddIssue CanBookBeIssued );
use Koha::CirculationRules;
use Koha::Database;
use Koha::Holds;
use Koha::ILL::ISO18626::Requests;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

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

subtest 'CanBookBeIssued() SUPPLY_ILL detection' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'ILLModule', 1 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $ill_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'A' }
        }
    );
    t::lib::Mocks::mock_preference( 'ILLPartnerCode', $ill_category->categorycode );

    my $ill_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $ill_category->categorycode, branchcode => $library->branchcode }
        }
    );

    my $other_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'A' }
        }
    );
    my $regular_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $other_category->categorycode, branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { patron => $ill_patron, branchcode => $library->branchcode } );

    # Test 1: item-level hold with ISO18626 request → SUPPLY_ILL is set
    my $item_hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $ill_patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $library->branchcode,
            }
        }
    );
    my $iso18626_request_item = $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::Requests',
            value => { hold_id => $item_hold->reserve_id, biblio_id => $item->biblionumber }
        }
    );

    my ( $error, $question, $alerts ) = CanBookBeIssued( $ill_patron, $item->barcode );
    ok( $question->{SUPPLY_ILL}, 'SUPPLY_ILL is set for ILL patron with item-level hold' );
    is(
        $question->{iso18626_payload_supplyill},
        $iso18626_request_item->iso18626_request_id,
        'iso18626_payload_supplyill contains the correct request ID for item-level hold'
    );

    $iso18626_request_item->delete;
    $item_hold->delete;

    # Test 2: biblio-level hold (itemnumber = NULL) with ISO18626 request → SUPPLY_ILL is set
    my $biblio_hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $ill_patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                itemnumber     => undef,
                branchcode     => $library->branchcode,
            }
        }
    );
    my $iso18626_request_biblio = $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::Requests',
            value => { hold_id => $biblio_hold->reserve_id, biblio_id => $item->biblionumber }
        }
    );

    ( $error, $question, $alerts ) = CanBookBeIssued( $ill_patron, $item->barcode );
    ok( $question->{SUPPLY_ILL}, 'SUPPLY_ILL is set for ILL patron with biblio-level hold' );
    is(
        $question->{iso18626_payload_supplyill},
        $iso18626_request_biblio->iso18626_request_id,
        'iso18626_payload_supplyill contains the correct request ID for biblio-level hold'
    );

    $iso18626_request_biblio->delete;
    $biblio_hold->delete;

    # Test 3: ILL patron with hold but no linked ISO18626 request → SUPPLY_ILL not set
    my $hold_no_request = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $ill_patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                itemnumber     => undef,
                branchcode     => $library->branchcode,
            }
        }
    );

    ( $error, $question, $alerts ) = CanBookBeIssued( $ill_patron, $item->barcode );
    ok( !$question->{SUPPLY_ILL}, 'SUPPLY_ILL is not set when hold has no linked ISO18626 request' );

    $hold_no_request->delete;

    # Test 4: non-ILL patron with hold and ISO18626 request → SUPPLY_ILL not set
    my $regular_hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $regular_patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                itemnumber     => undef,
                branchcode     => $library->branchcode,
            }
        }
    );
    my $iso18626_request_regular = $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::Requests',
            value => { hold_id => $regular_hold->reserve_id, biblio_id => $item->biblionumber }
        }
    );

    ( $error, $question, $alerts ) = CanBookBeIssued( $regular_patron, $item->barcode );
    ok( !$question->{SUPPLY_ILL}, 'SUPPLY_ILL is not set for a non-ILL patron' );

    $schema->storage->txn_rollback;
};

subtest 'AddIssue() ISO18626 request status update on checkout' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'ILLModule', 1 );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $ill_category = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { category_type => 'A' }
        }
    );
    t::lib::Mocks::mock_preference( 'ILLPartnerCode', $ill_category->categorycode );

    my $ill_patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { categorycode => $ill_category->categorycode, branchcode => $library->branchcode }
        }
    );

    my $item = $builder->build_sample_item( { library => $library->branchcode } );

    Koha::CirculationRules->set_rules(
        {
            categorycode => undef,
            itemtype     => undef,
            branchcode   => undef,
            rules        => {
                issuelength => 14,
                lengthunit  => 'days',
            }
        }
    );

    t::lib::Mocks::mock_userenv( { patron => $ill_patron, branchcode => $library->branchcode } );

    # Biblio-level hold with a linked ISO18626 request at WillSupply status
    my $biblio_hold = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $ill_patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                itemnumber     => undef,
                branchcode     => $library->branchcode,
            }
        }
    );
    my $iso18626_request = $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::Requests',
            value => {
                hold_id   => $biblio_hold->reserve_id,
                biblio_id => $item->biblionumber,
                status    => 'WillSupply',
            }
        }
    );

    my $mock_ua = Test::MockModule->new('LWP::UserAgent');
    $mock_ua->mock( 'post', sub { return $mock_ua_response; } );

    my $issue = AddIssue(
        $ill_patron, $item->barcode, undef, 0, undef, undef,
        { iso18626_payload => { iso18626_payload_supplyill => $iso18626_request->iso18626_request_id } }
    );

    $iso18626_request->discard_changes;

    ok( $issue, 'Checkout was created' );
    is( $iso18626_request->status,   'Loaned',         'ISO18626 request status updated to Loaned after checkout' );
    is( $iso18626_request->issue_id, $issue->issue_id, 'ISO18626 request issue_id linked to the new checkout' );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Hold::progress_iso18626_request() state machine' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    my $mock_ua = Test::MockModule->new('LWP::UserAgent');
    $mock_ua->mock( 'post', sub { return $mock_ua_response; } );

    my $make_hold_and_request = sub {
        my ($status) = @_;
        my $patron =
            $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library->branchcode } } );
        my $item = $builder->build_sample_item( { library => $library->branchcode } );
        my $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    itemnumber     => undef,
                    branchcode     => $library->branchcode,
                }
            }
        );
        my $request = $builder->build_object(
            {
                class => 'Koha::ILL::ISO18626::Requests',
                value => {
                    hold_id   => $hold->reserve_id,
                    biblio_id => $item->biblionumber,
                    status    => $status,
                }
            }
        );
        return ( $hold, $request );
    };

    # hold_created when status = RequestReceived → ExpectToSupply
    my ( $hold, $request ) = $make_hold_and_request->('RequestReceived');
    $hold->progress_iso18626_request( 'hold_created', {} );
    $request->discard_changes;
    is( $request->status, 'ExpectToSupply', 'hold_created transitions RequestReceived → ExpectToSupply' );

    # hold_created when status ≠ RequestReceived → no change
    ( $hold, $request ) = $make_hold_and_request->('ExpectToSupply');
    $hold->progress_iso18626_request( 'hold_created', {} );
    $request->discard_changes;
    is( $request->status, 'ExpectToSupply', 'hold_created does not transition status when not in RequestReceived' );

    # hold_waiting → WillSupply
    ( $hold, $request ) = $make_hold_and_request->('ExpectToSupply');
    $hold->progress_iso18626_request('hold_waiting');
    $request->discard_changes;
    is( $request->status, 'WillSupply', 'hold_waiting transitions ExpectToSupply → WillSupply' );

    # hold_waiting_reverted when status = WillSupply → ExpectToSupply
    ( $hold, $request ) = $make_hold_and_request->('WillSupply');
    $hold->progress_iso18626_request('hold_waiting_reverted');
    $request->discard_changes;
    is( $request->status, 'ExpectToSupply', 'hold_waiting_reverted transitions WillSupply → ExpectToSupply' );

    # hold_waiting_reverted when status ≠ WillSupply → no change
    ( $hold, $request ) = $make_hold_and_request->('ExpectToSupply');
    $hold->progress_iso18626_request('hold_waiting_reverted');
    $request->discard_changes;
    is( $request->status, 'ExpectToSupply', 'hold_waiting_reverted does not transition status when not in WillSupply' );

    # hold_cancelled → Unfilled
    ( $hold, $request ) = $make_hold_and_request->('ExpectToSupply');
    $hold->progress_iso18626_request('hold_cancelled');
    $request->discard_changes;
    is( $request->status, 'Unfilled', 'hold_cancelled transitions → Unfilled' );

    # hold with no ISO18626 request → no-op, no crash
    my $patron_no_ill =
        $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library->branchcode } } );
    my $item_no_ill = $builder->build_sample_item( { library => $library->branchcode } );
    my $hold_no_ill = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron_no_ill->borrowernumber,
                biblionumber   => $item_no_ill->biblionumber,
                itemnumber     => undef,
                branchcode     => $library->branchcode,
            }
        }
    );
    ok(
        !$hold_no_ill->progress_iso18626_request('hold_cancelled'),
        'progress_iso18626_request is a no-op when hold has no linked ISO18626 request'
    );

    $schema->storage->txn_rollback;
};

subtest 'progress_request() returns 0 and does not update status on schema validation failure' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $request = $builder->build_object(
        {
            class => 'Koha::ILL::ISO18626::Requests',
            value => { status => 'RequestReceived' }
        }
    );

    my $mock_validator = Test::MockModule->new('JSON::Validator::Schema::OpenAPIv2');
    $mock_validator->mock( 'validate', sub { return ('fake validation error') } );

    my $result;
    {
        local $SIG{__WARN__} = sub { };
        $result = $request->progress_request( 'supplyingAgency', { status => 'ExpectToSupply' } );
    }

    is( $result, 0, 'progress_request returns 0 when schema validation fails' );

    $request->discard_changes;
    is( $request->status, 'RequestReceived', 'Request status is not updated when validation fails' );

    $schema->storage->txn_rollback;
};

subtest 'add_message() and messages()' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $iso18626_request = $builder->build_object( { class => 'Koha::ILL::ISO18626::Requests' } );

    $iso18626_request->add_message( { type => 'supplyingAgencyMessage', message => { status => 'ExpectToSupply' } } );
    is( $iso18626_request->messages->count, 1, 'add_message with a HASH payload adds one message' );

    $iso18626_request->add_message( { type => 'supplyingAgencyMessage', message => '{"status":"WillSupply"}' } );
    is( $iso18626_request->messages->count, 2, 'add_message with a string payload adds another message' );

    $schema->storage->txn_rollback;
};
