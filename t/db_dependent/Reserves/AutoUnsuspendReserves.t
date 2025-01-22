#!/usr/bin/perl

# This file is part of Koha.
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
use Test::More tests => 2;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Reserves qw( AutoUnsuspendReserves );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'AutoUnsuspendReserves test' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $today    = dt_from_string();
    my $tomorrow = $today->clone->add( days => 1 );

    # Not expired hold
    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                expirationdate   => undef,
                cancellationdate => undef,
                priority         => 5,
                found            => undef,
            },
        }
    );

    $hold_1->suspend_hold($today);

    # Expired hold
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                expirationdate   => undef,
                cancellationdate => undef,
                priority         => 6,
                found            => undef,
            },
        }
    );

    $hold_2->suspend_hold($tomorrow);

    AutoUnsuspendReserves();

    # refresh
    $hold_1->discard_changes;
    $hold_2->discard_changes;

    ok( !$hold_1->is_suspended, 'Hold suspended until today should be unsuspended.' );
    ok( $hold_2->is_suspended,  'Hold suspended after today should be suspended.' );

    subtest 'logging enabled' => sub {

        plan tests => 2;

        # Enable logging
        t::lib::Mocks::mock_preference( 'HoldsLog', 1 );

        my $hold_3 = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    expirationdate   => undef,
                    cancellationdate => undef,
                    priority         => 5,
                    found            => undef,
                    suspend_until    => undef,
                }
            }
        );
        $hold_3->suspend_hold($today);

        my $logs_count = $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'RESUME' } )->count;

        AutoUnsuspendReserves();

        $hold_3->discard_changes;
        ok( !$hold_3->is_suspended, 'Hold suspended until today should be unsuspended.' );

        my $new_logs_count =
            $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'RESUME' } )->count;

        is(
            $new_logs_count,
            $logs_count + 1,
            'If logging is enabled, calling AutoUnsuspendReserves gets logged'
        );
    };

    subtest 'logging disabled' => sub {

        plan tests => 2;

        # Enable logging
        t::lib::Mocks::mock_preference( 'HoldsLog', 0 );

        my $hold_4 = $builder->build_object(
            {
                class => 'Koha::Holds',
                value => {
                    expirationdate   => undef,
                    cancellationdate => undef,
                    priority         => 5,
                    found            => undef
                }
            }
        );

        my $logs_count = $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'RESUME' } )->count;

        $hold_4->suspend_hold($today);

        AutoUnsuspendReserves();

        $hold_4->discard_changes;
        ok( !defined( $hold_4->suspend_until ), 'Hold suspended until today should be unsuspended.' );

        my $new_logs_count =
            $schema->resultset('ActionLog')->search( { module => 'HOLDS', action => 'RESUME' } )->count;

        is(
            $new_logs_count,
            $logs_count,
            'If logging is not enabled, no logging from AutoUnsuspendReserves calls'
        );
    };

    $schema->storage->txn_rollback;
};
