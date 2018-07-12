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

use Test::More tests => 36;
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

use Koha::Database;
use Koha::Patron;
use Koha::Old::Checkout;
use Koha::Old::Checkouts;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

my $loggedinuser = $builder->build({ source => 'Borrower',
                                    value => { flags => 1, lost => 0 } });

Koha::Auth::PermissionManager->grantPermission(
    scalar Koha::Patrons->find($loggedinuser->{borrowernumber}),
    'circulate', 'circulate_remaining_permissions'
);

my $session = t::lib::Mocks::mock_session({borrower => $loggedinuser});

my $nopermission = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
        lost         => 0,
    }
});

my $session_nopermission = t::lib::Mocks::mock_session({borrower => $nopermission});

my $borrower = $builder->build({ source => 'Borrower' });
my $borrowernumber = $borrower->{borrowernumber};

my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });

my $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/total' => 0)
  ->json_is('/records' => []);

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$t->request_ok($tx)
  ->status_is(401);

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
$t->request_ok($tx)
  ->status_is(403);

my $notexisting_borrowernumber = $borrowernumber + 1;
$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$notexisting_borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404)
  ->json_has('/error');

my $biblionumber = create_biblio('RESTful Web APIs');
my $itemnumber1 = create_item($biblionumber, 'TEST000001');
my $itemnumber2 = create_item($biblionumber, 'TEST000002');
my $itemnumber3 = create_item($biblionumber, 'TEST000003');
my $itemnumber4 = create_item($biblionumber, 'TEST000004');
my $itemnumber5 = create_item($biblionumber, 'TEST000005');

my $date_due = DateTime->now->add(weeks => 2);

my $issueId = Koha::Old::Checkouts->count({}) + int rand(150000);
my $issue1;
$issue1 = Koha::Old::Checkout->new({ issue_id => $issueId, borrowernumber => $borrowernumber, itemnumber => $itemnumber1, date_due => $date_due});
$issue1->store();

my $date_due1 = Koha::DateUtils::dt_from_string( $issue1->date_due );

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/records/0/issue_id' => $issueId)
  ->json_is('/total' => 1)
  ->json_hasnt('/records/1')
  ->json_hasnt('/error');

my $date_due_regexp = $date_due1->ymd . 'T' . $date_due1->hms . '\+' .'\d\d:\d\d';
$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $borrowernumber)
  ->json_is('/itemnumber' => $itemnumber1)
  ->json_like('/date_due' => qr/$date_due_regexp/)
  ->json_hasnt('/error');

$issue1->delete();

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404)
  ->json_has('/error');

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/total' => 0)
  ->json_is('/records' => [])
  ->json_hasnt('/error');

subtest 'test sorting, limit and offset' => sub {
    plan tests => 59;

    my $id = Koha::Old::Checkouts->search({}, {
        order_by => {'-desc' => 'issue_id'}})->next;
    $id = ($id) ? $id->issue_id+1 : 1;

    my $issue2 = Koha::Old::Checkout->new({
        issue_id => $id,
        borrowernumber => $borrowernumber,
        itemnumber => $itemnumber1,
        date_due => '2020-01-01',
        issuedate => '2029-12-01',
    })->store;
    my $issue3 = Koha::Old::Checkout->new({
        issue_id => $id+1,
        borrowernumber => $borrowernumber,
        itemnumber => $itemnumber1,
        date_due => '2030-01-01',
        issuedate => '2039-12-01',
    })->store;
    my $issue4 = Koha::Old::Checkout->new({
        issue_id => $id+2,
        borrowernumber => $borrowernumber,
        itemnumber => $itemnumber1,
        date_due => '2000-01-01',
        issuedate => '2009-12-01',
    })->store;
    my $issue5 = Koha::Old::Checkout->new({
        issue_id => $id+3,
        borrowernumber => $borrowernumber,
        itemnumber => $itemnumber1,
        date_due => '2010-01-01',
        issuedate => '2019-12-01',
    })->store;

    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/total' => 4)
      ->json_has('/records/0')
      ->json_has('/records/1')
      ->json_has('/records/2')
      ->json_has('/records/3')
      ->json_is('/records/0/issue_id' => $issue2->issue_id)
      ->json_is('/records/1/issue_id' => $issue3->issue_id)
      ->json_is('/records/2/issue_id' => $issue4->issue_id)
      ->json_is('/records/3/issue_id' => $issue5->issue_id)
      ->json_is('/records/0/itemnumber' => $issue2->itemnumber);

    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history"
        ."?borrowernumber=$borrowernumber&offset=2");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/total' => 4)
      ->json_has('/records/0')
      ->json_has('/records/1')
      ->json_hasnt('/records/2')
      ->json_is('/records/0/issue_id' => $issue4->issue_id)
      ->json_is('/records/1/issue_id' => $issue5->issue_id)
      ->json_is('/records/0/itemnumber' => $issue4->itemnumber);

    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history"
        ."?borrowernumber=$borrowernumber&offset=2&order=desc");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/total' => 4)
      ->json_has('/records/0')
      ->json_has('/records/1')
      ->json_hasnt('/records/2')
      ->json_is('/records/0/issue_id' => $issue3->issue_id)
      ->json_is('/records/1/issue_id' => $issue2->issue_id)
      ->json_is('/records/0/itemnumber' => $issue3->itemnumber);

    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history"
        ."?borrowernumber=$borrowernumber&offset=2&order=desc&limit=1");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/total' => 4)
      ->json_has('/records/0')
      ->json_hasnt('/records/1')
      ->json_is('/records/0/issue_id' => $issue3->issue_id)
      ->json_is('/records/0/itemnumber' => $issue3->itemnumber);

    $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history"
        ."?borrowernumber=$borrowernumber&sort=date_due");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/total' => 4)
      ->json_has('/records/0')
      ->json_has('/records/1')
      ->json_has('/records/2')
      ->json_has('/records/3')
      ->json_is('/records/0/issue_id' => $issue4->issue_id)
      ->json_is('/records/1/issue_id' => $issue5->issue_id)
      ->json_is('/records/2/issue_id' => $issue2->issue_id)
      ->json_is('/records/3/issue_id' => $issue3->issue_id);

      $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history"
        ."?borrowernumber=$borrowernumber&sort=date_due&order=desc");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/total' => 4)
      ->json_has('/records/0')
      ->json_has('/records/1')
      ->json_has('/records/2')
      ->json_has('/records/3')
      ->json_is('/records/0/issue_id' => $issue3->issue_id)
      ->json_is('/records/1/issue_id' => $issue2->issue_id)
      ->json_is('/records/2/issue_id' => $issue5->issue_id)
      ->json_is('/records/3/issue_id' => $issue4->issue_id);
};

subtest 'delete() tests' => sub {
    plan tests => 10;

    my $anonymous_patron = $builder->build({
        source => 'Borrower'
    })->{borrowernumber};
    t::lib::Mocks::mock_preference('AnonymousPatron', $anonymous_patron);

    my $id = Koha::Old::Checkouts->search({}, {
        order_by => {'-desc' => 'issue_id'}})->next;
    $id = ($id) ? $id->issue_id+1 : 1;

    my $issue1 = Koha::Old::Checkout->new({
        issue_id => $id,
        borrowernumber => $nopermission->{borrowernumber},
        itemnumber => $itemnumber1,
    })->store;
    my $issue2 = Koha::Old::Checkout->new({
        issue_id => $id+1,
        borrowernumber => $nopermission->{borrowernumber},
        itemnumber => $itemnumber1,
    })->store;

    $tx = $t->ua->build_tx(DELETE => "/api/v1/checkouts/history");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(400);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/checkouts/history"
        ."?borrowernumber=".($borrowernumber+1));
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/checkouts/history"
        ."?borrowernumber=".$nopermission->{borrowernumber});
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(200);

    is(Koha::Old::Checkouts->search({
        borrowernumber => $anonymous_patron,
        issue_id => { 'in' => [$id, $id+1] }
    })->count, 2, 'Found anonymized checkouts (anonymous patron)');

    t::lib::Mocks::mock_preference('AnonymousPatron', undef);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/checkouts/history"
        ."?borrowernumber=$anonymous_patron");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200);

    is(Koha::Old::Checkouts->search({
        borrowernumber => undef,
        issue_id => { 'in' => [$id, $id+1] }
    })->count, 2, 'Found anonymized checkouts (undef patron)');
};

Koha::Patrons->find($borrowernumber)->delete();

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404)
  ->json_has('/error');

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
        itype => 'Books'
    };

    my $itemnumber = C4::Items::AddItem($item, $biblionumber);

    return $itemnumber;
}
