#!/usr/bin/perl

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

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use C4::Calendar;

use Koha::Biblio::Availability::Booking;
use Koha::CirculationRules;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'check() parameter tests' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $today  = dt_from_string->truncate( to => 'day' );

    throws_ok {
        Koha::Biblio::Availability::Booking->check( { from => $today, to => $today } )
    }
    'Koha::Exceptions::MissingParameter', 'Missing biblio parameter throws';

    throws_ok {
        Koha::Biblio::Availability::Booking->check( { biblio => $biblio, to => $today } )
    }
    'Koha::Exceptions::MissingParameter', 'Missing from parameter throws';

    throws_ok {
        Koha::Biblio::Availability::Booking->check( { biblio => $biblio, from => $today } )
    }
    'Koha::Exceptions::MissingParameter', 'Missing to parameter throws';

    my $availability =
        Koha::Biblio::Availability::Booking->check( { biblio => $biblio, from => $today, to => $today } );
    is_deeply(
        [ sort keys %$availability ], [ 'availability', 'item_ids' ],
        'check returns the availability structure when the mandatory parameters are passed'
    );

    $schema->storage->txn_rollback;
};

subtest 'check() availability tests' => sub {
    plan tests => 24;

    $schema->storage->txn_begin;

    # Rule context must be fully under our control
    Koha::CirculationRules->search( { rule_name => { '-in' => [ 'bookings_lead_period', 'bookings_trail_period' ] } } )
        ->delete;

    my $branch   = $builder->build_object( { class => 'Koha::Libraries' } );
    my $itemtype = $builder->build_object( { class => 'Koha::ItemTypes' } );
    my $biblio   = $builder->build_sample_biblio();
    my $item1    = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype->itemtype } );
    my $item2 = $builder->build_sample_item(
        { biblionumber => $biblio->biblionumber, bookable => 1, itype => $itemtype->itemtype } );
    my $unbookable_item = $builder->build_sample_item( { biblionumber => $biblio->biblionumber, bookable => 0 } );

    Koha::CirculationRules->set_rules(
        {
            branchcode => $branch->branchcode,
            itemtype   => $itemtype->itemtype,
            rules      => {
                bookings_lead_period  => 2,
                bookings_trail_period => 1,
            },
        }
    );

    # Anchor booked days at local noon so their library-timezone date part
    # matches the local calendar date in any sane server timezone
    my $today = dt_from_string->truncate( to => 'day' );
    my $day   = sub { $today->clone->add( days => $_[0] ) };
    my $calc  = sub { Koha::Biblio::Availability::Booking->check( { biblio => $biblio, @_ } ) };

    my $booking = $builder->build_object(
        {
            class => 'Koha::Bookings',
            value => {
                biblio_id  => $biblio->biblionumber,
                item_id    => $item1->itemnumber,
                start_date => $day->(10)->add( hours => 12 ),
                end_date   => $day->(12)->add( hours => 12 ),
                status     => 'new',
            }
        }
    );

    my $checkout = $builder->build_object(
        {
            class => 'Koha::Checkouts',
            value => {
                itemnumber => $item2->itemnumber,
                issuedate  => $day->(-1)->add( hours => 12 ),
                date_due   => $day->(3)->add( hours => 12 ),
                returndate => undef,
            }
        }
    );

    my %context = (
        from              => $today,
        to                => $day->(30),
        pickup_library_id => $branch->branchcode,
        item_type_id      => $itemtype->itemtype,
    );

    my $availability = $calc->(%context);
    my $map          = $availability->{availability};

    # Expected per-(date, item) cell: reason codes grouped by category, with
    # the other categories empty.
    my $cell = sub {
        my (%by_cat) = @_;
        return {
            blockers => { map { $_ => 1 } @{ $by_cat{blockers} // [] } },
            confirms => { map { $_ => 1 } @{ $by_cat{confirms} // [] } },
            warnings => { map { $_ => 1 } @{ $by_cat{warnings} // [] } },
        };
    };

    is_deeply(
        $availability->{item_ids},
        [ sort { $a <=> $b } ( $item1->itemnumber, $item2->itemnumber ) ],
        "item_ids contains the bookable items only"
    );

    is_deeply(
        $map->{ $day->(10)->ymd }->{ $item1->itemnumber },
        $cell->( blockers => ['booking'] ), "Booked start day marked"
    );
    is_deeply(
        $map->{ $day->(12)->ymd }->{ $item1->itemnumber },
        $cell->( blockers => ['booking'] ), "Booked end day marked"
    );
    is_deeply(
        $map->{ $day->(8)->ymd }->{ $item1->itemnumber },
        $cell->( blockers => ['lead'] ),
        "Lead window opens lead_period days before the booking"
    );
    is_deeply(
        $map->{ $day->(9)->ymd }->{ $item1->itemnumber },
        $cell->( blockers => ['lead'] ), "Lead window closes on start - 1"
    );
    is_deeply(
        $map->{ $day->(13)->ymd }->{ $item1->itemnumber },
        $cell->( blockers => ['trail'] ), "Trail window after the booking"
    );
    is_deeply(
        $map->{ $day->(14)->ymd }->{ $item1->itemnumber },
        $cell->( warnings => ['lead_theoretical'] ),
        "Theoretical lead of a follow-up booking starts after the trail"
    );
    is_deeply(
        $map->{ $day->(15)->ymd }->{ $item1->itemnumber },
        $cell->( warnings => ['lead_theoretical'] ),
        "Theoretical lead spans lead_period days"
    );
    is(
        $map->{ $day->(16)->ymd }->{ $item1->itemnumber }, undef,
        "No markers beyond the theoretical lead"
    );
    is_deeply(
        $map->{ $today->ymd }->{ $item1->itemnumber },
        $cell->( warnings => ['lead_floor'] ), "Minimum-advance floor starts today"
    );
    is_deeply(
        $map->{ $day->(1)->ymd }->{ $item1->itemnumber },
        $cell->( warnings => ['lead_floor'] ), "Minimum-advance floor spans lead_period days"
    );

    is_deeply(
        $map->{ $today->ymd }->{ $item2->itemnumber },
        $cell->( blockers => ['checkout'] ),
        "Checkout day marked; harder block suppresses the lead floor"
    );
    is_deeply(
        $map->{ $day->(3)->ymd }->{ $item2->itemnumber },
        $cell->( blockers => ['checkout'] ), "Checkout due day marked"
    );
    is( $map->{ $day->(4)->ymd }->{ $item2->itemnumber }, undef, "No markers after the due date" );

    my $unbookable_marked = grep { exists $_->{ $unbookable_item->itemnumber } } values %$map;
    is( $unbookable_marked, 0, "Items that cannot be booked are never marked" );

    my $without_booking = $calc->( %context, booking_id => $booking->booking_id );
    is(
        $without_booking->{availability}->{ $day->(10)->ymd }->{ $item1->itemnumber }, undef,
        "booking_id removes the booking from the calculation"
    );
    is(
        $without_booking->{availability}->{ $day->(8)->ymd }->{ $item1->itemnumber }, undef,
        "booking_id removes the booking's windows too"
    );

    my $single_item = $calc->( %context, item_id => $item1->itemnumber );
    is_deeply(
        $single_item->{item_ids}, [ 0 + $item1->itemnumber ],
        "item_id restricts the calculation to the passed item"
    );
    my $item2_marked = grep { exists $_->{ $item2->itemnumber } } values %{ $single_item->{availability} };
    is( $item2_marked, 0, "Other items are not marked when item_id is passed" );

    my $holiday = $day->(20);
    C4::Calendar->new( branchcode => $branch->branchcode )->insert_single_holiday(
        day         => $holiday->day,
        month       => $holiday->month,
        year        => $holiday->year,
        title       => 'Closed',
        description => 'Closed'
    );
    my $with_holiday = $calc->(%context);
    is_deeply(
        $with_holiday->{availability}->{ $holiday->ymd }->{ $item1->itemnumber },
        $cell->( warnings => ['holiday'] ),
        "Closed days of the pickup library are marked for every item"
    );
    is_deeply(
        $with_holiday->{availability}->{ $holiday->ymd }->{ $item2->itemnumber },
        $cell->( warnings => ['holiday'] ),
        "... including items blocked elsewhere in the range"
    );

    my $without_context = $calc->( from => $today, to => $day->(30) );
    is_deeply(
        $without_context->{availability}->{ $day->(10)->ymd }->{ $item1->itemnumber },
        $cell->( blockers => ['booking'] ),
        "Bookings are marked without a pickup library context"
    );
    is(
        $without_context->{availability}->{ $day->(8)->ymd }->{ $item1->itemnumber }, undef,
        "No lead/trail windows when no rule matches the context"
    );
    is(
        $without_context->{availability}->{ $holiday->ymd }->{ $item1->itemnumber }, undef,
        "No holiday markers without a pickup library context"
    );

    $schema->storage->txn_rollback;
};
