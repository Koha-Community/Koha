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

app->log->level('error');

plugin 'Koha::REST::Plugin::Query';

get '/empty' => sub {
    my $c = shift;
    $c->render( json => undef, status => 200 );
};

get '/query' => sub {
    my $c     = shift;
    my $input = {
        _page     => 2,
        _per_page => 3,
        firstname => 'Manuel',
        surname   => 'Cohen Arazi'
    };
    my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($input);
    $c->render(
        json => {
            filtered_params => $filtered_params,
            reserved_params => $reserved_params
        },
        status => 200
    );
};

get '/query_full' => sub {
    my $c     = shift;
    my $input = {
        _match    => 'exact',
        _order_by => 'blah',
        _page     => 2,
        _per_page => 3,
        firstname => 'Manuel',
        surname   => 'Cohen Arazi'
    };
    my ( $filtered_params, $reserved_params ) = $c->extract_reserved_params($input);
    $c->render(
        json => {
            filtered_params => $filtered_params,
            reserved_params => $reserved_params
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
            params     => { _match => 'exact', _order_by => 'uno|-dos|+tres' }
        }
    );
    $c->render( json => $attributes, status => 200 );
};

# The tests

use Test::More tests => 2;
use Test::Mojo;

subtest 'extract_reserved_params() tests' => sub {

    plan tests => 8;

    my $t = Test::Mojo->new;

    $t->get_ok('/query')->status_is(200)
      ->json_is( '/filtered_params' =>
          { firstname => 'Manuel', surname => 'Cohen Arazi' } )
      ->json_is( '/reserved_params' => { _page => 2, _per_page => 3 } );

    $t->get_ok('/query_full')->status_is(200)
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
        } );

};

subtest 'dbic_merge_sorting() tests' => sub {

    plan tests => 5;

    my $t = Test::Mojo->new;

    $t->get_ok('/dbic_merge_sorting')
      ->status_is(200)
      ->json_is( '/a' => 'a', 'Existing values are kept (a)' )
      ->json_is( '/b' => 'b', 'Existing values are kept (b)' )
      ->json_is( '/order_by' => [ 'uno', { -desc => 'dos' }, { -asc => 'tres' } ] );
};
