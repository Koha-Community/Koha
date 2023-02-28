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

use Modern::Perl;
use DateTime;
use POSIX qw( floor );
use YAML::XS;
use Encode;

use C4::Context;
use C4::Stats qw( UpdateStats );
use C4::Reserves qw( CheckReserves CanItemBeReserved MoveReserve ModReserve ModReserveMinusPriority RevertWaitingStatus IsItemOnHoldAndFound IsAvailableForItemLevelRequest ItemsAnyAvailableAndNotRestricted );
use C4::Biblio qw( UpdateTotalIssues );
use C4::Items qw( ModItemTransfer ModDateLastSeen CartToShelf );
use C4::Accounts;
use C4::ItemCirculationAlertPreference;
use C4::Message;
use C4::Log qw( logaction ); # logaction
use C4::Overdues;
use C4::RotatingCollections qw(GetCollectionItemBranches);
use Algorithm::CheckDigits qw( CheckDigits );

use Data::Dumper qw( Dumper );
use Koha::Account;
use Koha::AuthorisedValues;
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::Biblioitems;
use Koha::DateUtils qw( dt_from_string );
use Koha::Calendar;
use Koha::Checkouts;
use Koha::Illrequests;
use Koha::Items;
use Koha::Patrons;
use Koha::Patron::Debarments qw( DelUniqueDebarment AddUniqueDebarment );
use Koha::Database;
use Koha::Libraries;
use Koha::Account::Lines;
use Koha::Holds;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Config::SysPrefs;
use Koha::Charges::Fees;
use Koha::Config::SysPref;
use Koha::Checkouts::ReturnClaims;
use Koha::SearchEngine::Indexer;
use Koha::Exceptions::Checkout;
use Koha::Plugins;
use Koha::Recalls;
use Carp qw( carp );
use List::MoreUtils qw( any );
use Scalar::Util qw( looks_like_number blessed );
use Date::Calc qw( Date_to_Days );
our (@ISA, @EXPORT_OK);
BEGIN {

    require Exporter;
    @ISA = qw(Exporter);

    # FIXME subs that should probably be elsewhere
    push @EXPORT_OK, qw(
      barcodedecode
      LostItem
      ReturnLostItem
      GetPendingOnSiteCheckouts

      CanBookBeIssued
      checkHighHolds
      CanBookBeRenewed
      AddIssue
      GetLoanLength
      GetHardDueDate
      AddRenewal
      GetRenewCount
      GetSoonestRenewDate
      GetLatestAutoRenewDate
      GetIssuingCharges
      AddIssuingCharge
      GetBranchBorrowerCircRule
      GetBranchItemRule
      GetBiblioIssues
      GetUpcomingDueIssues
      CheckIfIssuedToPatron
      IsItemIssued
      GetAgeRestriction
      GetTopIssues

      AddReturn
      MarkIssueReturned

      transferbook
      TooMany
      GetTransfersFromTo
      updateWrongTransfer
      CalcDateDue
      CheckValidBarcode
      IsBranchTransferAllowed
      CreateBranchTransferLimit
      DeleteBranchTransferLimits
      TransferSlip

      GetOfflineOperations
      GetOfflineOperation
      AddOfflineOperation
      DeleteOfflineOperation
      ProcessOfflineOperation
      ProcessOfflinePayment
      ProcessOfflineIssue
    );
    push @EXPORT_OK, '_GetCircControlBranch';    # This is wrong!
}

=head1 NAME

C4::Circulation - Koha circulation module

=head1 SYNOPSIS

use C4::Circulation;

=head1 DESCRIPTION

The functions in this module deal with circulation, issues, and
returns, as well as general information about the library.
Also deals with inventory.

=head1 FUNCTIONS

=head2 barcodedecode

  $str = &barcodedecode($barcode, [$filter]);

Generic filter function for barcode string.
Called on every circ if the System Pref itemBarcodeInputFilter is set.
Will do some manipulation of the barcode for systems that deliver a barcode
to circulation.pl that differs from the barcode stored for the item.
For proper functioning of this filter, calling the function on the 
correct barcode string (items.barcode) should return an unaltered barcode.
Barcode is going to be automatically trimmed of leading/trailing whitespaces.

The optional $filter argument is to allow for testing or explicit 
behavior that ignores the System Pref.  Valid values are the same as the 
System Pref options.

=cut

# FIXME -- the &decode fcn below should be wrapped into this one.
# FIXME -- these plugins should be moved out of Circulation.pm
#
sub barcodedecode {
    my ($barcode, $filter) = @_;

    return unless defined $barcode;

    my $branch = C4::Context::mybranch();
    $barcode =~ s/^\s+|\s+$//g;
    $filter = C4::Context->preference('itemBarcodeInputFilter') unless $filter;
    Koha::Plugins->call('item_barcode_transform',  \$barcode );
    $filter or return $barcode;     # ensure filter is defined, else return untouched barcode
	if ($filter eq 'whitespace') {
		$barcode =~ s/\s//g;
	} elsif ($filter eq 'cuecat') {
		chomp($barcode);
	    my @fields = split( /\./, $barcode );
	    my @results = map( C4::Circulation::_decode($_), @fields[ 1 .. $#fields ] );
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

=head2 _decode

  $str = &_decode($chunk);

Decodes a segment of a string emitted by a CueCat barcode scanner and
returns it.

FIXME: Should be replaced with Barcode::Cuecat from CPAN
or Javascript based decoding on the client side.

=cut

sub _decode {
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

  ($dotransfer, $messages, $iteminformation) = &transferbook({
                                                   from_branch => $frombranch
                                                   to_branch => $tobranch,
                                                   barcode => $barcode,
                                                   ignore_reserves => $ignore_reserves,
                                                   trigger => $trigger
                                                });

Transfers an item to a new branch. If the item is currently on loan, it is automatically returned before the actual transfer.

C<$fbr> is the code for the branch initiating the transfer.
C<$tbr> is the code for the branch to which the item should be transferred.

C<$barcode> is the barcode of the item to be transferred.

If C<$ignore_reserves> is true, C<&transferbook> ignores reserves.
Otherwise, if an item is reserved, the transfer fails.

C<$trigger> is the enum value for what triggered the transfer.

Returns three values:

=over

=item $dotransfer 

is true if the transfer was successful.

=item $messages

is a reference-to-hash which may have any of the following keys:

=over

=item C<BadBarcode>

There is no item in the catalog with the given barcode. The value is C<$barcode>.

=item C<DestinationEqualsHolding>

The item is already at the branch to which it is being transferred. The transfer is nonetheless considered to have failed. The value should be ignored.

=item C<WasReturned>

The item was on loan, and C<&transferbook> automatically returned it before transferring it. The value is the borrower number of the patron who had the item.

=item C<ResFound>

The item was reserved. The value is a reference-to-hash whose keys are fields from the reserves table of the Koha database, and C<biblioitemnumber>. It also has the key C<ResFound>, whose value is either C<Waiting> or C<Reserved>.

=item C<WasTransferred>

The item was eligible to be transferred. Barring problems communicating with the database, the transfer should indeed have succeeded. The value should be ignored.

=item C<RecallPlacedAtHoldingBranch>

A recall for this item was found, and the transfer has already been completed as the item's branch matches the recall's pickup branch.

=item C<RecallFound>

A recall for this item was found, and the item needs to be transferred to the recall's pickup branch.

=back

=back

=cut

sub transferbook {
    my $params = shift;
    my $tbr      = $params->{to_branch};
    my $fbr      = $params->{from_branch};
    my $ignoreRs = $params->{ignore_reserves};
    my $barcode  = $params->{barcode};
    my $trigger  = $params->{trigger};
    my $messages;
    my $dotransfer      = 1;
    my $item = Koha::Items->find( { barcode => $barcode } );

    Koha::Exceptions::MissingParameter->throw(
        "Missing mandatory parameter: from_branch")
      unless $fbr;

    Koha::Exceptions::MissingParameter->throw(
        "Missing mandatory parameter: to_branch")
      unless $tbr;

    # bad barcode..
    unless ( $item ) {
        $messages->{'BadBarcode'} = $barcode;
        $dotransfer = 0;
        return ( $dotransfer, $messages );
    }

    my $itemnumber = $item->itemnumber;
    # get branches of book...
    my $hbr = $item->homebranch;

    # if using Branch Transfer Limits
    if ( C4::Context->preference("UseBranchTransferLimits") == 1 ) {
        my $code = C4::Context->preference("BranchTransferLimitsType") eq 'ccode' ? $item->ccode : $item->biblio->biblioitem->itemtype; # BranchTransferLimitsType is 'ccode' or 'itemtype'
        if ( C4::Context->preference("item-level_itypes") && C4::Context->preference("BranchTransferLimitsType") eq 'itemtype' ) {
            if ( ! IsBranchTransferAllowed( $tbr, $fbr, $item->itype ) ) {
                $messages->{'NotAllowed'} = $tbr . "::" . $item->itype;
                $dotransfer = 0;
            }
        } elsif ( ! IsBranchTransferAllowed( $tbr, $fbr, $code ) ) {
            $messages->{'NotAllowed'} = $tbr . "::" . $code;
            $dotransfer = 0;
        }
    }

    # can't transfer book if is already there....
    if ( $fbr eq $tbr ) {
        $messages->{'DestinationEqualsHolding'} = 1;
        $dotransfer = 0;
    }

    # check if it is still issued to someone, return it...
    my $issue = $item->checkout;
    if ( $issue ) {
        AddReturn( $barcode, $fbr );
        $messages->{'WasReturned'} = $issue->borrowernumber;
    }

    # find reserves.....
    # That'll save a database query.
    my ( $resfound, $resrec, undef ) =
      CheckReserves( $item );
    if ( $resfound ) {
        $resrec->{'ResFound'} = $resfound;
        $messages->{'ResFound'} = $resrec;
        $dotransfer = 0 unless $ignoreRs;
    }

    # find recall
    if ( C4::Context->preference('UseRecalls') ) {
        my $recall = Koha::Recalls->find({ item_id => $itemnumber, status => 'in_transit' });
        if ( defined $recall ) {
            # do a transfer if the recall branch is different to the item holding branch
            if ( $recall->pickup_library_id eq $fbr ) {
                $dotransfer = 0;
                $messages->{'RecallPlacedAtHoldingBranch'} = 1;
            } else {
                $dotransfer = 1;
                $messages->{'RecallFound'} = $recall;
            }
        }
    }

    #actually do the transfer....
    if ($dotransfer) {
        ModItemTransfer( $itemnumber, $fbr, $tbr, $trigger );

        # don't need to update MARC anymore, we do it in batch now
        $messages->{'WasTransfered'} = $tbr;

    }
    ModDateLastSeen( $itemnumber );
    return ( $dotransfer, $messages );
}


sub TooMany {
    my $borrower        = shift;
    my $item_object = shift;
    my $params = shift;
    my $onsite_checkout = $params->{onsite_checkout} || 0;
    my $switch_onsite_checkout = $params->{switch_onsite_checkout} || 0;
    my $cat_borrower    = $borrower->{'categorycode'};
    my $dbh             = C4::Context->dbh;
    # Get which branchcode we need
    my $branch = _GetCircControlBranch($item_object->unblessed,$borrower);
    my $type = $item_object->effective_itemtype;

    my ($type_object, $parent_type, $parent_maxissueqty_rule);
    $type_object = Koha::ItemTypes->find( $type );
    $parent_type = $type_object->parent_type if $type_object;
    my $child_types = Koha::ItemTypes->search({ parent_type => $type });
    # Find any children if we are a parent_type;

    # given branch, patron category, and item type, determine
    # applicable issuing rule

    $parent_maxissueqty_rule = Koha::CirculationRules->get_effective_rule(
        {
            categorycode => $cat_borrower,
            itemtype     => $parent_type,
            branchcode   => $branch,
            rule_name    => 'maxissueqty',
        }
    ) if $parent_type;
    # If the parent rule is for default type we discount it
    $parent_maxissueqty_rule = undef if $parent_maxissueqty_rule && !defined $parent_maxissueqty_rule->itemtype;

    my $maxissueqty_rule = Koha::CirculationRules->get_effective_rule(
        {
            categorycode => $cat_borrower,
            itemtype     => $type,
            branchcode   => $branch,
            rule_name    => 'maxissueqty',
        }
    );

    my $maxonsiteissueqty_rule = Koha::CirculationRules->get_effective_rule(
        {
            categorycode => $cat_borrower,
            itemtype     => $type,
            branchcode   => $branch,
            rule_name    => 'maxonsiteissueqty',
        }
    );


    my $patron = Koha::Patrons->find($borrower->{borrowernumber});
    # if a rule is found and has a loan limit set, count
    # how many loans the patron already has that meet that
    # rule
    if (defined($maxissueqty_rule) and $maxissueqty_rule->rule_value ne "") {

        my $checkouts;
        if ( $maxissueqty_rule->branchcode ) {
            if ( C4::Context->preference('CircControl') eq 'PickupLibrary' ) {
                $checkouts = $patron->checkouts->search(
                    { 'me.branchcode' => $maxissueqty_rule->branchcode } );
            } elsif (C4::Context->preference('CircControl') eq 'PatronLibrary') {
                $checkouts = $patron->checkouts; # if branch is the patron's home branch, then count all loans by patron
            } else {
                my $branch_type = C4::Context->preference('HomeOrHoldingBranch') || 'homebranch';
                $checkouts = $patron->checkouts->search(
                    { "item.$branch_type" => $maxissueqty_rule->branchcode } );
            }
        } else {
            $checkouts = $patron->checkouts; # if rule is not branch specific then count all loans by patron
        }
        $checkouts = $checkouts->search(undef, { prefetch => 'item' });

        my $sum_checkouts;
        my $rule_itemtype = $maxissueqty_rule->itemtype;

        my @types;
        unless ( $rule_itemtype ) {
            # matching rule has the default item type, so count only
            # those existing loans that don't fall under a more
            # specific rule
            @types = Koha::CirculationRules->search(
                {
                    branchcode => $maxissueqty_rule->branchcode,
                    categorycode => [ $maxissueqty_rule->categorycode, $cat_borrower ],
                    itemtype  => { '!=' => undef },
                    rule_name => 'maxissueqty'
                }
            )->get_column('itemtype');
        } else {
            if ( $parent_maxissueqty_rule ) {
                # if we have a parent item type then we count loans of the
                # specific item type or its siblings or parent
                my $children = Koha::ItemTypes->search({ parent_type => $parent_type });
                @types = $children->get_column('itemtype');
                push @types, $parent_type;
            } elsif ( $child_types ) {
                # If we are a parent type, we need to count all child types and our own type
                @types = $child_types->get_column('itemtype');
                push @types, $type; # And don't forget to count our own types
            } else {
                # Otherwise only count the specific itemtype
                push @types, $type;
            }
        }

        while ( my $c = $checkouts->next ) {
            my $itemtype = $c->item->effective_itemtype;

            unless ( $rule_itemtype ) {
                next if grep {$_ eq $itemtype} @types;
            } else {
                next unless grep {$_ eq $itemtype} @types;
            }

            $sum_checkouts->{total}++;
            $sum_checkouts->{onsite_checkouts}++ if $c->onsite_checkout;
            $sum_checkouts->{itemtype}->{$itemtype}++;
        }

        my $checkout_count_type = $sum_checkouts->{itemtype}->{$type} || 0;
        my $checkout_count = $sum_checkouts->{total} || 0;
        my $onsite_checkout_count = $sum_checkouts->{onsite_checkouts} || 0;

        my $checkout_rules = {
            checkout_count               => $checkout_count,
            onsite_checkout_count        => $onsite_checkout_count,
            onsite_checkout              => $onsite_checkout,
            max_checkouts_allowed        => $maxissueqty_rule ? $maxissueqty_rule->rule_value : undef,
            max_onsite_checkouts_allowed => $maxonsiteissueqty_rule ? $maxonsiteissueqty_rule->rule_value : undef,
            switch_onsite_checkout       => $switch_onsite_checkout,
        };
        # If parent rules exists
        if ( defined($parent_maxissueqty_rule) and defined($parent_maxissueqty_rule->rule_value) ){
            $checkout_rules->{max_checkouts_allowed} = $parent_maxissueqty_rule ? $parent_maxissueqty_rule->rule_value : undef;
            my $qty_over = _check_max_qty($checkout_rules);
            return $qty_over if defined $qty_over;

            # If the parent rule is less than or equal to the child, we only need check the parent
            if( $maxissueqty_rule->rule_value < $parent_maxissueqty_rule->rule_value && defined($maxissueqty_rule->itemtype) ) {
                $checkout_rules->{checkout_count} = $checkout_count_type;
                $checkout_rules->{max_checkouts_allowed} = $maxissueqty_rule ? $maxissueqty_rule->rule_value : undef;
                my $qty_over = _check_max_qty($checkout_rules);
                return $qty_over if defined $qty_over;
            }
        } else {
            my $qty_over = _check_max_qty($checkout_rules);
            return $qty_over if defined $qty_over;
        }
    }

    # Now count total loans against the limit for the branch
    my $branch_borrower_circ_rule = GetBranchBorrowerCircRule($branch, $cat_borrower);
    if (defined($branch_borrower_circ_rule->{patron_maxissueqty}) and $branch_borrower_circ_rule->{patron_maxissueqty} ne '') {
        my $checkouts;
        if ( C4::Context->preference('CircControl') eq 'PickupLibrary' ) {
            $checkouts = $patron->checkouts->search(
                { 'me.branchcode' => $branch} );
        } elsif (C4::Context->preference('CircControl') eq 'PatronLibrary') {
            $checkouts = $patron->checkouts; # if branch is the patron's home branch, then count all loans by patron
        } else {
            my $branch_type = C4::Context->preference('HomeOrHoldingBranch') || 'homebranch';
            $checkouts = $patron->checkouts->search(
                { "item.$branch_type" => $branch},
                { prefetch            => 'item' } );
        }

        my $checkout_count = $checkouts->count;
        my $onsite_checkout_count = $checkouts->search({ onsite_checkout => 1 })->count;
        my $max_checkouts_allowed = $branch_borrower_circ_rule->{patron_maxissueqty};
        my $max_onsite_checkouts_allowed = $branch_borrower_circ_rule->{patron_maxonsiteissueqty} || undef;

        my $qty_over = _check_max_qty(
            {
                checkout_count               => $checkout_count,
                onsite_checkout_count        => $onsite_checkout_count,
                onsite_checkout              => $onsite_checkout,
                max_checkouts_allowed        => $max_checkouts_allowed,
                max_onsite_checkouts_allowed => $max_onsite_checkouts_allowed,
                switch_onsite_checkout       => $switch_onsite_checkout
            }
        );
        return $qty_over if defined $qty_over;
    }

    if ( not defined( $maxissueqty_rule ) and not defined($branch_borrower_circ_rule->{patron_maxissueqty}) ) {
        return { reason => 'NO_RULE_DEFINED', max_allowed => 0 };
    }

    # OK, the patron can issue !!!
    return;
}

sub _check_max_qty {
    my $params                       = shift;
    my $checkout_count               = $params->{checkout_count};
    my $onsite_checkout_count        = $params->{onsite_checkout_count};
    my $onsite_checkout              = $params->{onsite_checkout};
    my $max_checkouts_allowed        = $params->{max_checkouts_allowed};
    my $max_onsite_checkouts_allowed = $params->{max_onsite_checkouts_allowed};
    my $switch_onsite_checkout       = $params->{switch_onsite_checkout};

    if ( $onsite_checkout and defined $max_onsite_checkouts_allowed ) {
        if ( $max_onsite_checkouts_allowed eq '' ) { return; }
        if ( $onsite_checkout_count >= $max_onsite_checkouts_allowed ) {
            return {
                reason      => 'TOO_MANY_ONSITE_CHECKOUTS',
                count       => $onsite_checkout_count,
                max_allowed => $max_onsite_checkouts_allowed,
            };
        }
    }
    if ( C4::Context->preference('ConsiderOnSiteCheckoutsAsNormalCheckouts') ) {
        if ( $max_checkouts_allowed eq '' ) { return; }
        my $delta = $switch_onsite_checkout ? 1 : 0;
        if ( $checkout_count >= $max_checkouts_allowed + $delta ) {
            return {
                reason      => 'TOO_MANY_CHECKOUTS',
                count       => $checkout_count,
                max_allowed => $max_checkouts_allowed,
            };
        }
    }
    elsif ( not $onsite_checkout ) {
        if ( $max_checkouts_allowed eq '' ) { return; }
        if (
            $checkout_count - $onsite_checkout_count >= $max_checkouts_allowed )
        {
            return {
                reason      => 'TOO_MANY_CHECKOUTS',
                count       => $checkout_count - $onsite_checkout_count,
                max_allowed => $max_checkouts_allowed,
            };
        }
    }

    return;
}

=head2 CanBookBeIssued

  ( $issuingimpossible, $needsconfirmation, [ $alerts ] ) =  CanBookBeIssued( $patron,
                      $barcode, $duedate, $inprocess, $ignore_reserves, $params );

Check if a book can be issued.

C<$issuingimpossible> and C<$needsconfirmation> are hashrefs.

IMPORTANT: The assumption by users of this routine is that causes blocking
the issue are keyed by uppercase labels and other returned
data is keyed in lower case!

=over 4

=item C<$patron> is a Koha::Patron

=item C<$barcode> is the bar code of the book being issued.

=item C<$duedates> is a DateTime object.

=item C<$inprocess> boolean switch

=item C<$ignore_reserves> boolean switch

=item C<$params> Hashref of additional parameters

Available keys:
    override_high_holds - Ignore high holds
    onsite_checkout     - Checkout is an onsite checkout that will not leave the library

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

=head3 TRANSFERRED

reserved and being transferred for someone else.

=head3 INVALID_DATE

sticky due date is invalid or due date in the past

=head3 TOO_MANY

if the borrower borrows to much things

=head3 RECALLED

recalled by someone else

=cut

sub CanBookBeIssued {
    my ( $patron, $barcode, $duedate, $inprocess, $ignore_reserves, $params ) = @_;
    my %needsconfirmation;    # filled with problems that needs confirmations
    my %issuingimpossible;    # filled with problems that causes the issue to be IMPOSSIBLE
    my %alerts;               # filled with messages that shouldn't stop issuing, but the librarian should be aware of.
    my %messages;             # filled with information messages that should be displayed.

    my $onsite_checkout     = $params->{onsite_checkout}     || 0;
    my $override_high_holds = $params->{override_high_holds} || 0;

    my $item_object = Koha::Items->find({barcode => $barcode });

    # MANDATORY CHECKS - unless item exists, nothing else matters
    unless ( $item_object ) {
        $issuingimpossible{UNKNOWN_BARCODE} = 1;
    }
    return ( \%issuingimpossible, \%needsconfirmation ) if %issuingimpossible;

    my $item_unblessed = $item_object->unblessed; # Transition...
    my $issue = $item_object->checkout;
    my $biblio = $item_object->biblio;

    my $biblioitem = $biblio->biblioitem;
    my $effective_itemtype = $item_object->effective_itemtype;
    my $dbh             = C4::Context->dbh;
    my $patron_unblessed = $patron->unblessed;

    my $circ_library = Koha::Libraries->find( _GetCircControlBranch($item_unblessed, $patron_unblessed) );

    my $now = dt_from_string();
    $duedate ||= CalcDateDue( $now, $effective_itemtype, $circ_library->branchcode, $patron_unblessed );
    if (DateTime->compare($duedate,$now) == -1 ) { # duedate cannot be before now
         $needsconfirmation{INVALID_DATE} = $duedate;
    }

    my $fees = Koha::Charges::Fees->new(
        {
            patron    => $patron,
            library   => $circ_library,
            item      => $item_object,
            to_date   => $duedate,
        }
    );

    #
    # BORROWER STATUS
    #
    if ( $patron->category->category_type eq 'X' && (  $item_object->barcode  )) {
    	# stats only borrower -- add entry to statistics table, and return issuingimpossible{STATS} = 1  .
        C4::Stats::UpdateStats(
            {
                branch         => C4::Context->userenv->{'branch'},
                type           => 'localuse',
                itemnumber     => $item_object->itemnumber,
                itemtype       => $effective_itemtype,
                borrowernumber => $patron->borrowernumber,
                ccode          => $item_object->ccode,
                categorycode   => $patron->categorycode,
                location       => $item_object->location,
                interface      => C4::Context->interface,
            }
        );
        ModDateLastSeen( $item_object->itemnumber ); # FIXME Move to Koha::Item
        return( { STATS => 1 }, {});
    }

    if ( $patron->gonenoaddress && $patron->gonenoaddress == 1 ) {
        $issuingimpossible{GNA} = 1;
    }

    if ( $patron->lost && $patron->lost == 1 ) {
        $issuingimpossible{CARD_LOST} = 1;
    }
    if ( $patron->is_debarred ) {
        $issuingimpossible{DEBARRED} = 1;
    }

    if ( $patron->is_expired ) {
        $issuingimpossible{EXPIRED} = 1;
    }

    #
    # BORROWER STATUS
    #

    # DEBTS
    my $account = $patron->account;
    my $balance = $account->balance;
    my $non_issues_charges = $account->non_issues_charges;
    my $other_charges = $balance - $non_issues_charges;

    my $amountlimit = C4::Context->preference("noissuescharge");
    my $allowfineoverride = C4::Context->preference("AllowFineOverride");
    my $allfinesneedoverride = C4::Context->preference("AllFinesNeedOverride");

    # Check the debt of this patrons guarantees
    my $no_issues_charge_guarantees = C4::Context->preference("NoIssuesChargeGuarantees");
    $no_issues_charge_guarantees = undef unless looks_like_number( $no_issues_charge_guarantees );
    if ( defined $no_issues_charge_guarantees ) {
        my @guarantees = map { $_->guarantee } $patron->guarantee_relationships->as_list;
        my $guarantees_non_issues_charges = 0;
        foreach my $g ( @guarantees ) {
            $guarantees_non_issues_charges += $g->account->non_issues_charges;
        }

        if ( $guarantees_non_issues_charges > $no_issues_charge_guarantees && !$inprocess && !$allowfineoverride) {
            $issuingimpossible{DEBT_GUARANTEES} = $guarantees_non_issues_charges;
        } elsif ( $guarantees_non_issues_charges > $no_issues_charge_guarantees && !$inprocess && $allowfineoverride) {
            $needsconfirmation{DEBT_GUARANTEES} = $guarantees_non_issues_charges;
        } elsif ( $allfinesneedoverride && $guarantees_non_issues_charges > 0 && $guarantees_non_issues_charges <= $no_issues_charge_guarantees && !$inprocess ) {
            $needsconfirmation{DEBT_GUARANTEES} = $guarantees_non_issues_charges;
        }
    }

    # Check the debt of this patrons guarantors *and* the guarantees of those guarantors
    my $no_issues_charge_guarantors = C4::Context->preference("NoIssuesChargeGuarantorsWithGuarantees");
    $no_issues_charge_guarantors = undef unless looks_like_number( $no_issues_charge_guarantors );
    if ( defined $no_issues_charge_guarantors ) {
        my $guarantors_non_issues_charges = $patron->relationships_debt({ include_guarantors => 1, only_this_guarantor => 0, include_this_patron => 1 });

        if ( $guarantors_non_issues_charges > $no_issues_charge_guarantors && !$inprocess && !$allowfineoverride) {
            $issuingimpossible{DEBT_GUARANTORS} = $guarantors_non_issues_charges;
        } elsif ( $guarantors_non_issues_charges > $no_issues_charge_guarantors && !$inprocess && $allowfineoverride) {
            $needsconfirmation{DEBT_GUARANTORS} = $guarantors_non_issues_charges;
        } elsif ( $allfinesneedoverride && $guarantors_non_issues_charges > 0 && $guarantors_non_issues_charges <= $no_issues_charge_guarantors && !$inprocess ) {
            $needsconfirmation{DEBT_GUARANTORS} = $guarantors_non_issues_charges;
        }
    }

    if ( C4::Context->preference("IssuingInProcess") ) {
        if ( $non_issues_charges > $amountlimit && !$inprocess && !$allowfineoverride) {
            $issuingimpossible{DEBT} = $non_issues_charges;
        } elsif ( $non_issues_charges > $amountlimit && !$inprocess && $allowfineoverride) {
            $needsconfirmation{DEBT} = $non_issues_charges;
        } elsif ( $allfinesneedoverride && $non_issues_charges > 0 && $non_issues_charges <= $amountlimit && !$inprocess ) {
            $needsconfirmation{DEBT} = $non_issues_charges;
        }
    }
    else {
        if ( $non_issues_charges > $amountlimit && $allowfineoverride ) {
            $needsconfirmation{DEBT} = $non_issues_charges;
        } elsif ( $non_issues_charges > $amountlimit && !$allowfineoverride) {
            $issuingimpossible{DEBT} = $non_issues_charges;
        } elsif ( $non_issues_charges > 0 && $allfinesneedoverride ) {
            $needsconfirmation{DEBT} = $non_issues_charges;
        }
    }

    if ($balance > 0 && $other_charges > 0) {
        $alerts{OTHER_CHARGES} = sprintf( "%.2f", $other_charges );
    }

    $patron = Koha::Patrons->find( $patron->borrowernumber ); # FIXME Refetch just in case, to avoid regressions. But must not be needed
    $patron_unblessed = $patron->unblessed;

    if ( my $debarred_date = $patron->is_debarred ) {
         # patron has accrued fine days or has a restriction. $count is a date
        if ($debarred_date eq '9999-12-31') {
            $issuingimpossible{USERBLOCKEDNOENDDATE} = $debarred_date;
        }
        else {
            $issuingimpossible{USERBLOCKEDWITHENDDATE} = $debarred_date;
        }
    } elsif ( my $num_overdues = $patron->has_overdues ) {
        ## patron has outstanding overdue loans
        if ( C4::Context->preference("OverduesBlockCirc") eq 'block'){
            $issuingimpossible{USERBLOCKEDOVERDUE} = $num_overdues;
        }
        elsif ( C4::Context->preference("OverduesBlockCirc") eq 'confirmation'){
            $needsconfirmation{USERBLOCKEDOVERDUE} = $num_overdues;
        }
    }

    # Additional Materials Check
    if ( C4::Context->preference("CircConfirmItemParts")
        && $item_object->materials )
    {
        $needsconfirmation{ADDITIONAL_MATERIALS} = $item_object->materials;
    }

    #
    # CHECK IF BOOK ALREADY ISSUED TO THIS BORROWER
    #
    if ( $issue && $issue->borrowernumber eq $patron->borrowernumber ){

        # Already issued to current borrower.
        # If it is an on-site checkout if it can be switched to a normal checkout
        # or ask whether the loan should be renewed

        if ( $issue->onsite_checkout
                and C4::Context->preference('SwitchOnSiteCheckouts') ) {
            $messages{ONSITE_CHECKOUT_WILL_BE_SWITCHED} = 1;
        } else {
            my ($CanBookBeRenewed,$renewerror) = CanBookBeRenewed($patron, $issue);
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
    }
    elsif ( $issue ) {

        # issued to someone else

        my $patron = Koha::Patrons->find( $issue->borrowernumber );

        my ( $can_be_returned, $message ) = CanBookBeReturned( $item_unblessed, C4::Context->userenv->{branch} );

        if ( !$can_be_returned ) {
            $issuingimpossible{RETURN_IMPOSSIBLE} = 1;
            $issuingimpossible{branch_to_return} = $message;
        } else {
            if ( C4::Context->preference('AutoReturnCheckedOutItems') ) {
                $alerts{RETURNED_FROM_ANOTHER} = { patron => $patron };
            }
            else {
                $needsconfirmation{ISSUED_TO_ANOTHER} = 1;
                $needsconfirmation{issued_firstname} = $patron->firstname;
                $needsconfirmation{issued_surname} = $patron->surname;
                $needsconfirmation{issued_cardnumber} = $patron->cardnumber;
                $needsconfirmation{issued_borrowernumber} = $patron->borrowernumber;
            }
        }
    }

    # JB34 CHECKS IF BORROWERS DON'T HAVE ISSUE TOO MANY BOOKS
    #
    my $switch_onsite_checkout = (
          C4::Context->preference('SwitchOnSiteCheckouts')
      and $issue
      and $issue->onsite_checkout
      and $issue->borrowernumber == $patron->borrowernumber ? 1 : 0 );
    my $toomany = TooMany( $patron_unblessed, $item_object, { onsite_checkout => $onsite_checkout, switch_onsite_checkout => $switch_onsite_checkout, } );
    # if TooMany max_allowed returns 0 the user doesn't have permission to check out this book
    if ( $toomany && not exists $needsconfirmation{RENEW_ISSUE} ) {
        if ( $toomany->{max_allowed} == 0 ) {
            $needsconfirmation{PATRON_CANT} = 1;
        }
        if ( C4::Context->preference("AllowTooManyOverride") ) {
            $needsconfirmation{TOO_MANY} = $toomany->{reason};
            $needsconfirmation{current_loan_count} = $toomany->{count};
            $needsconfirmation{max_loans_allowed} = $toomany->{max_allowed};
        } else {
            $issuingimpossible{TOO_MANY} = $toomany->{reason};
            $issuingimpossible{current_loan_count} = $toomany->{count};
            $issuingimpossible{max_loans_allowed} = $toomany->{max_allowed};
        }
    }

    #
    # CHECKPREVCHECKOUT: CHECK IF ITEM HAS EVER BEEN LENT TO PATRON
    #
    $patron = Koha::Patrons->find( $patron->borrowernumber ); # FIXME Refetch just in case, to avoid regressions. But must not be needed
    if ( $patron->wants_check_for_previous_checkout && $patron->do_check_for_previous_checkout($item_unblessed) ) {
        $needsconfirmation{PREVISSUE} = 1;
    }

    #
    # ITEM CHECKING
    #
    if ( $item_object->notforloan )
    {
        if(!C4::Context->preference("AllowNotForLoanOverride")){
            $issuingimpossible{NOT_FOR_LOAN} = 1;
            $issuingimpossible{item_notforloan} = $item_object->notforloan;
        }else{
            $needsconfirmation{NOT_FOR_LOAN_FORCING} = 1;
            $needsconfirmation{item_notforloan} = $item_object->notforloan;
        }
    }
    else {
        # we have to check itemtypes.notforloan also
        if (C4::Context->preference('item-level_itypes')){
            # this should probably be a subroutine
            my $sth = $dbh->prepare("SELECT notforloan FROM itemtypes WHERE itemtype = ?");
            $sth->execute($effective_itemtype);
            my $notforloan=$sth->fetchrow_hashref();
            if ($notforloan->{'notforloan'}) {
                if (!C4::Context->preference("AllowNotForLoanOverride")) {
                    $issuingimpossible{NOT_FOR_LOAN} = 1;
                    $issuingimpossible{itemtype_notforloan} = $effective_itemtype;
                } else {
                    $needsconfirmation{NOT_FOR_LOAN_FORCING} = 1;
                    $needsconfirmation{itemtype_notforloan} = $effective_itemtype;
                }
            }
        }
        else {
            my $itemtype = Koha::ItemTypes->find($biblioitem->itemtype);
            if ( $itemtype && defined $itemtype->notforloan && $itemtype->notforloan == 1){
                if (!C4::Context->preference("AllowNotForLoanOverride")) {
                    $issuingimpossible{NOT_FOR_LOAN} = 1;
                    $issuingimpossible{itemtype_notforloan} = $effective_itemtype;
                } else {
                    $needsconfirmation{NOT_FOR_LOAN_FORCING} = 1;
                    $needsconfirmation{itemtype_notforloan} = $effective_itemtype;
                }
            }
        }
    }
    if ( $item_object->withdrawn && $item_object->withdrawn > 0 )
    {
        $issuingimpossible{WTHDRAWN} = 1;
    }
    if (   $item_object->restricted
        && $item_object->restricted == 1 )
    {
        $issuingimpossible{RESTRICTED} = 1;
    }
    if ( $item_object->itemlost && C4::Context->preference("IssueLostItem") ne 'nothing' ) {
        my $av = Koha::AuthorisedValues->search({ category => 'LOST', authorised_value => $item_object->itemlost });
        my $code = $av->count ? $av->next->lib : '';
        $needsconfirmation{ITEM_LOST} = $code if ( C4::Context->preference("IssueLostItem") eq 'confirm' );
        $alerts{ITEM_LOST} = $code if ( C4::Context->preference("IssueLostItem") eq 'alert' );
    }
    if ( C4::Context->preference("IndependentBranches") ) {
        my $userenv = C4::Context->userenv;
        unless ( C4::Context->IsSuperLibrarian() ) {
            my $HomeOrHoldingBranch = C4::Context->preference("HomeOrHoldingBranch");
            if ( $item_object->$HomeOrHoldingBranch ne $userenv->{branch} ){
                $issuingimpossible{ITEMNOTSAMEBRANCH} = 1;
                $issuingimpossible{'itemhomebranch'} = $item_object->$HomeOrHoldingBranch;
            }
            $needsconfirmation{BORRNOTSAMEBRANCH} = $patron->branchcode
              if ( $patron->branchcode ne $userenv->{branch} );
        }
    }

    #
    # CHECK IF THERE IS RENTAL CHARGES. RENTAL MUST BE CONFIRMED BY THE BORROWER
    #
    my $rentalConfirmation = C4::Context->preference("RentalFeesCheckoutConfirmation");
    if ($rentalConfirmation) {
        my ($rentalCharge) = GetIssuingCharges( $item_object->itemnumber, $patron->borrowernumber );

        my $itemtype_object = Koha::ItemTypes->find( $item_object->effective_itemtype );
        if ($itemtype_object) {
            my $accumulate_charge = $fees->accumulate_rentalcharge();
            if ( $accumulate_charge > 0 ) {
                $rentalCharge += $accumulate_charge;
            }
        }

        if ( $rentalCharge > 0 ) {
            $needsconfirmation{RENTALCHARGE} = $rentalCharge;
        }
    }

    my $recall;
    # CHECK IF ITEM HAS BEEN RECALLED BY ANOTHER PATRON
    # Only bother doing this if UseRecalls is enabled and the item is recallable
    # Don't look at recalls that are in transit
    if ( C4::Context->preference('UseRecalls') and $item_object->can_be_waiting_recall ) {
        my @recalls = $biblio->recalls({},{ order_by => { -asc => 'created_date' } })->filter_by_current->as_list;

        foreach my $r ( @recalls ) {
            if ( $r->item_id and
                $r->item_id == $item_object->itemnumber and
                $r->patron_id == $patron->borrowernumber and
                ( $r->waiting or $r->requested ) ) {
                $messages{RECALLED} = $r->id;
                $recall = $r;
                # this item is recalled by or already waiting for this borrower and the recall can be fulfilled
                last;
            }
            elsif ( $r->item_id and
                $r->item_id == $item_object->itemnumber and
                $r->in_transit ) {
                # recalled item is in transit
                $issuingimpossible{RECALLED_INTRANSIT} = $r->pickup_library_id;
            }
            elsif ( $r->item_level and
                $r->item_id == $item_object->itemnumber and
                $r->patron_id != $patron->borrowernumber and
                !$r->in_transit ) {
                # this specific item has been recalled by a different patron
                $needsconfirmation{RECALLED} = $r;
                $recall = $r;
                last;
            }
            elsif ( !$r->item_level and
                $r->patron_id != $patron->borrowernumber and
                !$r->in_transit ) {
                # a different patron has placed a biblio-level recall and this item is eligible to fill it
                $needsconfirmation{RECALLED} = $r;
                $recall = $r;
                last;
            }
        }
    }

    unless ( $ignore_reserves and defined $recall ) {
        # See if the item is on reserve.
        my ( $restype, $res ) = CheckReserves( $item_object );
        if ($restype) {
            my $resbor = $res->{'borrowernumber'};
            if ( $resbor ne $patron->borrowernumber ) {
                my $patron = Koha::Patrons->find( $resbor );
                if ( $restype eq "Waiting" )
                {
                    # The item is on reserve and waiting, but has been
                    # reserved by some other patron.
                    $needsconfirmation{RESERVE_WAITING} = 1;
                    $needsconfirmation{'resfirstname'} = $patron->firstname;
                    $needsconfirmation{'ressurname'} = $patron->surname;
                    $needsconfirmation{'rescardnumber'} = $patron->cardnumber;
                    $needsconfirmation{'resborrowernumber'} = $patron->borrowernumber;
                    $needsconfirmation{'resbranchcode'} = $res->{branchcode};
                    $needsconfirmation{'reswaitingdate'} = $res->{'waitingdate'};
                    $needsconfirmation{'reserve_id'} = $res->{reserve_id};
                }
                elsif ( $restype eq "Reserved" ) {
                    # The item is on reserve for someone else.
                    $needsconfirmation{RESERVED} = 1;
                    $needsconfirmation{'resfirstname'} = $patron->firstname;
                    $needsconfirmation{'ressurname'} = $patron->surname;
                    $needsconfirmation{'rescardnumber'} = $patron->cardnumber;
                    $needsconfirmation{'resborrowernumber'} = $patron->borrowernumber;
                    $needsconfirmation{'resbranchcode'} = $res->{branchcode};
                    $needsconfirmation{'resreservedate'} = $res->{reservedate};
                    $needsconfirmation{'reserve_id'} = $res->{reserve_id};
                }
                elsif ( $restype eq "Transferred" ) {
                    # The item is determined hold being transferred for someone else.
                    $needsconfirmation{TRANSFERRED} = 1;
                    $needsconfirmation{'resfirstname'} = $patron->firstname;
                    $needsconfirmation{'ressurname'} = $patron->surname;
                    $needsconfirmation{'rescardnumber'} = $patron->cardnumber;
                    $needsconfirmation{'resborrowernumber'} = $patron->borrowernumber;
                    $needsconfirmation{'resbranchcode'} = $res->{branchcode};
                    $needsconfirmation{'resreservedate'} = $res->{reservedate};
                    $needsconfirmation{'reserve_id'} = $res->{reserve_id};
                }
                elsif ( $restype eq "Processing" ) {
                    # The item is determined hold being processed for someone else.
                    $needsconfirmation{PROCESSING} = 1;
                    $needsconfirmation{'resfirstname'} = $patron->firstname;
                    $needsconfirmation{'ressurname'} = $patron->surname;
                    $needsconfirmation{'rescardnumber'} = $patron->cardnumber;
                    $needsconfirmation{'resborrowernumber'} = $patron->borrowernumber;
                    $needsconfirmation{'resbranchcode'} = $res->{branchcode};
                    $needsconfirmation{'resreservedate'} = $res->{reservedate};
                    $needsconfirmation{'reserve_id'} = $res->{reserve_id};
                }
            }
        }
    }

    ## CHECK AGE RESTRICTION
    my $agerestriction  = $biblioitem->agerestriction;
    my ($restriction_age, $daysToAgeRestriction) = GetAgeRestriction( $agerestriction, $patron->unblessed );
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
        my $check = checkHighHolds( $item_object, $patron );

        if ( $check->{exceeded} ) {
            my $highholds = {
                num_holds  => $check->{outstanding},
                duration   => $check->{duration},
                returndate => $check->{due_date},
            };
            if ($override_high_holds) {
                $alerts{HIGHHOLDS} = $highholds;
            }
            else {
                $needsconfirmation{HIGHHOLDS} = $highholds;
            }
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
        my $biblionumber = $item_object->biblionumber;
        require C4::Serials;
        my $is_a_subscription = C4::Serials::CountSubscriptionFromBiblionumber($biblionumber);
        unless ($is_a_subscription) {
            # FIXME Should be $patron->checkouts($args);
            my $checkouts = Koha::Checkouts->search(
                {
                    borrowernumber => $patron->borrowernumber,
                    biblionumber   => $biblionumber,
                },
                {
                    join => 'item',
                }
            );
            # if we get here, we don't already have a loan on this item,
            # so if there are any loans on this bib, ask for confirmation
            if ( $checkouts->count ) {
                $needsconfirmation{BIBLIO_ALREADY_ISSUED} = 1;
            }
        }
    }

    return ( \%issuingimpossible, \%needsconfirmation, \%alerts, \%messages, );
}

=head2 CanBookBeReturned

  ($returnallowed, $message) = CanBookBeReturned($item, $branch)

Check whether the item can be returned to the provided branch

=over 4

=item C<$item> is a hash of item information as returned Koha::Items->find->unblessed (Temporary, should be a Koha::Item instead)

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
    my ( $item, $patron ) = @_;
    my $branchcode = _GetCircControlBranch( $item->unblessed, $patron->unblessed );

    my $return_data = {
        exceeded    => 0,
        outstanding => 0,
        duration    => 0,
        due_date    => undef,
    };


    # Count holds on this record, ignoring the borrowers own holds as they would be filled by the checkout
    my $holds = Koha::Holds->search({
        biblionumber => $item->biblionumber,
        borrowernumber => { '!=' => $patron->borrowernumber }
    });

    if ( $holds->count() ) {
        $return_data->{outstanding} = $holds->count();

        my $decreaseLoanHighHoldsControl        = C4::Context->preference('decreaseLoanHighHoldsControl');
        my $decreaseLoanHighHoldsValue          = C4::Context->preference('decreaseLoanHighHoldsValue');
        my $decreaseLoanHighHoldsIgnoreStatuses = C4::Context->preference('decreaseLoanHighHoldsIgnoreStatuses');

        my @decreaseLoanHighHoldsIgnoreStatuses = split( /,/, $decreaseLoanHighHoldsIgnoreStatuses );

        if ( $decreaseLoanHighHoldsControl eq 'static' ) {

            # static means just more than a given number of holds on the record

            # If the number of holds is not above the threshold, we can stop here
            if ( $holds->count() <= $decreaseLoanHighHoldsValue ) {
                return $return_data;
            }
        }
        elsif ( $decreaseLoanHighHoldsControl eq 'dynamic' ) {

            # dynamic means X more than the number of holdable items on the record

            # let's get the items
            my @items = $holds->next()->biblio()->items()->as_list;

            # Remove any items with status defined to be ignored even if the would not make item unholdable
            foreach my $status (@decreaseLoanHighHoldsIgnoreStatuses) {
                @items = grep { !$_->$status } @items;
            }

            # Remove any items that are not holdable for this patron
            # We need to ignore hold counts as the borrower's own hold that will be filled by the checkout
            # could prevent them from placing further holds
            @items = grep { CanItemBeReserved( $patron, $_, undef, { ignore_hold_counts => 1 } )->{status} eq 'OK' } @items;

            my $items_count = scalar @items;

            my $threshold = $items_count + $decreaseLoanHighHoldsValue;

            # If the number of holds is less than the count of items we have
            # plus the number of holds allowed above that count, we can stop here
            if ( $holds->count() <= $threshold ) {
                return $return_data;
            }
        }

        my $issuedate = dt_from_string();

        my $itype = $item->effective_itemtype;
        my $daysmode = Koha::CirculationRules->get_effective_daysmode(
            {
                categorycode => $patron->categorycode,
                itemtype     => $itype,
                branchcode   => $branchcode,
            }
        );
        my $calendar = Koha::Calendar->new( branchcode => $branchcode, days_mode => $daysmode );

        my $orig_due = C4::Circulation::CalcDateDue( $issuedate, $itype, $branchcode, $patron->unblessed );

        my $rule = Koha::CirculationRules->get_effective_rule_value(
            {
                categorycode => $patron->categorycode,
                itemtype     => $item->effective_itemtype,
                branchcode   => $branchcode,
                rule_name    => 'decreaseloanholds',
            }
        );

        my $duration;
        if ( defined($rule) && $rule ne '' ){
            # overrides decreaseLoanHighHoldsDuration syspref
            $duration = $rule;
        } else {
            $duration = C4::Context->preference('decreaseLoanHighHoldsDuration');
        }
        my $reduced_datedue = $calendar->addDuration( $issuedate, $duration );
        $reduced_datedue->set_hour($orig_due->hour);
        $reduced_datedue->set_minute($orig_due->minute);
        $reduced_datedue->truncate( to => 'minute' );

        if ( DateTime->compare( $reduced_datedue, $orig_due ) == -1 ) {
            $return_data->{exceeded} = 1;
            $return_data->{duration} = $duration;
            $return_data->{due_date} = $reduced_datedue;
        }
    }

    return $return_data;
}

=head2 AddIssue

  &AddIssue($borrower, $barcode, [$datedue], [$cancelreserve], [$issuedate])

Issue a book. Does no check, they are done in CanBookBeIssued. If we reach this sub, it means the user confirmed if needed.

=over 4

=item C<$borrower> is a hash with borrower informations (from Koha::Patron->unblessed).

=item C<$barcode> is the barcode of the item being issued.

=item C<$datedue> is a DateTime object for the max date of return, i.e. the date due (optional).
Calculated if empty.

=item C<$cancelreserve> is 1 to override and cancel any pending reserves for the item (optional).

=item C<$issuedate> is a DateTime object for the date to issue the item (optional).
Defaults to today.

AddIssue does the following things :

  - step 01: check that there is a borrowernumber & a barcode provided
  - check for RENEWAL (book issued & being issued to the same patron)
      - renewal YES = Calculate Charge & renew
      - renewal NO  =
          * BOOK ACTUALLY ISSUED ? do a return if book is actually issued (but to someone else)
          * RESERVE PLACED ?
              - fill reserve if reserve to this patron
              - cancel reserve or not, otherwise
          * RECALL PLACED ?
              - fill recall if recall to this patron
              - cancel recall or not
              - revert recall's waiting status or not
          * TRANSFERT PENDING ?
              - complete the transfert
          * ISSUE THE BOOK

=back

=cut

sub AddIssue {
    my ( $borrower, $barcode, $datedue, $cancelreserve, $issuedate, $sipmode, $params ) = @_;

    my $onsite_checkout = $params && $params->{onsite_checkout} ? 1 : 0;
    my $switch_onsite_checkout = $params && $params->{switch_onsite_checkout};
    my $auto_renew = $params && $params->{auto_renew};
    my $cancel_recall = $params && $params->{cancel_recall};
    my $recall_id = $params && $params->{recall_id};
    my $dbh          = C4::Context->dbh;
    my $barcodecheck = CheckValidBarcode($barcode);

    my $issue;

    if ( $datedue && ref $datedue ne 'DateTime' ) {
        $datedue = dt_from_string($datedue);
    }

    # $issuedate defaults to today.
    if ( !defined $issuedate ) {
        $issuedate = dt_from_string();
    }
    else {
        if ( ref $issuedate ne 'DateTime' ) {
            $issuedate = dt_from_string($issuedate);

        }
    }

    # Stop here if the patron or barcode doesn't exist
    if ( $borrower && $barcode && $barcodecheck ) {
        # find which item we issue
        my $item_object = Koha::Items->find({ barcode => $barcode })
          or return;    # if we don't get an Item, abort.
        my $item_unblessed = $item_object->unblessed;

        my $branchcode = _GetCircControlBranch( $item_unblessed, $borrower );

        # get actual issuing if there is one
        my $actualissue = $item_object->checkout;

        # check if we just renew the issue.
        if ( $actualissue and $actualissue->borrowernumber eq $borrower->{'borrowernumber'}
                and not $switch_onsite_checkout ) {
            $datedue = AddRenewal(
                $borrower->{'borrowernumber'},
                $item_object->itemnumber,
                $branchcode,
                $datedue,
                $issuedate,    # here interpreted as the renewal date
            );
        }
        else {

            unless ($datedue) {
                my $itype = $item_object->effective_itemtype;
                $datedue = CalcDateDue( $issuedate, $itype, $branchcode, $borrower );

            }

            # Check if we need to use an exact due date set by the ILL module
            if ( C4::Context->preference('ILLModule') ) {
                # Check if there is an ILL connected with the biblio of the item we are issuing
                my $ill_request = Koha::Illrequests->search({
                    biblio_id => $item_object->biblionumber,
                    borrowernumber => $borrower->{'borrowernumber'},
                    completed => undef,
                    due_date => { '!=', undef },
                })->next;

                if ( $ill_request and length( $ill_request->due_date ) > 0 ) {
                    my $ill_dt = dt_from_string( $ill_request->due_date );
                    $ill_dt->set_hour(23);
                    $ill_dt->set_minute(59);
                    $datedue = $ill_dt;
                }
            }

            $datedue->truncate( to => 'minute' );

            my $patron = Koha::Patrons->find( $borrower );
            my $library = Koha::Libraries->find( $branchcode );
            my $fees = Koha::Charges::Fees->new(
                {
                    patron    => $patron,
                    library   => $library,
                    item      => $item_object,
                    to_date   => $datedue,
                }
            );

            # it's NOT a renewal
            if ( $actualissue and not $switch_onsite_checkout ) {
                # This book is currently on loan, but not to the person
                # who wants to borrow it now. mark it returned before issuing to the new borrower
                my ( $allowed, $message ) = CanBookBeReturned( $item_unblessed, C4::Context->userenv->{branch} );
                return unless $allowed;
                AddReturn( $item_object->barcode, C4::Context->userenv->{'branch'} );
                # AddReturn certainly has side-effects, like onloan => undef
                $item_object->discard_changes;
            }

            if ( C4::Context->preference('UseRecalls') ) {
                Koha::Recalls->move_recall(
                    {
                        action         => $cancel_recall,
                        recall_id      => $recall_id,
                        item           => $item_object,
                        borrowernumber => $borrower->{borrowernumber},
                    }
                );
            }

            C4::Reserves::MoveReserve( $item_object->itemnumber, $borrower->{'borrowernumber'}, $cancelreserve );

            # Starting process for transfer job (checking transfert and validate it if we have one)
            if ( my $transfer = $item_object->get_transfer ) {
                # updating line of branchtranfert to finish it, and changing the to branch value, implement a comment for visibility of this case (maybe for stats ....)
                $transfer->set(
                    {
                        datearrived => dt_from_string,
                        tobranch    => C4::Context->userenv->{branch},
                        comments    => 'Forced branchtransfer'
                    }
                )->store;
                if ( $transfer->reason && $transfer->reason eq 'Reserve' ) {
                    my $hold = $item_object->holds->search( { found => 'T' } )->next;
                    if ( $hold ) { # Is this really needed?
                        $hold->set( { found => undef } )->store;
                        C4::Reserves::ModReserveMinusPriority($item_object->itemnumber, $hold->reserve_id);
                    }
                }
            }

            # If automatic renewal wasn't selected while issuing, set the value according to the issuing rule.
            unless ($auto_renew) {
                my $rule = Koha::CirculationRules->get_effective_rule_value(
                    {
                        categorycode => $borrower->{categorycode},
                        itemtype     => $item_object->effective_itemtype,
                        branchcode   => $branchcode,
                        rule_name    => 'auto_renew'
                    }
                );

                $auto_renew = $rule if defined $rule && $rule ne '';
            }

            my $issue_attributes = {
                borrowernumber  => $borrower->{'borrowernumber'},
                issuedate       => $issuedate,
                date_due        => $datedue,
                branchcode      => C4::Context->userenv->{'branch'},
                onsite_checkout => $onsite_checkout,
                auto_renew      => $auto_renew ? 1 : 0,
            };

            # Get ID of logged in user.  if called from a batch job,
            # no user session exists and C4::Context->userenv() returns
            # the scalar '0'. Only do this if the syspref says so
            if ( C4::Context->preference('RecordStaffUserOnCheckout') ) {
                my $userenv = C4::Context->userenv();
                my $usernumber = (ref($userenv) eq 'HASH') ? $userenv->{'number'} : undef;
                if ($usernumber) {
                    $issue_attributes->{issuer_id} = $usernumber;
                }
            }

            # In the case that the borrower has an on-site checkout
            # and SwitchOnSiteCheckouts is enabled this converts it to a regular checkout
            $issue = Koha::Checkouts->find( { itemnumber => $item_object->itemnumber } );
            if ($issue) {
                $issue->set($issue_attributes)->store;
            }
            else {
                $issue = Koha::Checkout->new(
                    {
                        itemnumber => $item_object->itemnumber,
                        %$issue_attributes,
                    }
                )->store;
            }
            $issue->discard_changes;
            C4::Auth::track_login_daily( $borrower->{userid} );
            if ( $item_object->location && $item_object->location eq 'CART'
                && ( !$item_object->permanent_location || $item_object->permanent_location ne 'CART' ) ) {
            ## Item was moved to cart via UpdateItemLocationOnCheckin, anything issued should be taken off the cart.
                CartToShelf( $item_object->itemnumber );
            }

            if ( C4::Context->preference('UpdateTotalIssuesOnCirc') ) {
                UpdateTotalIssues( $item_object->biblionumber, 1, undef, { skip_holds_queue => 1 } );
            }

            # Record if item was lost
            my $was_lost = $item_object->itemlost;

            $item_object->issues( ( $item_object->issues || 0 ) + 1);
            $item_object->holdingbranch(C4::Context->userenv->{'branch'});
            $item_object->itemlost(0);
            $item_object->onloan($datedue->ymd());
            $item_object->datelastborrowed( dt_from_string()->ymd() );
            $item_object->datelastseen( dt_from_string() );
            $item_object->store( { log_action => 0, skip_holds_queue => 1 } );

            # If the item was lost, it has now been found, charge the overdue if necessary
            if ($was_lost) {
                if ( $item_object->{_charge} ) {
                    $actualissue //= Koha::Old::Checkouts->search(
                        { itemnumber => $item_unblessed->{itemnumber} },
                        {
                            order_by => { '-desc' => 'returndate' },
                            rows     => 1
                        }
                    )->single;
                    unless ( exists( $borrower->{branchcode} ) ) {
                        my $patron = $actualissue->patron;
                        $borrower = $patron->unblessed;
                    }
                    _CalculateAndUpdateFine(
                        {
                            issue       => $actualissue,
                            item        => $item_unblessed,
                            borrower    => $borrower,
                            return_date => $issuedate
                        }
                    );
                    _FixOverduesOnReturn( $borrower->{borrowernumber},
                        $item_object->itemnumber, undef, 'RENEWED' );
                }
            }

            # If it costs to borrow this book, charge it to the patron's account.
            my ( $charge, $itemtype ) = GetIssuingCharges( $item_object->itemnumber, $borrower->{'borrowernumber'} );
            if ( $charge && $charge > 0 ) {
                AddIssuingCharge( $issue, $charge, 'RENT' );
            }

            my $itemtype_object = Koha::ItemTypes->find( $item_object->effective_itemtype );
            if ( $itemtype_object ) {
                my $accumulate_charge = $fees->accumulate_rentalcharge();
                if ( $accumulate_charge > 0 ) {
                    AddIssuingCharge( $issue, $accumulate_charge, 'RENT_DAILY' );
                    $charge += $accumulate_charge;
                    $item_unblessed->{charge} = $charge;
                }
            }

            my $yaml = C4::Context->preference('UpdateNotForLoanStatusOnCheckout');
            if ($yaml) {
                $yaml = "$yaml\n\n";

                my $rules;
                eval { $rules = YAML::XS::Load(Encode::encode_utf8($yaml)); };
                if ($@) {
                    warn "Unable to parse UpdateNotForLoanStatusOnCheckout syspref : $@";
                }
                else {
                    foreach my $key ( keys %$rules ) {
                        if ( $item_object->notforloan eq $key ) {
                            $item_object->notforloan($rules->{$key})->store({ log_action => 0, skip_record_index => 1 });
                            last;
                        }
                    }
                }
            }

            # Record the fact that this book was issued.
            C4::Stats::UpdateStats(
                {
                    branch => C4::Context->userenv->{'branch'},
                    type => ( $onsite_checkout ? 'onsite_checkout' : 'issue' ),
                    amount         => $charge,
                    other          => ( $sipmode ? "SIP-$sipmode" : '' ),
                    itemnumber     => $item_object->itemnumber,
                    itemtype       => $item_object->effective_itemtype,
                    location       => $item_object->location,
                    borrowernumber => $borrower->{'borrowernumber'},
                    ccode          => $item_object->ccode,
                    categorycode   => $borrower->{'categorycode'},
                    interface      => C4::Context->interface,
                }
            );

            # Send a checkout slip.
            my $circulation_alert = 'C4::ItemCirculationAlertPreference';
            my %conditions        = (
                branchcode   => $branchcode,
                categorycode => $borrower->{categorycode},
                item_type    => $item_object->effective_itemtype,
                notification => 'CHECKOUT',
            );
            if ( $circulation_alert->is_enabled_for( \%conditions ) ) {
                SendCirculationAlert(
                    {
                        type     => 'CHECKOUT',
                        item     => $item_object->unblessed,
                        borrower => $borrower,
                        branch   => $branchcode,
                    }
                );
            }
            logaction(
                "CIRCULATION", "ISSUE",
                $borrower->{'borrowernumber'},
                $item_object->itemnumber,
            ) if C4::Context->preference("IssueLog");

            Koha::Plugins->call('after_circ_action', {
                action  => 'checkout',
                payload => {
                    type     => ( $onsite_checkout ? 'onsite_checkout' : 'issue' ),
                    checkout => $issue->get_from_storage
                }
            });

            Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
                {
                    biblio_ids => [ $item_object->biblionumber ]
                }
            ) if C4::Context->preference('RealTimeHoldsQueue');
        }
    }
    return $issue;
}

=head2 GetLoanLength

  my $loanlength = &GetLoanLength($borrowertype,$itemtype,branchcode)

Get loan length for an itemtype, a borrower type and a branch

=cut

sub GetLoanLength {
    my ( $categorycode, $itemtype, $branchcode ) = @_;

    # Initialize default values
    my $rules = {
        issuelength   => 0,
        renewalperiod => 0,
        lengthunit    => 'days',
    };

    my $found = Koha::CirculationRules->get_effective_rules( {
        branchcode => $branchcode,
        categorycode => $categorycode,
        itemtype => $itemtype,
        rules => [
            'issuelength',
            'renewalperiod',
            'lengthunit'
        ],
    } );

    # Search for rules!
    foreach my $rule_name (keys %$found) {
        $rules->{$rule_name} = $found->{$rule_name};
    }

    return $rules;
}


=head2 GetHardDueDate

  my ($hardduedate,$hardduedatecompare) = &GetHardDueDate($borrowertype,$itemtype,branchcode)

Get the Hard Due Date and it's comparison for an itemtype, a borrower type and a branch

=cut

sub GetHardDueDate {
    my ( $borrowertype, $itemtype, $branchcode ) = @_;

    my $rules = Koha::CirculationRules->get_effective_rules(
        {
            categorycode => $borrowertype,
            itemtype     => $itemtype,
            branchcode   => $branchcode,
            rules        => [ 'hardduedate', 'hardduedatecompare' ],
        }
    );

    if ( defined( $rules->{hardduedate} ) ) {
        if ( $rules->{hardduedate} ) {
            return ( dt_from_string( $rules->{hardduedate}, 'iso' ), $rules->{hardduedatecompare} );
        }
        else {
            return ( undef, undef );
        }
    }
}

=head2 GetBranchBorrowerCircRule

  my $branch_cat_rule = GetBranchBorrowerCircRule($branchcode, $categorycode);

Retrieves circulation rule attributes that apply to the given
branch and patron category, regardless of item type.  
The return value is a hashref containing the following key:

patron_maxissueqty - maximum number of loans that a
patron of the given category can have at the given
branch.  If the value is undef, no limit.

patron_maxonsiteissueqty - maximum of on-site checkouts that a
patron of the given category can have at the given
branch.  If the value is undef, no limit.

This will check for different branch/category combinations in the following order:
branch and category
branch only
category only
default branch and category

If no rule has been found in the database, it will default to
the buillt in rule:

patron_maxissueqty - undef
patron_maxonsiteissueqty - undef

C<$branchcode> and C<$categorycode> should contain the
literal branch code and patron category code, respectively - no
wildcards.

=cut

sub GetBranchBorrowerCircRule {
    my ( $branchcode, $categorycode ) = @_;

    # Initialize default values
    my $rules = {
        patron_maxissueqty       => undef,
        patron_maxonsiteissueqty => undef,
    };

    # Search for rules!
    foreach my $rule_name (qw( patron_maxissueqty patron_maxonsiteissueqty )) {
        my $rule = Koha::CirculationRules->get_effective_rule(
            {
                categorycode => $categorycode,
                itemtype     => undef,
                branchcode   => $branchcode,
                rule_name    => $rule_name,
            }
        );

        $rules->{$rule_name} = $rule->rule_value if defined $rule;
    }

    return $rules;
}

=head2 GetBranchItemRule

  my $branch_item_rule = GetBranchItemRule($branchcode, $itemtype);

Retrieves circulation rule attributes that apply to the given
branch and item type, regardless of patron category.

The return value is a hashref containing the following keys:

holdallowed => Hold policy for this branch and itemtype. Possible values:
  not_allowed:           No holds allowed.
  from_home_library:     Holds allowed only by patrons that have the same homebranch as the item.
  from_any_library:      Holds allowed from any patron.
  from_local_hold_group: Holds allowed from libraries in hold group

This searches branchitemrules in the following order:

  * Same branchcode and itemtype
  * Same branchcode, itemtype '*'
  * branchcode '*', same itemtype
  * branchcode and itemtype '*'

Neither C<$branchcode> nor C<$itemtype> should be '*'.

=cut

sub GetBranchItemRule {
    my ( $branchcode, $itemtype ) = @_;

    # Search for rules!
    my $rules = Koha::CirculationRules->get_effective_rules({
        branchcode => $branchcode,
        itemtype => $itemtype,
        rules => ['holdallowed', 'hold_fulfillment_policy']
    });

    # built-in default circulation rule
    $rules->{holdallowed} //= 'from_any_library';
    $rules->{hold_fulfillment_policy} //= 'any';

    return $rules;
}

=head2 AddReturn

  ($doreturn, $messages, $iteminformation, $borrower) =
      &AddReturn( $barcode, $branch [,$exemptfine] [,$returndate] );

Returns a book.

=over 4

=item C<$barcode> is the bar code of the book being returned.

=item C<$branch> is the code of the branch where the book is being returned.

=item C<$exemptfine> indicates that overdue charges for the item will be
removed. Optional.

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

=item C<RecallFound>

This item can fill a recall. The recall object is returned. If the recall pickup branch differs from
the branch this item is being returned at, C<RecallNeedsTransfer> is also returned which contains this
branchcode.

=item C<TransferredRecall>

This item has been transferred to this branch to fill a recall. The recall object is returned.

=back

C<$iteminformation> is a reference-to-hash, giving information about the
returned item from the issues table.

C<$borrower> is a reference-to-hash, giving information about the
patron who last borrowed the book.

=cut

sub AddReturn {
    my ( $barcode, $branch, $exemptfine, $return_date ) = @_;

    if ($branch and not Koha::Libraries->find($branch)) {
        warn "AddReturn error: branch '$branch' not found.  Reverting to " . C4::Context->userenv->{'branch'};
        undef $branch;
    }
    $branch = C4::Context->userenv->{'branch'} unless $branch;  # we trust userenv to be a safe fallback/default
    my $return_date_specified = !!$return_date;
    $return_date //= dt_from_string();
    my $messages;
    my $patron;
    my $doreturn       = 1;
    my $validTransfer = 1;
    my $stat_type = 'return';

    # get information on item
    my $item = Koha::Items->find({ barcode => $barcode });
    unless ($item) {
        return ( 0, { BadBarcode => $barcode } );    # no barcode means no item or borrower.  bail out.
    }

    my $itemnumber = $item->itemnumber;
    my $itemtype = $item->effective_itemtype;

    my $issue  = $item->checkout;
    if ( $issue ) {
        $patron = $issue->patron
            or die "Data inconsistency: barcode $barcode (itemnumber:$itemnumber) claims to be issued to non-existent borrowernumber '" . $issue->borrowernumber . "'\n"
                . Dumper($issue->unblessed) . "\n";
    } else {
        $messages->{'NotIssued'} = $barcode;
        $item->onloan(undef)->store( { skip_record_index => 1, skip_holds_queue => 1 } ) if defined $item->onloan;

        # even though item is not on loan, it may still be transferred;  therefore, get current branch info
        $doreturn = 0;
        # No issue, no borrowernumber.  ONLY if $doreturn, *might* you have a $borrower later.
        # Record this as a local use, instead of a return, if the RecordLocalUseOnReturn is on
        if (C4::Context->preference("RecordLocalUseOnReturn")) {
           $messages->{'LocalUse'} = 1;
           $stat_type = 'localuse';
        }
    }

    if ( $item->withdrawn ) { # book has been cancelled
        $messages->{'withdrawn'} = 1;

        # In the case where we block return of withdrawn, we should completely block the return
        # without updating item statuses, so we exit early
        return ( 0, $messages, $issue, ( $patron ? $patron->unblessed : {} ))
            if C4::Context->preference("BlockReturnOfWithdrawnItems");
    }


        # full item data, but no borrowernumber or checkout info (no issue)
    my $hbr = Koha::CirculationRules->get_return_branch_policy($item);
        # get the proper branch to which to return the item
    my $returnbranch = $hbr ne 'noreturn' ? $item->$hbr : $branch;
        # if $hbr was "noreturn" or any other non-item table value, then it should 'float' (i.e. stay at this branch)
    my $transfer_trigger = $hbr eq 'homebranch' ? 'ReturnToHome' : $hbr eq 'holdingbranch' ? 'ReturnToHolding' : undef;

    my $borrowernumber = $patron ? $patron->borrowernumber : undef;    # we don't know if we had a borrower or not
    my $patron_unblessed = $patron ? $patron->unblessed : {};

    my $update_loc_rules = C4::Context->yaml_preference('UpdateItemLocationOnCheckin');
    if ($update_loc_rules) {
        if ( defined $update_loc_rules->{_ALL_} ) {
            if ( $update_loc_rules->{_ALL_} eq '_PERM_' ) {
                $update_loc_rules->{_ALL_} = $item->permanent_location;
            }
            if ( $update_loc_rules->{_ALL_} eq '_BLANK_' ) {
                $update_loc_rules->{_ALL_} = '';
            }
            if (
                (
                    defined $item->location
                    && $item->location ne $update_loc_rules->{_ALL_}
                )
                || ( !defined $item->location
                    && $update_loc_rules->{_ALL_} ne "" )
              )
            {
                $messages->{'ItemLocationUpdated'} =
                  { from => $item->location, to => $update_loc_rules->{_ALL_} };
                $item->location( $update_loc_rules->{_ALL_} )->store(
                    {
                        log_action        => 0,
                        skip_record_index => 1,
                        skip_holds_queue  => 1
                    }
                );
            }
        }
        else {
            foreach my $key ( keys %$update_loc_rules ) {
                if ( $update_loc_rules->{$key} eq '_PERM_' ) {
                    $update_loc_rules->{$key} = $item->permanent_location;
                }
                elsif ( $update_loc_rules->{$key} eq '_BLANK_' ) {
                    $update_loc_rules->{$key} = '';
                }
                if (
                    (
                           defined $item->location
                        && $item->location eq $key
                        && $item->location ne $update_loc_rules->{$key}
                    )
                    || (   $key eq '_BLANK_'
                        && ( !defined $item->location || $item->location eq '' )
                        && $update_loc_rules->{$key} ne '' )
                  )
                {
                    $messages->{'ItemLocationUpdated'} = {
                        from => $item->location,
                        to   => $update_loc_rules->{$key}
                    };
                    $item->location( $update_loc_rules->{$key} )->store(
                        {
                            log_action        => 0,
                            skip_record_index => 1,
                            skip_holds_queue  => 1
                        }
                    );
                    last;
                }
            }
        }
    }

    my $yaml = C4::Context->preference('UpdateNotForLoanStatusOnCheckin');
    if ($yaml) {
        $yaml = "$yaml\n\n";  # YAML is anal on ending \n. Surplus does not hurt
        my $rules;
        eval { $rules = YAML::XS::Load(Encode::encode_utf8($yaml)); };
        if ($@) {
            warn "Unable to parse UpdateNotForLoanStatusOnCheckin syspref : $@";
        }
        else {
            foreach my $key ( keys %$rules ) {
                if ( $item->notforloan eq $key ) {
                    $messages->{'NotForLoanStatusUpdated'} = { from => $item->notforloan, to => $rules->{$key} };
                    $item->notforloan($rules->{$key})->store({ log_action => 0, skip_record_index => 1, skip_holds_queue => 1 }) unless $rules->{$key} eq 'ONLYMESSAGE';
                    last;
                }
            }
        }
    }

    # check if the return is allowed at this branch
    my ($returnallowed, $message) = CanBookBeReturned($item->unblessed, $branch);
    unless ($returnallowed){
        $messages->{'Wrongbranch'} = {
            Wrongbranch => $branch,
            Rightbranch => $message
        };
        $doreturn = 0;
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        $indexer->index_records( $item->biblionumber, "specialUpdate", "biblioserver" );
        return ( $doreturn, $messages, $issue, $patron_unblessed);
    }

    if ( $item->itemlost and C4::Context->preference("BlockReturnOfLostItems") ) {
        $doreturn = 0;
    }

    # case of a return of document (deal with issues and holdingbranch)
    if ($doreturn) {
        die "The item is not issed and cannot be returned" unless $issue; # Just in case...
        $patron or warn "AddReturn without current borrower";

        if ($patron) {
            eval {
                MarkIssueReturned( $borrowernumber, $item->itemnumber, $return_date, $patron->privacy, { skip_record_index => 1, skip_holds_queue => 1} );
            };
            unless ( $@ ) {
                if (
                    (
                        C4::Context->preference('CalculateFinesOnReturn')
                        || ( $return_date_specified && C4::Context->preference('CalculateFinesOnBackdate') )
                    )
                    && !$item->itemlost
                  )
                {
                    _CalculateAndUpdateFine( { issue => $issue, item => $item->unblessed, borrower => $patron_unblessed, return_date => $return_date } );
                }
            } else {
                carp "The checkin for the following issue failed, Please go to the about page and check all messages on the 'System information' to see if there are configuration / data issues ($@)" . Dumper( $issue->unblessed );

                my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
                $indexer->index_records( $item->biblionumber, "specialUpdate", "biblioserver" );

                return ( 0, { WasReturned => 0, DataCorrupted => 1 }, $issue, $patron_unblessed );
            }

            # FIXME is the "= 1" right?  This could be the borrower hash.
            $messages->{'WasReturned'} = 1;

        } else {
            $item->onloan(undef)->store({ log_action => 0 , skip_record_index => 1, skip_holds_queue => 1 });
        }
    }

    # the holdingbranch is updated if the document is returned to another location.
    # this is always done regardless of whether the item was on loan or not
    if ($item->holdingbranch ne $branch) {
        $item->holdingbranch($branch)->store({ log_action => 0, skip_record_index => 1, skip_holds_queue => 1 });
    }

    my $item_was_lost = $item->itemlost;
    my $leave_item_lost = C4::Context->preference("BlockReturnOfLostItems") ? 1 : 0;
    my $updated_item = ModDateLastSeen( $item->itemnumber, $leave_item_lost, { skip_record_index => 1, skip_holds_queue => 1 } ); # will unset itemlost if needed

    # fix up the accounts.....
    if ($item_was_lost) {
        $messages->{'WasLost'} = 1;
        unless ( C4::Context->preference("BlockReturnOfLostItems") ) {
            my @object_messages = @{ $updated_item->object_messages };
            for my $message (@object_messages) {
                $messages->{'LostItemFeeRefunded'} = 1
                  if $message->message eq 'lost_refunded';
                $messages->{'ProcessingFeeRefunded'} = 1
                  if $message->message eq 'processing_refunded';
                $messages->{'LostItemFeeRestored'} = 1
                  if $message->message eq 'lost_restored';

                if ( $message->message eq 'lost_charge' ) {
                    $issue //= Koha::Old::Checkouts->search(
                        { itemnumber => $item->itemnumber },
                        { order_by   => { '-desc' => 'returndate' }, rows => 1 }
                    )->single;
                    unless ( exists( $patron_unblessed->{branchcode} ) ) {
                        my $patron = $issue->patron;
                        $patron_unblessed = $patron->unblessed;
                    }
                    _CalculateAndUpdateFine(
                        {
                            issue       => $issue,
                            item        => $item->unblessed,
                            borrower    => $patron_unblessed,
                            return_date => $return_date
                        }
                    );
                    _FixOverduesOnReturn( $patron_unblessed->{borrowernumber},
                        $item->itemnumber, undef, 'RETURNED' );
                    $messages->{'LostItemFeeCharged'} = 1;
                }
            }
        }
    }

    # check if we have a transfer for this document
    my $transfer = $item->get_transfer;

    # if we have a transfer to complete, we update the line of transfers with the datearrived
    if ($transfer) {
        $validTransfer = 0;
        if ( $transfer->in_transit ) {
            if ( $transfer->tobranch eq $branch ) {
                $transfer->receive;
                $messages->{'TransferArrived'} = $transfer->frombranch;
                # validTransfer=1 allows us returning the item back if the reserve is cancelled
                $validTransfer = 1
                  if defined $transfer->reason && $transfer->reason eq 'Reserve';
            }
            else {
                $messages->{'WrongTransfer'}     = $transfer->tobranch;
                $messages->{'WrongTransferItem'} = $item->itemnumber;
                $messages->{'TransferTrigger'}   = $transfer->reason;
            }
        }
        else {
            if ( $transfer->tobranch eq $branch ) {
                $transfer->receive;
                $messages->{'TransferArrived'} = $transfer->frombranch;
                # validTransfer=1 allows us returning the item back if the reserve is cancelled
                $validTransfer = 1 if $transfer->reason eq 'Reserve';
            }
            else {
                $messages->{'TransferTrigger'} = $transfer->reason;
                if ( $transfer->frombranch eq $branch ) {
                    $transfer->transit;
                    $messages->{'WasTransfered'}   = $transfer->tobranch;
                }
                else {
                    $messages->{'WrongTransfer'}     = $transfer->tobranch;
                    $messages->{'WrongTransferItem'} = $item->itemnumber;
                }
            }
        }
    }

    # fix up the overdues in accounts...
    if ($borrowernumber) {
        my $fix = _FixOverduesOnReturn( $borrowernumber, $item->itemnumber, $exemptfine, 'RETURNED' );
        defined($fix) or warn "_FixOverduesOnReturn($borrowernumber, ".$item->itemnumber."...) failed!";  # zero is OK, check defined

        if ( $issue and $issue->is_overdue($return_date) ) {
        # fix fine days
            my ($debardate,$reminder) = _debar_user_on_return( $patron_unblessed, $item->unblessed, dt_from_string($issue->date_due), $return_date );
            if ($debardate and $debardate ne "9999-12-31") {
                if ($reminder){
                    $messages->{'PrevDebarred'} = $debardate;
                } else {
                    $messages->{'Debarred'} = $debardate;
                }
            } elsif ($patron->debarred) {
                if ( $patron->debarred eq "9999-12-31") {
                    $messages->{'ForeverDebarred'} = $patron->debarred;
                } else {
                    my $borrower_debar_dt = dt_from_string( $patron->debarred );
                    $borrower_debar_dt->truncate(to => 'day');
                    my $today_dt = $return_date->clone()->truncate(to => 'day');
                    if ( DateTime->compare( $borrower_debar_dt, $today_dt ) != -1 ) {
                        $messages->{'PrevDebarred'} = $patron->debarred;
                    }
                }
            }
        # there's no overdue on the item but borrower had been previously debarred
        } elsif ( $issue->date_due and $patron->debarred ) {
             if ( $patron->debarred eq "9999-12-31") {
                $messages->{'ForeverDebarred'} = $patron->debarred;
             } else {
                  my $borrower_debar_dt = dt_from_string( $patron->debarred );
                  $borrower_debar_dt->truncate(to => 'day');
                  my $today_dt = $return_date->clone()->truncate(to => 'day');
                  if ( DateTime->compare( $borrower_debar_dt, $today_dt ) != -1 ) {
                      $messages->{'PrevDebarred'} = $patron->debarred;
                  }
             }
        }
    }

    # find recalls...
    if ( C4::Context->preference('UseRecalls') ) {
        # check if this item is recallable first, which includes checking if UseRecalls syspref is enabled
        my $recall = undef;
        $recall = $item->check_recalls if $item->can_be_waiting_recall;
        if ( defined $recall ) {
            $messages->{RecallFound} = $recall;
            if ( $recall->pickup_library_id ne $branch ) {
                $messages->{RecallNeedsTransfer} = $branch;
            }
        }
    }

    # find reserves.....
    # launch the Checkreserves routine to find any holds
    my ($resfound, $resrec);
    my $lookahead= C4::Context->preference('ConfirmFutureHolds'); #number of days to look for future holds
    ($resfound, $resrec, undef) = CheckReserves( $item, $lookahead ) unless ( $item->withdrawn );
    # if a hold is found and is waiting at another branch, change the priority back to 1 and trigger the hold (this will trigger a transfer and update the hold status properly)
    if ( $resfound and $resfound eq "Waiting" and $branch ne $resrec->{branchcode} ) {
        my $hold = C4::Reserves::RevertWaitingStatus( { itemnumber => $item->itemnumber } );
        $resfound = 'Reserved';
        $resrec = $hold->unblessed;
    }
    if ($resfound) {
          $resrec->{'ResFound'} = $resfound;
        $messages->{'ResFound'} = $resrec;
    }

    # Record the fact that this book was returned.
    my $categorycode = $patron_unblessed ? $patron_unblessed->{categorycode} : undef;
    C4::Stats::UpdateStats({
        branch         => $branch,
        type           => $stat_type,
        itemnumber     => $itemnumber,
        itemtype       => $itemtype,
        location       => $item->location,
        borrowernumber => $borrowernumber,
        ccode          => $item->ccode,
        categorycode   => $categorycode,
        interface      => C4::Context->interface,
    });

    # Send a check-in slip. # NOTE: borrower may be undef. Do not try to send messages then.
    if ( $patron ) {
        my $circulation_alert = 'C4::ItemCirculationAlertPreference';
        my %conditions = (
            branchcode   => $branch,
            categorycode => $patron->categorycode,
            item_type    => $itemtype,
            notification => 'CHECKIN',
        );
        if ($doreturn && $circulation_alert->is_enabled_for(\%conditions)) {
            SendCirculationAlert({
                type     => 'CHECKIN',
                item     => $item->unblessed,
                borrower => $patron->unblessed,
                branch   => $branch,
                issue    => $issue
            });
        }

        logaction("CIRCULATION", "RETURN", $borrowernumber, $item->itemnumber)
            if C4::Context->preference("ReturnLog");
        }

    # Check if this item belongs to a biblio record that is attached to an
    # ILL request, if it is we need to update the ILL request's status
    if ( $doreturn and C4::Context->preference('CirculateILL')) {
        my $request = Koha::Illrequests->find(
            { biblio_id => $item->biblio->biblionumber }
        );
        $request->status('RET') if $request;
    }

    if ( C4::Context->preference('UseRecalls') ) {
        # all recalls that have triggered a transfer will have an allocated itemnumber
        my $transfer_recall = Koha::Recalls->find({ item_id => $item->itemnumber, status => 'in_transit' });
        if ( $transfer_recall and $transfer_recall->pickup_library_id eq $branch ) {
            $messages->{TransferredRecall} = $transfer_recall;
        }
    }

    # Transfer to returnbranch if Automatic transfer set or append message NeedsTransfer
    if ( $validTransfer && !C4::RotatingCollections::isItemInAnyCollection( $item->itemnumber )
        && ( $doreturn or $messages->{'NotIssued'} )
        and !$resfound
        and ( $branch ne $returnbranch )
        and not $messages->{'WrongTransfer'}
        and not $messages->{'WasTransfered'}
        and not $messages->{TransferredRecall}
        and not $messages->{RecallNeedsTransfer} )
    {
        my $BranchTransferLimitsType = C4::Context->preference("BranchTransferLimitsType") eq 'itemtype' ? 'effective_itemtype' : 'ccode';
        if  (C4::Context->preference("AutomaticItemReturn"    ) or
            (C4::Context->preference("UseBranchTransferLimits") and
             ! IsBranchTransferAllowed($branch, $returnbranch, $item->$BranchTransferLimitsType )
           )) {
            ModItemTransfer($item->itemnumber, $branch, $returnbranch, $transfer_trigger, { skip_record_index => 1 });
            $messages->{'WasTransfered'} = $returnbranch;
            $messages->{'TransferTrigger'} = $transfer_trigger;
        } else {
            $messages->{'NeedsTransfer'} = $returnbranch;
            $messages->{'TransferTrigger'} = $transfer_trigger;
        }
    }

    if ( C4::Context->preference('ClaimReturnedLostValue') ) {
        my $claims = Koha::Checkouts::ReturnClaims->search(
           {
               itemnumber => $item->id,
               resolution => undef,
           }
        );

        if ( $claims->count ) {
            $messages->{ReturnClaims} = $claims;
        }
    }

    # Check for bundle status
    if ( $item->in_bundle ) {
        my $host = $item->bundle_host;
        $messages->{InBundle} = $host;
    }

    my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
    $indexer->index_records( $item->biblionumber, "specialUpdate", "biblioserver" );

    if ( $doreturn and $issue ) {
        my $checkin = Koha::Old::Checkouts->find($issue->id);

        Koha::Plugins->call('after_circ_action', {
            action  => 'checkin',
            payload => {
                checkout=> $checkin
            }
        });

        Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
            {
                biblio_ids => [ $item->biblionumber ]
            }
        ) if C4::Context->preference('RealTimeHoldsQueue');
    }

    return ( $doreturn, $messages, $issue, ( $patron ? $patron->unblessed : {} ));
}

=head2 MarkIssueReturned

  MarkIssueReturned($borrowernumber, $itemnumber, $returndate, $privacy, [$params] );

Unconditionally marks an issue as being returned by
moving the C<issues> row to C<old_issues> and
setting C<returndate> to the current date.

if C<$returndate> is specified (in iso format), it is used as the date
of the return.

C<$privacy> contains the privacy parameter. If the patron has set privacy to 2,
the old_issue is immediately anonymised

Ideally, this function would be internal to C<C4::Circulation>,
not exported, but it is currently used in misc/cronjobs/longoverdue.pl
and offline_circ/process_koc.pl.

The last optional parameter allos passing skip_record_index to the item store call.

=cut

sub MarkIssueReturned {
    my ( $borrowernumber, $itemnumber, $returndate, $privacy, $params ) = @_;

    # Retrieve the issue
    my $issue = Koha::Checkouts->find( { itemnumber => $itemnumber } ) or return;

    return unless $issue->borrowernumber == $borrowernumber; # If the item is checked out to another patron we do not return it

    my $issue_id = $issue->issue_id;

    my $schema = Koha::Database->schema;

    # FIXME Improve the return value and handle it from callers
    $schema->txn_do(sub {

        my $patron = Koha::Patrons->find( $borrowernumber );

        # Update the returndate value
        if ( $returndate ) {
            $issue->returndate( $returndate )->store->discard_changes; # update and refetch
        }
        else {
            $issue->returndate( \'NOW()' )->store->discard_changes; # update and refetch
        }

        # Create the old_issues entry
        my $old_checkout = Koha::Old::Checkout->new($issue->unblessed)->store;

        # anonymise patron checkout immediately if $privacy set to 2 and AnonymousPatron is set to a valid borrowernumber
        if ( $privacy && $privacy == 2) {
            $old_checkout->anonymize;
        }

        # And finally delete the issue
        $issue->delete;

        $issue->item->onloan(undef)->store(
            {   log_action        => 0,
                skip_record_index => $params->{skip_record_index},
                skip_holds_queue  => $params->{skip_holds_queue}
            }
        );

        if ( C4::Context->preference('StoreLastBorrower') ) {
            my $item = Koha::Items->find( $itemnumber );
            $item->last_returned_by( $patron->borrowernumber )->store;
        }

        # Remove any OVERDUES related debarment if the borrower has no overdues
        my $overdue_restrictions = $patron->restrictions->search({ type => 'OVERDUES' });
        if ( C4::Context->preference('AutoRemoveOverduesRestrictions')
          && $patron->debarred
          && !$patron->has_overdues
          && $overdue_restrictions->count
        ) {
            DelUniqueDebarment({ borrowernumber => $borrowernumber, type => 'OVERDUES' });
        }

    });

    return $issue_id;
}

=head2 _debar_user_on_return

    _debar_user_on_return($borrower, $item, $datedue, $returndate);

C<$borrower> borrower hashref

C<$item> item hashref

C<$datedue> date due DateTime object

C<$returndate> DateTime object representing the return time

Internal function, called only by AddReturn that calculates and updates
 the user fine days, and debars them if necessary.

Should only be called for overdue returns

Calculation of the debarment date has been moved to a separate subroutine _calculate_new_debar_dt
to ease testing.

=cut

sub _calculate_new_debar_dt {
    my ( $borrower, $item, $dt_due, $return_date ) = @_;

    my $branchcode = _GetCircControlBranch( $item, $borrower );
    my $circcontrol = C4::Context->preference('CircControl');
    my $issuing_rule = Koha::CirculationRules->get_effective_rules(
        {   categorycode => $borrower->{categorycode},
            itemtype     => $item->{itype},
            branchcode   => $branchcode,
            rules => [
                'finedays',
                'lengthunit',
                'firstremind',
                'maxsuspensiondays',
                'suspension_chargeperiod',
            ]
        }
    );
    my $finedays = $issuing_rule ? $issuing_rule->{finedays} : undef;
    my $unit     = $issuing_rule ? $issuing_rule->{lengthunit} : undef;
    my $chargeable_units = C4::Overdues::get_chargeable_units($unit, $dt_due, $return_date, $branchcode);

    return unless $finedays;

    # finedays is in days, so hourly loans must multiply by 24
    # thus 1 hour late equals 1 day suspension * finedays rate
    $finedays = $finedays * 24 if ( $unit eq 'hours' );

    # grace period is measured in the same units as the loan
    my $grace =
      DateTime::Duration->new( $unit => $issuing_rule->{firstremind} // 0);

    my $deltadays = DateTime::Duration->new(
        days => $chargeable_units
    );

    if ( $deltadays->subtract($grace)->is_positive() ) {
        my $suspension_days = $deltadays * $finedays;

        if ( defined $issuing_rule->{suspension_chargeperiod} && $issuing_rule->{suspension_chargeperiod} > 1 ) {
            # No need to / 1 and do not consider / 0
            $suspension_days = DateTime::Duration->new(
                days => floor( $suspension_days->in_units('days') / $issuing_rule->{suspension_chargeperiod} )
            );
        }

        # If the max suspension days is < than the suspension days
        # the suspension days is limited to this maximum period.
        my $max_sd = $issuing_rule->{maxsuspensiondays};
        if ( defined $max_sd && $max_sd ne '' ) {
            $max_sd = DateTime::Duration->new( days => $max_sd );
            $suspension_days = $max_sd
              if DateTime::Duration->compare( $max_sd, $suspension_days ) < 0;
        }

        my ( $has_been_extended );
        if ( C4::Context->preference('CumulativeRestrictionPeriods') and $borrower->{debarred} ) {
            my $patron = Koha::Patrons->find($borrower->{borrowernumber});
            my $debarment = $patron->restrictions->search({type => 'SUSPENSION' },{rows => 1})->single;
            if ( $debarment ) {
                $return_date = dt_from_string( $debarment->expiration, 'sql' );
                $has_been_extended = 1;
            }
        }

        my $new_debar_dt;
        # Use the calendar or not to calculate the debarment date
        if ( C4::Context->preference('SuspensionsCalendar') eq 'noSuspensionsWhenClosed' ) {
            my $calendar = Koha::Calendar->new(
                branchcode => $branchcode,
                days_mode  => 'Calendar'
            );
            $new_debar_dt = $calendar->addDuration( $return_date, $suspension_days );
        }
        else {
            $new_debar_dt = $return_date->clone()->add_duration($suspension_days);
        }
        return $new_debar_dt;
    }
    return;
}

sub _debar_user_on_return {
    my ( $borrower, $item, $dt_due, $return_date ) = @_;

    $return_date //= dt_from_string();

    my $new_debar_dt = _calculate_new_debar_dt ($borrower, $item, $dt_due, $return_date);

    return unless $new_debar_dt;

    Koha::Patron::Debarments::AddUniqueDebarment({
        borrowernumber => $borrower->{borrowernumber},
        expiration     => $new_debar_dt->ymd(),
        type           => 'SUSPENSION',
    });
    # if borrower was already debarred but does not get an extra debarment
    my $patron = Koha::Patrons->find( $borrower->{borrowernumber} );
    my ($new_debarment_str, $is_a_reminder);
    if ( $borrower->{debarred} && $borrower->{debarred} eq $patron->is_debarred ) {
        $is_a_reminder = 1;
        $new_debarment_str = $borrower->{debarred};
    } else {
        $new_debarment_str = $new_debar_dt->ymd();
    }
    # FIXME Should return a DateTime object
    return $new_debarment_str, $is_a_reminder;
}

=head2 _FixOverduesOnReturn

   &_FixOverduesOnReturn($borrowernumber, $itemnumber, $exemptfine, $status);

C<$borrowernumber> borrowernumber

C<$itemnumber> itemnumber

C<$exemptfine> BOOL -- remove overdue charge associated with this issue. 

C<$status> ENUM -- reason for fix [ RETURNED, RENEWED, LOST, FORGIVEN ]

Internal function

=cut

sub _FixOverduesOnReturn {
    my ( $borrowernumber, $item, $exemptfine, $status ) = @_;
    unless( $borrowernumber ) {
        warn "_FixOverduesOnReturn() not supplied valid borrowernumber";
        return;
    }
    unless( $item ) {
        warn "_FixOverduesOnReturn() not supplied valid itemnumber";
        return;
    }
    unless( $status ) {
        warn "_FixOverduesOnReturn() not supplied valid status";
        return;
    }

    my $schema = Koha::Database->schema;

    my $result = $schema->txn_do(
        sub {
            # check for overdue fine
            my $accountlines = Koha::Account::Lines->search(
                {
                    borrowernumber  => $borrowernumber,
                    itemnumber      => $item,
                    debit_type_code => 'OVERDUE',
                    status          => 'UNRETURNED'
                }
            );
            return 0 unless $accountlines->count; # no warning, there's just nothing to fix

            my $accountline = $accountlines->next;
            my $payments = $accountline->credits;

            my $amountoutstanding = $accountline->amountoutstanding;
            if ( $accountline->amount == 0 && $payments->count == 0 ) {
                $accountline->delete;
                return 0; # no warning, we've just removed a zero value fine (backdated return)
            } elsif ($exemptfine && ($amountoutstanding != 0)) {
                my $account = Koha::Account->new({patron_id => $borrowernumber});
                my $credit = $account->add_credit(
                    {
                        amount     => $amountoutstanding,
                        user_id    => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                        library_id => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
                        interface  => C4::Context->interface,
                        type       => 'FORGIVEN',
                        item_id    => $item
                    }
                );

                $credit->apply({ debits => [ $accountline ] });

                if (C4::Context->preference("FinesLog")) {
                    &logaction("FINES", 'MODIFY',$borrowernumber,"Overdue forgiven: item $item");
                }
            }

            $accountline->status($status);
            return $accountline->store();
        }
    );

    return $result;
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

=head2 GetUpcomingDueIssues

  my $upcoming_dues = GetUpcomingDueIssues( { days_in_advance => 4 } );

=cut

sub GetUpcomingDueIssues {
    my $params = shift;

    $params->{'days_in_advance'} = 7 unless exists $params->{'days_in_advance'};
    my $dbh = C4::Context->dbh;
    my $statement;
    $statement = q{
        SELECT issues.*, items.itype as itemtype, items.homebranch, TO_DAYS( date_due )-TO_DAYS( NOW() ) as days_until_due, branches.branchemail
        FROM issues
        LEFT JOIN items USING (itemnumber)
        LEFT JOIN branches ON branches.branchcode =
    };
    $statement .= $params->{'owning_library'} ? " items.homebranch " : " issues.branchcode ";
    $statement .= " WHERE returndate is NULL AND TO_DAYS( date_due )-TO_DAYS( NOW() ) BETWEEN 0 AND ?";
    my @bind_parameters = ( $params->{'days_in_advance'} );
    
    my $sth = $dbh->prepare( $statement );
    $sth->execute( @bind_parameters );
    my $upcoming_dues = $sth->fetchall_arrayref({});

    return $upcoming_dues;
}

=head2 CanBookBeRenewed

  ($ok,$error,$info) = &CanBookBeRenewed($patron, $issue, $override_limit);

Find out whether a borrowed item may be renewed.

C<$patron> is the patron who currently has the issue.

C<$issue> is the checkout to renew.

C<$override_limit>, if supplied with a true value, causes
the limit on the number of times that the loan can be renewed
(as controlled by the item type) to be ignored. Overriding also allows
to renew sooner than "No renewal before" and to manually renew loans
that are automatically renewed.

C<$CanBookBeRenewed> returns a true value if the item may be renewed. The
item must currently be on loan to the specified borrower; renewals
must be allowed for the item's type; and the borrower must not have
already renewed the loan.
    $error will contain the reason the renewal can not proceed
    $info will contain a hash of additional info
      currently 'soonest_renew_date' if error is 'too soon'

=cut

sub CanBookBeRenewed {
    my ( $patron, $issue, $override_limit, $cron ) = @_;

    my $auto_renew = "no";
    my $soonest;
    my $item = $issue->item;

    return ( 0, 'no_item' ) unless $item;
    return ( 0, 'no_checkout' ) unless $issue;
    return ( 0, 'onsite_checkout' ) if $issue->onsite_checkout;
    return ( 0, 'item_issued_to_other_patron') if $issue->borrowernumber != $patron->borrowernumber;
    return ( 0, 'item_denied_renewal') if $item->is_denied_renewal;

       # override_limit will override anything else except on_reserve
    unless ( $override_limit ){
        my $branchcode = _GetCircControlBranch( $item->unblessed, $patron->unblessed );
        my $issuing_rule = Koha::CirculationRules->get_effective_rules(
            {
                categorycode => $patron->categorycode,
                itemtype     => $item->effective_itemtype,
                branchcode   => $branchcode,
                rules => [
                    'renewalsallowed',
                    'lengthunit',
                    'unseen_renewals_allowed'
                ]
            }
        );

        return ( 0, "too_many" )
          if not $issuing_rule->{renewalsallowed} or $issuing_rule->{renewalsallowed} <= $issue->renewals_count;

        return ( 0, "too_unseen" )
          if C4::Context->preference('UnseenRenewals') &&
            looks_like_number($issuing_rule->{unseen_renewals_allowed}) &&
            $issuing_rule->{unseen_renewals_allowed} <= $issue->unseen_renewals;

        my $overduesblockrenewing = C4::Context->preference('OverduesBlockRenewing');
        my $restrictionblockrenewing = C4::Context->preference('RestrictionBlockRenewing');
        my $restricted  = $patron->is_debarred;
        my $hasoverdues = $patron->has_overdues;

        if ( $restricted and $restrictionblockrenewing ) {
            return ( 0, 'restriction');
        } elsif ( ($hasoverdues and $overduesblockrenewing eq 'block') || ($issue->is_overdue and $overduesblockrenewing eq 'blockitem') ) {
            return ( 0, 'overdue');
        }

        ( $auto_renew, $soonest ) = _CanBookBeAutoRenewed({
            patron     => $patron,
            item       => $item,
            branchcode => $branchcode,
            issue      => $issue
        });
        return ( 0, $auto_renew, { soonest_renew_date => $soonest } ) if $auto_renew =~ 'auto_too_soon' && $cron;
        # cron wants 'too_soon' over 'on_reserve' for performance and to avoid
        # extra notices being sent. Cron also implies no override
        return ( 0, $auto_renew  ) if $auto_renew =~ 'auto_account_expired';
        return ( 0, $auto_renew  ) if $auto_renew =~ 'auto_too_late';
        return ( 0, $auto_renew  ) if $auto_renew =~ 'auto_too_much_oweing';
    }

    if ( C4::Context->preference('UseRecalls') ) {
        my $recall = undef;
        $recall = $item->check_recalls if $item->can_be_waiting_recall;
        if ( defined $recall ) {
            if ( $recall->item_level ) {
                # item-level recall. check if this item is the recalled item, otherwise renewal will be allowed
                return ( 0, 'recalled' ) if ( $recall->item_id == $item->itemnumber );
            } else {
                # biblio-level recall, so only disallow renewal if the biblio-level recall has been fulfilled by a different item
                return ( 0, 'recalled' ) unless ( $recall->waiting );
            }
        }
    }

    # There is an item level hold on this item, no other item can fill the hold
    return ( 0, "on_reserve" )
      if ( $item->current_holds->search( { non_priority => 0 } )->count );

    my $fillable_holds = Koha::Holds->search(
        {
            biblionumber => $item->biblionumber,
            non_priority => 0,
            found        => undef,
            reservedate  => { '<=' => \'NOW()' },
            suspend      => 0
        }
    );
    if ( $fillable_holds->count ) {
        if ( C4::Context->preference('AllowRenewalIfOtherItemsAvailable') ) {
            my @possible_holds = $fillable_holds->as_list;

            # Get all other items that could possibly fill reserves
            # FIXME We could join reserves (or more tables) here to eliminate some checks later
            my @other_items = Koha::Items->search({
                biblionumber => $item->biblionumber,
                onloan       => undef,
                notforloan   => 0,
                -not         => { itemnumber => $item->itemnumber } })->as_list;

            return ( 0, "on_reserve" ) if @possible_holds && (scalar @other_items < scalar @possible_holds);

            my %matched_items;
            foreach my $possible_hold (@possible_holds) {
                my $fillable = 0;
                my $patron_with_reserve = Koha::Patrons->find($possible_hold->borrowernumber);
                my $items_any_available = ItemsAnyAvailableAndNotRestricted({
                    biblionumber => $item->biblionumber,
                    patron => $patron_with_reserve
                });

                # FIXME: We are not checking whether the item we are renewing can fill the hold

                foreach my $other_item (@other_items) {
                  next if defined $matched_items{$other_item->itemnumber};
                  next if IsItemOnHoldAndFound( $other_item->itemnumber );
                  next unless IsAvailableForItemLevelRequest($other_item, $patron_with_reserve, undef, $items_any_available);
                  next unless CanItemBeReserved($patron_with_reserve,$other_item,undef,{ignore_hold_counts=>1})->{status} eq 'OK';
                  # NOTE: At checkin we call 'CheckReserves' which checks hold 'policy'
                  # CanItemBeReserved checks 'rules' and 'policies' which means
                  # items will fill holds at checkin that are rejected here
                  $fillable = 1;
                  $matched_items{$other_item->itemnumber} = 1;
                  last;
                }
                return ( 0, "on_reserve" ) unless $fillable;
            }
        }
        else {
            my ($status, $matched_reserve, $possible_reserves) = CheckReserves($item);
            return ( 0, "on_reserve" ) if $status;
        }
    }

    return ( 0, $auto_renew, { soonest_renew_date => $soonest } ) if $auto_renew =~ 'too_soon';#$auto_renew ne "no" && $auto_renew ne "ok";
    $soonest = GetSoonestRenewDate($patron, $issue);
    if ( $soonest > dt_from_string() ){
        return (0, "too_soon", { soonest_renew_date => $soonest } ) unless $override_limit;
    }

    return ( 0, "auto_renew" ) if $auto_renew eq "ok" && !$override_limit; # 0 if auto-renewal should not succeed

    return ( 1, undef );
}

=head2 AddRenewal

  &AddRenewal($borrowernumber, $itemnumber, $branch, [$datedue], [$lastreneweddate], [$seen], [$automatic]);

Renews a loan.

C<$borrowernumber> is the borrower number of the patron who currently
has the item.

C<$itemnumber> is the number of the item to renew.

C<$branch> is the library where the renewal took place (if any).
           The library that controls the circ policies for the renewal is retrieved from the issues record.

C<$datedue> can be a DateTime object used to set the due date.

C<$lastreneweddate> is an optional ISO-formatted date used to set issues.lastreneweddate.  If
this parameter is not supplied, lastreneweddate is set to the current date.

C<$skipfinecalc> is an optional boolean. There may be circumstances where, even if the
CalculateFinesOnReturn syspref is enabled, we don't want to calculate fines upon renew,
for example, when we're renewing as a result of a fine being paid (see RenewAccruingItemWhenPaid
syspref)

If C<$datedue> is the empty string, C<&AddRenewal> will calculate the due date automatically
from the book's item type.

C<$seen> is a boolean flag indicating if the item was seen or not during the renewal. This
informs the incrementing of the unseen_renewals column. If this flag is not supplied, we
fallback to a true value

C<$automatic> is a boolean flag indicating the renewal was triggered automatically and not by a person ( librarian or patron )

C<$skip_record_index> is an optional boolean flag to indicate whether queuing the search indexing
should be skipped for this renewal.

=cut

sub AddRenewal {
    my $borrowernumber  = shift;
    my $itemnumber      = shift or return;
    my $branch          = shift;
    my $datedue         = shift;
    my $lastreneweddate = shift || dt_from_string();
    my $skipfinecalc    = shift;
    my $seen            = shift;
    my $automatic       = shift;
    my $skip_record_index = shift;

    # Fallback on a 'seen' renewal
    $seen = defined $seen && $seen == 0 ? 0 : 1;

    my $item_object   = Koha::Items->find($itemnumber) or return;
    my $biblio = $item_object->biblio;
    my $issue  = $item_object->checkout;
    my $item_unblessed = $item_object->unblessed;

    my $renewal_type = $automatic ? "Automatic" : "Manual";

    my $dbh = C4::Context->dbh;

    return unless $issue;

    $borrowernumber ||= $issue->borrowernumber;

    if ( defined $datedue && ref $datedue ne 'DateTime' ) {
        $datedue = dt_from_string($datedue, 'sql');
    }

    my $patron = Koha::Patrons->find( $borrowernumber ) or return; # FIXME Should do more than just return
    my $patron_unblessed = $patron->unblessed;

    my $circ_library = Koha::Libraries->find( _GetCircControlBranch($item_unblessed, $patron_unblessed) );

    my $schema = Koha::Database->schema;
    $schema->txn_do(sub{

        if ( !$skipfinecalc && C4::Context->preference('CalculateFinesOnReturn') ) {
            _CalculateAndUpdateFine( { issue => $issue, item => $item_unblessed, borrower => $patron_unblessed } );
        }
        _FixOverduesOnReturn( $borrowernumber, $itemnumber, undef, 'RENEWED' );

        # If the due date wasn't specified, calculate it by adding the
        # book's loan length to today's date or the current due date
        # based on the value of the RenewalPeriodBase syspref.
        my $itemtype = $item_object->effective_itemtype;
        unless ($datedue) {

            $datedue = (C4::Context->preference('RenewalPeriodBase') eq 'date_due') ?
                                            dt_from_string( $issue->date_due, 'sql' ) :
                                            dt_from_string();
            $datedue =  CalcDateDue($datedue, $itemtype, $circ_library->branchcode, $patron_unblessed, 'is a renewal');
        }

        my $fees = Koha::Charges::Fees->new(
            {
                patron    => $patron,
                library   => $circ_library,
                item      => $item_object,
                from_date => dt_from_string( $issue->date_due, 'sql' ),
                to_date   => dt_from_string($datedue),
            }
        );

        # Increment the unseen renewals, if appropriate
        # We only do so if the syspref is enabled and
        # a maximum value has been set in the circ rules
        my $unseen_renewals = $issue->unseen_renewals;
        if (C4::Context->preference('UnseenRenewals')) {
            my $rule = Koha::CirculationRules->get_effective_rule(
                {   categorycode => $patron->categorycode,
                    itemtype     => $item_object->effective_itemtype,
                    branchcode   => $circ_library->branchcode,
                    rule_name    => 'unseen_renewals_allowed'
                }
            );
            if (!$seen && $rule && looks_like_number($rule->rule_value)) {
                $unseen_renewals++;
            } else {
                # If the renewal is seen, unseen should revert to 0
                $unseen_renewals = 0;
            }
        }

        # Update the issues record to have the new due date, and a new count
        # of how many times it has been renewed.
        my $renews = ( $issue->renewals_count || 0 ) + 1;
        my $sth = $dbh->prepare("UPDATE issues SET date_due = ?, renewals_count = ?, unseen_renewals = ?, lastreneweddate = ? WHERE issue_id = ?");

        eval{
            $sth->execute( $datedue->strftime('%Y-%m-%d %H:%M'), $renews, $unseen_renewals, $lastreneweddate, $issue->issue_id );
        };
        if( $sth->err ){
            Koha::Exceptions::Checkout::FailedRenewal->throw(
                error => 'Update of issue# ' . $issue->issue_id . ' failed with error: ' . $sth->errstr
            );
        }

        # Update the renewal count on the item, and tell zebra to reindex
        $renews = ( $item_object->renewals || 0 ) + 1;
        $item_object->renewals($renews);
        $item_object->onloan($datedue);
        # Don't index as we are in a transaction, skip hardcoded here
        $item_object->store({ log_action => 0, skip_record_index => 1 });

        # Charge a new rental fee, if applicable
        my ( $charge, $type ) = GetIssuingCharges( $itemnumber, $borrowernumber );
        if ( $charge > 0 ) {
            AddIssuingCharge($issue, $charge, 'RENT_RENEW');
        }

        # Charge a new accumulate rental fee, if applicable
        my $itemtype_object = Koha::ItemTypes->find( $itemtype );
        if ( $itemtype_object ) {
            my $accumulate_charge = $fees->accumulate_rentalcharge();
            if ( $accumulate_charge > 0 ) {
                AddIssuingCharge( $issue, $accumulate_charge, 'RENT_DAILY_RENEW' )
            }
            $charge += $accumulate_charge;
        }

        # Send a renewal slip according to checkout alert preferencei
        if ( C4::Context->preference('RenewalSendNotice') eq '1' ) {
            my $circulation_alert = 'C4::ItemCirculationAlertPreference';
            my %conditions        = (
                branchcode   => $branch,
                categorycode => $patron->categorycode,
                item_type    => $itemtype,
                notification => 'CHECKOUT',
            );
            if ( $circulation_alert->is_enabled_for( \%conditions ) ) {
                SendCirculationAlert(
                    {
                        type     => 'RENEWAL',
                        item     => $item_unblessed,
                        borrower => $patron->unblessed,
                        branch   => $branch,
                    }
                );
            }
        }

        # Remove any OVERDUES related debarment if the borrower has no overdues
        my $overdue_restrictions = $patron->restrictions->search({ type => 'OVERDUES' });
        if ( $patron
          && $patron->is_debarred
          && ! $patron->has_overdues
          && $overdue_restrictions->count
        ) {
            DelUniqueDebarment({ borrowernumber => $borrowernumber, type => 'OVERDUES' });
        }

        # Add renewal record
        my $renewal = Koha::Checkouts::Renewal->new(
            {
                checkout_id  => $issue->issue_id,
                interface    => C4::Context->interface,
                renewal_type => $renewal_type,
                renewer_id   => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                seen         => $seen,
            }
        )->store();

        # Add the renewal to stats
        C4::Stats::UpdateStats(
            {
                branch         => $item_object->renewal_branchcode({branch => $branch}),
                type           => 'renew',
                amount         => $charge,
                itemnumber     => $itemnumber,
                itemtype       => $itemtype,
                location       => $item_object->location,
                borrowernumber => $borrowernumber,
                ccode          => $item_object->ccode,
                categorycode   => $patron->categorycode,
                interface      => C4::Context->interface,
            }
        );

        #Log the renewal
        logaction("CIRCULATION", "RENEWAL", $borrowernumber, $itemnumber) if C4::Context->preference("RenewalLog");

        Koha::Plugins->call('after_circ_action', {
            action  => 'renewal',
            payload => {
                checkout  => $issue->get_from_storage
            }
        });
    });

    unless( $skip_record_index ){
        # We index now, after the transaction is committed
        my $indexer = Koha::SearchEngine::Indexer->new({ index => $Koha::SearchEngine::BIBLIOS_INDEX });
        $indexer->index_records( $item_object->biblionumber, "specialUpdate", "biblioserver" );
    }

    return $datedue;
}

sub GetRenewCount {
    # check renewal status
    my ( $borrowernumber_or_patron, $itemnumber_or_item ) = @_;

    my $dbh           = C4::Context->dbh;
    my $renewcount    = 0;
    my $unseencount    = 0;
    my $renewsallowed = 0;
    my $unseenallowed = 0;
    my $renewsleft    = 0;
    my $unseenleft    = 0;
    my $patron = blessed $borrowernumber_or_patron ?
        $borrowernumber_or_patron : Koha::Patrons->find($borrowernumber_or_patron);
    my $item = blessed $itemnumber_or_item ?
        $itemnumber_or_item : Koha::Items->find($itemnumber_or_item);

    return (0, 0, 0, 0, 0, 0) unless $patron or $item; # Wrong call, no renewal allowed

    # Look in the issues table for this item, lent to this borrower,
    # and not yet returned.

    # FIXME - I think this function could be redone to use only one SQL call.
    my $sth = $dbh->prepare(q{
        SELECT * FROM issues
        WHERE  (borrowernumber = ?) AND (itemnumber = ?)
    });
    $sth->execute( $patron->borrowernumber, $item->itemnumber );
    my $data = $sth->fetchrow_hashref;
    $renewcount = $data->{'renewals_count'} if $data->{'renewals_count'};
    $unseencount = $data->{'unseen_renewals'} if $data->{'unseen_renewals'};
    # $item and $borrower should be calculated
    my $branchcode = _GetCircControlBranch($item->unblessed, $patron->unblessed);

    my $rules = Koha::CirculationRules->get_effective_rules(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->effective_itemtype,
            branchcode   => $branchcode,
            rules        => [ 'renewalsallowed', 'unseen_renewals_allowed' ]
        }
    );
    $renewsallowed = $rules ? $rules->{renewalsallowed} : 0;
    $unseenallowed = $rules->{unseen_renewals_allowed} ?
        $rules->{unseen_renewals_allowed} :
        0;
    $renewsleft    = $renewsallowed - $renewcount;
    $unseenleft    = $unseenallowed - $unseencount;
    if($renewsleft < 0){ $renewsleft = 0; }
    if($unseenleft < 0){ $unseenleft = 0; }
    return (
        $renewcount,
        $renewsallowed,
        $renewsleft,
        $unseencount,
        $unseenallowed,
        $unseenleft
    );
}

=head2 GetSoonestRenewDate

  $NoRenewalBeforeThisDate = &GetSoonestRenewDate($patron, $issue);

Find out the soonest possible renew date of a borrowed item.

C<$patron> is the patron who currently has the item on loan.

C<$issue> is the the item issue.

C<$GetSoonestRenewDate> returns the DateTime of the soonest possible
renew date, based on the value "No renewal before" of the applicable
issuing rule. Returns the current date if the item can already be
renewed, and returns undefined if the patron, item, or checkout
cannot be found.

=cut

sub GetSoonestRenewDate {
    my ( $patron, $issue ) = @_;
    return unless $issue;
    return unless $patron;

    my $item = $issue->item;
    return unless $item;

    my $dbh = C4::Context->dbh;

    my $branchcode = _GetCircControlBranch( $item->unblessed, $patron->unblessed );
    my $issuing_rule = Koha::CirculationRules->get_effective_rules(
        {   categorycode => $patron->categorycode,
            itemtype     => $item->effective_itemtype,
            branchcode   => $branchcode,
            rules => [
                'norenewalbefore',
                'lengthunit',
            ]
        }
    );

    my $now = dt_from_string;

    if ( defined $issuing_rule->{norenewalbefore}
        and $issuing_rule->{norenewalbefore} ne "" )
    {
        my $soonestrenewal =
          dt_from_string( $issue->date_due )->subtract(
            $issuing_rule->{lengthunit} => $issuing_rule->{norenewalbefore} );

        if ( C4::Context->preference('NoRenewalBeforePrecision') eq 'date'
            and $issuing_rule->{lengthunit} eq 'days' )
        {
            $soonestrenewal->truncate( to => 'day' );
        }
        return $soonestrenewal if $now < $soonestrenewal;
    } elsif ( $issue->auto_renew && $patron->autorenew_checkouts ) {
        # Checkouts with auto-renewing fall back to due date
        my $soonestrenewal = dt_from_string( $issue->date_due );
        if ( C4::Context->preference('NoRenewalBeforePrecision') eq 'date'
            and $issuing_rule->{lengthunit} eq 'days' )
        {
            $soonestrenewal->truncate( to => 'day' );
        }
        return $soonestrenewal;
    }
    return $now;
}

=head2 GetLatestAutoRenewDate

  $NoAutoRenewalAfterThisDate = &GetLatestAutoRenewDate($patron, $issue);

Find out the latest possible auto renew date of a borrowed item.

C<$patron> is the patron who currently has the item on loan.

C<$issue> is the item issue.

C<$GetLatestAutoRenewDate> returns the DateTime of the latest possible
auto renew date, based on the value "No auto renewal after" and the "No auto
renewal after (hard limit) of the applicable issuing rule.
Returns undef if there is no date specify in the circ rules or if the patron, loan,
or item cannot be found.

=cut

sub GetLatestAutoRenewDate {
    my ( $patron, $issue ) = @_;
    return unless $issue;
    return unless $patron;

    my $item = $issue->item;
    return unless $item;

    my $dbh = C4::Context->dbh;

    my $branchcode = _GetCircControlBranch( $item->unblessed, $patron->unblessed );
    my $circulation_rules = Koha::CirculationRules->get_effective_rules(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->effective_itemtype,
            branchcode   => $branchcode,
            rules => [
                'no_auto_renewal_after',
                'no_auto_renewal_after_hard_limit',
                'lengthunit',
            ]
        }
    );

    return unless $circulation_rules;
    return
      if ( not $circulation_rules->{no_auto_renewal_after}
            or $circulation_rules->{no_auto_renewal_after} eq '' )
      and ( not $circulation_rules->{no_auto_renewal_after_hard_limit}
             or $circulation_rules->{no_auto_renewal_after_hard_limit} eq '' );

    my $maximum_renewal_date;
    if ( $circulation_rules->{no_auto_renewal_after} ) {
        $maximum_renewal_date = dt_from_string($issue->issuedate);
        $maximum_renewal_date->add(
            $circulation_rules->{lengthunit} => $circulation_rules->{no_auto_renewal_after}
        );
    }

    if ( $circulation_rules->{no_auto_renewal_after_hard_limit} ) {
        my $dt = dt_from_string( $circulation_rules->{no_auto_renewal_after_hard_limit} );
        $maximum_renewal_date = $dt if not $maximum_renewal_date or $maximum_renewal_date > $dt;
    }
    return $maximum_renewal_date;
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
    my $patron;
    if ( my $item_data = $sth->fetchrow_hashref ) {
        $item_type = $item_data->{itemtype};
        $charge    = $item_data->{rentalcharge};
        if ($charge) {
            # FIXME This should follow CircControl
            my $branch = C4::Context::mybranch();
            $patron //= Koha::Patrons->find( $borrowernumber );
            my $discount = Koha::CirculationRules->get_effective_rule({
                categorycode => $patron->categorycode,
                branchcode   => $branch,
                itemtype     => $item_type,
                rule_name    => 'rentaldiscount'
            });
            if ($discount) {
                $charge = ( $charge * ( 100 - $discount->rule_value ) ) / 100;
            }
            $charge = sprintf '%.2f', $charge; # ensure no fractions of a penny returned
        }
    }

    return ( $charge, $item_type );
}

=head2 AddIssuingCharge

  &AddIssuingCharge( $checkout, $charge, $type )

=cut

sub AddIssuingCharge {
    my ( $checkout, $charge, $type ) = @_;

    # FIXME What if checkout does not exist?

    my $account = Koha::Account->new({ patron_id => $checkout->borrowernumber });
    my $accountline = $account->add_debit(
        {
            amount      => $charge,
            note        => undef,
            user_id     => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
            library_id  => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
            interface   => C4::Context->interface,
            type        => $type,
            item_id     => $checkout->itemnumber,
            issue_id    => $checkout->issue_id,
        }
    );
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
        SELECT branchtransfer_id,itemnumber,datesent,frombranch
        FROM   branchtransfers
        WHERE  frombranch=?
          AND  tobranch=?
          AND datecancelled IS NULL
          AND datesent IS NOT NULL
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
    my ($type, $item, $borrower, $branch, $issue) =
        ($opts->{type}, $opts->{item}, $opts->{borrower}, $opts->{branch}, $opts->{issue});
    my %message_name = (
        CHECKIN  => 'Item_Check_in',
        CHECKOUT => 'Item_Checkout',
        RENEWAL  => 'Item_Checkout',
    );
    my $borrower_preferences = C4::Members::Messaging::GetMessagingPreferences({
        borrowernumber => $borrower->{borrowernumber},
        message_name   => $message_name{$type},
    });


    my $tables = {
        items => $item->{itemnumber},
        biblio      => $item->{biblionumber},
        biblioitems => $item->{biblionumber},
        borrowers   => $borrower,
        branches    => $branch,
    };

    # TODO: Currently, we need to pass an issue_id as identifier for old_issues, but still an itemnumber for issues.
    # See C4::Letters:: _parseletter_sth
    if( $type eq 'CHECKIN' ){
        $tables->{old_issues} = $issue->issue_id;
    } else {
        $tables->{issues} = $item->{itemnumber};
    }

    my $schema = Koha::Database->new->schema;
    my @transports = keys %{ $borrower_preferences->{transports} };

    # From the MySQL doc:
    # LOCK TABLES is not transaction-safe and implicitly commits any active transaction before attempting to lock the tables.
    # If the LOCK/UNLOCK statements are executed from tests, the current transaction will be committed.
    # To avoid that we need to guess if this code is execute from tests or not (yes it is a bit hacky)
    my $do_not_lock = ( exists $ENV{_} && $ENV{_} =~ m|prove| ) || $ENV{KOHA_TESTING};

    for my $mtt (@transports) {
        my $letter =  C4::Letters::GetPreparedLetter (
            module => 'circulation',
            letter_code => $type,
            branchcode => $branch,
            message_transport_type => $mtt,
            lang => $borrower->{lang},
            tables => $tables,
        ) or next;

        C4::Context->dbh->do(q|LOCK TABLE message_queue READ|) unless $do_not_lock;
        C4::Context->dbh->do(q|LOCK TABLE message_queue WRITE|) unless $do_not_lock;
        my $message = C4::Message->find_last_message($borrower, $type, $mtt);
        unless ( $message ) {
            C4::Context->dbh->do(q|UNLOCK TABLES|) unless $do_not_lock;
            my $patron = Koha::Patrons->find($borrower->{borrowernumber});
            C4::Message->enqueue($letter, $patron, $mtt);
        } else {
            $message->append($letter);
            $message->update;
        }
        C4::Context->dbh->do(q|UNLOCK TABLES|) unless $do_not_lock;
    }

    return;
}

=head2 updateWrongTransfer

  $items = updateWrongTransfer($itemNumber,$borrowernumber,$waitingAtLibrary,$FromLibrary);

This function validate the line of brachtransfer but with the wrong destination (mistake from a librarian ...), and create a new line in branchtransfer from the actual library to the original library of reservation 

=cut

sub updateWrongTransfer {
	my ( $itemNumber,$waitingAtLibrary,$FromLibrary ) = @_;

    # first step: cancel the original transfer
    my $item = Koha::Items->find($itemNumber);
    my $transfer = $item->get_transfer;
    $transfer->set({ datecancelled => dt_from_string, cancellation_reason => 'WrongTransfer' })->store();

    # second step: create a new transfer to the right location
    my $new_transfer = $item->request_transfer(
        {
            to            => $transfer->to_library,
            reason        => $transfer->reason,
            comment       => $transfer->comments,
            ignore_limits => 1,
            enqueue       => 1
        }
    );

    return $new_transfer;
}

=head2 CalcDateDue

$newdatedue = CalcDateDue($startdate,$itemtype,$branchcode,$borrower);

this function calculates the due date given the start date and configured circulation rules,
checking against the holidays calendar as per the daysmode circulation rule.
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

    my $length_key = ( $isrenewal and defined $loanlength->{renewalperiod} and $loanlength->{renewalperiod} ne q{} )
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
        $datedue = dt_from_string()->truncate( to => 'minute' );
    }


    my $daysmode = Koha::CirculationRules->get_effective_daysmode(
        {
            categorycode => $borrower->{categorycode},
            itemtype     => $itemtype,
            branchcode   => $branch,
        }
    );

    # calculate the datedue as normal
    if ( $daysmode eq 'Days' )
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
        my $calendar = Koha::Calendar->new( branchcode => $branch, days_mode => $daysmode );
        $datedue = $calendar->addDuration( $datedue, $dur, $loanlength->{lengthunit} );
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
        if ( $daysmode ne 'Days' ) {
          my $calendar = Koha::Calendar->new( branchcode => $branch, days_mode => $daysmode );
          if ( $calendar->is_holiday($datedue) ) {
              # Don't return on a closed day
              $datedue = $calendar->prev_open_days( $datedue, 1 );
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

Deprecated in favor of Koha::Item::Transfer::Limits->find/search and
Koha::Item->can_be_transferred.

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

Deprecated in favor of Koha::Item::Transfer::Limit->new.

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

Deprecated in favor of Koha::Item::Transfer::Limits->search({
    fromBranch => $fromBranch
    })->delete.

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
}

=head2 LostItem

  LostItem( $itemnumber, $mark_lost_from, $force_mark_returned, [$params] );

The final optional parameter, C<$params>, expected to contain
'skip_record_index' key, which relayed down to Koha::Item/store,
there it prevents calling of ModZebra index_records,
which takes most of the time in batch adds/deletes: index_records better
to be called later in C<additem.pl> after the whole loop.

$params:
    skip_record_index => 1|0

=cut

sub LostItem{
    my ($itemnumber, $mark_lost_from, $force_mark_returned, $params) = @_;

    unless ( $mark_lost_from ) {
        # Temporary check to avoid regressions
        die q|LostItem called without $mark_lost_from, check the API.|;
    }

    my $mark_returned;
    if ( $force_mark_returned ) {
        $mark_returned = 1;
    } else {
        my $pref = C4::Context->preference('MarkLostItemsAsReturned') // q{};
        $mark_returned = ( $pref =~ m|$mark_lost_from| );
    }

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
        my $patron = Koha::Patrons->find( $borrowernumber );

        my $fix = _FixOverduesOnReturn($borrowernumber, $itemnumber, C4::Context->preference('WhenLostForgiveFine'), 'LOST');
        defined($fix) or warn "_FixOverduesOnReturn($borrowernumber, $itemnumber...) failed!";  # zero is OK, check defined

        if (C4::Context->preference('WhenLostChargeReplacementFee')){
            C4::Accounts::chargelostitem(
                $borrowernumber,
                $itemnumber,
                $issues->{'replacementprice'},
                sprintf( "%s %s %s",
                    $issues->{'title'}          || q{},
                    $issues->{'barcode'}        || q{},
                    $issues->{'itemcallnumber'} || q{},
                ),
            );
            #FIXME : Should probably have a way to distinguish this from an item that really was returned.
            #warn " $issues->{'borrowernumber'}  /  $itemnumber ";
        }

        MarkIssueReturned($borrowernumber,$itemnumber,undef,$patron->privacy,$params) if $mark_returned;
    }

    # When an item is marked as lost, we should automatically cancel its outstanding transfers.
    my $item = Koha::Items->find($itemnumber);
    my $transfers = $item->get_transfers;
    while (my $transfer = $transfers->next) {
        $transfer->cancel({ reason => 'ItemLost', force => 1 });
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

    my $item = Koha::Items->find({barcode => $operation->{barcode}});

    if ( $item ) {
        my $itemnumber = $item->itemnumber;
        my $issue = $item->checkout;
        if ( $issue ) {
            my $leave_item_lost = C4::Context->preference("BlockReturnOfLostItems") ? 1 : 0;
            ModDateLastSeen( $itemnumber, $leave_item_lost );
            MarkIssueReturned(
                $issue->borrowernumber,
                $itemnumber,
                $operation->{timestamp},
            );
            $item->onloan(undef);
            $item->store({ log_action => 0 });
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

    my $patron = Koha::Patrons->find( { cardnumber => $operation->{cardnumber} } );

    if ( $patron ) {
        my $item = Koha::Items->find({ barcode => $operation->{barcode} });
        unless ($item) {
            return "Barcode not found.";
        }
        my $itemnumber = $item->itemnumber;
        my $issue = $item->checkout;

        if ( $issue and ( $issue->borrowernumber ne $patron->borrowernumber ) ) { # Item already issued to another patron mark it returned
            MarkIssueReturned(
                $issue->borrowernumber,
                $itemnumber,
                $operation->{timestamp},
            );
        }
        AddIssue(
            $patron->unblessed,
            $operation->{'barcode'},
            undef,
            undef,
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

    my $patron = Koha::Patrons->find({ cardnumber => $operation->{cardnumber} });

    $patron->account->pay(
        {
            amount     => $operation->{amount},
            library_id => $operation->{branchcode},
            interface  => 'koc'
        }
    );

    return "Success.";
}

=head2 TransferSlip

  TransferSlip($user_branch, $itemnumber, $barcode, $to_branch)

  Returns letter hash ( see C4::Letters::GetPreparedLetter ) or undef

=cut

sub TransferSlip {
    my ($branch, $itemnumber, $barcode, $to_branch) = @_;

    my $item =
      $itemnumber
      ? Koha::Items->find($itemnumber)
      : Koha::Items->find( { barcode => $barcode } );

    $item or return;

    return C4::Letters::GetPreparedLetter (
        module => 'circulation',
        letter_code => 'TRANSFERSLIP',
        branchcode => $branch,
        tables => {
            'branches'    => $to_branch,
            'biblio'      => $item->biblionumber,
            'items'       => $item->unblessed,
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

  if($daysToAgeRestriction <= 0) { #Borrower is allowed to access this material, as they are older or as old as the agerestriction }
  if($daysToAgeRestriction > 0) { #Borrower is this many days from meeting the agerestriction }

@PARAM1 the koha.biblioitems.agerestriction value, like K18, PEGI 13, ...
@PARAM2 a borrower-object with koha.borrowers.dateofbirth. (OPTIONAL)
@RETURNS The age restriction age in years and the days to fulfill the age restriction for the given borrower.
         Negative days mean the borrower has gone past the age restriction age.

=cut

sub GetAgeRestriction {
    my ($record_restrictions, $borrower) = @_;
    my $markers = C4::Context->preference('AgeRestrictionMarker');

    return unless $record_restrictions;
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
            my @Today = split /-/, dt_from_string()->ymd();
            my $daysToAgeRestriction = Date_to_Days(@alloweddate) - Date_to_Days(@Today);
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
        SELECT * FROM (
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
        GROUP BY b.biblionumber, b.title, b.author, bi.itemtype, bi.publishercode,
          bi.place, bi.publicationyear, b.copyrightdate, bi.pages, bi.size,
          i.ccode
        ORDER BY count DESC
    };

    $query .= q{ ) xxx WHERE count > 0 };
    $count = int($count);
    if ($count > 0) {
        $query .= "LIMIT $count";
    }

    my $rows = $dbh->selectall_arrayref($query, { Slice => {} }, @where_args);

    return @$rows;
}

=head2 Internal methods

=cut

sub _CalculateAndUpdateFine {
    my ($params) = @_;

    my $borrower    = $params->{borrower};
    my $item        = $params->{item};
    my $issue       = $params->{issue};
    my $return_date = $params->{return_date};

    unless ($borrower) { carp "No borrower passed in!" && return; }
    unless ($item)     { carp "No item passed in!"     && return; }
    unless ($issue)    { carp "No issue passed in!"    && return; }

    my $datedue = dt_from_string( $issue->date_due );

    # we only need to calculate and change the fines if we want to do that on return
    # Should be on for hourly loans
    my $control = C4::Context->preference('CircControl');
    my $branch_type = C4::Context->preference('HomeOrHoldingBranch') || 'homebranch';
    my $control_branchcode =
        ( $control eq 'ItemHomeLibrary' ) ? $item->{$branch_type}
      : ( $control eq 'PatronLibrary' )   ? $borrower->{branchcode}
      :                                     $issue->branchcode;

    my $date_returned = $return_date ? $return_date : dt_from_string();

    my ( $amount, $unitcounttotal, $unitcount  ) =
      C4::Overdues::CalcFine( $item, $borrower->{categorycode}, $control_branchcode, $datedue, $date_returned );

    if ( C4::Context->preference('finesMode') eq 'production' ) {
        if ( $amount > 0 ) {
            C4::Overdues::UpdateFine({
                issue_id       => $issue->issue_id,
                itemnumber     => $issue->itemnumber,
                borrowernumber => $issue->borrowernumber,
                amount         => $amount,
                due            => $datedue,
            });
        }
        elsif ($return_date) {

            # Backdated returns may have fines that shouldn't exist,
            # so in this case, we need to drop those fines to 0

            C4::Overdues::UpdateFine({
                issue_id       => $issue->issue_id,
                itemnumber     => $issue->itemnumber,
                borrowernumber => $issue->borrowernumber,
                amount         => 0,
                due            => $datedue,
            });
        }
    }
}

sub _CanBookBeAutoRenewed {
    my ( $params ) = @_;
    my $patron = $params->{patron};
    my $item = $params->{item};
    my $branchcode = $params->{branchcode};
    my $issue = $params->{issue};

    return "no" unless $issue->auto_renew && $patron->autorenew_checkouts;

    my $issuing_rule = Koha::CirculationRules->get_effective_rules(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->effective_itemtype,
            branchcode   => $branchcode,
            rules => [
                'no_auto_renewal_after',
                'no_auto_renewal_after_hard_limit',
                'lengthunit',
                'norenewalbefore',
            ]
        }
    );

    if ( $patron->is_expired && $patron->category->effective_BlockExpiredPatronOpacActions ) {
        return 'auto_account_expired';
    }

    if ( defined $issuing_rule->{no_auto_renewal_after}
            and $issuing_rule->{no_auto_renewal_after} ne "" ) {
        # Get issue_date and add no_auto_renewal_after
        # If this is greater than today, it's too late for renewal.
        my $maximum_renewal_date = dt_from_string($issue->issuedate, 'sql');
        $maximum_renewal_date->add(
            $issuing_rule->{lengthunit} => $issuing_rule->{no_auto_renewal_after}
        );
        my $now = dt_from_string;
        if ( $now >= $maximum_renewal_date ) {
            return "auto_too_late";
        }
    }
    if ( defined $issuing_rule->{no_auto_renewal_after_hard_limit}
                  and $issuing_rule->{no_auto_renewal_after_hard_limit} ne "" ) {
        # If no_auto_renewal_after_hard_limit is >= today, it's also too late for renewal
        if ( dt_from_string >= dt_from_string( $issuing_rule->{no_auto_renewal_after_hard_limit} ) ) {
            return "auto_too_late";
        }
    }

    if ( C4::Context->preference('OPACFineNoRenewalsBlockAutoRenew') ) {
        my $fine_no_renewals = C4::Context->preference("OPACFineNoRenewals");
        my $amountoutstanding =
          C4::Context->preference("OPACFineNoRenewalsIncludeCredit")
          ? $patron->account->balance
          : $patron->account->outstanding_debits->total_outstanding;
        if ( $amountoutstanding and $amountoutstanding > $fine_no_renewals ) {
            return "auto_too_much_oweing";
        }
    }

    my $soonest = GetSoonestRenewDate($patron, $issue);
    if ( $soonest > dt_from_string() )
    {
        return ( "auto_too_soon", $soonest );
    }

    return "ok";
}


1;

__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
