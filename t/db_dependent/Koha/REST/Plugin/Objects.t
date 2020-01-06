#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Acquisition::Orders;
use Koha::Cities;

# Dummy app for testing the plugin
use Mojolicious::Lite;

app->log->level('error');

plugin 'Koha::REST::Plugin::Objects';
plugin 'Koha::REST::Plugin::Query';
plugin 'Koha::REST::Plugin::Pagination';

get '/cities' => sub {
    my $c = shift;
    $c->validation->output($c->req->params->to_hash);
    my $cities = $c->objects->search(Koha::Cities->new);
    $c->render( status => 200, json => $cities );
};

get '/orders' => sub {
    my $c = shift;
    $c->stash('koha.embed', ( { fund => {} } ) );
    $c->validation->output($c->req->params->to_hash);
    my $orders = $c->objects->search(Koha::Acquisition::Orders->new);
    $c->render( status => 200, json => $orders );
};

# The tests
use Test::More tests => 3;
use Test::Mojo;

use t::lib::TestBuilder;
use Koha::Database;

my $t = Test::Mojo->new;

my $schema  = Koha::Database->new()->schema();
my $builder = t::lib::TestBuilder->new;

subtest 'objects.search helper' => sub {

    plan tests => 34;

    $schema->storage->txn_begin;

    # Remove existing cities to have more control on the search restuls
    Koha::Cities->delete;

    # Create two sample patrons that match the query
    $builder->build_object({
        class => 'Koha::Cities',
        value => {
            city_name => 'Manuel'
        }
    });
    $builder->build_object({
        class => 'Koha::Cities',
        value => {
            city_name => 'Manuela'
        }
    });

    $t->get_ok('/cities?name=manuel&_per_page=1&_page=1')
        ->status_is(200)
        ->header_like( 'Link' => qr/<http:\/\/.*\?.*&_page=2.*>; rel="next",/ )
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/name' => 'Manuel');

    $builder->build_object({
        class => 'Koha::Cities',
        value => {
            city_name => 'Emanuel'
        }
    });

    # _match=starts_with
    $t->get_ok('/cities?name=manuel&_per_page=3&_page=1&_match=starts_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/name' => 'Manuel')
        ->json_is('/1/name' => 'Manuela');

    # _match=ends_with
    $t->get_ok('/cities?name=manuel&_per_page=3&_page=1&_match=ends_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/name' => 'Manuel')
        ->json_is('/1/name' => 'Emanuel');

    # _match=exact
    $t->get_ok('/cities?name=manuel&_per_page=3&_page=1&_match=exact')
        ->status_is(200)
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/name' => 'Manuel');

    # _match=contains
    $t->get_ok('/cities?name=manuel&_per_page=3&_page=1&_match=contains')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_has('/2')
        ->json_hasnt('/3')
        ->json_is('/0/name' => 'Manuel')
        ->json_is('/1/name' => 'Manuela')
        ->json_is('/2/name' => 'Emanuel');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, sorting on mapped column' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    # Have complete control over the existing cities to ease testing
    Koha::Cities->delete;

    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'A', city_country => 'Argentina' } });
    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'B', city_country => 'Argentina' } });

    $t->get_ok('/cities?_order_by=%2Bname&_order_by=+country')
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_hasnt('/2')
      ->json_is('/0/name' => 'A')
      ->json_is('/1/name' => 'B');

    $t->get_ok('/cities?_order_by=-name')
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_hasnt('/2')
      ->json_is('/0/name' => 'B')
      ->json_is('/1/name' => 'A');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, embed' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $order = $builder->build_object({ class => 'Koha::Acquisition::Orders' });

    $t->get_ok('/orders?order_id=' . $order->ordernumber)
      ->json_is('/0',$order->to_api({ embed => ( { fund => {} } ) }));

    $schema->storage->txn_rollback;
};
