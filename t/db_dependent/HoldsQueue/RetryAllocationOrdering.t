#!/usr/bin/perl

# Test that C4::HoldsQueue::_allocateWithTransportCostMatrix() correctly
# compacts its working matrix between retries, regardless of the order in
# which Munkres' row-to-column assignment happens to report unfilled holds.
#
# This calls the (private) allocation routine directly, with hand-built
# fixtures, rather than going through CreateQueue()/the database: the
# defect being tested only manifests for a specific item-to-branch
# permutation, and List::Util::shuffle() inside the routine makes that
# permutation depend on the interpreter's random state. Pinning srand()
# here keeps the test deterministic without depending on how many random
# numbers TestBuilder/Faker happen to consume building DB fixtures.

use Modern::Perl;

use Test::More tests => 6;
use Test::NoWarnings;

use C4::HoldsQueue;

# A minimal stand-in for a Koha::Item: only the methods this routine calls.
package t::lib::FakeTransferableItem;

sub new                { my $class = shift; return bless {}, $class; }
sub can_be_transferred { return 1; }
sub item_group         { return; }

package main;

# Branches double as both holding branches (agents) and pickup branches
# (tasks). The transport cost matrix is deliberately scarce:
#   - L0 is the *only* holding branch that can serve pickups L0, L1 and L3.
#   - L1, L2 and L3 can each *only* serve pickup L2.
# So among {L0, L1, L3} pickups, at most one can ever be filled (by L0);
# the other two are genuinely unfillable and must both be reported as
# unallocated in the same retry pass - this is what makes the ordering of
# @unallocated matter, since the matrix compaction assumes ascending order.
my @branches = qw(L0 L1 L2 L3);
my %cost     = (
    L0 => { L0 => 10,    L1 => 11,    L2 => undef, L3 => 12 },
    L1 => { L0 => undef, L1 => undef, L2 => 5,     L3 => undef },
    L2 => { L0 => undef, L1 => undef, L2 => 6,     L3 => undef },
    L3 => { L0 => undef, L1 => undef, L2 => 7,     L3 => undef },
);

sub build_transport_cost_matrix {
    my %tcm;
    for my $holding (@branches) {
        for my $pickup (@branches) {
            my $cost = $cost{$holding}{$pickup};
            $tcm{$pickup}{$holding} =
                defined $cost
                ? { cost             => $cost, disable_transfer => 0 }
                : { disable_transfer => 1 };
        }
    }
    return \%tcm;
}

sub build_request {
    my ( $branch, $reserve_id, $note ) = @_;
    return {
        itemnumber      => undef,
        allocated       => undef,
        branchcode      => $branch,
        borrowerbranch  => $branch,
        itemtype        => undef,
        item_group_id   => undef,
        borrowernumber  => 1000 + $reserve_id,
        biblionumber    => 1,
        reserve_id      => $reserve_id,
        item_level_hold => 0,
        reservedate     => '2024-01-01',
        reservenotes    => $note,
    };
}

# One item per branch, and one initial hold request per branch, plus two
# extra pending requests for the always-fillable L2 pickup: this forces a
# retry (there are more requests than items) that reuses whatever the first
# pass left behind in the compacted matrix.
srand(80);    # known to trigger a non-ascending @unallocated on the first pass

my @available_items;
my %items_by_itemnumber;
my $itemnumber = 1;
for my $branch (@branches) {
    my $item = {
        itemnumber              => $itemnumber,
        holdingbranch           => $branch,
        holdallowed             => 'yes',
        hold_fulfillment_policy => '',
        itype                   => undef,
        _object                 => t::lib::FakeTransferableItem->new,
    };
    push @available_items, $item;
    $items_by_itemnumber{$itemnumber} = { _object => $item->{_object} };
    $itemnumber++;
}

my $reserve_id    = 1;
my @hold_requests = map { build_request( $_, $reserve_id++, "req_$_" ) } @branches;
push @hold_requests, build_request( 'L2', $reserve_id++, 'extra_0' );
push @hold_requests, build_request( 'L2', $reserve_id++, 'extra_1' );

my %libraries = map { $_ => { branchcode => $_ } } @branches;

my $allocated = C4::HoldsQueue::_allocateWithTransportCostMatrix(
    \@hold_requests, \@available_items, \@branches, \%libraries,
    build_transport_cost_matrix(), {}, \%items_by_itemnumber
);

my %holding_branch_used_for_note = map { $_->[1]{reservenotes} => $_->[1]{holdingbranch} } @$allocated;

ok( $holding_branch_used_for_note{req_L2}, 'the original L2 pickup request was allocated an item' );

my @l2_holding_branches = sort grep { defined } @holding_branch_used_for_note{qw(req_L2 extra_0 extra_1)};
is_deeply(
    \@l2_holding_branches,
    [qw(L1 L2 L3)],
    'all three L2 pickups were filled, one from each of the three branches that can supply L2 (no idle item, no dropped hold)'
);

ok(
    !defined $holding_branch_used_for_note{req_L1},
    'req_L1 is genuinely unfillable: L0 is the only item that could serve it, and it is cheaper to use L0 for req_L0'
);
ok(
    !defined $holding_branch_used_for_note{req_L3},
    'req_L3 is genuinely unfillable for the same reason'
);

my $filled = grep { defined } values %holding_branch_used_for_note;
is( $filled, 4, 'exactly 4 of the 6 pending requests could be filled with the 4 available items' );
