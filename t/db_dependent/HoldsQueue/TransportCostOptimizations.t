#!/usr/bin/perl

# Test C4::HoldsQueue::CreateQueue() for optimal allocation using the
# transport cost matrix.
#
# Wraps tests in transaction that's rolled back, so no data is destroyed
# MySQL WARNING: This makes sense only if your tables are InnoDB, otherwise
# transactions are not supported and mess is left behind

use Modern::Perl;

use Test::More tests => 117;
use Data::Dumper;

use C4::Context;
use Koha::Database;
use C4::Reserves qw( AddReserve );
use C4::HoldsQueue;

use t::lib::TestBuilder;
use t::lib::Mocks;

sub mock_cost_matrix {
    my $matrix  = shift;
    my $builder = shift;
    my $schema  = shift;

    my $rows = scalar(@$matrix);
    my $cols = $rows > 0 ? scalar( @{ $matrix->[0] } ) : 0;

    my $max = $rows >= $cols ? $rows : $cols;

    my @libraries = ();

    for ( my $i = 0 ; $i < $max ; $i++ ) {
        push @libraries, $builder->build(
            {
                source => 'Branch',
            }
        );
    }

    for ( my $i = 0 ; $i < scalar(@$matrix) ; $i++ ) {
        for ( my $j = 0 ; $j < scalar( @{ $matrix->[$i] } ) ; $j++ ) {
            if ( $i != $j ) {
                my $tc_rs = $schema->resultset('TransportCost');
                my $cost  = $matrix->[$i]->[$j];
                $tc_rs->create(
                    {
                        frombranch       => $libraries[$i]->{branchcode},
                        tobranch         => $libraries[$j]->{branchcode},
                        cost             => $cost,
                        disable_transfer => ( $cost < 0 ? 1 : 0 )
                    }
                );
            }
        }
    }

    return \@libraries;
}

sub mock_scenario {
    my $libraries           = shift;
    my $items_at_library    = shift;
    my $reserves_at_library = shift;
    my $builder             = shift;

    my @borrowers = ();

    for ( my $i = 0 ; $i < scalar(@$libraries) ; $i++ ) {
        my @at_library = ();
        for ( my $j = 0 ; $j < $reserves_at_library->[$i] ; $j++ ) {
            push @at_library, $builder->build(
                {
                    source => 'Borrower',
                    value  => {
                        branchcode => $libraries->[$i]->{branchcode},
                    }
                }
            );
        }
        push @borrowers, \@at_library;
    }

    my $biblio = $builder->build_sample_biblio();

    my @items = ();

    for ( my $i = 0 ; $i < scalar(@$libraries) ; $i++ ) {
        for ( my $j = 0 ; $j < $items_at_library->[$i] ; $j++ ) {
            push @items, $builder->build_sample_item(
                {
                    biblionumber  => $biblio->biblionumber,
                    holdingbranch => $libraries->[$i]->{branchcode},
                    homebranch    => $libraries->[$i]->{branchcode},
                }
            );
        }
    }

    for ( my $i = 0 ; $i < scalar(@$libraries) ; $i++ ) {
        for ( my $j = 0 ; $j < $reserves_at_library->[$i] ; $j++ ) {
            my $borrower = $borrowers[$i]->[$j];
            AddReserve(
                {
                    branchcode     => $borrower->{branchcode},
                    borrowernumber => $borrower->{borrowernumber},
                    biblionumber   => $biblio->biblionumber,
                    priority       => 1 + $j + $i * scalar(@$libraries),
                }
            );
        }
    }
}

sub library_index {
    my ( $branchcode, $libraries ) = @_;

    for ( my $i = 0 ; $i < scalar(@$libraries) ; $i++ ) {
        if ( $libraries->[$i]->{branchcode} eq $branchcode ) {
            return $i;
        }
    }

    return -1;
}

sub allocation_indices {
    my ( $libraries, $allocations ) = @_;

    my @allocations = ();

    for ( my $i = 0 ; $i < scalar(@$allocations) ; $i++ ) {
        my $pick    = library_index( $allocations->[$i]->{pickbranch},    $libraries );
        my $holding = library_index( $allocations->[$i]->{holdingbranch}, $libraries );
        push @allocations, [ $holding, $pick ];
    }

    return @allocations;
}

sub total_cost {
    my ( $matrix, $libraries, $allocations ) = @_;

    my @allocations = allocation_indices( $libraries, $allocations );
    my $total       = 0;

    for my $allocation (@allocations) {
        my $cost = $matrix->[ $allocation->[0] ]->[ $allocation->[1] ];
        $total += $cost;
    }

    return $total;
}

# Mock a scenario for reservations on a biblio.
#
# Parameters:
# $label               - Label for scenario
# $matrix              - Transport cost matrix (array of arrays of numbers).
# $items_at_library    - Array specifying the number of items for the biblio at each library.
#                        Indices correspond to the indices in the transport cost matrix.
# $reserves_at_library - Array specifying the number of holds on the biblio at each library.
#                        Indices correspond to the indices in the transport cost matrix.
# $expected_allocation - Array of tuples specifying expected allocation on the form
#                        [<index of holding library>, <index of of pick library>].  Specify
#                        undefined if optimal allocation is ambiguous
# $expected_total_cost - The expected total cost of the allocation.
sub test_allocation {
    my ( $label, $matrix, $items_at_library, $reserves_at_library, $expected_allocation, $expected_total_cost ) = @_;

    my $schema = Koha::Database->schema;
    $schema->storage->txn_begin;
    my $dbh = C4::Context->dbh;

    my $builder = t::lib::TestBuilder->new;

    t::lib::Mocks::mock_preference( 'UseBranchTransferLimits',  '0' );
    t::lib::Mocks::mock_preference( 'BranchTransferLimitsType', 'itemtype' );
    t::lib::Mocks::mock_preference( 'UseTransportCostMatrix',   '1' );

    my $libraries = mock_cost_matrix( $matrix, $builder, $schema );

    mock_scenario( $libraries, $items_at_library, $reserves_at_library, $builder );

    C4::HoldsQueue::CreateQueue();

    my $holds_queue = $dbh->selectall_arrayref( "SELECT * FROM tmp_holdsqueue", { Slice => {} } );

    if ($expected_allocation) {
        my @indices = allocation_indices( $libraries, $holds_queue );

        is( scalar(@indices), scalar(@$expected_allocation), "$label correct number of allocations" );

        # print STDERR Dumper(\@indices);

        while ( my $expected = shift @$expected_allocation ) {
            my $found = 0;
            for ( my $i = 0 ; $i < scalar(@indices) ; $i++ ) {
                if (   $expected->[0] == $indices[$i]->[0]
                    && $expected->[1] == $indices[$i]->[1] )
                {
                    $found = 1;
                    $indices[$i] = [ -1, -1 ];
                    last;
                }
            }
            ok( $found, "$label - allocation contained [" . $expected->[0] . ", " . $expected->[1] . "]" );
        }
    }

    is( total_cost( $matrix, $libraries, $holds_queue ), $expected_total_cost, "$label the total cost is as expected" );

    $schema->txn_rollback;
}

test_allocation(
    "trivial case",
    [],
    [],
    [],
    [],
    0
);

test_allocation(
    "unit case",
    [ [0] ],
    [1],
    [1],
    [ [ 0, 0 ] ],
    0
);

test_allocation(
    "all local allocations",
    [
        [ 0, 1, 1 ],
        [ 1, 0, 1 ],
        [ 1, 1, 0 ]
    ],
    [ 1, 1, 1 ],
    [ 1, 1, 1 ],
    undef,
    0
);

test_allocation(
    "some non-local allocations",
    [
        [ 0, 1, 1 ],
        [ 1, 0, 1 ],
        [ 1, 1, 0 ]
    ],
    [ 3,        0,        0 ],
    [ 1,        1,        1 ],
    [ [ 0, 0 ], [ 0, 1 ], [ 0, 2 ] ],
    2
);

test_allocation(
    "different costs 1",
    [
        [ 0,  2,  2 ],
        [ 1,  0,  1 ],
        [ -1, -1, 0 ]
    ],
    [ 3,        3,        0 ],
    [ 0,        0,        3 ],
    [ [ 1, 2 ], [ 1, 2 ], [ 1, 2 ] ],
    3
);

test_allocation(
    "different costs 2",
    [
        [ 0,  2,  2 ],
        [ 1,  0,  1 ],
        [ -1, -1, 0 ]
    ],
    [ 2,        2,        0 ],
    [ 0,        0,        3 ],
    [ [ 1, 2 ], [ 1, 2 ], [ 0, 2 ] ],
    4
);

test_allocation(
    "allocation prohibited",
    [
        [ 0,  -1 ],
        [ -1, 0 ],
    ],
    [ 2, 0 ],
    [ 0, 2 ],
    [],
    0
);

test_allocation(
    "some allocation prohibited",
    [
        [ 0,  -1, -1 ],
        [ -1, 0,  1 ],
        [ -1, -1, 0 ]
    ],
    [ 2,        2, 0 ],
    [ 0,        0, 4 ],
    [ [ 1, 2 ], [ 1, 2 ] ],
    2
);

test_allocation(
    "local allocation suboptimal",
    [
        [ 0, 1, 1 ],
        [ 1, 0, 10 ],
        [ 1, 1, 0 ]
    ],
    [ 1,        2, 0 ],
    [ 1,        0, 1 ],
    [ [ 0, 2 ], [ 1, 0 ] ],
    2
);

test_allocation(
    "prefer fewer fails",
    [
        [ 0,  1,  1,  1,  1 ],
        [ -1, 0,  -1, -1, 1 ],
        [ -1, -1, 0,  -1, -1 ],
        [ -1, -1, -1, 0,  -1 ],
        [ -1, -1, -1, -1, 0 ]
    ],
    [ 1,        1, 0, 0, 0 ],
    [ 0,        0, 1, 1, 1 ],
    [ [ 0, 2 ], [ 1, 4 ] ],
    2
);

test_allocation(
    "large volume",
    [
        [ (0) x 38, 23, 8 ],
        [ (0) x 38, 31, 29 ],
        [ (0) x 38, 10, 21 ],
        [ (0) x 38, 98, 58 ],
        [ (0) x 38, 24, 93 ],
        [ (0) x 38, 62, 71 ],
        [ (0) x 38, 75, 3 ],
        [ (0) x 38, 86, 32 ],
        [ (0) x 38, 45, 38 ],
        [ (0) x 38, 83, 75 ],
        [ (0) x 38, 45, 16 ],
        [ (0) x 38, 60, 7 ],
        [ (0) x 38, 83, 79 ],
        [ (0) x 38, 54, 59 ],
        [ (0) x 38, 78, 44 ],
        [ (0) x 38, 77, 49 ],
        [ (0) x 38, 9,  8 ],
        [ (0) x 38, 13, 63 ],
        [ (0) x 38, 82, 6 ],
        [ (0) x 38, 62, 9 ],
        [ (0) x 38, 22, 94 ],
        [ (0) x 38, 58, 8 ],
        [ (0) x 38, 39, 1 ],
        [ (0) x 38, 69, 71 ],
        [ (0) x 38, 13, 26 ],
        [ (0) x 38, 3,  67 ],
        [ (0) x 38, 39, 33 ],
        [ (0) x 38, 60, 91 ],
        [ (0) x 38, 46, 44 ],
        [ (0) x 38, 71, 59 ],
        [ (0) x 38, 66, 93 ],
        [ (0) x 38, 38, 92 ],
        [ (0) x 38, 72, 71 ],
        [ (0) x 38, 0,  7 ],
        [ (0) x 38, 44, 87 ],
        [ (0) x 38, 74, 41 ],
        [ (0) x 38, 21, 78 ],
        [ (0) x 38, 90, 68 ],
        [ (0) x 38, 96, 18 ],
        [ (0) x 38, 47, 68 ],
    ],
    [ (5) x 38, (0) x 2 ],
    [ (0) x 38, (40) x 2 ],
    [
        ( [ 33, 38 ] ) x 5,    # cost 0
        ( [ 22, 39 ] ) x 5,    # cost 1
        ( [ 6,  39 ] ) x 5,    # cost 3
        ( [ 25, 38 ] ) x 5,    # cost 3
        ( [ 18, 39 ] ) x 5,    # cost 6
        ( [ 11, 39 ] ) x 5,    # cost 7
        ( [ 0,  39 ] ) x 5,    # cost 8
        ( [ 21, 39 ] ) x 5,    # cost 8
        ( [ 16, 38 ] ) x 5,    # cost 9
        ( [ 19, 39 ] ) x 5,    # cost 9
        ( [ 2,  38 ] ) x 5,    # cost 10
        ( [ 17, 38 ] ) x 5,    # cost 13
        ( [ 24, 38 ] ) x 5,    # cost 13
        ( [ 10, 39 ] ) x 5,    # cost 16
        ( [ 36, 38 ] ) x 5,    # cost 21
        ( [ 20, 38 ] ) x 5,    # cost 22
    ],
    745
);
