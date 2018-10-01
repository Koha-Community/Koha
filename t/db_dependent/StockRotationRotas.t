#!/usr/bin/perl

# Copyright PTFS Europe 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Koha::Database;
use t::lib::TestBuilder;

use Test::More tests => 5;

my $schema = Koha::Database->new->schema;

use_ok('Koha::StockRotationRotas');
use_ok('Koha::StockRotationRota');

subtest 'Basic object tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $rota = $builder->build({ source => 'Stockrotationrota' });

    my $srrota = Koha::StockRotationRotas->find($rota->{rota_id});
    isa_ok(
        $srrota,
        'Koha::StockRotationRota',
        "Correctly create and load a stock rotation rota."
    );

    $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });
    $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });
    $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });

    my $srstages = $srrota->stockrotationstages;
    is( $srstages->count, 3, 'Correctly fetched stockrotationstages associated with this rota');

    isa_ok( $srstages->next, 'Koha::StockRotationStage', "Relationship correctly creates Koha::Objects." );

    #### Test add_item

    my $item = $builder->build({ source => 'Item' });

    $srrota->add_item($item->{itemnumber});

    is(
        Koha::StockRotationItems->find($item->{itemnumber})->stage_id,
        $srrota->first_stage->stage_id,
        "Adding an item results in a new sritem item being assigned to the first stage."
    );

    my $newrota = $builder->build({ source => 'Stockrotationrota' });

    my $srnewrota = Koha::StockRotationRotas->find($newrota->{rota_id});

    $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $newrota->{rota_id} },
    });

    $srnewrota->add_item($item->{itemnumber});

    is(
        Koha::StockRotationItems->find($item->{itemnumber})->stage_id,
        $srnewrota->stockrotationstages->next->stage_id,
        "Moving an item results in that sritem being assigned to the new first stage."
    );

    $schema->storage->txn_rollback;
};

subtest '->first_stage test' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $rota = $builder->build({ source => 'Stockrotationrota' });

    my $stage1 = $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });
    my $stage2 = $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });
    my $stage3 = $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });

    my $srrota = Koha::StockRotationRotas->find($rota->{rota_id});
    my $srstage2 = Koha::StockRotationStages->find($stage2->{stage_id});
    my $firststage = $srstage2->first_sibling || $srstage2;

    is( $srrota->first_stage->stage_id, $firststage->stage_id, "First stage works" );

    $srstage2->move_first;

    is( Koha::StockRotationRotas->find($rota->{rota_id})->first_stage->stage_id, $stage2->{stage_id}, "Stage re-organized" );

    $schema->storage->txn_rollback;
};

subtest '->items test' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $rota = $builder->build({ source => 'Stockrotationrota' });

    my $stage1 = $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });
    my $stage2 = $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });
    my $stage3 = $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id} },
    });

    map { $builder->build({
        source => 'Stockrotationitem',
        value => { stage_id => $_ },
    }) } (
        $stage1->{stage_id}, $stage1->{stage_id},
        $stage2->{stage_id}, $stage2->{stage_id},
        $stage3->{stage_id}, $stage3->{stage_id},
    );

    my $srrota = Koha::StockRotationRotas->find($rota->{rota_id});

    is(
        $srrota->stockrotationitems->count,
        6, "Correct number of items"
    );

    $schema->storage->txn_rollback;
};

1;
