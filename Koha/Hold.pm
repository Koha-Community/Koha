package Koha::Hold;

# Copyright ByWater Solutions 2014
# Copyright 2017 Koha Development team
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

use Modern::Perl;

use List::MoreUtils qw( any );

use C4::Context qw(preference);
use C4::Letters qw( GetPreparedLetter EnqueueLetter );
use C4::Log     qw( logaction );
use C4::Reserves;

use Koha::AuthorisedValues;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;
use Koha::Biblios;
use Koha::Hold::CancellationRequests;
use Koha::Items;
use Koha::Libraries;
use Koha::Calendar;
use Koha::Plugins;

use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;

use Koha::Exceptions;
use Koha::HoldGroups;
use Koha::Exceptions::Hold;

use base qw(Koha::Object);

=head1 NAME

Koha::Hold - Koha Hold object class

=head1 API

=head2 Class methods

=cut

=head3 age

returns the number of days since a hold was placed, optionally
using the calendar

my $age = $hold->age( $use_calendar );

=cut

sub age {
    my ( $self, $use_calendar ) = @_;

    my $today = dt_from_string;
    my $age;

    if ($use_calendar) {
        my $calendar = Koha::Calendar->new( branchcode => $self->branchcode );
        $age = $calendar->days_between( dt_from_string( $self->reservedate ), $today );
    } else {
        $age = $today->delta_days( dt_from_string( $self->reservedate ) );
    }

    $age = $age->in_units('days');

    return $age;
}

=head3 suspend_hold

my $hold = $hold->suspend_hold( $suspend_until );

=cut

sub suspend_hold {
    my ( $self, $date ) = @_;

    my $original = C4::Context->preference('HoldsLog') ? $self->unblessed : undef;

    $date &&= dt_from_string($date)->truncate( to => 'day' )->datetime;

    if ( $self->is_found ) {    # We can't suspend found holds
        if ( $self->is_waiting ) {
            Koha::Exceptions::Hold::CannotSuspendFound->throw( status => 'W' );
        } elsif ( $self->is_in_transit ) {
            Koha::Exceptions::Hold::CannotSuspendFound->throw( status => 'T' );
        } elsif ( $self->is_in_processing ) {
            Koha::Exceptions::Hold::CannotSuspendFound->throw( status => 'P' );
        } else {
            Koha::Exceptions::Hold::CannotSuspendFound->throw(
                'Unhandled data exception on found hold (id=' . $self->id . ', found=' . $self->found . ')' );
        }
    }

    $self->suspend(1);
    $self->suspend_until($date);
    $self->store();

    Koha::Plugins->call(
        'after_hold_action',
        {
            action  => 'suspend',
            payload => { hold => $self->get_from_storage }
        }
    );

    logaction( 'HOLDS', 'SUSPEND', $self->reserve_id, $self, undef, $original )
        if C4::Context->preference('HoldsLog');

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $self->biblionumber ] } )
        if C4::Context->preference('RealTimeHoldsQueue');

    return $self;
}

=head3 resume

my $hold = $hold->resume();

=cut

sub resume {
    my ($self) = @_;

    my $original = C4::Context->preference('HoldsLog') ? $self->unblessed : undef;

    $self->suspend(0);
    $self->suspend_until(undef);

    $self->store();

    Koha::Plugins->call(
        'after_hold_action',
        {
            action  => 'resume',
            payload => { hold => $self->get_from_storage }
        }
    );

    logaction( 'HOLDS', 'RESUME', $self->reserve_id, $self, undef, $original )
        if C4::Context->preference('HoldsLog');

    Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $self->biblionumber ] } )
        if C4::Context->preference('RealTimeHoldsQueue');

    return $self;
}

=head3 delete

$hold->delete();

=cut

sub delete {
    my ($self) = @_;

    my $deleted = $self->SUPER::delete($self);

    logaction( 'HOLDS', 'DELETE', $self->reserve_id, $self )
        if C4::Context->preference('HoldsLog');

    return $deleted;
}

=head3 move_hold

$hold->move_hold();

=cut

sub move_hold {
    my ( $self, $args ) = @_;

    my $original              = $self;
    my $original_biblionumber = $self->biblionumber;

    my $found = $original->found // '';

    if ( $found eq 'W' ) {
        return { success => 0, error => 'Cannot move a waiting hold' };
    }

    if ( $found eq 'T' ) {
        return { success => 0, error => 'Cannot move a hold in transit' };
    }

    my $patron = Koha::Patrons->find( { borrowernumber => $self->borrowernumber } );
    return { success => 0, error => 'Missing patron or target' } unless $patron;

    my ( $new_biblionumber, $new_itemnumber, $item, $canReserve );

    if ( $args->{new_itemnumber} ) {
        $item = Koha::Items->find( { itemnumber => $args->{new_itemnumber} } )
            or return { success => 0, error => 'Target item not found' };

        $new_itemnumber   = $item->itemnumber;
        $new_biblionumber = $item->biblionumber;

        $canReserve = C4::Reserves::CanItemBeReserved( $patron, $item, $self->branchcode, { ignore_hold_counts => 1 } );
    } elsif ( $args->{new_biblionumber} ) {
        $new_biblionumber = $args->{new_biblionumber};

        $canReserve = C4::Reserves::CanBookBeReserved(
            $patron->borrowernumber, $new_biblionumber, $self->branchcode,
            { ignore_hold_counts => 1 }
        );
    } else {
        return { success => 0, error => 'Missing itemnumber or biblionumber' };
    }

    return { success => 0, error => $canReserve->{status} }
        unless $canReserve->{status} eq 'OK';

    my $max = Koha::Holds->search(
        { biblionumber => $new_biblionumber },
        { order_by     => { -desc => 'priority' }, rows => 1 }
    )->next;
    my $base_priority = $max ? $max->priority : 0;
    my $priority      = $base_priority + 1;
    my $new_priority  = C4::Reserves::_ShiftPriority( $new_biblionumber, $priority );

    $self->update(
        {
            itemnumber   => $new_itemnumber,     # undef for biblio-level is fine
            biblionumber => $new_biblionumber,
            priority     => $new_priority,
        }
    );

    C4::Log::logaction( 'HOLDS', 'MODIFY', $self->reserve_id, $self, undef, $original )
        if C4::Context->preference('HoldsLog');

    return { success => 1, hold => $self };
}

=head3 cleanup_hold_group

$self->cleanup_hold_group;

Check if a hold group is left with a single or zero holds. Delete hold_group if so.
Accepts an optional $hold_group_id that, if defined, uses that instead of self->hold_group_id

=cut

sub cleanup_hold_group {
    my ( $self, $hold_group_id ) = @_;

    my $hold_group_id_to_check = $hold_group_id // $self->hold_group_id;
    my $hold_group             = Koha::HoldGroups->find($hold_group_id_to_check);
    return unless $hold_group;

    if ( $hold_group->holds->count <= 1 ) {
        $hold_group->delete();
    }
}

=head3 set_transfer

=cut

sub set_transfer {
    my ($self) = @_;

    $self->priority(0);
    $self->found('T');
    $self->store();

    Koha::Plugins->call(
        'after_hold_action',
        {
            action  => 'transfer',
            payload => { hold => $self->get_from_storage }
        }
    );

    return $self;
}

=head3 set_waiting

=cut

sub set_waiting {
    my ( $self, $desk_id ) = @_;

    $self->priority(0);

    my $today = dt_from_string();

    my $values = {
        found => 'W',
        ( !$self->waitingdate ? ( waitingdate => $today->ymd ) : () ),
        desk_id => $desk_id,
    };

    my $max_pickup_delay   = C4::Context->preference("ReservesMaxPickUpDelay");
    my $cancel_on_holidays = C4::Context->preference('ExpireReservesOnHolidays');

    my $rule = Koha::CirculationRules->get_effective_rule(
        {
            categorycode => $self->borrower->categorycode,
            itemtype     => $self->item->effective_itemtype,
            branchcode   => $self->branchcode,
            rule_name    => 'holds_pickup_period',
        }
    );
    if ( defined($rule) and $rule->rule_value ne '' ) {

        # circulation rule overrides ReservesMaxPickUpDelay
        $max_pickup_delay = $rule->rule_value;
    }

    my $new_expiration_date = dt_from_string( $self->waitingdate )->clone->add( days => $max_pickup_delay );

    if ( C4::Context->preference("ExcludeHolidaysFromMaxPickUpDelay") ) {
        my $itemtype = $self->item ? $self->item->effective_itemtype : $self->biblio->itemtype;
        my $daysmode = Koha::CirculationRules->get_effective_daysmode(
            {
                categorycode => $self->borrower->categorycode,
                itemtype     => $itemtype,
                branchcode   => $self->branchcode,
            }
        );
        my $calendar = Koha::Calendar->new( branchcode => $self->branchcode, days_mode => $daysmode );

        $new_expiration_date = $calendar->days_forward( dt_from_string( $self->waitingdate ), $max_pickup_delay );
    }

    # If patron's requested expiration date is prior to the
    # calculated one, we keep the patron's one.
    if ( $self->patron_expiration_date ) {
        my $requested_expiration = dt_from_string( $self->patron_expiration_date );

        my $cmp =
            $requested_expiration
            ? DateTime->compare( $requested_expiration, $new_expiration_date )
            : 0;

        $new_expiration_date = $cmp == -1 ? $requested_expiration : $new_expiration_date;
    }

    $values->{expirationdate} = $new_expiration_date->ymd;

    $self->set($values)->store();

    Koha::Plugins->call(
        'after_hold_action',
        {
            action  => 'waiting',
            payload => { hold => $self->get_from_storage }
        }
    );

    return $self;
}

=head3 is_pickup_location_valid

    if ($hold->is_pickup_location_valid({ library_id => $library->id }) ) {
        ...
    }

Returns a I<boolean> representing if the passed pickup location is valid for the hold.
It throws a I<Koha::Exceptions::_MissingParameter> if the library_id parameter is not
passed.

=cut

sub is_pickup_location_valid {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw('The library_id parameter is mandatory')
        unless $params->{library_id};

    my $pickup_locations;

    if ( $self->itemnumber ) {    # item-level
        $pickup_locations = $self->item->pickup_locations( { patron => $self->patron } );
    } else {                      # biblio-level
        $pickup_locations = $self->biblio->pickup_locations( { patron => $self->patron } );
    }

    return any { $_->branchcode eq $params->{library_id} } $pickup_locations->as_list;
}

=head3 set_pickup_location

    $hold->set_pickup_location(
        {
            library_id => $library->id,
          [ force   => 0|1 ]
        }
    );

Updates the hold pickup location. It throws a I<Koha::Exceptions::Hold::InvalidPickupLocation> if
the passed pickup location is not valid.

Note: It is up to the caller to verify if I<AllowHoldPolicyOverride> is set when setting the
B<force> parameter.

=cut

sub set_pickup_location {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw('The library_id parameter is mandatory')
        unless $params->{library_id};

    if (   $params->{force}
        || $self->is_pickup_location_valid( { library_id => $params->{library_id} } ) )
    {
        # all good, set the new pickup location
        $self->branchcode( $params->{library_id} )->store;
    } else {
        Koha::Exceptions::Hold::InvalidPickupLocation->throw;
    }

    return $self;
}

=head3 set_processing

$hold->set_processing;

Mark the hold as in processing.

=cut

sub set_processing {
    my ($self) = @_;

    $self->priority(0);
    $self->found('P');
    $self->store();

    Koha::Plugins->call(
        'after_hold_action',
        {
            action  => 'processing',
            payload => { hold => $self->get_from_storage }
        }
    );

    return $self;
}

=head3 is_found

Returns true if hold is waiting, in transit or in processing

=cut

sub is_found {
    my ($self) = @_;

    return 0 unless $self->found();
    return 1 if $self->found() eq 'W';
    return 1 if $self->found() eq 'T';
    return 1 if $self->found() eq 'P';
}

=head3 is_waiting

Returns true if hold is a waiting hold

=cut

sub is_waiting {
    my ($self) = @_;

    my $found = $self->found;
    return $found && $found eq 'W';
}

=head3 is_in_transit

Returns true if hold is a in_transit hold

=cut

sub is_in_transit {
    my ($self) = @_;

    return 0 unless $self->found();
    return $self->found() eq 'T';
}

=head3 is_in_processing

Returns true if hold is a in_processing hold

=cut

sub is_in_processing {
    my ($self) = @_;

    return 0 unless $self->found();
    return $self->found() eq 'P';
}

=head3 is_cancelable_from_opac

Returns true if hold is a cancelable hold

Holds may be only canceled if they are not found.

This is used from the OPAC.

=cut

sub is_cancelable_from_opac {
    my ($self) = @_;

    return 1 unless $self->is_found();
    return 0;    # if ->is_in_transit or if ->is_waiting or ->is_in_processing
}

=head3 cancellation_requestable_from_opac

    if ( $hold->cancellation_requestable_from_opac ) { ... }

Returns a I<boolean> representing if a cancellation request can be placed on the hold
from the OPAC. It targets holds that cannot be cancelled from the OPAC (see the
B<is_cancelable_from_opac> method above), but for which circulation rules allow
requesting cancellation.

Throws a B<Koha::Exceptions::InvalidStatus> exception with the following I<invalid_status>
values:

=over 4

=item B<'hold_not_waiting'>: the hold is expected to be waiting and it is not.

=item B<'no_item_linked'>: the waiting hold doesn't have an item properly linked.

=back

=cut

sub cancellation_requestable_from_opac {
    my ($self) = @_;

    Koha::Exceptions::InvalidStatus->throw( invalid_status => 'hold_not_waiting' )
        unless $self->is_waiting;

    my $item = $self->item;

    Koha::Exceptions::InvalidStatus->throw( invalid_status => 'no_item_linked' )
        unless $item;

    my $patron = $self->patron;

    my $controlbranch = $patron->branchcode;

    if ( C4::Context->preference('ReservesControlBranch') eq 'ItemHomeLibrary' ) {
        $controlbranch = $item->homebranch;
    }

    return Koha::CirculationRules->get_effective_rule_value(
        {
            categorycode => $patron->categorycode,
            itemtype     => $item->itype,
            branchcode   => $controlbranch,
            rule_name    => 'waiting_hold_cancellation',
        }
    ) ? 1 : 0;
}

=head3 is_at_destination

Returns true if hold is waiting
and the hold's pickup branch matches
the hold item's holding branch

=cut

sub is_at_destination {
    my ($self) = @_;

    return $self->is_waiting() && ( $self->branchcode() eq $self->item()->holdingbranch() );
}

=head3 biblio

Returns the related Koha::Biblio object for this hold

=cut

sub biblio {
    my ($self) = @_;
    my $rs = $self->_result->biblionumber;
    return Koha::Biblio->_new_from_dbic($rs);
}

=head3 patron

Returns the related Koha::Patron object for this hold

=cut

sub patron {
    my ($self) = @_;
    my $rs = $self->_result->patron;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 item

Returns the related Koha::Item object for this Hold

=cut

sub item {
    my ($self) = @_;
    my $rs = $self->_result->itemnumber;
    return unless $rs;
    return Koha::Item->_new_from_dbic($rs);
}

=head3 item_group

Returns the related Koha::Biblio::ItemGroup object for this Hold

=cut

sub item_group {
    my ($self) = @_;
    my $rs = $self->_result->item_group;
    return unless $rs;
    return Koha::Biblio::ItemGroup->_new_from_dbic($rs);
}

=head3 branch

Returns the related Koha::Library object for this hold

DEPRECATED

=cut

sub branch {
    return shift->pickup_library(@_);
}

=head3 pickup_library

Returns the related Koha::Library object for this hold

=cut

sub pickup_library {
    my ($self) = @_;
    my $rs = $self->_result->pickup_library;
    return Koha::Library->_new_from_dbic($rs);
}

=head3 desk

Returns the related Koha::Desk object for this Hold

=cut

sub desk {
    my $self    = shift;
    my $desk_rs = $self->_result->desk;
    return unless $desk_rs;
    return Koha::Desk->_new_from_dbic($desk_rs);
}

=head3 borrower

Returns the related Koha::Patron object for this Hold

=cut

# FIXME Should be renamed with ->patron
sub borrower {
    my ($self) = @_;
    my $rs = $self->_result->borrowernumber;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 is_suspended

my $bool = $hold->is_suspended();

=cut

sub is_suspended {
    my ($self) = @_;

    return $self->suspend();
}

=head3 add_cancellation_request

    my $cancellation_request = $hold->add_cancellation_request({ [ creation_date => $creation_date ] });

Adds a cancellation request to the hold. Returns the generated
I<Koha::Hold::CancellationRequest> object.

=cut

sub add_cancellation_request {
    my ( $self, $params ) = @_;

    my $request = Koha::Hold::CancellationRequest->new(
        {
            hold_id => $self->id,
            ( $params->{creation_date} ? ( creation_date => $params->{creation_date} ) : () ),
        }
    )->store;

    $request->discard_changes;

    return $request;
}

=head3 cancellation_requests

    my $cancellation_requests = $hold->cancellation_requests;

Returns related a I<Koha::Hold::CancellationRequests> resultset.

=cut

sub cancellation_requests {
    my ($self) = @_;

    return Koha::Hold::CancellationRequests->search( { hold_id => $self->id } );
}

=head3 cancellation_requested

    if ( $hold->cancellation_requested ) { ... }

Returns true if a cancellation request has been placed for the hold.

=cut

sub cancellation_requested {
    my ($self) = @_;

    return Koha::Hold::CancellationRequests->search( { hold_id => $self->id } )->count > 0;
}

=head3 cancel

my $cancel_hold = $hold->cancel(
    {
        [ charge_cancel_fee       => 1||0, ]
        [ cancellation_reason     => $cancellation_reason, ]
        [ skip_holds_queue        => 1||0 ]
        [ skip_hold_group_cleanup => 1||0 ]
    }
);

Cancel a hold:
- The hold will be moved to the old_reserves table with a priority=0
- The priority of other holds will be updated
- The patron will be charge (see ExpireReservesMaxPickUpDelayCharge) if the charge_cancel_fee parameter is set
- The canceled hold will have the cancellation reason added to old_reserves.cancellation_reason if one is passed in
- a CANCEL HOLDS log will be done if the pref HoldsLog is on

=cut

sub cancel {
    my ( $self, $params ) = @_;

    my $autofill_next = $params->{autofill} && $self->itemnumber && $self->found && $self->found eq 'W';

    my $original = C4::Context->preference('HoldsLog') ? $self->unblessed : undef;

    $self->_result->result_source->schema->txn_do(
        sub {
            my $patron = $self->patron;

            $self->cancellationdate( dt_from_string->strftime('%Y-%m-%d %H:%M:%S') );
            $self->priority(0);
            $self->cancellation_reason( $params->{cancellation_reason} );
            $self->store();

            my $dbh = $self->_result->result_source->schema->storage->dbh;
            $dbh->do(
                q{
                    DELETE  q, t
                    FROM    tmp_holdsqueue q
                    INNER JOIN hold_fill_targets t
                    ON  q.borrowernumber = t.borrowernumber
                        AND q.biblionumber = t.biblionumber
                        AND q.itemnumber = t.itemnumber
                        AND q.item_level_request = t.item_level_request
                        AND q.holdingbranch = t.source_branchcode
                    WHERE t.reserve_id = ?
                }, undef, $self->id
            );

            if ( $params->{cancellation_reason} ) {
                my $letter = C4::Letters::GetPreparedLetter(
                    module                 => 'reserves',
                    letter_code            => 'HOLD_CANCELLATION',
                    message_transport_type => 'email',
                    branchcode             => $self->borrower->branchcode,
                    lang                   => $self->borrower->lang,
                    tables                 => {
                        branches    => $self->borrower->branchcode,
                        borrowers   => $self->borrowernumber,
                        items       => $self->itemnumber,
                        biblio      => $self->biblionumber,
                        biblioitems => $self->biblionumber,
                        reserves    => $self->unblessed,
                    }
                );

                if ($letter) {
                    C4::Letters::EnqueueLetter(
                        {
                            letter                 => $letter,
                            borrowernumber         => $self->borrowernumber,
                            message_transport_type => 'email',
                        }
                    );
                }
            }

            my $old_me = $self->_move_to_old;

            Koha::Plugins->call(
                'after_hold_action',
                {
                    action  => 'cancel',
                    payload => { hold => $old_me->get_from_storage }
                }
            );

            # anonymize if required
            $old_me->anonymize
                if $patron->privacy == 2;

            $self->SUPER::delete();    # Do not add a DELETE log
                                       # now fix the priority on the others....
            C4::Reserves::_FixPriority( { biblionumber => $self->biblionumber } );

            # and, if desired, charge a cancel fee
            if ( $params->{'charge_cancel_fee'} ) {
                my $item   = $self->item;
                my $charge = Koha::CirculationRules->get_effective_expire_reserves_charge(
                    {
                        itemtype     => $item->effective_itemtype,
                        branchcode   => Koha::Policy::Holds->holds_control_library( $item, $self->borrower ),
                        categorycode => $self->borrower->categorycode,
                    }
                );

                my $account = Koha::Account->new( { patron_id => $self->borrowernumber } );
                $account->add_debit(
                    {
                        amount     => $charge,
                        user_id    => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                        interface  => C4::Context->interface,
                        library_id => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
                        type       => 'RESERVE_EXPIRED',
                        item_id    => $self->itemnumber
                    }
                ) if $charge;
            }

            C4::Log::logaction( 'HOLDS', 'CANCEL', $self->reserve_id, $self, undef, $original )
                if C4::Context->preference('HoldsLog');

            Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
                { biblio_ids => [ $old_me->biblionumber ] } )
                unless $params->{skip_holds_queue}
                or !C4::Context->preference('RealTimeHoldsQueue');
        }
    );

    $self->cleanup_hold_group() unless $params->{skip_hold_group_cleanup};

    if ($autofill_next) {
        my ( undef, $next_hold ) = C4::Reserves::CheckReserves( $self->item );
        if ($next_hold) {
            my $is_transfer = $self->branchcode ne $next_hold->{branchcode};

            C4::Reserves::ModReserveAffect(
                $self->itemnumber,        $self->borrowernumber, $is_transfer,
                $next_hold->{reserve_id}, $self->desk_id,        $autofill_next
            );
            C4::Items::ModItemTransfer( $self->itemnumber, $self->branchcode, $next_hold->{branchcode}, "Reserve" )
                if $is_transfer;
        }
    }

    return $self;
}

=head3 fill

    $hold->fill({ [ item_id => $item->id ] });

This method marks the hold as filled. It effectively moves it to old_reserves.
The optional I<item_id> parameter is used to set the information about the
item that filled the hold.

=cut

sub fill {
    my ( $self, $params ) = @_;
    $self->_result->result_source->schema->txn_do(
        sub {
            my $patron = $self->patron;

            my $original = C4::Context->preference('HoldsLog') ? $self->unblessed : undef;

            $self->set(
                {
                    found     => 'F',
                    priority  => 0,
                    timestamp => dt_from_string->strftime('%Y-%m-%d %H:%M:%S'),
                    $params->{item_id} ? ( itemnumber => $params->{item_id} ) : (),
                }
            );

            my $old_me = $self->_move_to_old;

            Koha::Plugins->call(
                'after_hold_action',
                {
                    action  => 'fill',
                    payload => { hold => $old_me->get_from_storage }
                }
            );

            # anonymize if required
            $old_me->anonymize
                if $patron->privacy == 2;

            $self->SUPER::delete();    # Do not add a DELETE log

            # now fix the priority on the others....
            C4::Reserves::_FixPriority( { biblionumber => $self->biblionumber } );

            if ( C4::Context->preference('HoldFeeMode') eq 'any_time_is_collected' ) {
                my $fee = $patron->category->reservefee // 0;
                if ( $fee > 0 ) {
                    $patron->account->add_debit(
                        {
                            amount      => $fee,
                            description => $self->biblio->title,
                            user_id     => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                            library_id  => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
                            interface   => C4::Context->interface,
                            type        => 'RESERVE',
                            item_id     => $self->itemnumber
                        }
                    );
                }
            }

            C4::Log::logaction( 'HOLDS', 'FILL', $self->id, $self, undef, $original )
                if C4::Context->preference('HoldsLog');

            # if this hold was part of a group, cancel other holds in the group
            if ( $self->hold_group_id ) {
                my @holds = $self->hold_group->holds->as_list;
                foreach my $h (@holds) {
                    $h->cancel( { skip_hold_group_cleanup => 1 } ) unless $h->reserve_id == $self->id;
                }
            }
            $self->cleanup_hold_group();

            Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue(
                { biblio_ids => [ $old_me->biblionumber ] } )
                if C4::Context->preference('RealTimeHoldsQueue');
        }
    );
    return $self;
}

=head3 revert_found

    $hold->revert_found();

Reverts any 'found' hold back to a regular hold with a priority of 1.
This method can revert holds in 'waiting' (W), 'in transit' (T), or 'in processing' (P) status.

For waiting holds, the desk_id is also cleared since the hold is no longer waiting
at a specific desk. For in transit and in processing holds, desk_id remains unchanged
(typically NULL as these statuses don't set desk_id).

=cut

sub revert_found {
    my ( $self, $params ) = @_;

    Koha::Exceptions::InvalidStatus->throw( invalid_status => 'hold_not_found' )
        unless $self->is_found;

    $self->_result->result_source->schema->txn_do(
        sub {
            my $original = C4::Context->preference('HoldsLog') ? $self->unblessed : undef;

            # Increment the priority of all other non-waiting
            # reserves for this bib record
            my $holds = Koha::Holds->search(
                {
                    biblionumber => $self->biblionumber,
                    priority     => { '>' => 0 }
                }
            )->update(
                { priority    => \'priority + 1' },
                { no_triggers => 1 }
            );

            ## Fix up the currently found reserve
            $self->set(
                {
                    priority       => 1,
                    found          => undef,
                    waitingdate    => undef,
                    expirationdate => $self->patron_expiration_date,
                    itemnumber     => $self->item_level_hold ? $self->itemnumber : undef,
                    ( $self->is_waiting ? ( desk_id => undef ) : () ),
                }
            )->store( { hold_reverted => 1 } );

            logaction( 'HOLDS', 'MODIFY', $self->id, $self, undef, $original )
                if C4::Context->preference('HoldsLog');

            C4::Reserves::_FixPriority( { biblionumber => $self->biblionumber } );

            Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $self->biblionumber ] } )
                if C4::Context->preference('RealTimeHoldsQueue');
        }
    );
    return $self;
}

=head3 sub change_type

    $hold->change_type                # to record level
    $hold->change_type( $itemnumber ) # to item level

Changes hold type between record and item level holds, only if record has
exactly one hold for a patron. This is because Koha expects all holds for
a patron on a record to be alike.

=cut

sub change_type {
    my ( $self, $itemnumber ) = @_;

    my $record_holds_per_patron = Koha::Holds->search(
        {
            borrowernumber => $self->borrowernumber,
            biblionumber   => $self->biblionumber,
        }
    );

    if ( $itemnumber && $self->itemnumber ) {
        $self->itemnumber($itemnumber)->store;
        return $self;
    }

    if ( $record_holds_per_patron->count == 1 ) {
        $self->set(
            {
                itemnumber      => $itemnumber ? $itemnumber : undef,
                item_level_hold => $itemnumber ? 1           : 0,
            }
        )->store;
    } else {
        Koha::Exceptions::Hold::CannotChangeHoldType->throw();
    }

    return $self;
}

=head3 store

Override base store method to set default
expirationdate for holds.

=cut

sub store {
    my ( $self, $params ) = @_;

    my $hold_reverted = $params->{hold_reverted} // 0;

    Koha::Exceptions::Hold::MissingPickupLocation->throw() unless $self->branchcode;

    if ( !$self->in_storage ) {
        if ( !$self->expirationdate && $self->patron_expiration_date ) {
            $self->expirationdate( $self->patron_expiration_date );
        }

        if ( C4::Context->preference('DefaultHoldExpirationdate')
            && !$self->expirationdate )
        {
            $self->_set_default_expirationdate;
        }
    } else {

        my %updated_columns = $self->_result->get_dirty_columns;
        return $self->SUPER::store unless %updated_columns;
        if ( exists $updated_columns{reservedate} || $hold_reverted ) {
            if (
                (
                    C4::Context->preference('DefaultHoldExpirationdate')
                    && ( !exists $updated_columns{expirationdate} || $hold_reverted )
                )
                )
            {
                if ( $self->patron_expiration_date ) {
                    $self->expirationdate( $self->patron_expiration_date );
                } else {
                    $self->_set_default_expirationdate;
                }
            }
        }
        if ( exists $updated_columns{branchcode} ) {
            Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $self->biblionumber ] } );
        }
    }

    $self = $self->SUPER::store;
}

sub _set_default_expirationdate {
    my $self = shift;

    my $period   = C4::Context->preference('DefaultHoldExpirationdatePeriod');
    my $timeunit = C4::Context->preference('DefaultHoldExpirationdateUnitOfTime') || 'days';

    if ( defined C4::Context->preference('DefaultHoldExpirationdatePeriod')
        && C4::Context->preference('DefaultHoldExpirationdatePeriod') ne '' )
    {
        $self->expirationdate( dt_from_string( $self->reservedate )->add( $timeunit => $period ) );
    }
}

=head3 hold_group

    my $hold_group = $hold->hold_group;
    my $hold_group_id = $hold_group->id if $hold_group;

Return the Koha::HoldGroup object of a hold if part of a hold group

=cut

sub hold_group {
    my ($self) = @_;

    if ( $self->hold_group_id ) {
        return Koha::HoldGroups->find( $self->hold_group_id );
    }

    return;
}

=head3 _move_to_old

my $is_moved = $hold->_move_to_old;

Move a hold to the old_reserve table following the same pattern as Koha::Patron->move_to_deleted

=cut

sub _move_to_old {
    my ($self) = @_;
    my $hold_infos = $self->unblessed;
    require Koha::Old::Hold;
    return Koha::Old::Hold->new($hold_infos)->store;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Hold object
on the API.

=cut

sub to_api_mapping {
    return {
        reserve_id             => 'hold_id',
        borrowernumber         => 'patron_id',
        reservedate            => 'hold_date',
        biblionumber           => 'biblio_id',
        deleted_biblionumber   => 'deleted_biblio_id',
        branchcode             => 'pickup_library_id',
        notificationdate       => undef,
        reminderdate           => undef,
        cancellationdate       => 'cancellation_date',
        reservenotes           => 'notes',
        found                  => 'status',
        itemnumber             => 'item_id',
        waitingdate            => 'waiting_date',
        expirationdate         => 'expiration_date',
        patron_expiration_date => undef,
        lowestPriority         => 'lowest_priority',
        suspend                => 'suspended',
        suspend_until          => 'suspended_until',
        itemtype               => 'item_type',
        item_level_hold        => 'item_level',
    };
}

=head3 can_update_pickup_location_opac

    my $can_update_pickup_location_opac = $hold->can_update_pickup_location_opac;

Returns if a hold can change pickup location from opac

=cut

sub can_update_pickup_location_opac {
    my ($self) = @_;

    my @statuses = split /,/, C4::Context->preference("OPACAllowUserToChangeBranch");
    foreach my $status (@statuses) {
        return 1 if ( $status eq 'pending'   && !$self->is_found && !$self->is_suspended );
        return 1 if ( $status eq 'intransit' && $self->is_in_transit );
        return 1 if ( $status eq 'suspended' && $self->is_suspended );
    }
    return 0;
}

=head3 strings_map

Returns a map of column name to string representations including the string.

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    my $strings = {
        pickup_library_id => { str => $self->pickup_library->branchname, type => 'library' },
    };

    if ( defined $self->cancellation_reason ) {
        my $av = Koha::AuthorisedValues->search(
            {
                category         => 'HOLD_CANCELLATION',
                authorised_value => $self->cancellation_reason,
            }
        );
        my $cancellation_reason_str =
              $av->count
            ? $params->{public}
                ? $av->next->opac_description
                : $av->next->lib
            : $self->cancellation_reason;

        $strings->{cancellation_reason} = {
            category => 'HOLD_CANCELLATION',
            str      => $cancellation_reason_str,
            type     => 'av',
        };
    }

    return $strings;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Reserve';
}

=head1 AUTHORS

Kyle M Hall <kyle@bywatersolutions.com>
Jonathan Druart <jonathan.druart@bugs.koha-community.org>
Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
