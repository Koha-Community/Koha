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

use Test::More tests => 10;
use Test::Mojo;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Borrower;

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

my $categorycode = Koha::Database->new()->schema()->resultset('Category')->first()->categorycode();
my $branchcode = Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

my $borrower = Koha::Borrower->new;
$borrower->categorycode( $categorycode );
$borrower->branchcode( $branchcode );
$borrower->surname("Test Surname");
$borrower->store;
my $borrowernumber = $borrower->borrowernumber;

$t->get_ok('/api/v1/borrowers')
  ->status_is(403);

$t->get_ok("/api/v1/borrowers/$borrowernumber")
  ->status_is(403);

my $loggedinuser = Koha::Borrower->new;
$loggedinuser->categorycode($categorycode);
$loggedinuser->branchcode($branchcode);
$loggedinuser->userid('test_rest_api_user');
$loggedinuser->flags(16); # flags for 'borrowers' permission only
$loggedinuser->store;

my $session = C4::Auth::get_session('');
$session->param('number', $loggedinuser->borrowernumber);
$session->param('id', $loggedinuser->userid);
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;

my $tx = $t->ua->build_tx(GET => '/api/v1/borrowers');
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$tx->req->env({REMOTE_ADDR => '127.0.0.1'});
$t->request_ok($tx)
  ->status_is(200);

$tx = $t->ua->build_tx(GET => "/api/v1/borrowers/$borrowernumber");
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $borrowernumber)
  ->json_is('/surname' => "Test Surname");

$dbh->rollback;
