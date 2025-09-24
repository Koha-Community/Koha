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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Database;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'ModBiblio() + holds_queue update tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock->mock(
        'enqueue',
        sub {
            my ( $self, $args ) = @_;
            my ( $package, $filename, $line ) = caller;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                'ModBiblio triggers a holds queue update for the related biblio'
            );
        }
    );

    # add a hold
    $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber => $biblio->id,
            }
        }
    );

    # this call will trigger the mocked 'enqueue'
    C4::Biblio::ModBiblio(
        $biblio->metadata->record, $biblio->id,
        $biblio->frameworkcode, { skip_holds_queue => 0 }
    );

    # this call will not trigger the mocked 'enqueue', so the test count is 1
    C4::Biblio::ModBiblio(
        $biblio->metadata->record, $biblio->id,
        $biblio->frameworkcode, { skip_holds_queue => 1 }
    );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    # this call should not trigger the mocked 'enqueue'
    C4::Biblio::ModBiblio(
        $biblio->metadata->record, $biblio->id,
        $biblio->frameworkcode, { skip_holds_queue => 0 }
    );

    # this call should not trigger the mocked 'enqueue'
    C4::Biblio::ModBiblio(
        $biblio->metadata->record, $biblio->id,
        $biblio->frameworkcode, { skip_holds_queue => 1 }
    );

    $schema->storage->txn_rollback;
};

subtest 'DelBiblio + holds_queue update tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    my $biblio = $builder->build_sample_biblio;

    my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock->mock(
        'enqueue',
        sub {
            my ( $self, $args ) = @_;
            is_deeply(
                $args->{biblio_ids},
                [ $biblio->id ],
                'DelBiblio triggers a holds queue update for the related biblio'
            );
        }
    );

    # add a hold
    $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                biblionumber => $biblio->id,
            }
        }
    );

    C4::Biblio::DelBiblio( $biblio->id );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    $biblio = $builder->build_sample_biblio;

    C4::Biblio::DelBiblio( $biblio->id );

    $schema->storage->txn_rollback;
};
