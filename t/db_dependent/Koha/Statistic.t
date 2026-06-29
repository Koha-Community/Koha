#!/usr/bin/perl

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

use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 3;
use Test::Warn;

use Koha::DateUtils qw(dt_from_string);
use Koha::Statistics;
use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;
my $dtf     = $schema->storage->datetime_parser;

subtest 'new() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $statistic = $builder->build_object(
        {
            class => 'Koha::Statistics',
            value => {
                datetime => $dtf->format_datetime( dt_from_string()->subtract( days => 7 ) ),
                type     => 'issue',
            },
        }
    )->unblessed;

    my $new_statistic = Koha::Statistic->new($statistic);
    is( $new_statistic->datetime, $statistic->{datetime}, "Passed 'datetime' is preserved" );

    delete $statistic->{datetime};
    is( $statistic->{datetime}, undef, "'datetime' not present (check)" );

    $new_statistic = Koha::Statistic->new($statistic);
    ok( defined $new_statistic->datetime, "'datetime' calculated if not passed" );

    $schema->storage->txn_rollback;
};

subtest 'pseudonymize() tests' => sub {

    plan tests => scalar(@Koha::Statistic::pseudonymization_types) + 2;

    $schema->storage->txn_begin;

    my $not_type = 'not_gonna_pseudo';

    my $pseudo_background = Test::MockModule->new('Koha::BackgroundJob::PseudonymizeStatistic');
    $pseudo_background->mock( enqueue => sub { warn "Called" } );

    my @statistics = ();

    ok( scalar(@Koha::Statistic::pseudonymization_types) > 0, 'some pseudonymization_types are defined' );

    my $sub_days = 0;    # TestBuilder does not handle many rows of Koha::Statistics very intuitively
    foreach my $type (@Koha::Statistic::pseudonymization_types) {
        push(
            @statistics,
            $builder->build_object(
                {
                    class => 'Koha::Statistics',
                    value => {
                        datetime => $dtf->format_datetime( dt_from_string()->subtract( days => $sub_days ) ),
                        type     => $type,
                    },
                }
            )
        );
        $sub_days++;
    }

    push(
        @statistics,
        $builder->build_object(
            {
                class => 'Koha::Statistics',
                value => {
                    datetime => $dtf->format_datetime( dt_from_string()->subtract( days => 7 ) ),
                    type     => $not_type,
                },
            }
        )
    );

    foreach my $statistic (@statistics) {
        my $type = $statistic->type;
        if ( $type ne $not_type ) {
            warnings_are {
                $statistic->pseudonymize();
            }
            ["Called"], "Background job enqueued for type $type";
        } else {
            warnings_are {
                $statistic->pseudonymize();
            }
            undef, "Background job not enqueued for type $type";
        }
    }

    $schema->storage->txn_rollback;
};
