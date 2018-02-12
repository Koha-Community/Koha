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

use Test::More tests => 21;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Patron;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

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
my $borrower = $builder->build({
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

$t->get_ok("/api/v1/patrons/" . $borrower->{ borrowernumber })
  ->status_is(401);

my $session = C4::Auth::get_session('');
$session->param('number', $borrower->{ borrowernumber });
$session->param('id', $borrower->{ userid });
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

$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . ($borrower->{ borrowernumber }-1));
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(403)
  ->json_is('/required_permissions', {"borrowers" => "edit_borrowers"});

# User without permissions, but is the owner of the object
$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $borrower->{borrowernumber});
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200);

# User without permissions, but is the guarantor of the owner of the object
$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $borrower->{borrowernumber});
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

$tx = $t->ua->build_tx(GET => "/api/v1/patrons/" . $borrower->{ borrowernumber });
$tx->req->cookies({name => 'CGISESSID', value => $session->id});
$t->request_ok($tx)
  ->status_is(200)
  ->json_is('/borrowernumber' => $borrower->{ borrowernumber })
  ->json_is('/surname' => $borrower->{ surname })
  ->json_is('/lost' => Mojo::JSON->true );

$schema->storage->txn_rollback;
