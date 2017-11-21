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
use Koha::Patrons;

# Dummy app for testing the plugin
use Mojolicious::Lite;

app->log->level('error');

plugin 'Koha::REST::Plugin::Objects';
plugin 'Koha::REST::Plugin::Query';
plugin 'Koha::REST::Plugin::Pagination';

get '/patrons' => sub {
    my $c = shift;
    $c->validation->output($c->req->params->to_hash);
    my $patrons = $c->objects->search(Koha::Patrons->new);
    $c->render( status => 200, json => $patrons->TO_JSON );
};


# The tests

use Test::More tests => 1;
use Test::Mojo;

use t::lib::TestBuilder;
use Koha::Database;

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

my $builder = t::lib::TestBuilder->new;
$builder->build({
    source => 'Borrower',
    value => {
        firstname => 'Manuel',
    },
});
$builder->build({
    source => 'Borrower',
    value => {
        firstname => 'Manuel',
    },
});

subtest 'objects.search helper' => sub {

    plan tests => 6;

    my $t = Test::Mojo->new;

    $t->get_ok('/patrons?firstname=Manuel&_per_page=1&_page=1')
        ->status_is(200)
        ->header_like( 'Link' => qr/<http:\/\/.*\?.*&_page=2.*>; rel="next",/ )
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/firstname' => 'Manuel');
};

$schema->storage->txn_rollback();
