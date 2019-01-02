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

use Test::More tests => 4;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use DateTime;

use C4::Context;
use C4::Biblio;
use C4::Items;

use Koha::ArticleRequest;
use Koha::ArticleRequest::Status;
use Koha::Database;
use Koha::Biblios;
use Koha::Biblioitems;
use Koha::Items;
use Koha::Patrons;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

my $builder = t::lib::TestBuilder->new();
my $schema  = Koha::Database->new->schema;

$schema->storage->txn_begin;

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');
my $tx;

my $categorycode = $builder->build({
    source => 'Category',
    value => {
        reservefee => 0
    }
})->{categorycode};
my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
my $branchcode2 = $builder->build({ source => 'Branch' })->{branchcode};

# User without any permissions
my $nopermission = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0,
        lost         => 0,
        debarred     => undef,
        debarredcomment => undef,
        dateexpiry   => '0000-00-00',
        gonenoaddress => undef,
    }
});
my $nopermission_patron = Koha::Patrons->find($nopermission->{borrowernumber});

my $session_nopermission = t::lib::Mocks::mock_session({borrower => $nopermission_patron});

my $borrower = Koha::Patrons->find($builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        surname      => 'Test Surname',
        userid       => $nopermission->{ userid }."z",
        flags        => 80,
        lost         => 0,
        debarred     => undef,
        debarredcomment => undef,
        dateexpiry   => '0000-00-00',
        gonenoaddress => undef,
    }
})->{'borrowernumber'});
my $borrowernumber = $borrower->borrowernumber;

my $borrower2 = Koha::Patrons->find($builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        surname      => 'Test Surname 2',
        userid       => $nopermission->{ userid }."x",
        flags        => 16,
        lost         => 0,
        debarred     => undef,
        debarredcomment => undef,
        dateexpiry   => '0000-00-00',
        gonenoaddress => undef,
    }
})->{'borrowernumber'});
my $borrowernumber2 = $borrower2->borrowernumber;

my $borrower3 = Koha::Patrons->find($builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        surname      => 'Test Surname 3',
        userid       => $nopermission->{ userid }."y",
        flags        => 64,
        lost         => 0,
        debarred     => undef,
        debarredcomment => undef,
        dateexpiry   => '0000-00-00',
        gonenoaddress => undef,
    }
})->{'borrowernumber'});
my $borrowernumber3 = $borrower3->borrowernumber;

# Get sessions
my $session =  t::lib::Mocks::mock_session({borrower => $borrower});
my $session2 = t::lib::Mocks::mock_session({borrower => $borrower2});
my $session3 = t::lib::Mocks::mock_session({borrower => $borrower3});

my $biblionumber = create_biblio('RESTful Web APIs');
my $itemnumber = create_item($biblionumber, 'TEST000001');

my $biblionumber2 = create_biblio('RESTful Web APIs');
my $itemnumber2 = create_item($biblionumber2, 'TEST000002');

Koha::IssuingRules->delete;
Koha::IssuingRule->new({
    categorycode => '*',
    branchcode   => '*',
    itemtype     => '*',
    reservesallowed => 1,
    reservecharge => 0,
    article_requests => 'yes'
})->store();

Koha::ArticleRequests->delete;

my $ar1 = Koha::ArticleRequest->new({
    borrowernumber => $borrowernumber,
    biblionumber   => $biblionumber,
    branchcode     => $branchcode,
    itemnumber     => $itemnumber
})->store();
my $ar1_id = $ar1->id;

my $ar2 = Koha::ArticleRequest->new({
    borrowernumber => $borrowernumber2,
    biblionumber   => $biblionumber,
    branchcode     => $branchcode,
    itemnumber     => $itemnumber
})->store();
my $ar2_id = $ar2->id;

my $post_data = {
    borrowernumber => int($borrowernumber),
    biblionumber => int($biblionumber),
    itemnumber => int($itemnumber),
    branchcode => $branchcode
};
my $put_data = {
    branchcode => $branchcode
};

subtest "Test endpoints without authentication" => sub {
    plan tests => 8;
    $t->get_ok('/api/v1/articlerequests')
      ->status_is(401);
    $t->post_ok('/api/v1/articlerequests' => json => $post_data)
      ->status_is(401);
    $t->put_ok("/api/v1/articlerequests/0" => json => $put_data)
      ->status_is(401);
    $t->delete_ok("/api/v1/articlerequests/0")
      ->status_is(401);
};


subtest "Test endpoints without permission" => sub {
    plan tests => 10;

    $tx = $t->ua->build_tx(GET => "/api/v1/articlerequests?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(GET => "/api/v1/articlerequests?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx) # reserveforothers permission
      ->status_is(403);
    $tx = $t->ua->build_tx(POST => "/api/v1/articlerequests" => json => $post_data );
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/0" => json => $put_data );
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(DELETE => "/api/v1/articlerequests/0");
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
};
subtest "Test endpoints without permission, but accessing own object" => sub {
    plan tests => 22;

    my $ar3 = Koha::ArticleRequest->new({
        borrowernumber => $nopermission->{'borrowernumber'},
        biblionumber   => $biblionumber,
        branchcode     => $branchcode,
        itemnumber     => $itemnumber
    })->store();
    my $ar3_id = $ar3->id;
    $ar3->complete();

    # try to delete my own request while it's completed; an error should occur
    $tx = $t->ua->build_tx(DELETE => "/api/v1/articlerequests/$ar3_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_is('/error', 'Request cannot be cancelled by patron.');

    # reset the status; after that, cancellation should work
    # N.B. Work around a bug in Koha::ArticleRequest not storing the result in open()
    $ar3->open()->store();

    $tx = $t->ua->build_tx(DELETE => "/api/v1/articlerequests/$ar3_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(200);

    my $remaining = Koha::ArticleRequests->find({ borrowernumber => $nopermission->{borrowernumber} });
    is($remaining->status, Koha::ArticleRequest::Status::Canceled, "Request deleted.");

    my $borrno_tmp = $post_data->{'borrowernumber'};
    $post_data->{'borrowernumber'} = int $nopermission->{'borrowernumber'};

    subtest 'test patron restrictions, POST' => sub {
        $nopermission_patron->set({ gonenoaddress => 1 })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/articlerequests" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx)
          ->status_is(403)
          ->json_is('/error' => 'Request cannot be placed. Reason: gonenoaddress');
        $nopermission_patron->set({ gonenoaddress => 0 })->store;

        $nopermission_patron->set({ debarred => "9999-12-31" })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/articlerequests" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx)
          ->status_is(403)
          ->json_is('/error' => 'Request cannot be placed. Reason: debarred');
        $nopermission_patron->set({ debarred => undef })->store;

        $nopermission_patron->set({ dateexpiry => "2000-01-01" })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/articlerequests" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) 
          ->status_is(403)
          ->json_is('/error' => 'Request cannot be placed. Reason: cardexpired');
        $nopermission_patron->set({ dateexpiry => "0000-00-00" })->store;

        $nopermission_patron->set({ lost => 1 })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/articlerequests" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) 
          ->status_is(403)
          ->json_is('/error' =>
                    "Patron's card has been marked as 'lost'. Access forbidden.");
        $nopermission_patron->set({ lost => 0 })->store;
    };

    subtest 'test patron restrictions, PUT' => sub {
        my $ar4 = Koha::ArticleRequest->new({
            borrowernumber => $nopermission->{'borrowernumber'},
            biblionumber   => $biblionumber,
            branchcode     => $branchcode,
            itemnumber     => $itemnumber,
            status         => Koha::ArticleRequest::Status::Completed
        })->store();
        my $ar4_id = $ar4->id;

        $nopermission_patron->set({ gonenoaddress => 1 })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/$ar4_id" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx)
          ->status_is(403)
          ->json_is('/error' => 'Request cannot be modified. Reason: gonenoaddress');
        $nopermission_patron->set({ gonenoaddress => 0 })->store;

        $nopermission_patron->set({ debarred => "9999-12-31" })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/$ar4_id" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) 
          ->status_is(403)
          ->json_is('/error' => 'Request cannot be modified. Reason: debarred');
        $nopermission_patron->set({ debarred => undef })->store;

        $nopermission_patron->set({ dateexpiry => "2000-01-01" })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/$ar4_id" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx)
          ->status_is(403)
          ->json_is('/error' => 'Request cannot be modified. Reason: cardexpired');
        $nopermission_patron->set({ dateexpiry => "0000-00-00" })->store;

        $nopermission_patron->set({ lost => 1 })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/$ar4_id" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx)
          ->status_is(403)
          ->json_is('/error' =>
                    "Patron's card has been marked as 'lost'. Access forbidden.");
        $nopermission_patron->set({ lost => 0 })->store;

        Koha::ArticleRequests->find($ar4_id)->cancel;
    };

    $tx = $t->ua->build_tx(POST => "/api/v1/articlerequests" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) 
      ->status_is(201)
      ->json_has('/id');

    my $req_id = $t->tx->res->json->{id};

    $tx = $t->ua->build_tx(GET => "/api/v1/articlerequests?borrowernumber=".$nopermission-> { borrowernumber });
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) 
      ->status_is(200)
      ->json_is('/count', 1)
      ->json_is('/records/0/borrowernumber', $nopermission->{ borrowernumber })
      ->json_is('/records/0/biblionumber', $biblionumber)
      ->json_is('/records/0/itemnumber', $itemnumber)
      ->json_is('/records/0/branchcode', $branchcode);

    $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/$req_id" => json => {
        branchcode => $branchcode2
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) 
      ->status_is(200)
      ->json_is('/id', $req_id)
      ->json_is('/branchcode', $branchcode2);
};

subtest "Test endpoints with permission" => sub {
    plan tests => 36;

    $tx = $t->ua->build_tx(GET => '/api/v1/articlerequests');
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/count', 3)
      ->json_has('/records/0')
      ->json_has('/records/1')
      ->json_has('/records/2')
      ->json_hasnt('/records/3');

    $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/$ar1_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/id', $ar1_id);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/articlerequests/$ar1_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(PUT => "/api/v1/articlerequests/$ar1_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(404)
      ->json_has('/error');

    $tx = $t->ua->build_tx(DELETE => "/api/v1/articlerequests/$ar1_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(404)
      ->json_has('/error');

    $tx = $t->ua->build_tx(GET => "/api/v1/articlerequests?borrowernumber=" . $borrower->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session2->id}); # get with borrowers flag
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/count', 0)
      ->json_is('/records', []);

    my $inexisting_borrowernumber = $borrowernumber2*2;
    $tx = $t->ua->build_tx(GET => "/api/v1/articlerequests?borrowernumber=$inexisting_borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/count', 0)
      ->json_is('/records', []);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/articlerequests/$ar2_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $post_data->{borrowernumber} = $borrowernumber;
    $tx = $t->ua->build_tx(POST => "/api/v1/articlerequests" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_has('/id');
    my $req_id = $t->tx->res->json->{id};

    $tx = $t->ua->build_tx(GET => "/api/v1/articlerequests?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/count', 1)
      ->json_is('/records/0/id', $req_id)
      ->json_is('/records/0/branchcode', $branchcode);
};


$schema->storage->txn_rollback;

sub create_biblio {
    my ($title) = @_;

    my $biblio = Koha::Biblio->new( { title => $title, datecreated => '2019-01-01' } )->store;
    my $biblioitem = Koha::Biblioitem->new({biblionumber => $biblio->biblionumber})->store;

    return $biblio->biblionumber;
}

sub create_item {
    my ( $biblionumber, $barcode ) = @_;

    Koha::Items->search( { barcode => $barcode } )->delete;
    my $builder = t::lib::TestBuilder->new;
    my $item    = $builder->build(
        {
            source => 'Item',
            value  => {
                biblionumber     => $biblionumber,
                barcode          => $barcode,
            }
        }
    );

    return $item->{itemnumber};
}
