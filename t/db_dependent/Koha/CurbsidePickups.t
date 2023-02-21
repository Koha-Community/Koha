#!/usr/bin/perl

# This file is part of Koha
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

use Test::More tests => 4;
use Test::Exception;

use C4::Calendar;
use Koha::CurbsidePickups;
use Koha::CurbsidePickupPolicies;
use Koha::Calendar;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Dates;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder          = t::lib::TestBuilder->new;
my $library          = $builder->build_object( { class => 'Koha::Libraries' } );
my $library_disabled = $builder->build_object( { class => 'Koha::Libraries' } );
my $logged_in_patron = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => { branchcode => $library->branchcode }
    }
);
t::lib::Mocks::mock_userenv( { patron => $logged_in_patron } );
my $patron = $builder->build_object(
    {
        class => 'Koha::Patrons',
        value => { branchcode => $library->branchcode }
    }
);

my $policy = Koha::CurbsidePickupPolicy->new(
    {
        branchcode              => $library->branchcode,
        enabled                 => 1,
        enable_waiting_holds_only => 0,
        pickup_interval         => 15,
        patrons_per_interval    => 2,
        patron_scheduled_pickup => 1
    }
)->store;
my $policy_disabled = Koha::CurbsidePickupPolicy->new(
    {
        branchcode              => $library_disabled->branchcode,
        enabled                 => 0,
        enable_waiting_holds_only => 0,
        pickup_interval         => 30,
        patrons_per_interval    => 2,
        patron_scheduled_pickup => 1
    }
)->store;

# Open Mondays from 12 to 18
$policy->add_opening_slot('1-12:00-18:45');

my $today = dt_from_string;

subtest 'Create a pickup' => sub {
    plan tests => 10;

    # Day and datetime are ok
    my $next_monday =
      $today->clone->add( days => ( 1 - $today->day_of_week ) % 7 );
    my $schedule_dt =
      $next_monday->set_hour(15)->set_minute(00)->set_second(00);
    my $params =
        {
            branchcode                => $library->branchcode,
            borrowernumber            => $patron->borrowernumber,
            scheduled_pickup_datetime => $schedule_dt,
            notes                     => 'just a note'
        };

    throws_ok {
        Koha::CurbsidePickup->new({%$params, branchcode => $library_disabled->branchcode})->store;
    }
    'Koha::Exceptions::CurbsidePickup::NotEnabled',
      'Cannot create pickup if the policy does not allow it';

   $policy->enabled(1)->store;

   $policy->enable_waiting_holds_only(1)->store;
    throws_ok {
        Koha::CurbsidePickup->new($params)->store;
    }
    'Koha::Exceptions::CurbsidePickup::NoWaitingHolds',
      'Cannot create pickup for a patron without waiting hold if flag is set';

    $policy->enable_waiting_holds_only(0)->store;
    my $cp = Koha::CurbsidePickup->new($params)->store;
    is( $cp->status, 'to-be-staged' );
    is( $patron->curbside_pickups->count, 1, 'Koha::Patron->curbside_pickups' );

    throws_ok {
        Koha::CurbsidePickup->new($params)->store
    }
    'Koha::Exceptions::CurbsidePickup::TooManyPickups',
      'Cannot create 2 pickups for the same patron';

    $cp->delete;

    $schedule_dt = $next_monday->set_hour(18)->set_minute(15)->set_second(00);
    $cp          = Koha::CurbsidePickup->new( { %$params, scheduled_pickup_datetime => $schedule_dt } )->store;
    ok($cp);
    $cp->delete;

    # Day is not ok
    my $next_tuesday =
      $today->clone->add( days => ( 2 - $today->day_of_week ) % 7 );
    $schedule_dt = $next_tuesday->set_hour(15)->set_minute(00)->set_second(00);
    throws_ok {
        Koha::CurbsidePickup->new({%$params, scheduled_pickup_datetime => $schedule_dt})->store;
    }
    'Koha::Exceptions::CurbsidePickup::NoMatchingSlots',
      'Cannot create a pickup on a day without opening slots defined';

    # Day ok but datetime not ok
    $schedule_dt = $next_monday->set_hour(19)->set_minute(00)->set_second(00);
    throws_ok {
        Koha::CurbsidePickup->new({%$params, scheduled_pickup_datetime => $schedule_dt})->store;
    }
    'Koha::Exceptions::CurbsidePickup::NoMatchingSlots',
      'Cannot create a pickup on a time without opening slots defined';

    # Day ok, datetime inside the opening slot, but wrong (15:07 for instance)
    $schedule_dt = $next_monday->set_hour(15)->set_minute(7)->set_second(0);
    throws_ok {
        Koha::CurbsidePickup->new({%$params, scheduled_pickup_datetime => $schedule_dt})->store;
    }
    'Koha::Exceptions::CurbsidePickup::NoMatchingSlots',
'Cannot create a pickup on a time that is not matching the start of an interval';

    # Day is a holiday
    Koha::Caches->get_instance->flush_all;
    C4::Calendar->new( branchcode => $library->branchcode )->insert_week_day_holiday(
        weekday     => 1,
        title       => '',
        description => 'Mondays',
    );
    my $calendar = Koha::Calendar->new( branchcode => $library->branchcode );
    throws_ok {
        Koha::CurbsidePickup->new({%$params, scheduled_pickup_datetime => $schedule_dt})->store;
    }
    'Koha::Exceptions::CurbsidePickup::LibraryIsClosed',
      'Cannot create a pickup on a holiday';

    C4::Context->dbh->do(q{DELETE FROM repeatable_holidays});
    Koha::Caches->get_instance->flush_all;
};

subtest 'workflow' => sub {
    plan tests => 11;

    my $pickups =
      Koha::CurbsidePickups->search( { branchcode => $library->branchcode } );

    my $next_monday =
      $today->clone->add( days => ( 1 - $today->day_of_week ) % 7 );
    my $schedule_dt =
      $next_monday->set_hour(15)->set_minute(00)->set_second(00);
    my $cp = Koha::CurbsidePickup->new(
        {
            branchcode                => $library->branchcode,
            borrowernumber            => $patron->borrowernumber,
            scheduled_pickup_datetime => $schedule_dt,
            notes                     => 'just a note'
        }
    )->store;
    is( $cp->status, 'to-be-staged' );
    is( $pickups->filter_by_to_be_staged->count, 1 );

    $cp->mark_as_staged;
    is( $cp->status, 'staged-and-ready' );
    is( $pickups->filter_by_staged_and_ready->count, 1 );

    $cp->mark_as_unstaged;
    is( $cp->status, 'to-be-staged' );

    $cp->mark_as_staged;

    $cp->mark_patron_has_arrived;
    is( $cp->status, 'patron-is-outside' );
    is( $pickups->filter_by_patron_outside->count, 1 );

    $cp->mark_as_delivered;
    is( $cp->status, 'delivered' );
    is( $pickups->filter_by_delivered->count, 1 );

    is( $pickups->filter_by_scheduled_today->count, 1 );
    $cp->scheduled_pickup_datetime($today->clone->subtract(days => 1))->store;
    is( $pickups->filter_by_scheduled_today->count, 0 );

    $cp->delete;
};

subtest 'mark_as_delivered' => sub {
    plan tests => 3;

    my $item = $builder->build_sample_item({ library => $library->branchcode });
    my $reserve_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            itemnumber     => $item->itemnumber,
        }
    );
    my $hold = Koha::Holds->find($reserve_id);
    $hold->set_waiting;

    my $next_monday =
      $today->clone->add( days => ( 1 - $today->day_of_week ) % 7 );
    my $schedule_dt =
      $next_monday->set_hour(15)->set_minute(00)->set_second(00);
    my $cp = Koha::CurbsidePickup->new(
        {
            branchcode                => $library->branchcode,
            borrowernumber            => $patron->borrowernumber,
            scheduled_pickup_datetime => $schedule_dt,
            notes                     => 'just a note'
        }
    )->store;

    $cp->mark_as_delivered;
    $cp->discard_changes;
    is( t::lib::Dates::compare( $cp->arrival_datetime, dt_from_string), 0, 'Arrival time has been set to now' );

    is( $hold->get_from_storage, undef, 'Hold has been filled' );
    my $checkout = Koha::Checkouts->find({ itemnumber => $item->itemnumber });
    is( $checkout->borrowernumber, $patron->borrowernumber, 'Item has correctly been checked out' );

    $cp->delete;
};

subtest 'notify_new_pickup' => sub {
    plan tests => 2;

    my $item =
      $builder->build_sample_item( { library => $library->branchcode } );
    my $reserve_id = C4::Reserves::AddReserve(
        {
            branchcode     => $library->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $item->biblionumber,
            priority       => 1,
            itemnumber     => $item->itemnumber,
        }
    );
    my $hold = Koha::Holds->find($reserve_id);
    $hold->set_waiting;

    my $next_monday =
      $today->clone->add( days => ( 1 - $today->day_of_week ) % 7 );
    my $schedule_dt =
      $next_monday->set_hour(15)->set_minute(00)->set_second(00);
    my $cp = Koha::CurbsidePickup->new(
        {
            branchcode                => $library->branchcode,
            borrowernumber            => $patron->borrowernumber,
            scheduled_pickup_datetime => $schedule_dt,
            notes                     => 'just a note'
        }
    )->store;

    $patron->set( { email => 'test@example.org' } )->store;
    my $dbh = C4::Context->dbh;
    $dbh->do( q|INSERT INTO borrower_message_preferences( borrowernumber, message_attribute_id ) VALUES ( ?, ?)|,
        undef, $patron->borrowernumber, 4
    );
    my $borrower_message_preference_id =
      $dbh->last_insert_id( undef, undef, "borrower_message_preferences", undef );
    $dbh->do(
        q|INSERT INTO borrower_message_transport_preferences( borrower_message_preference_id, message_transport_type) VALUES ( ?, ? )|,
        undef, $borrower_message_preference_id, 'email'
    );

    $cp->notify_new_pickup;

    my $messages = C4::Letters::GetQueuedMessages(
        { borrowernumber => $patron->borrowernumber } );
    is(
        $messages->[0]->{subject},
        sprintf ("You have scheduled a curbside pickup for %s", $library->branchname),
        "Notice correctly generated"
    );
    my $biblio_title = $item->biblio->title;
    like( $messages->[0]->{content},
        qr{$biblio_title}, "Content contains the list of waiting holds" );
};

$schema->storage->txn_rollback;
