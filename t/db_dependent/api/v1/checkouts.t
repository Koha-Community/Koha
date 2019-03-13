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

use Test::More tests => 53;
use Test::MockModule;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use DateTime;

use C4::Context;
use C4::Circulation;

use Koha::Database;
use Koha::DateUtils;

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
my $module = new Test::MockModule('C4::Context');
$module->mock('userenv', sub { { branch => $branchcode } });

$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id" )
  ->status_is(200)
  ->json_is([]);

my $notexisting_patron_id = $patron_id + 1;
$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$notexisting_patron_id" )
  ->status_is(200)
  ->json_is([]);

my $item1 = $builder->build_sample_item;
my $item2 = $builder->build_sample_item;
my $item3 = $builder->build_sample_item;

my $date_due = DateTime->now->add(weeks => 2);
my $issue1 = C4::Circulation::AddIssue($patron->unblessed, $item1->barcode, $date_due);
my $date_due1 = Koha::DateUtils::dt_from_string( $issue1->date_due );
my $issue2 = C4::Circulation::AddIssue($patron->unblessed, $item2->barcode, $date_due);
my $date_due2 = Koha::DateUtils::dt_from_string( $issue2->date_due );
my $issue3 = C4::Circulation::AddIssue($librarian->unblessed, $item3->barcode, $date_due);
my $date_due3 = Koha::DateUtils::dt_from_string( $issue3->date_due );

$t->get_ok( "//$userid:$password@/api/v1/checkouts?patron_id=$patron_id" )
  ->status_is(200)
  ->json_is('/0/patron_id' => $patron_id)
  ->json_is('/0/item_id' => $item1->itemnumber)
  ->json_is('/0/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due1 }) )
  ->json_is('/1/patron_id' => $patron_id)
  ->json_is('/1/item_id' => $item2->itemnumber)
  ->json_is('/1/due_date' => output_pref({ dateformat => "rfc3339", dt => $date_due2 }) )
  ->json_hasnt('/2');


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


$dbh->do('DELETE FROM issuingrules');
$dbh->do(q{
    INSERT INTO issuingrules (categorycode, branchcode, itemtype, renewalperiod, renewalsallowed)
    VALUES (?, ?, ?, ?, ?)
}, {}, '*', '*', '*', 7, 1);

my $expected_datedue = DateTime->now->add(days => 14)->set(hour => 23, minute => 59, second => 0);
$t->post_ok ( "//$userid:$password@/api/v1/checkouts/" . $issue1->issue_id . "/renewal" )
  ->status_is(201)
  ->json_is('/due_date' => output_pref( { dateformat => "rfc3339", dt => $expected_datedue }) )
  ->header_is(Location => "/api/v1/checkouts/" . $issue1->issue_id . "/renewal");

$t->post_ok( "//$unauth_userid:$unauth_password@/api/v1/checkouts/" . $issue3->issue_id . "/renewal" )
  ->status_is(403)
  ->json_is({ error => "Authorization failure. Missing required permission(s).",
              required_permissions => { circulate => "circulate_remaining_permissions" }
            });

$t->post_ok( "//$userid:$password@/api/v1/checkouts/" . $issue2->issue_id . "/renewal" )
  ->status_is(201)
  ->json_is('/due_date' => output_pref({ dateformat => "rfc3339", dt => $expected_datedue}) )
  ->header_is(Location => "/api/v1/checkouts/" . $issue2->issue_id . "/renewal");


$t->post_ok( "//$userid:$password@/api/v1/checkouts/" . $issue1->issue_id . "/renewal" )
  ->status_is(403)
  ->json_is({ error => 'Renewal not authorized (too_many)' });

