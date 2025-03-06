#!/usr/bin/perl

# Copyright 2024 Hypernova Oy
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Patrons;
use Try::Tiny;

# Dummy app for testing the plugin
use Mojolicious::Lite;

plugin 'Koha::REST::Plugin::Auth::PublicRoutes';

post '/public' => sub {
    my $c      = shift;
    my $params = $c->req->json;

    $c->stash( 'koha.user' => Koha::Patrons->find( $params->{'user'} ) );
    $c->stash( 'is_public' => 1 );

    try {
        my $patron_id = $params->{'patron_id'};
        $c->auth->public($patron_id);
        $c->render( status => 200, json => "OK" );
    } catch {
        if ( ref($_) eq 'Koha::Exceptions::REST::Public::Authentication::Required' ) {
            $c->render( status => 401, json => { message => 'authentication_required' } );
        } elsif ( ref($_) eq 'Koha::Exceptions::REST::Public::Unauthorized' ) {
            $c->render( status => 403, json => { message => 'unauthorized' } );
        } else {
            $c->render( status => 500, json => { message => 'other error' } );
        }
    }
};

post '/public_guarantor' => sub {
    my $c      = shift;
    my $params = $c->req->json;

    $c->stash( 'koha.user' => Koha::Patrons->find( $params->{'user'} ) );
    $c->stash( 'is_public' => 1 );

    try {
        my $patron_id = $params->{'patron_id'};
        $c->auth->public_guarantor($patron_id);
        $c->render( status => 200, json => "OK" );
    } catch {
        if ( ref($_) eq 'Koha::Exceptions::REST::Public::Authentication::Required' ) {
            $c->render( status => 401, json => { message => 'authentication_required' } );
        } elsif ( ref($_) eq 'Koha::Exceptions::REST::Public::Unauthorized' ) {
            $c->render( status => 403, json => { message => 'unauthorized' } );
        } else {
            $c->render( status => 500, json => { message => 'other error' } );
        }
    }
};

use Test::More tests => 2;
use Test::Mojo;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;

my $schema  = Koha::Database->new()->schema();
my $builder = t::lib::TestBuilder->new;

# FIXME: sessionStorage defaults to mysql, but it seems to break transaction handling
# this affects the other REST api tests
t::lib::Mocks::mock_preference( 'SessionStorage', 'tmp' );

subtest 'auth.public helper' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $unprivileged_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $another_patron      = $builder->build_object( { class => 'Koha::Patrons' } );

    my $t = Test::Mojo->new;

    $t->post_ok( '/public' => json => { patron_id => $another_patron->borrowernumber } )->status_is(401)
        ->json_is( { message => 'authentication_required' } );

    $t->post_ok( '/public' => json =>
            { user => $unprivileged_patron->borrowernumber, patron_id => $another_patron->borrowernumber } )
        ->status_is(403)->json_is( { message => 'unauthorized' } );

    $t->post_ok( '/public' => json =>
            { user => $unprivileged_patron->borrowernumber, patron_id => $unprivileged_patron->borrowernumber } )
        ->status_is(200)->json_is('OK');

    $schema->storage->txn_rollback;
};

subtest 'auth.public_guarantor helper' => sub {
    plan tests => 12;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'test' );

    my $guarantee = $builder->build_object( { class => 'Koha::Patrons' } );
    my $guarantor = $builder->build_object( { class => 'Koha::Patrons' } );
    $guarantee->add_guarantor( { guarantor_id => $guarantor->borrowernumber, relationship => 'test' } );
    my $another_patron = $builder->build_object( { class => 'Koha::Patrons' } );

    my $t = Test::Mojo->new;

    $t->post_ok( '/public_guarantor' => json => { patron_id => $another_patron->borrowernumber } )->status_is(401)
        ->json_is( { message => 'authentication_required' } );

    $t->post_ok( '/public_guarantor' => json =>
            { user => $guarantor->borrowernumber, patron_id => $another_patron->borrowernumber } )->status_is(403)
        ->json_is( { message => 'unauthorized' } );

    # user is not a guarantor of themself
    $t->post_ok(
        '/public_guarantor' => json => { user => $guarantor->borrowernumber, patron_id => $guarantor->borrowernumber } )
        ->status_is(403)->json_is( { message => 'unauthorized' } );

    $t->post_ok(
        '/public_guarantor' => json => { user => $guarantor->borrowernumber, patron_id => $guarantee->borrowernumber } )
        ->status_is(200)->json_is('OK');

    $schema->storage->txn_rollback;
};

1;
