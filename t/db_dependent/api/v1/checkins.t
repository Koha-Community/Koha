#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 21;
use Test::MockModule;
use Test::Mojo;
use Test::Warn;
use Mojo::JSON;
use t::lib::Mocks;
use t::lib::Mocks::Logger;
use t::lib::TestBuilder;

use C4::Circulation qw( AddIssue );
use C4::Reserves    qw( AddReserve );
use Koha::Database;
use Koha::Account;
use Koha::Checkouts;
use Koha::Checkins;
use Koha::CirculationRules;
use Koha::DateTime::Format::RFC3339;
use Koha::Exceptions::Checkin;
use Koha::Holds;
use Koha::Old::Checkouts;
use Koha::Recalls;
use Koha::Token;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
my $t = Test::Mojo->new('Koha::REST::V1');

# Builds a valid action token for a checkin follow-up action, regardless of
# the actions offered for the checkin, to reach the endpoint's own checks
sub action_token {
    my ( $checkin, $action, $user ) = @_;
    return Koha::Token->new->generate_jwt(
        { id => $checkin->_action_token_id( $action, $user ), expires => time + 60 } );
}

subtest 'get_availability' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => 'pass000', skip_validation => 1 } );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    # Unauthorized
    $t->get_ok( "//" . $patron->userid . ":pass000\@/api/v1/checkins/availability?item_id=" . $item->id )
        ->status_is(403);

    # Missing item_id
    $t->get_ok( "//$userid:$password\@/api/v1/checkins/availability?library_id=" . $library->branchcode )
        ->status_is(400);

    # Item not found
    $t->get_ok("//$userid:$password\@/api/v1/checkins/availability?item_id=999999999")->status_is(404);

    # Item not checked out - not_issued confirmation + token
    $t->get_ok( "//$userid:$password\@/api/v1/checkins/availability?item_id="
            . $item->id
            . "&library_id="
            . $library->branchcode )
        ->status_is(200)
        ->json_is( '/blockers' => {} )
        ->json_has('/confirms/not_issued')
        ->json_has('/confirmation_token');

    # Item checked out - no confirmations, no token
    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );
    AddIssue( $patron, $item->barcode );

    $t->get_ok( "//$userid:$password\@/api/v1/checkins/availability?item_id="
            . $item->id
            . "&library_id="
            . $library->branchcode )->status_is(200)->json_is( '/confirmation_token' => undef );

    # Withdrawn item with BlockReturnOfWithdrawnItems - has blocker
    my $withdrawn_item = $builder->build_sample_item( { library => $library->branchcode, withdrawn => 1 } );
    AddIssue( $patron, $withdrawn_item->barcode );
    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 1 );

    $t->get_ok( "//$userid:$password\@/api/v1/checkins/availability?item_id="
            . $withdrawn_item->id
            . "&library_id="
            . $library->branchcode )->status_is(200)->json_has('/blockers/blocked_withdrawn');

    $schema->storage->txn_rollback;
};

subtest 'add' => sub {

    plan tests => 36;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => 'pass000', skip_validation => 1 } );

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Unauthorized
    $t->post_ok(
        "//" . $patron->userid . ":pass000\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(403);

    # Missing parameters
    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => { library_id => $library->branchcode } )
        ->status_is(400)
        ->json_is( '/error_code' => 'missing_item_identifier' );

    # Item not found
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => 999999999,
            library_id => $library->branchcode,
        }
    )->status_is(404);

    # Not checked out - needs confirmation
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
        )
        ->status_is(412)
        ->json_is( '/error_code' => 'confirmation_required' )
        ->json_has('/confirms/not_issued')
        ->json_has('/confirmation_token');

    # Not checked out - with invalid token
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins?confirmation=invalid.token.value" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(412)->json_is( '/error_code' => 'confirmation_required' );

    # Not checked out - with valid token
    my $token = $t->tx->res->json('/confirmation_token');
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins?confirmation=$token" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200)->json_has('/checkin_id')->json_is( '/item_id' => $item->id )->json_has('/local_use');

    # Check out then check in - normal flow
    AddIssue( $patron, $item->barcode );
    my $checkout = Koha::Checkouts->find( { itemnumber => $item->id } );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
        )
        ->status_is(200)
        ->json_has('/checkin_id')
        ->json_is( '/item_id'     => $item->id )
        ->json_is( '/checkout_id' => $checkout->issue_id )
        ->json_is( '/library_id'  => $library->branchcode );

    # Check in by barcode
    AddIssue( $patron, $item->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            external_id => $item->barcode,
            library_id  => $library->branchcode,
        }
    )->status_is(200)->json_has('/checkin_id');

    # With embeds
    AddIssue( $patron, $item->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => { 'x-koha-embed' => 'item,library' } => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200)->json_has('/item')->json_has('/library');

    # Withdrawn + BlockReturnOfWithdrawnItems - blocked
    my $withdrawn_item = $builder->build_sample_item( { library => $library->branchcode, withdrawn => 1 } );
    AddIssue( $patron, $withdrawn_item->barcode );
    t::lib::Mocks::mock_preference( 'BlockReturnOfWithdrawnItems', 1 );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $withdrawn_item->id,
            library_id => $library->branchcode,
        }
    )->status_is(403)->json_is( '/error_code' => 'checkin_blocked' );

    $schema->storage->txn_rollback;
};

subtest 'add - barcode filtering' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode, barcode => 'BC42383FILTER' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );
    AddIssue( $patron, $item->barcode );

    t::lib::Mocks::mock_preference( 'itemBarcodeInputFilter', '' );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            external_id => 'BC42383 FILTER',
            library_id  => $library->branchcode,
        }
    )->status_is( 404, 'Barcode not found without itemBarcodeInputFilter' );

    t::lib::Mocks::mock_preference( 'itemBarcodeInputFilter', 'whitespace' );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            external_id => ' BC42383 FILTER ',
            library_id  => $library->branchcode,
        }
    )->status_is( 200, 'Barcode is filtered with itemBarcodeInputFilter' )->json_is( '/item_id' => $item->id );

    $schema->storage->txn_rollback;
};

subtest 'add - holds queue update' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron       = $builder->build_object( { class => 'Koha::Patrons' } );
    my $other_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library      = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my @enqueued;
    my $jobs_mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $jobs_mock->mock( 'enqueue', sub { push @enqueued, $_[1]->{biblio_ids}; return 1; } );

    my $item = $builder->build_sample_item( { library => $library->branchcode } );

    # RealTimeHoldsQueue disabled
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );
    AddIssue( $patron, $item->barcode );
    @enqueued = ();

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200);
    is( scalar @enqueued, 0, 'Holds queue not updated when RealTimeHoldsQueue is disabled' );

    # RealTimeHoldsQueue enabled, the item is returned
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );
    AddIssue( $patron, $item->barcode );
    @enqueued = ();

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200);
    is_deeply( \@enqueued, [ [ $item->biblionumber ] ], 'Holds queue updated for the returned item' );

    # RealTimeHoldsQueue enabled, not checked out and no hold: nothing returned
    @enqueued = ();
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => { 'x-koha-override' => 'not_issued' } => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200);
    is( scalar @enqueued, 0, 'Holds queue not updated when nothing was returned' );

    # RealTimeHoldsQueue enabled, not checked out but a hold is found
    AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $other_patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );
    @enqueued = ();
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => { 'x-koha-override' => 'not_issued' } => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200)->json_has('/hold_id');
    is_deeply(
        \@enqueued, [ [ $item->biblionumber ] ],
        'Holds queue updated when a hold is found, as it may be dismissed'
    );

    # Cancelling the hold found updates the holds queue (Koha::Hold->cancel)
    my $checkin_id = $t->tx->res->json('/checkin_id');
    my $token      = $t->tx->res->json('/action_tokens/hold_cancellation');
    @enqueued = ();
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins/$checkin_id/hold_cancellation?action_token=$token" => json => {} )
        ->status_is(201);
    is_deeply( \@enqueued, [ [ $item->biblionumber ] ], 'Holds queue updated when the hold is cancelled' );

    $schema->storage->txn_rollback;
};

subtest 'checkin blocked if exempt fine requested but permissions do not allow' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $password = 'thePassword123';

    # A librarian with circulate_remaining_permissions but WITHOUT
    # updatecharges/writeoff
    my $plain_librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**1 } } );
    $plain_librarian->set_password( { password => $password, skip_validation => 1 } );
    my $plain_userid = $plain_librarian->userid;

    # A librarian with circulate_remaining_permissions AND the granular
    # updatecharges/writeoff permission
    my $writeoff_librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**1 } } );
    $writeoff_librarian->set_password( { password => $password, skip_validation => 1 } );
    my $writeoff_userid = $writeoff_librarian->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $writeoff_librarian->borrowernumber,
                module_bit     => 10,                                    # updatecharges
                code           => 'writeoff',
            }
        }
    );

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Helper: check the item out and slap an outstanding OVERDUE fine on it,
    # so the return has a real fine that exempt_fine would forgive.
    my $charge_overdue = sub {
        my ($item) = @_;
        AddIssue( $patron, $item->barcode, dt_from_string->subtract( days => 14 ) );
        my $line = Koha::Account->new( { patron_id => $patron->borrowernumber } )->add_debit(
            {
                amount     => 5,
                type       => 'OVERDUE',
                item_id    => $item->id,
                interface  => 'commandline',
                library_id => $library->branchcode,
            }
        );
        $line->status('UNRETURNED')->store;
        return $line;
    };

    # Scenario 1: exempt_fine requested WITHOUT the writeoff permission
    my $item1     = $builder->build_sample_item( { library => $library->branchcode } );
    my $overdue_1 = $charge_overdue->($item1);

    $t->post_ok(
        "//$plain_userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item1->id,
            library_id  => $library->branchcode,
            exempt_fine => Mojo::JSON->true,
        }
    )->status_is(403)->json_is( '/error_code' => 'no_permission_for_exempt_fine' );

    $overdue_1->discard_changes;
    is( $overdue_1->amountoutstanding + 0, 5, 'The fine is left outstanding when the operator lacks writeoff' );

    # The item was not checked in either, since the request was rejected
    ok( Koha::Checkouts->find( { itemnumber => $item1->id } ), 'The item remains checked out' );

    # Scenario 2: exempt_fine requested WITH the writeoff permission
    my $item2     = $builder->build_sample_item( { library => $library->branchcode } );
    my $overdue_2 = $charge_overdue->($item2);

    $t->post_ok(
        "//$writeoff_userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item2->id,
            library_id  => $library->branchcode,
            exempt_fine => Mojo::JSON->true,
        }
    )->status_is(200)->json_has('/checkin_id');

    $overdue_2->discard_changes;
    is( $overdue_2->amountoutstanding + 0, 0, 'The fine is forgiven when the operator holds writeoff' );

    ok( !Koha::Checkouts->find( { itemnumber => $item2->id } ), 'The item was checked in' );

    $schema->storage->txn_rollback;
};

subtest 'add - return_date and dropbox_mode' => sub {

    plan tests => 24;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Check in with explicit return_date
    my $item = $builder->build_sample_item( { library => $library->branchcode } );
    AddIssue( $patron, $item->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => '2025-01-15T10:00:00',
        }
    )->status_is(200)->json_has('/checkin_id');
    is(
        Koha::Old::Checkouts->search( { itemnumber => $item->id } )->last->returndate,
        '2025-01-15 10:00:00', 'The return date and time are recorded'
    );

    # The return date cannot be in the future
    AddIssue( $patron, $item->barcode );
    my $future = dt_from_string->add( hours => 1 );
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => $future->strftime('%FT%T'),
        }
    )->status_is(400)->json_is( '/error_code' => 'return_date_in_future' );
    ok( $item->checkout, 'The item is still checked out' );

    # The offset is taken into account
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => Koha::DateTime::Format::RFC3339->format_datetime($future),
        }
    )->status_is(400)->json_is( '/error_code' => 'return_date_in_future' );

    # Not a date-time
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => '2025-01-15',
        }
    )->status_is(400);
    ok( $item->checkout, 'The item is still checked out' );

    # A valid date-time that cannot be parsed
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => '2025-01-15T10:00:00.123Z',
        }
        )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_parameter_value' )
        ->json_is( '/path'       => '/body/return_date' );
    ok( $item->checkout, 'The item is still checked out' );

    # Check in with dropbox_mode
    my $item2 = $builder->build_sample_item( { library => $library->branchcode } );
    AddIssue( $patron, $item2->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id      => $item2->id,
            library_id   => $library->branchcode,
            dropbox_mode => 1,
        }
    )->status_is(200)->json_has('/checkin_id');

    # dropbox_mode takes precedence over return_date
    my $item3 = $builder->build_sample_item( { library => $library->branchcode } );
    AddIssue( $patron, $item3->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id      => $item3->id,
            library_id   => $library->branchcode,
            return_date  => '2025-06-01T12:00:00',
            dropbox_mode => 1,
        }
    )->status_is(200);

    $schema->storage->txn_rollback;
};

subtest 'add - post-checkin messages' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Check in a lost item - should get was_lost message
    my $lost_item = $builder->build_sample_item( { library => $library->branchcode } );
    AddIssue( $patron, $lost_item->barcode );
    $lost_item->itemlost(1)->store;

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $lost_item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200)->json_has('/checkin_id');

    # Verify was_lost message is present somewhere in the messages array
    my $messages = $t->tx->res->json('/messages');
    ok( ( grep { $_->{message} eq 'was_lost' } @$messages ), 'was_lost message present' );

    # Check in item not checked out - our add() requires confirmation for
    # the not_issued case (we keep the 24401 confirmation flow), so it
    # returns 412 with a confirmation_required error rather than checking
    # in directly.
    my $free_item = $builder->build_sample_item( { library => $library->branchcode } );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $free_item->id,
            library_id => $library->branchcode,
        }
    )->status_is(412)->json_is( '/error_code' => 'confirmation_required' );

    # ... unless the caller overrides the not_issued confirmation, in which
    # case the check-in is recorded directly (matching the legacy behaviour).
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => { 'x-koha-override' => 'not_issued' } => json => {
            item_id    => $free_item->id,
            library_id => $library->branchcode,
        }
    )->status_is( 200, 'not_issued confirmation overridden -> checked in directly' );

    $schema->storage->txn_rollback;
};

subtest 'add - post-return processing' => sub {

    plan tests => 27;

    $schema->storage->txn_begin;

    # The checkin library defaults to the librarian's library
    my $library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $librarian = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 2, branchcode => $library->branchcode } } );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron        = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $to_library    = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $librarian->borrowernumber } );
    t::lib::Mocks::mock_preference( 'UseRecalls', 'off' );

    my $new_held_item = sub {
        my $item = $builder->build_sample_item( { library => $library->branchcode } );
        AddIssue( $patron, $item->barcode );
        my $hold_id = AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $librarian->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => 1,
            }
        );
        return ( $item, Koha::Holds->find($hold_id) );
    };

    # The patron's checkouts count can be embedded
    my $counted_item = $builder->build_sample_item( { library => $library->branchcode } );
    AddIssue( $patron, $counted_item->barcode );
    my $current_count = $patron->checkouts->count - 1;
    $t->post_ok( "//$userid:$password\@/api/v1/checkins" =>
            { 'x-koha-embed' => 'checkout,checkout.patron,checkout.patron.checkouts+count' } => json =>
            { item_id        => $counted_item->id } )
        ->status_is(200)
        ->json_is( '/checkout/patron/checkouts_count' => $current_count );

    # HoldsAutoFill disabled: the hold is left for the librarian to confirm
    t::lib::Mocks::mock_preference( 'HoldsAutoFill', 0 );
    my ( $item, $hold ) = $new_held_item->();

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => { item_id => $item->id } )->status_is(200);
    my $messages = $t->tx->res->json('/messages');
    ok( ( grep { $_->{message} eq 'hold_found' } @$messages ),        'hold_found message present' );
    ok( !( grep { $_->{message} eq 'hold_auto_filled' } @$messages ), 'No hold_auto_filled message' );
    $hold->discard_changes;
    ok( !$hold->is_waiting, 'Hold not set waiting without HoldsAutoFill' );

    # HoldsAutoFill enabled: the hold is filled on checkin
    t::lib::Mocks::mock_preference( 'HoldsAutoFill', 1 );
    ( $item, $hold ) = $new_held_item->();

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => { item_id => $item->id } )->status_is(200);
    $messages = $t->tx->res->json('/messages');
    my ($auto_filled) = grep { $_->{message} eq 'hold_auto_filled' } @$messages;
    ok( $auto_filled, 'hold_auto_filled message present' );
    is( $auto_filled->{payload}->{reserve_id}, $hold->id, 'hold_auto_filled payload carries the hold id' );
    $hold->discard_changes;
    ok( $hold->is_waiting, 'Hold set waiting with HoldsAutoFill' );

    # Wrong transfer: the transfer is replaced, starting from the checkin library
    my $transfer_item = $builder->build_sample_item( { library => $other_library->branchcode } );
    my $old_transfer  = $transfer_item->request_transfer( { to => $to_library, reason => 'Manual' } );
    $old_transfer->transit;

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => { 'x-koha-override' => 'not_issued' } => json =>
            { item_id => $transfer_item->id } )->status_is(200);
    $messages = $t->tx->res->json('/messages');
    ok( ( grep { $_->{message} eq 'wrong_transfer' } @$messages ), 'wrong_transfer message present' );
    my $transfer_id = $t->tx->res->json('/transfer_id');
    ok( $transfer_id, 'Checkin linked to a transfer' );
    my $new_transfer = Koha::Item::Transfers->find($transfer_id);
    is( $new_transfer->frombranch, $library->branchcode,    'New transfer starts at the checkin library' );
    is( $new_transfer->tobranch,   $to_library->branchcode, 'New transfer keeps the original destination' );
    $old_transfer->discard_changes;
    is( $old_transfer->cancellation_reason, 'WrongTransfer', 'Original transfer cancelled as WrongTransfer' );

    # Bundle verification: missing items are marked lost and reported
    t::lib::Mocks::mock_preference( 'BundleLostValue', 2 );
    my $host    = $builder->build_sample_item( { library => $library->branchcode } );
    my $present = $builder->build_sample_item( { library => $library->branchcode } );
    my $missing = $builder->build_sample_item( { library => $library->branchcode } );
    $host->add_to_bundle($present);
    $host->add_to_bundle($missing);
    AddIssue( $patron, $host->barcode );

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => { item_id => $host->id } )->status_is(412);
    my $token = $t->tx->res->json('/confirmation_token');

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins?confirmation=$token" => json => {
            item_id                  => $host->id,
            verified_bundle_barcodes => [ $present->barcode ],
        }
    )->status_is(200);
    $messages = $t->tx->res->json('/messages');
    my ($missing_msg) = grep { $_->{message} eq 'bundle_missing_items' } @$messages;
    ok( $missing_msg, 'bundle_missing_items message present' );
    is_deeply(
        [ map { $_->{item_id} } @{ $missing_msg->{payload}->{items} } ], [ $missing->itemnumber ],
        'Missing item reported'
    );
    $missing->discard_changes;
    is( $missing->itemlost, 2, 'Missing item marked lost' );

    $schema->storage->txn_rollback;
};

subtest 'add - HoldsAutoFill failure' => sub {

    plan tests => 20;

    $schema->storage->txn_begin;

    my $library   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $librarian = $builder->build_object(
        { class => 'Koha::Patrons', value => { flags => 2, branchcode => $library->branchcode } } );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $librarian->borrowernumber } );
    t::lib::Mocks::mock_preference( 'UseRecalls',         'off' );
    t::lib::Mocks::mock_preference( 'HoldsAutoFill',      1 );
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    my @enqueued;
    my $jobs_mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $jobs_mock->mock( 'enqueue', sub { push @enqueued, $_[1]->{biblio_ids}; return 1; } );

    my $exception;
    my $checkin_mock = Test::MockModule->new('Koha::Checkin');
    $checkin_mock->mock( 'confirm_hold', sub { $exception->(); } );

    my $new_held_item = sub {
        my $item = $builder->build_sample_item( { library => $library->branchcode } );
        AddIssue( $patron, $item->barcode );
        my $hold_id = AddReserve(
            {
                branchcode     => $library->branchcode,
                borrowernumber => $librarian->borrowernumber,
                biblionumber   => $item->biblionumber,
                priority       => 1,
            }
        );
        return ( $item, Koha::Holds->find($hold_id) );
    };

    my %cases = (
        hold_not_found   => sub { Koha::Exceptions::Checkin::HoldNotFound->throw('The hold no longer exists') },
        item_checked_out => sub { Koha::Exceptions::Checkin::ItemCheckedOut->throw('Checked out') },
    );

    for my $error_code ( sort keys %cases ) {
        $exception = $cases{$error_code};
        my ( $item, $hold ) = $new_held_item->();
        @enqueued = ();

        $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => { item_id => $item->id } )
            ->status_is( 200, "$error_code: the check-in is not failed" );
        my $messages = $t->tx->res->json('/messages');
        my ($failed) = grep { $_->{message} eq 'hold_auto_fill_failed' } @$messages;
        ok( $failed, "$error_code: hold_auto_fill_failed message present" );
        is( $failed->{type},                  'warning',   "$error_code: reported as a warning" );
        is( $failed->{payload}->{error_code}, $error_code, "$error_code: error_code in the payload" );
        is( $failed->{payload}->{reserve_id}, $hold->id,   "$error_code: reserve_id in the payload" );
        ok( !( grep { $_->{message} eq 'hold_auto_filled' } @$messages ), "$error_code: no hold_auto_filled message" );
        is_deeply( \@enqueued, [ [ $item->biblionumber ] ], "$error_code: holds queue still updated" );
        $item->discard_changes;
        ok( !$item->onloan, "$error_code: the item has been checked in" );
    }

    # Unexpected errors are not swallowed
    $exception = sub { die "Something unexpected\n" };
    my ($item) = $new_held_item->();
    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => { item_id => $item->id } )
        ->status_is( 500, q{Unexpected exceptions are rethrown} );

    $schema->storage->txn_rollback;
};

subtest 'sub-resource confirmation endpoints' => sub {

    plan tests => 48;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => 'pass000', skip_validation => 1 } );

    my $checkin_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $pickup_library  = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv(
        { branchcode => $checkin_library->branchcode, borrowernumber => $librarian->borrowernumber } );
    t::lib::Mocks::mock_preference( 'UseRecalls', 0 );

    # -- hold_confirmation: not found
    $t->post_ok("//$userid:$password\@/api/v1/checkins/999999999/hold_confirmation?action_token=x")->status_is(404);

    # -- hold_confirmation: no hold (400)
    my $item_no_hold = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    AddIssue( $patron, $item_no_hold->barcode );
    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json =>
            { item_id => $item_no_hold->id, library_id => $checkin_library->branchcode } )->status_is(200);
    my $checkin_no_hold_id = $t->tx->res->json('/checkin_id');

    my $token = action_token( Koha::Checkins->find($checkin_no_hold_id), 'hold_confirmation', $librarian );
    $t->post_ok("//$userid:$password\@/api/v1/checkins/$checkin_no_hold_id/hold_confirmation?action_token=$token")
        ->status_is(400)
        ->json_is( q{/error_code} => q{no_hold_associated} );

    # -- hold_confirmation: same library (set to waiting)
    my $item = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    AddIssue( $patron, $item->barcode );

    my $reserve_id = AddReserve(
        {
            branchcode     => $checkin_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json =>
            { item_id => $item->id, library_id => $checkin_library->branchcode } )->status_is(200);
    my $checkin_id = $t->tx->res->json('/checkin_id');
    $token = $t->tx->res->json('/action_tokens/hold_confirmation');

    $t->post_ok("//$userid:$password\@/api/v1/checkins/$checkin_id/hold_confirmation?action_token=$token")
        ->status_is(201)
        ->header_is( 'Location' => "/api/v1/checkins/$checkin_id/hold_confirmation" );

    my $hold = Koha::Holds->find($reserve_id);
    is( $hold->found, 'W', 'Hold set to waiting after hold_confirmation' );

    # -- hold_confirmation: item checked out again in the meantime (409)
    t::lib::Mocks::mock_preference( 'HoldsAutoFill', 0 );
    my $item_on_loan = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    AddIssue( $patron, $item_on_loan->barcode );

    my $reserve_id_on_loan = AddReserve(
        {
            branchcode     => $pickup_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item_on_loan->biblionumber,
            itemnumber     => $item_on_loan->itemnumber,
            priority       => 1,
        }
    );

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json =>
            { item_id => $item_on_loan->id, library_id => $checkin_library->branchcode } )->status_is(200);
    my $checkin_on_loan_id = $t->tx->res->json('/checkin_id');
    $token = $t->tx->res->json('/action_tokens/hold_confirmation');

    my $other_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    AddIssue( $other_patron, $item_on_loan->barcode );

    $t->post_ok("//$userid:$password\@/api/v1/checkins/$checkin_on_loan_id/hold_confirmation?action_token=$token")
        ->status_is(409)
        ->json_is( '/error_code' => 'item_checked_out' );

    # -- hold_confirmation: the hold vanished in the meantime (409)
    # Drop the loan (without recording a new check-in) so the item is no longer
    # checked out, and the hold path is reached
    $item_on_loan->checkout->delete;
    {
        my $checkin_mock = Test::MockModule->new('Koha::Checkin');
        $checkin_mock->mock( 'ModReserveAffect', sub { return; } );
        $t->post_ok("//$userid:$password\@/api/v1/checkins/$checkin_on_loan_id/hold_confirmation?action_token=$token")
            ->status_is(409)
            ->json_is( '/error_code' => 'hold_not_found' );
    }

    is( Koha::Holds->find($reserve_id_on_loan)->found,          undef, 'Hold left pending' );
    is( Koha::Checkins->find($checkin_on_loan_id)->transfer_id, undef, 'No transfer created' );

    # -- hold_cancellation
    my $item2 = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    AddIssue( $patron, $item2->barcode );

    my $reserve_id2 = AddReserve(
        {
            branchcode     => $checkin_library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item2->biblionumber,
            itemnumber     => $item2->itemnumber,
            priority       => 1,
        }
    );

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json =>
            { item_id => $item2->id, library_id => $checkin_library->branchcode } )->status_is(200);
    my $checkin_id2 = $t->tx->res->json('/checkin_id');
    $token = $t->tx->res->json('/action_tokens/hold_cancellation');

    warning_like {
        $t->post_ok(
            "//$userid:$password\@/api/v1/checkins/$checkin_id2/hold_cancellation?action_token=$token" => json =>
                { reason => 'PATRON_REQUEST' } )
            ->status_is(201)
            ->header_is( 'Location' => "/api/v1/checkins/$checkin_id2/hold_cancellation" );
    }
    qr/HOLD_CANCELLATION/, 'Warning about missing letter template expected';

    is( Koha::Holds->find($reserve_id2), undef, 'Hold cancelled' );

    # -- transfer_confirmation
    my $item3     = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    my $to_branch = $builder->build_object( { class => 'Koha::Libraries' } );
    my $transfer  = $item3->request_transfer( { to => $to_branch, reason => 'Manual' } );

    my $checkin3 = Koha::Checkin->new(
        {
            item_id     => $item3->itemnumber,
            user_id     => $librarian->borrowernumber,
            library_id  => $checkin_library->branchcode,
            transfer_id => $transfer->id,
        }
    )->store;

    $token = $checkin3->action_tokens( { user => $librarian } )->{transfer_confirmation};
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins/" . $checkin3->id . "/transfer_confirmation?action_token=$token" )
        ->status_is(201)
        ->header_is( 'Location' => "/api/v1/checkins/" . $checkin3->id . "/transfer_confirmation" );

    $transfer->discard_changes;
    ok( $transfer->datesent, 'Transfer set in transit' );

    # -- transfer_confirmation without a transfer (AutomaticItemReturn disabled)
    my $item5    = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    my $checkin5 = Koha::Checkin->new(
        {
            item_id    => $item5->itemnumber,
            user_id    => $librarian->borrowernumber,
            library_id => $checkin_library->branchcode,
        }
    )->store;
    $token = action_token( $checkin5, 'transfer_confirmation', $librarian );
    my $checkin5_url =
        "//$userid:$password\@/api/v1/checkins/" . $checkin5->id . "/transfer_confirmation?action_token=$token";

    $t->post_ok($checkin5_url)
        ->status_is( 400, q{No transfer and no destination} )
        ->json_is( q{/error_code} => q{no_transfer_associated} );

    $t->post_ok( $checkin5_url => json => { to_library_id => 'NOT_A_LIBRARY' } )
        ->status_is( 400, q{Destination library does not exist} )
        ->json_is( q{/error_code} => q{invalid_parameter_value} );

    $t->post_ok( $checkin5_url => json => { to_library_id => $to_branch->branchcode, reason => 'ReturnToHome' } )
        ->status_is( 201, 'Transfer requested to the passed library' );

    $checkin5->discard_changes;
    is( $checkin5->transfer->tobranch, $to_branch->branchcode, 'Transfer goes to the passed library' );
    ok( $checkin5->transfer->datesent, 'Requested transfer set in transit' );

    # -- transfer_cancellation
    my $item4     = $builder->build_sample_item( { library => $checkin_library->branchcode } );
    my $transfer4 = $item4->request_transfer( { to => $to_branch, reason => 'Manual' } );
    $transfer4->transit;

    my $checkin4 = Koha::Checkin->new(
        {
            item_id     => $item4->itemnumber,
            user_id     => $librarian->borrowernumber,
            library_id  => $checkin_library->branchcode,
            transfer_id => $transfer4->id,
        }
    )->store;

    $token = $checkin4->action_tokens( { user => $librarian } )->{transfer_cancellation};
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins/" . $checkin4->id . "/transfer_cancellation?action_token=$token" )
        ->status_is(201)
        ->header_is( 'Location' => "/api/v1/checkins/" . $checkin4->id . "/transfer_cancellation" );

    $transfer4->discard_changes;
    ok( $transfer4->datecancelled, 'Transfer cancelled' );

    $schema->storage->txn_rollback;
};

subtest 'recall_confirmation' => sub {

    plan tests => 17;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 0 } } );
    $patron->set_password( { password => 'pass000', skip_validation => 1 } );

    my $checkin_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $pickup_library  = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv(
        { branchcode => $checkin_library->branchcode, borrowernumber => $librarian->borrowernumber } );
    t::lib::Mocks::mock_preference( 'UseRecalls', 1 );

    my $build_recall_checkin = sub {
        my ($pickup) = @_;
        my $item     = $builder->build_sample_item( { library => $checkin_library->branchcode } );
        my $recall   = Koha::Recall->new(
            {
                patron_id         => $patron->borrowernumber,
                created_date      => \'NOW()',
                biblio_id         => $item->biblionumber,
                pickup_library_id => $pickup->branchcode,
                status            => 'requested',
                item_id           => $item->itemnumber,
                item_level        => 1,
            }
        )->store;
        my $checkin = Koha::Checkin->new(
            {
                item_id    => $item->itemnumber,
                user_id    => $librarian->borrowernumber,
                library_id => $checkin_library->branchcode,
                recall_id  => $recall->id,
            }
        )->store;
        return ( $checkin, $recall );
    };

    # Checkin not found
    $t->post_ok("//$userid:$password\@/api/v1/checkins/999999999/recall_confirmation?action_token=x")->status_is(404);

    my ( $checkin, $recall ) = $build_recall_checkin->($checkin_library);

    # No permission
    my $token = action_token( $checkin, 'recall_confirmation', $patron );
    $t->post_ok( "//"
            . $patron->userid
            . ":pass000\@/api/v1/checkins/"
            . $checkin->id
            . "/recall_confirmation?action_token=$token" )->status_is(403);
    $recall->discard_changes;
    ok( $recall->requested, 'Recall untouched without permission' );

    # No recall associated with the checkin
    my $checkin_no_recall = Koha::Checkin->new(
        {
            item_id    => $builder->build_sample_item->itemnumber,
            user_id    => $librarian->borrowernumber,
            library_id => $checkin_library->branchcode,
        }
    )->store;
    $token = action_token( $checkin_no_recall, 'recall_confirmation', $librarian );
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins/" . $checkin_no_recall->id . "/recall_confirmation?action_token=$token" )
        ->status_is(400)
        ->json_is( q{/error_code} => q{no_recall_associated} );

    # Same library: the recall is set waiting
    $token = $checkin->action_tokens( { user => $librarian } )->{recall_confirmation};
    $t->post_ok( "//$userid:$password\@/api/v1/checkins/" . $checkin->id . "/recall_confirmation?action_token=$token" )
        ->status_is(201)
        ->header_is( 'Location' => "/api/v1/checkins/" . $checkin->id . "/recall_confirmation" )
        ->json_is( '/recall_id' => $recall->id );
    $recall->discard_changes;
    ok( $recall->waiting, 'Recall set to waiting at the checkin library' );

    # Different pickup library: the recall is set in transit
    my ( $checkin2, $recall2 ) = $build_recall_checkin->($pickup_library);
    $token = $checkin2->action_tokens( { user => $librarian } )->{recall_confirmation};
    $t->post_ok( "//$userid:$password\@/api/v1/checkins/" . $checkin2->id . "/recall_confirmation?action_token=$token" )
        ->status_is(201);
    $recall2->discard_changes;
    ok( $recall2->in_transit, 'Recall set in transit to the pickup library' );
    is(
        $recall2->item->get_transfer->tobranch, $pickup_library->branchcode,
        'The transfer goes to the pickup library'
    );

    $schema->storage->txn_rollback;
};

subtest 'sub-resource endpoints reject stale checkins' => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $librarian->borrowernumber } );

    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );
    my $transfer = $item->request_transfer( { to => $library, reason => 'Manual' } );
    my $recall   = $builder->build_object( { class => 'Koha::Recalls' } );

    my $stale_checkin = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            library_id  => $library->branchcode,
            hold_id     => $reserve_id,
            transfer_id => $transfer->id,
            recall_id   => $recall->id,
        }
    )->store;

    # The item is checked in again
    Koha::Checkin->new( { item_id => $item->itemnumber, library_id => $library->branchcode } )->store;

    for my $action (
        qw( hold_confirmation hold_cancellation transfer_confirmation transfer_cancellation recall_confirmation))
    {
        my $token = $stale_checkin->action_tokens( { user => $librarian } )->{$action};
        $t->post_ok( "//$userid:$password\@/api/v1/checkins/" . $stale_checkin->id . "/$action?action_token=$token" )
            ->status_is( 409, "$action rejected for a stale checkin" )
            ->json_is( '/error_code' => 'stale_checkin' );
    }

    is( Koha::Holds->find($reserve_id)->found, undef, 'The hold has not been touched' );

    $schema->storage->txn_rollback;
};

subtest q{sub-resource endpoints reject checkins of items checked out again} => sub {

    plan tests => 16;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => q{Koha::Patrons}, value => { flags => 1 } } );
    my $password  = q{thePassword123};
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => q{Koha::Patrons} } );
    my $library = $builder->build_object( { class => q{Koha::Libraries} } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $librarian->borrowernumber } );

    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );
    my $transfer = $item->request_transfer( { to => $library, reason => q{Manual} } );
    my $recall   = $builder->build_object( { class => q{Koha::Recalls} } );

    my $checkin = Koha::Checkin->new(
        {
            item_id     => $item->itemnumber,
            library_id  => $library->branchcode,
            hold_id     => $reserve_id,
            transfer_id => $transfer->id,
            recall_id   => $recall->id,
        }
    )->store;

    # The item is checked out again, without a new check-in
    $builder->build_object(
        {
            class => q{Koha::Checkouts},
            value => { itemnumber => $item->itemnumber, borrowernumber => $patron->borrowernumber }
        }
    );

    for my $action (
        qw( hold_confirmation hold_cancellation transfer_confirmation transfer_cancellation recall_confirmation))
    {
        my $token = $checkin->action_tokens( { user => $librarian } )->{$action};
        $t->post_ok( "//$userid:$password\@/api/v1/checkins/" . $checkin->id . "/$action?action_token=$token" )
            ->status_is( 409, "$action rejected for an item checked out again" )
            ->json_is( q{/error_code} => q{item_checked_out} );
    }

    is( Koha::Holds->find($reserve_id)->found, undef, q{The hold has not been touched} );

    $schema->storage->txn_rollback;
};

subtest q{add() cancels the waiting holds with a cancellation request} => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => q{Koha::Patrons}, value => { flags => 2**1 } } );
    my $password  = q{thePassword123};
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => q{Koha::Patrons} } );
    my $library = $builder->build_object( { class => q{Koha::Libraries} } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    my $hold = $builder->build_object(
        {
            class => q{Koha::Holds},
            value => {
                borrowernumber => $patron->borrowernumber,
                biblionumber   => $item->biblionumber,
                itemnumber     => $item->itemnumber,
                branchcode     => $library->branchcode,
                found          => q{W},
                priority       => 0,
            }
        }
    );
    $hold->add_cancellation_request;

    my $borrower = $builder->build_object( { class => q{Koha::Patrons} } );
    AddIssue( $borrower, $item->barcode, undef, undef, undef, undef, { ignore_reserves => 1 } );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200);

    ok( !Koha::Holds->find( $hold->id ), q{The hold with a cancellation request has been cancelled} );

    $schema->storage->txn_rollback;
};

subtest 'sub-resource endpoints require a valid action token' => sub {

    plan tests => 26;

    $schema->storage->txn_begin;

    my $password = 'thePassword123';

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $other_librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 1 } } );

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $librarian->borrowernumber } );
    t::lib::Mocks::mock_preference( 'HoldsAutoFill', 0 );

    # A checkin without follow-up actions gets no tokens
    AddIssue( $patron, $item->barcode );
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => { item_id => $item->id, library_id => $library->branchcode }
    )->status_is(200)->json_is( '/action_tokens' => {} );

    # A checkin that finds a hold gets tokens for the hold actions
    my $reserve_id = AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            itemnumber     => $item->itemnumber,
            priority       => 1,
        }
    );
    AddIssue( $builder->build_object( { class => 'Koha::Patrons' } ), $item->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => { item_id => $item->id, library_id => $library->branchcode }
        )
        ->status_is(200)
        ->json_has('/action_tokens/hold_confirmation')
        ->json_has('/action_tokens/hold_cancellation')
        ->json_hasnt('/action_tokens/recall_confirmation');

    my $checkin_id   = $t->tx->res->json('/checkin_id');
    my $tokens       = $t->tx->res->json('/action_tokens');
    my $endpoint_url = "//$userid:$password\@/api/v1/checkins/$checkin_id/hold_confirmation";

    $t->post_ok($endpoint_url)->status_is( 400, 'Missing action token' );

    $t->post_ok("$endpoint_url?action_token=invalid.token.value")
        ->status_is( 403, 'Invalid action token' )
        ->json_is( '/error_code' => 'invalid_action_token' );

    $t->post_ok("$endpoint_url?action_token=$tokens->{hold_cancellation}")
        ->status_is( 403, 'Token for another action' )
        ->json_is( '/error_code' => 'invalid_action_token' );

    my $other_user_token =
        Koha::Checkins->find($checkin_id)->action_tokens( { user => $other_librarian } )->{hold_confirmation};
    $t->post_ok("$endpoint_url?action_token=$other_user_token")
        ->status_is( 403, 'Token for another user' )
        ->json_is( '/error_code' => 'invalid_action_token' );

    {
        my $jwt_mock = Test::MockModule->new('Mojo::JWT');
        $jwt_mock->mock( 'now', sub { time + Koha::Checkin::ACTION_TOKEN_EXPIRY_SECONDS + 60 } );
        $t->post_ok("$endpoint_url?action_token=$tokens->{hold_confirmation}")
            ->status_is( 403, 'Expired action token' )
            ->json_is( '/error_code' => 'invalid_action_token' );
    }

    is( Koha::Holds->find($reserve_id)->found, undef, 'The hold has not been touched' );

    $t->post_ok("$endpoint_url?action_token=$tokens->{hold_confirmation}")->status_is( 201, 'Valid action token' );
    is( Koha::Holds->find($reserve_id)->found, 'W', 'The hold is waiting' );

    $schema->storage->txn_rollback;
};

subtest 'hold_cancellation - forgive_hold_fees' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    my $password = 'thePassword123';

    my $plain_librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**1 } } );
    $plain_librarian->set_password( { password => $password, skip_validation => 1 } );
    my $plain_userid = $plain_librarian->userid;

    my $writeoff_librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**1 } } );
    $writeoff_librarian->set_password( { password => $password, skip_validation => 1 } );
    my $writeoff_userid = $writeoff_librarian->userid;
    $builder->build(
        {
            source => 'UserPermission',
            value  => {
                borrowernumber => $writeoff_librarian->borrowernumber,
                module_bit     => 10,                                    # updatecharges
                code           => 'writeoff',
            }
        }
    );

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode, borrowernumber => $writeoff_librarian->id } );
    t::lib::Mocks::mock_preference( 'ExpireReservesMaxPickUpDelayCharge', 5 );
    Koha::CirculationRules->search( { rule_name => 'expire_reserves_charge' } )->delete;

    # A checkin that found a waiting hold
    my $build_checkin = sub {
        my $item = $builder->build_sample_item( { library => $library->branchcode } );
        my $hold = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $item->biblionumber,
                    itemnumber     => $item->itemnumber,
                    branchcode     => $library->branchcode,
                    found          => 'W',
                    priority       => 0,
                }
            }
        );
        my $checkin = Koha::Checkin->new(
            {
                item_id    => $item->itemnumber,
                user_id    => $writeoff_librarian->borrowernumber,
                library_id => $library->branchcode,
                hold_id    => $hold->id,
            }
        )->store;
        return ( $checkin, $hold );
    };
    my $expired_hold_fees = sub {
        return $patron->account->lines->search( { debit_type_code => 'RESERVE_EXPIRED' } )->count;
    };

    my ( $checkin, $hold ) = $build_checkin->();

    my $token = $checkin->action_tokens( { user => $plain_librarian } )->{hold_cancellation};
    $t->post_ok( "//$plain_userid:$password\@/api/v1/checkins/"
            . $checkin->id
            . "/hold_cancellation?action_token=$token" => json => { forgive_hold_fees => Mojo::JSON->true } )
        ->status_is(403)
        ->json_is( '/error_code'                       => 'no_permission_for_forgive_hold_fees' )
        ->json_is( '/policy/module'                    => 'checkin' )
        ->json_is( '/policy/checkin/forgive_hold_fees' => Mojo::JSON->false );
    ok( Koha::Holds->find( $hold->id ), 'Hold not cancelled without the writeoff permission' );

    $token = $checkin->action_tokens( { user => $writeoff_librarian } )->{hold_cancellation};
    $t->post_ok( "//$writeoff_userid:$password\@/api/v1/checkins/"
            . $checkin->id
            . "/hold_cancellation?action_token=$token" => json => { forgive_hold_fees => Mojo::JSON->true } )
        ->status_is(201);
    is( Koha::Holds->find( $hold->id ), undef, 'Hold cancelled' );
    is( $expired_hold_fees->(),         0,     'No expired hold fee charged when forgiven' );

    ( $checkin, $hold ) = $build_checkin->();

    $token = $checkin->action_tokens( { user => $writeoff_librarian } )->{hold_cancellation};
    $t->post_ok(
        "//$writeoff_userid:$password\@/api/v1/checkins/" . $checkin->id . "/hold_cancellation?action_token=$token" )
        ->status_is(201);
    is( Koha::Holds->find( $hold->id ), undef, 'Hold cancelled' );
    is( $expired_hold_fees->(),         1,     'Expired hold fee charged when not forgiven' );

    $schema->storage->txn_rollback;
};

subtest 'Module policy in policy errors' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    # A librarian WITHOUT updatecharges/writeoff (so exempt_fine is denied),
    # but with circulate_remaining_permissions to reach the endpoint
    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**1 } } );
    my $password  = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );
    t::lib::Mocks::mock_preference( 'UseRecalls',        'opac_and_staff' );
    t::lib::Mocks::mock_preference( 'SpecifyReturnDate', 0 );
    t::lib::Mocks::mock_preference( 'AudioAlerts',       1 );

    AddIssue( $patron, $item->barcode );

    # The responses are validated against the spec, so the policy matches
    # the module_policy definition
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            exempt_fine => Mojo::JSON->true,
        }
        )
        ->status_is(403)
        ->json_is( '/error_code'                     => 'no_permission_for_exempt_fine' )
        ->json_is( '/policy/module'                  => 'checkin' )
        ->json_is( '/policy/global/audio_alerts'     => Mojo::JSON->true )
        ->json_is( '/policy/checkin/exempt_fine'     => Mojo::JSON->false )
        ->json_is( '/policy/checkin/recalls_enabled' => Mojo::JSON->true );

    is_deeply(
        [ sort keys %{ $t->tx->res->json->{policy} } ], [qw( checkin global module )],
        'The policy is the module policy envelope'
    );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => '2026-01-01T10:00:00Z',
        }
        )
        ->status_is(403)
        ->json_is( '/error_code'                         => 'return_date_not_allowed' )
        ->json_is( '/policy/module'                      => 'checkin' )
        ->json_is( '/policy/checkin/specify_return_date' => Mojo::JSON->false );

    ok( Koha::Checkouts->find( { itemnumber => $item->id } ), 'The item remains checked out' );

    # Errors not caused by the policy do not carry it
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            external_id => $item->barcode,
        }
    )->status_is(400)->json_is( '/error_code' => 'mutually_exclusive_parameters' )->json_hasnt('/policy');

    $schema->storage->txn_rollback;
};

subtest 'input validation tests' => sub {

    plan tests => 31;

    $schema->storage->txn_begin;

    my $password = 'thePassword123';

    my $librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**1 } } );
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $other_librarian = $builder->build_object( { class => 'Koha::Patrons', value => { flags => 2**1 } } );
    $other_librarian->set_password( { password => $password, skip_validation => 1 } );
    my $other_userid = $other_librarian->userid;

    my $patron  = $builder->build_object( { class => 'Koha::Patrons' } );
    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );

    # Unknown library
    $t->get_ok( "//$userid:$password\@/api/v1/checkins/availability?item_id=" . $item->id . "&library_id=NOPE" )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_parameter_value' )
        ->json_is( '/path'       => '/query/library_id' );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => 'NOPE',
        }
        )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_parameter_value' )
        ->json_is( '/path'       => '/body/library_id' );

    # Library scope follows the x-koha-library rules (IndependentBranches)
    AddIssue( $patron, $item->barcode );
    t::lib::Mocks::mock_preference( 'IndependentBranches', 1 );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(403)->json_is( '/error_code' => 'library_not_allowed' );

    ok( Koha::Checkouts->find( { itemnumber => $item->id } ), 'The item was not checked in' );

    t::lib::Mocks::mock_preference( 'IndependentBranches', 0 );

    # Defaults to the logged in library
    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => { item_id => $item->id } )
        ->status_is(200)
        ->json_is( '/library_id' => $librarian->branchcode );

    # Items without a barcode cannot be checked in
    my $no_barcode = $builder->build_sample_item( { library => $library->branchcode } );
    $no_barcode->barcode(undef)->store;

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $no_barcode->id,
            library_id => $library->branchcode,
        }
    )->status_is(409)->json_is( '/error_code' => 'item_without_barcode' );

    # return_date and dropbox_mode are covered by the "add - return_date and
    # dropbox_mode" subtest

    # Confirmation tokens are tied to the user, and cannot be tampered with
    my $not_issued = $builder->build_sample_item( { library => $library->branchcode } );
    my $body       = { item_id => $not_issued->id, library_id => $library->branchcode };

    $t->post_ok( "//$userid:$password\@/api/v1/checkins" => json => $body )
        ->status_is(412)
        ->json_has('/confirmation_token');
    my $token = $t->tx->res->json('/confirmation_token');

    $t->post_ok( "//$other_userid:$password\@/api/v1/checkins?confirmation=$token" => json => $body )->status_is(412);

    my $tampered = $token;
    substr( $tampered, -2, 1, substr( $tampered, -2, 1 ) eq 'A' ? 'B' : 'A' );
    $t->post_ok( "//$userid:$password\@/api/v1/checkins?confirmation=$tampered" => json => $body )->status_is(412);

    $t->post_ok( "//$userid:$password\@/api/v1/checkins?confirmation=$token" => json => $body )->status_is(200);

    # The debits created by the check-in can be embedded
    t::lib::Mocks::mock_preference( 'finesMode',              'production' );
    t::lib::Mocks::mock_preference( 'CalculateFinesOnReturn', 1 );
    Koha::CirculationRules->set_rules(
        {
            branchcode   => undef,
            categorycode => undef,
            itemtype     => undef,
            rules        => {
                fine         => 1,
                finedays     => 0,
                firstremind  => 0,
                chargeperiod => 1,
                lengthunit   => 'days',
            }
        }
    );

    my $overdue_item = $builder->build_sample_item( { library => $library->branchcode } );
    AddIssue( $patron, $overdue_item->barcode, dt_from_string->subtract( days => 14 ) );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => { 'x-koha-embed' => 'debits' } => json => {
            item_id    => $overdue_item->id,
            library_id => $library->branchcode,
        }
    )->status_is(200)->json_is( q{/debits/0/type} => q{OVERDUE} );

    is(
        $t->tx->res->json(q{/debits/0/checkin_id}), $t->tx->res->json(q{/checkin_id}),
        q{The debit is linked to the check-in}
    );

    $schema->storage->txn_rollback;
};

subtest 'add() reports a check-in that failed' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => q{Koha::Patrons}, value => { flags => 2**1 } } );
    my $password  = q{thePassword123};
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => q{Koha::Patrons} } );
    my $library = $builder->build_object( { class => q{Koha::Libraries} } );
    my $item    = $builder->build_sample_item( { library => $library->branchcode } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );
    AddIssue( $patron, $item->barcode );

    # The return fails, as when the data is corrupted
    my $circulation_mock = Test::MockModule->new(q{C4::Circulation});
    $circulation_mock->mock( q{MarkIssueReturned}, sub { die qq{Internal details\n} } );

    my $logger = t::lib::Mocks::Logger->new;

    warning_like {
        $t->post_ok(
            "//$userid:$password\@/api/v1/checkins" => json => {
                item_id    => $item->id,
                library_id => $library->branchcode,
            }
        )->status_is(500)->json_is( q{/error_code} => q{checkin_failed} );
    }
    qr{The checkin for the following issue failed}, q{AddReturn warns about the failure};

    unlike( $t->tx->res->body, qr{Internal details}, q{The internal error is not exposed} );
    $logger->error_like( qr{Internal details}, q{The internal error is logged} );
    ok( $item->checkout, q{The item is still checked out} );

    $schema->storage->txn_rollback;
};

subtest 'add() records blocked check-ins' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $librarian = $builder->build_object( { class => q{Koha::Patrons}, value => { flags => 2**1 } } );
    my $password  = q{thePassword123};
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron  = $builder->build_object( { class => q{Koha::Patrons} } );
    my $library = $builder->build_object( { class => q{Koha::Libraries} } );

    t::lib::Mocks::mock_userenv( { branchcode => $library->branchcode } );
    t::lib::Mocks::mock_preference( q{BlockReturnOfWithdrawnItems}, 1 );
    t::lib::Mocks::mock_preference( q{BlockReturnOfLostItems},      1 );
    t::lib::Mocks::mock_preference( q{RecordLocalUseOnReturn},      1 );

    # Withdrawn item, not checked out: the local use is recorded
    my $withdrawn = $builder->build_sample_item( { library => $library->branchcode, withdrawn => 1, localuse => 0 } );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $withdrawn->id,
            library_id => $library->branchcode,
        }
    )->status_is(403)->json_is( q{/error_code} => q{checkin_blocked} )->json_has(q{/checkin_id});

    $withdrawn->discard_changes;
    is( $withdrawn->localuse, 1, q{The local use is recorded} );
    ok(
        Koha::Checkins->find( $t->tx->res->json(q{/checkin_id}) )->local_use,
        q{The check-in is recorded as a local use}
    );

    # Lost item, checked out: the date last seen is updated, the item is not returned
    my $lost = $builder->build_sample_item( { library => $library->branchcode } );
    AddIssue( $patron, $lost->barcode );
    $lost->set( { itemlost => 1, datelastseen => q{2020-01-01} } )->store;

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id    => $lost->id,
            library_id => $library->branchcode,
        }
    )->status_is(403)->json_is( q{/error_code} => q{checkin_blocked} );

    $lost->discard_changes;
    is( $lost->itemlost,                            1,                   q{The item is still lost} );
    is( dt_from_string( $lost->datelastseen )->ymd, dt_from_string->ymd, q{The date last seen is updated} );
    ok( $lost->checkout, q{The item is still checked out} );

    $schema->storage->txn_rollback;
};
