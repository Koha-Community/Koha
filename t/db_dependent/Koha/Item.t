#!/usr/bin/perl

# Copyright 2019 Koha Development team
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

use Koha::Items;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'hidden_in_opac() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $item  = $builder->build_sample_item({ itemlost => 2 });
    my $rules = {};

    # disable hidelostitems as it interteres with OpachiddenItems for the calculation
    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );

    ok( !$item->hidden_in_opac, 'No rules passed, shouldn\'t hide' );
    ok( !$item->hidden_in_opac({ rules => $rules }), 'Empty rules passed, shouldn\'t hide' );

    # enable hidelostitems to verify correct behaviour
    t::lib::Mocks::mock_preference( 'hidelostitems', 1 );
    ok( $item->hidden_in_opac, 'Even with no rules, item should hide because of hidelostitems syspref' );

    # disable hidelostitems
    t::lib::Mocks::mock_preference( 'hidelostitems', 0 );
    my $withdrawn = $item->withdrawn + 1; # make sure this attribute doesn't match

    $rules = { withdrawn => [$withdrawn], itype => [ $item->itype ] };

    ok( $item->hidden_in_opac({ rules => $rules }), 'Rule matching itype passed, should hide' );



    $schema->storage->txn_rollback;
};
