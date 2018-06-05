#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Test::More tests => 67;
use Test::MockModule;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use DateTime;
use MARC::Record;

use C4::Context;
use C4::Biblio;
use C4::Circulation;
use C4::Items;

use Koha::Account::Lines;
use Koha::Database;
use Koha::Patron;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

my $loggedinuser = $builder->build({
    source => 'Borrower',
    value => {
        gonenoaddress => 0,
        lost => 0,
        debarred => undef,
        debarredcomment => undef,
    }
});

Koha::Auth::PermissionManager->grantPermission(
    scalar Koha::Patrons->find($loggedinuser->{borrowernumber}),
    'circulate', 'circulate_remaining_permissions'
);

my $session = t::lib::Mocks::mock_session({borrower => $loggedinuser});

my $patron = $builder->build({ source => 'Borrower',
    value => {
        flags => 0,
        gonenoaddress => undef,
        lost => undef,
        debarred => undef,
        debarredcomment => undef,
    }
});
my $borrowernumber = $patron->{borrowernumber};
my $patron_session = t::lib::Mocks::mock_session({borrower => $patron});

my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });

my $tx = $t->ua->build_tx(GET => "/api/v1/checkouts?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is([]);

my $notexisting_borrowernumber = $borrowernumber + 1;
$tx = $t->ua->build_tx(GET => "/api/v1/checkouts?borrowernumber=$notexisting_borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is([]);

my $biblionumber = create_biblio('RESTful Web APIs');
my $itemnumber1 = create_item($biblionumber, 'TEST000001');
my $itemnumber2 = create_item($biblionumber, 'TEST000002');
my $itemnumber3 = create_item($biblionumber, 'TEST000003');

my $date_due = DateTime->now->add(weeks => 2);
my $issue1 = C4::Circulation::AddIssue($patron, 'TEST000001', $date_due);
my $date_due1 = Koha::DateUtils::dt_from_string( $issue1->date_due );
my $issue2 = C4::Circulation::AddIssue($patron, 'TEST000002', $date_due);
my $date_due2 = Koha::DateUtils::dt_from_string( $issue2->date_due );
my $issue3 = C4::Circulation::AddIssue($loggedinuser, 'TEST000003', $date_due);
my $date_due3 = Koha::DateUtils::dt_from_string( $issue3->date_due );

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/0/borrowernumber' => $borrowernumber)
  ->json_is('/0/itemnumber' => $itemnumber1)
  ->json_like('/0/date_due' => qr/$date_due1\+\d\d:\d\d/)
  ->json_is('/1/borrowernumber' => $borrowernumber)
  ->json_is('/1/itemnumber' => $itemnumber2)
  ->json_like('/1/date_due' => qr/$date_due2\+\d\d:\d\d/)
  ->json_hasnt('/2');

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/".$issue3->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is({ error => "Authorization failure. Missing required permission(s).",
              required_permissions => { circulate => "circulate_remaining_permissions" }
						});

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts?borrowernumber=".$loggedinuser->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is({ error => "Authorization failure. Missing required permission(s).",
						  required_permissions => { circulate => "circulate_remaining_permissions" }
					  });

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/0/borrowernumber' => $borrowernumber)
  ->json_is('/0/itemnumber' => $itemnumber1)
  ->json_like('/0/date_due' => qr/$date_due1\+\d\d:\d\d/)
  ->json_is('/1/borrowernumber' => $borrowernumber)
  ->json_is('/1/itemnumber' => $itemnumber2)
  ->json_like('/1/date_due' => qr/$date_due2\+\d\d:\d\d/)
  ->json_hasnt('/2');

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $borrowernumber)
  ->json_is('/itemnumber' => $itemnumber1)
  ->json_like('/date_due' => qr/$date_due1\+\d\d:\d\d/)
  ->json_hasnt('/1');

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_like('/date_due' => qr/$date_due1\+\d\d:\d\d/);

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_like('/date_due' => qr/$date_due2\+\d\d:\d\d/);


Koha::IssuingRules->delete;
Koha::IssuingRule->new({
    categorycode => '*',
    branchcode   => '*',
    itemtype     => '*',
    ccode        => '*',
    permanent_location => '*',
    renewalperiod   => 7,
    renewalsallowed => 1,
})->store;

my $expected_datedue = DateTime->now->add(days => 14)->set(hour => 23, minute => 59, second => 0);
$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_like('/date_due' => qr/$expected_datedue\+\d\d:\d\d/);

$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue3->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is({ error => "Authorization failure. Missing required permission(s).",
              required_permissions => { circulate => "circulate_remaining_permissions" }
						});

t::lib::Mocks::mock_preference( "OpacRenewalAllowed", 0 );
$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue2->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is({ error => "Opac Renewal not allowed"	});

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id . "/renewability");
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is({ error => "You don't have the required permission" });

t::lib::Mocks::mock_preference( "OpacRenewalAllowed", 1 );
$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id . "/renewability");
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is({ renewable => Mojo::JSON->true, error => undef });

subtest 'test restricted renewability due to patron restrictions' => sub {
    plan tests => 15;

    my $kp = Koha::Patrons->find($patron->{borrowernumber});

    $kp->set({ debarred => '9999-12-12' })->store;
    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id
                           . "/renewability");
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is({ renewable => Mojo::JSON->false, error => 'debarred' });
    $kp->set({ debarred => undef })->store;

    $kp->set({ lost => 1 })->store;
    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id
                           . "/renewability");
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is({ renewable => Mojo::JSON->false, error => 'cardlost' });
    $kp->set({ lost => undef })->store;

    $kp->set({ gonenoaddress => 1 })->store;
    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id
                           . "/renewability");
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is({ renewable => Mojo::JSON->false, error => 'gonenoaddress' });
    $kp->set({ gonenoaddress => undef })->store;

    $kp->set({ dateexpiry => '2000-01-01' })->store;
    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id
                           . "/renewability");
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is({ renewable => Mojo::JSON->false, error => 'cardexpired' });
    $kp->set({ dateexpiry => undef })->store;

    my $accountline = Koha::Account::Line->new({
        borrowernumber => $kp->borrowernumber,
        amountoutstanding => 9999999999,
        accountno => 0,
    })->store;
    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id
                           . "/renewability");
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is({ renewable => Mojo::JSON->false, error => 'debt' });
    $accountline->delete;
};

$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue2->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_like('/date_due' => qr/$expected_datedue\+\d\d:\d\d/);

$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is({ error => 'Renewal not authorized (too_many)' });

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id . "/renewability");
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is({ renewable => Mojo::JSON->false, error => 'too_many' });

$schema->storage->txn_rollback;

sub create_biblio {
    my ($title) = @_;

    my $record = new MARC::Record;
    $record->append_fields(
        new MARC::Field('200', ' ', ' ', a => $title),
    );

    my ($biblionumber) = C4::Biblio::AddBiblio($record, '');

    return $biblionumber;
}

sub create_item {
    my ($biblionumber, $barcode) = @_;

    my $item = {
        barcode => $barcode,
        itype   => 'BK',
    };

    my $itemnumber = C4::Items::AddItem($item, $biblionumber);

    return $itemnumber;
}
