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

use Test::More tests => 78;
use Test::Mojo;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;

BEGIN {
    use_ok('Koha::Object');
    use_ok('Koha::Patron');
}

my $builder = t::lib::TestBuilder->new();
my $dbh = C4::Context->dbh;
my $schema  = Koha::Database->schema;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

$schema->storage->txn_begin;

my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };
my $guarantor = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
    }
});
my $patron = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
        lost         => 1,
        guarantorid  => $guarantor->{borrowernumber},
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

my $tx = $t->ua->build_tx(GET => '/api/v1/patrons');
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403);

$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . ($patron->{ borrowernumber }-1));
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is('/required_permissions', {"borrowers" => "1"});

$tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/" . $patron->{ borrowernumber });
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is('/required_permissions', {"borrowers" => "1"});

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

my $loggedinuser = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 16 # borrowers flag
    }
});

$session = C4::Auth::get_session('');
$session->param('number', $loggedinuser->{ borrowernumber });
$session->param('id', $loggedinuser->{ userid });
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;

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
  ->json_is('/lost' => Mojo::JSON->true );

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
  ->json_is('/error' => "Something went wrong, check Koha logs for details.");
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

$newpatron->{ cardnumber } = "234567";
$newpatron->{ userid } = "updatedtestuser";
$newpatron->{ surname } = "UpdatedTestUser";

$tx = $t->ua->build_tx(PUT => "/api/v1/patrons/" . $newpatron->{ borrowernumber } => json => $newpatron);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200, 'Patron updated successfully')
  ->json_has($newpatron);

### DELETE /api/v1/patrons

$tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/0");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(404, 'Patron not found');

$tx = $t->ua->build_tx(DELETE => "/api/v1/patrons/" . $newpatron->{ borrowernumber });
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200, 'Patron deleted successfully');

$schema->storage->txn_rollback;
