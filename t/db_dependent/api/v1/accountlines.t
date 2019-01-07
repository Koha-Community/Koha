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


use Test::More tests => 3;
use Test::Mojo;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Auth;
use C4::Context;

use Koha::Database;
use Koha::Account::Lines;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new();

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

$ENV{REMOTE_ADDR} = '127.0.0.1';
my $t = Test::Mojo->new('Koha::REST::V1');

my $path = '/api/v1/accountlines';

subtest 'list() tests' => sub {
    plan tests => 13;

    $schema->storage->txn_begin;

    my ($librarian, $session) = create_user_and_session(1024);
    my ($borrower, $borrowersession) = create_user_and_session(0);
    my ($borrower2, undef) = create_user_and_session(0);

    my $borrowernumber = $borrower->{borrowernumber};
    my $borrowernumber2 = $borrower2->{borrowernumber};

    Koha::Account::Lines->search->delete;
    Koha::Account::Line->new({
        borrowernumber => $borrowernumber,
        amount => 20, accounttype => 'A', amountoutstanding => 20
    })->store;
    Koha::Account::Line->new({
        borrowernumber => $borrowernumber,
        amount => 40, accounttype => 'F', amountoutstanding => 40
    })->store;
    Koha::Account::Line->new({
        borrowernumber => $borrowernumber2,
        amount => 80, accounttype => 'F', amountoutstanding => 80
    })->store;

    my ($bibnum, $title, $bibitemnum) = create_helper_biblio({
        itemtype => 'BK',
        remainder_of_title => 'Remainder'
    });
    $bibitemnum = Koha::Biblioitem->new({
        biblionumber => $bibnum,
        biblioitemnumber => $bibitemnum,
    })->store->biblioitemnumber unless Koha::Biblioitems->find($bibitemnum);
    my $item = Koha::Item->new({
        biblionumber => $bibnum,
        biblioitemnumber => $bibitemnum,
    })->store;
    Koha::Account::Line->new({
        borrowernumber => $borrowernumber2,
        amount => 20, accounttype => 'A', amountoutstanding => 20,
        description => $item->itemnumber,
        itemnumber => $item->itemnumber,
    })->store;

    $t->get_ok($path)
      ->status_is(401);

    my $tx = $t->ua->build_tx(GET => "$path?borrowernumber=$borrowernumber2");
    $tx->req->cookies({name => 'CGISESSID', value => $borrowersession->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(GET => "$path?borrowernumber=$borrowernumber");
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    my $json = $t->tx->res->json;
    ok(ref $json eq 'ARRAY', 'response is a JSON array');
    ok(scalar @$json == 2, 'response array contains 2 elements');

    $tx = $t->ua->build_tx(GET => $path);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    $json = $t->tx->res->json;
    ok(ref $json eq 'ARRAY', 'response is a JSON array');
    ok(scalar @$json == 4, 'response array contains 4 elements');
    is($json->[3]->{description} => 'Silence in the library', 'Itemnumber converted');

    $schema->storage->txn_rollback;
};

subtest 'edit() tests' => sub {
    plan tests => 10;

    $schema->storage->txn_begin;

    my ($librarian, $session) = create_user_and_session(1024);
    my ($borrower, $borrowersession) = create_user_and_session(0);

    Koha::Account::Line->new({
        borrowernumber => $borrower->{borrowernumber},
        amount => 20, accounttype => 'A', amountoutstanding => 20
    })->store;

    my $put_data = {
        'amount' => -19,
        'amountoutstanding' => -19
    };

    $t->put_ok("/api/v1/accountlines/-9999" => json => {'amount' => -5})
    ->status_is(401);

    my $tx = $t->ua->build_tx( PUT => "$path/-9999" => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
        ->status_is(404);

    my $accountline_to_edit = Koha::Account::Lines->search({
        borrowernumber => $borrower->{borrowernumber}
    })->unblessed()->[0];

    $tx = $t->ua->build_tx(PUT => "$path/$accountline_to_edit->{accountlines_id}"
                           => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $borrowersession->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(403);

    $tx = $t->ua->build_tx(PUT => "$path/$accountline_to_edit->{accountlines_id}"
            => json => $put_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
        ->status_is(200);

    my $accountline_edited = Koha::Account::Lines->search({
        borrowernumber => $borrower->{borrowernumber}
    })->unblessed()->[0];

    is($accountline_edited->{amount}, '-19.000000');
    is($accountline_edited->{amountoutstanding}, '-19.000000');

    $schema->storage->txn_rollback;
};

subtest 'post() tests' => sub {
    plan tests => 21;

    $schema->storage->txn_begin;

    my ($librarian, $session) = create_user_and_session(1024);
    my ($borrower, $borrowersession) = create_user_and_session(0);
    my ($borrower2, undef) = create_user_and_session(0);

    Koha::Account::Line->new({
        borrowernumber => $borrower->{borrowernumber},
        amount => 20, accounttype => 'A', amountoutstanding => 20
    })->store;
    Koha::Account::Line->new({
        borrowernumber => $borrower->{borrowernumber},
        amount => 40, accounttype => 'F', amountoutstanding => 40
    })->store;
    Koha::Account::Line->new({
        borrowernumber => $borrower->{borrowernumber},
        amount => 80, accounttype => 'F', amountoutstanding => 80
    })->store;
    Koha::Account::Line->new({
        borrowernumber => $borrower->{borrowernumber},
        amount => 10, accounttype => 'F', amountoutstanding => 10
    })->store;

    $t->post_ok("$path/-9999/payment" => json => {amount => 5})
      ->status_is(401);

    my $tx = $t->ua->build_tx(POST => "$path/-9999/payment" =>
                              json => { amount => 1000 });
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(404);

    my $accountline_to_pay = Koha::Account::Lines->search({
        borrowernumber => $borrower->{borrowernumber},
        amount => 20
    })->unblessed()->[0];
    $tx = $t->ua->build_tx(
        POST => "$path/$accountline_to_pay->{accountlines_id}/payment"
    );
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400);

    $tx = $t->ua->build_tx(
        POST => "$path/$accountline_to_pay->{accountlines_id}/payment"
                 => json => { amount => 0 }
    );
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400);

    $tx = $t->ua->build_tx(
        POST => "$path/$accountline_to_pay->{accountlines_id}/payment"
                => json => { amount => "no" }
    );
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400);

    $tx = $t->ua->build_tx(
        POST => "$path/$accountline_to_pay->{accountlines_id}/payment"
                => json => { amount => 20 }
    );
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);

    my $accountline_paid = Koha::Account::Lines->search({
        borrowernumber => $borrower->{borrowernumber},
        amount => -20
    })->unblessed()->[0];
    ok($accountline_paid);

    # Partial payment tests
    my $post_data = {
        'amount' => 17,
        'note' => 'Partial payment'
    };
    
    $tx = $t->ua->build_tx(POST => "$path/-9999/payment"=> json => $post_data);
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
        ->status_is(404);
    
    my $accountline_to_partiallypay = Koha::Account::Lines->search({
        borrowernumber => $borrower->{borrowernumber},
        amount => 80
    })->unblessed()->[0];
    $tx = $t->ua->build_tx(
        POST => "$path/$accountline_to_partiallypay->{accountlines_id}/payment"
                => json => {amount => 'foo'}
    );
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(400);
    
    $tx = $t->ua->build_tx(
        POST => "$path/$accountline_to_partiallypay->{accountlines_id}/payment"
                    => json => $post_data
    );
    $tx->req->cookies({name => 'CGISESSID', value => $session->id});
    $tx->req->env({REMOTE_ADDR => '127.0.0.1'});
    $t->request_ok($tx)
      ->status_is(200);
    
    $accountline_to_partiallypay = Koha::Account::Lines->search({
        borrowernumber => $borrower->{borrowernumber},
        amount => 80
    })->unblessed()->[0];
    is($accountline_to_partiallypay->{amountoutstanding}, '63.000000');
    
    my $accountline_partiallypaid = Koha::Account::Lines->search({
        borrowernumber => $borrower->{borrowernumber},
        amount => -17
    })->unblessed()->[0];
    ok($accountline_partiallypaid);

    $schema->storage->txn_rollback;
};

sub create_user_and_session {
    my ($flags) = @_;

    my $categorycode = $builder->build({ source => 'Category' })->{categorycode};
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};

    my $user = $builder->build({
        source => 'Borrower',
        value => {
            branchcode   => $branchcode,
            categorycode => $categorycode,
            flags        => $flags,
            lost         => 0,
        }
    });

    # Create a session for the authorized user
    my $session = t::lib::Mocks::mock_session({borrower => $user});

    return ($user, $session);
}

sub create_helper_biblio {
    my $params = shift;
    my $itemtype = $params->{itemtype};
    my $remainder = $params->{remainder_of_title};
    my ($bibnum, $title, $bibitemnum);
    my $bib = MARC::Record->new();
    $title = 'Silence in the library';
    my @title_subfields;
    push @title_subfields, (a => $title);
    push @title_subfields, (b => $remainder) if $remainder;
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', @title_subfields),
        MARC::Field->new('942', ' ', ' ', c => $itemtype),
    );
    return ($bibnum, $title, $bibitemnum) = C4::Biblio::AddBiblio($bib, '');
    warn "bibnum $bibnum title $title bibitemnum $bibitemnum";
}

1;
