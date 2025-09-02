package C4::HoldsQueue;

# Copyright 2011 Catalyst IT
#
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

# FIXME: expand perldoc, explain intended logic

use Modern::Perl;
use base 'Exporter';

BEGIN {
    our @EXPORT_OK = qw(
        CreateQueue
        GetHoldsQueueItems

        TransportCostMatrix
        UpdateTransportCostMatrix
        GetPendingHoldRequestsForBib
        load_branches_to_pull_from
        update_queue_for_biblio
    );
}

use C4::Context;
use C4::Circulation qw( GetBranchItemRule );
use Koha::DateUtils qw( dt_from_string );
use Koha::Hold::HoldsQueueItems;
use Koha::HoldGroup;
use Koha::Items;
use Koha::Libraries;
use Koha::Logger;
use Koha::Patrons;

use List::Util         qw( shuffle );
use List::MoreUtils    qw( any );
use Algorithm::Munkres qw();

=head1 FUNCTIONS

=head2 TransportCostMatrix

  TransportCostMatrix();

Returns Transport Cost Matrix as a hashref <to branch code> => <from branch code> => cost

=cut

sub TransportCostMatrix {
    my ($params) = @_;

    my $dbh             = C4::Context->dbh;
    my $transport_costs = $dbh->selectall_arrayref( "SELECT * FROM transport_cost", { Slice => {} } );

    my $today = dt_from_string();
    my %transport_cost_matrix;
    foreach (@$transport_costs) {
        my $from     = $_->{frombranch};
        my $to       = $_->{tobranch};
        my $cost     = $_->{cost};
        my $disabled = $_->{disable_transfer};
        $transport_cost_matrix{$to}{$from} = {
            cost             => $cost,
            disable_transfer => $disabled
        };
    }

    return \%transport_cost_matrix;
}

=head2 UpdateTransportCostMatrix

  UpdateTransportCostMatrix($records);

Updates full Transport Cost Matrix table. $records is an arrayref of records.
Records: { frombranch => <code>, tobranch => <code>, cost => <figure>, disable_transfer => <0,1> }

=cut

sub UpdateTransportCostMatrix {
    my ($records) = @_;
    my $dbh = C4::Context->dbh;

    my $sth =
        $dbh->prepare("INSERT INTO transport_cost (frombranch, tobranch, cost, disable_transfer) VALUES (?, ?, ?, ?)");

    $dbh->do("DELETE FROM transport_cost");
    foreach (@$records) {
        my $cost = $_->{cost};
        my $from = $_->{frombranch};
        my $to   = $_->{tobranch};
        if ( $_->{disable_transfer} ) {
            $cost ||= 0;
        } elsif ( !defined($cost) || ( $cost !~ m/(0|[1-9][0-9]*)(\.[0-9]*)?/o ) ) {
            warn "Invalid $from -> $to cost $cost - must be a number >= 0, disabling";
            $cost = 0;
            $_->{disable_transfer} = 1;
        }
        $sth->execute( $from, $to, $cost, $_->{disable_transfer} ? 1 : 0 );
    }
}

=head2 GetHoldsQueueItems

  GetHoldsQueueItems({ branchlimit => $branch, itemtypeslimit =>  $itype, ccodeslimit => $ccode, locationslimit => $location );

Returns hold queue for a holding branch. If branch is omitted, then whole queue is returned

=cut

sub GetHoldsQueueItems {
    my $params = shift;
    my $dbh    = C4::Context->dbh;

    my $search_params;
    $search_params->{'me.holdingbranch'} = $params->{branchlimit}    if $params->{branchlimit};
    $search_params->{'itype'}            = $params->{itemtypeslimit} if $params->{itemtypeslimit};
    $search_params->{'ccode'}            = $params->{ccodeslimit}    if $params->{ccodeslimit};
    $search_params->{'location'}         = $params->{locationslimit} if $params->{locationslimit};

    my $results = Koha::Hold::HoldsQueueItems->search(
        $search_params,
        {
            join => [
                'borrower',
            ],
            prefetch => [
                'biblio',
                'biblioitem',
                { 'item' => { 'item_group_item' => 'item_group' } }
            ],
            order_by => [
                'ccode',        'location',   'item.cn_sort', 'author',
                'biblio.title', 'pickbranch', 'reservedate'
            ],
        }
    );

    return $results;
}

=head2 CreateQueue

  CreateQueue();

Top level function that turns reserves into tmp_holdsqueue and hold_fill_targets.

=cut

sub CreateQueue {
    my $params      = shift;
    my $unallocated = $params->{unallocated};
    my $loops       = $params->{loops} || 1;
    my $dbh         = C4::Context->dbh;

    unless ($unallocated) {
        $dbh->do("DELETE FROM tmp_holdsqueue");    # clear the old table for new info
        $dbh->do("DELETE FROM hold_fill_targets");
    }

    my $total_bibs            = 0;
    my $total_requests        = 0;
    my $total_available_items = 0;
    my $num_items_mapped      = 0;

    my $branches_to_use;
    my $transport_cost_matrix;
    my $use_transport_cost_matrix = C4::Context->preference("UseTransportCostMatrix");
    if ($use_transport_cost_matrix) {
        $transport_cost_matrix = TransportCostMatrix();
        unless ( keys %$transport_cost_matrix ) {
            warn "UseTransportCostMatrix set to yes, but matrix not populated";
            undef $transport_cost_matrix;
        }
    }

    $branches_to_use = load_branches_to_pull_from($use_transport_cost_matrix);

    my $bibs_with_pending_requests = GetBibsWithPendingHoldRequests();

    # Split the list of bibs into chunks to run in parallel
    my @chunks;
    if ( $loops > 1 ) {
        my $i = 0;
        while (@$bibs_with_pending_requests) {
            push( @{ $chunks[$i] }, pop(@$bibs_with_pending_requests) );

            $i++;
            $i = 0 if $i >= $loops;
        }

        my $pm = Parallel::ForkManager->new($loops);

    DATA_LOOP:
        foreach my $chunk (@chunks) {
            my $pid = $pm->start and next DATA_LOOP;
            foreach my $biblionumber (@$chunk) {
                update_queue_for_biblio(
                    {
                        biblio_id             => $biblionumber,
                        branches_to_use       => $branches_to_use,
                        transport_cost_matrix => $transport_cost_matrix,
                        unallocated           => $unallocated
                    }
                );
            }
            $pm->finish;
        }

        $pm->wait_all_children;
    } else {
        foreach my $biblionumber (@$bibs_with_pending_requests) {
            update_queue_for_biblio(
                {
                    biblio_id             => $biblionumber,
                    branches_to_use       => $branches_to_use,
                    transport_cost_matrix => $transport_cost_matrix,
                    unallocated           => $unallocated
                }
            );
        }
    }
}

=head2 GetBibsWithPendingHoldRequests

  my $biblionumber_aref = GetBibsWithPendingHoldRequests();

Return an arrayref of the biblionumbers of all bibs
that have one or more unfilled hold requests.

=cut

sub GetBibsWithPendingHoldRequests {
    my $dbh = C4::Context->dbh;

    my $skip_non_target_holds_query     = Koha::HoldGroup::skip_non_target_holds_query('sql');
    my $skip_non_target_holds_query_sql = $skip_non_target_holds_query ? " $skip_non_target_holds_query" : '';

    my $bib_query = "SELECT DISTINCT biblionumber
                     FROM reserves
                     WHERE found IS NULL
                     AND priority > 0
                     AND reservedate <= CURRENT_DATE()
                     AND suspend = 0
                     AND reserve_id NOT IN (SELECT reserve_id FROM hold_fill_targets)
                     $skip_non_target_holds_query_sql
                     ";
    my $sth = $dbh->prepare($bib_query);

    $sth->execute();
    my $biblionumbers = $sth->fetchall_arrayref();
    return [ map { $_->[0] } @$biblionumbers ];
}

=head2 GetPendingHoldRequestsForBib

    my $requests = GetPendingHoldRequestsForBib( { biblionumber => $biblionumber, unallocated => $unallocated } );

Returns an arrayref of hashrefs to pending, unfilled hold requests
on the bib identified by $biblionumber. Optionally returns only unallocated holds.  The following keys
are present in each hashref:

    biblionumber
    borrowernumber
    itemnumber
    priority
    branchcode
    reservedate
    reservenotes
    borrowerbranch

The arrayref is sorted in order of increasing priority.

=cut

sub GetPendingHoldRequestsForBib {
    my $params       = shift;
    my $biblionumber = $params->{biblionumber};
    my $unallocated  = $params->{unallocated};

    my $dbh = C4::Context->dbh;

    my $skip_non_target_holds_query     = Koha::HoldGroup::skip_non_target_holds_query('sql');
    my $skip_non_target_holds_query_sql = $skip_non_target_holds_query ? " $skip_non_target_holds_query" : '';

    my $request_query = "SELECT biblionumber, borrowernumber, itemnumber, priority, reserve_id, reserves.branchcode,
                                reservedate, reservenotes, borrowers.branchcode AS borrowerbranch, itemtype, item_level_hold, item_group_id
                         FROM reserves
                         JOIN borrowers USING (borrowernumber)
                         WHERE biblionumber = ?
                         AND found IS NULL
                         AND priority > 0
                         AND reservedate <= CURRENT_DATE()
                         AND suspend = 0 ";
    $request_query .= "AND reserve_id NOT IN (SELECT reserve_id FROM hold_fill_targets) " if $unallocated;
    $request_query .= $skip_non_target_holds_query_sql;
    $request_query .= "ORDER BY priority";
    my $sth = $dbh->prepare($request_query);
    $sth->execute($biblionumber);

    my $requests = $sth->fetchall_arrayref( {} );
    return $requests;

}

=head2 GetItemsAvailableToFillHoldRequestsForBib

  my $available_items = GetItemsAvailableToFillHoldRequestsForBib($biblionumber, $branches_ar);

Returns an arrayref of items available to fill hold requests
for the bib identified by C<$biblionumber>.  An item is available
to fill a hold request if and only if:

    * it is not on loan
    * it is not withdrawn
    * it is not marked notforloan
    * it is not currently in transit
    * it is not lost
    * it is not sitting on the hold shelf
    * it is not damaged (unless AllowHoldsOnDamagedItems is on)

=cut

sub GetItemsAvailableToFillHoldRequestsForBib {
    my ( $biblionumber, $branches_to_use ) = @_;

    my $dbh         = C4::Context->dbh;
    my $items_query = "SELECT items.itemnumber, homebranch, holdingbranch, itemtypes.itemtype AS itype
                       FROM items ";

    if ( C4::Context->preference('item-level_itypes') ) {
        $items_query .= "LEFT JOIN itemtypes ON (itemtypes.itemtype = items.itype) ";
    } else {
        $items_query .= "JOIN biblioitems USING (biblioitemnumber)
                           LEFT JOIN itemtypes USING (itemtype) ";
    }
    $items_query .= " LEFT JOIN branchtransfers ON (
                           items.itemnumber = branchtransfers.itemnumber
                           AND branchtransfers.datearrived IS NULL AND branchtransfers.datecancelled IS NULL
                     )";
    $items_query .= " WHERE items.notforloan = 0
                       AND holdingbranch IS NOT NULL
                       AND itemlost = 0
                       AND withdrawn = 0";
    $items_query .= "  AND damaged = 0" unless C4::Context->preference('AllowHoldsOnDamagedItems');
    $items_query .= "  AND items.onloan IS NULL
                       AND (itemtypes.notforloan IS NULL OR itemtypes.notforloan = 0)
                       AND items.itemnumber NOT IN (
                           SELECT itemnumber
                           FROM reserves
                           WHERE biblionumber = ?
                           AND itemnumber IS NOT NULL
                           AND (found IS NOT NULL OR priority = 0)
                        )
                        AND items.itemnumber NOT IN (
                           SELECT itemnumber
                           FROM tmp_holdsqueue
                           WHERE biblionumber = ?
                        )
                       AND items.biblionumber = ?
                       AND branchtransfers.itemnumber IS NULL";

    my @params = ( $biblionumber, $biblionumber, $biblionumber );
    if ( $branches_to_use && @$branches_to_use ) {
        $items_query .= " AND holdingbranch IN (" . join( ",", map { "?" } @$branches_to_use ) . ")";
        push @params, @$branches_to_use;
    }
    my $sth = $dbh->prepare($items_query);
    $sth->execute(@params);

    my $itm = $sth->fetchall_arrayref( {} );
    return [
        grep {
            my $rule = C4::Circulation::GetBranchItemRule( $_->{homebranch}, $_->{itype} );
            $_->{holdallowed}             = $rule->{holdallowed};
            $_->{hold_fulfillment_policy} = $rule->{hold_fulfillment_policy};
        } @{$itm}
    ];
}

=head2 _checkHoldPolicy

    _checkHoldPolicy($item, $request)

    check if item agrees with hold policies

=cut

sub _checkHoldPolicy {
    my ( $item, $request ) = @_;

    return 0 unless $item->{holdallowed} ne 'not_allowed';

    return 0
        if $item->{holdallowed} eq 'from_home_library'
        && $item->{homebranch} ne $request->{borrowerbranch};

    return 0
        if $item->{'holdallowed'} eq 'from_local_hold_group'
        && !Koha::Libraries->find( $item->{homebranch} )
        ->validate_hold_sibling( { branchcode => $request->{borrowerbranch} } );

    my $hold_fulfillment_policy = $item->{hold_fulfillment_policy};

    return 0
        if $hold_fulfillment_policy eq 'holdgroup'
        && !Koha::Libraries->find( $item->{homebranch} )
        ->validate_hold_sibling( { branchcode => $request->{branchcode} } );

    return 0
        if $hold_fulfillment_policy eq 'homebranch'
        && $request->{branchcode} ne $item->{$hold_fulfillment_policy};

    return 0
        if $hold_fulfillment_policy eq 'holdingbranch'
        && $request->{branchcode} ne $item->{$hold_fulfillment_policy};

    return 0
        if $hold_fulfillment_policy eq 'patrongroup'
        && !Koha::Libraries->find( $request->{borrowerbranch} )
        ->validate_hold_sibling( { branchcode => $request->{branchcode} } );

    return 1;

}

sub _allocateWithTransportCostMatrix {
    my (
        $hold_requests, $available_items, $branches_to_use, $libraries, $transport_cost_matrix, $allocated_items,
        $items_by_itemnumber
    ) = @_;

    my @allocated;

    my @remaining_items =
        shuffle( grep { !exists $allocated_items->{ $_->{itemnumber} } && $_->{holdallowed} ne 'not_allowed'; }
            @$available_items );

    my @requests  = grep { !defined $_->{itemnumber} && !defined $_->{allocated} } @$hold_requests;
    my @remaining = ();

    my $num_agents = scalar(@remaining_items);
    my $num_tasks  = scalar(@requests);

    return [] if $num_agents == 0 || $num_tasks == 0;

    if ( $num_tasks > $num_agents ) {
        @remaining = @requests[ $num_agents .. $num_tasks - 1 ];
        @requests  = @requests[ 0 .. $num_agents - 1 ];
        $num_tasks = $num_agents;
    }

    my @m = map { [ (undef) x $num_tasks ] } ( 1 .. $num_agents );

    my $inf = -1;    # Initially represent infinity with a negative value.
    my $max = 0;

    # If some candidate holds requests cannot be filled and there are
    # hold requests remaining, we will try again a limited number of
    # times.
    #
    # The limit is chosen arbitrarily and only servers to keep the
    # asymptotic worst case to O(num_tasks³).
    my $RETRIES          = 8;
    my $retries          = $RETRIES;
    my $r                = 0;
    my @candidate_tasks  = ( (0) x $num_tasks );
    my @candidate_agents = ( (0) x $num_agents );

RETRY:
    while (1) {
        return [] if $num_agents == 0 || $num_tasks == 0;

        if ( $num_tasks < $num_agents && @remaining ) {

            # On retry, move tasks from @remaining to @requests up to
            # the number of agents.
            my $nr = scalar(@remaining);
            my $na = $num_agents - $num_tasks;
            my $nm = $nr < $na ? $nr : $na;
            push @requests, ( splice @remaining, 0, $nm );
            $num_tasks += $nm;
            for ( my $t = scalar(@candidate_tasks) ; $t < $num_tasks ; $t++ ) {
                push @candidate_tasks, 0;
            }
        }

        for ( my $i = 0 ; $i < $num_agents ; $i++ ) {
            for ( my $j = $r ; $j < $num_tasks ; $j++ ) {
                my $item    = $remaining_items[$i];
                my $request = $requests[$j];

                my $pickup_branch = $request->{branchcode} || $request->{borrowerbranch};
                my $srcbranch     = $item->{holdingbranch};

                $m[$i][$j] = $inf
                    and next
                    unless _checkHoldPolicy( $item, $request );
                $m[$i][$j] = $inf
                    and next
                    unless $items_by_itemnumber->{ $item->{itemnumber} }->{_object}
                    ->can_be_transferred( { to => $libraries->{ $request->{branchcode} } } );

                # If hold itemtype is set, item's itemtype must match
                $m[$i][$j] = $inf
                    and next
                    unless ( !$request->{itemtype}
                    || $item->{itype} eq $request->{itemtype} );

                # If hold item_group is set, item's item_group must match
                $m[$i][$j] = $inf
                    and next
                    unless (
                    !$request->{item_group_id}
                    || (   $item->{_object}->item_group
                        && $item->{_object}->item_group->id eq $request->{item_group_id} )
                    );

                my $cell = $transport_cost_matrix->{$pickup_branch}{$srcbranch};
                my $cost;

                if ( !defined $cell && $pickup_branch eq $srcbranch ) {
                    $cost = 0;
                } elsif ( !defined $cell || $cell->{disable_transfer} ) {
                    $cost = $inf;
                } else {
                    if ( defined $cell->{cost} ) {
                        $cost = $cell->{cost};
                    } else {
                        $cost = $inf;
                    }
                }

                $m[$i][$j] = $cost;

                if ( $cost != $inf ) {

                    # There is at least one possible item in row $i and column $j
                    $candidate_tasks[$j]  = 1;
                    $candidate_agents[$i] = 1;
                }

                if ( $cost > $max ) {
                    $max = $cost;
                }
            }
        }

        # Remove any hold request for which there is no finite transport cost item available.
        my $removed_something = 0;

        for ( my $j = 0, my $j0 = 0 ; $j < $num_tasks ; $j++ ) {
            if ( !$candidate_tasks[$j] ) {
                for ( my $i = 0 ; $i < $num_agents ; $i++ ) {
                    splice @{ $m[$i] }, $j - $j0, 1;
                }
                splice @requests, $j - $j0, 1;
                $j0++;
                $removed_something = 1;
            }
        }

        $num_tasks = scalar(@requests);

        if ( $num_agents > $num_tasks && @remaining ) {

            $r                = $num_tasks;
            @candidate_tasks  = ( (1) x $num_tasks );
            @candidate_agents = ( (1) x $num_agents );
            next RETRY;
        }

        if ( $num_tasks > $num_agents ) {

            return [] if $num_agents == 0;
            unshift @remaining, ( splice @requests, $num_agents );
            $num_tasks = $num_agents;
        }

        return [] if $num_agents == 0 || $num_tasks == 0;

        # Substitute infinity with a cost that is higher than the total of
        # any possible assignment.  This ensures that any possible
        # assignment will be selected before any assignment of infinite
        # cost.  Infinite cost assignments can be be filtered out at the
        # end.
        $inf = $max * $num_tasks + 1;

        my @m0 = map { [ (undef) x $num_tasks ] } ( 1 .. $num_agents );
        for ( my $i = 0 ; $i < $num_agents ; $i++ ) {
            for ( my $j = 0 ; $j < $num_tasks ; $j++ ) {
                if ( $m[$i][$j] < 0 ) {

                    # Bias towards not allocating items to holds closer to
                    # the end of the queue in the queue if not all holds
                    # can be filled by representing infinity with
                    # different values.
                    $m0[$i][$j] = $inf + ( $num_tasks - $j );
                } else {
                    $m0[$i][$j] = $m[$i][$j];
                }
            }
        }

        my $res = [ (undef) x $num_agents ];

        Algorithm::Munkres::assign( \@m0, $res );

        my @unallocated = ();
        @allocated = ();
        for ( my $i = 0 ; $i < $num_agents ; $i++ ) {
            my $j = $res->[$i];
            if ( !defined $j || $j >= $num_tasks ) {

                # If the algorithm zero-pads the matrix
                # (Algorithm::Munkres version 0.08) holds may be
                # allocated to nonexisting items ($j >= 0).  We just ignore these.
                next;
            }
            if ( $m0[$i][$j] > $max ) {

                # No finite cost item was assigned to this hold.
                push @unallocated, $j;
            } else {

                my $request = $requests[$j];
                my $item    = $remaining_items[$i];
                push @allocated, [
                    $item->{itemnumber},
                    {
                        borrowernumber => $request->{borrowernumber},
                        biblionumber   => $request->{biblionumber},
                        holdingbranch  => $item->{holdingbranch},
                        pickup_branch  => $request->{branchcode}
                            || $request->{borrowerbranch},
                        reserve_id   => $request->{reserve_id},
                        item_level   => $request->{item_level_hold},
                        reservedate  => $request->{reservedate},
                        reservenotes => $request->{reservenotes},
                    }
                ];
            }
        }

        if ( $retries-- > 0 && @unallocated && @remaining ) {

            # Remove the transport cost of unfilled holds and compact the matrix.
            # Also remove the hold request from the array.
            for ( my $i = 0 ; $i < $num_agents ; $i++ ) {
                my $u = 0;
                for ( my $j = 0 ; $j < $num_tasks ; $j++ ) {
                    if ( $u < scalar(@unallocated) && $unallocated[$u] == $j ) {
                        $u++;
                    } elsif ( $u > 0 ) {
                        $m[$i][ $j - $u ] = $m[$i][$j];
                    }
                }
            }
            for ( my $u = 0 ; $u < scalar(@unallocated) ; $u++ ) {
                splice @requests, $unallocated[$u], 1;
            }
            $num_tasks = scalar(@requests);

            $r = $num_tasks;
        } else {
            if ( $retries == 0 && @unallocated && @remaining ) {
                Koha::Logger->get->warn(
                    "There are available items that have not been allocated and remaining holds, but we abort trying to fill these after $RETRIES retries."
                );
            }
            last RETRY;
        }
    }

    return \@allocated;
}

=head2 MapItemsToHoldRequests

  my $item_map = MapItemsToHoldRequests($hold_requests, $available_items, $branches, $transport_cost_matrix)

  Parameters:
  $hold_requests is a hash containing hold information built by GetPendingHoldRequestsForBib
  $available_items is a hash containing item information built by GetItemsAvailableToFillHoldRequestsForBib
  $branches is an arrayref to a list of branches filled by load_branches_to_pull_from
  $transport_cost_matrix is a hash of hashes with branchcodes as keys, listing the cost to transfer from that branch to another

  Returns a hash of hashes with itemnumbers as keys, each itemnumber containing a hash with the information
  about the hold it has been mapped to.

  This routine attempts to match the holds in the following priority
  1 - If local holds priority is enabled we check all requests to see if local matches can be found
  2 - We check for item level matches and fill those
  3 - We now loop the remaining requests in priority order attempting to fill with
      a - Items where HoldsQueuePrioritizeBranch matches either from items held at the pickup branch, or at the least cost branch (if Transport Cost Matrix is being used)
      b - Items where the homebranch of the item and the pickup library match
      c - Items from the least cost branch (or items at the pickup location if available)
      d - Any item that can fill the hold

=cut

sub MapItemsToHoldRequests {
    my ( $hold_requests, $available_items, $branches_to_use, $transport_cost_matrix ) = @_;

    # handle trivial cases
    return unless scalar(@$hold_requests) > 0;
    return unless scalar(@$available_items) > 0;

    map { $_->{_object} = Koha::Items->find( $_->{itemnumber} ) } @$available_items;
    my $libraries = {};
    map { $libraries->{ $_->id } = $_ } Koha::Libraries->search->as_list;

    # group available items by itemnumber
    my %items_by_itemnumber = map { $_->{itemnumber} => $_ } @$available_items;

    # items already allocated
    my %allocated_items = ();

    # map of items to hold requests
    my %item_map = ();

    # figure out which item-level requests can be filled
    my $num_items_remaining = scalar(@$available_items);

    # Look for Local Holds Priority matches first

    my $LocalHoldsPriority = C4::Context->preference('LocalHoldsPriority');
    if ( $LocalHoldsPriority ne 'None' ) {
        my $LocalHoldsPriorityPatronControl = C4::Context->preference('LocalHoldsPriorityPatronControl');
        my $LocalHoldsPriorityItemControl   = C4::Context->preference('LocalHoldsPriorityItemControl');
        foreach my $request (@$hold_requests) {
            last if $num_items_remaining == 0;
            my $patron = Koha::Patrons->find( $request->{borrowernumber} );
            next if $patron->category->exclude_from_local_holds_priority;
            if ( $LocalHoldsPriority eq 'GiveLibrary' || $LocalHoldsPriority eq 'GiveLibraryAndGroup' ) {
                my $local_hold_match;
                foreach my $item (@$available_items) {
                    next if $item->{_object}->exclude_from_local_holds_priority;

                    next unless _can_item_fill_request( $item, $request, $libraries );

                    next if $request->{itemnumber} && $request->{itemnumber} != $item->{itemnumber};

                    my $local_holds_priority_item_branchcode = $item->{$LocalHoldsPriorityItemControl};

                    my $local_holds_priority_patron_branchcode =
                          ( $LocalHoldsPriorityPatronControl eq 'PickupLibrary' ) ? $request->{branchcode}
                        : ( $LocalHoldsPriorityPatronControl eq 'HomeLibrary' )   ? $request->{borrowerbranch}
                        :                                                           undef;

                    $local_hold_match =
                        $local_holds_priority_item_branchcode eq $local_holds_priority_patron_branchcode;

                    if ($local_hold_match) {
                        if (    exists $items_by_itemnumber{ $item->{itemnumber} }
                            and not exists $allocated_items{ $item->{itemnumber} }
                            and not $request->{allocated} )
                        {
                            $item_map{ $item->{itemnumber} } = {
                                borrowernumber => $request->{borrowernumber},
                                biblionumber   => $request->{biblionumber},
                                holdingbranch  => $item->{holdingbranch},
                                pickup_branch  => $request->{branchcode}
                                    || $request->{borrowerbranch},
                                reserve_id   => $request->{reserve_id},
                                item_level   => $request->{item_level_hold},
                                reservedate  => $request->{reservedate},
                                reservenotes => $request->{reservenotes},
                            };
                            $allocated_items{ $item->{itemnumber} }++;
                            $request->{allocated} = 1;
                            $num_items_remaining--;
                        }
                    }
                }
            }
        }

        # Look for local group matches if no library matches were found
        if ( $LocalHoldsPriority eq 'GiveLibraryGroup' || $LocalHoldsPriority eq 'GiveLibraryAndGroup' ) {
            my $local_hold_group_match;
            foreach my $request (@$hold_requests) {
                last if $num_items_remaining == 0;
                my $patron = Koha::Patrons->find( $request->{borrowernumber} );
                next if $patron->category->exclude_from_local_holds_priority;
                foreach my $item (@$available_items) {
                    next if $item->{_object}->exclude_from_local_holds_priority;

                    next unless _can_item_fill_request( $item, $request, $libraries );

                    next if $request->{itemnumber} && $request->{itemnumber} != $item->{itemnumber};

                    my $local_holds_priority_item_branchcode = $item->{$LocalHoldsPriorityItemControl};

                    my $local_holds_priority_patron_branchcode =
                          ( $LocalHoldsPriorityPatronControl eq 'PickupLibrary' ) ? $request->{branchcode}
                        : ( $LocalHoldsPriorityPatronControl eq 'HomeLibrary' )   ? $request->{borrowerbranch}
                        :                                                           undef;

                    $local_hold_group_match =
                        Koha::Libraries->find( { branchcode => $local_holds_priority_item_branchcode } )
                        ->validate_hold_sibling( { branchcode => $local_holds_priority_patron_branchcode } );

                    if ($local_hold_group_match) {
                        if (    exists $items_by_itemnumber{ $item->{itemnumber} }
                            and not exists $allocated_items{ $item->{itemnumber} }
                            and not $request->{allocated} )
                        {
                            $item_map{ $item->{itemnumber} } = {
                                borrowernumber => $request->{borrowernumber},
                                biblionumber   => $request->{biblionumber},
                                holdingbranch  => $item->{holdingbranch},
                                pickup_branch  => $request->{branchcode}
                                    || $request->{borrowerbranch},
                                reserve_id   => $request->{reserve_id},
                                item_level   => $request->{item_level_hold},
                                reservedate  => $request->{reservedate},
                                reservenotes => $request->{reservenotes},
                            };
                            $allocated_items{ $item->{itemnumber} }++;
                            $request->{allocated} = 1;
                            $num_items_remaining--;
                        }
                    }
                }
            }
        }
    }

    # Handle item level requests
    # Note that we loop the requests in priority order reserving an item for each title level hold
    # So we will only fill item level requests if there are enough items to fill higher priority
    # title level holds.
    foreach my $request (@$hold_requests) {
        last if $num_items_remaining == 0;
        next if $request->{allocated};

        # is this an item-level request?
        if ( defined( $request->{itemnumber} ) ) {

            # fill it if possible; if not skip it
            if (    exists $items_by_itemnumber{ $request->{itemnumber} }
                and not exists $allocated_items{ $request->{itemnumber} }
                and _can_item_fill_request( $items_by_itemnumber{ $request->{itemnumber} }, $request, $libraries ) )
            {

                $item_map{ $request->{itemnumber} } = {
                    borrowernumber => $request->{borrowernumber},
                    biblionumber   => $request->{biblionumber},
                    holdingbranch  => $items_by_itemnumber{ $request->{itemnumber} }->{holdingbranch},
                    pickup_branch  => $request->{branchcode} || $request->{borrowerbranch},
                    reserve_id     => $request->{reserve_id},
                    item_level     => $request->{item_level_hold},
                    reservedate    => $request->{reservedate},
                    reservenotes   => $request->{reservenotes},
                };
                $allocated_items{ $request->{itemnumber} }++;
                $num_items_remaining--;
            }
        } else {

            # it's title-level request that will take up one item
            $num_items_remaining--;
        }
    }

    if ( defined $transport_cost_matrix ) {
        my $allocations = _allocateWithTransportCostMatrix(
            $hold_requests,         $available_items,  $branches_to_use, $libraries,
            $transport_cost_matrix, \%allocated_items, \%items_by_itemnumber
        );
        for my $allocation (@$allocations) {
            $item_map{ $allocation->[0] } = $allocation->[1];
            $num_items_remaining--;
        }
        return \%item_map;
    }

    # group available items by branch
    my %items_by_branch = ();
    foreach my $item (@$available_items) {
        next unless $item->{holdallowed} ne 'not_allowed';

        push @{ $items_by_branch{ $item->{holdingbranch} } }, $item
            unless exists $allocated_items{ $item->{itemnumber} };
    }
    return \%item_map unless keys %items_by_branch;

    # now handle the title-level requests
    $num_items_remaining = scalar(@$available_items) - scalar( keys %allocated_items );
    my $pull_branches;
    foreach my $request (@$hold_requests) {
        last if $num_items_remaining == 0;
        next if $request->{allocated};
        next if defined( $request->{itemnumber} );    # already handled these

        # HoldsQueuePrioritizeBranch check
        # ********************************
        my $pickup_branch = $request->{branchcode} || $request->{borrowerbranch};
        my ( $itemnumber, $holdingbranch );    # These variables are used for tracking the filling of the hold
                                               # $itemnumber, when set, is the item that has been chosen for the hold
            # $holdingbranch gets set to the pickup branch of the request if there are items held at that branch
            # otherwise it gets set to the least cost branch of the transport cost matrix
            # otherwise it gets sets to the first branch from the list of branches to pull from

        my $holding_branch_items = $items_by_branch{$pickup_branch};
        if ($holding_branch_items) {
            $holdingbranch = $pickup_branch;
        }

        my $priority_branch = C4::Context->preference('HoldsQueuePrioritizeBranch') // 'homebranch';
        foreach my $item (@$holding_branch_items) {
            if ( _can_item_fill_request( $item, $request, $libraries )
                && $request->{borrowerbranch} eq $item->{$priority_branch} )
            {
                $itemnumber = $item->{itemnumber};
                last;
            }
        }

        # End HoldsQueuePrioritizeBranch check
        # ********************************

        # Not found yet, fall back to basics
        unless ($itemnumber) {
            if ($branches_to_use) {
                $pull_branches = $branches_to_use;
            } else {
                $pull_branches = [ keys %items_by_branch ];
            }
            $holdingbranch ||= $pull_branches->[0];    # We set this as the first from the list of pull branches
                # unless we set it above to the pickupbranch or the least cost branch
                # FIXME: The intention is to follow StaticHoldsQueueWeight, but we don't check that pref

            # Try picking items where the home and pickup branch match first
            foreach my $branch (@$pull_branches) {
                my $holding_branch_items = $items_by_branch{$branch}
                    or next;

                foreach my $item (@$holding_branch_items) {
                    if ( $pickup_branch eq $item->{homebranch}
                        && _can_item_fill_request( $item, $request, $libraries ) )
                    {
                        $itemnumber    = $item->{itemnumber};
                        $holdingbranch = $branch;
                        last;
                    }
                }
                last if $itemnumber;
            }

            # Now try items from the least cost branch based on the transport cost matrix or StaticHoldsQueueWeight
            unless ( $itemnumber || !$holdingbranch ) {
                foreach my $current_item ( @{ $items_by_branch{$holdingbranch} } ) {
                    next unless _can_item_fill_request( $current_item, $request, $libraries );

                    $itemnumber = $current_item->{itemnumber};
                    last;    # quit this loop as soon as we have a suitable item
                }
            }

            # Now try for items for any item that can fill this hold
            unless ($itemnumber) {
                foreach my $branch (@$pull_branches) {
                    my $holding_branch_items = $items_by_branch{$branch}
                        or next;

                    foreach my $item (@$holding_branch_items) {
                        if ( _can_item_fill_request( $item, $request, $libraries ) ) {
                            $itemnumber    = $item->{itemnumber};
                            $holdingbranch = $branch;
                            last;
                        }
                    }
                    last if $itemnumber;
                }
            }
        }

        if ($itemnumber) {
            my $holding_branch_items = $items_by_branch{$holdingbranch}
                or die "Have $itemnumber, $holdingbranch, but no items!";
            @$holding_branch_items = grep { $_->{itemnumber} != $itemnumber } @$holding_branch_items;
            delete $items_by_branch{$holdingbranch} unless @$holding_branch_items;

            $item_map{$itemnumber} = {
                borrowernumber => $request->{borrowernumber},
                biblionumber   => $request->{biblionumber},
                holdingbranch  => $holdingbranch,
                pickup_branch  => $pickup_branch,
                reserve_id     => $request->{reserve_id},
                item_level     => $request->{item_level_hold},
                reservedate    => $request->{reservedate},
                reservenotes   => $request->{reservenotes},
            };
            $num_items_remaining--;
        }
    }
    return \%item_map;
}

=head2 _can_item_fill_request

  my $bool = _can_item_fill_request( $item, $request, $libraries );

  This is an internal function of MapItemsToHoldRequests for checking an item against a hold. It uses the custom hashes for item and hold information
  used by that routine

=cut

sub _can_item_fill_request {
    my ( $item, $request, $libraries ) = @_;

    # Don't fill item level holds that contravene the hold pickup policy at this time
    return unless _checkHoldPolicy( $item, $request );

    # If hold itemtype is set, item's itemtype must match
    return unless ( !$request->{itemtype}
        || $item->{itype} eq $request->{itemtype} );

    # If hold item_group is set, item's item_group must match
    return
        unless (
        !$request->{item_group_id}
        || (   $item->{_object}->item_group
            && $item->{_object}->item_group->id eq $request->{item_group_id} )
        );

    return
        unless $item->{_object}->can_be_transferred( { to => $libraries->{ $request->{branchcode} } } );

    return 1;
}

=head2 CreatePickListFromItemMap

=cut

=head2 CreatePicklistFromItemMap

Missing POD for CreatePicklistFromItemMap.

=cut

sub CreatePicklistFromItemMap {
    my $item_map = shift;

    my $dbh = C4::Context->dbh;

    my $sth_load = $dbh->prepare( "
        INSERT INTO tmp_holdsqueue (biblionumber,itemnumber,barcode,surname,firstname,phone,borrowernumber,
                                    cardnumber,reservedate,title, itemcallnumber,
                                    holdingbranch,pickbranch,notes, item_level_request)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    " );

    foreach my $itemnumber ( sort keys %$item_map ) {
        my $mapped_item    = $item_map->{$itemnumber};
        my $biblionumber   = $mapped_item->{biblionumber};
        my $borrowernumber = $mapped_item->{borrowernumber};
        my $pickbranch     = $mapped_item->{pickup_branch};
        my $holdingbranch  = $mapped_item->{holdingbranch};
        my $reservedate    = $mapped_item->{reservedate};
        my $reservenotes   = $mapped_item->{reservenotes};
        my $item_level     = $mapped_item->{item_level};

        my $item           = Koha::Items->find($itemnumber);
        my $barcode        = $item->barcode;
        my $itemcallnumber = $item->itemcallnumber;

        my $patron     = Koha::Patrons->find($borrowernumber);
        my $cardnumber = $patron->cardnumber;
        my $surname    = $patron->surname;
        my $firstname  = $patron->firstname;
        my $phone      = $patron->phone;

        my $biblio = Koha::Biblios->find($biblionumber);
        my $title  = $biblio->title;

        $sth_load->execute(
            $biblionumber,  $itemnumber,  $barcode,      $surname, $firstname, $phone, $borrowernumber,
            $cardnumber,    $reservedate, $title,        $itemcallnumber,
            $holdingbranch, $pickbranch,  $reservenotes, $item_level
        );
    }
}

=head2 AddToHoldTargetMap

=cut

sub AddToHoldTargetMap {
    my $item_map = shift;

    my $dbh    = C4::Context->dbh;
    my $schema = Koha::Database->new->schema;

    my $insert_sql = q(
        INSERT INTO hold_fill_targets (borrowernumber, biblionumber, itemnumber, source_branchcode, item_level_request, reserve_id) VALUES (?, ?, ?, ?, ?, ?)
    );
    my $sth_insert = $dbh->prepare($insert_sql);

    foreach my $itemnumber ( keys %$item_map ) {
        my $mapped_item = $item_map->{$itemnumber};
        $schema->txn_do(
            sub {
                $dbh->do( 'DELETE FROM hold_fill_targets WHERE itemnumber = ?', {}, $itemnumber );
                $sth_insert->execute(
                    $mapped_item->{borrowernumber}, $mapped_item->{biblionumber}, $itemnumber,
                    $mapped_item->{holdingbranch},  $mapped_item->{item_level},   $mapped_item->{reserve_id}
                );
            }
        );
    }
}

# Helper functions, not part of any interface

sub _trim {
    return $_[0] unless $_[0];
    $_[0] =~ s/^\s+//;
    $_[0] =~ s/\s+$//;
    $_[0];
}

=head2 load_branches_to_pull_from

Missing POD for load_branches_to_pull_from.

=cut

sub load_branches_to_pull_from {
    my $use_transport_cost_matrix = shift;

    my @branches_to_use;

    unless ($use_transport_cost_matrix) {
        my $static_branch_list = C4::Context->preference("StaticHoldsQueueWeight");
        @branches_to_use = map { _trim($_) } split( /,/, $static_branch_list )
            if $static_branch_list;
    }

    @branches_to_use = Koha::Database->new()->schema()->resultset('Branch')->get_column('branchcode')->all()
        unless (@branches_to_use);

    @branches_to_use = shuffle(@branches_to_use)
        if C4::Context->preference("RandomizeHoldsQueueWeight");

    my $today = dt_from_string();
    if ( C4::Context->preference('HoldsQueueSkipClosed') ) {
        @branches_to_use = grep { !Koha::Calendar->new( branchcode => $_ )->is_holiday($today) } @branches_to_use;
    }

    return \@branches_to_use;
}

=head2 least_cost_branch

Missing POD for least_cost_branch.

=cut

sub least_cost_branch {

    #$from - arrayref
    my ( $to, $from, $transport_cost_matrix ) = @_;

    # Nothing really spectacular: supply to branch, a list of potential from branches
    # and find the minimum from - to value from the transport_cost_matrix
    return $from->[0] if ( @$from == 1 && $transport_cost_matrix->{$to}{ $from->[0] }->{disable_transfer} != 1 );

    # If the pickup library is in the list of libraries to pull from,
    # return that library right away, it is obviously the least costly
    return ($to) if any { $_ eq $to } @$from;

    my ( $least_cost, @branch );
    foreach (@$from) {
        my $cell = $transport_cost_matrix->{$to}{$_};
        next if $cell->{disable_transfer};

        my $cost = $cell->{cost};
        next unless defined $cost;    # XXX should this be reported?

        unless ( defined $least_cost ) {
            $least_cost = $cost;
            push @branch, $_;
            next;
        }

        next if $cost > $least_cost;

        if ( $cost == $least_cost ) {
            push @branch, $_;
            next;
        }

        @branch     = ($_);
        $least_cost = $cost;
    }

    return $branch[0];

    # XXX return a random @branch with minimum cost instead of the first one;
    # return $branch[0] if @branch == 1;
}

=head3 update_queue_for_biblio

    my $result = update_queue_for_biblio(
        {
            biblio_id             => $biblio_id,
          [ branches_to_use       => $branches_to_use,
            transport_cost_matrix => $transport_cost_matrix,
            delete                => $delete,
            unallocated           => $unallocated, ]
        }
    );

Given a I<biblio_id>, this method calculates and sets the holds queue entries
for the biblio's holds, and the hold fill targets (items).

=head4 Return value

It return a hashref containing:

=over

=item I<requests>: the pending holds count for the biblio.

=item I<available_items> the count of items that are available to fill holds for the biblio.

=item I<mapped_items> the total items that got mapped.

=back

=head4 Optional parameters

=over

=item I<branches_to_use> a list of branchcodes to be used to restrict which items can be used.

=item I<transport_cost_matrix> is the output of C<TransportCostMatrix>.

=item I<delete> tells the method to delete prior entries on the related tables for the biblio_id.

=item I<unallocated> tells the method to limit the holds to those not in the holds queue, should not
    be passed at the same time as delete.

=back

Note: All the optional parameters will be calculated in the method if omitted. They
are allowed to be passed to avoid calculating them many times inside loops.

=cut

sub update_queue_for_biblio {
    my ($args) = @_;
    my $biblio_id = $args->{biblio_id};
    my $result;

    # We need to empty the queue for this biblio unless CreateQueue has emptied the entire queue for rebuilding
    if ( $args->{delete} ) {
        my $dbh = C4::Context->dbh;

        $dbh->do("DELETE FROM tmp_holdsqueue WHERE biblionumber=$biblio_id");
        $dbh->do("DELETE FROM hold_fill_targets WHERE biblionumber=$biblio_id");
    }

    my $hold_requests =
        GetPendingHoldRequestsForBib( { biblionumber => $biblio_id, unallocated => $args->{unallocated} } );
    $result->{requests} = scalar( @{$hold_requests} );

    # No need to check anything else if there are no holds to fill
    return $result unless $result->{requests};

    my $branches_to_use = $args->{branches_to_use}
        // load_branches_to_pull_from( C4::Context->preference('UseTransportCostMatrix') );
    my $transport_cost_matrix;

    if ( !exists $args->{transport_cost_matrix}
        && C4::Context->preference('UseTransportCostMatrix') )
    {
        $transport_cost_matrix = TransportCostMatrix();
    } else {
        $transport_cost_matrix = $args->{transport_cost_matrix};
    }

    my $available_items = GetItemsAvailableToFillHoldRequestsForBib( $biblio_id, $branches_to_use );

    $result->{available_items} = scalar( @{$available_items} );

    my $item_map = MapItemsToHoldRequests( $hold_requests, $available_items, $branches_to_use, $transport_cost_matrix );
    $result->{mapped_items} = scalar( keys %{$item_map} );

    if ($item_map) {
        CreatePicklistFromItemMap($item_map);
        AddToHoldTargetMap($item_map);
    }

    return $result;
}

1;
