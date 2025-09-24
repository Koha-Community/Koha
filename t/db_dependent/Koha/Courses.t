#!/usr/bin/perl

# Copyright 2024 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Koha::Course::Reserve->course' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $reserve = $builder->build_object( { class => 'Koha::Course::Reserves' } );
    is( ref( $reserve->course ), 'Koha::Course', '->course should return a Koha::Course object' );

    $schema->storage->txn_rollback;
};
