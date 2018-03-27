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

use Test::More tests => 162;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::AuthUtils;
use Koha::Database;
use Koha::Patron;
use Koha::Account::Lines;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
}

t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $builder = t::lib::TestBuilder->new();
my $dbh = C4::Context->dbh;
my $schema  = Koha::Database->schema;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my $categorycode = $builder->build({ source => 'Category', value => {passwordpolicy => ''} })->{ categorycode };
my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
my $guarantor = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
        lost         => 0,
    }
});
my $password = "secret";
my $patron = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
        lost         => 0,
        gonenoaddress => 0,
        guarantorid    => $guarantor->{borrowernumber},
        password     => Koha::AuthUtils::hash_password($password),
        email => 'nobody@example.com',
        emailpro => 'nobody@example.com',
        B_email => 'nobody@example.com',
    }
});

my $librarian = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        lost         => 0,
        password     => Koha::AuthUtils::hash_password("test"),
        othernames   => 'librarian_othernames',
    }
});
Koha::Auth::PermissionManager->grantPermissions({
    $librarian->{borrowernumber}, {
        borrowers => 'view_borrowers'
    }
});

$t->get_ok('/api/v1/patrons')
  ->status_is(401);

$t->get_ok("/api/v1/patrons/" . $patron->{ borrowernumber })
  ->status_is(401);

my $session = C4::Auth::get_session('');
$session->param('number', $patron->{ borrowernumber });
$session->param('id', $patron->{ userid });
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;

my $session2 = C4::Auth::get_session('');
$session2->param('number', $guarantor->{ borrowernumber });
$session2->param('id', $guarantor->{ userid });
$session2->param('ip', '127.0.0.1');
$session2->param('lasttime', time());
$session2->flush;

my $session3 = C4::Auth::get_session('');
$session3->param('number', $librarian->{ borrowernumber });
$session3->param('id', $librarian->{ userid });
$session3->param('ip', '127.0.0.1');
$session3->param('lasttime', time());
$session3->flush;

my $tx = $t->ua->build_tx(GET => '/api/v1/patrons');
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403);

$tx = $t->ua->build_tx(GET => "/api/v1/patrons/".$librarian->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is('/required_permissions', {"borrowers" => "view_borrowers"});

$tx = $t->ua->build_tx(GET => "/api/v1/patrons?guarantorid=".$librarian->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is('/required_permissions', {"borrowers" => "view_borrowers"});

$tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/" . $patron->{ borrowernumber });
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is('/required_permissions', {"borrowers" => "1"});

Koha::Auth::PermissionManager->grantAllSubpermissions(
    $librarian->{borrowernumber}, 'borrowers'
);

# User without permissions, but is the owner of the object
$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $patron->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200);

# User without permissions, but is the guarantor of the owner of the object
$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $patron->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session2->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/guarantorid', $guarantor->{borrowernumber});

# Get guarantor's guarantees without permission
$tx = $t->ua->build_tx(GET => "/api/v1/patrons?guarantorid=".$guarantor->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session2->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/0/borrowernumber', $patron->{borrowernumber});

Koha::Patrons->find($patron)->set({ guarantorid => undef })->store;
$tx = $t->ua->build_tx(GET => "/api/v1/patrons?guarantorid=".$guarantor->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session2->id});
$t->request_ok($tx)
  ->status_is(200)
  ->content_is('[]');
Koha::Patrons->find($patron)->set({ guarantorid =>  $guarantor->{borrowernumber} })->store;

# Get guarantee's guarantor without permission
$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $guarantor->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber', $guarantor->{borrowernumber});

my $password_obj = {
    current_password    => $password,
    new_password        => "new password",
};

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/-100/password' => json => $password_obj);
$t->request_ok($tx)
  ->status_is(401);

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$patron->{borrowernumber}.'/password');
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400);

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$guarantor->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403);

my $loggedinuser = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 1040, # borrowers and updatecharges (2^4 | 2^10)
        password     => Koha::AuthUtils::hash_password($password),
        lost         => 0,
    }
});

$session = C4::Auth::get_session('');
$session->param('number', $loggedinuser->{ borrowernumber });
$session->param('id', $loggedinuser->{ userid });
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;

my $session_nopermission = C4::Auth::get_session('');
$session_nopermission->param('number', $patron->{ borrowernumber });
$session_nopermission->param('id', $patron->{ userid });
$session_nopermission->param('ip', '127.0.0.1');
$session_nopermission->param('lasttime', time());
$session_nopermission->flush;

$tx = $t->ua->build_tx(GET => '/api/v1/patrons');
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);
ok(@{$tx->res->json} >= 1, 'Json response lists all when no params given');

$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $patron->{ borrowernumber });
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $patron->{ borrowernumber })
  ->json_is('/surname' => $patron->{ surname })
  ->json_is('/lost' => Mojo::JSON->false );

$tx = $t->ua->build_tx(GET => '/api/v1/patrons' => form => {surname => 'nonexistent'});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);
ok(@{$tx->res->json} == 0, "Json response yields no results when params doesn't match");

$tx = $t->ua->build_tx(GET => '/api/v1/patrons' => form => {surname => $patron->{ surname }});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200)
  ->json_has($patron);
ok(@{$tx->res->json} == 1, 'Json response yields expected results when params match');

### POST /api/v1/patrons

my $newpatron = {
  branchcode   => $branchcode,
  categorycode => $categorycode,
  surname      => "TestUser",
  cardnumber => "123456",
  userid => "testuser"
};

$newpatron->{ branchcode } = "nonexistent"; # Test invalid branchcode
$tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_is('/error' => "Library with branchcode \"nonexistent\" does not exist");

$newpatron->{ branchcode } = $branchcode;
$newpatron->{ categorycode } = "nonexistent"; # Test invalid patron category
$tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_is('/error' => "Patron category \"nonexistent\" does not exist");
$newpatron->{ categorycode } = $categorycode;

$newpatron->{ falseproperty } = "Non existent property";
$tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(500)
  ->json_is('/error' => "Something went wrong, check Koha logs for details.");

delete $newpatron->{ falseproperty };
$tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(201, 'Patron created successfully')
  ->json_has('/borrowernumber', 'got a borrowernumber')
  ->json_is('/cardnumber', $newpatron->{ cardnumber })
  ->json_is('/surname' => $newpatron->{ surname })
  ->json_is('/firstname' => $newpatron->{ firstname });
$newpatron->{borrowernumber} = $tx->res->json->{borrowernumber};

$tx = $t->ua->build_tx(POST => "/api/v1/patrons" => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(409)
  ->json_has('/error', 'Fails when trying to POST duplicate cardnumber or userid')
  ->json_has('/conflict', { userid => $newpatron->{ userid }, cardnumber => $newpatron->{ cardnumber } });

### PUT /api/v1/patrons
$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/0" => json => {});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404)
  ->json_has('/error', 'Fails when trying to PUT nonexistent patron');

$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => {branchcode => $branchcode, categorycode => "nonexistent"});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_is('/error' => "Patron category \"nonexistent\" does not exist");

$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => {branchcode => "nonexistent"});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_is('/error' => "Library with branchcode \"nonexistent\" does not exist");

$newpatron->{ falseproperty } = "Non existent property";
$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(500)
  ->json_is('/error' => "Something went wrong, check the logs.");
delete $newpatron->{ falseproperty };

$newpatron->{ cardnumber } = $patron-> { cardnumber };
$newpatron->{ userid } = $patron-> { userid };
$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(409)
  ->json_has('/error' => "Fails when trying to update to an existing cardnumber or userid")
  ->json_has('/conflict', { cardnumber => $patron->{ cardnumber }, userid => $patron->{ userid } });

$newpatron->{ cardnumber } = "123456";
$newpatron->{ userid } = "testuser";
$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(204, 'No changes - patron NOT updated');

subtest 'Test OPACPatronDetails preference' => sub {
    plan tests => 7;
    t::lib::Mocks::mock_preference("OPACPatronDetails", 0);
    $patron = Koha::Patrons->find({ borrowernumber => $patron->{borrowernumber} })->TO_JSON;
    $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $patron->{ borrowernumber } => json => $patron);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(403, 'OPACPatronDetails off - modifications not allowed.');

    t::lib::Mocks::mock_preference("OPACPatronDetails", 1);
    $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $patron->{ borrowernumber } => json => $patron);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(204, 'Updating myself with my current data'); # no modifications

    $patron->{'firstname'} = "noob";
    $tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $patron->{ borrowernumber } => json => $patron);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(202, 'Updating myself with my current data'); # update my first name
    Koha::Patron::Modifications->find({ borrowernumber => $patron->{borrowernumber}, firstname => "noob" })->approve;
    is(Koha::Patrons->find({ borrowernumber => $patron->{borrowernumber}})->firstname, "noob", "Changes approved");
};


$newpatron->{ cardnumber } = "234567";
$newpatron->{ userid } = "updatedtestuser";
$newpatron->{ surname } = "UpdatedTestUser";
$newpatron->{ othernames } = $librarian->{othernames};

$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(409)
  ->json_is('/error' => "Patron othernames must be unique");
delete $newpatron->{ othernames };

$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200, 'Patron updated successfully')
  ->json_has($newpatron);

subtest 'patch() tests' => sub {
    plan tests => 12;

    my ($borrowernumber, $session_id) =
    create_user_and_session({ authorized => 16 });
    my ($patronnumber, $patron_session_id) =
    create_user_and_session({ authorized => 0 });

    my $update = { surname => 'Koha-Suomi' };
    $tx = $t->ua->build_tx(PATCH => "/api/v1/patrons/" . $borrowernumber => json => $update );
    $tx->req->cookies({name => 'CGISESSID', value => $session_id});
    $t->request_ok($tx)
      ->status_is(200, 'Patron updated successfully')
      ->json_hasnt('/');

    $update = { firstname => 'Koha-Suomi' };
    $tx = $t->ua->build_tx(PATCH => "/api/v1/patrons/" . $patronnumber => json => $update );
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session_id});
    $t->request_ok($tx)
      ->status_is(202, 'Patron updated successfully')
      ->json_hasnt('/');

    $update = { privacy => 0 };
    $tx = $t->ua->build_tx(PATCH => "/api/v1/patrons/" . $patronnumber => json => $update );
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session_id});
    $t->request_ok($tx)
      ->status_is(200, 'Patron updated successfully')
      ->json_hasnt('/');

    $update = { smsalertnumber => '+35850000000' };
    $tx = $t->ua->build_tx(PATCH => "/api/v1/patrons/" . $patronnumber => json => $update );
    $tx->req->cookies({name => 'CGISESSID', value => $patron_session_id});
    $t->request_ok($tx)
      ->status_is(200, 'Patron updated successfully')
      ->json_hasnt('/');

    Koha::Patrons->find($borrowernumber)->delete; # clean
};

### DELETE /api/v1/patrons

$tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/0");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404, 'Patron not found');

$tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/" . $newpatron->{ borrowernumber });
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200, 'Patron deleted successfully');

# Payment tests
my $borrower2 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        lost         => 0,
    }
});
my $borrowernumber2 = $borrower2->{borrowernumber};

$dbh->do(q|
    INSERT INTO accountlines (borrowernumber, amount, accounttype, amountoutstanding)
    VALUES (?, 26, 'A', 26)
    |, undef, $borrowernumber2);

$t->post_ok("/api/v1/patrons/$borrowernumber2/payment" => json => {'amount' => 8})
    ->status_is(401);

my $post_data2 = {
    'amount' => 24,
    'note' => 'Partial payment'
};

$tx = $t->ua->build_tx(POST => "/api/v1/patrons/8789798797/payment" => json => $post_data2);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(404);

$tx = $t->ua->build_tx(POST => "/api/v1/patrons/$borrowernumber2/payment" => json => {amount => 0});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(400);

$tx = $t->ua->build_tx(POST => "/api/v1/patrons/$borrowernumber2/payment" => json => {amount => 'foo'});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(400);

$tx = $t->ua->build_tx(POST => "/api/v1/patrons/$borrowernumber2/payment" => json => $post_data2);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(204);

my $accountline_partiallypaid = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber2, 'amount' => 26})->unblessed()->[0];

is($accountline_partiallypaid->{amountoutstanding}, '2.000000');

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/-100/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404);

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200);

ok(C4::Auth::checkpw_hash($password_obj->{'new_password'}, Koha::Patrons->find($loggedinuser->{borrowernumber})->password), "New password in database.");
is(C4::Auth::checkpw_hash($password_obj->{'current_password'}, Koha::Patrons->find($loggedinuser->{borrowernumber})->password), "", "Old password is gone.");

$password_obj->{'current_password'} = $password_obj->{'new_password'};
$password_obj->{'new_password'} = "a";
t::lib::Mocks::mock_preference("minPasswordLength", 5);
$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password must be at least 5 characters long/, "Password too short");

$password_obj->{'new_password'} = "ab12fsF!";
$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200);

$password_obj->{'new_password'} = " ab12fsF! ";
$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password contains leading or trailing whitespace/, "Leading or trailing whitespace");

$password_obj = {
    current_password    => $password,
    new_password        => "new password",
};

t::lib::Mocks::mock_preference("OpacPasswordChange", 0);
$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$patron->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is('/error', "OPAC password change is disabled");

t::lib::Mocks::mock_preference("OpacPasswordChange", 1);
$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$patron->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
$t->request_ok($tx)
  ->status_is(200);

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$patron->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session3->id});
$t->request_ok($tx)
  ->status_is(200);

my $oldcategory = Koha::Patron::Categories->find($categorycode);
$oldcategory->passwordpolicy('simplenumeric')->store;

$password_obj = {
    current_password    => $password,
    new_password        => "12345",
};

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200);

$password_obj->{'new_password'} = "1234";

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password can only contain digits 0-9 and must be at least 5 characters long/, "Password too short");

$password_obj->{'new_password'} = "12F34";

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password can only contain digits 0-9 and must be at least 5 characters long/, "Simplenumeric password policy not in valid format");

$oldcategory->passwordpolicy('alphanumeric')->store;
t::lib::Mocks::mock_preference("minAlnumPasswordLength", 4);

$password_obj = {
    current_password    => $password,
    new_password        => "D124",
};

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200);

$password_obj->{'new_password'} = "12D";

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password must contain both numbers and non-special characters and must be at least 4 characters long/, "Password too short");

$password_obj->{'new_password'} = "1234";

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password must contain both numbers and non-special characters and must be at least 4 characters long/, "Alphanumeric password policy not in valid format");

$oldcategory->passwordpolicy('complex')->store;
t::lib::Mocks::mock_preference("minComplexPasswordLength", 6);

$password_obj = {
    current_password    => $password,
    new_password        => "D124!a",
};

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200);

$password_obj->{'new_password'} = "1aD!";

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password must contain numbers, lower and uppercase characters and special characters and must be at least 6 characters long/, "Password too short");

$password_obj->{'new_password'} = "1234Sa";

$tx = $t->ua->build_tx(PATCH => '/api/v1/patrons/'.$loggedinuser->{borrowernumber}.'/password' => json => $password_obj);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(400)
  ->json_like('/error', qr/Password policy: password must contain numbers, lower and uppercase characters and special characters and must be at least 6 characters long/, "Alphanumeric password policy not in valid format");

# patronstatus
my $debt = {
    current_outstanding => 9001,
    max_outstanding => 5,
};
t::lib::Mocks::mock_preference('maxoutstanding', $debt->{max_outstanding});
my $k_patron = Koha::Patrons->find($patron->{borrowernumber});
my $line = Koha::Account::Line->new({
    borrowernumber => $patron->{borrowernumber},
    amountoutstanding => $debt->{current_outstanding},
})->store;
$tx = $t->ua->build_tx(GET => "/api/v1/patrons/".$patron->{ borrowernumber }
                             ."/status");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $patron->{ borrowernumber })
  ->json_is('/surname' => $patron->{ surname })
  ->json_is('/blocks/Patron::Debt' => $debt);

$schema->storage->txn_rollback;

sub create_user_and_session {

    my $args  = shift;
    my $flags = ( $args->{authorized} ) ? $args->{authorized} : 0;
    my $dbh   = C4::Context->dbh;

    my $user = $builder->build(
        {
            source => 'Borrower',
            value  => {
                flags => $flags,
                lost  => 0,
            }
        }
    );

    # Create a session for the authorized user
    my $session = t::lib::Mocks::mock_session({borrower => $user});

    return ( $user->{borrowernumber}, $session->id );
}
