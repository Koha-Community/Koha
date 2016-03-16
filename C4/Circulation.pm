package C4::Circulation;

# Copyright 2000-2002 Katipo Communications
# copyright 2010 BibLibre
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
#use warnings; FIXME - Bug 2505
use DateTime;
use Koha::DateUtils;
use C4::Context;
use C4::Stats;
use C4::Reserves;
use C4::Biblio;
use C4::Items;
use C4::Members;
use C4::Accounts;
use C4::ItemCirculationAlertPreference;
use C4::Message;
use C4::Debug;
use C4::Branch; # GetBranches
use C4::Log; # logaction
use C4::Koha qw(
    GetAuthorisedValueByCode
    GetAuthValCode
    GetKohaAuthorisedValueLib
);
use C4::Overdues qw(CalcFine UpdateFine get_chargeable_units);
use C4::RotatingCollections qw(GetCollectionItemBranches);
use Algorithm::CheckDigits;

use Data::Dumper;
use Koha::DateUtils;
use Koha::Calendar;
use Koha::Items;
use Koha::Patrons;
use Koha::Patron::Debarments;
use Koha::Database;
use Koha::Libraries;
use Koha::Holds;
use Carp;
use List::MoreUtils qw( uniq );
use Scalar::Util qw( looks_like_number );
use Date::Calc qw(
  Today
  Today_and_Now
  Add_Delta_YM
  Add_Delta_DHMS
  Date_to_Days
  Day_of_Week
  Add_Delta_Days
);
use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
	require Exporter;
	@ISA    = qw(Exporter);

	# FIXME subs that should probably be elsewhere
	push @EXPORT, qw(
		&barcodedecode
        &LostItem
        &ReturnLostItem
        &GetPendingOnSiteCheckouts
	);

	# subs to deal with issuing a book
	push @EXPORT, qw(
		&CanBookBeIssued
		&CanBookBeRenewed
		&AddIssue
		&AddRenewal
		&GetRenewCount
        &GetSoonestRenewDate
		&GetItemIssue
		&GetItemIssues
		&GetIssuingCharges
		&GetIssuingRule
        &GetBranchBorrowerCircRule
        &GetBranchItemRule
		&GetBiblioIssues
		&GetOpenIssue
		&AnonymiseIssueHistory
        &CheckIfIssuedToPatron
        &IsItemIssued
        GetTopIssues
	);

	# subs to deal with returns
	push @EXPORT, qw(
		&AddReturn
        &MarkIssueReturned
	);

	# subs to deal with transfers
	push @EXPORT, qw(
		&transferbook
		&GetTransfers
		&GetTransfersFromTo
		&updateWrongTransfer
		&DeleteTransfer
                &IsBranchTransferAllowed
                &CreateBranchTransferLimit
                &DeleteBranchTransferLimits
        &TransferSlip
	);

    # subs to deal with offline circulation
    push @EXPORT, qw(
      &GetOfflineOperations
      &GetOfflineOperation
      &AddOfflineOperation
      &DeleteOfflineOperation
      &ProcessOfflineOperation
    );
}

=head1 NAME

C4::Circulation - Koha circulation module

=head1 SYNOPSIS

use C4::Circulation;

=head1 DESCRIPTION

The functions in this module deal with circulation, issues, and
returns, as well as general information about the library.
Also deals with stocktaking.

=head1 FUNCTIONS

=head2 barcodedecode

  $str = &barcodedecode($barcode, [$filter]);

Generic filter function for barcode string.
Called on every circ if the System Pref itemBarcodeInputFilter is set.
Will do some manipulation of the barcode for systems that deliver a barcode
to circulation.pl that differs from the barcode stored for the item.
For proper functioning of this filter, calling the function on the 
correct barcode string (items.barcode) should return an unaltered barcode.

The optional $filter argument is to allow for testing or explicit 
behavior that ignores the System Pref.  Valid values are the same as the 
System Pref options.

=cut

# FIXME -- the &decode fcn below should be wrapped into this one.
# FIXME -- these plugins should be moved out of Circulation.pm
#
sub barcodedecode {
    my ($barcode, $filter) = @_;
    my $branch = C4::Branch::mybranch();
    $filter = C4::Context->preference('itemBarcodeInputFilter') unless $filter;
    $filter or return $barcode;     # ensure filter is defined, else return untouched barcode
	if ($filter eq 'whitespace') {
		$barcode =~ s/\s//g;
	} elsif ($filter eq 'cuecat') {
		chomp($barcode);
	    my @fields = split( /\./, $barcode );
	    my @results = map( decode($_), @fields[ 1 .. $#fields ] );
	    ($#results == 2) and return $results[2];
	} elsif ($filter eq 'T-prefix') {
		if ($barcode =~ /^[Tt](\d)/) {
			(defined($1) and $1 eq '0') and return $barcode;
            $barcode = substr($barcode, 2) + 0;     # FIXME: probably should be substr($barcode, 1)
		}
        return sprintf("T%07d", $barcode);
        # FIXME: $barcode could be "T1", causing warning: substr outside of string
        # Why drop the nonzero digit after the T?
        # Why pass non-digits (or empty string) to "T%07d"?
	} elsif ($filter eq 'libsuite8') {
		unless($barcode =~ m/^($branch)-/i){	#if barcode starts with branch code its in Koha style. Skip it.
			if($barcode =~ m/^(\d)/i){	#Some barcodes even start with 0's & numbers and are assumed to have b as the item type in the libsuite8 software
                                $barcode =~ s/^[0]*(\d+)$/$branch-b-$1/i;
                        }else{
				$barcode =~ s/^(\D+)[0]*(\d+)$/$branch-$1-$2/i;
			}
		}
    } elsif ($filter eq 'EAN13') {
        my $ean = CheckDigits('ean');
        if ( $ean->is_valid($barcode) ) {
            #$barcode = sprintf('%013d',$barcode); # this doesn't work on 32-bit systems
            $barcode = '0' x ( 13 - length($barcode) ) . $barcode;
        } else {
            warn "# [$barcode] not valid EAN-13/UPC-A\n";
        }
	}
    return $barcode;    # return barcode, modified or not
}

=head2 decode

  $str = &decode($chunk);

Decodes a segment of a string emitted by a CueCat barcode scanner and
returns it.

FIXME: Should be replaced with Barcode::Cuecat from CPAN
or Javascript based decoding on the client side.

=cut

sub decode {
    my ($encoded) = @_;
    my $seq =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+-';
    my @s = map { index( $seq, $_ ); } split( //, $encoded );
    my $l = ( $#s + 1 ) % 4;
    if ($l) {
        if ( $l == 1 ) {
            # warn "Error: Cuecat decode parsing failed!";
            return;
        }
        $l = 4 - $l;
        $#s += $l;
    }
    my $r = '';
    while ( $#s >= 0 ) {
        my $n = ( ( $s[0] << 6 | $s[1] ) << 6 | $s[2] ) << 6 | $s[3];
        $r .=
            chr( ( $n >> 16 ) ^ 67 )
         .chr( ( $n >> 8 & 255 ) ^ 67 )
         .chr( ( $n & 255 ) ^ 67 );
        @s = @s[ 4 .. $#s ];
    }
    $r = substr( $r, 0, length($r) - $l );
    return $r;
}

=head2 transferbook

  ($dotransfer, $messages, $iteminformation) = &transferbook($newbranch, 
                                            $barcode, $ignore_reserves);

Transfers an item to a new branch. If the item is currently on loan, it is automatically returned before the actual transfer.

C<$newbranch> is the code for the branch to which the item should be transferred.

C<$barcode> is the barcode of the item to be transferred.

If C<$ignore_reserves> is true, C<&transferbook> ignores reserves.
Otherwise, if an item is reserved, the transfer fails.

Returns three values:

=over

=item $dotransfer 

is true if the transfer was successful.

=item $messages

is a reference-to-hash which may have any of the following keys:

=over

=item C<BadBarcode>

There is no item in the catalog with the given barcode. The value is C<$barcode>.

=item C<IsPermanent>

The item's home branch is permanent. This doesn't prevent the item from being transferred, though. The value is the code of the item's home branch.

=item C<DestinationEqualsHolding>

The item is already at the branch to which it is being transferred. The transfer is nonetheless considered to have failed. The value should be ignored.

=item C<WasReturned>

The item was on loan, and C<&transferbook> automatically returned it before transferring it. The value is the borrower number of the patron who had the item.

=item C<ResFound>

The item was reserved. The value is a reference-to-hash whose keys are fields from the reserves table of the Koha database, and C<biblioitemnumber>. It also has the key C<ResFound>, whose value is either C<Waiting> or C<Reserved>.

=item C<WasTransferred>

The item was eligible to be transferred. Barring problems communicating with the database, the transfer should indeed have succeeded. The value should be ignored.

=back

=back

=cut

sub transferbook {
    my ( $tbr, $barcode, $ignoreRs ) = @_;
    my $messages;
    my $dotransfer      = 1;
    my $branches        = GetBranches();
    my $itemnumber = GetItemnumberFromBarcode( $barcode );
    my $issue      = GetItemIssue($itemnumber);
    my $biblio = GetBiblioFromItemNumber($itemnumber);

    # bad barcode..
    if ( not $itemnumber ) {
        $messages->{'BadBarcode'} = $barcode;
        $dotransfer = 0;
    }

    # get branches of book...
    my $hbr = $biblio->{'homebranch'};
    my $fbr = $biblio->{'holdingbranch'};

    # if using Branch Transfer Limits
    if ( C4::Context->preference("UseBranchTransferLimits") == 1 ) {
        if ( C4::Context->preference("item-level_itypes") && C4::Context->preference("BranchTransferLimitsType") eq 'itemtype' ) {
            if ( ! IsBranchTransferAllowed( $tbr, $fbr, $biblio->{'itype'} ) ) {
                $messages->{'NotAllowed'} = $tbr . "::" . $biblio->{'itype'};
                $dotransfer = 0;
            }
        } elsif ( ! IsBranchTransferAllowed( $tbr, $fbr, $biblio->{ C4::Context->preference("BranchTransferLimitsType") } ) ) {
            $messages->{'NotAllowed'} = $tbr . "::" . $biblio->{ C4::Context->preference("BranchTransferLimitsType") };
            $dotransfer = 0;
    	}
    }

    # if is permanent...
    if ( $hbr && $branches->{$hbr}->{'PE'} ) {
        $messages->{'IsPermanent'} = $hbr;
        $dotransfer = 0;
    }

    # can't transfer book if is already there....
    if ( $fbr eq $tbr ) {
        $messages->{'DestinationEqualsHolding'} = 1;
        $dotransfer = 0;
    }

    # check if it is still issued to someone, return it...
    if ($issue->{borrowernumber}) {
        AddReturn( $barcode, $fbr );
        $messages->{'WasReturned'} = $issue->{borrowernumber};
    }

    # find reserves.....
    # That'll save a database query.
    my ( $resfound, $resrec, undef ) =
      CheckReserves( $itemnumber );
    if ( $resfound and not $ignoreRs ) {
        $resrec->{'ResFound'} = $resfound;

        #         $messages->{'ResFound'} = $resrec;
        $dotransfer = 1;
    }

    #actually do the transfer....
    if ($dotransfer) {
        ModItemTransfer( $itemnumber, $fbr, $tbr );

        # don't need to update MARC anymore, we do it in batch now
        $messages->{'WasTransfered'} = 1;

    }
    ModDateLastSeen( $itemnumber );
    return ( $dotransfer, $messages, $biblio );
}


sub TooMany {
    my $borrower        = shift;
    my $biblionumber = shift;
	my $item		= shift;
    my $params = shift;
    my $onsite_checkout = $params->{onsite_checkout} || 0;
    my $cat_borrower    = $borrower->{'categorycode'};
    my $dbh             = C4::Context->dbh;
	my $branch;
	# Get which branchcode we need
	$branch = _GetCircControlBranch($item,$borrower);
	my $type = (C4::Context->preference('item-level_itypes')) 
  			? $item->{'itype'}         # item-level
			: $item->{'itemtype'};     # biblio-level
 
    # given branch, patron category, and item type, determine
    # applicable issuing rule
    my $issuing_rule = GetIssuingRule($cat_borrower, $type, $branch);

    # if a rule is found and has a loan limit set, count
    # how many loans the patron already has that meet that
    # rule
    if (defined($issuing_rule) and defined($issuing_rule->{'maxissueqty'})) {
        my @bind_params;
        my $count_query = q|
            SELECT COUNT(*) AS total, COALESCE(SUM(onsite_checkout), 0) AS onsite_checkouts
            FROM issues
            JOIN items USING (itemnumber)
        |;

        my $rule_itemtype = $issuing_rule->{itemtype};
        if ($rule_itemtype eq "*") {
            # matching rule has the default item type, so count only
            # those existing loans that don't fall under a more
            # specific rule
            if (C4::Context->preference('item-level_itypes')) {
                $count_query .= " WHERE items.itype NOT IN (
                                    SELECT itemtype FROM issuingrules
                                    WHERE branchcode = ?
                                    AND   (categorycode = ? OR categorycode = ?)
                                    AND   itemtype <> '*'
                                  ) ";
            } else { 
                $count_query .= " JOIN  biblioitems USING (biblionumber) 
                                  WHERE biblioitems.itemtype NOT IN (
                                    SELECT itemtype FROM issuingrules
                                    WHERE branchcode = ?
                                    AND   (categorycode = ? OR categorycode = ?)
                                    AND   itemtype <> '*'
                                  ) ";
            }
            push @bind_params, $issuing_rule->{branchcode};
            push @bind_params, $issuing_rule->{categorycode};
            push @bind_params, $cat_borrower;
        } else {
            # rule has specific item type, so count loans of that
            # specific item type
            if (C4::Context->preference('item-level_itypes')) {
                $count_query .= " WHERE items.itype = ? ";
            } else { 
                $count_query .= " JOIN  biblioitems USING (biblionumber) 
                                  WHERE biblioitems.itemtype= ? ";
            }
            push @bind_params, $type;
        }

        $count_query .= " AND borrowernumber = ? ";
        push @bind_params, $borrower->{'borrowernumber'};
        my $rule_branch = $issuing_rule->{branchcode};
        if ($rule_branch ne "*") {
            if (C4::Context->preference('CircControl') eq 'PickupLibrary') {
                $count_query .= " AND issues.branchcode = ? ";
                push @bind_params, $branch;
            } elsif (C4::Context->preference('CircControl') eq 'PatronLibrary') {
                ; # if branch is the patron's home branch, then count all loans by patron
            } else {
                $count_query .= " AND items.homebranch = ? ";
                push @bind_params, $branch;
            }
        }

        my ( $checkout_count, $onsite_checkout_count ) = $dbh->selectrow_array( $count_query, {}, @bind_params );

        my $max_checkouts_allowed = $issuing_rule->{maxissueqty};
        my $max_onsite_checkouts_allowed = $issuing_rule->{maxonsiteissueqty};

        if ( $onsite_checkout ) {
            if ( $onsite_checkout_count >= $max_onsite_checkouts_allowed )  {
                return {
                    reason => 'TOO_MANY_ONSITE_CHECKOUTS',
                    count => $onsite_checkout_count,
                    max_allowed => $max_onsite_checkouts_allowed,
                }
            }
        }
        if ( C4::Context->preference('ConsiderOnSiteCheckoutsAsNormalCheckouts') ) {
            if ( $checkout_count >= $max_checkouts_allowed ) {
                return {
                    reason => 'TOO_MANY_CHECKOUTS',
                    count => $checkout_count,
                    max_allowed => $max_checkouts_allowed,
                };
            }
        } elsif ( not $onsite_checkout ) {
            if ( $checkout_count - $onsite_checkout_count >= $max_checkouts_allowed )  {
                return {
                    reason => 'TOO_MANY_CHECKOUTS',
                    count => $checkout_count - $onsite_checkout_count,
                    max_allowed => $max_checkouts_allowed,
                };
            }
        }
    }

    # Now count total loans against the limit for the branch
    my $branch_borrower_circ_rule = GetBranchBorrowerCircRule($branch, $cat_borrower);
    if (defined($branch_borrower_circ_rule->{maxissueqty})) {
        my @bind_params = ();
        my $branch_count_query = q|
            SELECT COUNT(*) AS total, COALESCE(SUM(onsite_checkout), 0) AS onsite_checkouts
            FROM issues
            JOIN items USING (itemnumber)
            WHERE borrowernumber = ?
        |;
        push @bind_params, $borrower->{borrowernumber};

        if (C4::Context->preference('CircControl') eq 'PickupLibrary') {
            $branch_count_query .= " AND issues.branchcode = ? ";
            push @bind_params, $branch;
        } elsif (C4::Context->preference('CircControl') eq 'PatronLibrary') {
            ; # if branch is the patron's home branch, then count all loans by patron
        } else {
            $branch_count_query .= " AND items.homebranch = ? ";
            push @bind_params, $branch;
        }
        my ( $checkout_count, $onsite_checkout_count ) = $dbh->selectrow_array( $branch_count_query, {}, @bind_params );
        my $max_checkouts_allowed = $branch_borrower_circ_rule->{maxissueqty};
        my $max_onsite_checkouts_allowed = $branch_borrower_circ_rule->{maxonsiteissueqty};

        if ( $onsite_checkout ) {
            if ( $onsite_checkout_count >= $max_onsite_checkouts_allowed )  {
                return {
                    reason => 'TOO_MANY_ONSITE_CHECKOUTS',
                    count => $onsite_checkout_count,
                    max_allowed => $max_onsite_checkouts_allowed,
                }
            }
        }
        if ( C4::Context->preference('ConsiderOnSiteCheckoutsAsNormalCheckouts') ) {
            if ( $checkout_count >= $max_checkouts_allowed ) {
                return {
                    reason => 'TOO_MANY_CHECKOUTS',
                    count => $checkout_count,
                    max_allowed => $max_checkouts_allowed,
                };
            }
        } elsif ( not $onsite_checkout ) {
            if ( $checkout_count - $onsite_checkout_count >= $max_checkouts_allowed )  {
                return {
                    reason => 'TOO_MANY_CHECKOUTS',
                    count => $checkout_count - $onsite_checkout_count,
                    max_allowed => $max_checkouts_allowed,
                };
            }
        }
    }

    # OK, the patron can issue !!!
    return;
}

=head2 itemissues

  @issues = &itemissues($biblioitemnumber, $biblio);

Looks up information about who has borrowed the bookZ<>(s) with the
given biblioitemnumber.

C<$biblio> is ignored.

C<&itemissues> returns an array of references-to-hash. The keys
include the fields from the C<items> table in the Koha database.
Additional keys include:

=over 4

=item C<date_due>

If the item is currently on loan, this gives the due date.

If the item is not on loan, then this is either "Available" or
"Cancelled", if the item has been withdrawn.

=item C<card>

If the item is currently on loan, this gives the card number of the
patron who currently has the item.

=item C<timestamp0>, C<timestamp1>, C<timestamp2>

These give the timestamp for the last three times the item was
borrowed.

=item C<card0>, C<card1>, C<card2>

The card number of the last three patrons who borrowed this item.

=item C<borrower0>, C<borrower1>, C<borrower2>

The borrower number of the last three patrons who borrowed this item.

=back

=cut

#'
sub itemissues {
    my ( $bibitem, $biblio ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare("Select * from items where items.biblioitemnumber = ?")
      || die $dbh->errstr;
    my $i = 0;
    my @results;

    $sth->execute($bibitem) || die $sth->errstr;

    while ( my $data = $sth->fetchrow_hashref ) {

        # Find out who currently has this item.
        # FIXME - Wouldn't it be better to do this as a left join of
        # some sort? Currently, this code assumes that if
        # fetchrow_hashref() fails, then the book is on the shelf.
        # fetchrow_hashref() can fail for any number of reasons (e.g.,
        # database server crash), not just because no items match the
        # search criteria.
        my $sth2 = $dbh->prepare(
            "SELECT * FROM issues
                LEFT JOIN borrowers ON issues.borrowernumber = borrowers.borrowernumber
                WHERE itemnumber = ?
            "
        );

        $sth2->execute( $data->{'itemnumber'} );
        if ( my $data2 = $sth2->fetchrow_hashref ) {
            $data->{'date_due'} = $data2->{'date_due'};
            $data->{'card'}     = $data2->{'cardnumber'};
            $data->{'borrower'} = $data2->{'borrowernumber'};
        }
        else {
            $data->{'date_due'} = ($data->{'withdrawn'} eq '1') ? 'Cancelled' : 'Available';
        }


        # Find the last 3 people who borrowed this item.
        $sth2 = $dbh->prepare(
            "SELECT * FROM old_issues
                LEFT JOIN borrowers ON  issues.borrowernumber = borrowers.borrowernumber
                WHERE itemnumber = ?
                ORDER BY returndate DESC,timestamp DESC"
        );

        $sth2->execute( $data->{'itemnumber'} );
        for ( my $i2 = 0 ; $i2 < 2 ; $i2++ )
        {    # FIXME : error if there is less than 3 pple borrowing this item
            if ( my $data2 = $sth2->fetchrow_hashref ) {
                $data->{"timestamp$i2"} = $data2->{'timestamp'};
                $data->{"card$i2"}      = $data2->{'cardnumber'};
                $data->{"borrower$i2"}  = $data2->{'borrowernumber'};
            }    # if
        }    # for

        $results[$i] = $data;
        $i++;
    }

    return (@results);
}

=head2 CanBookBeIssued

  ( $issuingimpossible, $needsconfirmation ) =  CanBookBeIssued( $borrower, 
                      $barcode, $duedate, $inprocess, $ignore_reserves );

Check if a book can be issued.

C<$issuingimpossible> and C<$needsconfirmation> are some hashref.

=over 4

=item C<$borrower> hash with borrower informations (from GetMember or GetMemberDetails)

=item C<$barcode> is the bar code of the book being issued.

=item C<$duedates> is a DateTime object.

=item C<$inprocess> boolean switch

=item C<$ignore_reserves> boolean switch

=back

Returns :

=over 4

=item C<$issuingimpossible> a reference to a hash. It contains reasons why issuing is impossible.
Possible values are :

=back

=head3 INVALID_DATE 

sticky due date is invalid

=head3 GNA

borrower gone with no address

=head3 CARD_LOST

borrower declared it's card lost

=head3 DEBARRED

borrower debarred

=head3 UNKNOWN_BARCODE

barcode unknown

=head3 NOT_FOR_LOAN

item is not for loan

=head3 WTHDRAWN

item withdrawn.

=head3 RESTRICTED

item is restricted (set by ??)

C<$needsconfirmation> a reference to a hash. It contains reasons why the loan 
could be prevented, but ones that can be overriden by the operator.

Possible values are :

=head3 DEBT

borrower has debts.

=head3 RENEW_ISSUE

renewing, not issuing

=head3 ISSUED_TO_ANOTHER

issued to someone else.

=head3 RESERVED

reserved for someone else.

=head3 INVALID_DATE

sticky due date is invalid or due date in the past

=head3 TOO_MANY

if the borrower borrows to much things

=cut

sub CanBookBeIssued {
    my ( $borrower, $barcode, $duedate, $inprocess, $ignore_reserves, $params ) = @_;
    my %needsconfirmation;    # filled with problems that needs confirmations
    my %issuingimpossible;    # filled with problems that causes the issue to be IMPOSSIBLE
    my %alerts;               # filled with messages that shouldn't stop issuing, but the librarian should be aware of.

    my $onsite_checkout = $params->{onsite_checkout} || 0;

    my $item = GetItem(GetItemnumberFromBarcode( $barcode ));
    my $issue = GetItemIssue($item->{itemnumber});
	my $biblioitem = GetBiblioItemData($item->{biblioitemnumber});
	$item->{'itemtype'}=$item->{'itype'}; 
    my $dbh             = C4::Context->dbh;

    # MANDATORY CHECKS - unless item exists, nothing else matters
    unless ( $item->{barcode} ) {
        $issuingimpossible{UNKNOWN_BARCODE} = 1;
    }
	return ( \%issuingimpossible, \%needsconfirmation ) if %issuingimpossible;

    #
    # DUE DATE is OK ? -- should already have checked.
    #
    if ($duedate && ref $duedate ne 'DateTime') {
        $duedate = dt_from_string($duedate);
    }
    my $now = DateTime->now( time_zone => C4::Context->tz() );
    unless ( $duedate ) {
        my $issuedate = $now->clone();

        my $branch = _GetCircControlBranch($item,$borrower);
        my $itype = ( C4::Context->preference('item-level_itypes') ) ? $item->{'itype'} : $biblioitem->{'itemtype'};
        $duedate = CalcDateDue( $issuedate, $itype, $branch, $borrower );

        # Offline circ calls AddIssue directly, doesn't run through here
        #  So issuingimpossible should be ok.
    }
    if ($duedate) {
        my $today = $now->clone();
        $today->truncate( to => 'minute');
        if (DateTime->compare($duedate,$today) == -1 ) { # duedate cannot be before now
            $needsconfirmation{INVALID_DATE} = output_pref($duedate);
        }
    } else {
            $issuingimpossible{INVALID_DATE} = output_pref($duedate);
    }

    #
    # BORROWER STATUS
    #
    if ( $borrower->{'category_type'} eq 'X' && (  $item->{barcode}  )) { 
    	# stats only borrower -- add entry to statistics table, and return issuingimpossible{STATS} = 1  .
        &UpdateStats({
                     branch => C4::Context->userenv->{'branch'},
                     type => 'localuse',
                     itemnumber => $item->{'itemnumber'},
                     itemtype => $item->{'itemtype'},
                     borrowernumber => $borrower->{'borrowernumber'},
                     ccode => $item->{'ccode'}}
                    );
        ModDateLastSeen( $item->{'itemnumber'} );
        return( { STATS => 1 }, {});
    }
    if ( ref $borrower->{flags} ) {
        if ( $borrower->{flags}->{GNA} ) {
            $issuingimpossible{GNA} = 1;
        }
        if ( $borrower->{flags}->{'LOST'} ) {
            $issuingimpossible{CARD_LOST} = 1;
        }
        if ( $borrower->{flags}->{'DBARRED'} ) {
            $issuingimpossible{DEBARRED} = 1;
        }
    }
    if ( !defined $borrower->{dateexpiry} || $borrower->{'dateexpiry'} eq '0000-00-00') {
        $issuingimpossible{EXPIRED} = 1;
    } else {
        my $expiry_dt = dt_from_string( $borrower->{dateexpiry}, 'sql', 'floating' );
        $expiry_dt->truncate( to => 'day');
        my $today = $now->clone()->truncate(to => 'day');
        $today->set_time_zone( 'floating' );
        if ( DateTime->compare($today, $expiry_dt) == 1 ) {
            $issuingimpossible{EXPIRED} = 1;
        }
    }

    #
    # BORROWER STATUS
    #

    # DEBTS
    my ($balance, $non_issue_charges, $other_charges) =
      C4::Members::GetMemberAccountBalance( $borrower->{'borrowernumber'} );

    my $amountlimit = C4::Context->preference("noissuescharge");
    my $allowfineoverride = C4::Context->preference("AllowFineOverride");
    my $allfinesneedoverride = C4::Context->preference("AllFinesNeedOverride");

    # Check the debt of this patrons guarantees
    my $no_issues_charge_guarantees = C4::Context->preference("NoIssuesChargeGuarantees");
    $no_issues_charge_guarantees = undef unless looks_like_number( $no_issues_charge_guarantees );
    if ( defined $no_issues_charge_guarantees ) {
        my $p = Koha::Patrons->find( $borrower->{borrowernumber} );
        my @guarantees = $p->guarantees();
        my $guarantees_non_issues_charges;
        foreach my $g ( @guarantees ) {
            my ( $b, $n, $o ) = C4::Members::GetMemberAccountBalance( $g->id );
            $guarantees_non_issues_charges += $n;
        }

        if ( $guarantees_non_issues_charges > $no_issues_charge_guarantees && !$inprocess && !$allowfineoverride) {
            $issuingimpossible{DEBT_GUARANTEES} = $guarantees_non_issues_charges;
        } elsif ( $guarantees_non_issues_charges > $no_issues_charge_guarantees && !$inprocess && $allowfineoverride) {
            $needsconfirmation{DEBT_GUARANTEES} = $guarantees_non_issues_charges;
        } elsif ( $allfinesneedoverride && $guarantees_non_issues_charges > 0 && $guarantees_non_issues_charges <= $no_issues_charge_guarantees && !$inprocess ) {
            $needsconfirmation{DEBT_GUARANTEES} = $guarantees_non_issues_charges;
        }
    }

    if ( C4::Context->preference("IssuingInProcess") ) {
        if ( $non_issue_charges > $amountlimit && !$inprocess && !$allowfineoverride) {
            $issuingimpossible{DEBT} = sprintf( "%.2f", $non_issue_charges );
        } elsif ( $non_issue_charges > $amountlimit && !$inprocess && $allowfineoverride) {
            $needsconfirmation{DEBT} = sprintf( "%.2f", $non_issue_charges );
        } elsif ( $allfinesneedoverride && $non_issue_charges > 0 && $non_issue_charges <= $amountlimit && !$inprocess ) {
            $needsconfirmation{DEBT} = sprintf( "%.2f", $non_issue_charges );
        }
    }
    else {
        if ( $non_issue_charges > $amountlimit && $allowfineoverride ) {
            $needsconfirmation{DEBT} = sprintf( "%.2f", $non_issue_charges );
        } elsif ( $non_issue_charges > $amountlimit && !$allowfineoverride) {
            $issuingimpossible{DEBT} = sprintf( "%.2f", $non_issue_charges );
        } elsif ( $non_issue_charges > 0 && $allfinesneedoverride ) {
            $needsconfirmation{DEBT} = sprintf( "%.2f", $non_issue_charges );
        }
    }

    if ($balance > 0 && $other_charges > 0) {
        $alerts{OTHER_CHARGES} = sprintf( "%.2f", $other_charges );
    }

    my ($blocktype, $count) = C4::Members::IsMemberBlocked($borrower->{'borrowernumber'});
    if ($blocktype == -1) {
        ## patron has outstanding overdue loans
	    if ( C4::Context->preference("OverduesBlockCirc") eq 'block'){
	        $issuingimpossible{USERBLOCKEDOVERDUE} = $count;
	    }
	    elsif ( C4::Context->preference("OverduesBlockCirc") eq 'confirmation'){
	        $needsconfirmation{USERBLOCKEDOVERDUE} = $count;
	    }
    } elsif($blocktype == 1) {
        # patron has accrued fine days or has a restriction. $count is a date
        if ($count eq '9999-12-31') {
            $issuingimpossible{USERBLOCKEDNOENDDATE} = $count;
        }
        else {
            $issuingimpossible{USERBLOCKEDWITHENDDATE} = $count;
        }
    }

#
    # JB34 CHECKS IF BORROWERS DON'T HAVE ISSUE TOO MANY BOOKS
    #
    my $toomany = TooMany( $borrower, $item->{biblionumber}, $item, { onsite_checkout => $onsite_checkout } );
    # if TooMany max_allowed returns 0 the user doesn't have permission to check out this book
    if ( $toomany ) {
        if ( $toomany->{max_allowed} == 0 ) {
            $needsconfirmation{PATRON_CANT} = 1;
        }
        if ( C4::Context->preference("AllowTooManyOverride") ) {
            $needsconfirmation{TOO_MANY} = $toomany->{reason};
            $needsconfirmation{current_loan_count} = $toomany->{count};
            $needsconfirmation{max_loans_allowed} = $toomany->{max_allowed};
        } else {
            $needsconfirmation{TOO_MANY} = $toomany->{reason};
            $issuingimpossible{current_loan_count} = $toomany->{count};
            $issuingimpossible{max_loans_allowed} = $toomany->{max_allowed};
        }
    }

    #
    # ITEM CHECKING
    #
    if ( $item->{'notforloan'} )
    {
        if(!C4::Context->preference("AllowNotForLoanOverride")){
            $issuingimpossible{NOT_FOR_LOAN} = 1;
            $issuingimpossible{item_notforloan} = $item->{'notforloan'};
        }else{
            $needsconfirmation{NOT_FOR_LOAN_FORCING} = 1;
            $needsconfirmation{item_notforloan} = $item->{'notforloan'};
        }
    }
    else {
        # we have to check itemtypes.notforloan also
        if (C4::Context->preference('item-level_itypes')){
            # this should probably be a subroutine
            my $sth = $dbh->prepare("SELECT notforloan FROM itemtypes WHERE itemtype = ?");
            $sth->execute($item->{'itemtype'});
            my $notforloan=$sth->fetchrow_hashref();
            if ($notforloan->{'notforloan'}) {
                if (!C4::Context->preference("AllowNotForLoanOverride")) {
                    $issuingimpossible{NOT_FOR_LOAN} = 1;
                    $issuingimpossible{itemtype_notforloan} = $item->{'itype'};
                } else {
                    $needsconfirmation{NOT_FOR_LOAN_FORCING} = 1;
                    $needsconfirmation{itemtype_notforloan} = $item->{'itype'};
                }
            }
        }
        elsif ($biblioitem->{'notforloan'} == 1){
            if (!C4::Context->preference("AllowNotForLoanOverride")) {
                $issuingimpossible{NOT_FOR_LOAN} = 1;
                $issuingimpossible{itemtype_notforloan} = $biblioitem->{'itemtype'};
            } else {
                $needsconfirmation{NOT_FOR_LOAN_FORCING} = 1;
                $needsconfirmation{itemtype_notforloan} = $biblioitem->{'itemtype'};
            }
        }
    }
    if ( $item->{'withdrawn'} && $item->{'withdrawn'} > 0 )
    {
        $issuingimpossible{WTHDRAWN} = 1;
    }
    if (   $item->{'restricted'}
        && $item->{'restricted'} == 1 )
    {
        $issuingimpossible{RESTRICTED} = 1;
    }
    if ( $item->{'itemlost'} && C4::Context->preference("IssueLostItem") ne 'nothing' ) {
        my $code = GetAuthorisedValueByCode( 'LOST', $item->{'itemlost'} );
        $needsconfirmation{ITEM_LOST} = $code if ( C4::Context->preference("IssueLostItem") eq 'confirm' );
        $alerts{ITEM_LOST} = $code if ( C4::Context->preference("IssueLostItem") eq 'alert' );
    }
    if ( C4::Context->preference("IndependentBranches") ) {
        my $userenv = C4::Context->userenv;
        unless ( C4::Context->IsSuperLibrarian() ) {
            if ( $item->{C4::Context->preference("HomeOrHoldingBranch")} ne $userenv->{branch} ){
                $issuingimpossible{ITEMNOTSAMEBRANCH} = 1;
                $issuingimpossible{'itemhomebranch'} = $item->{C4::Context->preference("HomeOrHoldingBranch")};
            }
            $needsconfirmation{BORRNOTSAMEBRANCH} = GetBranchName( $borrower->{'branchcode'} )
              if ( $borrower->{'branchcode'} ne $userenv->{branch} );
        }
    }
    #
    # CHECK IF THERE IS RENTAL CHARGES. RENTAL MUST BE CONFIRMED BY THE BORROWER
    #
    my $rentalConfirmation = C4::Context->preference("RentalFeesCheckoutConfirmation");

    if ( $rentalConfirmation ){
        my ($rentalCharge) = GetIssuingCharges( $item->{'itemnumber'}, $borrower->{'borrowernumber'} );
        if ( $rentalCharge > 0 ){
            $rentalCharge = sprintf("%.02f", $rentalCharge);
            $needsconfirmation{RENTALCHARGE} = $rentalCharge;
        }
    }

    #
    # CHECK IF BOOK ALREADY ISSUED TO THIS BORROWER
    #
    if ( $issue->{borrowernumber} && $issue->{borrowernumber} eq $borrower->{'borrowernumber'} ){

        # Already issued to current borrower. Ask whether the loan should
        # be renewed.
        my ($CanBookBeRenewed,$renewerror) = CanBookBeRenewed(
            $borrower->{'borrowernumber'},
            $item->{'itemnumber'}
        );
        if ( $CanBookBeRenewed == 0 ) {    # no more renewals allowed
            if ( $renewerror eq 'onsite_checkout' ) {
                $issuingimpossible{NO_RENEWAL_FOR_ONSITE_CHECKOUTS} = 1;
            }
            else {
                $issuingimpossible{NO_MORE_RENEWALS} = 1;
            }
        }
        else {
            $needsconfirmation{RENEW_ISSUE} = 1;
        }
    }
    elsif ($issue->{borrowernumber}) {

        # issued to someone else
        my $currborinfo =    C4::Members::GetMember( borrowernumber => $issue->{borrowernumber} );

#        warn "=>.$currborinfo->{'firstname'} $currborinfo->{'surname'} ($currborinfo->{'cardnumber'})";
        $needsconfirmation{ISSUED_TO_ANOTHER} = 1;
        $needsconfirmation{issued_firstname} = $currborinfo->{'firstname'};
        $needsconfirmation{issued_surname} = $currborinfo->{'surname'};
        $needsconfirmation{issued_cardnumber} = $currborinfo->{'cardnumber'};
        $needsconfirmation{issued_borrowernumber} = $currborinfo->{'borrowernumber'};
    }

    unless ( $ignore_reserves ) {
        # See if the item is on reserve.
        my ( $restype, $res ) = C4::Reserves::CheckReserves( $item->{'itemnumber'} );
        if ($restype) {
            my $resbor = $res->{'borrowernumber'};
            if ( $resbor ne $borrower->{'borrowernumber'} ) {
                my ( $resborrower ) = C4::Members::GetMember( borrowernumber => $resbor );
                my $branchname = GetBranchName( $res->{'branchcode'} );
                if ( $restype eq "Waiting" )
                {
                    # The item is on reserve and waiting, but has been
                    # reserved by some other patron.
                    $needsconfirmation{RESERVE_WAITING} = 1;
                    $needsconfirmation{'resfirstname'} = $resborrower->{'firstname'};
                    $needsconfirmation{'ressurname'} = $resborrower->{'surname'};
                    $needsconfirmation{'rescardnumber'} = $resborrower->{'cardnumber'};
                    $needsconfirmation{'resborrowernumber'} = $resborrower->{'borrowernumber'};
                    $needsconfirmation{'resbranchname'} = $branchname;
                    $needsconfirmation{'reswaitingdate'} = $res->{'waitingdate'};
                }
                elsif ( $restype eq "Reserved" ) {
                    # The item is on reserve for someone else.
                    $needsconfirmation{RESERVED} = 1;
                    $needsconfirmation{'resfirstname'} = $resborrower->{'firstname'};
                    $needsconfirmation{'ressurname'} = $resborrower->{'surname'};
                    $needsconfirmation{'rescardnumber'} = $resborrower->{'cardnumber'};
                    $needsconfirmation{'resborrowernumber'} = $resborrower->{'borrowernumber'};
                    $needsconfirmation{'resbranchname'} = $branchname;
                    $needsconfirmation{'resreservedate'} = $res->{'reservedate'};
                }
            }
        }
    }

    ## CHECK AGE RESTRICTION
    my $agerestriction  = $biblioitem->{'agerestriction'};
    my ($restriction_age, $daysToAgeRestriction) = GetAgeRestriction( $agerestriction, $borrower );
    if ( $daysToAgeRestriction && $daysToAgeRestriction > 0 ) {
        if ( C4::Context->preference('AgeRestrictionOverride') ) {
            $needsconfirmation{AGE_RESTRICTION} = "$agerestriction";
        }
        else {
            $issuingimpossible{AGE_RESTRICTION} = "$agerestriction";
        }
    }

    ## check for high holds decreasing loan period
    if ( C4::Context->preference('decreaseLoanHighHolds') ) {
        my $check = checkHighHolds( $item, $borrower );

        if ( $check->{exceeded} ) {
            $needsconfirmation{HIGHHOLDS} = {
                num_holds  => $check->{outstanding},
                duration   => $check->{duration},
                returndate => output_pref( $check->{due_date} ),
            };
        }
    }

    if (
        !C4::Context->preference('AllowMultipleIssuesOnABiblio') &&
        # don't do the multiple loans per bib check if we've
        # already determined that we've got a loan on the same item
        !$issuingimpossible{NO_MORE_RENEWALS} &&
        !$needsconfirmation{RENEW_ISSUE}
    ) {
        # Check if borrower has already issued an item from the same biblio
        # Only if it's not a subscription
        my $biblionumber = $item->{biblionumber};
        require C4::Serials;
        my $is_a_subscription = C4::Serials::CountSubscriptionFromBiblionumber($biblionumber);
        unless ($is_a_subscription) {
            my $issues = GetIssues( {
                borrowernumber => $borrower->{borrowernumber},
                biblionumber   => $biblionumber,
            } );
            my @issues = $issues ? @$issues : ();
            # if we get here, we don't already have a loan on this item,
            # so if there are any loans on this bib, ask for confirmation
            if (scalar @issues > 0) {
                $needsconfirmation{BIBLIO_ALREADY_ISSUED} = 1;
            }
        }
    }

    return ( \%issuingimpossible, \%needsconfirmation, \%alerts );
}

=head2 CanBookBeReturned

  ($returnallowed, $message) = CanBookBeReturned($item, $branch)

Check whether the item can be returned to the provided branch

=over 4

=item C<$item> is a hash of item information as returned from GetItem

=item C<$branch> is the branchcode where the return is taking place

=back

Returns:

=over 4

=item C<$returnallowed> is 0 or 1, corresponding to whether the return is allowed (1) or not (0)

=item C<$message> is the branchcode where the item SHOULD be returned, if the return is not allowed

=back

=cut

sub CanBookBeReturned {
  my ($item, $branch) = @_;
  my $allowreturntobranch = C4::Context->preference("AllowReturnToBranch") || 'anywhere';

  # assume return is allowed to start
  my $allowed = 1;
  my $message;

  # identify all cases where return is forbidden
  if ($allowreturntobranch eq 'homebranch' && $branch ne $item->{'homebranch'}) {
     $allowed = 0;
     $message = $item->{'homebranch'};
  } elsif ($allowreturntobranch eq 'holdingbranch' && $branch ne $item->{'holdingbranch'}) {
     $allowed = 0;
     $message = $item->{'holdingbranch'};
  } elsif ($allowreturntobranch eq 'homeorholdingbranch' && $branch ne $item->{'homebranch'} && $branch ne $item->{'holdingbranch'}) {
     $allowed = 0;
     $message = $item->{'homebranch'}; # FIXME: choice of homebranch is arbitrary
  }

  return ($allowed, $message);
}

=head2 CheckHighHolds

    used when syspref decreaseLoanHighHolds is active. Returns 1 or 0 to define whether the minimum value held in
    decreaseLoanHighHoldsValue is exceeded, the total number of outstanding holds, the number of days the loan
    has been decreased to (held in syspref decreaseLoanHighHoldsValue), and the new due date

=cut

sub checkHighHolds {
    my ( $item, $borrower ) = @_;
    my $biblio = GetBiblioFromItemNumber( $item->{itemnumber} );
    my $branch = _GetCircControlBranch( $item, $borrower );

    my $return_data = {
        exceeded    => 0,
        outstanding => 0,
        duration    => 0,
        due_date    => undef,
    };

    my $holds = Koha::Holds->search( { biblionumber => $item->{'biblionumber'} } );

    if ( $holds->count() ) {
        $return_data->{outstanding} = $holds->count();

        my $decreaseLoanHighHoldsControl        = C4::Context->preference('decreaseLoanHighHoldsControl');
        my $decreaseLoanHighHoldsValue          = C4::Context->preference('decreaseLoanHighHoldsValue');
        my $decreaseLoanHighHoldsIgnoreStatuses = C4::Context->preference('decreaseLoanHighHoldsIgnoreStatuses');

        my @decreaseLoanHighHoldsIgnoreStatuses = split( /,/, $decreaseLoanHighHoldsIgnoreStatuses );

        if ( $decreaseLoanHighHoldsControl eq 'static' ) {

            # static means just more than a given number of holds on the record

            # If the number of holds is less than the threshold, we can stop here
            if ( $holds->count() < $decreaseLoanHighHoldsValue ) {
                return $return_data;
            }
        }
        elsif ( $decreaseLoanHighHoldsControl eq 'dynamic' ) {

            # dynamic means X more than the number of holdable items on the record

            # let's get the items
            my @items = $holds->next()->biblio()->items();

            # Remove any items with status defined to be ignored even if the would not make item unholdable
            foreach my $status (@decreaseLoanHighHoldsIgnoreStatuses) {
                @items = grep { !$_->$status } @items;
            }

            # Remove any items that are not holdable for this patron
            @items = grep { CanItemBeReserved( $borrower->{borrowernumber}, $_->itemnumber ) eq 'OK' } @items;

            my $items_count = scalar @items;

            my $threshold = $items_count + $decreaseLoanHighHoldsValue;

            # If the number of holds is less than the count of items we have
            # plus the number of holds allowed above that count, we can stop here
            if ( $holds->count() <= $threshold ) {
                return $return_data;
            }
        }

        my $issuedate = DateTime->now( time_zone => C4::Context->tz() );

        my $calendar = Koha::Calendar->new( branchcode => $branch );

        my $itype =
          ( C4::Context->preference('item-level_itypes') )
          ? $biblio->{'itype'}
          : $biblio->{'itemtype'};

        my $orig_due = C4::Circulation::CalcDateDue( $issuedate, $itype, $branch, $borrower );

        my $decreaseLoanHighHoldsDuration = C4::Context->preference('decreaseLoanHighHoldsDuration');

        my $reduced_datedue = $calendar->addDate( $issuedate, $decreaseLoanHighHoldsDuration );

        if ( DateTime->compare( $reduced_datedue, $orig_due ) == -1 ) {
            $return_data->{exceeded} = 1;
            $return_data->{duration} = $decreaseLoanHighHoldsDuration;
            $return_data->{due_date} = $reduced_datedue;
        }
    }

    return $return_data;
}

=head2 AddIssue

  &AddIssue($borrower, $barcode, [$datedue], [$cancelreserve], [$issuedate])

Issue a book. Does no check, they are done in CanBookBeIssued. If we reach this sub, it means the user confirmed if needed.

=over 4

=item C<$borrower> is a hash with borrower informations (from GetMember or GetMemberDetails).

=item C<$barcode> is the barcode of the item being issued.

=item C<$datedue> is a DateTime object for the max date of return, i.e. the date due (optional).
Calculated if empty.

=item C<$cancelreserve> is 1 to override and cancel any pending reserves for the item (optional).

=item C<$issuedate> is the date to issue the item in iso (YYYY-MM-DD) format (optional).
Defaults to today.  Unlike C<$datedue>, NOT a DateTime object, unfortunately.

AddIssue does the following things :

  - step 01: check that there is a borrowernumber & a barcode provided
  - check for RENEWAL (book issued & being issued to the same patron)
      - renewal YES = Calculate Charge & renew
      - renewal NO  =
          * BOOK ACTUALLY ISSUED ? do a return if book is actually issued (but to someone else)
          * RESERVE PLACED ?
              - fill reserve if reserve to this patron
              - cancel reserve or not, otherwise
          * TRANSFERT PENDING ?
              - complete the transfert
          * ISSUE THE BOOK

=back

=cut

sub AddIssue {
    my ( $borrower, $barcode, $datedue, $cancelreserve, $issuedate, $sipmode, $params ) = @_;
    my $onsite_checkout = $params && $params->{onsite_checkout} ? 1 : 0;
    my $auto_renew = $params && $params->{auto_renew};
    my $dbh = C4::Context->dbh;
    my $barcodecheck=CheckValidBarcode($barcode);

    my $issue;

    if ($datedue && ref $datedue ne 'DateTime') {
        $datedue = dt_from_string($datedue);
    }
    # $issuedate defaults to today.
    if ( ! defined $issuedate ) {
        $issuedate = DateTime->now(time_zone => C4::Context->tz());
    }
    else {
        if ( ref $issuedate ne 'DateTime') {
            $issuedate = dt_from_string($issuedate);

        }
    }
	if ($borrower and $barcode and $barcodecheck ne '0'){#??? wtf
		# find which item we issue
		my $item = GetItem('', $barcode) or return;	# if we don't get an Item, abort.
		my $branch = _GetCircControlBranch($item,$borrower);
		
		# get actual issuing if there is one
		my $actualissue = GetItemIssue( $item->{itemnumber});
		
		# get biblioinformation for this item
		my $biblio = GetBiblioFromItemNumber($item->{itemnumber});
		
		#
		# check if we just renew the issue.
		#
		if ($actualissue->{borrowernumber} eq $borrower->{'borrowernumber'}) {
		    $datedue = AddRenewal(
			$borrower->{'borrowernumber'},
			$item->{'itemnumber'},
			$branch,
			$datedue,
			$issuedate, # here interpreted as the renewal date
			);
		}
		else {
        # it's NOT a renewal
			if ( $actualissue->{borrowernumber}) {
				# This book is currently on loan, but not to the person
				# who wants to borrow it now. mark it returned before issuing to the new borrower
				AddReturn(
					$item->{'barcode'},
					C4::Context->userenv->{'branch'}
				);
			}

            MoveReserve( $item->{'itemnumber'}, $borrower->{'borrowernumber'}, $cancelreserve );
			# Starting process for transfer job (checking transfert and validate it if we have one)
            my ($datesent) = GetTransfers($item->{'itemnumber'});
            if ($datesent) {
        # 	updating line of branchtranfert to finish it, and changing the to branch value, implement a comment for visibility of this case (maybe for stats ....)
                my $sth =
                    $dbh->prepare(
                    "UPDATE branchtransfers 
                        SET datearrived = now(),
                        tobranch = ?,
                        comments = 'Forced branchtransfer'
                    WHERE itemnumber= ? AND datearrived IS NULL"
                    );
                $sth->execute(C4::Context->userenv->{'branch'},$item->{'itemnumber'});
            }

        # If automatic renewal wasn't selected while issuing, set the value according to the issuing rule.
        unless ($auto_renew) {
            my $issuingrule = GetIssuingRule($borrower->{categorycode}, $item->{itype}, $branch);
            $auto_renew = $issuingrule->{auto_renew};
        }

        # Record in the database the fact that the book was issued.
        unless ($datedue) {
            my $itype = ( C4::Context->preference('item-level_itypes') ) ? $biblio->{'itype'} : $biblio->{'itemtype'};
            $datedue = CalcDateDue( $issuedate, $itype, $branch, $borrower );

        }
        $datedue->truncate( to => 'minute');

        $issue = Koha::Database->new()->schema()->resultset('Issue')->create(
            {
                borrowernumber  => $borrower->{'borrowernumber'},
                itemnumber      => $item->{'itemnumber'},
                issuedate       => $issuedate->strftime('%Y-%m-%d %H:%M:%S'),
                date_due        => $datedue->strftime('%Y-%m-%d %H:%M:%S'),
                branchcode      => C4::Context->userenv->{'branch'},
                onsite_checkout => $onsite_checkout,
                auto_renew      => $auto_renew ? 1 : 0
            }
        );

        if ( C4::Context->preference('ReturnToShelvingCart') ) { ## ReturnToShelvingCart is on, anything issued should be taken off the cart.
          CartToShelf( $item->{'itemnumber'} );
        }
        $item->{'issues'}++;
        if ( C4::Context->preference('UpdateTotalIssuesOnCirc') ) {
            UpdateTotalIssues($item->{'biblionumber'}, 1);
        }

        ## If item was lost, it has now been found, reverse any list item charges if necessary.
        if ( $item->{'itemlost'} ) {
            if ( C4::Context->preference('RefundLostItemFeeOnReturn' ) ) {
                _FixAccountForLostAndReturned( $item->{'itemnumber'}, undef, $item->{'barcode'} );
            }
        }

        ModItem({ issues           => $item->{'issues'},
                  holdingbranch    => C4::Context->userenv->{'branch'},
                  itemlost         => 0,
                  datelastborrowed => DateTime->now(time_zone => C4::Context->tz())->ymd(),
                  onloan           => $datedue->ymd(),
                }, $item->{'biblionumber'}, $item->{'itemnumber'});
        ModDateLastSeen( $item->{'itemnumber'} );

        # If it costs to borrow this book, charge it to the patron's account.
        my ( $charge, $itemtype ) = GetIssuingCharges(
            $item->{'itemnumber'},
            $borrower->{'borrowernumber'}
        );
        if ( $charge > 0 ) {
            AddIssuingCharge(
                $item->{'itemnumber'},
                $borrower->{'borrowernumber'}, $charge
            );
            $item->{'charge'} = $charge;
        }

        # Record the fact that this book was issued.
        &UpdateStats({
                      branch => C4::Context->userenv->{'branch'},
                      type => ( $onsite_checkout ? 'onsite_checkout' : 'issue' ),
                      amount => $charge,
                      other => ($sipmode ? "SIP-$sipmode" : ''),
                      itemnumber => $item->{'itemnumber'},
                      itemtype => $item->{'itype'},
                      borrowernumber => $borrower->{'borrowernumber'},
                      ccode => $item->{'ccode'}}
        );

        # Send a checkout slip.
        my $circulation_alert = 'C4::ItemCirculationAlertPreference';
        my %conditions = (
            branchcode   => $branch,
            categorycode => $borrower->{categorycode},
            item_type    => $item->{itype},
            notification => 'CHECKOUT',
        );
        if ($circulation_alert->is_enabled_for(\%conditions)) {
            SendCirculationAlert({
                type     => 'CHECKOUT',
                item     => $item,
                borrower => $borrower,
                branch   => $branch,
            });
        }
    }

    logaction("CIRCULATION", "ISSUE", $borrower->{'borrowernumber'}, $biblio->{'itemnumber'})
        if C4::Context->preference("IssueLog");
  }
  return $issue;
}

=head2 GetLoanLength

  my $loanlength = &GetLoanLength($borrowertype,$itemtype,branchcode)

Get loan length for an itemtype, a borrower type and a branch

=cut

sub GetLoanLength {
    my ( $borrowertype, $itemtype, $branchcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(qq{
        SELECT issuelength, lengthunit, renewalperiod
        FROM issuingrules
        WHERE   categorycode=?
            AND itemtype=?
            AND branchcode=?
            AND issuelength IS NOT NULL
    });

    # try to find issuelength & return the 1st available.
    # check with borrowertype, itemtype and branchcode, then without one of those parameters
    $sth->execute( $borrowertype, $itemtype, $branchcode );
    my $loanlength = $sth->fetchrow_hashref;

    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    $sth->execute( $borrowertype, '*', $branchcode );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    $sth->execute( '*', $itemtype, $branchcode );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    $sth->execute( '*', '*', $branchcode );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    $sth->execute( $borrowertype, $itemtype, '*' );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    $sth->execute( $borrowertype, '*', '*' );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    $sth->execute( '*', $itemtype, '*' );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    $sth->execute( '*', '*', '*' );
    $loanlength = $sth->fetchrow_hashref;
    return $loanlength
      if defined($loanlength) && defined $loanlength->{issuelength};

    # if no rule is set => 0 day (hardcoded)
    return {
        issuelength => 0,
        renewalperiod => 0,
        lengthunit => 'days',
    };

}


=head2 GetHardDueDate

  my ($hardduedate,$hardduedatecompare) = &GetHardDueDate($borrowertype,$itemtype,branchcode)

Get the Hard Due Date and it's comparison for an itemtype, a borrower type and a branch

=cut

sub GetHardDueDate {
    my ( $borrowertype, $itemtype, $branchcode ) = @_;

    my $rule = GetIssuingRule( $borrowertype, $itemtype, $branchcode );

    if ( defined( $rule ) ) {
        if ( $rule->{hardduedate} ) {
            return (dt_from_string($rule->{hardduedate}, 'iso'),$rule->{hardduedatecompare});
        } else {
            return (undef, undef);
        }
    }
}

=head2 GetIssuingRule

  my $irule = &GetIssuingRule($borrowertype,$itemtype,branchcode)

FIXME - This is a copy-paste of GetLoanLength
as a stop-gap.  Do not wish to change API for GetLoanLength 
this close to release.

Get the issuing rule for an itemtype, a borrower type and a branch
Returns a hashref from the issuingrules table.

=cut

sub GetIssuingRule {
    my ( $borrowertype, $itemtype, $branchcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =  $dbh->prepare( "select * from issuingrules where categorycode=? and itemtype=? and branchcode=?"  );
    my $irule;

    $sth->execute( $borrowertype, $itemtype, $branchcode );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    $sth->execute( $borrowertype, "*", $branchcode );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    $sth->execute( "*", $itemtype, $branchcode );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    $sth->execute( "*", "*", $branchcode );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    $sth->execute( $borrowertype, $itemtype, "*" );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    $sth->execute( $borrowertype, "*", "*" );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    $sth->execute( "*", $itemtype, "*" );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    $sth->execute( "*", "*", "*" );
    $irule = $sth->fetchrow_hashref;
    return $irule if defined($irule) ;

    # if no rule matches,
    return;
}

=head2 GetBranchBorrowerCircRule

  my $branch_cat_rule = GetBranchBorrowerCircRule($branchcode, $categorycode);

Retrieves circulation rule attributes that apply to the given
branch and patron category, regardless of item type.  
The return value is a hashref containing the following key:

maxissueqty - maximum number of loans that a
patron of the given category can have at the given
branch.  If the value is undef, no limit.

maxonsiteissueqty - maximum of on-site checkouts that a
patron of the given category can have at the given
branch.  If the value is undef, no limit.

This will first check for a specific branch and
category match from branch_borrower_circ_rules. 

If no rule is found, it will then check default_branch_circ_rules
(same branch, default category).  If no rule is found,
it will then check default_borrower_circ_rules (default 
branch, same category), then failing that, default_circ_rules
(default branch, default category).

If no rule has been found in the database, it will default to
the buillt in rule:

maxissueqty - undef
maxonsiteissueqty - undef

C<$branchcode> and C<$categorycode> should contain the
literal branch code and patron category code, respectively - no
wildcards.

=cut

sub GetBranchBorrowerCircRule {
    my ( $branchcode, $categorycode ) = @_;

    my $rules;
    my $dbh = C4::Context->dbh();
    $rules = $dbh->selectrow_hashref( q|
        SELECT maxissueqty, maxonsiteissueqty
        FROM branch_borrower_circ_rules
        WHERE branchcode = ?
        AND   categorycode = ?
    |, {}, $branchcode, $categorycode ) ;
    return $rules if $rules;

    # try same branch, default borrower category
    $rules = $dbh->selectrow_hashref( q|
        SELECT maxissueqty, maxonsiteissueqty
        FROM default_branch_circ_rules
        WHERE branchcode = ?
    |, {}, $branchcode ) ;
    return $rules if $rules;

    # try default branch, same borrower category
    $rules = $dbh->selectrow_hashref( q|
        SELECT maxissueqty, maxonsiteissueqty
        FROM default_borrower_circ_rules
        WHERE categorycode = ?
    |, {}, $categorycode ) ;
    return $rules if $rules;

    # try default branch, default borrower category
    $rules = $dbh->selectrow_hashref( q|
        SELECT maxissueqty, maxonsiteissueqty
        FROM default_circ_rules
    |, {} );
    return $rules if $rules;

    # built-in default circulation rule
    return {
        maxissueqty => undef,
        maxonsiteissueqty => undef,
    };
}

=head2 GetBranchItemRule

  my $branch_item_rule = GetBranchItemRule($branchcode, $itemtype);

Retrieves circulation rule attributes that apply to the given
branch and item type, regardless of patron category.

The return value is a hashref containing the following keys:

holdallowed => Hold policy for this branch and itemtype. Possible values:
  0: No holds allowed.
  1: Holds allowed only by patrons that have the same homebranch as the item.
  2: Holds allowed from any patron.

returnbranch => branch to which to return item.  Possible values:
  noreturn: do not return, let item remain where checked in (floating collections)
  homebranch: return to item's home branch
  holdingbranch: return to issuer branch

This searches branchitemrules in the following order:

  * Same branchcode and itemtype
  * Same branchcode, itemtype '*'
  * branchcode '*', same itemtype
  * branchcode and itemtype '*'

Neither C<$branchcode> nor C<$itemtype> should be '*'.

=cut

sub GetBranchItemRule {
    my ( $branchcode, $itemtype ) = @_;
    my $dbh = C4::Context->dbh();
    my $result = {};

    my @attempts = (
        ['SELECT holdallowed, returnbranch, hold_fulfillment_policy
            FROM branch_item_rules
            WHERE branchcode = ?
              AND itemtype = ?', $branchcode, $itemtype],
        ['SELECT holdallowed, returnbranch, hold_fulfillment_policy
            FROM default_branch_circ_rules
            WHERE branchcode = ?', $branchcode],
        ['SELECT holdallowed, returnbranch, hold_fulfillment_policy
            FROM default_branch_item_rules
            WHERE itemtype = ?', $itemtype],
        ['SELECT holdallowed, returnbranch, hold_fulfillment_policy
            FROM default_circ_rules'],
    );

    foreach my $attempt (@attempts) {
        my ($query, @bind_params) = @{$attempt};
        my $search_result = $dbh->selectrow_hashref ( $query , {}, @bind_params )
          or next;

        # Since branch/category and branch/itemtype use the same per-branch
        # defaults tables, we have to check that the key we want is set, not
        # just that a row was returned
        $result->{'holdallowed'}  = $search_result->{'holdallowed'}  unless ( defined $result->{'holdallowed'} );
        $result->{'hold_fulfillment_policy'} = $search_result->{'hold_fulfillment_policy'} unless ( defined $result->{'hold_fulfillment_policy'} );
        $result->{'returnbranch'} = $search_result->{'returnbranch'} unless ( defined $result->{'returnbranch'} );
    }
    
    # built-in default circulation rule
    $result->{'holdallowed'} = 2 unless ( defined $result->{'holdallowed'} );
    $result->{'hold_fulfillment_policy'} = 'any' unless ( defined $result->{'hold_fulfillment_policy'} );
    $result->{'returnbranch'} = 'homebranch' unless ( defined $result->{'returnbranch'} );

    return $result;
}

=head2 AddReturn

  ($doreturn, $messages, $iteminformation, $borrower) =
      &AddReturn( $barcode, $branch [,$exemptfine] [,$dropbox] [,$returndate] );

Returns a book.

=over 4

=item C<$barcode> is the bar code of the book being returned.

=item C<$branch> is the code of the branch where the book is being returned.

=item C<$exemptfine> indicates that overdue charges for the item will be
removed. Optional.

=item C<$dropbox> indicates that the check-in date is assumed to be
yesterday, or the last non-holiday as defined in C4::Calendar .  If
overdue charges are applied and C<$dropbox> is true, the last charge
will be removed.  This assumes that the fines accrual script has run
for _today_. Optional.

=item C<$return_date> allows the default return date to be overridden
by the given return date. Optional.

=back

C<&AddReturn> returns a list of four items:

C<$doreturn> is true iff the return succeeded.

C<$messages> is a reference-to-hash giving feedback on the operation.
The keys of the hash are:

=over 4

=item C<BadBarcode>

No item with this barcode exists. The value is C<$barcode>.

=item C<NotIssued>

The book is not currently on loan. The value is C<$barcode>.

=item C<IsPermanent>

The book's home branch is a permanent collection. If you have borrowed
this book, you are not allowed to return it. The value is the code for
the book's home branch.

=item C<withdrawn>

This book has been withdrawn/cancelled. The value should be ignored.

=item C<Wrongbranch>

This book has was returned to the wrong branch.  The value is a hashref
so that C<$messages->{Wrongbranch}->{Wrongbranch}> and C<$messages->{Wrongbranch}->{Rightbranch}>
contain the branchcode of the incorrect and correct return library, respectively.

=item C<ResFound>

The item was reserved. The value is a reference-to-hash whose keys are
fields from the reserves table of the Koha database, and
C<biblioitemnumber>. It also has the key C<ResFound>, whose value is
either C<Waiting>, C<Reserved>, or 0.

=item C<WasReturned>

Value 1 if return is successful.

=item C<NeedsTransfer>

If AutomaticItemReturn is disabled, return branch is given as value of NeedsTransfer.

=back

C<$iteminformation> is a reference-to-hash, giving information about the
returned item from the issues table.

C<$borrower> is a reference-to-hash, giving information about the
patron who last borrowed the book.

=cut

sub AddReturn {
    my ( $barcode, $branch, $exemptfine, $dropbox, $return_date, $dropboxdate ) = @_;

    if ($branch and not Koha::Libraries->find($branch)) {
        warn "AddReturn error: branch '$branch' not found.  Reverting to " . C4::Context->userenv->{'branch'};
        undef $branch;
    }
    $branch = C4::Context->userenv->{'branch'} unless $branch;  # we trust userenv to be a safe fallback/default
    my $messages;
    my $borrower;
    my $biblio;
    my $doreturn       = 1;
    my $validTransfert = 0;
    my $stat_type = 'return';

    # get information on item
    my $itemnumber = GetItemnumberFromBarcode( $barcode );
    unless ($itemnumber) {
        return (0, { BadBarcode => $barcode }); # no barcode means no item or borrower.  bail out.
    }
    my $issue  = GetItemIssue($itemnumber);
    if ($issue and $issue->{borrowernumber}) {
        $borrower = C4::Members::GetMemberDetails($issue->{borrowernumber})
            or die "Data inconsistency: barcode $barcode (itemnumber:$itemnumber) claims to be issued to non-existent borrowernumber '$issue->{borrowernumber}'\n"
                . Dumper($issue) . "\n";
    } else {
        $messages->{'NotIssued'} = $barcode;
        # even though item is not on loan, it may still be transferred;  therefore, get current branch info
        $doreturn = 0;
        # No issue, no borrowernumber.  ONLY if $doreturn, *might* you have a $borrower later.
        # Record this as a local use, instead of a return, if the RecordLocalUseOnReturn is on
        if (C4::Context->preference("RecordLocalUseOnReturn")) {
           $messages->{'LocalUse'} = 1;
           $stat_type = 'localuse';
        }
    }

    my $item = GetItem($itemnumber) or die "GetItem($itemnumber) failed";

    if ( $item->{'location'} eq 'PROC' ) {
        if ( C4::Context->preference("InProcessingToShelvingCart") ) {
            $item->{'location'} = 'CART';
        }
        else {
            $item->{location} = $item->{permanent_location};
        }

        ModItem( $item, $item->{'biblionumber'}, $item->{'itemnumber'} );
    }

        # full item data, but no borrowernumber or checkout info (no issue)
        # we know GetItem should work because GetItemnumberFromBarcode worked
    my $hbr = GetBranchItemRule($item->{'homebranch'}, $item->{'itype'})->{'returnbranch'} || "homebranch";
        # get the proper branch to which to return the item
    my $returnbranch = $item->{$hbr} || $branch ;
        # if $hbr was "noreturn" or any other non-item table value, then it should 'float' (i.e. stay at this branch)

    my $borrowernumber = $borrower->{'borrowernumber'} || undef;    # we don't know if we had a borrower or not

    my $yaml = C4::Context->preference('UpdateNotForLoanStatusOnCheckin');
    if ($yaml) {
        $yaml = "$yaml\n\n";  # YAML is anal on ending \n. Surplus does not hurt
        my $rules;
        eval { $rules = YAML::Load($yaml); };
        if ($@) {
            warn "Unable to parse UpdateNotForLoanStatusOnCheckin syspref : $@";
        }
        else {
            foreach my $key ( keys %$rules ) {
                if ( $item->{notforloan} eq $key ) {
                    $messages->{'NotForLoanStatusUpdated'} = { from => $item->{notforloan}, to => $rules->{$key} };
                    ModItem( { notforloan => $rules->{$key} }, undef, $itemnumber );
                    last;
                }
            }
        }
    }


    # check if the book is in a permanent collection....
    # FIXME -- This 'PE' attribute is largely undocumented.  afaict, there's no user interface that reflects this functionality.
    if ( $returnbranch ) {
        my $branches = GetBranches();    # a potentially expensive call for a non-feature.
        $branches->{$returnbranch}->{PE} and $messages->{'IsPermanent'} = $returnbranch;
    }

    # check if the return is allowed at this branch
    my ($returnallowed, $message) = CanBookBeReturned($item, $branch);
    unless ($returnallowed){
        $messages->{'Wrongbranch'} = {
            Wrongbranch => $branch,
            Rightbranch => $message
        };
        $doreturn = 0;
        return ( $doreturn, $messages, $issue, $borrower );
    }

    if ( $item->{'withdrawn'} ) { # book has been cancelled
        $messages->{'withdrawn'} = 1;
        $doreturn = 0 if C4::Context->preference("BlockReturnOfWithdrawnItems");
    }

    # case of a return of document (deal with issues and holdingbranch)
    my $today = DateTime->now( time_zone => C4::Context->tz() );

    if ($doreturn) {
        my $datedue = $issue->{date_due};
        $borrower or warn "AddReturn without current borrower";
		my $circControlBranch;
        if ($dropbox) {
            # define circControlBranch only if dropbox mode is set
            # don't allow dropbox mode to create an invalid entry in issues (issuedate > today)
            # FIXME: check issuedate > returndate, factoring in holidays

            $circControlBranch = _GetCircControlBranch($item,$borrower);
            $issue->{'overdue'} = DateTime->compare($issue->{'date_due'}, $dropboxdate ) == -1 ? 1 : 0;
        }

        if ($borrowernumber) {
            if ( ( C4::Context->preference('CalculateFinesOnReturn') && $issue->{'overdue'} ) || $return_date ) {
                # we only need to calculate and change the fines if we want to do that on return
                # Should be on for hourly loans
                my $control = C4::Context->preference('CircControl');
                my $control_branchcode =
                    ( $control eq 'ItemHomeLibrary' ) ? $item->{homebranch}
                  : ( $control eq 'PatronLibrary' )   ? $borrower->{branchcode}
                  :                                     $issue->{branchcode};

                my $date_returned =
                  $return_date ? dt_from_string($return_date) : $today;

                my ( $amount, $type, $unitcounttotal ) =
                  C4::Overdues::CalcFine( $item, $borrower->{categorycode},
                    $control_branchcode, $datedue, $date_returned );

                $type ||= q{};

                if ( C4::Context->preference('finesMode') eq 'production' ) {
                    if ( $amount > 0 ) {
                        C4::Overdues::UpdateFine(
                            {
                                issue_id       => $issue->{issue_id},
                                itemnumber     => $issue->{itemnumber},
                                borrowernumber => $issue->{borrowernumber},
                                amount         => $amount,
                                type           => $type,
                                due            => output_pref($datedue),
                            }
                        );
                    }
                    elsif ($return_date) {

                        # Backdated returns may have fines that shouldn't exist,
                        # so in this case, we need to drop those fines to 0

                        C4::Overdues::UpdateFine(
                            {
                                issue_id       => $issue->{issue_id},
                                itemnumber     => $issue->{itemnumber},
                                borrowernumber => $issue->{borrowernumber},
                                amount         => 0,
                                type           => $type,
                                due            => output_pref($datedue),
                            }
                        );
                    }
                }
            }

            eval {
                MarkIssueReturned( $borrowernumber, $item->{'itemnumber'},
                    $circControlBranch, $return_date, $borrower->{'privacy'} );
            };
            if ( $@ ) {
                $messages->{'Wrongbranch'} = {
                    Wrongbranch => $branch,
                    Rightbranch => $message
                };
                carp $@;
                return ( 0, { WasReturned => 0 }, $issue, $borrower );
            }

            # FIXME is the "= 1" right?  This could be the borrower hash.
            $messages->{'WasReturned'} = 1;

        }

        ModItem({ onloan => undef }, $issue->{'biblionumber'}, $item->{'itemnumber'});
    }

    # the holdingbranch is updated if the document is returned to another location.
    # this is always done regardless of whether the item was on loan or not
    if ($item->{'holdingbranch'} ne $branch) {
        UpdateHoldingbranch($branch, $item->{'itemnumber'});
        $item->{'holdingbranch'} = $branch; # update item data holdingbranch too
    }
    ModDateLastSeen( $item->{'itemnumber'} );

    # check if we have a transfer for this document
    my ($datesent,$frombranch,$tobranch) = GetTransfers( $item->{'itemnumber'} );

    # if we have a transfer to do, we update the line of transfers with the datearrived
    my $is_in_rotating_collection = C4::RotatingCollections::isItemInAnyCollection( $item->{'itemnumber'} );
    if ($datesent) {
        if ( $tobranch eq $branch ) {
            my $sth = C4::Context->dbh->prepare(
                "UPDATE branchtransfers SET datearrived = now() WHERE itemnumber= ? AND datearrived IS NULL"
            );
            $sth->execute( $item->{'itemnumber'} );
            # if we have a reservation with valid transfer, we can set it's status to 'W'
            ShelfToCart( $item->{'itemnumber'} ) if ( C4::Context->preference("ReturnToShelvingCart") );
            C4::Reserves::ModReserveStatus($item->{'itemnumber'}, 'W');
        } else {
            $messages->{'WrongTransfer'}     = $tobranch;
            $messages->{'WrongTransferItem'} = $item->{'itemnumber'};
        }
        $validTransfert = 1;
    } else {
        ShelfToCart( $item->{'itemnumber'} ) if ( C4::Context->preference("ReturnToShelvingCart") );
    }

    # fix up the accounts.....
    if ( $item->{'itemlost'} ) {
        $messages->{'WasLost'} = 1;

        if ( C4::Context->preference('RefundLostItemFeeOnReturn' ) ) {
            _FixAccountForLostAndReturned($item->{'itemnumber'}, $borrowernumber, $barcode);    # can tolerate undef $borrowernumber
            $messages->{'LostItemFeeRefunded'} = 1;
        }
    }

    # fix up the overdues in accounts...
    if ($borrowernumber) {
        my $fix = _FixOverduesOnReturn($borrowernumber, $item->{itemnumber}, $exemptfine, $dropbox);
        defined($fix) or warn "_FixOverduesOnReturn($borrowernumber, $item->{itemnumber}...) failed!";  # zero is OK, check defined
        
        if ( $issue->{overdue} && $issue->{date_due} ) {
        # fix fine days
            $today = $dropboxdate if $dropbox;
            my ($debardate,$reminder) = _debar_user_on_return( $borrower, $item, $issue->{date_due}, $today );
            if ($reminder){
                $messages->{'PrevDebarred'} = $debardate;
            } else {
                $messages->{'Debarred'} = $debardate if $debardate;
            }
        # there's no overdue on the item but borrower had been previously debarred
        } elsif ( $issue->{date_due} and $borrower->{'debarred'} ) {
             if ( $borrower->{debarred} eq "9999-12-31") {
                $messages->{'ForeverDebarred'} = $borrower->{'debarred'};
             } else {
                  my $borrower_debar_dt = dt_from_string( $borrower->{debarred} );
                  $borrower_debar_dt->truncate(to => 'day');
                  my $today_dt = $today->clone()->truncate(to => 'day');
                  if ( DateTime->compare( $borrower_debar_dt, $today_dt ) != -1 ) {
                      $messages->{'PrevDebarred'} = $borrower->{'debarred'};
                  }
             }
        }
    }

    # find reserves.....
    # if we don't have a reserve with the status W, we launch the Checkreserves routine
    my ($resfound, $resrec);
    my $lookahead= C4::Context->preference('ConfirmFutureHolds'); #number of days to look for future holds
    ($resfound, $resrec, undef) = C4::Reserves::CheckReserves( $item->{'itemnumber'}, undef, $lookahead ) unless ( $item->{'withdrawn'} );
    if ($resfound) {
          $resrec->{'ResFound'} = $resfound;
        $messages->{'ResFound'} = $resrec;
    }

    # Record the fact that this book was returned.
    # FIXME itemtype should record item level type, not bibliolevel type
    UpdateStats({
                branch => $branch,
                type => $stat_type,
                itemnumber => $item->{'itemnumber'},
                itemtype => $biblio->{'itemtype'},
                borrowernumber => $borrowernumber,
                ccode => $item->{'ccode'}}
    );

    # Send a check-in slip. # NOTE: borrower may be undef.  probably shouldn't try to send messages then.
    my $circulation_alert = 'C4::ItemCirculationAlertPreference';
    my %conditions = (
        branchcode   => $branch,
        categorycode => $borrower->{categorycode},
        item_type    => $item->{itype},
        notification => 'CHECKIN',
    );
    if ($doreturn && $circulation_alert->is_enabled_for(\%conditions)) {
        SendCirculationAlert({
            type     => 'CHECKIN',
            item     => $item,
            borrower => $borrower,
            branch   => $branch,
        });
    }
    
    logaction("CIRCULATION", "RETURN", $borrowernumber, $item->{'itemnumber'})
        if C4::Context->preference("ReturnLog");
    
    # Remove any OVERDUES related debarment if the borrower has no overdues
    if ( $borrowernumber
      && $borrower->{'debarred'}
      && C4::Context->preference('AutoRemoveOverduesRestrictions')
      && !C4::Members::HasOverdues( $borrowernumber )
      && @{ GetDebarments({ borrowernumber => $borrowernumber, type => 'OVERDUES' }) }
    ) {
        DelUniqueDebarment({ borrowernumber => $borrowernumber, type => 'OVERDUES' });
    }

    # Transfer to returnbranch if Automatic transfer set or append message NeedsTransfer
    if (!$is_in_rotating_collection && ($doreturn or $messages->{'NotIssued'}) and !$resfound and ($branch ne $returnbranch) and not $messages->{'WrongTransfer'}){
        if  (C4::Context->preference("AutomaticItemReturn"    ) or
            (C4::Context->preference("UseBranchTransferLimits") and
             ! IsBranchTransferAllowed($branch, $returnbranch, $item->{C4::Context->preference("BranchTransferLimitsType")} )
           )) {
            $debug and warn sprintf "about to call ModItemTransfer(%s, %s, %s)", $item->{'itemnumber'},$branch, $returnbranch;
            $debug and warn "item: " . Dumper($item);
            ModItemTransfer($item->{'itemnumber'}, $branch, $returnbranch);
            $messages->{'WasTransfered'} = 1;
        } else {
            $messages->{'NeedsTransfer'} = $returnbranch;
        }
    }

    return ( $doreturn, $messages, $issue, $borrower );
}

=head2 MarkIssueReturned

  MarkIssueReturned($borrowernumber, $itemnumber, $dropbox_branch, $returndate, $privacy);

Unconditionally marks an issue as being returned by
moving the C<issues> row to C<old_issues> and
setting C<returndate> to the current date, or
the last non-holiday date of the branccode specified in
C<dropbox_branch> .  Assumes you've already checked that 
it's safe to do this, i.e. last non-holiday > issuedate.

if C<$returndate> is specified (in iso format), it is used as the date
of the return. It is ignored when a dropbox_branch is passed in.

C<$privacy> contains the privacy parameter. If the patron has set privacy to 2,
the old_issue is immediately anonymised

Ideally, this function would be internal to C<C4::Circulation>,
not exported, but it is currently needed by one 
routine in C<C4::Accounts>.

=cut

sub MarkIssueReturned {
    my ( $borrowernumber, $itemnumber, $dropbox_branch, $returndate, $privacy ) = @_;

    my $anonymouspatron;
    if ( $privacy == 2 ) {
        # The default of 0 will not work due to foreign key constraints
        # The anonymisation will fail if AnonymousPatron is not a valid entry
        # We need to check if the anonymous patron exist, Koha will fail loudly if it does not
        # Note that a warning should appear on the about page (System information tab).
        $anonymouspatron = C4::Context->preference('AnonymousPatron');
        die "Fatal error: the patron ($borrowernumber) has requested their circulation history be anonymized on check-in, but the AnonymousPatron system preference is empty or not set correctly."
            unless C4::Members::GetMember( borrowernumber => $anonymouspatron );
    }
    my $dbh   = C4::Context->dbh;
    my $query = 'UPDATE issues SET returndate=';
    my @bind;
    if ($dropbox_branch) {
        my $calendar = Koha::Calendar->new( branchcode => $dropbox_branch );
        my $dropboxdate = $calendar->addDate( DateTime->now( time_zone => C4::Context->tz), -1 );
        $query .= ' ? ';
        push @bind, $dropboxdate->strftime('%Y-%m-%d %H:%M');
    } elsif ($returndate) {
        $query .= ' ? ';
        push @bind, $returndate;
    } else {
        $query .= ' now() ';
    }
    $query .= ' WHERE  borrowernumber = ?  AND itemnumber = ?';
    push @bind, $borrowernumber, $itemnumber;
    # FIXME transaction
    my $sth_upd  = $dbh->prepare($query);
    $sth_upd->execute(@bind);
    my $sth_copy = $dbh->prepare('INSERT INTO old_issues SELECT * FROM issues
                                  WHERE borrowernumber = ?
                                  AND itemnumber = ?');
    $sth_copy->execute($borrowernumber, $itemnumber);
    # anonymise patron checkout immediately if $privacy set to 2 and AnonymousPatron is set to a valid borrowernumber
    if ( $privacy == 2) {
        my $sth_ano = $dbh->prepare("UPDATE old_issues SET borrowernumber=?
                                  WHERE borrowernumber = ?
                                  AND itemnumber = ?");
       $sth_ano->execute($anonymouspatron, $borrowernumber, $itemnumber);
    }
    my $sth_del  = $dbh->prepare("DELETE FROM issues
                                  WHERE borrowernumber = ?
                                  AND itemnumber = ?");
    $sth_del->execute($borrowernumber, $itemnumber);

    ModItem( { 'onloan' => undef }, undef, $itemnumber );

    if ( C4::Context->preference('StoreLastBorrower') ) {
        my $item = Koha::Items->find( $itemnumber );
        my $patron = Koha::Patrons->find( $borrowernumber );
        $item->last_returned_by( $patron );
    }
}

=head2 _debar_user_on_return

    _debar_user_on_return($borrower, $item, $datedue, today);

C<$borrower> borrower hashref

C<$item> item hashref

C<$datedue> date due DateTime object

C<$today> DateTime object representing the return time

Internal function, called only by AddReturn that calculates and updates
 the user fine days, and debars him if necessary.

Should only be called for overdue returns

=cut

sub _debar_user_on_return {
    my ( $borrower, $item, $dt_due, $dt_today ) = @_;

    my $branchcode = _GetCircControlBranch( $item, $borrower );

    my $circcontrol = C4::Context->preference('CircControl');
    my $issuingrule =
      GetIssuingRule( $borrower->{categorycode}, $item->{itype}, $branchcode );
    my $finedays = $issuingrule->{finedays};
    my $unit     = $issuingrule->{lengthunit};
    my $chargeable_units = C4::Overdues::get_chargeable_units($unit, $dt_due, $dt_today, $branchcode);

    if ($finedays) {

        # finedays is in days, so hourly loans must multiply by 24
        # thus 1 hour late equals 1 day suspension * finedays rate
        $finedays = $finedays * 24 if ( $unit eq 'hours' );

        # grace period is measured in the same units as the loan
        my $grace =
          DateTime::Duration->new( $unit => $issuingrule->{firstremind} );

        my $deltadays = DateTime::Duration->new(
            days => $chargeable_units
        );
        if ( $deltadays->subtract($grace)->is_positive() ) {
            my $suspension_days = $deltadays * $finedays;

            # If the max suspension days is < than the suspension days
            # the suspension days is limited to this maximum period.
            my $max_sd = $issuingrule->{maxsuspensiondays};
            if ( defined $max_sd ) {
                $max_sd = DateTime::Duration->new( days => $max_sd );
                $suspension_days = $max_sd
                  if DateTime::Duration->compare( $max_sd, $suspension_days ) < 0;
            }

            my $new_debar_dt =
              $dt_today->clone()->add_duration( $suspension_days );

            Koha::Patron::Debarments::AddUniqueDebarment({
                borrowernumber => $borrower->{borrowernumber},
                expiration     => $new_debar_dt->ymd(),
                type           => 'SUSPENSION',
            });
            # if borrower was already debarred but does not get an extra debarment
            if ( $borrower->{debarred} eq Koha::Patron::Debarments::IsDebarred($borrower->{borrowernumber}) ) {
                    return ($borrower->{debarred},1);
            }
            return $new_debar_dt->ymd();
        }
    }
    return;
}

=head2 _FixOverduesOnReturn

   &_FixOverduesOnReturn($brn,$itm, $exemptfine, $dropboxmode);

C<$brn> borrowernumber

C<$itm> itemnumber

C<$exemptfine> BOOL -- remove overdue charge associated with this issue. 
C<$dropboxmode> BOOL -- remove lastincrement on overdue charge associated with this issue.

Internal function, called only by AddReturn

=cut

sub _FixOverduesOnReturn {
    my ($borrowernumber, $item);
    unless ($borrowernumber = shift) {
        warn "_FixOverduesOnReturn() not supplied valid borrowernumber";
        return;
    }
    unless ($item = shift) {
        warn "_FixOverduesOnReturn() not supplied valid itemnumber";
        return;
    }
    my ($exemptfine, $dropbox) = @_;
    my $dbh = C4::Context->dbh;

    # check for overdue fine
    my $sth = $dbh->prepare(
"SELECT * FROM accountlines WHERE (borrowernumber = ?) AND (itemnumber = ?) AND (accounttype='FU' OR accounttype='O')"
    );
    $sth->execute( $borrowernumber, $item );

    # alter fine to show that the book has been returned
    my $data = $sth->fetchrow_hashref;
    return 0 unless $data;    # no warning, there's just nothing to fix

    my $uquery;
    my @bind = ($data->{'accountlines_id'});
    if ($exemptfine) {
        $uquery = "update accountlines set accounttype='FFOR', amountoutstanding=0";
        if (C4::Context->preference("FinesLog")) {
            &logaction("FINES", 'MODIFY',$borrowernumber,"Overdue forgiven: item $item");
        }
    } elsif ($dropbox && $data->{lastincrement}) {
        my $outstanding = $data->{amountoutstanding} - $data->{lastincrement} ;
        my $amt = $data->{amount} - $data->{lastincrement} ;
        if (C4::Context->preference("FinesLog")) {
            &logaction("FINES", 'MODIFY',$borrowernumber,"Dropbox adjustment $amt, item $item");
        }
         $uquery = "update accountlines set accounttype='F' ";
         if($outstanding  >= 0 && $amt >=0) {
            $uquery .= ", amount = ? , amountoutstanding=? ";
            unshift @bind, ($amt, $outstanding) ;
        }
    } else {
        $uquery = "update accountlines set accounttype='F' ";
    }
    $uquery .= " where (accountlines_id = ?)";
    my $usth = $dbh->prepare($uquery);
    return $usth->execute(@bind);
}

=head2 _FixAccountForLostAndReturned

  &_FixAccountForLostAndReturned($itemnumber, [$borrowernumber, $barcode]);

Calculates the charge for a book lost and returned.

Internal function, not exported, called only by AddReturn.

FIXME: This function reflects how inscrutable fines logic is.  Fix both.
FIXME: Give a positive return value on success.  It might be the $borrowernumber who received credit, or the amount forgiven.

=cut

sub _FixAccountForLostAndReturned {
    my $itemnumber     = shift or return;
    my $borrowernumber = @_ ? shift : undef;
    my $item_id        = @_ ? shift : $itemnumber;  # Send the barcode if you want that logged in the description
    my $dbh = C4::Context->dbh;
    # check for charge made for lost book
    my $sth = $dbh->prepare("SELECT * FROM accountlines WHERE itemnumber = ? AND accounttype IN ('L', 'Rep', 'W') ORDER BY date DESC, accountno DESC");
    $sth->execute($itemnumber);
    my $data = $sth->fetchrow_hashref;
    $data or return;    # bail if there is nothing to do
    $data->{accounttype} eq 'W' and return;    # Written off

    # writeoff this amount
    my $offset;
    my $amount = $data->{'amount'};
    my $acctno = $data->{'accountno'};
    my $amountleft;                                             # Starts off undef/zero.
    if ($data->{'amountoutstanding'} == $amount) {
        $offset     = $data->{'amount'};
        $amountleft = 0;                                        # Hey, it's zero here, too.
    } else {
        $offset     = $amount - $data->{'amountoutstanding'};   # Um, isn't this the same as ZERO?  We just tested those two things are ==
        $amountleft = $data->{'amountoutstanding'} - $amount;   # Um, isn't this the same as ZERO?  We just tested those two things are ==
    }
    my $usth = $dbh->prepare("UPDATE accountlines SET accounttype = 'LR',amountoutstanding='0'
        WHERE (accountlines_id = ?)");
    $usth->execute($data->{'accountlines_id'});      # We might be adjusting an account for some OTHER borrowernumber now.  Not the one we passed in.
    #check if any credit is left if so writeoff other accounts
    my $nextaccntno = getnextacctno($data->{'borrowernumber'});
    $amountleft *= -1 if ($amountleft < 0);
    if ($amountleft > 0) {
        my $msth = $dbh->prepare("SELECT * FROM accountlines WHERE (borrowernumber = ?)
                            AND (amountoutstanding >0) ORDER BY date");     # might want to order by amountoustanding ASC (pay smallest first)
        $msth->execute($data->{'borrowernumber'});
        # offset transactions
        my $newamtos;
        my $accdata;
        while (($accdata=$msth->fetchrow_hashref) and ($amountleft>0)){
            if ($accdata->{'amountoutstanding'} < $amountleft) {
                $newamtos = 0;
                $amountleft -= $accdata->{'amountoutstanding'};
            }  else {
                $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
                $amountleft = 0;
            }
            my $thisacct = $accdata->{'accountlines_id'};
            # FIXME: move prepares outside while loop!
            my $usth = $dbh->prepare("UPDATE accountlines SET amountoutstanding= ?
                    WHERE (accountlines_id = ?)");
            $usth->execute($newamtos,$thisacct);
            $usth = $dbh->prepare("INSERT INTO accountoffsets
                (borrowernumber, accountno, offsetaccount,  offsetamount)
                VALUES
                (?,?,?,?)");
            $usth->execute($data->{'borrowernumber'},$accdata->{'accountno'},$nextaccntno,$newamtos);
        }
    }
    $amountleft *= -1 if ($amountleft > 0);
    my $desc = "Item Returned " . $item_id;
    $usth = $dbh->prepare("INSERT INTO accountlines
        (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
        VALUES (?,?,now(),?,?,'CR',?)");
    $usth->execute($data->{'borrowernumber'},$nextaccntno,0-$amount,$desc,$amountleft);
    if ($borrowernumber) {
        # FIXME: same as query above.  use 1 sth for both
        $usth = $dbh->prepare("INSERT INTO accountoffsets
            (borrowernumber, accountno, offsetaccount,  offsetamount)
            VALUES (?,?,?,?)");
        $usth->execute($borrowernumber, $data->{'accountno'}, $nextaccntno, $offset);
    }
    ModItem({ paidfor => '' }, undef, $itemnumber);
    return;
}

=head2 _GetCircControlBranch

   my $circ_control_branch = _GetCircControlBranch($iteminfos, $borrower);

Internal function : 

Return the library code to be used to determine which circulation
policy applies to a transaction.  Looks up the CircControl and
HomeOrHoldingBranch system preferences.

C<$iteminfos> is a hashref to iteminfo. Only {homebranch or holdingbranch} is used.

C<$borrower> is a hashref to borrower. Only {branchcode} is used.

=cut

sub _GetCircControlBranch {
    my ($item, $borrower) = @_;
    my $circcontrol = C4::Context->preference('CircControl');
    my $branch;

    if ($circcontrol eq 'PickupLibrary' and (C4::Context->userenv and C4::Context->userenv->{'branch'}) ) {
        $branch= C4::Context->userenv->{'branch'};
    } elsif ($circcontrol eq 'PatronLibrary') {
        $branch=$borrower->{branchcode};
    } else {
        my $branchfield = C4::Context->preference('HomeOrHoldingBranch') || 'homebranch';
        $branch = $item->{$branchfield};
        # default to item home branch if holdingbranch is used
        # and is not defined
        if (!defined($branch) && $branchfield eq 'holdingbranch') {
            $branch = $item->{homebranch};
        }
    }
    return $branch;
}






=head2 GetItemIssue

  $issue = &GetItemIssue($itemnumber);

Returns patron currently having a book, or undef if not checked out.

C<$itemnumber> is the itemnumber.

C<$issue> is a hashref of the row from the issues table.

=cut

sub GetItemIssue {
    my ($itemnumber) = @_;
    return unless $itemnumber;
    my $sth = C4::Context->dbh->prepare(
        "SELECT items.*, issues.*
        FROM issues
        LEFT JOIN items ON issues.itemnumber=items.itemnumber
        WHERE issues.itemnumber=?");
    $sth->execute($itemnumber);
    my $data = $sth->fetchrow_hashref;
    return unless $data;
    $data->{issuedate_sql} = $data->{issuedate};
    $data->{date_due_sql} = $data->{date_due};
    $data->{issuedate} = dt_from_string($data->{issuedate}, 'sql');
    $data->{issuedate}->truncate(to => 'minute');
    $data->{date_due} = dt_from_string($data->{date_due}, 'sql');
    $data->{date_due}->truncate(to => 'minute');
    my $dt = DateTime->now( time_zone => C4::Context->tz)->truncate( to => 'minute');
    $data->{'overdue'} = DateTime->compare($data->{'date_due'}, $dt ) == -1 ? 1 : 0;
    return $data;
}

=head2 GetOpenIssue

  $issue = GetOpenIssue( $itemnumber );

Returns the row from the issues table if the item is currently issued, undef if the item is not currently issued

C<$itemnumber> is the item's itemnumber

Returns a hashref

=cut

sub GetOpenIssue {
  my ( $itemnumber ) = @_;
  return unless $itemnumber;
  my $dbh = C4::Context->dbh;  
  my $sth = $dbh->prepare( "SELECT * FROM issues WHERE itemnumber = ? AND returndate IS NULL" );
  $sth->execute( $itemnumber );
  return $sth->fetchrow_hashref();

}

=head2 GetIssues

    $issues = GetIssues({});    # return all issues!
    $issues = GetIssues({ borrowernumber => $borrowernumber, biblionumber => $biblionumber });

Returns all pending issues that match given criteria.
Returns a arrayref or undef if an error occurs.

Allowed criteria are:

=over 2

=item * borrowernumber

=item * biblionumber

=item * itemnumber

=back

=cut

sub GetIssues {
    my ($criteria) = @_;

    # Build filters
    my @filters;
    my @allowed = qw(borrowernumber biblionumber itemnumber);
    foreach (@allowed) {
        if (defined $criteria->{$_}) {
            push @filters, {
                field => $_,
                value => $criteria->{$_},
            };
        }
    }

    # Do we need to join other tables ?
    my %join;
    if (defined $criteria->{biblionumber}) {
        $join{items} = 1;
    }

    # Build SQL query
    my $where = '';
    if (@filters) {
        $where = "WHERE " . join(' AND ', map { "$_->{field} = ?" } @filters);
    }
    my $query = q{
        SELECT issues.*
        FROM issues
    };
    if (defined $join{items}) {
        $query .= q{
            LEFT JOIN items ON (issues.itemnumber = items.itemnumber)
        };
    }
    $query .= $where;

    # Execute SQL query
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    my $rv = $sth->execute(map { $_->{value} } @filters);

    return $rv ? $sth->fetchall_arrayref({}) : undef;
}

=head2 GetItemIssues

  $issues = &GetItemIssues($itemnumber, $history);

Returns patrons that have issued a book

C<$itemnumber> is the itemnumber
C<$history> is false if you just want the current "issuer" (if any)
and true if you want issues history from old_issues also.

Returns reference to an array of hashes

=cut

sub GetItemIssues {
    my ( $itemnumber, $history ) = @_;
    
    my $today = DateTime->now( time_zome => C4::Context->tz);  # get today date
    $today->truncate( to => 'minute' );
    my $sql = "SELECT * FROM issues
              JOIN borrowers USING (borrowernumber)
              JOIN items     USING (itemnumber)
              WHERE issues.itemnumber = ? ";
    if ($history) {
        $sql .= "UNION ALL
                 SELECT * FROM old_issues
                 LEFT JOIN borrowers USING (borrowernumber)
                 JOIN items USING (itemnumber)
                 WHERE old_issues.itemnumber = ? ";
    }
    $sql .= "ORDER BY date_due DESC";
    my $sth = C4::Context->dbh->prepare($sql);
    if ($history) {
        $sth->execute($itemnumber, $itemnumber);
    } else {
        $sth->execute($itemnumber);
    }
    my $results = $sth->fetchall_arrayref({});
    foreach (@$results) {
        my $date_due = dt_from_string($_->{date_due},'sql');
        $date_due->truncate( to => 'minute' );

        $_->{overdue} = (DateTime->compare($date_due, $today) == -1) ? 1 : 0;
    }
    return $results;
}

=head2 GetBiblioIssues

  $issues = GetBiblioIssues($biblionumber);

this function get all issues from a biblionumber.

Return:
C<$issues> is a reference to array which each value is ref-to-hash. This ref-to-hash containts all column from
tables issues and the firstname,surname & cardnumber from borrowers.

=cut

sub GetBiblioIssues {
    my $biblionumber = shift;
    return unless $biblionumber;
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT issues.*,items.barcode,biblio.biblionumber,biblio.title, biblio.author,borrowers.cardnumber,borrowers.surname,borrowers.firstname
        FROM issues
            LEFT JOIN borrowers ON borrowers.borrowernumber = issues.borrowernumber
            LEFT JOIN items ON issues.itemnumber = items.itemnumber
            LEFT JOIN biblioitems ON items.itemnumber = biblioitems.biblioitemnumber
            LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
        WHERE biblio.biblionumber = ?
        UNION ALL
        SELECT old_issues.*,items.barcode,biblio.biblionumber,biblio.title, biblio.author,borrowers.cardnumber,borrowers.surname,borrowers.firstname
        FROM old_issues
            LEFT JOIN borrowers ON borrowers.borrowernumber = old_issues.borrowernumber
            LEFT JOIN items ON old_issues.itemnumber = items.itemnumber
            LEFT JOIN biblioitems ON items.itemnumber = biblioitems.biblioitemnumber
            LEFT JOIN biblio ON biblio.biblionumber = items.biblionumber
        WHERE biblio.biblionumber = ?
        ORDER BY timestamp
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber, $biblionumber);

    my @issues;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @issues, $data;
    }
    return \@issues;
}

=head2 GetUpcomingDueIssues

  my $upcoming_dues = GetUpcomingDueIssues( { days_in_advance => 4 } );

=cut

sub GetUpcomingDueIssues {
    my $params = shift;

    $params->{'days_in_advance'} = 7 unless exists $params->{'days_in_advance'};
    my $dbh = C4::Context->dbh;

    my $statement = <<END_SQL;
SELECT issues.*, items.itype as itemtype, items.homebranch, TO_DAYS( date_due )-TO_DAYS( NOW() ) as days_until_due, branches.branchemail
FROM issues 
LEFT JOIN items USING (itemnumber)
LEFT OUTER JOIN branches USING (branchcode)
WHERE returndate is NULL
HAVING days_until_due >= 0 AND days_until_due <= ?
END_SQL

    my @bind_parameters = ( $params->{'days_in_advance'} );
    
    my $sth = $dbh->prepare( $statement );
    $sth->execute( @bind_parameters );
    my $upcoming_dues = $sth->fetchall_arrayref({});

    return $upcoming_dues;
}

=head2 CanBookBeRenewed

  ($ok,$error) = &CanBookBeRenewed($borrowernumber, $itemnumber[, $override_limit]);

Find out whether a borrowed item may be renewed.

C<$borrowernumber> is the borrower number of the patron who currently
has the item on loan.

C<$itemnumber> is the number of the item to renew.

C<$override_limit>, if supplied with a true value, causes
the limit on the number of times that the loan can be renewed
(as controlled by the item type) to be ignored. Overriding also allows
to renew sooner than "No renewal before" and to manually renew loans
that are automatically renewed.

C<$CanBookBeRenewed> returns a true value if the item may be renewed. The
item must currently be on loan to the specified borrower; renewals
must be allowed for the item's type; and the borrower must not have
already renewed the loan. $error will contain the reason the renewal can not proceed

=cut

sub CanBookBeRenewed {
    my ( $borrowernumber, $itemnumber, $override_limit ) = @_;

    my $dbh    = C4::Context->dbh;
    my $renews = 1;

    my $item      = GetItem($itemnumber)      or return ( 0, 'no_item' );
    my $itemissue = GetItemIssue($itemnumber) or return ( 0, 'no_checkout' );
    return ( 0, 'onsite_checkout' ) if $itemissue->{onsite_checkout};

    $borrowernumber ||= $itemissue->{borrowernumber};
    my $borrower = C4::Members::GetMember( borrowernumber => $borrowernumber )
      or return;

    my ( $resfound, $resrec, undef ) = C4::Reserves::CheckReserves($itemnumber);

    # This item can fill one or more unfilled reserve, can those unfilled reserves
    # all be filled by other available items?
    if ( $resfound
        && C4::Context->preference('AllowRenewalIfOtherItemsAvailable') )
    {
        my $schema = Koha::Database->new()->schema();

        my $item_holds = $schema->resultset('Reserve')->search( { itemnumber => $itemnumber, found => undef } )->count();
        if ($item_holds) {
            # There is an item level hold on this item, no other item can fill the hold
            $resfound = 1;
        }
        else {

            # Get all other items that could possibly fill reserves
            my @itemnumbers = $schema->resultset('Item')->search(
                {
                    biblionumber => $resrec->{biblionumber},
                    onloan       => undef,
                    notforloan   => 0,
                    -not         => { itemnumber => $itemnumber }
                },
                { columns => 'itemnumber' }
            )->get_column('itemnumber')->all();

            # Get all other reserves that could have been filled by this item
            my @borrowernumbers;
            while (1) {
                my ( $reserve_found, $reserve, undef ) =
                  C4::Reserves::CheckReserves( $itemnumber, undef, undef, \@borrowernumbers );

                if ($reserve_found) {
                    push( @borrowernumbers, $reserve->{borrowernumber} );
                }
                else {
                    last;
                }
            }

            # If the count of the union of the lists of reservable items for each borrower
            # is equal or greater than the number of borrowers, we know that all reserves
            # can be filled with available items. We can get the union of the sets simply
            # by pushing all the elements onto an array and removing the duplicates.
            my @reservable;
            foreach my $b (@borrowernumbers) {
                my ($borr) = C4::Members::GetMemberDetails($b);
                foreach my $i (@itemnumbers) {
                    my $item = GetItem($i);
                    if (   IsAvailableForItemLevelRequest( $item, $borr )
                        && CanItemBeReserved( $b, $i )
                        && !IsItemOnHoldAndFound($i) )
                    {
                        push( @reservable, $i );
                    }
                }
            }

            @reservable = uniq(@reservable);

            if ( @reservable >= @borrowernumbers ) {
                $resfound = 0;
            }
        }
    }
    return ( 0, "on_reserve" ) if $resfound;    # '' when no hold was found

    return ( 1, undef ) if $override_limit;

    my $branchcode = _GetCircControlBranch( $item, $borrower );
    my $issuingrule =
      GetIssuingRule( $borrower->{categorycode}, $item->{itype}, $branchcode );

    return ( 0, "too_many" )
      if $issuingrule->{renewalsallowed} <= $itemissue->{renewals};

    my $overduesblockrenewing = C4::Context->preference('OverduesBlockRenewing');
    my $restrictionblockrenewing = C4::Context->preference('RestrictionBlockRenewing');
    my $restricted = Koha::Patron::Debarments::IsDebarred($borrowernumber);
    my $hasoverdues = C4::Members::HasOverdues($borrowernumber);

    if ( $restricted and $restrictionblockrenewing ) {
        return ( 0, 'restriction');
    } elsif ( ($hasoverdues and $overduesblockrenewing eq 'block') || ($itemissue->{overdue} and $overduesblockrenewing eq 'blockitem') ) {
        return ( 0, 'overdue');
    }

    if ( defined $issuingrule->{norenewalbefore}
        and $issuingrule->{norenewalbefore} ne "" )
    {

        # Calculate soonest renewal by subtracting 'No renewal before' from due date
        my $soonestrenewal =
          $itemissue->{date_due}->clone()
          ->subtract(
            $issuingrule->{lengthunit} => $issuingrule->{norenewalbefore} );

        # Depending on syspref reset the exact time, only check the date
        if ( C4::Context->preference('NoRenewalBeforePrecision') eq 'date'
            and $issuingrule->{lengthunit} eq 'days' )
        {
            $soonestrenewal->truncate( to => 'day' );
        }

        if ( $soonestrenewal > DateTime->now( time_zone => C4::Context->tz() ) )
        {
            return ( 0, "auto_too_soon" ) if $itemissue->{auto_renew};
            return ( 0, "too_soon" );
        }
        elsif ( $itemissue->{auto_renew} ) {
            return ( 0, "auto_renew" );
        }
    }

    # Fallback for automatic renewals:
    # If norenewalbefore is undef, don't renew before due date.
    elsif ( $itemissue->{auto_renew} ) {
        my $now = dt_from_string;
        return ( 0, "auto_renew" )
          if $now >= $itemissue->{date_due};
        return ( 0, "auto_too_soon" );
    }

    return ( 1, undef );
}

=head2 AddRenewal

  &AddRenewal($borrowernumber, $itemnumber, $branch, [$datedue], [$lastreneweddate]);

Renews a loan.

C<$borrowernumber> is the borrower number of the patron who currently
has the item.

C<$itemnumber> is the number of the item to renew.

C<$branch> is the library where the renewal took place (if any).
           The library that controls the circ policies for the renewal is retrieved from the issues record.

C<$datedue> can be a DateTime object used to set the due date.

C<$lastreneweddate> is an optional ISO-formatted date used to set issues.lastreneweddate.  If
this parameter is not supplied, lastreneweddate is set to the current date.

If C<$datedue> is the empty string, C<&AddRenewal> will calculate the due date automatically
from the book's item type.

=cut

sub AddRenewal {
    my $borrowernumber  = shift;
    my $itemnumber      = shift or return;
    my $branch          = shift;
    my $datedue         = shift;
    my $lastreneweddate = shift || DateTime->now(time_zone => C4::Context->tz)->ymd();

    my $item   = GetItem($itemnumber) or return;
    my $biblio = GetBiblioFromItemNumber($itemnumber) or return;

    my $dbh = C4::Context->dbh;

    # Find the issues record for this book
    my $sth =
      $dbh->prepare("SELECT * FROM issues WHERE itemnumber = ?");
    $sth->execute( $itemnumber );
    my $issuedata = $sth->fetchrow_hashref;

    return unless ( $issuedata );

    $borrowernumber ||= $issuedata->{borrowernumber};

    if ( defined $datedue && ref $datedue ne 'DateTime' ) {
        carp 'Invalid date passed to AddRenewal.';
        return;
    }

    # If the due date wasn't specified, calculate it by adding the
    # book's loan length to today's date or the current due date
    # based on the value of the RenewalPeriodBase syspref.
    unless ($datedue) {

        my $borrower = C4::Members::GetMember( borrowernumber => $borrowernumber ) or return;
        my $itemtype = (C4::Context->preference('item-level_itypes')) ? $biblio->{'itype'} : $biblio->{'itemtype'};

        $datedue = (C4::Context->preference('RenewalPeriodBase') eq 'date_due') ?
                                        dt_from_string( $issuedata->{date_due} ) :
                                        DateTime->now( time_zone => C4::Context->tz());
        $datedue =  CalcDateDue($datedue, $itemtype, $issuedata->{'branchcode'}, $borrower, 'is a renewal');
    }

    # Update the issues record to have the new due date, and a new count
    # of how many times it has been renewed.
    my $renews = $issuedata->{'renewals'} + 1;
    $sth = $dbh->prepare("UPDATE issues SET date_due = ?, renewals = ?, lastreneweddate = ?
                            WHERE borrowernumber=? 
                            AND itemnumber=?"
    );

    $sth->execute( $datedue->strftime('%Y-%m-%d %H:%M'), $renews, $lastreneweddate, $borrowernumber, $itemnumber );

    # Update the renewal count on the item, and tell zebra to reindex
    $renews = $biblio->{'renewals'} + 1;
    ModItem({ renewals => $renews, onloan => $datedue->strftime('%Y-%m-%d %H:%M')}, $biblio->{'biblionumber'}, $itemnumber);

    # Charge a new rental fee, if applicable?
    my ( $charge, $type ) = GetIssuingCharges( $itemnumber, $borrowernumber );
    if ( $charge > 0 ) {
        my $accountno = getnextacctno( $borrowernumber );
        my $item = GetBiblioFromItemNumber($itemnumber);
        my $manager_id = 0;
        $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv; 
        $sth = $dbh->prepare(
                "INSERT INTO accountlines
                    (date, borrowernumber, accountno, amount, manager_id,
                    description,accounttype, amountoutstanding, itemnumber)
                    VALUES (now(),?,?,?,?,?,?,?,?)"
        );
        $sth->execute( $borrowernumber, $accountno, $charge, $manager_id,
            "Renewal of Rental Item $item->{'title'} $item->{'barcode'}",
            'Rent', $charge, $itemnumber );
    }

    # Send a renewal slip according to checkout alert preferencei
    if ( C4::Context->preference('RenewalSendNotice') eq '1') {
	my $borrower = C4::Members::GetMemberDetails( $borrowernumber, 0 );
	my $circulation_alert = 'C4::ItemCirculationAlertPreference';
	my %conditions = (
		branchcode   => $branch,
		categorycode => $borrower->{categorycode},
		item_type    => $item->{itype},
		notification => 'CHECKOUT',
	);
	if ($circulation_alert->is_enabled_for(\%conditions)) {
		SendCirculationAlert({
			type     => 'RENEWAL',
			item     => $item,
		borrower => $borrower,
		branch   => $branch,
		});
	}
    }

    # Remove any OVERDUES related debarment if the borrower has no overdues
    my $borrower = C4::Members::GetMember( borrowernumber => $borrowernumber );
    if ( $borrowernumber
      && $borrower->{'debarred'}
      && !C4::Members::HasOverdues( $borrowernumber )
      && @{ GetDebarments({ borrowernumber => $borrowernumber, type => 'OVERDUES' }) }
    ) {
        DelUniqueDebarment({ borrowernumber => $borrowernumber, type => 'OVERDUES' });
    }

    # Log the renewal
    UpdateStats({branch => $branch,
                type => 'renew',
                amount => $charge,
                itemnumber => $itemnumber,
                itemtype => $item->{itype},
                borrowernumber => $borrowernumber,
                ccode => $item->{'ccode'}}
                );
	return $datedue;
}

sub GetRenewCount {
    # check renewal status
    my ( $bornum, $itemno ) = @_;
    my $dbh           = C4::Context->dbh;
    my $renewcount    = 0;
    my $renewsallowed = 0;
    my $renewsleft    = 0;

    my $borrower = C4::Members::GetMember( borrowernumber => $bornum);
    my $item     = GetItem($itemno); 

    # Look in the issues table for this item, lent to this borrower,
    # and not yet returned.

    # FIXME - I think this function could be redone to use only one SQL call.
    my $sth = $dbh->prepare(
        "select * from issues
                                where (borrowernumber = ?)
                                and (itemnumber = ?)"
    );
    $sth->execute( $bornum, $itemno );
    my $data = $sth->fetchrow_hashref;
    $renewcount = $data->{'renewals'} if $data->{'renewals'};
    # $item and $borrower should be calculated
    my $branchcode = _GetCircControlBranch($item, $borrower);
    
    my $issuingrule = GetIssuingRule($borrower->{categorycode}, $item->{itype}, $branchcode);
    
    $renewsallowed = $issuingrule->{'renewalsallowed'};
    $renewsleft    = $renewsallowed - $renewcount;
    if($renewsleft < 0){ $renewsleft = 0; }
    return ( $renewcount, $renewsallowed, $renewsleft );
}

=head2 GetSoonestRenewDate

  $NoRenewalBeforeThisDate = &GetSoonestRenewDate($borrowernumber, $itemnumber);

Find out the soonest possible renew date of a borrowed item.

C<$borrowernumber> is the borrower number of the patron who currently
has the item on loan.

C<$itemnumber> is the number of the item to renew.

C<$GetSoonestRenewDate> returns the DateTime of the soonest possible
renew date, based on the value "No renewal before" of the applicable
issuing rule. Returns the current date if the item can already be
renewed, and returns undefined if the borrower, loan, or item
cannot be found.

=cut

sub GetSoonestRenewDate {
    my ( $borrowernumber, $itemnumber ) = @_;

    my $dbh = C4::Context->dbh;

    my $item      = GetItem($itemnumber)      or return;
    my $itemissue = GetItemIssue($itemnumber) or return;

    $borrowernumber ||= $itemissue->{borrowernumber};
    my $borrower = C4::Members::GetMemberDetails($borrowernumber)
      or return;

    my $branchcode = _GetCircControlBranch( $item, $borrower );
    my $issuingrule =
      GetIssuingRule( $borrower->{categorycode}, $item->{itype}, $branchcode );

    my $now = dt_from_string;

    if ( defined $issuingrule->{norenewalbefore}
        and $issuingrule->{norenewalbefore} ne "" )
    {
        my $soonestrenewal =
          $itemissue->{date_due}->clone()
          ->subtract(
            $issuingrule->{lengthunit} => $issuingrule->{norenewalbefore} );

        if ( C4::Context->preference('NoRenewalBeforePrecision') eq 'date'
            and $issuingrule->{lengthunit} eq 'days' )
        {
            $soonestrenewal->truncate( to => 'day' );
        }
        return $soonestrenewal if $now < $soonestrenewal;
    }
    return $now;
}

=head2 GetIssuingCharges

  ($charge, $item_type) = &GetIssuingCharges($itemnumber, $borrowernumber);

Calculate how much it would cost for a given patron to borrow a given
item, including any applicable discounts.

C<$itemnumber> is the item number of item the patron wishes to borrow.

C<$borrowernumber> is the patron's borrower number.

C<&GetIssuingCharges> returns two values: C<$charge> is the rental charge,
and C<$item_type> is the code for the item's item type (e.g., C<VID>
if it's a video).

=cut

sub GetIssuingCharges {

    # calculate charges due
    my ( $itemnumber, $borrowernumber ) = @_;
    my $charge = 0;
    my $dbh    = C4::Context->dbh;
    my $item_type;

    # Get the book's item type and rental charge (via its biblioitem).
    my $charge_query = 'SELECT itemtypes.itemtype,rentalcharge FROM items
        LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber';
    $charge_query .= (C4::Context->preference('item-level_itypes'))
        ? ' LEFT JOIN itemtypes ON items.itype = itemtypes.itemtype'
        : ' LEFT JOIN itemtypes ON biblioitems.itemtype = itemtypes.itemtype';

    $charge_query .= ' WHERE items.itemnumber =?';

    my $sth = $dbh->prepare($charge_query);
    $sth->execute($itemnumber);
    if ( my $item_data = $sth->fetchrow_hashref ) {
        $item_type = $item_data->{itemtype};
        $charge    = $item_data->{rentalcharge};
        my $branch = C4::Branch::mybranch();
        my $discount_query = q|SELECT rentaldiscount,
            issuingrules.itemtype, issuingrules.branchcode
            FROM borrowers
            LEFT JOIN issuingrules ON borrowers.categorycode = issuingrules.categorycode
            WHERE borrowers.borrowernumber = ?
            AND (issuingrules.itemtype = ? OR issuingrules.itemtype = '*')
            AND (issuingrules.branchcode = ? OR issuingrules.branchcode = '*')|;
        my $discount_sth = $dbh->prepare($discount_query);
        $discount_sth->execute( $borrowernumber, $item_type, $branch );
        my $discount_rules = $discount_sth->fetchall_arrayref({});
        if (@{$discount_rules}) {
            # We may have multiple rules so get the most specific
            my $discount = _get_discount_from_rule($discount_rules, $branch, $item_type);
            $charge = ( $charge * ( 100 - $discount ) ) / 100;
        }
    }

    return ( $charge, $item_type );
}

# Select most appropriate discount rule from those returned
sub _get_discount_from_rule {
    my ($rules_ref, $branch, $itemtype) = @_;
    my $discount;

    if (@{$rules_ref} == 1) { # only 1 applicable rule use it
        $discount = $rules_ref->[0]->{rentaldiscount};
        return (defined $discount) ? $discount : 0;
    }
    # could have up to 4 does one match $branch and $itemtype
    my @d = grep { $_->{branchcode} eq $branch && $_->{itemtype} eq $itemtype } @{$rules_ref};
    if (@d) {
        $discount = $d[0]->{rentaldiscount};
        return (defined $discount) ? $discount : 0;
    }
    # do we have item type + all branches
    @d = grep { $_->{branchcode} eq q{*} && $_->{itemtype} eq $itemtype } @{$rules_ref};
    if (@d) {
        $discount = $d[0]->{rentaldiscount};
        return (defined $discount) ? $discount : 0;
    }
    # do we all item types + this branch
    @d = grep { $_->{branchcode} eq $branch && $_->{itemtype} eq q{*} } @{$rules_ref};
    if (@d) {
        $discount = $d[0]->{rentaldiscount};
        return (defined $discount) ? $discount : 0;
    }
    # so all and all (surely we wont get here)
    @d = grep { $_->{branchcode} eq q{*} && $_->{itemtype} eq q{*} } @{$rules_ref};
    if (@d) {
        $discount = $d[0]->{rentaldiscount};
        return (defined $discount) ? $discount : 0;
    }
    # none of the above
    return 0;
}

=head2 AddIssuingCharge

  &AddIssuingCharge( $itemno, $borrowernumber, $charge )

=cut

sub AddIssuingCharge {
    my ( $itemnumber, $borrowernumber, $charge ) = @_;
    my $dbh = C4::Context->dbh;
    my $nextaccntno = getnextacctno( $borrowernumber );
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;
    my $query ="
        INSERT INTO accountlines
            (borrowernumber, itemnumber, accountno,
            date, amount, description, accounttype,
            amountoutstanding, manager_id)
        VALUES (?, ?, ?,now(), ?, 'Rental', 'Rent',?,?)
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $itemnumber, $nextaccntno, $charge, $charge, $manager_id );
}

=head2 GetTransfers

  GetTransfers($itemnumber);

=cut

sub GetTransfers {
    my ($itemnumber) = @_;

    my $dbh = C4::Context->dbh;

    my $query = '
        SELECT datesent,
               frombranch,
               tobranch
        FROM branchtransfers
        WHERE itemnumber = ?
          AND datearrived IS NULL
        ';
    my $sth = $dbh->prepare($query);
    $sth->execute($itemnumber);
    my @row = $sth->fetchrow_array();
    return @row;
}

=head2 GetTransfersFromTo

  @results = GetTransfersFromTo($frombranch,$tobranch);

Returns the list of pending transfers between $from and $to branch

=cut

sub GetTransfersFromTo {
    my ( $frombranch, $tobranch ) = @_;
    return unless ( $frombranch && $tobranch );
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT itemnumber,datesent,frombranch
        FROM   branchtransfers
        WHERE  frombranch=?
          AND  tobranch=?
          AND datearrived IS NULL
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $frombranch, $tobranch );
    my @gettransfers;

    while ( my $data = $sth->fetchrow_hashref ) {
        push @gettransfers, $data;
    }
    return (@gettransfers);
}

=head2 DeleteTransfer

  &DeleteTransfer($itemnumber);

=cut

sub DeleteTransfer {
    my ($itemnumber) = @_;
    return unless $itemnumber;
    my $dbh          = C4::Context->dbh;
    my $sth          = $dbh->prepare(
        "DELETE FROM branchtransfers
         WHERE itemnumber=?
         AND datearrived IS NULL "
    );
    return $sth->execute($itemnumber);
}

=head2 AnonymiseIssueHistory

  ($rows,$err_history_not_deleted) = AnonymiseIssueHistory($date,$borrowernumber)

This function write NULL instead of C<$borrowernumber> given on input arg into the table issues.
if C<$borrowernumber> is not set, it will delete the issue history for all borrower older than C<$date>.

If c<$borrowernumber> is set, it will delete issue history for only that borrower, regardless of their opac privacy
setting (force delete).

return the number of affected rows and a value that evaluates to true if an error occurred deleting the history.

=cut

sub AnonymiseIssueHistory {
    my $date           = shift;
    my $borrowernumber = shift;
    my $dbh            = C4::Context->dbh;
    my $query          = "
        UPDATE old_issues
        SET    borrowernumber = ?
        WHERE  returndate < ?
          AND borrowernumber IS NOT NULL
    ";

    # The default of 0 does not work due to foreign key constraints
    # The anonymisation should not fail quietly if AnonymousPatron is not a valid entry
    # Set it to undef (NULL)
    my $anonymouspatron = C4::Context->preference('AnonymousPatron') || undef;
    my @bind_params = ($anonymouspatron, $date);
    if (defined $borrowernumber) {
       $query .= " AND borrowernumber = ?";
       push @bind_params, $borrowernumber;
    } else {
       $query .= " AND (SELECT privacy FROM borrowers WHERE borrowers.borrowernumber=old_issues.borrowernumber) <> 0";
    }
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind_params);
    my $anonymisation_err = $dbh->err;
    my $rows_affected = $sth->rows;  ### doublecheck row count return function
    return ($rows_affected, $anonymisation_err);
}

=head2 SendCirculationAlert

Send out a C<check-in> or C<checkout> alert using the messaging system.

B<Parameters>:

=over 4

=item type

Valid values for this parameter are: C<CHECKIN> and C<CHECKOUT>.

=item item

Hashref of information about the item being checked in or out.

=item borrower

Hashref of information about the borrower of the item.

=item branch

The branchcode from where the checkout or check-in took place.

=back

B<Example>:

    SendCirculationAlert({
        type     => 'CHECKOUT',
        item     => $item,
        borrower => $borrower,
        branch   => $branch,
    });

=cut

sub SendCirculationAlert {
    my ($opts) = @_;
    my ($type, $item, $borrower, $branch) =
        ($opts->{type}, $opts->{item}, $opts->{borrower}, $opts->{branch});
    my %message_name = (
        CHECKIN  => 'Item_Check_in',
        CHECKOUT => 'Item_Checkout',
	RENEWAL  => 'Item_Checkout',
    );
    my $borrower_preferences = C4::Members::Messaging::GetMessagingPreferences({
        borrowernumber => $borrower->{borrowernumber},
        message_name   => $message_name{$type},
    });
    my $issues_table = ( $type eq 'CHECKOUT' || $type eq 'RENEWAL' ) ? 'issues' : 'old_issues';

    my @transports = keys %{ $borrower_preferences->{transports} };
    # warn "no transports" unless @transports;
    for (@transports) {
        # warn "transport: $_";
        my $message = C4::Message->find_last_message($borrower, $type, $_);
        if (!$message) {
            #warn "create new message";
            my $letter =  C4::Letters::GetPreparedLetter (
                module => 'circulation',
                letter_code => $type,
                branchcode => $branch,
                message_transport_type => $_,
                tables => {
                    $issues_table => $item->{itemnumber},
                    'items'       => $item->{itemnumber},
                    'biblio'      => $item->{biblionumber},
                    'biblioitems' => $item->{biblionumber},
                    'borrowers'   => $borrower,
                    'branches'    => $branch,
                }
            ) or next;
            C4::Message->enqueue($letter, $borrower, $_);
        } else {
            #warn "append to old message";
            my $letter =  C4::Letters::GetPreparedLetter (
                module => 'circulation',
                letter_code => $type,
                branchcode => $branch,
                message_transport_type => $_,
                tables => {
                    $issues_table => $item->{itemnumber},
                    'items'       => $item->{itemnumber},
                    'biblio'      => $item->{biblionumber},
                    'biblioitems' => $item->{biblionumber},
                    'borrowers'   => $borrower,
                    'branches'    => $branch,
                }
            ) or next;
            $message->append($letter);
            $message->update;
        }
    }

    return;
}

=head2 updateWrongTransfer

  $items = updateWrongTransfer($itemNumber,$borrowernumber,$waitingAtLibrary,$FromLibrary);

This function validate the line of brachtransfer but with the wrong destination (mistake from a librarian ...), and create a new line in branchtransfer from the actual library to the original library of reservation 

=cut

sub updateWrongTransfer {
	my ( $itemNumber,$waitingAtLibrary,$FromLibrary ) = @_;
	my $dbh = C4::Context->dbh;	
# first step validate the actual line of transfert .
	my $sth =
        	$dbh->prepare(
			"update branchtransfers set datearrived = now(),tobranch=?,comments='wrongtransfer' where itemnumber= ? AND datearrived IS NULL"
          	);
        	$sth->execute($FromLibrary,$itemNumber);

# second step create a new line of branchtransfer to the right location .
	ModItemTransfer($itemNumber, $FromLibrary, $waitingAtLibrary);

#third step changing holdingbranch of item
	UpdateHoldingbranch($FromLibrary,$itemNumber);
}

=head2 UpdateHoldingbranch

  $items = UpdateHoldingbranch($branch,$itmenumber);

Simple methode for updating hodlingbranch in items BDD line

=cut

sub UpdateHoldingbranch {
	my ( $branch,$itemnumber ) = @_;
    ModItem({ holdingbranch => $branch }, undef, $itemnumber);
}

=head2 CalcDateDue

$newdatedue = CalcDateDue($startdate,$itemtype,$branchcode,$borrower);

this function calculates the due date given the start date and configured circulation rules,
checking against the holidays calendar as per the 'useDaysMode' syspref.
C<$startdate>   = DateTime object representing start date of loan period (assumed to be today)
C<$itemtype>  = itemtype code of item in question
C<$branch>  = location whose calendar to use
C<$borrower> = Borrower object
C<$isrenewal> = Boolean: is true if we want to calculate the date due for a renewal. Else is false.

=cut

sub CalcDateDue {
    my ( $startdate, $itemtype, $branch, $borrower, $isrenewal ) = @_;

    $isrenewal ||= 0;

    # loanlength now a href
    my $loanlength =
            GetLoanLength( $borrower->{'categorycode'}, $itemtype, $branch );

    my $length_key = ( $isrenewal and defined $loanlength->{renewalperiod} )
            ? qq{renewalperiod}
            : qq{issuelength};

    my $datedue;
    if ( $startdate ) {
        if (ref $startdate ne 'DateTime' ) {
            $datedue = dt_from_string($datedue);
        } else {
            $datedue = $startdate->clone;
        }
    } else {
        $datedue =
          DateTime->now( time_zone => C4::Context->tz() )
          ->truncate( to => 'minute' );
    }


    # calculate the datedue as normal
    if ( C4::Context->preference('useDaysMode') eq 'Days' )
    {    # ignoring calendar
        if ( $loanlength->{lengthunit} eq 'hours' ) {
            $datedue->add( hours => $loanlength->{$length_key} );
        } else {    # days
            $datedue->add( days => $loanlength->{$length_key} );
            $datedue->set_hour(23);
            $datedue->set_minute(59);
        }
    } else {
        my $dur;
        if ($loanlength->{lengthunit} eq 'hours') {
            $dur = DateTime::Duration->new( hours => $loanlength->{$length_key});
        }
        else { # days
            $dur = DateTime::Duration->new( days => $loanlength->{$length_key});
        }
        my $calendar = Koha::Calendar->new( branchcode => $branch );
        $datedue = $calendar->addDate( $datedue, $dur, $loanlength->{lengthunit} );
        if ($loanlength->{lengthunit} eq 'days') {
            $datedue->set_hour(23);
            $datedue->set_minute(59);
        }
    }

    # if Hard Due Dates are used, retrieve them and apply as necessary
    my ( $hardduedate, $hardduedatecompare ) =
      GetHardDueDate( $borrower->{'categorycode'}, $itemtype, $branch );
    if ($hardduedate) {    # hardduedates are currently dates
        $hardduedate->truncate( to => 'minute' );
        $hardduedate->set_hour(23);
        $hardduedate->set_minute(59);
        my $cmp = DateTime->compare( $hardduedate, $datedue );

# if the calculated due date is after the 'before' Hard Due Date (ceiling), override
# if the calculated date is before the 'after' Hard Due Date (floor), override
# if the hard due date is set to 'exactly', overrride
        if ( $hardduedatecompare == 0 || $hardduedatecompare == $cmp ) {
            $datedue = $hardduedate->clone;
        }

        # in all other cases, keep the date due as it is

    }

    # if ReturnBeforeExpiry ON the datedue can't be after borrower expirydate
    if ( C4::Context->preference('ReturnBeforeExpiry') ) {
        my $expiry_dt = dt_from_string( $borrower->{dateexpiry}, 'iso', 'floating');
        if( $expiry_dt ) { #skip empty expiry date..
            $expiry_dt->set( hour => 23, minute => 59);
            my $d1= $datedue->clone->set_time_zone('floating');
            if ( DateTime->compare( $d1, $expiry_dt ) == 1 ) {
                $datedue = $expiry_dt->clone->set_time_zone( C4::Context->tz );
            }
        }
    }

    return $datedue;
}


sub CheckValidBarcode{
my ($barcode) = @_;
my $dbh = C4::Context->dbh;
my $query=qq|SELECT count(*) 
	     FROM items 
             WHERE barcode=?
	    |;
my $sth = $dbh->prepare($query);
$sth->execute($barcode);
my $exist=$sth->fetchrow ;
return $exist;
}

=head2 IsBranchTransferAllowed

  $allowed = IsBranchTransferAllowed( $toBranch, $fromBranch, $code );

Code is either an itemtype or collection doe depending on the pref BranchTransferLimitsType

=cut

sub IsBranchTransferAllowed {
	my ( $toBranch, $fromBranch, $code ) = @_;

	if ( $toBranch eq $fromBranch ) { return 1; } ## Short circuit for speed.
        
	my $limitType = C4::Context->preference("BranchTransferLimitsType");   
	my $dbh = C4::Context->dbh;
            
	my $sth = $dbh->prepare("SELECT * FROM branch_transfer_limits WHERE toBranch = ? AND fromBranch = ? AND $limitType = ?");
	$sth->execute( $toBranch, $fromBranch, $code );
	my $limit = $sth->fetchrow_hashref();
                        
	## If a row is found, then that combination is not allowed, if no matching row is found, then the combination *is allowed*
	if ( $limit->{'limitId'} ) {
		return 0;
	} else {
		return 1;
	}
}                                                        

=head2 CreateBranchTransferLimit

  CreateBranchTransferLimit( $toBranch, $fromBranch, $code );

$code is either itemtype or collection code depending on what the pref BranchTransferLimitsType is set to.

=cut

sub CreateBranchTransferLimit {
   my ( $toBranch, $fromBranch, $code ) = @_;
   return unless defined($toBranch) && defined($fromBranch);
   my $limitType = C4::Context->preference("BranchTransferLimitsType");
   
   my $dbh = C4::Context->dbh;
   
   my $sth = $dbh->prepare("INSERT INTO branch_transfer_limits ( $limitType, toBranch, fromBranch ) VALUES ( ?, ?, ? )");
   return $sth->execute( $code, $toBranch, $fromBranch );
}

=head2 DeleteBranchTransferLimits

    my $result = DeleteBranchTransferLimits($frombranch);

Deletes all the library transfer limits for one library.  Returns the
number of limits deleted, 0e0 if no limits were deleted, or undef if
no arguments are supplied.

=cut

sub DeleteBranchTransferLimits {
    my $branch = shift;
    return unless defined $branch;
    my $dbh    = C4::Context->dbh;
    my $sth    = $dbh->prepare("DELETE FROM branch_transfer_limits WHERE fromBranch = ?");
    return $sth->execute($branch);
}

sub ReturnLostItem{
    my ( $borrowernumber, $itemnum ) = @_;

    MarkIssueReturned( $borrowernumber, $itemnum );
    my $borrower = C4::Members::GetMember( 'borrowernumber'=>$borrowernumber );
    my $item = C4::Items::GetItem( $itemnum );
    my $old_note = ($item->{'paidfor'} && ($item->{'paidfor'} ne q{})) ? $item->{'paidfor'}.' / ' : q{};
    my @datearr = localtime(time);
    my $date = ( 1900 + $datearr[5] ) . "-" . ( $datearr[4] + 1 ) . "-" . $datearr[3];
    my $bor = "$borrower->{'firstname'} $borrower->{'surname'} $borrower->{'cardnumber'}";
    ModItem({ paidfor =>  $old_note."Paid for by $bor $date" }, undef, $itemnum);
}


sub LostItem{
    my ($itemnumber, $mark_returned) = @_;

    my $dbh = C4::Context->dbh();
    my $sth=$dbh->prepare("SELECT issues.*,items.*,biblio.title 
                           FROM issues 
                           JOIN items USING (itemnumber) 
                           JOIN biblio USING (biblionumber)
                           WHERE issues.itemnumber=?");
    $sth->execute($itemnumber);
    my $issues=$sth->fetchrow_hashref();

    # If a borrower lost the item, add a replacement cost to the their record
    if ( my $borrowernumber = $issues->{borrowernumber} ){
        my $borrower = C4::Members::GetMemberDetails( $borrowernumber );

        if (C4::Context->preference('WhenLostForgiveFine')){
            my $fix = _FixOverduesOnReturn($borrowernumber, $itemnumber, 1, 0); # 1, 0 = exemptfine, no-dropbox
            defined($fix) or warn "_FixOverduesOnReturn($borrowernumber, $itemnumber...) failed!";  # zero is OK, check defined
        }
        if (C4::Context->preference('WhenLostChargeReplacementFee')){
            C4::Accounts::chargelostitem($borrowernumber, $itemnumber, $issues->{'replacementprice'}, "Lost Item $issues->{'title'} $issues->{'barcode'}");
            #FIXME : Should probably have a way to distinguish this from an item that really was returned.
            #warn " $issues->{'borrowernumber'}  /  $itemnumber ";
        }

        MarkIssueReturned($borrowernumber,$itemnumber,undef,undef,$borrower->{'privacy'}) if $mark_returned;
    }
}

sub GetOfflineOperations {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM pending_offline_operations WHERE branchcode=? ORDER BY timestamp");
    $sth->execute(C4::Context->userenv->{'branch'});
    my $results = $sth->fetchall_arrayref({});
    return $results;
}

sub GetOfflineOperation {
    my $operationid = shift;
    return unless $operationid;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM pending_offline_operations WHERE operationid=?");
    $sth->execute( $operationid );
    return $sth->fetchrow_hashref;
}

sub AddOfflineOperation {
    my ( $userid, $branchcode, $timestamp, $action, $barcode, $cardnumber, $amount ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("INSERT INTO pending_offline_operations (userid, branchcode, timestamp, action, barcode, cardnumber, amount) VALUES(?,?,?,?,?,?,?)");
    $sth->execute( $userid, $branchcode, $timestamp, $action, $barcode, $cardnumber, $amount );
    return "Added.";
}

sub DeleteOfflineOperation {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("DELETE FROM pending_offline_operations WHERE operationid=?");
    $sth->execute( shift );
    return "Deleted.";
}

sub ProcessOfflineOperation {
    my $operation = shift;

    my $report;
    if ( $operation->{action} eq 'return' ) {
        $report = ProcessOfflineReturn( $operation );
    } elsif ( $operation->{action} eq 'issue' ) {
        $report = ProcessOfflineIssue( $operation );
    } elsif ( $operation->{action} eq 'payment' ) {
        $report = ProcessOfflinePayment( $operation );
    }

    DeleteOfflineOperation( $operation->{operationid} ) if $operation->{operationid};

    return $report;
}

sub ProcessOfflineReturn {
    my $operation = shift;

    my $itemnumber = C4::Items::GetItemnumberFromBarcode( $operation->{barcode} );

    if ( $itemnumber ) {
        my $issue = GetOpenIssue( $itemnumber );
        if ( $issue ) {
            MarkIssueReturned(
                $issue->{borrowernumber},
                $itemnumber,
                undef,
                $operation->{timestamp},
            );
            ModItem(
                { renewals => 0, onloan => undef },
                $issue->{'biblionumber'},
                $itemnumber
            );
            return "Success.";
        } else {
            return "Item not issued.";
        }
    } else {
        return "Item not found.";
    }
}

sub ProcessOfflineIssue {
    my $operation = shift;

    my $borrower = C4::Members::GetMemberDetails( undef, $operation->{cardnumber} ); # Get borrower from operation cardnumber

    if ( $borrower->{borrowernumber} ) {
        my $itemnumber = C4::Items::GetItemnumberFromBarcode( $operation->{barcode} );
        unless ($itemnumber) {
            return "Barcode not found.";
        }
        my $issue = GetOpenIssue( $itemnumber );

        if ( $issue and ( $issue->{borrowernumber} ne $borrower->{borrowernumber} ) ) { # Item already issued to another borrower, mark it returned
            MarkIssueReturned(
                $issue->{borrowernumber},
                $itemnumber,
                undef,
                $operation->{timestamp},
            );
        }
        AddIssue(
            $borrower,
            $operation->{'barcode'},
            undef,
            1,
            $operation->{timestamp},
            undef,
        );
        return "Success.";
    } else {
        return "Borrower not found.";
    }
}

sub ProcessOfflinePayment {
    my $operation = shift;

    my $borrower = C4::Members::GetMemberDetails( undef, $operation->{cardnumber} ); # Get borrower from operation cardnumber
    my $amount = $operation->{amount};

    recordpayment( $borrower->{borrowernumber}, $amount );

    return "Success."
}


=head2 TransferSlip

  TransferSlip($user_branch, $itemnumber, $barcode, $to_branch)

  Returns letter hash ( see C4::Letters::GetPreparedLetter ) or undef

=cut

sub TransferSlip {
    my ($branch, $itemnumber, $barcode, $to_branch) = @_;

    my $item =  GetItem( $itemnumber, $barcode )
      or return;

    return C4::Letters::GetPreparedLetter (
        module => 'circulation',
        letter_code => 'TRANSFERSLIP',
        branchcode => $branch,
        tables => {
            'branches'    => $to_branch,
            'biblio'      => $item->{biblionumber},
            'items'       => $item,
        },
    );
}

=head2 CheckIfIssuedToPatron

  CheckIfIssuedToPatron($borrowernumber, $biblionumber)

  Return 1 if any record item is issued to patron, otherwise return 0

=cut

sub CheckIfIssuedToPatron {
    my ($borrowernumber, $biblionumber) = @_;

    my $dbh = C4::Context->dbh;
    my $query = q|
        SELECT COUNT(*) FROM issues
        LEFT JOIN items ON items.itemnumber = issues.itemnumber
        WHERE items.biblionumber = ?
        AND issues.borrowernumber = ?
    |;
    my $is_issued = $dbh->selectrow_array($query, {}, $biblionumber, $borrowernumber );
    return 1 if $is_issued;
    return;
}

=head2 IsItemIssued

  IsItemIssued( $itemnumber )

  Return 1 if the item is on loan, otherwise return 0

=cut

sub IsItemIssued {
    my $itemnumber = shift;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(q{
        SELECT COUNT(*)
        FROM issues
        WHERE itemnumber = ?
    });
    $sth->execute($itemnumber);
    return $sth->fetchrow;
}

=head2 GetAgeRestriction

  my ($ageRestriction, $daysToAgeRestriction) = GetAgeRestriction($record_restrictions, $borrower);
  my ($ageRestriction, $daysToAgeRestriction) = GetAgeRestriction($record_restrictions);

  if($daysToAgeRestriction <= 0) { #Borrower is allowed to access this material, as he is older or as old as the agerestriction }
  if($daysToAgeRestriction > 0) { #Borrower is this many days from meeting the agerestriction }

@PARAM1 the koha.biblioitems.agerestriction value, like K18, PEGI 13, ...
@PARAM2 a borrower-object with koha.borrowers.dateofbirth. (OPTIONAL)
@RETURNS The age restriction age in years and the days to fulfill the age restriction for the given borrower.
         Negative days mean the borrower has gone past the age restriction age.

=cut

sub GetAgeRestriction {
    my ($record_restrictions, $borrower) = @_;
    my $markers = C4::Context->preference('AgeRestrictionMarker');

    # Split $record_restrictions to something like FSK 16 or PEGI 6
    my @values = split ' ', uc($record_restrictions);
    return unless @values;

    # Search first occurrence of one of the markers
    my @markers = split /\|/, uc($markers);
    return unless @markers;

    my $index            = 0;
    my $restriction_year = 0;
    for my $value (@values) {
        $index++;
        for my $marker (@markers) {
            $marker =~ s/^\s+//;    #remove leading spaces
            $marker =~ s/\s+$//;    #remove trailing spaces
            if ( $marker eq $value ) {
                if ( $index <= $#values ) {
                    $restriction_year += $values[$index];
                }
                last;
            }
            elsif ( $value =~ /^\Q$marker\E(\d+)$/ ) {

                # Perhaps it is something like "K16" (as in Finland)
                $restriction_year += $1;
                last;
            }
        }
        last if ( $restriction_year > 0 );
    }

    #Check if the borrower is age restricted for this material and for how long.
    if ($restriction_year && $borrower) {
        if ( $borrower->{'dateofbirth'} ) {
            my @alloweddate = split /-/, $borrower->{'dateofbirth'};
            $alloweddate[0] += $restriction_year;

            #Prevent runime eror on leap year (invalid date)
            if ( ( $alloweddate[1] == 2 ) && ( $alloweddate[2] == 29 ) ) {
                $alloweddate[2] = 28;
            }

            #Get how many days the borrower has to reach the age restriction
            my $daysToAgeRestriction = Date_to_Days(@alloweddate) - Date_to_Days(Today);
            #Negative days means the borrower went past the age restriction age
            return ($restriction_year, $daysToAgeRestriction);
        }
    }

    return ($restriction_year);
}


=head2 GetPendingOnSiteCheckouts

=cut

sub GetPendingOnSiteCheckouts {
    my $dbh = C4::Context->dbh;
    return $dbh->selectall_arrayref(q|
        SELECT
          items.barcode,
          items.biblionumber,
          items.itemnumber,
          items.itemnotes,
          items.itemcallnumber,
          items.location,
          issues.date_due,
          issues.branchcode,
          issues.date_due < NOW() AS is_overdue,
          biblio.author,
          biblio.title,
          borrowers.firstname,
          borrowers.surname,
          borrowers.cardnumber,
          borrowers.borrowernumber
        FROM items
        LEFT JOIN issues ON items.itemnumber = issues.itemnumber
        LEFT JOIN biblio ON items.biblionumber = biblio.biblionumber
        LEFT JOIN borrowers ON issues.borrowernumber = borrowers.borrowernumber
        WHERE issues.onsite_checkout = 1
    |, { Slice => {} } );
}

sub GetTopIssues {
    my ($params) = @_;

    my ($count, $branch, $itemtype, $ccode, $newness)
        = @$params{qw(count branch itemtype ccode newness)};

    my $dbh = C4::Context->dbh;
    my $query = q{
        SELECT b.biblionumber, b.title, b.author, bi.itemtype, bi.publishercode,
          bi.place, bi.publicationyear, b.copyrightdate, bi.pages, bi.size,
          i.ccode, SUM(i.issues) AS count
        FROM biblio b
        LEFT JOIN items i ON (i.biblionumber = b.biblionumber)
        LEFT JOIN biblioitems bi ON (bi.biblionumber = b.biblionumber)
    };

    my (@where_strs, @where_args);

    if ($branch) {
        push @where_strs, 'i.homebranch = ?';
        push @where_args, $branch;
    }
    if ($itemtype) {
        if (C4::Context->preference('item-level_itypes')){
            push @where_strs, 'i.itype = ?';
            push @where_args, $itemtype;
        } else {
            push @where_strs, 'bi.itemtype = ?';
            push @where_args, $itemtype;
        }
    }
    if ($ccode) {
        push @where_strs, 'i.ccode = ?';
        push @where_args, $ccode;
    }
    if ($newness) {
        push @where_strs, 'TO_DAYS(NOW()) - TO_DAYS(b.datecreated) <= ?';
        push @where_args, $newness;
    }

    if (@where_strs) {
        $query .= 'WHERE ' . join(' AND ', @where_strs);
    }

    $query .= q{
        GROUP BY b.biblionumber
        HAVING count > 0
        ORDER BY count DESC
    };

    $count = int($count);
    if ($count > 0) {
        $query .= "LIMIT $count";
    }

    my $rows = $dbh->selectall_arrayref($query, { Slice => {} }, @where_args);

    return @$rows;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

