#!/usr/bin/perl

# Copyright 2015 Koha Development team
# Copyright 2020 BULAC
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
use Test::More tests => 5;

use Koha::Desk;
use Koha::Desks;
use Koha::Database;
use Koha::Libraries;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Add CPL if missing.
if ( not defined Koha::Libraries->find('CPL') ) {
    Koha::Library->new( { branchcode => 'CPL', branchname => 'Centerville' } )->store;
}

my $builder     = t::lib::TestBuilder->new;
my $nb_of_desks = Koha::Desks->search->count;
my $new_desk_1  = Koha::Desk->new(
    {
        desk_name  => 'my_desk_name_for_test_1',
        branchcode => 'CPL',
    }
)->store;
my $new_desk_2 = Koha::Desk->new(
    {
        desk_name  => 'my_desk_name_for_test_2',
        branchcode => 'CPL',
    }
)->store;

like( $new_desk_1->desk_id, qr|^\d+$|, 'Adding a new desk should have set the desk_id' );
is( Koha::Desks->search->count, $nb_of_desks + 2, 'The 2 desks should have been added' );

my $retrieved_desk_1 = Koha::Desks->find( $new_desk_1->desk_id );
is( $retrieved_desk_1->desk_name, $new_desk_1->desk_name, 'Find a desk by id should return the correct desk' );

$retrieved_desk_1->delete;
is( Koha::Desks->search->count, $nb_of_desks + 1, 'Delete should have deleted the desk' );

$schema->storage->txn_rollback;
