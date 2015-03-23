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

use Test::More tests => 57;
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

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;
$dbh->{RaiseError} = 1;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

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

my $patron = $builder->build({ source => 'Borrower', value => { flags => 0 } });
my $borrowernumber = $patron->{borrowernumber};
my $patron_session = C4::Auth::get_session('');
$patron_session->param('number', $borrowernumber);
$patron_session->param('id', $patron->{ userid });
$patron_session->param('ip', '127.0.0.1');
$patron_session->param('lasttime', time());
$patron_session->flush;

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
  ->json_is('/0/date_due' => $date_due1->ymd . ' ' . $date_due1->hms)
  ->json_is('/1/borrowernumber' => $borrowernumber)
  ->json_is('/1/itemnumber' => $itemnumber2)
  ->json_is('/1/date_due' => $date_due2->ymd . ' ' . $date_due2->hms)
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
  ->json_is('/0/date_due' => $date_due1->ymd . ' ' . $date_due1->hms)
  ->json_is('/1/borrowernumber' => $borrowernumber)
  ->json_is('/1/itemnumber' => $itemnumber2)
  ->json_is('/1/date_due' => $date_due2->ymd . ' ' . $date_due2->hms)
  ->json_hasnt('/2');

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $borrowernumber)
  ->json_is('/itemnumber' => $itemnumber1)
  ->json_is('/date_due' => $date_due1->ymd . ' ' . $date_due1->hms)
  ->json_hasnt('/1');

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/date_due' => $date_due1->ymd . ' ' . $date_due1->hms);

$tx = $t->ua->build_tx(GET => "/api/v1/checkouts/" . $issue2->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/date_due' => $date_due2->ymd . ' ' . $date_due2->hms);


$dbh->do('DELETE FROM issuingrules');
$dbh->do(q{
    INSERT INTO issuingrules (categorycode, branchcode, itemtype, renewalperiod, renewalsallowed)
    VALUES (?, ?, ?, ?, ?)
}, {}, '*', '*', '*', 7, 1);

my $expected_datedue = DateTime->now->add(days => 14)->set(hour => 23, minute => 59, second => 0);
$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/date_due' => $expected_datedue->ymd . ' ' . $expected_datedue->hms);

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

t::lib::Mocks::mock_preference( "OpacRenewalAllowed", 1 );
$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue2->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $patron_session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/date_due' => $expected_datedue->ymd . ' ' . $expected_datedue->hms);

$tx = $t->ua->build_tx(PUT => "/api/v1/checkouts/" . $issue1->issue_id);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is({ error => 'Renewal not authorized (too_many)' });

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
