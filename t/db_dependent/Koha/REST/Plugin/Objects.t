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
use Koha::AuthorisedValueCategories;
use Koha::AuthorisedValues;
use Koha::Cities;
use Koha::Biblios;
use Koha::Patrons;

use Mojo::JSON qw(encode_json);

# Dummy app for testing the plugin
use Mojolicious::Lite;

app->log->level('error');

plugin 'Koha::REST::Plugin::Objects';
plugin 'Koha::REST::Plugin::Query';
plugin 'Koha::REST::Plugin::Pagination';

get '/cities' => sub {
    my $c = shift;
    $c->validation->output($c->req->params->to_hash);
    $c->stash_embed( { spec => { parameters => [ { name => 'x-koha-embed', items => { enum => ['+strings'] } } ] } } );
    my $cities = $c->objects->search(Koha::Cities->new);
    $c->render( status => 200, json => $cities );
};

get '/cities/rs' => sub {
    my $c = shift;
    $c->validation->output( $c->req->params->to_hash );
    $c->stash_embed;
    my $cities = $c->objects->search_rs( Koha::Cities->new );

    $c->render( status => 200, json => { count => $cities->count } );
};

get '/cities/:city_id' => sub {
    my $c = shift;
    my $id = $c->stash("city_id");
    $c->stash_embed( { spec => { parameters => [ { name => 'x-koha-embed', items => { enum => ['+strings'] } } ] } } );
    my $city = $c->objects->find(Koha::Cities->new, $id);
    $c->render( status => 200, json => $city );
};

get '/orders' => sub {
    my $c = shift;
    $c->stash('koha.embed', ( { fund => {} } ) );
    $c->validation->output($c->req->params->to_hash);
    my $orders = $c->objects->search(Koha::Acquisition::Orders->new);
    $c->render( status => 200, json => $orders );
};

get '/orders/:order_id' => sub {
    my $c = shift;
    $c->stash('koha.embed', ( { fund => {} } ) );
    my $id = $c->stash("order_id");
    my $order = $c->objects->find(Koha::Acquisition::Orders->new, $id);
    $c->render( status => 200, json => $order );
};

get '/biblios' => sub {
    my $c = shift;
    my $output = $c->req->params->to_hash;
    $output->{query} = $c->req->json if defined $c->req->json;
    my $headers = $c->req->headers->to_hash;
    $output->{'x-koha-query'} = $headers->{'x-koha-query'} if defined $headers->{'x-koha-query'};
    $c->validation->output($output);
    my $biblios_set = Koha::Biblios->new;
    $c->stash("koha.embed", {
        "suggestions" => {
            children => {
                "suggester" => {}
            }
        }
    });
    my $biblios = $c->objects->search($biblios_set);
    $c->render( status => 200, json => {count => scalar(@$biblios), biblios => $biblios} );
};

get '/libraries/:library_id_1/:library_id_2' => sub {

    my $c = shift;

    # Emulate a public route by stashing the is_public value
    $c->stash( 'is_public' => 1 );

    my $library_id_1 = $c->param('library_id_1');
    my $library_id_2 = $c->param('library_id_2');

    my $libraries_rs = Koha::Libraries->search(
        { branchcode => [ $library_id_1, $library_id_2 ] },
        { order_by   => 'branchname' }
    );
    my $libraries    = $c->objects->search( $libraries_rs );

    $c->render(
        status => 200,
        json   => $libraries
    );
};

get '/my_patrons' => sub {

    my $c = shift;

    my $patrons = $c->objects->search( scalar Koha::Patrons->search( {}, { order_by   => 'borrowernumber' }) );

    $c->render(
        status => 200,
        json   => $patrons
    );
};

get '/cities/:city_id/rs' => sub {
    my $c = shift;
    $c->validation->output( $c->req->params->to_hash );
    $c->stash_embed;
    my $city_id = $c->param('city_id');
    my $city    = $c->objects->find_rs( Koha::Cities->new, $city_id );

    $c->render( status => 200, json => { name => $city->city_name } );
};

# The tests
use Test::More tests => 18;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;

my $schema  = Koha::Database->new()->schema();
my $builder = t::lib::TestBuilder->new;

subtest 'objects.search helper' => sub {

    plan tests => 50;

    $schema->storage->txn_begin;

    # Remove existing cities to have more control on the search results
    Koha::Cities->delete;

    # Create three sample cities that match the query. This makes sure we
    # always have a "next" link regardless of Mojolicious::Plugin::OpenAPI version.
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
    $builder->build_object({
        class => 'Koha::Cities',
        value => {
            city_name => 'Manuelab'
        }
    });

    my $t = Test::Mojo->new;
    $t->get_ok('/cities?name=manuel&_per_page=1&_page=1')
        ->status_is(200)
        ->header_like( 'Link' => qr/<http:\/\/.*[\?&]_page=2.*>; rel="next",/ )
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
    $t->get_ok('/cities?name=manuel&_per_page=4&_page=1&_match=starts_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_has('/2')
        ->json_hasnt('/3')
        ->json_is('/0/name' => 'Manuel')
        ->json_is('/1/name' => 'Manuela')
        ->json_is('/2/name' => 'Manuelab');

    # _match=ends_with
    $t->get_ok('/cities?name=manuel&_per_page=4&_page=1&_match=ends_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/name' => 'Manuel')
        ->json_is('/1/name' => 'Emanuel');

    # _match=exact
    $t->get_ok('/cities?name=manuel&_per_page=4&_page=1&_match=exact')
        ->status_is(200)
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/name' => 'Manuel');

    # _match=contains
    $t->get_ok('/cities?name=manuel&_per_page=4&_page=1&_match=contains')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_has('/2')
        ->json_has('/3')
        ->json_hasnt('/4')
        ->json_is('/0/name' => 'Manuel')
        ->json_is('/1/name' => 'Manuela')
        ->json_is('/2/name' => 'Manuelab')
        ->json_is('/3/name' => 'Emanuel');

    # Add 20 more cities
    for ( 1..20 ) {
        $builder->build_object({ class => 'Koha::Cities' });
    }

    t::lib::Mocks::mock_preference('RESTdefaultPageSize', 20 );
    $t->get_ok('/cities')
      ->status_is(200);

    my $response_count = scalar @{ $t->tx->res->json };
    is( $response_count, 20, 'RESTdefaultPageSize is honoured by default (20)' );

    t::lib::Mocks::mock_preference('RESTdefaultPageSize', 5 );
    $t->get_ok('/cities')
      ->status_is(200);

    $response_count = scalar @{ $t->tx->res->json };
    is( $response_count, 5, 'RESTdefaultPageSize is honoured by default (5)' );

    $t->get_ok('/cities?_page=1&_per_page=-1')
      ->status_is(200);

    $response_count = scalar @{ $t->tx->res->json };
    is( $response_count, 24, '_per_page=-1 means all resources' );

    $t->get_ok('/cities?_page=100&_per_page=-1')
      ->status_is(200);

    $response_count = scalar @{ $t->tx->res->json };
    is( $response_count, 24, 'When _per_page=-1 the page param is not considered' );

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, sorting on mapped column' => sub {

    plan tests => 42;

    $schema->storage->txn_begin;

    # Have complete control over the existing cities to ease testing
    Koha::Cities->delete;

    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'A', city_country => 'Argentina' } });
    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'B', city_country => 'Argentina' } });
    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'C', city_country => 'Argentina' } });
    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'C', city_country => 'Belarus' } });

    my $t = Test::Mojo->new;
    # CSV-param
    $t->get_ok('/cities?_order_by=%2Bname,-country')
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_is('/0/name' => 'A')
      ->json_is('/1/name' => 'B')
      ->json_is('/2/name' => 'C')
      ->json_is('/2/country' => 'Belarus')
      ->json_is('/3/name' => 'C')
      ->json_is('/3/country' => 'Argentina')
      ->json_hasnt('/4');

    # Multi-param: traditional
    $t->get_ok('/cities?_order_by=%2Bname&_order_by=-country')
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_is('/0/name' => 'A')
      ->json_is('/1/name' => 'B')
      ->json_is('/2/name' => 'C')
      ->json_is('/2/country' => 'Belarus')
      ->json_is('/3/name' => 'C')
      ->json_is('/3/country' => 'Argentina')
      ->json_hasnt('/4');

    # Multi-param: PHP Style, Passes validation as above, subsequntly explodes
    $t->get_ok('/cities?_order_by[]=%2Bname&_order_by[]=-country')
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_is('/0/name' => 'A')
      ->json_is('/1/name' => 'B')
      ->json_is('/2/name' => 'C')
      ->json_is('/2/country' => 'Belarus')
      ->json_is('/3/name' => 'C')
      ->json_is('/3/country' => 'Argentina')
      ->json_hasnt('/4');

    # Single-param
    $t->get_ok('/cities?_order_by=-name')
      ->status_is(200)
      ->json_has('/0')
      ->json_has('/1')
      ->json_is('/0/name' => 'C')
      ->json_is('/1/name' => 'C')
      ->json_is('/2/name' => 'B')
      ->json_is('/3/name' => 'A')
      ->json_hasnt('/4');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, encoding' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    Koha::Cities->delete;

    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'A', city_country => 'Argentina' } });
    $builder->build_object({ class => 'Koha::Cities', value => { city_name => 'B', city_country => '❤Argentina❤' } });

    my $t = Test::Mojo->new;
    $t->get_ok('/cities?q={"country": "❤Argentina❤"}')
      ->status_is(200)
      ->json_has('/0')
      ->json_hasnt('/1')
      ->json_is('/0/name' => 'B');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, X-Total-Count and X-Base-Total-Count' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    Koha::Cities->delete;

    my $long_city_name = 'Llanfairpwllgwyngyll';
    for my $i ( 1 .. length($long_city_name) ) {
        $builder->build_object(
            {
                class => 'Koha::Cities',
                value => {
                    city_name    => substr( $long_city_name, 0, $i ),
                    city_country => 'Wales'
                }
            }
        );
    }

    my $t = Test::Mojo->new;
    $t->get_ok('/cities?name=L&_per_page=10&_page=1&_match=starts_with')
      ->status_is(200)
      ->header_is( 'X-Total-Count' => 20, 'X-Total-Count header present' )
      ->header_is( 'X-Base-Total-Count' => 20, 'X-Base-Total-Count header present' );

    $t->get_ok('/cities?name=Llan&_per_page=10&_page=1&_match=starts_with')
      ->status_is(200)
      ->header_is( 'X-Total-Count' => 17, 'X-Total-Count header present' )
      ->header_is('X-Base-Total-Count' => 20, 'X-Base-Total-Count header present' );

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, embed' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $order = $builder->build_object({ class => 'Koha::Acquisition::Orders' });

    my $t = Test::Mojo->new;
    $t->get_ok('/orders?order_id=' . $order->ordernumber)
      ->json_is('/0',$order->to_api({ embed => ( { fund => {} } ) }));

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper with query parameter' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object( { class => "Koha::Patrons" } );
    my $patron2 = $builder->build_object( { class => "Koha::Patrons" } );
    my $biblio1 = $builder->build_sample_biblio;
    my $biblio2 = $builder->build_sample_biblio;
    my $biblio3 = $builder->build_sample_biblio;
    my $suggestion1 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron1->borrowernumber, biblionumber => $biblio1->biblionumber} } );
    my $suggestion2 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio2->biblionumber} } );
    my $suggestion3 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio3->biblionumber} } );

    my $t = Test::Mojo->new;
    $t->get_ok('/biblios' => json => {"suggestions.suggester.patron_id" => $patron1->borrowernumber })
      ->json_is('/count' => 1, 'there should be 1 biblio with suggestions of patron 1');

    $t->get_ok('/biblios' => json => {"suggestions.suggester.patron_id" => $patron2->borrowernumber })
      ->json_is('/count' => 2, 'there should be 2 biblios with suggestions of patron 2');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper with q parameter' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object( { class => "Koha::Patrons" } );
    my $patron2 = $builder->build_object( { class => "Koha::Patrons" } );
    my $biblio1 = $builder->build_sample_biblio;
    my $biblio2 = $builder->build_sample_biblio;
    my $biblio3 = $builder->build_sample_biblio;
    my $suggestion1 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron1->borrowernumber, biblionumber => $biblio1->biblionumber} } );
    my $suggestion2 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio2->biblionumber} } );
    my $suggestion3 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio3->biblionumber} } );

    my $t = Test::Mojo->new;
    $t->get_ok('/biblios?q={"suggestions.suggester.patron_id": "'.$patron1->borrowernumber.'"}')
      ->json_is('/count' => 1, 'there should be 1 biblio with suggestions of patron 1');

    $t->get_ok('/biblios?q={"suggestions.suggester.patron_id": "'.$patron2->borrowernumber.'"}')
      ->json_is('/count' => 2, 'there should be 2 biblios with suggestions of patron 2');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper with x-koha-query header' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object( { class => "Koha::Patrons" } );
    my $patron2 = $builder->build_object( { class => "Koha::Patrons" } );
    my $biblio1 = $builder->build_sample_biblio;
    my $biblio2 = $builder->build_sample_biblio;
    my $biblio3 = $builder->build_sample_biblio;
    my $suggestion1 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron1->borrowernumber, biblionumber => $biblio1->biblionumber} } );
    my $suggestion2 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio2->biblionumber} } );
    my $suggestion3 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio3->biblionumber} } );

    my $t = Test::Mojo->new;
    $t->get_ok('/biblios' => {'x-koha-query' => '{"suggestions.suggester.patron_id": "'.$patron1->borrowernumber.'"}'})
      ->json_is('/count' => 1, 'there should be 1 biblio with suggestions of patron 1');

    $t->get_ok('/biblios' => {'x-koha-query' => '{"suggestions.suggester.patron_id": "'.$patron2->borrowernumber.'"}'})
      ->json_is('/count' => 2, 'there should be 2 biblios with suggestions of patron 2');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper with all query methods' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object( { class => "Koha::Patrons" , value => {firstname=>'patron1'} } );
    my $patron2 = $builder->build_object( { class => "Koha::Patrons" , value => {firstname=>'patron2'} } );
    my $biblio1 = $builder->build_sample_biblio;
    my $biblio2 = $builder->build_sample_biblio;
    my $biblio3 = $builder->build_sample_biblio;
    my $suggestion1 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron1->borrowernumber, biblionumber => $biblio1->biblionumber} } );
    my $suggestion2 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio2->biblionumber} } );
    my $suggestion3 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio3->biblionumber} } );

    my $t = Test::Mojo->new;
    $t->get_ok('/biblios?q={"suggestions.suggester.firstname": "'.$patron1->firstname.'"}' => {'x-koha-query' => '{"suggestions.suggester.patron_id": "'.$patron1->borrowernumber.'"}'} => json => {"suggestions.suggester.cardnumber" => $patron1->cardnumber})
      ->json_is('/count' => 1, 'there should be 1 biblio with suggestions of patron 1');

    $t->get_ok('/biblios?q={"suggestions.suggester.firstname": "'.$patron2->firstname.'"}' => {'x-koha-query' => '{"suggestions.suggester.patron_id": "'.$patron2->borrowernumber.'"}'} => json => {"suggestions.suggester.cardnumber" => $patron2->cardnumber})
      ->json_is('/count' => 2, 'there should be 2 biblios with suggestions of patron 2');

    $t->get_ok('/biblios?q={"suggestions.suggester.firstname": "'.$patron1->firstname.'"}' => {'x-koha-query' => '{"suggestions.suggester.patron_id": "'.$patron2->borrowernumber.'"}'} => json => {"suggestions.suggester.cardnumber" => $patron2->cardnumber})
      ->json_is('/count' => 0, 'there shouldn\'t be biblios where suggester has patron1 fistname and patron2 id');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper order by embedded columns' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object( { class => "Koha::Patrons" , value => {firstname=>'patron1'} } );
    my $patron2 = $builder->build_object( { class => "Koha::Patrons" , value => {firstname=>'patron2'} } );
    my $biblio1 = $builder->build_sample_biblio;
    my $biblio2 = $builder->build_sample_biblio;
    my $suggestion1 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron1->borrowernumber, biblionumber => $biblio1->biblionumber} } );
    my $suggestion2 = $builder->build_object( { class => "Koha::Suggestions", value => { suggestedby => $patron2->borrowernumber, biblionumber => $biblio2->biblionumber} } );

    my $t = Test::Mojo->new;
    $t->get_ok('/biblios?_order_by=-suggestions.suggester.firstname' => json => [{"me.biblio_id" => $biblio1->biblionumber}, {"me.biblio_id" => $biblio2->biblionumber}])
      ->json_is('/biblios/0/biblio_id' => $biblio2->biblionumber, 'Biblio 2 should be first')
      ->json_is('/biblios/1/biblio_id' => $biblio1->biblionumber, 'Biblio 1 should be second');

    $schema->storage->txn_rollback;
};

subtest 'objects.search_rs helper' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Remove existing cities to have more control on the search results
    Koha::Cities->delete;

 # Create three sample cities that match the query. This makes sure we
 # always have a "next" link regardless of Mojolicious::Plugin::OpenAPI version.
    $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name => 'city1'
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name => 'city2'
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name => 'city3'
            }
        }
    );

    my $t = Test::Mojo->new;
    $t->get_ok('/cities/rs')->status_is(200)->json_is( '/count' => 3 );

    $schema->storage->txn_rollback;
};

subtest 'objects.find helper' => sub {

    plan tests => 9;

    my $t = Test::Mojo->new;

    $schema->storage->txn_begin;

    my $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
    my $city_2 = $builder->build_object( { class => 'Koha::Cities' } );

    $t->get_ok( '/cities/' . $city_1->id )
      ->status_is(200)
      ->json_is( $city_1->to_api );

    $t->get_ok( '/cities/' . $city_2->id )
      ->status_is(200)
      ->json_is( $city_2->to_api );

    # Remove the city
    my $city_2_id = $city_2->id;
    $city_2->delete;
    $t->get_ok( '/cities/' . $city_2_id )
      ->status_is(200)
      ->json_is( undef );

    $schema->storage->txn_rollback;
};

subtest 'objects.find helper, embed' => sub {

    plan tests => 2;

    my $t = Test::Mojo->new;

    $schema->storage->txn_begin;

    my $order = $builder->build_object({ class => 'Koha::Acquisition::Orders' });

    $t->get_ok( '/orders/' . $order->ordernumber )
      ->json_is( $order->to_api( { embed => ( { fund => {} } ) } ) );

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, public requests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries', value => { branchname => 'A' } });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries', value => { branchname => 'B' } });

    my $t = Test::Mojo->new;

    $t->get_ok( '/libraries/'.$library_1->id.'/'.$library_2->id )
      ->json_is('/0' => $library_1->to_api({ public => 1 }), 'Public representation of $library_1 is retrieved')
      ->json_is('/1' => $library_2->to_api({ public => 1 }), 'Public representation of $library_2 is retrieved');

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper, search_limited() tests' => sub {

    plan tests => 9;

    $schema->storage->txn_begin;

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });

    my $patron_1 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $library_1->id } });
    my $patron_2 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $library_1->id } });
    my $patron_3 = $builder->build_object({ class => 'Koha::Patrons', value => { branchcode => $library_2->id } });

    my @libraries_where_can_see_patrons = ( $library_1->id, $library_2->id );

    my $t = Test::Mojo->new;

    my $mocked_patron = Test::MockModule->new('Koha::Patron');
    $mocked_patron->mock( 'libraries_where_can_see_patrons', sub
        {
            return @libraries_where_can_see_patrons;
        }
    );

    my $patron = $builder->build_object(
        {
            class => 'Koha::Patrons',
            value => { flags => 2**4 }    # borrowers flag = 4
        }
    );

    t::lib::Mocks::mock_userenv({ patron => $patron });

    $t->get_ok( "/my_patrons?q=" . encode_json( { library_id => [ $library_1->id, $library_2->id ] } ) )
      ->status_is(200)
      ->json_is( '/0/patron_id' => $patron_1->id )
      ->json_is( '/1/patron_id' => $patron_2->id )
      ->json_is( '/2/patron_id' => $patron_3->id );

    @libraries_where_can_see_patrons = ( $library_2->id );

    my $res = $t->get_ok( "/my_patrons?q=" . encode_json( { library_id => [ $library_1->id, $library_2->id ] } ) )
      ->status_is(200)
      ->json_is( '/0/patron_id' => $patron_3->id, 'Returns the only allowed patron' )
      ->tx->res->json;

    is( scalar @{$res}, 1, 'Only one patron returned' );

    $schema->storage->txn_rollback;
};

subtest 'objects.find helper with expanded authorised values' => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $t = Test::Mojo->new;

    Koha::AuthorisedValues->search( { category => 'Countries' } )->delete;
    Koha::AuthorisedValueCategories->search( { category_name => 'Countries' } )
      ->delete;

    my $cat = $builder->build_object(
        {
            class => 'Koha::AuthorisedValueCategories',
            value => { category_name => 'Countries' }
        }
    );
    my $fr = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'FR',
                lib              => 'France',
                category         => $cat->category_name
            }
        }
    );
    my $us = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'US',
                lib              => 'United States of America',
                category         => $cat->category_name
            }
        }
    );
    my $ar = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'AR',
                lib              => 'Argentina',
                category         => $cat->category_name
            }
        }
    );

    my $city_class = Test::MockModule->new('Koha::City');
    $city_class->mock(
        'strings_map',
        sub {
            my ($self, $params) = @_;
            use Koha::AuthorisedValues;

            my $av = Koha::AuthorisedValues->find(
                {
                    authorised_value => $self->city_country,
                    category         => 'Countries'
                }
            );

            return {
                city_country => {
                    category => $av->category,
                    str      => ( $params->{public} ) ? $av->lib_opac : $av->lib,
                    type     => 'av',
                }
            };
        }
    );

    my $manuel = $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name    => 'Manuel',
                city_country => 'AR'
            }
        }
    );
    my $manuela = $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name    => 'Manuela',
                city_country => 'US'
            }
        }
    );

    $t->get_ok( '/cities/' . $manuel->id => { 'x-koha-embed' => '+strings' } )
      ->status_is(200)->json_is( '/name' => 'Manuel' )
      ->json_has('/_strings')
      ->json_is( '/_strings/country/type'     => 'av' )
      ->json_is( '/_strings/country/category' => $cat->category_name )
      ->json_is( '/_strings/country/str'      => $ar->lib );

    $t->get_ok( '/cities/' . $manuel->id => { 'x-koha-embed' => '' } )
      ->status_is(200)->json_is( '/name' => 'Manuel' )
      ->json_hasnt('/_strings');

    $t->get_ok( '/cities/' . $manuela->id => { 'x-koha-embed' => '+strings' } )
      ->status_is(200)->json_is( '/name' => 'Manuela' )
      ->json_has('/_strings')
      ->json_is( '/_strings/country/type'     => 'av' )
      ->json_is( '/_strings/country/category' => $cat->category_name )
      ->json_is( '/_strings/country/str'      => $us->lib );

    $schema->storage->txn_rollback;
};

subtest 'objects.search helper with expanded authorised values' => sub {

    plan tests => 24;

    my $t = Test::Mojo->new;

    $schema->storage->txn_begin;

    Koha::AuthorisedValues->search( { category => 'Countries' } )->delete;
    Koha::AuthorisedValueCategories->search( { category_name => 'Countries' } )
      ->delete;

    my $cat = $builder->build_object(
        {
            class => 'Koha::AuthorisedValueCategories',
            value => { category_name => 'Countries' }
        }
    );
    my $fr = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'FR',
                lib              => 'France',
                category         => $cat->category_name
            }
        }
    );
    my $us = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'US',
                lib              => 'United States of America',
                category         => $cat->category_name
            }
        }
    );
    my $ar = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => {
                authorised_value => 'AR',
                lib              => 'Argentina',
                category         => $cat->category_name
            }
        }
    );

    my $city_class = Test::MockModule->new('Koha::City');
    $city_class->mock(
        'strings_map',
        sub {
            my ($self, $params) = @_;
            use Koha::AuthorisedValues;

            my $av = Koha::AuthorisedValues->find(
                {
                    authorised_value => $self->city_country,
                    category         => 'Countries'
                }
            );

            return {
                city_country => {
                    category => $av->category,
                    str      => ( $params->{public} ) ? $av->lib_opac : $av->lib,
                    type     => 'av',
                }
            };
        }
    );


    $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name    => 'Manuel',
                city_country => 'AR'
            }
        }
    );
    $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name    => 'Manuela',
                city_country => 'US'
            }
        }
    );

    $t->get_ok( '/cities?name=manuel&_per_page=4&_page=1&_match=starts_with' =>
          { 'x-koha-embed' => '+strings' } )->status_is(200)
      ->json_has('/0')->json_has('/1')->json_hasnt('/2')
      ->json_is( '/0/name' => 'Manuel' )
      ->json_has('/0/_strings')
      ->json_is( '/0/_strings/country/str'      => $ar->lib )
      ->json_is( '/0/_strings/country/type'     => 'av' )
      ->json_is( '/0/_strings/country/category' => $cat->category_name )
      ->json_is( '/1/name' => 'Manuela' )
      ->json_has('/1/_strings')
      ->json_is( '/1/_strings/country/str' => $us->lib )
      ->json_is( '/1/_strings/country/type'     => 'av' )
      ->json_is( '/1/_strings/country/category' => $cat->category_name );

    $t->get_ok( '/cities?name=manuel&_per_page=4&_page=1&_match=starts_with' )->status_is(200)
      ->json_has('/0')->json_has('/1')->json_hasnt('/2')
      ->json_is( '/0/name' => 'Manuel' )->json_hasnt('/0/_strings')
      ->json_is( '/1/name' => 'Manuela' )->json_hasnt('/1/_strings');


    $schema->storage->txn_rollback;
};

subtest 'objects.find_rs helper' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    # Remove existing cities to have more control on the search results
    Koha::Cities->delete;

 # Create three sample cities that match the query. This makes sure we
 # always have a "next" link regardless of Mojolicious::Plugin::OpenAPI version.
    my $city1 = $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name => 'city1'
            }
        }
    );
    my $city2 = $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name => 'city2'
            }
        }
    );
    my $city3 = $builder->build_object(
        {
            class => 'Koha::Cities',
            value => {
                city_name => 'city3'
            }
        }
    );

    my $t = Test::Mojo->new;

    $t->get_ok( '/cities/' . $city1->id . '/rs' )->status_is(200)
      ->json_is( '/name' => 'city1' );

    $t->get_ok( '/cities/' . $city2->id . '/rs' )->status_is(200)
      ->json_is( '/name' => 'city2' );

    $t->get_ok( '/cities/' . $city3->id . '/rs' )->status_is(200)
      ->json_is( '/name' => 'city3' );

    $schema->storage->txn_rollback;
};
