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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 4;
use Test::Exception;

use t::lib::TestBuilder;
use Koha::Database;
use Koha::Z3950Server;
use Koha::Z3950Servers;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'new, find and delete tests' => sub {
    plan tests => 4;
    $schema->storage->txn_begin;
    my $nb_of_z39s = Koha::Z3950Servers->search->count;
    my $new_z39_1  = Koha::Z3950Server->new(
        {
            host       => 'my_host1.org',
            port       => '32',
            db         => 'db1',
            servername => 'my_test_1',
            servertype => 'zed',
            recordtype => 'biblio',
            syntax     => 'USMARC',
            encoding   => 'MARC-8',
        }
    )->store;
    my $new_z39_2 = Koha::Z3950Server->new(
        {
            host       => 'my_host2.org',
            port       => '64',
            db         => 'db2',
            servername => 'my_test_2',
            servertype => 'zed',
            recordtype => 'authority',
            syntax     => 'USMARC',
            encoding   => 'MARC-8',
        }
    )->store;

    like( $new_z39_1->id, qr|^\d+$|, 'Adding a new z39 server should have set the id' );
    is( Koha::Z3950Servers->search->count, $nb_of_z39s + 2, 'The 2 z39 servers should have been added' );

    my $retrieved_z39_1 = Koha::Z3950Servers->find( $new_z39_1->id );
    is(
        $retrieved_z39_1->servername, $new_z39_1->servername,
        'Find a z39 server by id should return the correct z39 server'
    );

    $retrieved_z39_1->delete;
    is( Koha::Z3950Servers->search->count, $nb_of_z39s + 1, 'Delete should have deleted the z39 server' );

    $schema->storage->txn_rollback;
};

subtest 'Host, syntax and encoding are NOT NULL now (BZ 30571)' => sub {
    plan tests => 7;
    $schema->storage->txn_begin;
    local $SIG{__WARN__} = sub { };    # TODO Needed it for suppressing DBIx warns

    my $server = Koha::Z3950Server->new(
        {
            port       => '80',
            db         => 'db',
            servername => 'my_test_3',
            servertype => 'zed',
            recordtype => 'biblio',
        }
    );

    throws_ok { $server->store } 'Koha::Exceptions::Object::NotNull', 'Exception on empty host';
    is( $@->property, 'host', 'Exception identifies the host column' );

    $server->host('host_added.nl');
    throws_ok { $server->store } 'Koha::Exceptions::Object::NotNull', 'Exception on empty syntax';
    is( $@->property, 'syntax', 'Exception identifies the syntax column' );

    $server->syntax('USMARC');
    throws_ok { $server->store } 'Koha::Exceptions::Object::NotNull', 'Exception on empty encoding';
    is( $@->property, 'encoding', 'Exception identifies the encoding column' );

    $server->encoding('utf8');
    lives_ok { $server->store } 'No exceptions anymore';

    $schema->storage->txn_rollback;
};

subtest 'library_limits' => sub {
    plan tests => 8;

    $schema->storage->txn_begin;

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $server = $builder->build_object(
        {
            class => 'Koha::Z3950Servers',
            value => {
                host => 'test.example.com',
                port => 210,
                db   => 'testdb'
            }
        }
    );

    # Test adding library limit
    $server->add_library_limit( $library1->branchcode );
    my $limits = $server->library_limits();
    is( $limits->count,            1,                     'One library limit added' );
    is( $limits->next->branchcode, $library1->branchcode, 'Correct library limit' );

    # Test search with library limits
    my $servers = Koha::Z3950Servers->search_with_library_limits(
        { id => $server->id },
        {},
        $library1->branchcode
    );
    is( $servers->count, 1, 'Server found for authorized library' );

    $servers = Koha::Z3950Servers->search_with_library_limits(
        { id => $server->id },
        {},
        $library2->branchcode
    );
    is( $servers->count, 0, 'Server not found for unauthorized library' );

    # Test replacing library limits
    $server->library_limits( [ $library1->branchcode, $library2->branchcode ] );
    $limits = $server->library_limits();
    is( $limits->count, 2, 'Two library limits set' );

    # Test removing library limit
    $server->del_library_limit( $library1->branchcode );
    $limits = $server->library_limits();
    is( $limits->count,            1,                     'One library limit remains' );
    is( $limits->next->branchcode, $library2->branchcode, 'Correct remaining limit' );

    # Test server with no limits (available to all)
    my $unrestricted_server = $builder->build_object( { class => 'Koha::Z3950Servers' } );
    $servers = Koha::Z3950Servers->search_with_library_limits(
        { id => $unrestricted_server->id },
        {},
        $library1->branchcode
    );
    is( $servers->count, 1, 'Unrestricted server available to all libraries' );

    $schema->storage->txn_rollback;
};
