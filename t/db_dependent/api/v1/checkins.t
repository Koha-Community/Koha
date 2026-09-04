#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 5;
use Test::Mojo;
use Mojo::JSON;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation qw( AddIssue );
use Koha::Database;
use Koha::Account;
use Koha::Checkouts;
use Koha::CirculationRules;
use Koha::Old::Checkouts;
use Koha::DateUtils qw( dt_from_string );

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
my $t = Test::Mojo->new('Koha::REST::V1');

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

    # Item not checked out — NotIssued confirmation + token
    $t->get_ok( "//$userid:$password\@/api/v1/checkins/availability?item_id="
            . $item->id
            . "&library_id="
            . $library->branchcode )
        ->status_is(200)
        ->json_is( '/blockers' => {} )
        ->json_has('/confirms/NotIssued')
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
            . $library->branchcode )->status_is(200)->json_has('/blockers/BlockedWithdrawn');

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
        ->json_has('/confirms/NotIssued')
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

subtest 'input validation tests' => sub {

    plan tests => 41;

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

    # return_date
    t::lib::Mocks::mock_preference( 'SpecifyReturnDate', 1 );
    AddIssue( $patron, $item->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => 'not a date',
        }
        )
        ->status_is(400)
        ->json_is( '/error_code' => 'invalid_parameter_value' )
        ->json_is( '/path'       => '/body/return_date' );

    my $return_date = dt_from_string->subtract( days => 2 );
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id     => $item->id,
            library_id  => $library->branchcode,
            return_date => $return_date->strftime('%Y-%m-%dT%H:%M:%S'),
        }
    )->status_is(200);

    my $old_checkout =
        Koha::Old::Checkouts->search( { itemnumber => $item->id }, { order_by => { -desc => 'issue_id' } } )->next;
    is( dt_from_string( $old_checkout->returndate )->ymd, $return_date->ymd, 'return_date is used' );

    # dropbox_mode
    AddIssue( $patron, $item->barcode );

    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins" => json => {
            item_id      => $item->id,
            library_id   => $library->branchcode,
            dropbox_mode => Mojo::JSON->true,
        }
    )->status_is(200);

    $old_checkout =
        Koha::Old::Checkouts->search( { itemnumber => $item->id }, { order_by => { -desc => 'issue_id' } } )->next;
    is(
        dt_from_string( $old_checkout->returndate )->ymd, Koha::Checkouts->calculate_dropbox_date()->ymd,
        'dropbox_mode uses the dropbox date'
    );

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
