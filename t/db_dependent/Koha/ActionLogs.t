#!/usr/bin/perl
# This file is part of Koha.
#
# Copyright 2019 Koha Development Team
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

use C4::Context;
use C4::Log qw( logaction );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

BEGIN {
    use_ok('Koha::ActionLogs');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'store() tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    my $logs_count = Koha::ActionLogs->count;
    my $log        = Koha::ActionLog->new(
        {
            module    => 'CIRCULATION',
            action    => 'ISSUE',
            interface => 'intranet',
        }
    )->store;
    $log->discard_changes;

    is( ref($log),               'Koha::ActionLog', 'Log object creation success' );
    is( Koha::ActionLogs->count, $logs_count + 1,   'Exactly one log was saved' );

    my $yesterday = dt_from_string->subtract( days => 1 );
    $log->timestamp($yesterday)->store;
    $log->info("a new info")->store;    # Must be 2 different store calls
    is(
        dt_from_string( $log->get_from_storage->timestamp ), $yesterday,
        'timestamp column should not be updated to current_timestamp'
    );

    $schema->storage->txn_rollback;
};

subtest 'search() tests' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron1 = $builder->build_object(
        {
            class => 'Koha::Patrons',
        }
    );

    logaction( "MEMBERS", "MODIFY", $patron1->borrowernumber, "test" );

    is(
        Koha::ActionLogs->search( { object => $patron1->borrowernumber } )->count, 1,
        'search() return right number of action logs'
    );

    $schema->storage->txn_rollback;
};

1;
