#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#           2006 SAN-OP
#           2007-2010 BibLibre, Paul POULAIN
#           2010 Catalyst IT
#           2011 PTFS-Europe Ltd.
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

=head1 returns.pl

script to execute returns of books

=cut

use Modern::Perl;

# FIXME There are weird things going on with $patron and $borrowernumber in this script

use CGI qw ( -utf8 );
use DateTime;

use C4::Auth        qw( get_template_and_user get_session haspermission );
use C4::Circulation qw( barcodedecode GetBranchItemRule AddReturn LostItem );
use C4::Context;
use C4::Members::Messaging;
use C4::Members;
use C4::Output   qw( output_html_with_http_headers );
use C4::Reserves qw( ModReserve ModReserveAffect CheckReserves );
use C4::RotatingCollections;
use Koha::AuthorisedValues;
use Koha::BiblioFrameworks;
use Koha::Calendar;
use Koha::Checkouts;
use Koha::CirculationRules;
use Koha::DateUtils qw( dt_from_string );
use Koha::Holds;
use Koha::Item::Transfers;
use Koha::Items;
use Koha::Patrons;
use Koha::Recalls;

my $query = CGI->new;

#getting the template
my ( $template, $librarian, $cookie, $flags ) = get_template_and_user(
    {
        template_name => "circ/returns.tt",
        query         => $query,
        type          => "intranet",
        flagsrequired => { circulate => "circulate_remaining_permissions" },
    }
);

my $sessionID = $query->cookie("CGISESSID");
my $session   = get_session($sessionID);
my $desk_id   = C4::Context->userenv->{"desk_id"} || '';

# Print a reserve slip on this page
if ( $query->param('print_slip') ) {
    $template->param(
        print_slip => 1,
        reserve_id => scalar $query->param('reserve_id'),
    );
}

# print a recall slip
if ( $query->param('recall_slip') ) {
    $template->param(
        recall_slip => 1,
        recall_id   => scalar $query->param('recall_id'),
    );
}

#####################
#Global vars
my $userenv                  = C4::Context->userenv;
my $userenv_branch           = $userenv->{'branch'} // '';
my $forgivemanualholdsexpire = $query->param('forgivemanualholdsexpire');

my $overduecharges = ( C4::Context->preference('finesMode') && C4::Context->preference('finesMode') eq 'production' );

#set up so only the last 8 returned items display (make for faster loading pages)
my $returned_counter = C4::Context->preference('numReturnedItemsToShow') || 8;

# Set up the item stack ....
my @checkins;
my $i;
for my $counter ( $query->multi_param("checkin_counter") ) {
    push @checkins, {
        barcode        => scalar $query->param("checkin_barcode_$counter"),
        duedate        => scalar $query->param("checkin_duedate_$counter"),
        borrowernumber => scalar $query->param("checkin_borrowernumber_$counter"),
        not_returned   => scalar $query->param("checkin_not_returned_$counter"),
    };

    last if ++$i >= $returned_counter;
}

my $op = $query->param('op') // '';

############
# Deal with the requests....
my $itemnumber = $query->param('itemnumber');
if ( $query->param('reserve_id') && $op eq 'cud-affect_reserve' ) {
    my $borrowernumber     = $query->param('borrowernumber');
    my $reserve_id         = $query->param('reserve_id');
    my $diffBranchReturned = $query->param('diffBranch');
    my $cancel_reserve     = $query->param('cancel_reserve');
    my $cancel_reason      = $query->param('cancel_reason');

    # fix up item type for display
    my $item   = Koha::Items->find($itemnumber);
    my $biblio = $item->biblio;
    my $hold   = Koha::Holds->find($reserve_id) or die "Hold for item $itemnumber not found\n";   #TODO Not very elegant

    if ($cancel_reserve) {
        $hold->cancel( { charge_cancel_fee => !$forgivemanualholdsexpire, cancellation_reason => $cancel_reason } );

        # check if we have other reserves for this document, if we have a result send the message of transfer
        my ( undef, $nextreservinfo, undef ) = CheckReserves( $item, C4::Context->preference('ConfirmFutureHolds') );
        if ( $userenv_branch ne $nextreservinfo->{'branchcode'} ) {
            my $patron = Koha::Patrons->find( $nextreservinfo->{'borrowernumber'} );
            $template->param(
                itemtitle        => $biblio->title,
                itembiblionumber => $biblio->biblionumber,
                iteminfo         => $biblio->author,
                patron           => $patron,
                diffbranch       => 1,
            );
        }
    } else {
        my $diffBranchSend = ( $userenv_branch ne $diffBranchReturned ) ? $diffBranchReturned : undef;

        # diffBranchSend tells ModReserveAffect whether document is expected in this library or not,
        # i.e., whether to apply waiting status
        ModReserveAffect( $itemnumber, $borrowernumber, $diffBranchSend, $reserve_id, $desk_id );

        if ($diffBranchSend) {
            my $tobranch = $hold->pickup_library();

            # Add transfer, enqueue if one is already in the queue, and immediately set to in transit
            my $transfer = $item->request_transfer( { to => $tobranch, reason => 'Reserve', enqueue => 1 } );
            $transfer->transit;
        }
    }
}

if ( $query->param('recall_id') && $op eq 'cud-affect_recall' ) {
    my $recall        = Koha::Recalls->find( scalar $query->param('recall_id') );
    my $itemnumber    = $query->param('itemnumber');
    my $return_branch = $query->param('returnbranch');

    if ($recall) {
        my $item;
        if ( !$recall->item_level ) {
            $item = Koha::Items->find($itemnumber);
        }

        if ( $recall->pickup_library_id ne $return_branch ) {
            $recall->start_transfer( { item => $item } ) if !$recall->in_transit;
        } else {
            my $expirationdate = $recall->calc_expirationdate;
            $recall->set_waiting( { item => $item, expirationdate => $expirationdate } ) if !$recall->waiting;
        }
    }
}

my $borrower;
my $returned = 0;
my $messages;
my $issue;
my $barcode    = $query->param('barcode');
my $exemptfine = $query->param('exemptfine');
if ( $exemptfine
    && !C4::Auth::haspermission( C4::Context->userenv->{'id'}, { 'updatecharges' => 'writeoff' } ) )
{
    # silently prevent unauthorized operator from forgiving overdue
    # fines by manually tweaking form parameters
    undef $exemptfine;
}
my $dropboxmode    = $query->param('dropboxmode');
my $canceltransfer = $query->param('canceltransfer');
my $transit        = $query->param('transit');
my $dest           = $query->param('dest');

#dropbox: get last open day (today - 1)
my $dropboxdate = Koha::Checkouts::calculate_dropbox_date();

my $return_date_override = $query->param('return_date_override') || q{};
if ($return_date_override) {
    if ( C4::Context->preference('SpecifyReturnDate') ) {

        # note that we've overridden the return date
        $template->param( return_date_was_overriden => 1 );

        my $return_date_override_remember = $query->param('return_date_override_remember');

        # Save the original format if we are remembering for this series
        $template->param(
            return_date_override          => $return_date_override,
            return_date_override_remember => 1
        ) if ($return_date_override_remember);
    }
}

# If 'needstransfer' was set and the librarian has chosen to initiate the transfer
if ( $op eq 'cud-dotransfer' ) {

    my $transferitem = $query->param('transferitem');
    my $item         = Koha::Items->find($transferitem);
    my $tobranchcode = $query->param('tobranch');
    my $tobranch     = Koha::Libraries->find($tobranchcode);
    my $trigger      = $query->param('trigger');
    my $transfer     = $item->request_transfer( { to => $tobranch, reason => $trigger } );
    $transfer->transit;
}

if ( $op eq 'cud-ignore_reserve' ) {
    my $ignored_item = $query->param('ignoreitem');
    my $item         = Koha::Items->find($ignored_item);
    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $item->biblionumber ] } )
        if C4::Context->preference('RealTimeHoldsQueue');

}

if ( $transit && $op eq 'cud-transfer' ) {
    my $transfer = Koha::Item::Transfers->find($transit);
    if ($canceltransfer) {
        $transfer->cancel( { reason => 'Manual', force => 1 } );
        if ( C4::Context->preference('UseRecalls') ) {
            my $recall_transfer_deleted = Koha::Recalls->find( { item_id => $itemnumber, status => 'in_transit' } );
            if ( defined $recall_transfer_deleted ) {
                $recall_transfer_deleted->revert_transfer;
            }
        }
        $template->param( transfercancelled => 1 );
    } else {
        $transfer->transit;
    }
} elsif ($canceltransfer) {
    my $item     = Koha::Items->find($itemnumber);
    my $transfer = $item->get_transfer;
    $transfer->cancel( { reason => 'Manual', force => 1 } );
    if ( C4::Context->preference('UseRecalls') ) {
        my $recall_transfer_deleted = Koha::Recalls->find( { item_id => $itemnumber, status => 'in_transit' } );
        if ( defined $recall_transfer_deleted ) {
            $recall_transfer_deleted->revert_transfer;
        }
    }
    if ( $dest eq "ttr" ) {
        print $query->redirect("/cgi-bin/koha/circ/transferstoreceive.pl");
        exit;
    } else {
        $template->param( transfercancelled => 1 );
    }
}

# actually return book and prepare item table.....
my $returnbranch;
if ( $barcode && ( $op eq 'cud-checkin' || $op eq 'cud-affect_reserve' ) ) {
    $barcode = barcodedecode($barcode) if $barcode;
    my $item = Koha::Items->find( { barcode => $barcode } );

    if ($item) {
        $itemnumber = $item->itemnumber;

        # Check if we should display a checkin message, based on the the item
        # type of the checked in item
        my $itemtype = Koha::ItemTypes->find( $item->effective_itemtype );
        if ( $itemtype && $itemtype->checkinmsg ) {
            $template->param(
                checkinmsg     => $itemtype->checkinmsg,
                checkinmsgtype => $itemtype->checkinmsgtype,
            );
        }

        # make sure return branch respects home branch circulation rules, default to homebranch
        my $hbr = Koha::CirculationRules->get_return_branch_policy($item);
        my $validate_float =
            Koha::Libraries->find( $item->homebranch )->validate_float_sibling( { branchcode => $userenv_branch } );

        # get the proper branch to which to return the item
        # if library isn't in same the float group, transfer item to homelibrary
        $returnbranch =
              $hbr eq 'noreturn'
            ? $userenv_branch
            : $hbr eq 'returnbylibrarygroup' ? $validate_float
                ? $userenv_branch
                : $item->homebranch
            : $item->$hbr;
        my $materials    = $item->materials;
        my $descriptions = Koha::AuthorisedValues->get_description_by_koha_field(
            { frameworkcode => '', kohafield => 'items.materials', authorised_value => $materials } );
        $materials = $descriptions->{lib} // $materials;

        my $checkout = $item->checkout;
        my $biblio   = $item->biblio;
        $template->param(
            title                => $biblio->title,
            returnbranch         => $returnbranch,
            author               => $biblio->author,
            itembiblionumber     => $biblio->biblionumber,
            biblionumber         => $biblio->biblionumber,
            additional_materials => $materials,
            issue                => $checkout,
            item                 => $item,
        );
    }    # FIXME else we should not call AddReturn but set BadBarcode directly instead

    my %input = (
        counter => 0,
        first   => 1,
        barcode => $barcode,
    );

    my $return_date =
          $dropboxmode
        ? $dropboxdate
        : dt_from_string($return_date_override);

    # Block return if multi-part and confirm has not been received
    my $needs_confirm =
           C4::Context->preference("CircConfirmItemParts")
        && $item
        && $item->materials
        && !$query->param('multiple_confirm');
    $template->param( 'multiple_confirmed' => 1 )
        if $query->param('multiple_confirm');

    # Block return if bundle and confirm has not been received
    my $bundle_confirm =
           $item
        && $item->is_bundle
        && !$query->param('confirm_items_bundle_return');
    $template->param( 'confirm_items_bundle_returned' => 1 )
        if $query->param('confirm_items_bundle_return');

    # is there a waiting hold for the item, for which cancellation
    # has been requested?
    if ($item) {
        my $waiting_holds_to_be_cancelled = $item->holds->waiting->filter_by_has_cancellation_requests;
        while ( my $hold = $waiting_holds_to_be_cancelled->next ) {
            $hold->cancel;
        }
    }

    # do the return
    ( $returned, $messages, $issue, $borrower ) = AddReturn( $barcode, $userenv_branch, $exemptfine, $return_date )
        unless ( $needs_confirm || $bundle_confirm );

    if ($returned) {
        my $date_due_dt = dt_from_string( $issue->date_due, 'sql' );

        unshift @checkins, {
            barcode        => $barcode,
            duedate        => $issue ? $issue->date_due       : undef,
            borrowernumber => $issue ? $issue->borrowernumber : undef,
            not_returned   => 0,
        };

        if ( C4::Context->preference("FineNotifyAtCheckin") ) {
            my $patron  = Koha::Patrons->find( $borrower->{borrowernumber} );
            my $balance = $patron->account->balance;

            if ( $balance > 0 ) {
                $template->param( fines              => sprintf( "%.2f", $balance ) );
                $template->param( fineborrowernumber => $borrower->{'borrowernumber'} );
            }
        }

        if ( C4::Context->preference("WaitingNotifyAtCheckin") ) {

            #Check for waiting holds
            my $patron        = Koha::Patrons->find( $borrower->{borrowernumber} );
            my $waiting_holds = $patron->holds->search( { found => 'W', branchcode => $userenv_branch } )->count;
            if ( $waiting_holds > 0 ) {
                $template->param(
                    waiting_holds       => $waiting_holds,
                    holdsborrowernumber => $borrower->{'borrowernumber'},
                    holdsfirstname      => $borrower->{'firstname'},
                    holdssurname        => $borrower->{'surname'},
                );
            }
        }

    } elsif ( C4::Context->preference('ShowAllCheckins')
        and !$messages->{'BadBarcode'}
        and !$needs_confirm
        and !$bundle_confirm )
    {
        unshift @checkins, {
            barcode        => $barcode,
            duedate        => $issue ? $issue->date_due       : undef,
            borrowernumber => $issue ? $issue->borrowernumber : undef,
            not_returned   => 1,
        };
    }
    $template->param( privacy => $borrower->{privacy} );

    if ($needs_confirm) {
        $template->param( needs_confirm => $needs_confirm );
    }

    if ($bundle_confirm) {
        $template->param(
            items_bundle_return_confirmation => 1,
        );
    }

    # Mark missing bundle items as lost and report unexpected items
    if (   $item
        && $item->is_bundle
        && $query->param('confirm_items_bundle_return')
        && !$query->param('do_not_verify_items_bundle_contents') )
    {
        my $BundleLostValue = C4::Context->preference('BundleLostValue');
        my $barcodes        = $query->param('verify-items-bundle-contents-barcodes');
        my @barcodes        = map { s/^\s+|\s+$//gr } ( split /\n/, $barcodes );
        my $expected_items  = { map { $_->barcode => $_ } $item->bundle_items->as_list };
        my $verify_items    = Koha::Items->search( { barcode => { 'in' => \@barcodes } } );
        my @unexpected_items;
        my @missing_items;
        my @bundle_items;

        while ( my $verify_item = $verify_items->next ) {

            # Fix and lost statuses
            $verify_item->itemlost(0);

            # Update last_seen
            $verify_item->datelastseen( dt_from_string() );

            # Update last_borrowed if actual checkin
            $verify_item->datelastborrowed( dt_from_string()->ymd() ) if $issue;

            # Expected item, remove from lookup table
            if ( delete $expected_items->{ $verify_item->barcode } ) {
                push @bundle_items, $verify_item;
            }

            # Unexpected item, warn and remove from bundle
            else {
                $verify_item->remove_from_bundle;
                push @unexpected_items, $verify_item;
            }

            # Store results
            $verify_item->store();
        }
        for my $missing_item ( keys %{$expected_items} ) {
            my $bundle_item = $expected_items->{$missing_item};

            # Mark as lost if it's not already lost
            if ( !$bundle_item->itemlost ) {
                $bundle_item->itemlost($BundleLostValue)->store();

                # Add return_claim record if this is an actual checkin
                if ($issue) {
                    $bundle_item->_result->create_related(
                        'return_claims',
                        {
                            issue_id       => $issue->issue_id,
                            itemnumber     => $bundle_item->itemnumber,
                            borrowernumber => $issue->borrowernumber,
                            created_by     => C4::Context->userenv()->{number},
                            created_on     => dt_from_string
                        }
                    );
                }
                push @missing_items, $bundle_item;

                # NOTE: We cannot use C4::LostItem here because the item itself doesn't have a checkout
                # and thus would not get charged.. it's checked out as part of the bundle.
                if ( C4::Context->preference('WhenLostChargeReplacementFee') && $issue ) {
                    C4::Accounts::chargelostitem(
                        $issue->borrowernumber,
                        $bundle_item->itemnumber,
                        $bundle_item->replacementprice,
                        sprintf(
                            "%s %s %s",
                            $bundle_item->biblio->title  || q{},
                            $bundle_item->barcode        || q{},
                            $bundle_item->itemcallnumber || q{},
                        ),
                    );
                }
            }
        }
        $template->param(
            unexpected_items => \@unexpected_items,
            missing_items    => \@missing_items,
            bundle_items     => \@bundle_items
        );
    }
}
$template->param( checkins => \@checkins );

my $found    = 0;
my $waiting  = 0;
my $reserved = 0;
my $recalled = 0;

# new op dev : we check if the document must be returned to his homebranch directly,
#  if the document is transferred, we have warning message .

if ( $messages->{'WasTransfered'} ) {
    $template->param(
        found      => 1,
        transfer   => $messages->{'WasTransfered'},
        transferto => $messages->{'TransferTo'},
        trigger    => $messages->{'TransferTrigger'},
        itemnumber => $itemnumber,
    );
}

if ( $messages->{'NeedsTransfer'} ) {
    $template->param(
        found         => 1,
        needstransfer => $messages->{'NeedsTransfer'},
        trigger       => $messages->{'TransferTrigger'},
    );
}

if ( $messages->{'Wrongbranch'} ) {
    $template->param(
        wrongbranch => 1,
        rightbranch => $messages->{'Wrongbranch'}->{'Rightbranch'},
    );
}

# case of wrong transfer, if the document wasn't transferred to the right library (according to branchtransfer (tobranch) BDD)

if ( $messages->{'WrongTransfer'} and not $messages->{'WasTransfered'} ) {

    # Trigger modal to prompt librarian
    $template->param(
        WrongTransfer     => 1,
        TransferWaitingAt => $messages->{'WrongTransfer'},
        WrongTransferItem => $messages->{'WrongTransferItem'},
        trigger           => $messages->{'TransferTrigger'},
    );

    # Update the transfer to reflect the new item holdingbranch
    my $item         = Koha::Items->find( $messages->{'WrongTransferItem'} );
    my $old_transfer = $item->get_transfer;

    # We need to ignore limits here. While we can't transfer from this branch, it is, wrongly, here right now
    # and that fact must be recorded
    my $new_transfer = $item->request_transfer(
        {
            to            => $old_transfer->to_library,
            reason        => $old_transfer->reason,
            replace       => 'WrongTransfer',
            ignore_limits => 1
        }
    );
    $template->param( NewTransfer => $new_transfer->id );

    my $reserve = $messages->{'ResFound'};
    if ($reserve) {
        my $patron = Koha::Patrons->find( $reserve->{'borrowernumber'} );
        $template->param(
            patron => $patron,
        );
    }
}

#
# reserve found and item arrived at the expected branch
#
if ( $messages->{'ResFound'} ) {
    my $reserve            = $messages->{'ResFound'};
    my $patron             = Koha::Patrons->find( $reserve->{borrowernumber} );
    my $holdmsgpreferences = C4::Members::Messaging::GetMessagingPreferences(
        { borrowernumber => $reserve->{'borrowernumber'}, message_name => 'Hold_Filled' } );
    my $branchCheck = ( $userenv_branch eq $reserve->{branchcode} );
    if ( $reserve->{'ResFound'} eq "Waiting" ) {
        $template->param(
            waiting => $branchCheck ? 1 : undef,
        );
    } elsif ( C4::Context->preference('HoldsAutoFill') ) {
        my $item   = Koha::Items->find($itemnumber);
        my $biblio = $item->biblio;

        my $diffBranchSend = !$branchCheck ? $reserve->{branchcode} : undef;
        ModReserveAffect( $itemnumber, $reserve->{borrowernumber}, $diffBranchSend, $reserve->{reserve_id}, $desk_id );

        if ($diffBranchSend) {
            my $tobranch = Koha::Libraries->find( $reserve->{branchcode} );

            # Add transfer, enqueue if one is already in the queue, and immediately set to in transit
            my $transfer = $item->request_transfer( { to => $tobranch, reason => 'Reserve', enqueue => 1 } );
            $transfer->transit;
        }

        $template->param(
            hold_auto_filled => 1,
            print_slip       => C4::Context->preference('HoldsAutoFillPrintSlip'),
            reserve_id       => $reserve->{reserve_id},
        );

        if ($diffBranchSend) {
            $template->param(
                itemtitle        => $biblio->title,
                itembiblionumber => $biblio->biblionumber,
                iteminfo         => $biblio->author,
                diffbranch       => 1,
            );
        }
    } else {
        $template->param(
            intransit    => $branchCheck ? undef : 1,
            transfertodo => $branchCheck ? undef : 1,
            reserve_id   => $reserve->{reserve_id},
            reserved     => 1,
        );
    }

    # same params for Waiting or Reserved
    $template->param(
        found          => 1,
        patron         => $patron,
        barcode        => $barcode,
        destbranch     => $reserve->{'branchcode'},
        reservenotes   => $reserve->{'reservenotes'},
        reserve_id     => $reserve->{reserve_id},
        bormessagepref => $holdmsgpreferences->{'transports'},
    );
}

if ( $messages->{RecallFound} ) {
    my $recall = $messages->{RecallFound};
    if ( dt_from_string( $recall->timestamp ) == dt_from_string ) {

        # we just updated this recall
        $template->param( recall => $recall );
    } else {
        my $transferbranch = $messages->{RecallNeedsTransfer};
        my $transfertodo   = ( !$transferbranch or $transferbranch eq $recall->library->branchcode ) ? undef : 1;
        $template->param(
            found         => 1,
            recall        => $recall,
            recalled      => $recall->waiting ? 0 : 1,
            transfertodo  => $transfertodo,
            waitingrecall => $recall->waiting ? 1 : 0,
        );
    }
}

if ( $messages->{TransferredRecall} ) {
    my $recall = $messages->{TransferredRecall};

    # confirm transfer has arrived at the branch
    my $transfer = Koha::Item::Transfers->search(
        { datearrived => { '!='  => undef }, itemnumber => $recall->item_id },
        { order_by    => { -desc => 'datearrived' } }
    )->next;

    # if transfer has completed, show popup to confirm as waiting
    if ( defined $transfer and $transfer->tobranch eq $recall->pickup_library_id ) {
        $template->param(
            found    => 1,
            recall   => $recall,
            recalled => 1,
        );
    }
}

# Error Messages
my @errmsgloop;
foreach my $code ( keys %$messages ) {
    my %err;
    if ( $code eq 'BadBarcode' ) {
        $err{badbarcode} = 1;
        $err{msg}        = $messages->{'BadBarcode'};
    } elsif ( $code eq 'NotIssued' ) {
        $err{notissued} = 1;
        $err{msg}       = '';
    } elsif ( $code eq 'LocalUse' ) {
        $err{localuse} = 1;
    } elsif ( $code eq 'WasLost' ) {
        $err{waslost} = 1;
    } elsif ( $code eq 'LostItemFeeRefunded' ) {
        $template->param( LostItemFeeRefunded => 1 );
    } elsif ( $code eq 'LostItemPaymentNotRefunded' ) {
        $template->param( LostItemPaymentNotRefunded => 1 );
    } elsif ( $code eq 'LostItemFeeCharged' ) {
        $template->param( LostItemFeeCharged => 1 );
    } elsif ( $code eq 'LostItemFeeRestored' ) {
        $template->param( LostItemFeeRestored => 1 );
    } elsif ( $code eq 'ProcessingFeeRefunded' ) {
        $template->param( ProcessingFeeRefunded => 1 );
    } elsif ( $code eq 'ResFound' ) {
        ;    # FIXME... anything to do here?
    } elsif ( $code eq 'WasReturned' ) {
        ;    # FIXME... anything to do here?
    } elsif ( $code eq 'WasTransfered' ) {
        ;    # FIXME... anything to do here?
    } elsif ( $code eq 'TransferTo' ) {
        ;    # Handled above, along with WasTransfered
    } elsif ( $code eq 'withdrawn' ) {
        $err{withdrawn} = 1;
    } elsif ( $code eq 'WrongTransfer' ) {
        ;    # FIXME... anything to do here?
    } elsif ( $code eq 'WrongTransferItem' ) {
        ;    # FIXME... anything to do here?
    } elsif ( $code eq 'NeedsTransfer' ) {
    } elsif ( $code eq 'TransferTrigger' ) {
        ;    # Handled alongside NeedsTransfer
    } elsif ( $code eq 'TransferArrived' ) {
        $err{transferred} = $messages->{'TransferArrived'};
    } elsif ( $code eq 'Wrongbranch' ) {
    } elsif ( $code eq 'Debarred' ) {
        $err{debarred}            = $messages->{'Debarred'};
        $err{debarcardnumber}     = $borrower->{cardnumber};
        $err{debarborrowernumber} = $borrower->{borrowernumber};
        $err{debarname}           = "$borrower->{firstname} $borrower->{surname}";
    } elsif ( $code eq 'PrevDebarred' ) {
        $err{prevdebarred} = $messages->{'PrevDebarred'};
    } elsif ( $code eq 'ForeverDebarred' ) {
        $err{foreverdebarred} = $messages->{'ForeverDebarred'};
    } elsif ( $code eq 'ItemLocationUpdated' ) {
        $err{ItemLocationUpdated} = $messages->{ItemLocationUpdated};
    } elsif ( $code eq 'NotForLoanStatusUpdated' ) {
        $err{NotForLoanStatusUpdated} = $messages->{NotForLoanStatusUpdated};
    } elsif ( $code eq 'DataCorrupted' ) {
        $err{data_corrupted} = $messages->{'DataCorrupted'};
    } elsif ( $code eq 'ReturnClaims' ) {
        $template->param( ReturnClaims => $messages->{ReturnClaims} );
    } elsif ( $code eq 'ClaimAutoResolved' ) {
        $template->param( ClaimAutoResolved => $messages->{ClaimAutoResolved} );
    } elsif ( $code eq 'RecallFound' ) {
        ;
    } elsif ( $code eq 'RecallNeedsTransfer' ) {
        ;
    } elsif ( $code eq 'TransferredRecall' ) {
        ;
    } elsif ( $code eq 'InBundle' ) {
        $template->param( InBundle => $messages->{InBundle} );
    } elsif ( $code eq 'UpdateLastSeenError' ) {
        $err{UpdateLastSeenError} = $messages->{UpdateLastSeenError};
    } else {
        die "Unknown error code $code";    # note we need all the (empty) elsif's above, or we die.
                                           # This forces the issue of staying in sync w/ Circulation.pm
    }
    if (%err) {
        push( @errmsgloop, \%err );
    }
}
$template->param( errmsgloop => \@errmsgloop );

my $shelflocations = {
    map { $_->{authorised_value} => $_->{lib} } Koha::AuthorisedValues->get_descriptions_by_koha_field(
        { frameworkcode => '', kohafield => 'items.location' }
    )
};
for my $checkin (@checkins) {
    my $item = Koha::Items->find( { barcode => $checkin->{barcode} } );
    next unless $item;    # FIXME The item has been deleted in the meantime,
                          # we could handle that better displaying a message in the template

    if ( $checkin->{duedate} ) {
        my $duedate = dt_from_string( $checkin->{duedate}, 'sql' );
        my $patron  = Koha::Patrons->find( $checkin->{borrowernumber} );

        my $return_overdue;
        unless ($dropboxmode) {
            $return_overdue = 1 if ( DateTime->compare( $duedate, dt_from_string() ) == -1 );
        } else {
            $return_overdue = 1 if ( DateTime->compare( $duedate, $dropboxdate ) == -1 );
        }
        $checkin->{return_overdue} = $return_overdue;
        $checkin->{patron}         = $patron;
    }

    $checkin->{item} = $item;
    my $biblio = $item->biblio;
    $checkin->{biblio} = $item->biblio;

    # TODO Move this logic somewhere else
    $checkin->{item_location} = $item->location;
    my $shelfcode = $checkin->{item_location};
    $checkin->{item_location} = $shelflocations->{$shelfcode}
        if ( defined($shelfcode) && defined($shelflocations) && exists( $shelflocations->{$shelfcode} ) );
}

$template->param(
    checkins                 => \@checkins,
    errmsgloop               => \@errmsgloop,
    exemptfine               => $exemptfine,
    dropboxmode              => $dropboxmode,
    dropboxdate              => $dropboxdate,
    forgivemanualholdsexpire => $forgivemanualholdsexpire,
    overduecharges           => $overduecharges,
    AudioAlerts              => C4::Context->preference("AudioAlerts"),
);

if ($barcode) {
    my $item_from_barcode = Koha::Items->find( { barcode => $barcode } );    # How many times do we fetch this item?!?
    if ($item_from_barcode) {
        $itemnumber = $item_from_barcode->itemnumber;
        my ( $holdingBranch, $collectionBranch ) = GetCollectionItemBranches($itemnumber);
        if ( $holdingBranch and $collectionBranch ) {
            $holdingBranch    //= '';
            $collectionBranch //= $returnbranch;
            if ( !( $holdingBranch eq $collectionBranch ) ) {
                $template->param(
                    collectionItemNeedsTransferred => 1,
                    collectionBranch               => $collectionBranch,
                );
            }
        }
    }
}

$template->param( itemnumber => $itemnumber );

# Checking if there is a Fast Cataloging Framework
$template->param( fast_cataloging => 1 ) if Koha::BiblioFrameworks->find('FA');

# actually print the page!
output_html_with_http_headers $query, $cookie, $template->output;
