#!/usr/bin/perl 
#-----------------------------------
# Script Name: build_holds_queue.pl
# Description: builds a holds queue in the tmp_holdsqueue table
#-----------------------------------

use strict;
use warnings;
BEGIN {
    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/../kohalib.pl" };
}

use C4::Context;
use C4::Search;
use C4::Items;
use C4::Branch;
use C4::Circulation;
use C4::Members;
use C4::Biblio;
use Data::Dumper;

my $bibs_with_pending_requests = GetBibsWithPendingHoldRequests();

my $dbh   = C4::Context->dbh;
$dbh->do("DELETE FROM tmp_holdsqueue");  # clear the old table for new info
$dbh->do("DELETE FROM hold_fill_targets");

my $total_bibs = 0;
my $total_requests = 0;
my $total_available_items = 0;
my $num_items_mapped = 0;
foreach my $biblionumber (@$bibs_with_pending_requests) {
    $total_bibs++;
    my $hold_requests =   GetPendingHoldRequestsForBib($biblionumber);
    $total_requests += scalar(@$hold_requests);
    my $available_items = GetItemsAvailableToFillHoldRequestsForBib($biblionumber);
    $total_available_items += scalar(@$available_items);
    my $item_map = MapItemsToHoldRequests($hold_requests, $available_items);
    if (defined($item_map)) {
        $num_items_mapped += scalar(keys %$item_map);
        CreatePicklistFromItemMap($item_map);
        AddToHoldTargetMap($item_map);
        if ((scalar(keys %$item_map) < scalar(@$hold_requests)) and
            (scalar(keys %$item_map) < scalar(@$available_items))) {
            # DOUBLE CHECK, but this is probably OK - unfilled item-level requests
            # FIXME
            #warn "unfilled requests for $biblionumber";
            #warn Dumper($hold_requests);
            #warn Dumper($available_items);
            #warn Dumper($item_map);
        }
    }
}

exit 0;

=head2 GetBibsWithPendingHoldRequests

=over 4

my $biblionumber_aref = GetBibsWithPendingHoldRequests();

=back

Return an arrayref of the biblionumbers of all bibs
that have one or more unfilled hold requests.

=cut

sub GetBibsWithPendingHoldRequests {
    my $dbh = C4::Context->dbh;

    my $bib_query = "SELECT DISTINCT biblionumber
                     FROM reserves
                     WHERE found IS NULL
                     AND priority > 0";
    my $sth = $dbh->prepare($bib_query);

    $sth->execute();
    my $biblionumbers = $sth->fetchall_arrayref();

    return [ map { $_->[0] } @$biblionumbers ];
}

=head2 GetPendingHoldRequestsForBib

=over 4

my $requests = GetPendingHoldRequestsForBib($biblionumber);

=back

Returns an arrayref of hashrefs to pending, unfilled hold requests
on the bib identified by $biblionumber.  The following keys
are present in each hashref:

biblionumber
borrowernumber
itemnumber
priority
branchcode
reservedate
reservenotes

The arrayref is sorted in order of increasing priority.

=cut

sub GetPendingHoldRequestsForBib {
    my $biblionumber = shift;

    my $dbh = C4::Context->dbh;

    my $request_query = "SELECT biblionumber, borrowernumber, itemnumber, priority, branchcode, reservedate, reservenotes
                         FROM reserves
                         WHERE biblionumber = ?
                         AND found IS NULL
                         AND priority > 0
                         ORDER BY priority";
    my $sth = $dbh->prepare($request_query);
    $sth->execute($biblionumber);

    my $requests = $sth->fetchall_arrayref({});
    return $requests;

}

=head2 GetItemsAvailableToFillHoldRequestsForBib

=over 4

my $available_items = GetItemsAvailableToFillHoldRequestsForBib($biblionumber);

=back

Returns an arrayref of items available to fill hold requests
for the bib identified by C<$biblionumber>.  An item is available
to fill a hold request if and only if:

* it is not on loan
* it is not withdrawn
* it is not marked notforloan
* it is not currently in transit
* it is not lost
* it is not sitting on the hold shelf

=cut

sub GetItemsAvailableToFillHoldRequestsForBib {
    my $biblionumber = shift;

    my $dbh = C4::Context->dbh;
    my $items_query = "SELECT itemnumber, homebranch, holdingbranch
                       FROM items ";

    if (C4::Context->preference('item-level_itypes')) {
        $items_query .=   "LEFT JOIN itemtypes ON (itemtypes.itemtype = items.itype) ";
    } else {
        $items_query .=   "JOIN biblioitems USING (biblioitemnumber)
                           LEFT JOIN itemtypes USING (itemtype) ";
    }
    $items_query .=   "LEFT JOIN reserves USING (itemnumber)
                       WHERE items.notforloan = 0
                       AND holdingbranch IS NOT NULL
                       AND itemlost = 0
                       AND wthdrawn = 0
                       AND items.onloan IS NULL
                       AND (itemtypes.notforloan IS NULL OR itemtypes.notforloan = 0)
                       AND (priority IS NULL OR priority > 0)
                       AND found IS NULL
                       AND biblionumber = ?";
    my $sth = $dbh->prepare($items_query);
    $sth->execute($biblionumber);

    my $items = $sth->fetchall_arrayref({});
    return [ grep { my @transfers = GetTransfers($_->{itemnumber}); $#transfers == -1; } @$items ]; 
}

=head2 MapItemsToHoldRequests

=over 4

MapItemsToHoldRequests($hold_requests, $available_items);

=back

=cut

sub MapItemsToHoldRequests {
    my $hold_requests = shift;
    my $available_items = shift;

    # handle trival cases
    return unless scalar(@$hold_requests) > 0;
    return unless scalar(@$available_items) > 0;

    # identify item-level requests
    my %specific_items_requested = map { $_->{itemnumber} => 1 } 
                                   grep { defined($_->{itemnumber}) }
                                   @$hold_requests;

    # group available items by itemnumber
    my %items_by_itemnumber = map { $_->{itemnumber} => $_ } @$available_items;

    # items already allocated
    my %allocated_items = ();

    # map of items to hold requests
    my %item_map = ();
 
    # figure out which item-level requests can be filled    
    my $num_items_remaining = scalar(@$available_items);
    foreach my $request (@$hold_requests) {
        last if $num_items_remaining == 0;

        # is this an item-level request?
        if (defined($request->{itemnumber})) {
            # fill it if possible; if not skip it
            if (exists $items_by_itemnumber{$request->{itemnumber}} and
                not exists $allocated_items{$request->{itemnumber}}) {
                $item_map{$request->{itemnumber}} = { 
                    borrowernumber => $request->{borrowernumber},
                    biblionumber => $request->{biblionumber},
                    holdingbranch =>  $items_by_itemnumber{$request->{itemnumber}}->{holdingbranch},
                    pickup_branch => $request->{branchcode},
                    item_level => 1,
                    reservedate => $request->{reservedate},
                    reservenotes => $request->{reservenotes},
                };
                $allocated_items{$request->{itemnumber}}++;
                $num_items_remaining--;
            }
        } else {
            # it's title-level request that will take up one item
            $num_items_remaining--;
        }
    }

    # group available items by branch
    my %items_by_branch = ();
    foreach my $item (@$available_items) {
        push @{ $items_by_branch{ $item->{holdingbranch} } }, $item unless exists $allocated_items{ $item->{itemnumber} };
    }

    # now handle the title-level requests
    $num_items_remaining = scalar(@$available_items) - scalar(keys %allocated_items); 
    foreach my $request (@$hold_requests) {
        last if $num_items_remaining <= 0;
        next if defined($request->{itemnumber}); # already handled these

        # look for local match first
        my $pickup_branch = $request->{branchcode};
        if (exists $items_by_branch{$pickup_branch}) {
            my $item = pop @{ $items_by_branch{$pickup_branch} };
            delete $items_by_branch{$pickup_branch} if scalar(@{ $items_by_branch{$pickup_branch} }) == 0;
            $item_map{$item->{itemnumber}} = { 
                                                borrowernumber => $request->{borrowernumber},
                                                biblionumber => $request->{biblionumber},
                                                holdingbranch => $pickup_branch,
                                                pickup_branch => $pickup_branch,
                                                item_level => 0,
                                                reservedate => $request->{reservedate},
                                                reservenotes => $request->{reservenotes},
                                             };
            $num_items_remaining--;
        } else {
            # FIXME implement static, random options
            foreach my $branch (sort keys %items_by_branch) {
                my $item = pop @{ $items_by_branch{$branch} };
                delete $items_by_branch{$branch} if scalar(@{ $items_by_branch{$branch} }) == 0;
                $item_map{$item->{itemnumber}} = { 
                                                    borrowernumber => $request->{borrowernumber},
                                                    biblionumber => $request->{biblionumber},
                                                    holdingbranch => $branch,
                                                    pickup_branch => $pickup_branch,
                                                    item_level => 0,
                                                    reservedate => $request->{reservedate},
                                                    reservenotes => $request->{reservenotes},
                                                 };
                $num_items_remaining--; 
                last;
            }
        }
    }
    return \%item_map;
}

=head2 CreatePickListFromItemMap 

=cut

sub CreatePicklistFromItemMap {
    my $item_map = shift;

    my $dbh = C4::Context->dbh;

    my $sth_load=$dbh->prepare("
        INSERT INTO tmp_holdsqueue (biblionumber,itemnumber,barcode,surname,firstname,phone,borrowernumber,
                                    cardnumber,reservedate,title, itemcallnumber,
                                    holdingbranch,pickbranch,notes, item_level_request)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    ");

    foreach my $itemnumber  (sort keys %$item_map) {
        my $mapped_item = $item_map->{$itemnumber};
        my $biblionumber = $mapped_item->{biblionumber}; 
        my $borrowernumber = $mapped_item->{borrowernumber}; 
        my $pickbranch = $mapped_item->{pickup_branch};
        my $holdingbranch = $mapped_item->{holdingbranch};
        my $reservedate = $mapped_item->{reservedate};
        my $reservenotes = $mapped_item->{reservenotes};
        my $item_level = $mapped_item->{item_level};

        my $item = GetItem($itemnumber);
        my $barcode = $item->{barcode};
        my $itemcallnumber = $item->{itemcallnumber};

        my $borrower = GetMember($borrowernumber);
        my $cardnumber = $borrower->{'cardnumber'};
        my $surname = $borrower->{'surname'};
        my $firstname = $borrower->{'firstname'};
        my $phone = $borrower->{'phone'};
   
        my $bib = GetBiblioData($biblionumber);
        my $title = $bib->{title}; 

        $sth_load->execute($biblionumber, $itemnumber, $barcode, $surname, $firstname, $phone, $borrowernumber,
                           $cardnumber, $reservedate, $title, $itemcallnumber,
                           $holdingbranch, $pickbranch, $reservenotes, $item_level);
    }
}

=head2 AddToHoldTargetMap

=cut

sub AddToHoldTargetMap {
    my $item_map = shift;

    my $dbh = C4::Context->dbh;

    my $insert_sql = q(
        INSERT INTO hold_fill_targets (borrowernumber, biblionumber, itemnumber, source_branchcode, item_level_request)
                               VALUES (?, ?, ?, ?, ?)
    );
    my $sth_insert = $dbh->prepare($insert_sql);

    foreach my $itemnumber (keys %$item_map) {
        my $mapped_item = $item_map->{$itemnumber};
        $sth_insert->execute($mapped_item->{borrowernumber}, $mapped_item->{biblionumber}, $itemnumber,
                             $mapped_item->{holdingbranch}, $mapped_item->{item_level});
    }
}
