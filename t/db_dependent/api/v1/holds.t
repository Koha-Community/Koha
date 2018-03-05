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

use Test::More tests => 5;
use Test::Mojo;
use t::lib::TestBuilder;
use t::lib::Mocks;

use DateTime;

use C4::Context;
use C4::Reserves;
use C4::Items;

use Koha::Database;
use Koha::DateUtils;
use Koha::Biblios;
use Koha::Biblioitems;
use Koha::Items;
use Koha::Patrons;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

$schema->storage->txn_begin;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');
my $tx;

my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
my $itemtype = $builder->build({ source => 'Itemtype' })->{itemtype};

# User without any permissions
my $nopermission = $builder->build({
    source => 'Borrower',
    value => {
        branchcode   => $branchcode,
        categorycode => $categorycode,
        flags        => 0
    }
});
my $session_nopermission = C4::Auth::get_session('');
$session_nopermission->param('number', $nopermission->{ borrowernumber });
$session_nopermission->param('id', $nopermission->{ userid });
$session_nopermission->param('ip', '127.0.0.1');
$session_nopermission->param('lasttime', time());
$session_nopermission->flush;

my $patron_1 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $categorycode,
            branchcode   => $branchcode,
            surname      => 'Test Surname',
            flags        => 80, #borrowers and reserveforothers flags
        }
    }
);

my $patron_2 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $categorycode,
            branchcode   => $branchcode,
            surname      => 'Test Surname 2',
            flags        => 16, # borrowers flag
        }
    }
);

my $patron_3 = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => {
            categorycode => $categorycode,
            branchcode   => $branchcode,
            surname      => 'Test Surname 3',
            flags        => 64, # reserveforothers flag
        }
    }
);

# Get sessions
my $session = C4::Auth::get_session('');
$session->param('number', $patron_1->borrowernumber);
$session->param('id', $patron_1->userid);
$session->param('ip', '127.0.0.1');
$session->param('lasttime', time());
$session->flush;
my $session2 = C4::Auth::get_session('');
$session2->param('number', $patron_2->borrowernumber);
$session2->param('id', $patron_2->userid);
$session2->param('ip', '127.0.0.1');
$session2->param('lasttime', time());
$session2->flush;
my $session3 = C4::Auth::get_session('');
$session3->param('number', $patron_3->borrowernumber);
$session3->param('id', $patron_3->userid);
$session3->param('ip', '127.0.0.1');
$session3->param('lasttime', time());
$session3->flush;

my $biblionumber = create_biblio('RESTful Web APIs');
my $item = create_item($biblionumber, 'TEST000001');
my $itemnumber = $item->{itemnumber};
$item->{itype} = $itemtype;
C4::Items::ModItem($item, $biblionumber, $itemnumber);

my $biblionumber2 = create_biblio('RESTful Web APIs');
my $item2 = create_item($biblionumber2, 'TEST000002');
my $itemnumber2 = $item2->{itemnumber};

my $dbh = C4::Context->dbh;
$dbh->do('DELETE FROM reserves');
$dbh->do('DELETE FROM issuingrules');
    $dbh->do(q{
        INSERT INTO issuingrules (categorycode, branchcode, itemtype, reservesallowed)
        VALUES (?, ?, ?, ?)
    }, {}, '*', '*', '*', 1);

my $reserve_id = C4::Reserves::AddReserve($branchcode, $patron_1->borrowernumber,
    $biblionumber, undef, 1, undef, undef, undef, '', $itemnumber);

# Add another reserve to be able to change first reserve's rank
my $reserve_id2 = C4::Reserves::AddReserve($branchcode, $patron_2->borrowernumber,
    $biblionumber, undef, 2, undef, undef, undef, '', $itemnumber);

my $suspend_until = DateTime->now->add(days => 10)->ymd;
my $expirationdate = DateTime->now->add(days => 10)->ymd;

my $post_data = {
    borrowernumber => int($patron_1->borrowernumber),
    biblionumber => int($biblionumber),
    itemnumber => int($itemnumber),
    branchcode => $branchcode,
    expirationdate => $expirationdate,
};
my $put_data = {
    priority => 2,
    suspend_until => $suspend_until,
};

subtest "Test endpoints without authentication" => sub {
    plan tests => 8;
    $t->get_ok('/api/v1/holds')
      ->status_is(401);
    $t->post_ok('/api/v1/holds')
      ->status_is(401);
    $t->put_ok('/api/v1/holds/0')
      ->status_is(401);
    $t->delete_ok('/api/v1/holds/0')
      ->status_is(401);
};


subtest "Test endpoints without permission" => sub {
    plan tests => 10;

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx) # no permission
      ->status_is(403);
    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=" . $patron_1->borrowernumber);
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
    plan tests => 16;

    my $borrno_tmp = $post_data->{'borrowernumber'};
    $post_data->{'borrowernumber'} = int $nopermission->{'borrowernumber'};
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

    my $reserve_id3 = Koha::Holds->find({ borrowernumber => $nopermission->{borrowernumber} })->reserve_id;
    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id3" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session_nopermission->id});
    $t->request_ok($tx)    # create hold to myself
      ->status_is(200)->json_is( '/reserve_id', $reserve_id3 )->json_is(
        '/suspend_until',
        output_pref(
            {
                dateformat => 'rfc3339',
                dt => dt_from_string( $suspend_until . ' 00:00:00', 'sql' )
            }
        )
      )
      ->json_is( '/priority',   2 )
      ->json_is( '/itemnumber', $itemnumber );
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
      ->json_is('/0/borrowernumber', $nopermission->{borrowernumber})
      ->json_hasnt('/1');

    $tx = $t->ua->build_tx(PUT => "/api/v1/holds/$reserve_id" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)->status_is(200)->json_is( '/reserve_id', $reserve_id )
      ->json_is(
        '/suspend_until',
        output_pref(
            {
                dateformat => 'rfc3339',
                dt => dt_from_string( $suspend_until . ' 00:00:00', 'sql' )
            }
        )
      )
      ->json_is( '/priority', 2 );

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

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session2->id}); # get with borrowers flag
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is([]);

    my $inexisting_borrowernumber = $patron_2->borrowernumber * 2;
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

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=" . $patron_1->borrowernumber);
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


subtest 'Reserves with itemtype' => sub {
    plan tests => 9;

    my $post_data = {
        borrowernumber => int($patron_1->borrowernumber),
        biblionumber => int($biblionumber),
        branchcode => $branchcode,
        itemtype => $itemtype,
    };

    $tx = $t->ua->build_tx(DELETE => "/api/v1/holds/$reserve_id");
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(200);

    $tx = $t->ua->build_tx(POST => "/api/v1/holds" => json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session3->id});
    $t->request_ok($tx)
      ->status_is(201)
      ->json_has('/reserve_id');

    $reserve_id = $t->tx->res->json->{reserve_id};

    $tx = $t->ua->build_tx(GET => "/api/v1/holds?borrowernumber=" . $patron_1->borrowernumber);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $t->request_ok($tx)
      ->status_is(200)
      ->json_is('/0/reserve_id', $reserve_id)
      ->json_is('/0/itemtype', $itemtype);
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

    return $item;
}
