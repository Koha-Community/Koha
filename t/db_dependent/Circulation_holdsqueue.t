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

use Test::More tests => 1;
use Test::MockModule;

use C4::Circulation qw( AddIssue AddReturn );

use Koha::Database;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'AddIssue() and AddReturn() real-time holds queue tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build_object({ class => 'Koha::Libraries' });
    my $patron  = $builder->build_object({ class => 'Koha::Patrons' });
    my $item    = $builder->build_sample_item({ library => $library->id });

    t::lib::Mocks::mock_userenv({ branchcode => $library->id });
    t::lib::Mocks::mock_preference( 'UpdateTotalIssuesOnCirc', 1 );
    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 1 );

    my $action;

    my $mock = Test::MockModule->new('Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue');
    $mock->mock( 'enqueue', sub {
        my ( $self, $args ) = @_;
        my ($package, $filename, $line) = caller;
        is_deeply(
            $args->{biblio_ids},
            [ $item->biblionumber ],
            "$action triggers a holds queue update for the related biblio from $package at line $line"
        );
    } );

    $action = 'AddIssue';
    AddIssue( $patron, $item->barcode, );

    $action = 'AddReturn';
    AddReturn( $item->barcode );

    t::lib::Mocks::mock_preference( 'RealTimeHoldsQueue', 0 );

    $action = 'AddIssue';
    AddIssue( $patron, $item->barcode, );

    $action = 'AddReturn';
    AddReturn( $item->barcode );

    $schema->storage->txn_rollback;
};
