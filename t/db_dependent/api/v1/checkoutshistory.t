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

use Test::More tests => 31;
use Test::MockModule;
use Test::Mojo;
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

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;
$dbh->{RaiseError} = 1;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM items');
$dbh->do('DELETE FROM issuingrules');
my $loggedinuser = $builder->build({ source => 'Borrower' });

$dbh->do(q{
    INSERT INTO user_permissions (borrowernumber, module_bit, code)
    VALUES (?, 1, 'circulate_remaining_permissions')
}, undef, $loggedinuser->{borrowernumber});

my $session = C4::Auth::get_session('');
$session->param('number', $loggedinuser->{ borrowernumber });
$session->param('id', $loggedinuser->{ userid });
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;

my $nopermission = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
    }
});

my $session_nopermission = C4::Auth::get_session('');
$session_nopermission->param('number', $nopermission->{ borrowernumber });
$session_nopermission->param('id', $nopermission->{ userid });
$session_nopermission->param('ip', '127.0.0.1');
$session_nopermission->param('lasttime', time());
$session_nopermission->flush;

my $borrower = $builder->build({ source => 'Borrower' });
my $borrowernumber = $borrower->{borrowernumber};

my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });

my $tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is([]);

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
  ->json_is('/0/issue_id' => $issueId)
  ->json_hasnt('/1')
  ->json_hasnt('/error');

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $borrowernumber)
  ->json_is('/itemnumber' => $itemnumber1)
  ->json_is('/date_due' => $date_due1->ymd . ' ' . $date_due1->hms)
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
  ->json_hasnt('/0')
  ->json_hasnt('/error');

Koha::Patrons->find($borrowernumber)->delete();

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/history?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404)
  ->json_has('/error');

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
    };

    my $itemnumber = C4::Items::AddItem($item, $biblionumber);

    return $itemnumber;
}
