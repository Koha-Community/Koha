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

plugin 'Koha::REST::Plugin::Pagination';

# For add_pagination_headers()

get '/empty' => sub {
    my $c = shift;
    $c->render( json => { ok => 1 }, status => 200 );
};

get '/pagination_headers' => sub {
    my $c = shift;
    $c->add_pagination_headers({ total => 10, params => { _page => 2, _per_page => 3, firstname => 'Jonathan' } });
    $c->render( json => { ok => 1 }, status => 200 );
};

get '/pagination_headers_first_page' => sub {
    my $c = shift;
    $c->add_pagination_headers({ total => 10, params => { _page => 1, _per_page => 3, firstname => 'Jonathan' } });
    $c->render( json => { ok => 1 }, status => 200 );
};

get '/pagination_headers_last_page' => sub {
    my $c = shift;
    $c->add_pagination_headers({ total => 10, params => { _page => 4, _per_page => 3, firstname => 'Jonathan' } });
    $c->render( json => { ok => 1 }, status => 200 );
};

# For dbic_merge_pagination

get '/dbic_merge_pagination' => sub {
    my $c = shift;
    my $filter = { firstname => 'Kyle', surname => 'Hall' };
    $filter = $c->dbic_merge_pagination({ filter => $filter, params => { _page => 1, _per_page => 3 } });
    $c->render( json => $filter, status => 200 );
};

get '/pagination_headers_without_page_size' => sub {
    my $c = shift;
    $c->add_pagination_headers({ total => 10, params => { _page => 2, firstname => 'Jonathan' } });
    $c->render( json => { ok => 1 }, status => 200 );
};

get '/pagination_headers_without_page' => sub {
    my $c = shift;
    $c->add_pagination_headers({ total => 10, params => { _per_page => 4, firstname => 'Jonathan' } });
    $c->render( json => { ok => 1 }, status => 200 );
};

# The tests

use Test::More tests => 2;
use Test::Mojo;

use t::lib::Mocks;

subtest 'add_pagination_headers() tests' => sub {

    plan tests => 64;

    my $t = Test::Mojo->new;

    $t->get_ok('/empty')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => undef, 'X-Total-Count is undefined' )
      ->header_is( 'Link'          => undef, 'Link is undefined' );

    $t->get_ok('/pagination_headers')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count contains the passed value' )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="prev",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_page=1.*>; rel="prev",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="prev",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_page=3.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_page=1.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*_page=4.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="last"/ );

    $t->get_ok('/pagination_headers_first_page')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count contains the passed value' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*>; rel="prev",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="next",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_page=2.*>; rel="next",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="next",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="first",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_page=1.*>; rel="first",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="first",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="last"/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_page=4.*>; rel="last"/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="last"/ );

    $t->get_ok('/pagination_headers_last_page')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count contains the passed value' )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="prev",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_page=3.*>; rel="prev",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="prev",/ )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*>; rel="next",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="first",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_page=1.*>; rel="first",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="first",/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_per_page=3.*>; rel="last"/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*_page=4.*>; rel="last"/ )
      ->header_like(   'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="last"/ );

    t::lib::Mocks::mock_preference('RESTdefaultPageSize', 3);
    $t->get_ok('/pagination_headers_without_page_size')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count contains the passed value' )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="prev",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="prev",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="prev",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=3.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=4.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="last"/ );

    $t->get_ok('/pagination_headers_without_page')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => undef, 'X-Total-Count header absent' )
      ->header_is( 'Link'          => undef, 'Link header absent' );


};

subtest 'dbic_merge_pagination() tests' => sub {

    plan tests => 3;

    my $t = Test::Mojo->new;

    $t->get_ok('/dbic_merge_pagination')
      ->status_is(200)
      ->json_is({ firstname => 'Kyle', surname => 'Hall', page => 1, rows => 3 });
};
