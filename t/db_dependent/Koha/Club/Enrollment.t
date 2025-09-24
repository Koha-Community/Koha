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
use Test::More tests => 2;
use Test::Exception;

use Koha::Patron;
use Koha::Database;
use Koha::DateUtils qw(dt_from_string);

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'is_canceled' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $enrollment =
        $builder->build_object( { class => 'Koha::Club::Enrollments', value => { date_canceled => undef } } );

    ok( !$enrollment->is_canceled, 'Enrollment should not be canceled' );

    $enrollment->date_canceled( dt_from_string + "" )->store;

    ok( $enrollment->is_canceled, 'Enrollment should be canceled' );

    $schema->storage->txn_rollback;
    }
