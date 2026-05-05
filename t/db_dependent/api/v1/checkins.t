#!/usr/bin/env perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation qw( AddIssue );
use Koha::Database;

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
        ->json_is( '/error_code' => 'MISSING_OR_WRONG_PARAMETERS' );

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
        ->json_is( '/error_code' => 'CONFIRMATION_REQUIRED' )
        ->json_has('/confirms/NotIssued')
        ->json_has('/confirmation_token');

    # Not checked out - with invalid token
    $t->post_ok(
        "//$userid:$password\@/api/v1/checkins?confirmation=invalid.token.value" => json => {
            item_id    => $item->id,
            library_id => $library->branchcode,
        }
    )->status_is(412)->json_is( '/error_code' => 'CONFIRMATION_REQUIRED' );

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
    )->status_is(403)->json_is( '/error_code' => 'CHECKIN_NOT_AUTHORIZED' );

    $schema->storage->txn_rollback;
};
