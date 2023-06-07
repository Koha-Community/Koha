#!/usr/bin/perl

# Copyright 2023 Koha Development team
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

use Test::More tests => 1;

use Koha::Database;
use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'holds_control_library() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );

    my $patron = $builder->build_object( { class => 'Koha::Patrons', value => { branchcode => $library_1->id } } );
    my $item   = $builder->build_sample_item( { library => $library_2->id } );

    t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'ItemHomeLibrary' );

    my $policy = Koha::Policy::Holds->new;

    is( $policy->holds_control_library( $item, $patron ), $library_2->id );

    t::lib::Mocks::mock_preference( 'ReservesControlBranch', 'PatronLibrary' );

    is( $policy->holds_control_library( $item, $patron ), $library_1->id );

    $schema->storage->txn_rollback;
};
