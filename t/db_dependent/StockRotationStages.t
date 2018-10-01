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

use Test::More tests => 6;

my $schema = Koha::Database->new->schema;

use_ok('Koha::StockRotationStages');
use_ok('Koha::StockRotationStage');

my $builder = t::lib::TestBuilder->new;

subtest 'Basic object tests' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $library = $builder->build({ source => 'Branch' });
    my $rota = $builder->build({ source => 'Stockrotationrota' });
    my $stage = $builder->build({
        source => 'Stockrotationstage',
        value  => {
            branchcode_id => $library->{branchcode},
            rota_id       => $rota->{rota_id},
        },
    });

    my $srstage = Koha::StockRotationStages->find($stage->{stage_id});
    isa_ok(
        $srstage,
        'Koha::StockRotationStage',
        "Correctly create and load a stock rotation stage."
    );

    # Relationship to library
    isa_ok( $srstage->branchcode, 'Koha::Library', "Fetched related branch." );
    is( $srstage->branchcode->branchcode, $library->{branchcode}, "Related branch OK." );

    # Relationship to rota
    isa_ok( $srstage->rota, 'Koha::StockRotationRota', "Fetched related rota." );
    is( $srstage->rota->rota_id, $rota->{rota_id}, "Related rota OK." );

    $schema->storage->txn_rollback;
};

subtest 'DBIx::Class::Ordered tests' => sub {
    plan tests => 33;

    $schema->storage->txn_begin;

    my $library = $builder->build({ source => 'Branch' });
    my $rota = $builder->build({ source => 'Stockrotationrota' });
    my $stagefirst = $builder->build({
        source   => 'Stockrotationstage',
        value    => { rota_id  => $rota->{rota_id}, position => 1 }
    });
    my $stageprevious = $builder->build({
        source   => 'Stockrotationstage',
        value    => { rota_id  => $rota->{rota_id}, position => 2 }
    });
    my $stage = $builder->build({
        source => 'Stockrotationstage',
        value  => { rota_id => $rota->{rota_id}, position => 3 },
    });
    my $stagenext = $builder->build({
        source   => 'Stockrotationstage',
        value    => { rota_id  => $rota->{rota_id}, position => 4 }
    });
    my $stagelast = $builder->build({
        source   => 'Stockrotationstage',
        value    => { rota_id  => $rota->{rota_id}, position => 5 }
    });

    my $srstage = Koha::StockRotationStages->find($stage->{stage_id});

    is($srstage->siblings->count, 4, "Siblings works.");
    is($srstage->previous_siblings->count, 2, "Previous Siblings works.");
    is($srstage->next_siblings->count, 2, "Next Siblings works.");

    my $map = {
        first_sibling    => $stagefirst,
        previous_sibling => $stageprevious,
        next_sibling     => $stagenext,
        last_sibling     => $stagelast,
    };
    # Test plain relations:
    while ( my ( $srxsr, $check ) = each %{$map} ) {
        my $sr = $srstage->$srxsr;
        isa_ok($sr, 'Koha::StockRotationStage', "Fetched using '$srxsr'.");
        is($sr->stage_id, $check->{stage_id}, "'$srxsr' data is correct.");
    };

    # Test mutators
    ## Move Previous
    ok($srstage->move_previous, "Previous.");
    is($srstage->previous_sibling->stage_id, $stagefirst->{stage_id}, "Previous, correct previous.");
    is($srstage->next_sibling->stage_id, $stageprevious->{stage_id}, "Previous, correct next.");
    ## Move Next
    ok($srstage->move_next, "Back to middle.");
    is($srstage->previous_sibling->stage_id, $stageprevious->{stage_id}, "Middle, correct previous.");
    is($srstage->next_sibling->stage_id, $stagenext->{stage_id}, "Middle, correct next.");
    ## Move First
    ok($srstage->move_first, "First.");
    is($srstage->previous_sibling, 0, "First, correct previous.");
    is($srstage->next_sibling->stage_id, $stagefirst->{stage_id}, "First, correct next.");
    ## Move Last
    ok($srstage->move_last, "Last.");
    is($srstage->previous_sibling->stage_id, $stagelast->{stage_id}, "Last, correct previous.");
    is($srstage->next_sibling, 0, "Last, correct next.");
    ## Move To

    ### Out of range moves.
    is(
        $srstage->move_to($srstage->siblings->count + 2),
        0, "Move above count of stages."
    );
    is($srstage->move_to(0), 0, "Move to 0th position.");
    is($srstage->move_to(-1), 0, "Move to negative position.");

    ### Move To
    ok($srstage->move_to(3), "Move.");
    is($srstage->previous_sibling->stage_id, $stageprevious->{stage_id}, "Move, correct previous.");
    is($srstage->next_sibling->stage_id, $stagenext->{stage_id}, "Move, correct next.");

    # Group manipulation
    my $newrota = $builder->build({ source => 'Stockrotationrota' });
    ok($srstage->move_to_group($newrota->{rota_id}), "Move to Group.");
    is(Koha::StockRotationStages->find($srstage->stage_id)->rota_id, $newrota->{rota_id}, "Moved correctly.");

    # Delete in ordered context
    ok($srstage->delete, "Deleted OK.");
    is(
        Koha::StockRotationStages->find($stageprevious)->next_sibling->stage_id,
        $stagenext->{stage_id},
        "Delete, correctly re-ordered."
    );

    $schema->storage->txn_rollback;
};

subtest 'Relationship to stockrotationitems' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;
    my $stage = $builder->build({ source => 'Stockrotationstage' });

    $builder->build({
        source => 'Stockrotationitem',
        value  => { stage_id => $stage->{stage_id} },
    });
    $builder->build({
        source => 'Stockrotationitem',
        value  => { stage_id => $stage->{stage_id} },
    });
    $builder->build({
        source => 'Stockrotationitem',
        value  => { stage_id => $stage->{stage_id} },
    });

    my $srstage = Koha::StockRotationStages->find($stage->{stage_id});
    my $sritems = $srstage->stockrotationitems;
    is(
        $sritems->count, 3,
        'Correctly fetched stockrotationitems associated with this stage'
    );

    isa_ok(
        $sritems->next, 'Koha::StockRotationItem',
        "Relationship correctly creates Koha::Objects."
    );

    $schema->storage->txn_rollback;
};


subtest 'Tests for investigate (singular)' => sub {

    plan tests => 3;

    # In this subtest series we will primarily be testing whether items end up
    # in the correct 'branched' section of the stage-report.  We don't care
    # for item reasons here, as they are tested in StockRotationItems.

    # We will run tests on first on an empty report (the base-case) and then
    # on a populated report.

    # We will need:
    # - Libraries which will hold the Items
    # - Rota Which containing the related stages
    #   + Stages on which we run investigate
    #     * Items on the stages

    $schema->storage->txn_begin;

    # Libraries
    my $library1 = $builder->build({ source => 'Branch' });
    my $library2 = $builder->build({ source => 'Branch' });
    my $library3 = $builder->build({ source => 'Branch' });

    my $stage1lib = $builder->build({ source => 'Branch' });
    my $stage2lib = $builder->build({ source => 'Branch' });
    my $stage3lib = $builder->build({ source => 'Branch' });
    my $stage4lib = $builder->build({ source => 'Branch' });

    my $libraries = [ $library1, $library2, $library3, $stage1lib, $stage2lib,
                      $stage3lib, $stage4lib ];

    # Rota
    my $rota = $builder->build({
        source => 'Stockrotationrota',
        value  => { cyclical => 0 },
    });

    # Stages
    my $stage1 = $builder->build({
        source => 'Stockrotationstage',
        value  => {
            rota_id => $rota->{rota_id},
            branchcode_id => $stage1lib->{branchcode},
            duration => 10,
            position => 1,
        },
    });
    my $stage2 = $builder->build({
        source => 'Stockrotationstage',
        value  => {
            rota_id => $rota->{rota_id},
            branchcode_id => $stage2lib->{branchcode},
            duration => 20,
            position => 2,
        },
    });
    my $stage3 = $builder->build({
        source => 'Stockrotationstage',
        value  => {
            rota_id => $rota->{rota_id},
            branchcode_id => $stage3lib->{branchcode},
            duration => 10,
            position => 3,
        },
    });
    my $stage4 = $builder->build({
        source => 'Stockrotationstage',
        value  => {
            rota_id => $rota->{rota_id},
            branchcode_id => $stage4lib->{branchcode},
            duration => 20,
            position => 4,
        },
    });

    # Test on an empty report.
    my $spec =  {
        $library1->{branchcode} => 1,
        $library2->{branchcode} => 1,
        $library3->{branchcode} => 1,
        $stage1lib->{branchcode} => 2,
        $stage2lib->{branchcode} => 1,
        $stage3lib->{branchcode} => 3,
        $stage4lib->{branchcode} => 4
    };
    while ( my ( $code, $count ) = each %{$spec} ) {
        my $cnt = 0;
        while ( $cnt < $count ) {
            my $item = $builder->build({
                source => 'Stockrotationitem',
                value  => {
                    stage_id => $stage1->{stage_id},
                    indemand => 0,
                    fresh    => 1,
                }
            });
            my $dbitem = Koha::StockRotationItems->find($item);
            $dbitem->itemnumber->homebranch($code)
                ->holdingbranch($code)->store;
            $cnt++;
        }
    }
    my $report = Koha::StockRotationStages
        ->find($stage1->{stage_id})->investigate;
    my $results = [];
    foreach my $lib ( @{$libraries} ) {
        my $items = $report->{branched}->{$lib->{branchcode}}->{items} || [];
        push @{$results},
            scalar @{$items};
    }

    # Items assigned to stag1lib -> log, hence $results[4] = 0;
    is_deeply( $results, [ 1, 1, 1, 2, 1, 3, 4 ], "Empty report test 1.");

    # Now we test by adding the next stage's items to the same report.
    $spec =  {
        $library1->{branchcode} => 3,
        $library2->{branchcode} => 2,
        $library3->{branchcode} => 1,
        $stage1lib->{branchcode} => 4,
        $stage2lib->{branchcode} => 2,
        $stage3lib->{branchcode} => 0,
        $stage4lib->{branchcode} => 3
    };
    while ( my ( $code, $count ) = each %{$spec} ) {
        my $cnt = 0;
        while ( $cnt < $count ) {
            my $item = $builder->build({
                source => 'Stockrotationitem',
                value  => {
                    stage_id => $stage2->{stage_id},
                    indemand => 0,
                    fresh => 1,
                }
            });
            my $dbitem = Koha::StockRotationItems->find($item);
            $dbitem->itemnumber->homebranch($code)
                ->holdingbranch($code)->store;
            $cnt++;
        }
    }

    $report = Koha::StockRotationStages
        ->find($stage2->{stage_id})->investigate($report);
    $results = [];
    foreach my $lib ( @{$libraries} ) {
        my $items = $report->{branched}->{$lib->{branchcode}}->{items} || [];
        push @{$results},
            scalar @{$items};
    }
    is_deeply( $results, [ 4, 3, 2, 6, 3, 3, 7 ], "full report test.");

    # Carry out db updates
    foreach my $item (@{$report->{items}}) {
        my $reason = $item->{reason};
        if ( $reason eq 'repatriation' ) {
            $item->{object}->repatriate;
        } elsif ( grep { $reason eq $_ }
                      qw/in-demand advancement initiation/ ) {
            $item->{object}->advance;
        }
    }

    $report = Koha::StockRotationStages
        ->find($stage1->{stage_id})->investigate;
    $results = [];
    foreach my $lib ( @{$libraries} ) {
        my $items = $report->{branched}->{$lib->{branchcode}}->{items} || [];
        push @{$results},
            scalar @{$items};
    }
    # All items have been 'initiated', which means they are either happily in
    # transit or happily at the library they are supposed to be.  Either way
    # they will register as 'not-ready' in the stock rotation report.
    is_deeply( $results, [ 0, 0, 0, 0, 0, 0, 0 ], "All items now in logs.");

    $schema->storage->txn_rollback;
};

1;
