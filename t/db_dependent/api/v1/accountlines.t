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


use Test::More tests => 37;
use Test::Mojo;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Account::Line;

my $builder = t::lib::TestBuilder->new();

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = $builder->build({ source => 'Category' })->{ categorycode };
my $branchcode = $builder->build({ source => 'Branch' })->{ branchcode };

$t->get_ok('/api/v1/accountlines')
  ->status_is(401);

$t->put_ok("/api/v1/accountlines/11224409" => json => {'amount' => -5})
    ->status_is(401);

$t->post_ok("/api/v1/accountlines/11224408/payment")
    ->status_is(401);

my $loggedinuser = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 1024
    }
});

my $borrower = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
    }
});

my $borrower2 = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
    }
});
my $borrowernumber = $borrower->{borrowernumber};
my $borrowernumber2 = $borrower2->{borrowernumber};

$dbh->do(q| DELETE FROM accountlines |);
$dbh->do(q|
    INSERT INTO accountlines (borrowernumber, amount, accounttype, amountoutstanding)
    VALUES (?, 20, 'A', 20), (?, 40, 'F', 40), (?, 80, 'F', 80), (?, 10, 'F', 10)
    |, undef, $borrowernumber, $borrowernumber, $borrowernumber, $borrowernumber2);

my $session = C4::Auth::get_session('');
$session->param('number', $loggedinuser->{ borrowernumber });
$session->param('id', $loggedinuser->{ userid });
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;

my $borrowersession = C4::Auth::get_session('');
$borrowersession->param('number', $borrower->{ borrowernumber });
$borrowersession->param('id', $borrower->{ userid });
$borrowersession->param('ip', '127.0.0.1');
$borrowersession->param('lasttime', time());
$borrowersession->flush;

my $tx = $t->ua->build_tx(GET => "/api/v1/accountlines?borrowernumber=$borrowernumber2");
$tx->req->cookies({name => 'CGISESSID', value => $borrowersession->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(403);

$tx = $t->ua->build_tx(GET => "/api/v1/accountlines?borrowernumber=$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);

my $json = $t->tx->res->json;
ok(ref $json eq 'ARRAY', 'response is a JSON array');
ok(scalar @$json == 3, 'response array contains 3 elements');

$tx = $t->ua->build_tx(GET => "/api/v1/accountlines");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);

$json = $t->tx->res->json;
ok(ref $json eq 'ARRAY', 'response is a JSON array');
ok(scalar @$json == 4, 'response array contains 3 elements');

# Editing accountlines tests
my $put_data = {
    'amount' => -19,
    'amountoutstanding' => -19
};

$tx = $t->ua->build_tx(
    PUT => "/api/v1/accountlines/11224409"
        => json => $put_data);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
    ->status_is(404);

my $accountline_to_edit = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber2})->unblessed()->[0];

$tx = $t->ua->build_tx(PUT => "/api/v1/accountlines/$accountline_to_edit->{accountlines_id}" => json => $put_data);
$tx->req->cookies({name => 'CGISESSID', value => $borrowersession->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(403);

$tx = $t->ua->build_tx(
    PUT => "/api/v1/accountlines/$accountline_to_edit->{accountlines_id}"
        => json => $put_data);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
    ->status_is(200);

my $accountline_edited = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber2})->unblessed()->[0];

is($accountline_edited->{amount}, '-19.000000');
is($accountline_edited->{amountoutstanding}, '-19.000000');


# Payment tests
$tx = $t->ua->build_tx(POST => "/api/v1/accountlines/4562765765/payment");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(404);

my $accountline_to_pay = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber, 'amount' => 20})->unblessed()->[0];
$tx = $t->ua->build_tx(POST => "/api/v1/accountlines/$accountline_to_pay->{accountlines_id}/payment");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);
#$t->content_is('toto');

my $accountline_paid = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber, 'amount' => -20})->unblessed()->[0];
ok($accountline_paid);

# Partial payment tests
my $post_data = {
    'amount' => 17,
    'note' => 'Partial payment'
};

$tx = $t->ua->build_tx(
    POST => "/api/v1/accountlines/11224419/payment"
        => json => $post_data);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
    ->status_is(404);

my $accountline_to_partiallypay = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber, 'amount' => 80})->unblessed()->[0];

$tx = $t->ua->build_tx(POST => "/api/v1/accountlines/$accountline_to_partiallypay->{accountlines_id}/payment" => json => {amount => 'foo'});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(400);

$tx = $t->ua->build_tx(POST => "/api/v1/accountlines/$accountline_to_partiallypay->{accountlines_id}/payment" => json => $post_data);
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);

$accountline_to_partiallypay = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber, 'amount' => 80})->unblessed()->[0];
is($accountline_to_partiallypay->{amountoutstanding}, '63.000000');

my $accountline_partiallypaid = Koha::Account::Lines->search({'borrowernumber' => $borrowernumber, 'amount' => -17})->unblessed()->[0];
ok($accountline_partiallypaid);

$dbh->rollback;
