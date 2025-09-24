#!/usr/bin/perl

# Copyright 2022 Theke Solutions
#
# This file is part of Koha
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Patrons;
use Koha::Auth::Identity::Provider::Domains;
use Koha::Patrons;
use Try::Tiny;

# Dummy app for testing the plugin
use Mojolicious::Lite;

plugin 'Koha::REST::Plugin::Auth::IdP';

post '/register_user' => sub {
    my $c      = shift;
    my $params = $c->req->json;
    try {
        my $domain = Koha::Auth::Identity::Provider::Domains->find( $params->{domain_id} );
        my $patron = $c->auth->register(
            {
                data      => $params->{data},
                domain    => $domain,
                interface => $params->{interface}
            }
        );
        $c->render( status => 200, json => $patron->unblessed );
    } catch {
        if ( ref($_) eq 'Koha::Exceptions::Auth::Unauthorized' ) {
            $c->render( status => 401, json => { message => 'unauthorized' } );
        } else {
            $c->render( status => 500, json => { message => 'other error' } );
        }
    }
};

post '/start_session' => sub {
    my $c      = shift;
    my $userid = my $params = $c->req->json->{userid};

    try {
        my $patron = Koha::Patrons->search( { userid => $userid } );
        my ( $status, $cookie, $session_id ) = $c->auth->session( { patron => $patron->next, interface => 'opac' } );
        $c->render( status => 200, json => { status => $status } );
    } catch {
        if ( ref($_) eq 'Koha::Exceptions::Auth::CannotCreateSession' ) {
            $c->render( status => 401, json => { message => 'unauthorized' } );
        } else {
            $c->render( status => 500, json => { message => 'other error' } );
        }
    }
};

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;

my $schema  = Koha::Database->new()->schema();
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

subtest 'auth.register helper' => sub {
    plan tests => 6;

    $schema->storage->txn_begin;

    # generate a random patron
    my $patron_to_delete = $builder->build_object( { class => 'Koha::Patrons' } );
    my $userid           = $patron_to_delete->userid;

    # delete patron
    $patron_to_delete->delete;

    my $provider =
        $builder->build_object( { class => 'Koha::Auth::Identity::Providers', value => { matchpoint => 'email' } } );

    my $domain_with_register = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => { identity_provider_id => $provider->id, domain => 'domain1.com', auto_register => 1 }
        }
    );

    my $domain_without_register = $builder->build_object(
        {
            class => 'Koha::Auth::Identity::Provider::Domains',
            value => { identity_provider_id => $provider->id, domain => 'domain2.com', auto_register => 0 }
        }
    );

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $category = $builder->build_object( { class => 'Koha::Patron::Categories' } );

    my $user_data = {
        firstname    => 'test',
        surname      => 'test',
        userid       => $userid,
        branchcode   => $library->branchcode,
        categorycode => $category->categorycode
    };

    my $t = Test::Mojo->new;

    $t->post_ok(
        '/register_user' => json => {
            data => $user_data, domain_id => $domain_with_register->identity_provider_domain_id, interface => 'opac'
        }
    )->status_is(200)->json_has( '/firstname', 'test' );

    $t->post_ok(
        '/register_user' => json => {
            data => $user_data, domain_id => $domain_without_register->identity_provider_domain_id, interface => 'opac'
        }
    )->status_is(401)->json_has( '/message', 'unauthorized' );

    $schema->storage->txn_rollback;
};

subtest 'auth.session helper' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $t = Test::Mojo->new;
    $t->post_ok( '/start_session' => json => { userid => $patron->userid } )->status_is(200)
        ->json_has( '/status', 'ok' );

    $schema->storage->txn_rollback;
};

1;
