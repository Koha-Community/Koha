package Koha::Biblio::Availability::Booking;

# Copyright 2026 LMSCloud GmbH
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

use DateTime;

use Koha::Calendar;
use Koha::CirculationRules;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::Result::Availability;

# The reason vocabulary and the category each reason belongs to.
# blockers prevent a new booking; warnings are advisory context that does not.
use constant REASON_CATEGORY => {
    booking          => 'blockers',
    checkout         => 'blockers',
    lead             => 'blockers',
    trail            => 'blockers',
    holiday          => 'warnings',
    lead_floor       => 'warnings',
    lead_theoretical => 'warnings',
};

# The Koha::Result::Availability method that files a reason under its category.
use constant ADD_METHOD_FOR_CATEGORY => {
    blockers => 'add_blocker',
    warnings => 'add_warning',
};

=head1 NAME

Koha::Biblio::Availability::Booking - Booking availability of a bibliographic record over a date range

=head1 SYNOPSIS

    use Koha::Biblio::Availability::Booking;

    my $availability = Koha::Biblio::Availability::Booking->check(
        {
            biblio => $biblio,
            from   => $from,
            to     => $to,
        }
    );

Usually reached through the C<< $biblio->booking_availability >> wrapper.

=head1 DESCRIPTION

Calculates, for each calendar date in an inclusive range, the booking
availability of a bibliographic record's bookable items: a sparse map of
dates to item ids, where each cell records the C<blockers> that prevent a
new booking and the C<warnings> that are advisory only.

=head1 API

=head2 Class methods

=head3 check

    my $availability = Koha::Biblio::Availability::Booking->check(
        {
            biblio => $biblio,
            from   => $from,
            to     => $to,
            [ pickup_library_id => $pickup_library_id, ]
            [ patron            => $patron, ]
            [ item_type_id      => $item_type_id, ]
            [ item_id           => $item_id, ]
            [ booking_id        => $booking_id, ]
        }
    );

Computes the booking availability over the range and returns a hashref
with the bookable item ids and a sparse per-(date, item) availability
map. Each cell records three reason sets: C<blockers> that prevent a new
booking, C<confirms> (always empty for bookings), and C<warnings> that
are advisory context only.

    {
        item_ids     => [ 101, 102 ],
        availability => {
            '2026-08-10' => {
                101 => { blockers => { booking => 1 }, confirms => {}, warnings => {} },
                102 => { blockers => { lead => 1 }, confirms => {}, warnings => { holiday => 1 } },
            },
        },
    }

C<blockers> hold the reasons that block a new booking on that date for
that item: C<booking>, C<checkout>, C<lead>, C<trail>. An item with no
C<blockers> on a date (or absent from the map) is bookable that day, so
the available dates for an item are the complement of its blocked dates.
C<warnings> hold context that does NOT block a booking, for display only:
C<holiday>, C<lead_floor>, C<lead_theoretical>. A cell exists only when it
carries at least one blocker or warning, but always carries all three
category keys.

Booking dates and checkout due dates are both attributed to their local
calendar day in the library timezone.

I<biblio>, I<from> and I<to> are mandatory; a
C<Koha::Exceptions::MissingParameter> exception is thrown when one of
them is missing. I<from> and I<to> bound the inclusive date range and
are truncated to calendar days.

I<pickup_library_id>, I<patron> and I<item_type_id> are the context for
resolving the effective C<bookings_lead_period> and
C<bookings_trail_period> circulation rules; the same context applies to
every existing booking, matching the booking calendar. Holiday reasons
are only emitted when a pickup library is passed.

I<item_id> restricts the calculation to a single bookable item.
I<booking_id> excludes a booking from the calculation; this is helpful
when you are updating an existing booking.

=cut

sub check {
    my ( $class, $params ) = @_;

    for my $mandatory (qw( biblio from to )) {
        Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: $mandatory")
            unless $params->{$mandatory};
    }

    my $self = bless {
        biblio            => $params->{biblio},
        from              => dt_from_string( $params->{from} )->set_time_zone('floating')->truncate( to => 'day' ),
        to                => dt_from_string( $params->{to} )->set_time_zone('floating')->truncate( to => 'day' ),
        pickup_library_id => $params->{pickup_library_id},
        patron            => $params->{patron},
        item_type_id      => $params->{item_type_id},
        item_id           => $params->{item_id},
        booking_id        => $params->{booking_id},
        availability      => {},
        trail_ends        => [],
    }, $class;

    my $bookable_items = $self->{biblio}->bookable_items;
    $bookable_items = $bookable_items->search( { itemnumber => $self->{item_id} } )
        if $self->{item_id};
    $self->{bookable_item_ids} = [ $bookable_items->get_column('itemnumber') ];

    my $rules = Koha::CirculationRules->get_effective_rules(
        {
            rules        => [ 'bookings_lead_period', 'bookings_trail_period' ],
            branchcode   => $self->{pickup_library_id},
            categorycode => $self->{patron} ? $self->{patron}->categorycode : undef,
            itemtype     => $self->{item_type_id},
        }
    );
    $self->{lead_days}  = $rules->{bookings_lead_period}  || 0;
    $self->{trail_days} = $rules->{bookings_trail_period} || 0;

    $self->_mark_bookings;
    $self->_mark_checkouts;
    $self->_mark_holidays;
    $self->_mark_lead_windows;

    # Cells are built as Koha::Result::Availability objects (see _mark), so
    # they need flattening to plain hashrefs for the wire format.
    my %availability;
    while ( my ( $date, $by_item ) = each %{ $self->{availability} } ) {
        $availability{$date} = { map { $_ => $by_item->{$_}->to_hashref } keys %$by_item };
    }

    return {
        item_ids     => [ sort { $a <=> $b } map { 0 + $_ } @{ $self->{bookable_item_ids} } ],
        availability => \%availability,
    };
}

=head2 Internal methods

=head3 _mark_bookings

Marks the days blocked by existing bookings: C<booking> over the booked
span, C<lead> before it and C<trail> after it. Collects the trail window
ends for C<_mark_lead_windows>.

=cut

sub _mark_bookings {
    my ($self) = @_;

    my $lead_days  = $self->{lead_days};
    my $trail_days = $self->{trail_days};

    # The search window is padded by the lead/trail periods so bookings
    # outside the range whose windows reach into it are still found; the
    # extra day absorbs timezone day-boundary shifts.
    my $dtf          = Koha::Database->new->schema->storage->datetime_parser;
    my $window_start = $self->{from}->clone->subtract( days => $trail_days + $lead_days + 1 );
    my $window_end   = $self->{to}->clone->add( days => $lead_days + 1 );

    my $bookings = $self->{biblio}->bookings(
        {
            status     => { '-not_in' => [ 'cancelled', 'completed' ] },
            item_id    => { '-in'     => $self->{bookable_item_ids} },
            start_date => { '<='      => $dtf->format_datetime($window_end) },
            end_date   => { '>='      => $dtf->format_datetime($window_start) },
            (
                $self->{booking_id}
                ? ( booking_id => { '!=' => $self->{booking_id} } )
                : ()
            ),
        }
    );

    while ( my $booking = $bookings->next ) {
        my $item_id = $booking->item_id;

        # Booked days follow the library-timezone day-boundary contract:
        # dt_from_string yields the instant in the library timezone, whose
        # local date part is the booked calendar date (see Bug 42868).
        my $start = dt_from_string( $booking->start_date )->set_time_zone('floating')->truncate( to => 'day' );
        my $end   = dt_from_string( $booking->end_date )->set_time_zone('floating')->truncate( to => 'day' );

        $self->_mark( { item_id => $item_id, reason => 'booking', start => $start, end => $end } );
        $self->_mark(
            {
                item_id => $item_id,
                reason  => 'lead',
                start   => $start->clone->subtract( days => $lead_days ),
                end     => $start->clone->subtract( days => 1 ),
            }
        ) if $lead_days;

        if ($trail_days) {
            my $trail_end = $end->clone->add( days => $trail_days );
            $self->_mark(
                {
                    item_id => $item_id,
                    reason  => 'trail',
                    start   => $end->clone->add( days => 1 ),
                    end     => $trail_end,
                }
            );
            push @{ $self->{trail_ends} }, [ $item_id, $trail_end ];
        }
    }

    return;
}

=head3 _mark_checkouts

Marks the days blocked by current checkouts as C<checkout>, from the
issue date through the due date.

=cut

sub _mark_checkouts {
    my ($self) = @_;

    my $dtf          = Koha::Database->new->schema->storage->datetime_parser;
    my $window_start = $self->{from}->clone->subtract( days => $self->{trail_days} + $self->{lead_days} + 1 );

    my $checkouts = $self->{biblio}->current_checkouts->search(
        {
            "me.itemnumber" => { '-in' => $self->{bookable_item_ids} },
            date_due        => { '>='  => $dtf->format_datetime($window_start) },
        }
    );
    while ( my $checkout = $checkouts->next ) {

        # Due dates are real local instants, not day-contract values
        my $start = dt_from_string( $checkout->issuedate )->set_time_zone('floating')->truncate( to => 'day' );
        my $end   = dt_from_string( $checkout->date_due )->set_time_zone('floating')->truncate( to => 'day' );
        $self->_mark( { item_id => $checkout->itemnumber, reason => 'checkout', start => $start, end => $end } );
    }

    return;
}

=head3 _mark_holidays

Marks the pickup library's closed days as C<holiday> for every item.
Does nothing unless a pickup library was passed.

=cut

sub _mark_holidays {
    my ($self) = @_;

    return unless $self->{pickup_library_id};

    my $calendar = Koha::Calendar->new( branchcode => $self->{pickup_library_id} );
    for ( my $day = $self->{from}->clone ; DateTime->compare( $day, $self->{to} ) <= 0 ; $day->add( days => 1 ) ) {
        next unless $calendar->is_holiday($day);
        $self->_mark( { item_id => $_, reason => 'holiday', start => $day, end => $day } )
            for @{ $self->{bookable_item_ids} };
    }

    return;
}

=head3 _mark_lead_windows

Marks the C<lead_floor> window (no new booking can start until the lead
period from today has passed) and, for each existing booking, the
C<lead_theoretical> window of a hypothetical follow-up booking placed
right after its trail period. Does nothing unless a lead period applies.

=cut

sub _mark_lead_windows {
    my ($self) = @_;

    my $lead_days = $self->{lead_days};
    return unless $lead_days;

    my $today = dt_from_string->set_time_zone('floating')->truncate( to => 'day' );

    $self->_soft_mark(
        {
            item_id => $_,
            reason  => 'lead_floor',
            start   => $today->clone,
            end     => $today->clone->add( days => $lead_days - 1 ),
        }
    ) for @{ $self->{bookable_item_ids} };

    for my $trail_end ( @{ $self->{trail_ends} } ) {
        my ( $item_id, $end ) = @$trail_end;
        my $start = $end->clone->add( days => 1 );
        $start = $today->clone if DateTime->compare( $start, $today ) < 0;
        $self->_soft_mark(
            {
                item_id => $item_id,
                reason  => 'lead_theoretical',
                start   => $start,
                end     => $end->clone->add( days => $lead_days ),
            }
        );
    }

    return;
}

=head3 _mark

    $self->_mark( { item_id => $item_id, reason => $reason, start => $start, end => $end } );

Records a reason for an item on every day of the passed span, clamped to
the requested range. The reason is filed under its category (C<blockers>
or C<warnings>, per C<REASON_CATEGORY>) on that day's L<Koha::Result::Availability>
cell, creating it on first use.

=cut

sub _mark {
    my ( $self, $params ) = @_;

    my ( $item_id, $reason, $start, $end ) = @{$params}{qw(item_id reason start end)};

    my $category = REASON_CATEGORY->{$reason}
        or Koha::Exceptions::WrongParameter->throw("Unknown booking availability reason: $reason");
    my $add_method = ADD_METHOD_FOR_CATEGORY->{$category};

    my $day  = ( DateTime->compare( $start, $self->{from} ) >= 0 ? $start : $self->{from} )->clone;
    my $last = ( DateTime->compare( $end,   $self->{to} ) <= 0   ? $end   : $self->{to} );
    while ( DateTime->compare( $day, $last ) <= 0 ) {
        my $cell = $self->{availability}->{ $day->ymd }->{$item_id} //= Koha::Result::Availability->new;
        $cell->$add_method( $reason => 1 );
        $day->add( days => 1 );
    }

    return;
}

=head3 _soft_mark

    $self->_soft_mark( { item_id => $item_id, reason => $reason, start => $start, end => $end } );

Like C<_mark>, but skips the days on which the item is already blocked
harder (C<booking> or C<checkout>).

=cut

sub _soft_mark {
    my ( $self, $params ) = @_;

    my ( $item_id, $reason, $start, $end ) = @{$params}{qw(item_id reason start end)};

    for ( my $day = $start->clone ; DateTime->compare( $day, $end ) <= 0 ; $day->add( days => 1 ) ) {
        next if DateTime->compare( $day, $self->{from} ) < 0 or DateTime->compare( $day, $self->{to} ) > 0;

        # Read without autovivifying: touching a not-yet-marked cell must
        # not spawn an empty availability entry in the output.
        my $cell = ( $self->{availability}->{ $day->ymd } // {} )->{$item_id};
        next if $cell and ( $cell->blockers->{booking} or $cell->blockers->{checkout} );
        $self->_mark( { item_id => $item_id, reason => $reason, start => $day, end => $day } );
    }

    return;
}

=head1 AUTHOR

Paul Derscheid <paul.derscheid@lmscloud.de>

=cut

1;
