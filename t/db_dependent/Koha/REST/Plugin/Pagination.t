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

use Koha::Patrons;

use t::lib::TestBuilder;

app->log->level('error');

plugin 'Koha::REST::Plugin::Pagination';

my $schema = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

# Add 10 known 'Jonathan' patrons
my @patron_ids;
for my $i ( 1 .. 10 ) {
    push @patron_ids, $builder->build_object({ class => 'Koha::Patrons', value => { firstname => 'Jonathan' } })->id;
}
# Add two non-Jonathans
push @patron_ids, $builder->build_object({ class => 'Koha::Patrons' })->id;
push @patron_ids, $builder->build_object({ class => 'Koha::Patrons' })->id;

# For add_pagination_headers()

get '/empty' => sub {
    my $c = shift;
    $c->render( json => { ok => 1 }, status => 200 );
};

get '/pagination_headers' => sub {
    my $c = shift;

    my $args = $c->req->params->to_hash;

    my $result_set = Koha::Patrons->search(
        { borrowernumber => \@patron_ids }
    );

    my $rows = ($args->{_per_page}) ?
                        ( $args->{_per_page} == -1 ) ?  undef : $args->{_per_page}
                        : C4::Context->preference('RESTdefaultPageSize');

    my $objects_rs = $result_set->search( { firstname => 'Jonathan' } ,{ page => $args->{_page} // 1, rows => $rows });

    $c->stash('koha.pagination.page'         => $args->{_page});
    $c->stash('koha.pagination.per_page'     => $args->{_per_page});
    $c->stash('koha.pagination.base_total'   => $result_set->count);
    $c->stash('koha.pagination.query_params' => $args);
    $c->stash('koha.pagination.total'        => $objects_rs->is_paged ? $objects_rs->pager->total_entries : $objects_rs->count);

    $c->add_pagination_headers;

    $c->render( json => { ok => 1 }, status => 200 );
};

# For dbic_merge_pagination

get '/dbic_merge_pagination' => sub {
    my $c = shift;
    my $filter = { firstname => 'Kyle', surname => 'Hall' };
    $filter = $c->dbic_merge_pagination({ filter => $filter, params => { _page => 1, _per_page => 3 } });
    $c->render( json => $filter, status => 200 );
};

# The tests

use Test::More tests => 2;
use Test::Mojo;

use t::lib::Mocks;

subtest 'add_pagination_headers() tests' => sub {

    plan tests => 109;

    my $t = Test::Mojo->new;

    $t->get_ok('/empty')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count'      => undef, 'X-Total-Count is undefined' )
      ->header_is( 'X-Base-Total-Count' => undef, 'X-Base-Total-Count is undefined' )
      ->header_is( 'Link'               => undef, 'Link is undefined' );

    $t->get_ok('/pagination_headers?firstname=Jonathan&_page=2&_per_page=3')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count correctly set' )
      ->header_is( 'X-Base-Total-Count' => 12, 'X-Base-Total-Count correctly set' )
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

    $t->get_ok('/pagination_headers?firstname=Jonathan&_page=1&_per_page=3')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count correctly set' )
      ->header_is( 'X-Base-Total-Count' => 12, 'X-Base-Total-Count correctly set' )
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

    $t->get_ok('/pagination_headers?firstname=Jonathan&_page=4&_per_page=3')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count correctly set' )
      ->header_is( 'X-Base-Total-Count' => 12, 'X-Base-Total-Count correctly set' )
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
    $t->get_ok('/pagination_headers?firstname=Jonathan&_page=2')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count correctly set' )
      ->header_is( 'X-Base-Total-Count' => 12, 'X-Base-Total-Count correctly set' )
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

    $t->get_ok('/pagination_headers?firstname=Jonathan&_per_page=3')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count header present, even without page param' )
      ->header_is( 'X-Base-Total-Count' => 12, 'X-Base-Total-Count correctly set' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="prev",/, 'First page, no previous' )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=2.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="next",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=3.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=4.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="last"/ );

    $t->get_ok('/pagination_headers?firstname=Jonathan&_per_page=-1')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count header present, with per_page=-1' )
      ->header_is( 'X-Base-Total-Count' => 12, 'X-Base-Total-Count correctly set' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="next",/, 'No next page, all resources are fetched' )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="last"/ );

    $t->get_ok('/pagination_headers?firstname=Jonathan&_per_page=-1&_page=100')
      ->status_is( 200 )
      ->header_is( 'X-Total-Count' => 10, 'X-Total-Count header present, with per_page=-1' )
      ->header_is( 'X-Base-Total-Count' => 12, 'X-Base-Total-Count correctly set' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="prev",/, 'First page, no previous' )
      ->header_unlike( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="next",/, 'No next page, all resources are fetched' )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="first",/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*per_page=-1.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*page=1.*>; rel="last"/ )
      ->header_like( 'Link' => qr/<http:\/\/.*\?.*firstname=Jonathan.*>; rel="last"/ );
};

subtest 'dbic_merge_pagination() tests' => sub {

    plan tests => 3;

    my $t = Test::Mojo->new;

    $t->get_ok('/dbic_merge_pagination')
      ->status_is(200)
      ->json_is({ firstname => 'Kyle', surname => 'Hall', page => 1, rows => 3 });
};
