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

# Dummy app for testing the plugin
use Mojolicious::Lite;
use Try::Tiny;

use Koha::Cities;
use Koha::Holds;
use Koha::Biblios;
use Koha::Patron::Relationship;

app->log->level('error');

plugin 'Koha::REST::Plugin::Query';

get '/empty' => sub {
    my $c = shift;
    $c->render( json => undef, status => 200 );
};

get '/query' => sub {
    my $c     = shift;
    my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($c->req->params->to_hash);
    $c->render(
        json => {
            filtered_params => $filtered_params,
            reserved_params => $reserved_params
        },
        status => 200
    );
};

get '/query_full/:id/:subid' => sub {
    my $c     = shift;
    my $params = $c->req->params->to_hash;
    $params->{id} = $c->stash->{id};
    $params->{subid} = $c->stash->{subid};
    my ( $filtered_params, $reserved_params, $path_params ) = $c->extract_reserved_params($params);
    $c->render(
        json => {
            filtered_params => $filtered_params,
            reserved_params => $reserved_params,
            path_params => $path_params
        },
        status => 200
    );
};

get '/dbic_merge_sorting' => sub {
    my $c = shift;
    my $attributes = { a => 'a', b => 'b' };
    $attributes = $c->dbic_merge_sorting(
        {
            attributes => $attributes,
            params     => { _match => 'exact', _order_by => [ 'uno', '-dos', '+tres', ' cuatro' ] }
        }
    );
    $c->render( json => $attributes, status => 200 );
};

get '/dbic_merge_sorting_single' => sub {
    my $c = shift;
    my $attributes = { a => 'a', b => 'b' };
    $attributes = $c->dbic_merge_sorting(
        {
            attributes => $attributes,
            params     => { _match => 'exact', _order_by => '-uno' }
        }
    );
    $c->render( json => $attributes, status => 200 );
};

get '/dbic_merge_sorting_result_set' => sub {
    my $c = shift;
    my $attributes = { a => 'a', b => 'b' };
    my $result_set = Koha::Cities->new;
    $attributes = $c->dbic_merge_sorting(
        {
            attributes => $attributes,
            params     => { _match => 'exact', _order_by => [ 'name', '-postal_code', '+country', ' state' ] },
            result_set => $result_set
        }
    );
    $c->render( json => $attributes, status => 200 );
};

get '/dbic_merge_sorting_date' => sub {
    my $c = shift;
    my $attributes = { a => 'a', b => 'b' };
    my $result_set = Koha::Holds->new;
    $attributes = $c->dbic_merge_sorting(
        {
            attributes => $attributes,
            params     => { _match => 'exact', _order_by => [ '-hold_date' ] },
            result_set => $result_set
        }
    );
    $c->render( json => $attributes, status => 200 );
};

get '/dbic_merge_prefetch' => sub {
    my $c = shift;
    my $attributes = {};
    my $result_set = Koha::Holds->new;
    $c->stash('koha.embed', {
            "item" => {},
            "biblio" => {
                children => {
                    "orders" => {}
                }
            }
        });

    $c->dbic_merge_prefetch({
        attributes => $attributes,
        result_set => $result_set
    });

    $c->render( json => $attributes, status => 200 );
};

get '/dbic_merge_prefetch_recursive' => sub {
    my $c = shift;
    my $attributes = {};
    my $result_set = Koha::Patron::Relationship->new;
    $c->stash('koha.embed', {
      "guarantee" => {
        "children" => {
          "article_requests" => {},
          "housebound_profile" => {
            "children" => {
              "housebound_visits" => {}
            }
          },
          "housebound_role" => {}
        }
      }
    });

    $c->dbic_merge_prefetch({
        attributes => $attributes,
        result_set => $result_set
    });

    $c->render( json => $attributes, status => 200 );
};

get '/dbic_merge_prefetch_count' => sub {
    my $c = shift;
    my $attributes = {};
    my $result_set = Koha::Patron::Relationship->new;
    $c->stash('koha.embed', {
            "guarantee_count" => {
              "is_count" => 1
            }
        });

    $c->dbic_merge_prefetch({
        attributes => $attributes,
        result_set => $result_set
    });

    $c->render( json => $attributes, status => 200 );
};

get '/merge_q_params' => sub {
  my $c = shift;
  my $filtered_params = {'biblio_id' => 1};
  my $result_set = Koha::Biblios->new;
  $filtered_params = $c->merge_q_params($filtered_params, $c->req->json->{q}, $result_set);

  $c->render( json => $filtered_params, status => 200 );
};

get '/build_query' => sub {
    my $c = shift;
    my ( $filtered_params, $reserved_params ) =
      $c->extract_reserved_params( $c->req->params->to_hash );
    my $query;
    try {
        $query = $c->build_query_params( $filtered_params, $reserved_params );
        $c->render( json => { query => $query }, status => 200 );
    }
    catch {
        $c->render(
            json => { exception_msg => $_->message, exception_type => ref($_) },
            status => 400
        );
    };
};

get '/stash_embed' => sub {
    my $c = shift;

    $c->stash_embed();
    my $embed   = $c->stash('koha.embed');
    my $strings = $c->stash('koha.strings');

    $c->render(
        status => 200,
        json   => {
            strings => $strings,
            embed   => $embed,
        }
    );
};

get '/stash_overrides' => sub {
    my $c = shift;

    $c->stash_overrides();
    my $overrides = $c->stash('koha.overrides');

    $c->render(
        status => 200,
        json   => $overrides
    );
};

sub to_model {
    my ($args) = @_;
    $args->{three} = delete $args->{tres}
        if exists $args->{tres};
    return $args;
}

# The tests

use Test::More tests => 7;
use Test::Mojo;

subtest 'extract_reserved_params() tests' => sub {

    plan tests => 9;

    my $t = Test::Mojo->new;

    $t->get_ok('/query?_page=2&_per_page=3&firstname=Manuel&surname=Cohen%20Arazi')->status_is(200)
      ->json_is( '/filtered_params' =>
          { firstname => 'Manuel', surname => 'Cohen Arazi' } )
      ->json_is( '/reserved_params' => { _page => 2, _per_page => 3 } );

    $t->get_ok('/query_full/with/path?_match=exact&_order_by=blah&_page=2&_per_page=3&firstname=Manuel&surname=Cohen%20Arazi')->status_is(200)
      ->json_is(
        '/filtered_params' => {
            firstname => 'Manuel',
            surname   => 'Cohen Arazi'
        } )
      ->json_is(
        '/reserved_params' => {
            _page     => 2,
            _per_page => 3,
            _match    => 'exact',
            _order_by => 'blah'
        } )
      ->json_is(
        '/path_params' => {
            id => 'with',
            subid => 'path'
        } );

};

subtest 'dbic_merge_sorting() tests' => sub {

    plan tests => 20;

    my $t = Test::Mojo->new;

    $t->get_ok('/dbic_merge_sorting')->status_is(200)
      ->json_is( '/a' => 'a', 'Existing values are kept (a)' )
      ->json_is( '/b' => 'b', 'Existing values are kept (b)' )->json_is(
        '/order_by' => [
            'uno',
            { -desc => 'dos' },
            { -asc  => 'tres' },
            { -asc  => 'cuatro' }
        ]
      );

    $t->get_ok('/dbic_merge_sorting_result_set')->status_is(200)
      ->json_is( '/a' => 'a', 'Existing values are kept (a)' )
      ->json_is( '/b' => 'b', 'Existing values are kept (b)' )->json_is(
        '/order_by' => [
            'city_name',
            { -desc => 'city_zipcode' },
            { -asc  => 'city_country' },
            { -asc  => 'city_state' }
        ]
      );

    $t->get_ok('/dbic_merge_sorting_date')->status_is(200)
      ->json_is( '/a' => 'a', 'Existing values are kept (a)' )
      ->json_is( '/b' => 'b', 'Existing values are kept (b)' )->json_is(
        '/order_by' => [
            { -desc => 'reservedate' }
        ]
      );

    $t->get_ok('/dbic_merge_sorting_single')->status_is(200)
      ->json_is( '/a' => 'a', 'Existing values are kept (a)' )
      ->json_is( '/b' => 'b', 'Existing values are kept (b)' )->json_is(
        '/order_by' => [
            { '-desc' => 'uno' }
        ]
      );
};

subtest '/dbic_merge_prefetch' => sub {
    plan tests => 10;

    my $t = Test::Mojo->new;

    $t->get_ok('/dbic_merge_prefetch')->status_is(200)
      ->json_is( '/prefetch/0' => { 'biblio' => 'orders' } )
      ->json_is( '/prefetch/1' => 'item' );

    $t->get_ok('/dbic_merge_prefetch_recursive')->status_is(200)
      ->json_is('/prefetch/0' => {
        guarantee => [
          'article_requests',
          {housebound_profile => 'housebound_visits'},
          'housebound_role'
        ]
      });

    $t->get_ok('/dbic_merge_prefetch_count')->status_is(200)
      ->json_is('/prefetch/0' => 'guarantee');
};

subtest '/merge_q_params' => sub {
  plan tests => 3;
  my $t = Test::Mojo->new;

  $t->get_ok('/merge_q_params' => json => {
    q => {
      "-not_bool" => "suggestions.suggester.patron_card_lost",
      "-or" => [
        {
          "creation_date" => {
            "!=" => ["fff", "zzz", "xxx"]
          }
        },
        { "suggestions.suggester.housebound_profile.frequency" => "123" },
        {
          "suggestions.suggester.library_id" => {"like" => "%CPL%"}
        }
      ]
    }
  })->status_is(200)
    ->json_is( '/-and' => [
        {
          "-not_bool" => "suggester.lost",
          "-or" => [
            {
              "datecreated" => {
                "!=" => [
                  "fff",
                  "zzz",
                  "xxx"
                ]
              }
            },
            {
              "housebound_profile.frequency" => 123
            },
            {
              "suggester.branchcode" => {
                "like" => "\%CPL\%"
              }
            }
          ]
        },
        {
          "biblio_id" => 1
        }
      ]);
};

subtest '_build_query_params_from_api' => sub {

    plan tests => 16;

    my $t = Test::Mojo->new;

    # _match => contains
    $t->get_ok('/build_query?_match=contains&title=Ender&author=Orson')
      ->status_is(200)
      ->json_is( '/query' =>
          { author => { like => '%Orson%' }, title => { like => '%Ender%' } } );

    # _match => starts_with
    $t->get_ok('/build_query?_match=starts_with&title=Ender&author=Orson')
      ->status_is(200)
      ->json_is( '/query' =>
          { author => { like => 'Orson%' }, title => { like => 'Ender%' } } );

    # _match => ends_with
    $t->get_ok('/build_query?_match=ends_with&title=Ender&author=Orson')
      ->status_is(200)
      ->json_is( '/query' =>
          { author => { like => '%Orson' }, title => { like => '%Ender' } } );

    # _match => exact
    $t->get_ok('/build_query?_match=exact&title=Ender&author=Orson')
      ->status_is(200)
      ->json_is( '/query' => { author => 'Orson', title => 'Ender' } );

    # _match => blah
    $t->get_ok('/build_query?_match=blah&title=Ender&author=Orson')
      ->status_is(400)
      ->json_is( '/exception_msg'  => 'Invalid value for _match param (blah)' )
      ->json_is( '/exception_type' => 'Koha::Exceptions::WrongParameter' );

};

subtest 'stash_embed() tests' => sub {

    plan tests => 16;

    my $t = Test::Mojo->new;

    $t->get_ok( '/stash_embed' => { 'x-koha-embed' => 'checkouts,checkouts.item' } )
      ->json_is( '/embed' => { checkouts => { children => { item => { } } } } );

    $t->get_ok( '/stash_embed' => { 'x-koha-embed' => 'checkouts,checkouts.item,library' } )
      ->json_is( '/embed' => { checkouts => { children => { item => {} } }, library => {} } );

    $t->get_ok( '/stash_embed' => { 'x-koha-embed' => 'holds+count' } )
      ->json_is( '/embed' => { holds_count => { is_count => 1 } } );

    $t->get_ok( '/stash_embed' => { 'x-koha-embed' => 'holds:count' } )
      ->json_is( '/embed' => { holds_count => { is_count => 1 } } );

    $t->get_ok( '/stash_embed' => { 'x-koha-embed' => 'checkouts,checkouts.item,patron' } )
      ->json_is( '/embed' => {
            checkouts => { children => { item => {} } },
            patron    => {}
        });

    $t->get_ok( '/stash_embed' => { 'x-koha-embed' => 'checkouts,checkouts.item+strings,patron+strings' } )
      ->json_is( '/embed' => {
            checkouts => { children => { item => { strings => 1 } } },
            patron    => { strings => 1 }
        })
      ->json_is( '/strings' => undef );

    $t->get_ok( '/stash_embed' => { 'x-koha-embed' => 'checkouts+strings,checkouts.item,patron,+strings' } )
      ->json_is( '/embed' => {
            checkouts => { children => { item => { } }, strings => 1 },
            patron    => { }
        })
      ->json_is( '/strings' => 1 );
};

subtest 'stash_overrides() tests' => sub {

    plan tests => 6;

    my $t = Test::Mojo->new;

    $t->get_ok( '/stash_overrides' => { 'x-koha-override' => 'any,none,some_other,any,' } )
      ->json_is( { 'any' => 1, 'none' => 1, 'some_other' => 1 } ); # empty string and duplicates are skipped

    $t->get_ok( '/stash_overrides' => { 'x-koha-override' => '' } )
      ->json_is( {} ); # empty string is skipped

    $t->get_ok( '/stash_overrides' => { } )
      ->json_is( {} ); # x-koha-ovverride not passed is skipped

};
