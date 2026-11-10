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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Mojo;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

# Dummy app for testing the plugin
use Mojolicious::Lite;

app->log->level('fatal');

plugin 'Koha::REST::Plugin::Policy';

# Route that refuses the request, returning the policy for the logged-in
# user's branch, or the passed library
get '/checkin_policy' => sub {
    my $c = shift;
    $c->stash( 'koha.user' => $c->app->{_test_user} );
    my $library_id = $c->param('library_id');
    $c->render(
        status => 403,
        json   => {
            error      => 'Refused',
            error_code => 'refused',
            policy     => $c->module_policy( 'Checkin', $library_id ? { library => $library_id } : () ),
        }
    );
};

# Route that requests an unknown module scope
get '/unknown_policy' => sub {
    my $c = shift;
    $c->stash( 'koha.user' => $c->app->{_test_user} );
    $c->render( status => 200, json => { policy => $c->module_policy('NoSuchModuleScope') } );
};

my $t = Test::Mojo->new;

subtest 'module_policy() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'UseRecalls',        'opac_and_staff' );
    t::lib::Mocks::mock_preference( 'SpecifyReturnDate', 0 );
    t::lib::Mocks::mock_preference( 'AudioAlerts',       1 );

    my $user_library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $other_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $patron        = $builder->build_object(
        { class => 'Koha::Patrons', value => { branchcode => $user_library->branchcode, flags => 1 } } );

    app->{_test_user} = $patron;

    $t->get_ok('/checkin_policy')
        ->status_is(403)
        ->json_is( '/policy/module'                      => 'checkin' )
        ->json_is( '/policy/global/audio_alerts'         => Mojo::JSON->true )
        ->json_is( '/policy/checkin/recalls_enabled'     => Mojo::JSON->true )
        ->json_is( '/policy/checkin/specify_return_date' => Mojo::JSON->false )
        ->json_has('/policy/checkin/dropbox_date');

    $t->get_ok( '/checkin_policy?library_id=' . $other_library->branchcode )
        ->status_is(403)
        ->json_is( '/policy/module' => 'checkin' )
        ->json_has('/policy/checkin/exempt_fine');

    my $body = $t->tx->res->json;
    is_deeply(
        [ sort keys %{ $body->{policy} } ], [qw( checkin global module )],
        'The policy is the module policy envelope'
    );

    # A missing policy class is a bug: it explodes
    $t->get_ok('/unknown_policy')->status_is(500);

    $schema->storage->txn_rollback;
};
