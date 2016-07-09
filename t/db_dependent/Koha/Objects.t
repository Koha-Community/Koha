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

use Test::More tests => 2;

use Koha::Authority::Types;
use Koha::Patrons;
use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

is( ref(Koha::Authority::Types->find('')), 'Koha::Authority::Type', 'Koha::Objects->find should work if the primary key is an empty string' );

my @columns = Koha::Patrons->columns;
my $borrowernumber_exists = grep { /^borrowernumber$/ } @columns;
is( $borrowernumber_exists, 1, 'Koha::Objects->columns should return the table columns' );

$schema->storage->txn_rollback;
1;
