#!/usr/bin/perl

# Copyright 2018 Koha Development team
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

use Koha::Library::OverDriveInfos;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $library1 = $builder->build({ source => 'Branch'});
my $library2 = $builder->build({ source => 'Branch'});
my $nb_of_infos = Koha::Library::OverDriveInfos->search->count;
my $new_od_info_1 = Koha::Library::OverDriveInfo->new({
    branchcode => $library1->{'branchcode'},
    authname => 'Gorilla'
})->store;
my $new_od_info_2 = Koha::Library::OverDriveInfo->new({
    branchcode => $library2->{'branchcode'},
    authname => 'Cheese'
})->store;


is( $new_od_info_1->authname, "Gorilla", 'Adding a new authname should have set the authname');
is( Koha::Library::OverDriveInfos->search->count, $nb_of_infos + 2, 'The 2 infos should have been added' );

my $retrieved_od_info_1 = Koha::Library::OverDriveInfos->find( $new_od_info_1->branchcode );
is( $retrieved_od_info_1->authname, $new_od_info_1->authname, 'Find an info  by branch should return the correct info' );

$retrieved_od_info_1->delete;
is( Koha::Library::OverDriveInfos->search->count, $nb_of_infos + 1, 'Delete should have deleted the info' );

$schema->storage->txn_rollback;
