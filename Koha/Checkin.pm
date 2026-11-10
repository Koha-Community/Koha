package Koha::Checkin;

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

use Modern::Perl;

use Koha::Database;
use Koha::Account::Credits;
use Koha::Account::Debits;
use Koha::Checkins;
use Koha::DateUtils qw( dt_from_string );
use Koha::Desks;
use Koha::Exceptions::Checkin;
use Koha::Holds;
use Koha::Items;
use Koha::Item::Transfers;
use Koha::Libraries;
use Koha::Old::Checkouts;
use Koha::Patron::Restrictions;
use Koha::Patrons;
use Koha::Recalls;
use Koha::Token;
use Koha::Checkouts::ReturnClaims;

use C4::Accounts;
use C4::Context;
use C4::Reserves qw( ModReserveAffect );

use base qw(Koha::Object);

use constant ACTION_TOKEN_EXPIRY_SECONDS => 900;    # 15 minutes

=head1 NAME

Koha::Checkin - Koha Checkin object class

=head1 API

=head2 Relations

=head3 item

    my $item = $checkin->item;

Returns the related L<Koha::Item> object.

=cut

sub item {
    my ($self) = @_;
    my $rs = $self->_result->item;
    return unless $rs;
    return Koha::Item->_new_from_dbic($rs);
}

=head3 user

    my $user = $checkin->user;

Returns the L<Koha::Patron> who processed the checkin.

=cut

sub user {
    my ($self) = @_;
    my $rs = $self->_result->user;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 library

    my $library = $checkin->library;

Returns the related L<Koha::Library> object.

=cut

sub library {
    my ($self) = @_;
    my $rs = $self->_result->library;
    return unless $rs;
    return Koha::Library->_new_from_dbic($rs);
}

=head3 desk

    my $desk = $checkin->desk;

Returns the related L<Koha::Desk> object, if set.

=cut

sub desk {
    my ($self) = @_;
    my $rs = $self->_result->desk;
    return unless $rs;
    return Koha::Desk->_new_from_dbic($rs);
}

=head3 checkout

    my $checkout = $checkin->checkout;

Returns the related L<Koha::Old::Checkout> object, if this checkin returned a checkout.

=cut

sub checkout {
    my ($self) = @_;
    my $rs = $self->_result->checkout;
    return unless $rs;
    return Koha::Old::Checkout->_new_from_dbic($rs);
}

=head3 transfer

    my $transfer = $checkin->transfer;

Returns the related L<Koha::Item::Transfer> object, if this checkin triggered a transfer.

=cut

sub transfer {
    my ($self) = @_;
    my $rs = $self->_result->transfer;
    return unless $rs;
    return Koha::Item::Transfer->_new_from_dbic($rs);
}

=head3 hold

    my $hold = $checkin->hold;

Returns the related L<Koha::Hold> object, if this checkin filled a hold.

=cut

sub hold {
    my ($self) = @_;
    my $rs = $self->_result->hold;
    return unless $rs;
    return Koha::Hold->_new_from_dbic($rs);
}

=head3 recall

    my $recall = $checkin->recall;

Returns the related L<Koha::Recall> object, if this checkin filled a recall.

=cut

sub recall {
    my ($self) = @_;
    my $rs = $self->_result->recall;
    return unless $rs;
    return Koha::Recall->_new_from_dbic($rs);
}

=head3 restriction

    my $restriction = $checkin->restriction;

Returns the related L<Koha::Patron::Restriction> object, if this checkin triggered a restriction.

=cut

sub restriction {
    my ($self) = @_;
    my $rs = $self->_result->restriction;
    return unless $rs;
    return Koha::Patron::Restriction->_new_from_dbic($rs);
}

=head3 claim

    my $claim = $checkin->claim;

Returns the related L<Koha::Checkouts::ReturnClaim> object, if this checkin resolved a return claim.

=cut

sub claim {
    my ($self) = @_;
    my $rs = $self->_result->claim;
    return unless $rs;
    return Koha::Checkouts::ReturnClaim->_new_from_dbic($rs);
}

=head3 debits

    my $debits = $checkin->debits;

Returns the debit L<Koha::Account::Debits> linked to this checkin.

=cut

sub debits {
    my ($self) = @_;
    my $rs = $self->_result->debits;
    return Koha::Account::Debits->_new_from_dbic($rs);
}

=head3 credits

    my $credits = $checkin->credits;

Returns the credit L<Koha::Account::Credits> linked to this checkin.

=cut

sub credits {
    my ($self) = @_;
    my $rs = $self->_result->credits;
    return Koha::Account::Credits->_new_from_dbic($rs);
}

=head2 Accessors

=head3 is_latest

    if ( $checkin->is_latest ) { ... }

Returns true if this is the latest checkin recorded for its item. Follow-up
actions (setting a hold aside, confirming a transfer, etc.) only make sense
for the latest checkin of an item: a later checkin means the item has
circulated since.

=cut

sub is_latest {
    my ($self) = @_;

    return !Koha::Checkins->search(
        {
            item_id    => $self->item_id,
            checkin_id => { '>' => $self->id },
        }
    )->count;
}

=head3 pending_actions

    my $actions = $checkin->pending_actions;

Returns an arrayref with the names of the follow-up actions that can be
offered for this checkin, matching the C</checkins/{checkin_id}/*> API
endpoints:

=over 4

=item * I<hold_confirmation>, I<hold_cancellation> - A hold was found

=item * I<transfer_confirmation>, I<transfer_cancellation> - A transfer was
triggered. Only I<transfer_confirmation> is offered when the item needs a
transfer that was not created (I<needs_transfer> message, see
I<AutomaticItemReturn>)

=item * I<recall_confirmation> - A recall was found

=back

=cut

sub pending_actions {
    my ($self) = @_;

    my @actions;

    push @actions, qw( hold_confirmation hold_cancellation )
        if $self->hold_id;

    if ( $self->transfer_id ) {
        push @actions, qw( transfer_confirmation transfer_cancellation );
    } elsif ( grep { $_->message eq 'needs_transfer' } @{ $self->object_messages } ) {
        push @actions, 'transfer_confirmation';
    }

    push @actions, 'recall_confirmation'
        if $self->recall_id;

    return \@actions;
}

=head3 action_tokens

    my $tokens = $checkin->action_tokens( { user => $patron } );

Returns a hashref with a signed token for each of the I<pending_actions>,
keyed by action name. Each token is tied to this checkin, the passed I<user>
(a L<Koha::Patron>, the staff member) and the action, and expires after
C<ACTION_TOKEN_EXPIRY_SECONDS>.

=cut

sub action_tokens {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw("'user' is required")
        unless $params->{user};

    my $tokenizer = Koha::Token->new;

    return {
        map {
            $_ => $tokenizer->generate_jwt(
                {
                    id      => $self->_action_token_id( $_, $params->{user} ),
                    expires => time + ACTION_TOKEN_EXPIRY_SECONDS,
                }
            )
        } @{ $self->pending_actions }
    };
}

=head3 check_action_token

    my $valid = $checkin->check_action_token(
        {
            action => 'hold_confirmation',
            user   => $patron,
            token  => $token,
        }
    );

Returns true if I<token> was issued by I<action_tokens> for this checkin,
I<user> and I<action>, and has not expired.

=cut

sub check_action_token {
    my ( $self, $params ) = @_;

    return 0 unless $params->{action} && $params->{user} && $params->{token};

    return Koha::Token->new->check_jwt(
        {
            id    => $self->_action_token_id( $params->{action}, $params->{user} ),
            token => $params->{token},
        }
    ) ? 1 : 0;
}

=head2 Actions

=head3 confirm_hold

    $checkin->confirm_hold;

Sets the trapped hold to waiting, at the checkin's desk if any. If the pickup
library differs from the checkin library, creates a transfer and sets it in
transit.

Throws C<Koha::Exceptions::MissingParameter> if there is no hold associated
with this checkin.

Throws C<Koha::Exceptions::Checkin::HoldNotFound> if the hold no longer
exists (e.g. it was cancelled or filled in the meantime).

Throws C<Koha::Exceptions::Checkin::ItemCheckedOut> if the item has been
checked out again since the checkin (e.g. from another workstation). The hold
is left pending and no transfer is created.

Returns the C<Koha::Checkin> object for chaining.

=cut

sub confirm_hold {
    my ($self) = @_;

    Koha::Exceptions::MissingParameter->throw("No hold associated with this checkin")
        unless $self->hold_id;

    my $hold = $self->hold;

    Koha::Exceptions::Checkin::HoldNotFound->throw("The hold no longer exists")
        unless $hold;

    my $item            = $self->item;
    my $checkin_library = $self->library_id;
    my $pickup_library  = $hold->branchcode;

    # If pickup branch differs, a transfer is needed
    my $diff_branch = ( $checkin_library ne $pickup_library ) ? $pickup_library : undef;

    # The hold must not be left in transit without a transfer
    Koha::Database->new->schema->txn_do(
        sub {
            # ModReserveAffect returns undef if the hold is not found, 0 if it
            # refuses to set aside a hold for an item that is on loan, 1 on success
            my $affected = ModReserveAffect(
                $item->itemnumber, $hold->borrowernumber, $diff_branch, $hold->id,
                $self->desk_id
            );

            Koha::Exceptions::Checkin::HoldNotFound->throw("The hold no longer exists")
                unless defined $affected;

            Koha::Exceptions::Checkin::ItemCheckedOut->throw(
                "The item has been checked out in the meantime, the hold remains pending")
                unless $affected;

            # Create transfer if needed
            if ($diff_branch) {
                my $transfer =
                    $item->request_transfer( { to => $hold->pickup_library, reason => 'Reserve', enqueue => 1 } );
                $transfer->transit;
                $self->set( { transfer_id => $transfer->id } )->store;
            }
        }
    );

    return $self;
}

=head3 cancel_hold

    $checkin->cancel_hold;
    $checkin->cancel_hold( { reason => 'PATRON_REQUEST', forgive_hold_fees => 1 } );

Cancels the hold associated with this checkin and clears the hold_id.
The cancellation fee (I<ExpireReservesMaxPickUpDelayCharge>) is charged
unless I<forgive_hold_fees> is passed.

Throws C<Koha::Exceptions::MissingParameter> if there is no hold associated
with this checkin.

Returns the C<Koha::Checkin> object for chaining.

=cut

sub cancel_hold {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw("No hold associated with this checkin")
        unless $self->hold_id;

    my $hold = $self->hold;

    Koha::Database->new->schema->txn_do(
        sub {
            $hold->cancel(
                {
                    cancellation_reason => $params->{reason},
                    charge_cancel_fee   => $params->{forgive_hold_fees} ? 0 : 1,
                }
            );

            $self->set( { hold_id => undef } )->store;
        }
    );

    return $self;
}

=head3 confirm_transfer

    $checkin->confirm_transfer;
    $checkin->confirm_transfer( { to_library_id => 'CPL', reason => 'ReturnToHome' } );

Sets the transfer associated with this checkin in transit (populates datesent).

If the checkin has no transfer yet (the item needs one but I<AutomaticItemReturn>
is disabled) and I<to_library_id> is passed, a transfer to that library is
requested with the passed I<reason> (I<Manual> by default) and set in transit.

Throws C<Koha::Exceptions::MissingParameter> if there is no transfer associated
with this checkin and no I<to_library_id> is passed.

Throws C<Koha::Exceptions::Checkin::TransferFinished> if the transfer has
already arrived or has been cancelled.

Returns the C<Koha::Checkin> object for chaining.

=cut

sub confirm_transfer {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw("No transfer associated with this checkin")
        unless $self->transfer_id || $params->{to_library_id};

    Koha::Exceptions::Checkin::TransferFinished->throw("The transfer has already arrived or has been cancelled")
        if $self->transfer_id && ( $self->transfer->datearrived || $self->transfer->datecancelled );

    Koha::Database->new->schema->txn_do(
        sub {
            unless ( $self->transfer_id ) {
                my $transfer = $self->item->request_transfer(
                    {
                        to     => Koha::Libraries->find( $params->{to_library_id} ),
                        reason => $params->{reason} // 'Manual',
                    }
                );
                $self->set( { transfer_id => $transfer->id } )->store;
            }

            my $transfer = $self->transfer;

            $transfer->transit unless $transfer->datesent;
        }
    );

    return $self;
}

=head3 cancel_transfer

    $checkin->cancel_transfer;

Cancels the transfer associated with this checkin and clears the transfer_id.

If the item has a recall in transit, it reverts the recall transfer as well.

Throws C<Koha::Exceptions::MissingParameter> if there is no transfer associated
with this checkin.

Throws C<Koha::Exceptions::Checkin::TransferFinished> if the transfer has
already arrived or has been cancelled.

Returns the C<Koha::Checkin> object for chaining.

=cut

sub cancel_transfer {
    my ($self) = @_;

    Koha::Exceptions::MissingParameter->throw("No transfer associated with this checkin")
        unless $self->transfer_id;

    my $transfer = $self->transfer;

    Koha::Exceptions::Checkin::TransferFinished->throw("The transfer has already arrived or has been cancelled")
        if $transfer->datearrived || $transfer->datecancelled;

    Koha::Database->new->schema->txn_do(
        sub {
            $transfer->cancel( { reason => 'Manual', force => 1 } );

            # If there's a recall in transit for this item, revert it
            #
            # FIXME: This recall-revert-on-cancel trigger really belongs one level
            # down, in Koha::Item::Transfer->cancel, so that *every* transfer
            # cancellation reverts an in-transit recall regardless of the caller
            # (checkin, transfers-to-receive, etc.). It lives here for now because
            # Koha::Item::Transfer->cancel is shared by callers that must not trigger
            # this behaviour; moving it down should be done carefully in a follow-up.
            if ( C4::Context->preference('UseRecalls') ne 'off' ) {
                my $item   = $self->item;
                my $recall = Koha::Recalls->find( { item_id => $item->itemnumber, status => 'in_transit' } );
                $recall->revert_transfer if $recall;
            }

            $self->set( { transfer_id => undef } )->store;
        }
    );

    return $self;
}

=head3 replace_wrong_transfer

    $checkin->replace_wrong_transfer;

Called when the item was checked in at a library that is not the
destination of its current transfer. Replaces that transfer with a new
one, from the checkin library to the original destination, so the
transfer reflects where the item actually is, and links it to this checkin.

Transfer limits are ignored: the item may not be allowed to be sent from
this library, but it is (wrongly) here and that fact must be recorded.

Returns the C<Koha::Checkin> object for chaining.

=cut

sub replace_wrong_transfer {
    my ($self) = @_;

    my $item         = $self->item;
    my $old_transfer = $item->get_transfer;

    return $self unless $old_transfer;

    Koha::Database->new->schema->txn_do(
        sub {
            my $new_transfer = $item->request_transfer(
                {
                    to            => $old_transfer->to_library,
                    reason        => $old_transfer->reason,
                    replace       => 'WrongTransfer',
                    ignore_limits => 1,
                }
            );

            $self->set( { transfer_id => $new_transfer->id } )->store;
        }
    );

    return $self;
}

=head3 confirm_recall

    $checkin->confirm_recall;

Resolves the recall associated with this checkin. If the recall's pickup
library is the same as the checkin library, sets the recall to waiting.
Otherwise, starts a transfer to the pickup library.

Throws C<Koha::Exceptions::MissingParameter> if there is no recall associated
with this checkin.

Throws C<Koha::Exceptions::Checkin::TransferNotStarted> if the transfer to the
pickup library could not be started. The recall is left unchanged, and the
exception carries the messages returned by C<C4::Circulation::transferbook>.

Returns the C<Koha::Checkin> object for chaining.

=cut

sub confirm_recall {
    my ($self) = @_;

    Koha::Exceptions::MissingParameter->throw("No recall associated with this checkin")
        unless $self->recall_id;

    my $recall = $self->recall;
    my $item   = $self->item;

    Koha::Database->new->schema->txn_do(
        sub {
            if ( $recall->pickup_library_id ne $self->library_id ) {

                # Needs transfer to pickup library
                unless ( $recall->in_transit ) {
                    my ( undef, $dotransfer, $messages ) = $recall->start_transfer( { item => $item } );
                    Koha::Exceptions::Checkin::TransferNotStarted->throw(
                        error    => "The transfer to the recall pickup library could not be started",
                        messages => $messages,
                    ) unless $dotransfer;
                }
            } else {

                # Same library - set to waiting
                my $expirationdate = $recall->calc_expirationdate;
                $recall->set_waiting( { item => $item, expirationdate => $expirationdate } )
                    unless $recall->waiting;
            }
        }
    );

    return $self;
}

=head3 verify_bundle

    my $result = $checkin->verify_bundle(
        {
            verified_barcodes => \@barcodes,
            patron_id         => $patron_id,
        }
    );

Processes bundle verification after checkin. Verified items get their
lost status cleared. Missing items (expected but not verified) are
marked as lost using C<BundleLostValue>. Unexpected items (verified
but not in the bundle) are removed from the bundle.

All the changes are made in a single transaction.

When the checkin returned a checkout, I<patron_id> is the patron the
bundle was checked out to (taken before the return, as the stored
checkout may already be anonymized). A return claim is recorded for
each missing item and, if I<WhenLostChargeReplacementFee> is enabled,
the replacement fee is charged to that patron.

Returns a hashref with keys: verified, missing, unexpected.

=cut

sub verify_bundle {
    my ( $self, $params ) = @_;

    my $verified_barcodes = $params->{verified_barcodes} || [];
    my $patron_id         = $params->{patron_id};
    my $item              = $self->item;
    my $checkout          = $self->checkout;

    my $BundleLostValue = C4::Context->preference('BundleLostValue') || 1;

    # Build lookup of expected bundle items
    my $expected = { map { $_->barcode => $_ } $item->bundle_items->as_list };

    my @verified;
    my @unexpected;
    my @missing;

    Koha::Database->new->schema->txn_do(
        sub {
            # Process verified barcodes
            if (@$verified_barcodes) {
                my $verify_items = Koha::Items->search( { barcode => { 'in' => $verified_barcodes } } );
                while ( my $vi = $verify_items->next ) {

                    # Clear lost status
                    $vi->itemlost(0);
                    $vi->datelastseen( dt_from_string() );
                    $vi->datelastborrowed( dt_from_string()->ymd() ) if $checkout;

                    if ( delete $expected->{ $vi->barcode } ) {
                        push @verified, $vi;
                    } else {

                        # Not expected - remove from bundle
                        $vi->remove_from_bundle;
                        push @unexpected, $vi;
                    }
                    $vi->store;
                }
            }

            # Mark remaining expected items as lost
            for my $barcode ( sort keys %$expected ) {
                my $missing_item = $expected->{$barcode};

                next if $missing_item->itemlost;

                $missing_item->itemlost($BundleLostValue)->store;

                if ( $checkout && $patron_id ) {
                    Koha::Checkouts::ReturnClaim->new(
                        {
                            issue_id       => $checkout->issue_id,
                            itemnumber     => $missing_item->itemnumber,
                            borrowernumber => $patron_id,
                            created_by     => $self->user_id // ( C4::Context->userenv // {} )->{number},
                        }
                    )->store;

                    # C4::LostItem is not used here: the bundled item has no checkout
                    # of its own (it was checked out as part of the bundle), so it
                    # would not get charged.
                    if ( C4::Context->preference('WhenLostChargeReplacementFee') ) {
                        C4::Accounts::chargelostitem(
                            $patron_id,
                            $missing_item->itemnumber,
                            $missing_item->replacementprice,
                            sprintf(
                                "%s %s %s",
                                $missing_item->biblio->title  || q{},
                                $missing_item->barcode        || q{},
                                $missing_item->itemcallnumber || q{},
                            ),
                        );
                    }
                }

                push @missing, $missing_item;
            }
        }
    );

    return {
        verified   => \@verified,
        missing    => \@missing,
        unexpected => \@unexpected,
    };
}

=head2 Internal methods

=head3 _action_token_id

    my $id = $checkin->_action_token_id( $action, $user );

Returns the identifier signed in the action tokens.

=cut

sub _action_token_id {
    my ( $self, $action, $user ) = @_;
    return join( ':', 'checkin_action', $self->id, $user->id, $action );
}

=head3 to_api_mapping

=cut

sub to_api_mapping {
    return { timestamp => undef };
}

=head3 _type

=cut

sub _type {
    return 'Checkin';
}

1;
