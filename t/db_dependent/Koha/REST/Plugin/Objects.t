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
    $c->render( status => 200, json => $patrons );
};

get '/patrons_to_model' => sub {
    my $c = shift;
    $c->validation->output($c->req->params->to_hash);
    my $patrons_set = Koha::Patrons->new;
    my $patrons = $c->objects->search( $patrons_set, \&to_model );
    $c->render( status => 200, json => $patrons );
};

get '/patrons_to_model_to_api' => sub {
    my $c = shift;
    $c->validation->output($c->req->params->to_hash);
    my $patrons_set = Koha::Patrons->new;
    my $patrons = $c->objects->search( $patrons_set, \&to_model, \&to_api );
    $c->render( status => 200, json => $patrons );
};

sub to_model {
    my $params = shift;

    if ( exists $params->{nombre} ) {
        $params->{firstname} = delete $params->{nombre};
    }

    return $params;
}

sub to_api {
    my $params = shift;

    if ( exists $params->{firstname} ) {
        $params->{nombre} = delete $params->{firstname};
    }

    return $params;
}

# The tests
use Test::More tests => 1;
use Test::Mojo;

use t::lib::TestBuilder;
use Koha::Database;

my $schema = Koha::Database->new()->schema();


my $builder = t::lib::TestBuilder->new;

subtest 'objects.search helper' => sub {

    plan tests => 90;

    my $t = Test::Mojo->new;

    $schema->storage->txn_begin;

    # Delete existing patrons
    Koha::Patrons->search->delete;
    # Create two sample patrons that match the query
    $builder->build_object({
        class => 'Koha::Patrons',
        value => {
            firstname => 'Manuel'
        }
    });
    $builder->build_object({
        class => 'Koha::Patrons',
        value => {
            firstname => 'Manuela'
        }
    });

    $t->get_ok('/patrons?firstname=manuel&_per_page=1&_page=1')
        ->status_is(200)
        ->header_like( 'Link' => qr/<http:\/\/.*\?.*&_page=2.*>; rel="next",/ )
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/firstname' => 'Manuel');

    $builder->build_object({
        class => 'Koha::Patrons',
        value => {
            firstname => 'Emanuel'
        }
    });

    # _match=starts_with
    $t->get_ok('/patrons?firstname=manuel&_per_page=3&_page=1&_match=starts_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/firstname' => 'Manuel')
        ->json_is('/1/firstname' => 'Manuela');

    # _match=ends_with
    $t->get_ok('/patrons?firstname=manuel&_per_page=3&_page=1&_match=ends_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/firstname' => 'Manuel')
        ->json_is('/1/firstname' => 'Emanuel');

    # _match=exact
    $t->get_ok('/patrons?firstname=manuel&_per_page=3&_page=1&_match=exact')
        ->status_is(200)
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/firstname' => 'Manuel');

    # _match=contains
    $t->get_ok('/patrons?firstname=manuel&_per_page=3&_page=1&_match=contains')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_has('/2')
        ->json_hasnt('/3')
        ->json_is('/0/firstname' => 'Manuel')
        ->json_is('/1/firstname' => 'Manuela')
        ->json_is('/2/firstname' => 'Emanuel');

    ## _to_model tests
    # _match=starts_with
    $t->get_ok('/patrons_to_model?nombre=manuel&_per_page=3&_page=1&_match=starts_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/firstname' => 'Manuel')
        ->json_is('/1/firstname' => 'Manuela');

    # _match=ends_with
    $t->get_ok('/patrons_to_model?nombre=manuel&_per_page=3&_page=1&_match=ends_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/firstname' => 'Manuel')
        ->json_is('/1/firstname' => 'Emanuel');

    # _match=exact
    $t->get_ok('/patrons_to_model?nombre=manuel&_per_page=3&_page=1&_match=exact')
        ->status_is(200)
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/firstname' => 'Manuel');

    # _match=contains
    $t->get_ok('/patrons_to_model?nombre=manuel&_per_page=3&_page=1&_match=contains')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_has('/2')
        ->json_hasnt('/3')
        ->json_is('/0/firstname' => 'Manuel')
        ->json_is('/1/firstname' => 'Manuela')
        ->json_is('/2/firstname' => 'Emanuel');

    ## _to_model && _to_api tests
    # _match=starts_with
    $t->get_ok('/patrons_to_model_to_api?nombre=manuel&_per_page=3&_page=1&_match=starts_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/nombre' => 'Manuel')
        ->json_is('/1/nombre' => 'Manuela');

    # _match=ends_with
    $t->get_ok('/patrons_to_model_to_api?nombre=manuel&_per_page=3&_page=1&_match=ends_with')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_hasnt('/2')
        ->json_is('/0/nombre' => 'Manuel')
        ->json_is('/1/nombre' => 'Emanuel');

    # _match=exact
    $t->get_ok('/patrons_to_model_to_api?nombre=manuel&_per_page=3&_page=1&_match=exact')
        ->status_is(200)
        ->json_has('/0')
        ->json_hasnt('/1')
        ->json_is('/0/nombre' => 'Manuel');

    # _match=contains
    $t->get_ok('/patrons_to_model_to_api?nombre=manuel&_per_page=3&_page=1&_match=contains')
        ->status_is(200)
        ->json_has('/0')
        ->json_has('/1')
        ->json_has('/2')
        ->json_hasnt('/3')
        ->json_is('/0/nombre' => 'Manuel')
        ->json_is('/1/nombre' => 'Manuela')
        ->json_is('/2/nombre' => 'Emanuel');

    $schema->storage->txn_rollback;
};
