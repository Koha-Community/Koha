package Koha::Calendar;

use Modern::Perl;

use Carp qw( croak );
use DateTime;
use DateTime::Duration;
use C4::Context;
use Koha::Caches;
use Koha::Exceptions;
use Koha::Exceptions::Calendar;

# This limit avoids an infinite loop when searching for an open day in an
# always closed library
# The value is arbitrary, but it should be large enough to be able to
# consider there is no open days if we haven't found any with that many
# iterations, and small enough to allow the loop to end quickly
# See next_open_days and prev_open_days
use constant OPEN_DAYS_SEARCH_MAX_ITERATIONS => 5000;

sub new {
    my ( $classname, %options ) = @_;
    my $self = {};
    bless $self, $classname;
    for my $o_name ( keys %options ) {
        my $o = lc $o_name;
        $self->{$o} = $options{$o_name};
    }
    if ( !defined $self->{branchcode} ) {
        croak 'No branchcode argument passed to Koha::Calendar->new';
    }
    $self->_init();
    return $self;
}

sub _init {
    my $self   = shift;
    my $branch = $self->{branchcode};
    my $dbh    = C4::Context->dbh();
    my $weekly_closed_days_sth =
        $dbh->prepare('SELECT weekday FROM repeatable_holidays WHERE branchcode = ? AND weekday IS NOT NULL');
    $weekly_closed_days_sth->execute($branch);
    $self->{weekly_closed_days} = [ 0, 0, 0, 0, 0, 0, 0 ];
    while ( my $tuple = $weekly_closed_days_sth->fetchrow_hashref ) {
        $self->{weekly_closed_days}->[ $tuple->{weekday} ] = 1;
    }
    my $day_month_closed_days_sth =
        $dbh->prepare('SELECT day, month FROM repeatable_holidays WHERE branchcode = ? AND weekday IS NULL');
    $day_month_closed_days_sth->execute($branch);
    $self->{day_month_closed_days} = {};
    while ( my $tuple = $day_month_closed_days_sth->fetchrow_hashref ) {
        $self->{day_month_closed_days}->{ $tuple->{month} }->{ $tuple->{day} } =
            1;
    }

    $self->{test} = 0;
    return;
}

sub _holidays {
    my ($self) = @_;

    my $key      = $self->{branchcode} . "_holidays";
    my $cache    = Koha::Caches->get_instance();
    my $holidays = $cache->get_from_cache($key);

    # $holidays looks like:
    # {
    #    20131122 => 1, # single_holiday
    #    20131123 => 0, # exception_holiday
    #    ...
    # }

    # Populate the cache if necessary
    unless ($holidays) {
        my $dbh = C4::Context->dbh;
        $holidays = {};

        # Add holidays for each branch
        my $holidays_sth = $dbh->prepare(
            'SELECT day, month, year, MAX(isexception) FROM special_holidays WHERE branchcode = ? GROUP BY day, month, year'
        );
        $holidays_sth->execute( $self->{branchcode} );

        while ( my ( $day, $month, $year, $exception ) = $holidays_sth->fetchrow ) {
            my $datestring = sprintf( "%04d", $year ) . sprintf( "%02d", $month ) . sprintf( "%02d", $day );

            $holidays->{$datestring} = $exception ? 0 : 1;
        }
        $cache->set_in_cache( $key, $holidays, { expiry => 76800 } );
    }
    return $holidays // {};
}

sub addDuration {
    my ( $self, $startdate, $add_duration, $unit ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory option for Koha:Calendar->addDuration: days_mode")
        unless exists $self->{days_mode};

    # Default to days duration (legacy support I guess)
    if ( ref $add_duration ne 'DateTime::Duration' ) {
        $add_duration = DateTime::Duration->new( days => $add_duration );
    }

    $unit ||= 'days';    # default days ?
    my $dt;
    if ( $unit eq 'hours' ) {

        # Fixed for legacy support. Should be set as a branch parameter
        my $return_by_hour = 10;

        $dt = $self->addHours( $startdate, $add_duration, $return_by_hour );
    } else {

        # days
        $dt = $self->addDays( $startdate, $add_duration );
    }
    return $dt;
}

sub addHours {
    my ( $self, $startdate, $hours_duration, $return_by_hour ) = @_;
    my $base_date = $startdate->clone();

    $base_date->add_duration($hours_duration);

    # If we are using the calendar behave for now as if Datedue
    # was the chosen option (current intended behaviour)

    Koha::Exceptions::MissingParameter->throw("Missing mandatory option for Koha:Calendar->addHours: days_mode")
        unless exists $self->{days_mode};

    if (   $self->{days_mode} ne 'Days'
        && $self->is_holiday($base_date) )
    {

        if ( $hours_duration->is_negative() ) {
            $base_date = $self->prev_open_days( $base_date, 1 );
        } else {
            $base_date = $self->next_open_days( $base_date, 1 );
        }

        $base_date->set_hour($return_by_hour);

    }

    return $base_date;
}

sub addDays {
    my ( $self, $startdate, $days_duration ) = @_;
    my $base_date = $startdate->clone();

    Koha::Exceptions::MissingParameter->throw("Missing mandatory option for Koha:Calendar->addDays: days_mode")
        unless exists $self->{days_mode};

    if ( $self->{days_mode} eq 'Calendar' ) {

        # use the calendar to skip all days the library is closed
        # when adding
        my $days = abs $days_duration->in_units('days');

        if ( $days_duration->is_negative() ) {
            while ($days) {
                $base_date = $self->prev_open_days( $base_date, 1 );
                --$days;
            }
        } else {
            while ($days) {
                $base_date = $self->next_open_days( $base_date, 1 );
                --$days;
            }
        }

    } else {    # Days, Datedue or Dayweek
                # use straight days, then use calendar to push
                # the date to the next open day as appropriate
                # if Datedue or Dayweek
        $base_date->add_duration($days_duration);

        if (   $self->{days_mode} eq 'Datedue'
            || $self->{days_mode} eq 'Dayweek' )
        {
            # Datedue or Dayweek, then use the calendar to push
            # the date to the next open day if holiday
            if ( $self->is_holiday($base_date) ) {
                my $dow  = $base_date->day_of_week;
                my $days = $days_duration->in_units('days');

                # Is it a period based on weeks
                my $push_amt = $days % 7 == 0 ? $self->get_push_amt($base_date) : 1;
                if ( $days_duration->is_negative() ) {
                    $base_date = $self->prev_open_days( $base_date, $push_amt );
                } else {
                    $base_date = $self->next_open_days( $base_date, $push_amt );
                }
            }
        }
    }

    return $base_date;
}

sub get_push_amt {
    my ( $self, $base_date ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory option for Koha:Calendar->get_push_amt: days_mode")
        unless exists $self->{days_mode};

    my $dow = $base_date->day_of_week;

    # Representation fix
    # DateTime object dow (1-7) where Monday is 1
    # Arrays are 0-based where 0 = Sunday, not 7.
    if ( $dow == 7 ) {
        $dow = 0;
    }

    return (
        # We're using Dayweek useDaysMode option
        $self->{days_mode} eq 'Dayweek' &&

            # It's not a permanently closed day
            !$self->{weekly_closed_days}->[$dow]
    ) ? 7 : 1;
}

sub is_holiday {
    my ( $self, $dt ) = @_;

    my $localdt = $dt->clone();
    my $day     = $localdt->day;
    my $month   = $localdt->month;
    my $ymd     = $localdt->ymd('');

    #Change timezone to "floating" before doing any calculations or comparisons
    $localdt->set_time_zone("floating");
    $localdt->truncate( to => 'day' );

    return $self->_holidays->{$ymd} if defined( $self->_holidays->{$ymd} );

    my $dow = $localdt->day_of_week;

    # Representation fix
    # DateTime object dow (1-7) where Monday is 1
    # Arrays are 0-based where 0 = Sunday, not 7.
    if ( $dow == 7 ) {
        $dow = 0;
    }

    if ( $self->{weekly_closed_days}->[$dow] == 1 ) {
        return 1;
    }

    if ( exists $self->{day_month_closed_days}->{$month}->{$day} ) {
        return 1;
    }

    # damn have to go to work after all
    return 0;
}

sub next_open_days {
    my ( $self, $dt, $to_add ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory option for Koha:Calendar->next_open_days: days_mode")
        unless exists $self->{days_mode};

    my $base_date = $dt->clone();

    $base_date->add( days => $to_add );
    my $i = 0;
    while ( $self->is_holiday($base_date) && $i < OPEN_DAYS_SEARCH_MAX_ITERATIONS ) {
        my $add_next = $self->get_push_amt($base_date);
        $base_date->add( days => $add_next );
        ++$i;
    }

    if ( $self->is_holiday($base_date) ) {
        Koha::Exceptions::Calendar::NoOpenDays->throw(
            sprintf( 'Unable to find an open day for library %s', $self->{branchcode} ) );
    }

    return $base_date;
}

sub prev_open_days {
    my ( $self, $dt, $to_sub ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory option for Koha:Calendar->get_open_days: days_mode")
        unless exists $self->{days_mode};

    my $base_date = $dt->clone();

    # It feels logical to be passed a positive number, though we're
    # subtracting, so do the right thing
    $to_sub = $to_sub > 0 ? 0 - $to_sub : $to_sub;

    $base_date->add( days => $to_sub );

    my $i = 0;
    while ( $self->is_holiday($base_date) && $i < OPEN_DAYS_SEARCH_MAX_ITERATIONS ) {
        my $sub_next = $self->get_push_amt($base_date);

        # Ensure we're subtracting when we need to be
        $sub_next = $sub_next > 0 ? 0 - $sub_next : $sub_next;
        $base_date->add( days => $sub_next );
        ++$i;
    }

    if ( $self->is_holiday($base_date) ) {
        Koha::Exceptions::Calendar::NoOpenDays->throw(
            sprintf( 'Unable to find an open day for library %s', $self->{branchcode} ) );
    }

    return $base_date;
}

sub days_forward {
    my $self     = shift;
    my $start_dt = shift;
    my $num_days = shift;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory option for Koha:Calendar->days_forward: days_mode")
        unless exists $self->{days_mode};

    return $start_dt unless $num_days > 0;

    my $base_dt = $start_dt->clone();

    while ( $num_days-- ) {
        $base_dt = $self->next_open_days( $base_dt, 1 );
    }

    return $base_dt;
}

sub days_between {
    my $self     = shift;
    my $start_dt = shift;
    my $end_dt   = shift;

    # Change time zone for date math and swap if needed
    $start_dt = $start_dt->clone->set_time_zone('floating');
    $end_dt   = $end_dt->clone->set_time_zone('floating');
    if ( $start_dt->compare($end_dt) > 0 ) {
        ( $start_dt, $end_dt ) = ( $end_dt, $start_dt );
    }

    # start and end should not be closed days
    my $delta_days = $start_dt->delta_days($end_dt)->delta_days;
    while ( $start_dt->compare($end_dt) < 1 ) {
        $delta_days-- if $self->is_holiday($start_dt);
        $start_dt->add( days => 1 );
    }
    return DateTime::Duration->new( days => $delta_days );
}

sub hours_between {
    my ( $self, $start_date, $end_date ) = @_;
    my $start_dt = $start_date->clone()->set_time_zone('floating');
    my $end_dt   = $end_date->clone()->set_time_zone('floating');

    my $duration = $end_dt->delta_ms($start_dt);
    $start_dt->truncate( to => 'day' );
    $end_dt->truncate( to => 'day' );

    # NB this is a kludge in that it assumes all days are 24 hours
    # However for hourly loans the logic should be expanded to
    # take into account open/close times then it would be a duration
    # of library open hours
    my $skipped_days = 0;
    while ( $start_dt->compare($end_dt) < 1 ) {
        $skipped_days++ if $self->is_holiday($start_dt);
        $start_dt->add( days => 1 );
    }

    if ($skipped_days) {
        $duration->subtract_duration( DateTime::Duration->new( hours => 24 * $skipped_days ) );
    }

    return $duration;
}

sub set_daysmode {
    my ( $self, $mode ) = @_;

    # if not testing this is a no op
    if ( $self->{test} ) {
        $self->{days_mode} = $mode;
    }

    return;
}

sub clear_weekly_closed_days {
    my $self = shift;
    $self->{weekly_closed_days} = [ 0, 0, 0, 0, 0, 0, 0 ];    # Sunday only
    return;
}

1;
__END__

=head1 NAME

Koha::Calendar - Object containing a branches calendar

=head1 SYNOPSIS

  use Koha::Calendar

  my $c = Koha::Calendar->new( branchcode => 'MAIN' );
  my $dt = dt_from_string();

  # are we open
  $open = $c->is_holiday($dt);
  # when will item be due if loan period = $dur (a DateTime::Duration object)
  $duedate = $c->addDuration($dt,$dur,'days');


=head1 DESCRIPTION

  Implements those features of C4::Calendar needed for Staffs Rolling Loans

=head1 METHODS

=head2 new : Create a calendar object

my $calendar = Koha::Calendar->new( branchcode => 'MAIN' );

The option branchcode is required


=head2 addDuration

    my $dt = $calendar->addDuration($date, $dur, $unit)

C<$date> is a DateTime object representing the starting date of the interval.

C<$offset> is a DateTime::Duration to add to it

C<$unit> is a string value 'days' or 'hours' toflag granularity of duration

Currently unit is only used to invoke Staffs return Monday at 10 am rule this
parameter will be removed when issuingrules properly cope with that


=head2 addHours

    my $dt = $calendar->addHours($date, $dur, $return_by_hour )

C<$date> is a DateTime object representing the starting date of the interval.

C<$offset> is a DateTime::Duration to add to it

C<$return_by_hour> is an integer value representing the opening hour for the branch

=head2 get_push_amt

    my $amt = $calendar->get_push_amt($date)

C<$date> is a DateTime object representing a closed return date

Using the days_mode syspref value and the nature of the closed return
date, return how many days we should jump forward to find another return date

=head2 addDays

    my $dt = $calendar->addDays($date, $dur)

C<$date> is a DateTime object representing the starting date of the interval.

C<$offset> is a DateTime::Duration to add to it

C<$unit> is a string value 'days' or 'hours' toflag granularity of duration

Currently unit is only used to invoke Staffs return Monday at 10 am rule this
parameter will be removed when issuingrules properly cope with that

=head2 is_holiday

$yesno = $calendar->is_holiday($dt);

passed a DateTime object returns 1 if it is a closed day
0 if not according to the calendar

=head2 days_between

$duration = $calendar->days_between($start_dt, $end_dt);

Passed two dates returns a DateTime::Duration object measuring the length between them
ignoring closed days. Always returns a positive number irrespective of the
relative order of the parameters.

Note: This routine assumes neither the passed start_dt nor end_dt can be a closed day

=head2 hours_between

$duration = $calendar->hours_between($start_dt, $end_dt);

Passed two dates returns a DateTime::Duration object measuring the length between them
ignoring closed days. Always returns a positive number irrespective of the
relative order of the parameters.

Note: This routine assumes neither the passed start_dt nor end_dt can be a closed day

=head2 next_open_days

$datetime = $calendar->next_open_days($duedate_dt, $to_add)

Passed a Datetime and number of days,  returns another Datetime representing
the next open day after adding the passed number of days. It is intended for
use to calculate the due date when useDaysMode syspref is set to either
'Datedue', 'Calendar' or 'Dayweek'.

=head2 prev_open_days

$datetime = $calendar->prev_open_days($duedate_dt, $to_sub)

Passed a Datetime and a number of days, returns another Datetime
representing the previous open day after subtracting the number of passed
days. It is intended for use to calculate the due date when useDaysMode
syspref is set to either 'Datedue', 'Calendar' or 'Dayweek'.

=head2 days_forward

$datetime = $calendar->days_forward($start_dt, $to_add)

Passed a Datetime and number of days, returns another Datetime representing
the next open day after adding the passed number of days. It is intended for
use to calculate the due date when useDaysMode syspref is set to either
'Datedue', 'Calendar' or 'Dayweek'.

=head2 set_daysmode

For testing only allows the calling script to change days mode

=head2 clear_weekly_closed_days

In test mode changes the testing set of closed days to a new set with
no closed days. TODO passing an array of closed days to this would
allow testing of more configurations

=head2 add_holiday

Passed a datetime object this will add it to the calendar's list of
closed days. This is for testing so that we can alter the Calenfar object's
list of specified dates

=head1 DIAGNOSTICS

Will croak if not passed a branchcode in new

=head1 BUGS AND LIMITATIONS

This only contains a limited subset of the functionality in C4::Calendar
Only enough to support Staffs Rolling loans

=head1 AUTHOR

Colin Campbell colin.campbell@ptfs-europe.com

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2011 PTFS-Europe Ltd All rights reserved

Koha is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

Koha is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Koha; if not, see <http://www.gnu.org/licenses>.
