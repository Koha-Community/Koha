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
use C4::Reserves;
use C4::Items;

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
})->store;

my $reserve_id = C4::Reserves::AddReserve($branchcode, $borrowernumber,
    $biblionumber, undef, 1, undef, undef, undef, '', $itemnumber);

# Add another reserve to be able to change first reserve's rank
my $reserve_id2 = C4::Reserves::AddReserve($branchcode, $borrowernumber2,
    $biblionumber, undef, 2, undef, undef, undef, '', $itemnumber);

my $suspend_until = DateTime->now->add(days => 10)->ymd;
my $expirationdate = DateTime->now->add(days => 10)->ymd;

my $post_data = {
    borrowernumber => int($borrowernumber),
    biblionumber => int($biblionumber),
    itemnumber => int($itemnumber),
    branchcode => $branchcode,
    expirationdate => $expirationdate,
};
my $put_data = {
    priority => 2,
    suspend_until => $suspend_until
};

subtest "Test endpoints without authentication" => sub {
    plan tests => 8;
    $t->get_ok('/api/v1/holds')
      ->status_is(401);
    $t->post_ok('/api/v1/holds' => json => $post_data)
      ->status_is(401);
    $t->put_ok('/api/v1/holds/0' => json => $put_data)
      ->status_is(401);
    $t->delete_ok('/api/v1/holds/0')
      ->status_is(401);
};


subtest "Test endpoints without permission" => sub {
    plan tests => 10;

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx) # reserveforothers permission
      ->status_is(403);
    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data );
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/0" => json => $put_data );
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/0");
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
};
subtest "Test endpoints without permission, but accessing own object" => sub {
    plan tests => 37;

    my $reserve_id3 = C4::Reserves::AddReserve($branchcode, $nopermission->{'borrowernumber'},
    $biblionumber, undef, 2, undef, undef, undef, '', $itemnumber, 'W');
    # try to delete my own hold while it's waiting; an error should occur
    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id3" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_is('/error', 'Hold is already in transfer or waiting and cannot be cancelled by patron.');
    # reset the hold's found status; after that, cancellation should work
    Koha::Holds->find($reserve_id3)->found('')->store;
    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id3" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)
      ->status_is(200);
    is(Koha::Holds->find({ borrowernumber => $nopermission->{borrowernumber} }), undef, "Hold deleted.");

    my $borrno_tmp = $post_data->{'borrowernumber'};
    $post_data->{'borrowernumber'} = int $nopermission->{'borrowernumber'};

    subtest 'test patron restrictions, POST' => sub {
        $nopermission_patron->set({ gonenoaddress => 1 })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' => 'Reserve cannot be placed. Reason: gonenoaddress');
        $nopermission_patron->set({ gonenoaddress => 0 })->store;

        $nopermission_patron->set({ debarred => "9999-12-31" })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' => 'Reserve cannot be placed. Reason: debarred');
        $nopermission_patron->set({ debarred => undef })->store;

        $nopermission_patron->set({ dateexpiry => "2000-01-01" })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' => 'Reserve cannot be placed. Reason: cardexpired');
        $nopermission_patron->set({ dateexpiry => "0000-00-00" })->store;

        $nopermission_patron->set({ lost => 1 })->store;
        $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' =>
                    "Patron's card has been marked as 'lost'. Access forbidden.");
        $nopermission_patron->set({ lost => 0 })->store;
    };

    subtest 'test patron restrictions, PUT' => sub {
        my $reserve_id4 = C4::Reserves::AddReserve($branchcode, $nopermission->{'borrowernumber'},
        $biblionumber, undef, 2, undef, undef, undef, '', $itemnumber, 'W');
        $nopermission_patron->set({ gonenoaddress => 1 })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id4" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' => 'Reserve cannot be modified. Reason: gonenoaddress');
        $nopermission_patron->set({ gonenoaddress => 0 })->store;

        $nopermission_patron->set({ debarred => "9999-12-31" })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id4" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' => 'Reserve cannot be modified. Reason: debarred');
        $nopermission_patron->set({ debarred => undef })->store;

        $nopermission_patron->set({ dateexpiry => "2000-01-01" })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id4" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' => 'Reserve cannot be modified. Reason: cardexpired');
        $nopermission_patron->set({ dateexpiry => "0000-00-00" })->store;

        $nopermission_patron->set({ lost => 1 })->store;
        $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id4" =>
                               json => $post_data);
        $tx->req->cookies({name => 'CGISESSID',
                           value => $session_nopermission->id});
        $t->request_ok($tx) # create hold to myself
          ->status_is(403)
          ->json_is('/error' =>
                    "Patron's card has been marked as 'lost'. Access forbidden.");
        $nopermission_patron->set({ lost => 0 })->store;

        C4::Reserves::CancelReserve({ reserve_id => $reserve_id4 });
    };

    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # create hold to myself
      ->status_is(201)
      ->json_has('/reserve_id');

    $post_data->{'borrowernumber'} = $borrno_tmp;
    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=".$nopermission-> { borrowernumber });
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # get my own holds
      ->status_is(200)
      ->json_is('/0/borrowernumber', $nopermission->{ borrowernumber })
      ->json_is('/0/biblionumber', $biblionumber)
      ->json_is('/0/itemnumber', $itemnumber)
      ->json_is('/0/expirationdate', $expirationdate)
      ->json_is('/0/branchcode', $branchcode);

    $reserve_id3 = Koha::Holds->find({ borrowernumber => $nopermission->{borrowernumber} })->reserve_id;
    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id3" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # create hold to myself
      ->status_is(200)
      ->json_is('/reserve_id', $reserve_id3)
      ->json_like('/suspend_until', qr/${suspend_until}T00:00:00\+\d\d:\d\d/)
      ->json_is('/priority', 3);

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id3" => json => {
        branchcode => $branchcode2
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # create hold to myself
      ->status_is(200)
      ->json_is('/reserve_id', $reserve_id3)
      ->json_is('/branchcode', $branchcode2);

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id3" => json => {
        suspend_until => $suspend_until
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # create hold to myself
      ->status_is(200)
      ->json_is('/reserve_id', $reserve_id3)
      ->json_is('/suspend', Mojo::JSON->true)
      ->json_like('/suspend_until', qr/^$suspend_until/);

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id3" => json => {
        suspend => Mojo::JSON->false
    });
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # create hold to myself
      ->status_is(200)
      ->json_is('/reserve_id', $reserve_id3)
      ->json_is('/suspend', Mojo::JSON->false)
      ->json_is('/suspend_until', undef);
};

subtest "Test endpoints with permission" => sub {
    plan tests => 45;

    $tx = $t->ua->build_tx(GET => '/api/v1/holds');
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_has('/2')
      ->json_hasnt('/3');

    $tx = $t->ua->build_tx(GET => '/api/v1/holds?priority=2');
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/borrowernumber', $borrowernumber2)
      ->json_hasnt('/1');

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/reserve_id', $reserve_id)
      ->json_like('/suspend_until', qr/${suspend_until}T00:00:00\+\d\d:\d\d/)
      ->json_is('/priority', 2);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(404)
      ->json_has('/error');

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(404)
      ->json_has('/error');

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=".$borrower->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session2->id}); # get with borrowers flag
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is([]);

    my $inexisting_borrowernumber = $borrowernumber2*2;
    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=$inexisting_borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is([]);

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id2");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_has('/reserve_id');
    $reserve_id = $t->tx->res->json->{reserve_id};

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/reserve_id', $reserve_id)
      ->json_is('/0/expirationdate', $expirationdate)
      ->json_is('/0/branchcode', $branchcode);

    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_like('/error', qr/itemAlreadyOnHold/);

    $post_data->{biblionumber} = int($biblionumber2);
    $post_data->{itemnumber} = int($itemnumber2);
    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(403)
      ->json_like('/error', qr/tooManyReserves/);
};


$schema->storage->txn_rollback;

sub create_biblio {
    my ($title) = @_;

    my $biblio = Koha::Biblio->new( { title => $title } )->store;
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
