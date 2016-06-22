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

use Koha::Library;
use Koha::Libraries;
use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_of_libraries = Koha::Libraries->search->count;
my $new_library_1 = Koha::Library->new({
    branchcode => 'my_bc_1',
    branchname => 'my_branchname_1',
    branchnotes => 'my_branchnotes_1',
    marcorgcode => 'US-MyLib',
})->store;
my $new_library_2 = Koha::Library->new({
    branchcode => 'my_bc_2',
    branchname => 'my_branchname_2',
    branchnotes => 'my_branchnotes_2',
})->store;

is( Koha::Libraries->search->count,         $nb_of_libraries + 2,  'The 2 libraries should have been added' );

my $retrieved_library_1 = Koha::Libraries->find( $new_library_1->branchcode );
is( $retrieved_library_1->branchname, $new_library_1->branchname, 'Find a library by branchcode should return the correct library' );

$retrieved_library_1->delete;
is( Koha::Libraries->search->count, $nb_of_libraries + 1, 'Delete should have deleted the library' );

$schema->storage->txn_rollback;

subtest '->get_effective_marcorgcode' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries',
                                             value => { marcorgcode => 'US-MyLib' } });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries',
                                             value => { marcorgcode => undef } });

    t::lib::Mocks::mock_preference('MARCOrgCode', 'US-Default');

    is( $library_1->get_effective_marcorgcode, 'US-MyLib',
       'If defined, use library\'s own marc org code');
    is( $library_2->get_effective_marcorgcode, 'US-Default',
       'If not defined library\' marc org code, use the one from system preferences');

    t::lib::Mocks::mock_preference('MARCOrgCode', 'Blah');
    is( $library_2->get_effective_marcorgcode, 'Blah',
       'Fallback is always MARCOrgCode syspref');

    $library_2->marcorgcode('ThisIsACode')->store();
    is( $library_2->get_effective_marcorgcode, 'ThisIsACode',
       'Pick library_2 code');

    $schema->storage->txn_rollback;
};
