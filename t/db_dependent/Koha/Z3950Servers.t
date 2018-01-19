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

use Test::More tests => 4;

use Koha::Z3950Server;
use Koha::Z3950Servers;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_z39s = Koha::Z3950Servers->search->count;
my $new_z39_1 = Koha::Z3950Server->new({
    host => 'my_host1.org',
    port => '32',
    db => 'db1',
    servername => 'my_test_1',
    servertype => 'zed',
    recordtype => 'biblio',
})->store;
my $new_z39_2 = Koha::Z3950Server->new({
    host => 'my_host2.org',
    port => '64',
    db => 'db2',
    servername => 'my_test_2',
    servertype => 'zed',
    recordtype => 'authority',
})->store;

like( $new_z39_1->id, qr|^\d+$|, 'Adding a new z39 server should have set the id');
is( Koha::Z3950Servers->search->count, $nb_of_z39s + 2, 'The 2 z39 servers should have been added' );

my $retrieved_z39_1 = Koha::Z3950Servers->find( $new_z39_1->id );
is( $retrieved_z39_1->servername, $new_z39_1->servername, 'Find a z39 server by id should return the correct z39 server' );

$retrieved_z39_1->delete;
is( Koha::Z3950Servers->search->count, $nb_of_z39s + 1, 'Delete should have deleted the z39 server' );

$schema->storage->txn_rollback;
