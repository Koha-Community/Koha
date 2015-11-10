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

use Test::More tests => 12;
use Test::Mojo;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;

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
    INSERT INTO accountlines (borrowernumber, amount, accounttype)
    VALUES (?, 20, 'A'), (?, 40, 'F'), (?, 80, 'F'), (?, 10, 'F')
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

$dbh->rollback;
