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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 105;
use Test::MockModule;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use DateTime;

use C4::Context;
use C4::Circulation qw( AddIssue AddReturn CanBookBeIssued );

use Koha::Database;
use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Token;

my $schema = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'RESTBasicAuth', 1 );
my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my $dbh = C4::Context->dbh;

my $librarian = $builder->build_object({
    class => 'Koha::Patrons',
    value => { flags => 2 }
});
my $password = 'thePassword123';
$librarian->set_password({ password => $password, skip_validation => 1 });
my $userid = $librarian->userid;

my $patron = $builder->build_object({
    class => 'Koha::Patrons',
    value => { flags => 0 }
});
my $unauth_password = 'thePassword000';
$patron->set_password({ password => $unauth_password, skip_validattion => 1 });
my $unauth_userid = $patron->userid;
my $patron_id = $patron->borrowernumber;

my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id" )
  ->status_is(200)
  ->json_is([]);

my $notexisting_patron_id = $patron_id + 1;
$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$notexisting_patron_id" )
  ->status_is(200)
  ->json_is([]);

Koha::CirculationRules->set_rules(
    {
        categorycode => undef,
        itemtype     => undef,
        branchcode   => undef,
        rules        => {
            renewalperiod => 7,
            renewalsallowed => 1,
            issuelength => 5,
        }
    }
);

my $item1 = $builder->build_sample_item;
my $item2 = $builder->build_sample_item;
my $item3 = $builder->build_sample_item;
my $item4 = $builder->build_sample_item;

my $date_due = DateTime->now->add(weeks => 2);
my $issue1 = C4::Circulation::AddIssue($patron, $item1->barcode, $date_due);
my $date_due1 = Koha::DateUtils::dt_from_string( $issue1->date_due );
my $issue2 = C4::Circulation::AddIssue($patron, $item2->barcode, $date_due);
my $date_due2 = Koha::DateUtils::dt_from_string( $issue2->date_due );
my $issue3 = C4::Circulation::AddIssue($librarian, $item3->barcode, $date_due);
my $date_due3 = Koha::DateUtils::dt_from_string( $issue3->date_due );
my $issue4 = C4::Circulation::AddIssue($patron, $item4->barcode);
C4::Circulation::AddReturn($item4->barcode, $branchcode);

$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id" )
  ->status_is(200)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => $item1->itemnumber)
  ->json_is('/0/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due1 }) )
  ->json_is('/1/patron_id' => $patron_id)
  ->json_is('/1/item_id' => $item2->itemnumber)
  ->json_is('/1/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due2 }) )
  ->json_hasnt('/2');

# Test checked_in parameter, zero means, the response is same as without it
$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id&checked_in=0" )
  ->status_is(200)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => $item1->itemnumber)
  ->json_is('/0/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due1 }) )
  ->json_is('/1/patron_id' => $patron_id)
  ->json_is('/1/item_id' => $item2->itemnumber)
  ->json_is('/1/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due2 }) )
  ->json_hasnt('/2');

# Test checked_in parameter, one measn, the checked in checkout is in the response too
$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id&checked_in=1" )
  ->status_is(200)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => $item4->itemnumber)
  ->json_hasnt('/1');

$item4->delete;
$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id&checked_in=1" )
  ->status_is(200)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => undef);

$t->get_ok( "//$unauth_userid:$unauth_password@/api/v1/checkouts/" . $issue3->issue_id )
  ->status_is(403)
  ->json_is({ error => "Authorization failure. Missing required permission(s).",
              required_permissions => { circulate => "circulate_remaining_permissions" }
            });

$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id")
  ->status_is(200)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => $item1->itemnumber)
  ->json_is('/0/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due1 }) )
  ->json_is('/1/patron_id' => $patron_id)
  ->json_is('/1/item_id' => $item2->itemnumber)
  ->json_is('/1/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due2 }) )
  ->json_hasnt('/2');

$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id&_per_page=1&_page=1")
  ->status_is(200)
  ->header_is('X-Total-Count', '2')
  ->header_like('Link', qr|rel="next"|)
  ->header_like('Link', qr|rel="first"|)
  ->header_like('Link', qr|rel="last"|)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => $item1->itemnumber)
  ->json_is('/0/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due1 }) )
  ->json_hasnt('/1');

$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id&_per_page=1&_page=2")
  ->status_is(200)
  ->header_is('X-Total-Count', '2')
  ->header_like('Link', qr|rel="prev"|)
  ->header_like('Link', qr|rel="first"|)
  ->header_like('Link', qr|rel="last"|)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => $item2->itemnumber)
  ->json_is('/0/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due2 }) )
  ->json_hasnt('/1');

$t->get_ok( "//$userid:$password@/api/v1/checkouts/" . $issue1->issue_id)
  ->status_is(200)
  ->json_is('/patron_id' => $patron_id)
  ->json_is('/item_id' => $item1->itemnumber)
  ->json_is('/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due1 }) )
  ->json_hasnt('/1');

$t->get_ok( "//$userid:$password@/api/v1/checkouts/" . $issue1->issue_id)
  ->status_is(200)
  ->json_is('/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due1 }) );

$t->get_ok( "//$userid:$password@/api/v1/checkouts/" . $issue2->issue_id)
  ->status_is(200)
  ->json_is('/due_date' => output_pref( { dateformat => "rfc3339", dt => $date_due2 }) );

my $expected_datedue = $date_due
    ->set_time_zone('local')
    ->add(days => 7)
    ->set(hour => 23, minute => 59, second => 0);

$t->post_ok ( "//$userid:$password@/api/v1/checkouts/" . $issue1->issue_id . "/renewal" )
  ->status_is(201)
  ->json_is('/due_date' => output_pref( { dateformat => "rfc3339", dt => $expected_datedue }) )
  ->header_is(Location => "/api/v1/checkouts/" . $issue1->issue_id . "/renewal");

my $renewal = $issue1->renewals->last;
is( $renewal->renewal_type, 'Manual', 'Manual renewal recorded' );

$t->get_ok ( "//$userid:$password@/api/v1/checkouts/" . $issue1->issue_id . "/renewals" )
  ->status_is(200)
  ->json_is('/0/checkout_id' => $issue1->issue_id)
  ->json_is('/0/interface'   => 'api')
  ->json_is('/0/renewer_id'  => $librarian->borrowernumber );

$t->post_ok( "//$unauth_userid:$unauth_password@/api/v1/checkouts/" . $issue3->issue_id . "/renewal" )
  ->status_is(403)
  ->json_is({ error => "Authorization failure. Missing required permission(s).",
              required_permissions => { circulate => "circulate_remaining_permissions" }
            });

$t->get_ok( "//$userid:$password@/api/v1/checkouts/" . $issue2->issue_id . "/allows_renewal")
  ->status_is(200)
  ->json_is({
        allows_renewal   => Mojo::JSON->true,
        max_renewals     => 1,
        unseen_renewals  => 0,
        current_renewals => 0,
        error            => undef
    });

$t->post_ok( "//$userid:$password@/api/v1/checkouts/" . $issue2->issue_id . "/renewal" )
  ->status_is(201)
  ->json_is('/due_date' => output_pref({ dateformat => "rfc3339", dt => $expected_datedue}) )
  ->header_is(Location => "/api/v1/checkouts/" . $issue2->issue_id . "/renewal");


$t->post_ok( "//$userid:$password@/api/v1/checkouts/" . $issue1->issue_id . "/renewal" )
  ->status_is(403)
  ->json_is({ error => 'Renewal not authorized (too_many)' });

$t->get_ok( "//$userid:$password@/api/v1/checkouts/" . $issue2->issue_id . "/allows_renewal")
  ->status_is(200)
  ->json_is({
        allows_renewal   => Mojo::JSON->false,
        max_renewals     => 1,
        unseen_renewals  => 0,
        current_renewals => 1,
        error            => 'too_many'
    });

$schema->storage->txn_rollback;

subtest 'get_availability' => sub {

    plan tests => 29;

    $schema->storage->txn_begin;
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $unauth_password = 'thePassword000';
    $patron->set_password( { password => $unauth_password, skip_validattion => 1 } );
    my $unauth_userid = $patron->userid;
    my $patron_id     = $patron->borrowernumber;

    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};

    my $item1    = $builder->build_sample_item;
    my $item1_id = $item1->id;

    my %issuingimpossible = ();
    my %needsconfirmation = ();
    my %alerts            = ();
    my %messages          = ();
    my $mocked_circ       = Test::MockModule->new('C4::Circulation');
    $mocked_circ->mock(
        'CanBookBeIssued',
        sub {
            return ( \%issuingimpossible, \%needsconfirmation, \%alerts, \%messages );
        }
    );

    $t->get_ok(
        "//$unauth_userid:$unauth_password@/api/v1/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")
        ->status_is(403)->json_is(
        {
            error                => "Authorization failure. Missing required permission(s).",
            required_permissions => { circulate => "circulate_remaining_permissions" }
        }
        );

    # Available
    $t->get_ok("//$userid:$password@/api/v1/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")
        ->status_is(200)->json_is( '/blockers' => {} )->json_is( '/confirms' => {} )->json_is( '/warnings' => {} )
        ->json_has('/confirmation_token');

    # Blocked
    %issuingimpossible = ( GNA => 1 );
    $t->get_ok("//$userid:$password@/api/v1/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")
        ->status_is(200)->json_is( '/blockers' => { GNA => 1 } )->json_is( '/confirms' => {} )
        ->json_is( '/warnings' => {} )->json_has('/confirmation_token');
    %issuingimpossible = ();

    # Warnings/Info
    %alerts   = ( alert1   => "this is an alert" );
    %messages = ( message1 => "this is a message" );
    $t->get_ok("//$userid:$password@/api/v1/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")
        ->status_is(200)->json_is( '/blockers' => {} )->json_is( '/confirms' => {} )
        ->json_is( '/warnings' => { alert1 => "this is an alert", message1 => "this is a message" } )
        ->json_has('/confirmation_token');
    %alerts   = ();
    %messages = ();

    # Needs confirm
    %needsconfirmation = ( confirm1 => 1, confirm2 => 'please' );
    my $token = Koha::Token->new->generate_jwt( { id => $librarian->id . ":" . $item1_id . ":confirm1:confirm2" } );
    $t->get_ok("//$userid:$password@/api/v1/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")
        ->status_is(200)->json_is( '/blockers' => {} )
        ->json_is( '/confirms' => { confirm1 => 1, confirm2 => 'please' } )->json_is( '/warnings' => {} )
        ->json_has('/confirmation_token');
    my $confirmation_token = $t->tx->res->json('/confirmation_token');
    ok(
        Koha::Token->new->check_jwt(
            {
                id    => $librarian->id . ":" . $item1_id . ":confirm1:confirm2",
                token => $confirmation_token
            }
        ),
        'Correct token'
    );
    %needsconfirmation = ();

    subtest 'public availability' => sub {
        plan tests => 18;

        # Available, Not authentication required
        $t->get_ok("/api/v1/public/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")->status_is(200)
            ->json_is( '/blockers' => {} )->json_is( '/confirms' => {} )->json_is( '/warnings' => {} )
            ->json_has('/confirmation_token');

        # Needs confirmation upgrade to blocker
        %needsconfirmation = ( TOO_MANY => 1, ISSUED_TO_ANOTHER => 1 );
        $t->get_ok("/api/v1/public/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")->status_is(200)
            ->json_is( '/blockers' => { TOO_MANY => 1, ISSUED_TO_ANOTHER => 1 } )->json_is( '/confirms' => {} )
            ->json_is( '/warnings' => {} )->json_has('/confirmation_token');
        %needsconfirmation = ();

        # Remove personal information from public endpoint
        %issuingimpossible = (
            issued_borrowernumber => 'private',
            issued_cardnumber     => 'private',
            issued_firstname      => 'private',
            issued_surname        => 'private',
            resborrowernumber     => 'private',
            resbranchcode         => 'private',
            rescardnumber         => 'private',
            reserve_id            => 'private',
            resfirstname          => 'private',
            resreservedate        => 'private',
            ressurname            => 'private',
            item_notforloan       => 'private'
        );
        %alerts = (
            issued_borrowernumber => 'private',
            issued_cardnumber     => 'private',
            issued_firstname      => 'private',
            issued_surname        => 'private',
            resborrowernumber     => 'private',
            resbranchcode         => 'private',
            rescardnumber         => 'private',
            reserve_id            => 'private',
            resfirstname          => 'private',
            resreservedate        => 'private',
            ressurname            => 'private',
            item_notforloan       => 'private'
        );

        %needsconfirmation = (
            issued_borrowernumber => 'private',
            issued_cardnumber     => 'private',
            issued_firstname      => 'private',
            issued_surname        => 'private',
            resborrowernumber     => 'private',
            resbranchcode         => 'private',
            rescardnumber         => 'private',
            reserve_id            => 'private',
            resfirstname          => 'private',
            resreservedate        => 'private',
            ressurname            => 'private',
            item_notforloan       => 'private'
        );
        $t->get_ok("/api/v1/public/checkouts/availability?item_id=$item1_id&patron_id=$patron_id")->status_is(200)
            ->json_is( '/blockers' => {} )->json_is( '/confirms' => {} )->json_is( '/warnings' => {} )
            ->json_has('/confirmation_token');
        %issuingimpossible = ();
        %alerts            = ();
        %needsconfirmation = ();
    };

    $schema->storage->txn_rollback;
};

subtest 'add checkout' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;
    my $librarian = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2 }
        }
    );
    my $password = 'thePassword123';
    $librarian->set_password( { password => $password, skip_validation => 1 } );
    my $userid = $librarian->userid;

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 0 }
        }
    );
    my $unauth_password = 'thePassword000';
    $patron->set_password( { password => $unauth_password, skip_validattion => 1 } );
    my $unauth_userid = $patron->userid;
    my $patron_id     = $patron->borrowernumber;

    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};

    my $item1    = $builder->build_sample_item;
    my $item1_id = $item1->id;

    my %issuingimpossible = ();
    my %needsconfirmation = ();
    my %alerts            = ();
    my %messages          = ();
    my $mocked_circ       = Test::MockModule->new('C4::Circulation');
    $mocked_circ->mock(
        'CanBookBeIssued',
        sub {
            return ( \%issuingimpossible, \%needsconfirmation, \%alerts, \%messages );
        }
    );

    $t->post_ok( "//$unauth_userid:$unauth_password@/api/v1/checkouts" => json =>
            { item_id => $item1_id, patron_id => $patron_id } )->status_is(403)->json_is(
        {
            error                => "Authorization failure. Missing required permission(s).",
            required_permissions => { circulate => "circulate_remaining_permissions" }
        }
            );

    $t->post_ok( "//$userid:$password@/api/v1/checkouts" => json => { item_id => $item1_id, patron_id => $patron_id } )
        ->status_is(201);

    # Needs confirm
    %needsconfirmation = ( confirm1 => 1, confirm2 => 'please' );
    $t->post_ok(
        "//$userid:$password@/api/v1/checkouts" => json => {
            item_id   => $item1_id,
            patron_id => $patron_id,
        }
    )->status_is(412);

    my $token = Koha::Token->new->generate_jwt( { id => $librarian->id . ":" . $item1_id . ":confirm1:confirm2" } );
    $t->post_ok(
        "//$userid:$password@/api/v1/checkouts?confirmation=$token" => json => {
            item_id   => $item1_id,
            patron_id => $patron_id
        }
    )->status_is(201)->or( sub { diag $t->tx->res->body } );
    %needsconfirmation = ();

    subtest 'public add' => sub {
        plan tests => 14;

        my $useridp = $patron->userid;
        $patron->set_password( { password => $password, skip_validation => 1 } );

        # Feature disabled
        t::lib::Mocks::mock_preference( 'OpacTrustedCheckout', 0 );

        $t->post_ok(
            "/api/v1/public/patrons/$patron_id/checkouts" => json => { item_id => $item1_id, patron_id => $patron_id } )
            ->status_is(401)->json_is( { error => "Authentication failure." } );

        $t->post_ok( "//$useridp:$password@/api/v1/public/patrons/$patron_id/checkouts" => json =>
                { item_id => $item1_id, patron_id => $patron_id } )->status_is(405)
            ->json_is( { error => "Feature disabled", error_code => "FEATURE_DISABLED" } );

        # Feature enabled
        t::lib::Mocks::mock_preference( 'OpacTrustedCheckout', 1 );

        $t->post_ok(
            "/api/v1/public/patrons/$patron_id/checkouts" => json => { item_id => $item1_id, patron_id => $patron_id } )
            ->status_is(401)->json_is( { error => "Authentication failure." } );

        $t->post_ok( "//$userid:$password@/api/v1/public/patrons/$patron_id/checkouts" => json =>
                { item_id => $item1_id, patron_id => $patron_id } )->status_is(403)->json_is(
            {
                error                => "Authorization failure. Missing required permission(s).",
                required_permissions => undef
            }
                );

        $t->post_ok( "//$useridp:$password@/api/v1/public/patrons/$patron_id/checkouts" => json =>
                { item_id => $item1_id, patron_id => $patron_id } )->status_is(201);
    };

    $schema->storage->txn_rollback;
};
