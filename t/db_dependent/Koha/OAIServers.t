#!/usr/bin/perl

# Copyright 2015 Koha Development team
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
use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use t::lib::TestBuilder;
use Koha::Database;
use Koha::OAIServer;
use Koha::OAIServers;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'new, find and delete tests' => sub {
    plan tests => 4;
    $schema->storage->txn_begin;
    my $nb_of_oais = Koha::OAIServers->search->count;
    my $new_oai_1  = Koha::OAIServer->new(
        {
            endpoint   => 'my_host1.org',
            oai_set    => 'set1',
            servername => 'my_test_1',
            dataformat => 'oai_dc',
            recordtype => 'biblio',
        }
    )->store;
    my $new_oai_2 = Koha::OAIServer->new(
        {
            endpoint   => 'my_host2.org',
            oai_set    => 'set2',
            servername => 'my_test_2',
            dataformat => 'marcxml',
            recordtype => 'authority',
        }
    )->store;

    like( $new_oai_1->id, qr|^\d+$|, 'Adding a new oai server should have set the id' );
    is( Koha::OAIServers->search->count, $nb_of_oais + 2, 'The 2 oai servers should have been added' );

    my $retrieved_oai_1 = Koha::OAIServers->find( $new_oai_1->id );
    is(
        $retrieved_oai_1->servername, $new_oai_1->servername,
        'Find a oai server by id should return the correct oai server'
    );

    $retrieved_oai_1->delete;
    is( Koha::OAIServers->search->count, $nb_of_oais + 1, 'Delete should have deleted the oai server' );

    $schema->storage->txn_rollback;
};

subtest 'Check NOT NULL without default values' => sub {
    plan tests => 5;
    $schema->storage->txn_begin;
    local $SIG{__WARN__} = sub { };    # TODO Needed it for suppressing DBIx warns

    my $server = Koha::OAIServer->new(
        {
            oai_set    => 'set3',
            dataformat => 'marcxml',
            recordtype => 'biblio',
        }
    );

    throws_ok { $server->store } 'DBIx::Class::Exception', 'Exception on empty endpoint';
    like( $@->{msg}, qr/'endpoint' doesn't have a default value/, 'Verified that DBIx blamed endpoint' );

    $server->endpoint('endpoint_added');
    throws_ok { $server->store } 'DBIx::Class::Exception', 'Exception on empty servername';
    like( $@->{msg}, qr/'servername' doesn't have a default value/, 'Verified that DBIx blamed servername' );

    $server->servername('servername_added');

    lives_ok { $server->store } 'No exceptions anymore';

    $schema->storage->txn_rollback;
};
