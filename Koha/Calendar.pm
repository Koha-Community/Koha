package Koha::Calendar;
use strict;
use warnings;
use 5.010;

use DateTime;
use DateTime::Set;
use DateTime::Duration;
use C4::Context;
use Koha::Caches;
use Carp;

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
    my $self       = shift;
    my $branch     = $self->{branchcode};
    my $dbh        = C4::Context->dbh();
    my $weekly_closed_days_sth = $dbh->prepare(
'SELECT weekday FROM repeatable_holidays WHERE branchcode = ? AND weekday IS NOT NULL'
    );
    $weekly_closed_days_sth->execute( $branch );
    $self->{weekly_closed_days} = [ 0, 0, 0, 0, 0, 0, 0 ];
    while ( my $tuple = $weekly_closed_days_sth->fetchrow_hashref ) {
        $self->{weekly_closed_days}->[ $tuple->{weekday} ] = 1;
    }
    my $day_month_closed_days_sth = $dbh->prepare(
'SELECT day, month FROM repeatable_holidays WHERE branchcode = ? AND weekday IS NULL'
    );
    $day_month_closed_days_sth->execute( $branch );
    $self->{day_month_closed_days} = {};
    while ( my $tuple = $day_month_closed_days_sth->fetchrow_hashref ) {
        $self->{day_month_closed_days}->{ $tuple->{month} }->{ $tuple->{day} } =
          1;
    }

    $self->{days_mode}       ||= C4::Context->preference('useDaysMode');
    $self->{test}            = 0;
    return;
}

sub exception_holidays {
    my ( $self ) = @_;

    my $cache  = Koha::Caches->get_instance();
    my $cached = $cache->get_from_cache('exception_holidays');
    return $cached if $cached;

    my $dbh = C4::Context->dbh;
    my $branch = $self->{branchcode};
    my $exception_holidays_sth = $dbh->prepare(
'SELECT day, month, year FROM special_holidays WHERE branchcode = ? AND isexception = 1'
    );
    $exception_holidays_sth->execute( $branch );
    my $dates = [];
    while ( my ( $day, $month, $year ) = $exception_holidays_sth->fetchrow ) {
        push @{$dates},
          DateTime->new(
            day       => $day,
            month     => $month,
            year      => $year,
            time_zone => "floating",
          )->truncate( to => 'day' );
    }
    $self->{exception_holidays} =
      DateTime::Set->from_datetimes( dates => $dates );
    $cache->set_in_cache( 'exception_holidays', $self->{exception_holidays} );
    return $self->{exception_holidays};
}

sub single_holidays {
    my ( $self, $date ) = @_;
    my $branchcode = $self->{branchcode};
    my $cache           = Koha::Caches->get_instance();
    my $single_holidays = $cache->get_from_cache('single_holidays');

    # $single_holidays looks like:
    # {
    #   CPL =>  [
    #        [0] 20131122,
    #         ...
    #    ],
    #   ...
    # }

    unless ($single_holidays) {
        my $dbh = C4::Context->dbh;
        $single_holidays = {};

        # push holidays for each branch
        my $branches_sth =
          $dbh->prepare('SELECT distinct(branchcode) FROM special_holidays');
        $branches_sth->execute();
        while ( my $br = $branches_sth->fetchrow ) {
            my $single_holidays_sth = $dbh->prepare(
'SELECT day, month, year FROM special_holidays WHERE branchcode = ? AND isexception = 0'
            );
            $single_holidays_sth->execute($br);

            my @ymd_arr;
            while ( my ( $day, $month, $year ) =
                $single_holidays_sth->fetchrow )
            {
                my $dt = DateTime->new(
                    day       => $day,
                    month     => $month,
                    year      => $year,
                    time_zone => 'floating',
                )->truncate( to => 'day' );
                push @ymd_arr, $dt->ymd('');
            }
            $single_holidays->{$br} = \@ymd_arr;
        }    # br
        $cache->set_in_cache( 'single_holidays', $single_holidays,
            { expiry => 76800 } )    #24 hrs ;
    }
    my $holidays  = ( $single_holidays->{$branchcode} );
    for my $hols  (@$holidays ) {
            return 1 if ( $date == $hols )   #match ymds;
    }
    return 0;
}

sub addDate {
    my ( $self, $startdate, $add_duration, $unit ) = @_;

    # Default to days duration (legacy support I guess)
    if ( ref $add_duration ne 'DateTime::Duration' ) {
        $add_duration = DateTime::Duration->new( days => $add_duration );
    }

    $unit ||= 'days'; # default days ?
    my $dt;

    if ( $unit eq 'hours' ) {
        # Fixed for legacy support. Should be set as a branch parameter
        my $return_by_hour = 10;

        $dt = $self->addHours($startdate, $add_duration, $return_by_hour);
    } else {
        # days
        $dt = $self->addDays($startdate, $add_duration);
    }

    return $dt;
}

sub addHours {
    my ( $self, $startdate, $hours_duration, $return_by_hour ) = @_;
    my $base_date = $startdate->clone();

    $base_date->add_duration($hours_duration);

    # If we are using the calendar behave for now as if Datedue
    # was the chosen option (current intended behaviour)

    if ( $self->{days_mode} ne 'Days' &&
          $self->is_holiday($base_date) ) {

        if ( $hours_duration->is_negative() ) {
            $base_date = $self->prev_open_day($base_date);
        } else {
            $base_date = $self->next_open_day($base_date);
        }

        $base_date->set_hour($return_by_hour);

    }

    return $base_date;
}

sub addDays {
    my ( $self, $startdate, $days_duration ) = @_;
    my $base_date = $startdate->clone();

    $self->{days_mode} ||= q{};

    if ( $self->{days_mode} eq 'Calendar' ) {
        # use the calendar to skip all days the library is closed
        # when adding
        my $days = abs $days_duration->in_units('days');

        if ( $days_duration->is_negative() ) {
            while ($days) {
                $base_date = $self->prev_open_day($base_date);
                --$days;
            }
        } else {
            while ($days) {
                $base_date = $self->next_open_day($base_date);
                --$days;
            }
        }

    } else { # Days or Datedue
        # use straight days, then use calendar to push
        # the date to the next open day if Datedue
        $base_date->add_duration($days_duration);

        if ( $self->{days_mode} eq 'Datedue' ) {
            # Datedue, then use the calendar to push
            # the date to the next open day if holiday
            if ( $self->is_holiday($base_date) ) {

                if ( $days_duration->is_negative() ) {
                    $base_date = $self->prev_open_day($base_date);
                } else {
                    $base_date = $self->next_open_day($base_date);
                }
            }
        }
    }

    return $base_date;
}

sub is_holiday {
    my ( $self, $dt ) = @_;

    my $localdt = $dt->clone();
    my $day   = $localdt->day;
    my $month = $localdt->month;

    #Change timezone to "floating" before doing any calculations or comparisons
    $localdt->set_time_zone("floating");
    $localdt->truncate( to => 'day' );


    if ( $self->exception_holidays->contains($localdt) ) {
        # exceptions are not holidays
        return 0;
    }

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

    my $ymd   = $localdt->ymd('')  ;
    if ($self->single_holidays(  $ymd  ) == 1 ) {
        return 1;
    }

    # damn have to go to work after all
    return 0;
}

sub next_open_day {
    my ( $self, $dt ) = @_;
    my $base_date = $dt->clone();

    $base_date->add(days => 1);

    while ($self->is_holiday($base_date)) {
        $base_date->add(days => 1);
    }

    return $base_date;
}

sub prev_open_day {
    my ( $self, $dt ) = @_;
    my $base_date = $dt->clone();

    $base_date->add(days => -1);

    while ($self->is_holiday($base_date)) {
        $base_date->add(days => -1);
    }

    return $base_date;
}

sub days_forward {
    my $self     = shift;
    my $start_dt = shift;
    my $num_days = shift;

    return $start_dt unless $num_days > 0;

    my $base_dt = $start_dt->clone();

    while ($num_days--) {
        $base_dt = $self->next_open_day($base_dt);
    }

    return $base_dt;
}

sub days_between {
    my $self     = shift;
    my $start_dt = shift;
    my $end_dt   = shift;

    # Change time zone for date math and swap if needed
    $start_dt = $start_dt->clone->set_time_zone('floating');
    $end_dt = $end_dt->clone->set_time_zone('floating');
    if( $start_dt->compare($end_dt) > 0 ) {
        ( $start_dt, $end_dt ) = ( $end_dt, $start_dt );
    }

    # start and end should not be closed days
    my $days = $start_dt->delta_days($end_dt)->delta_days;
    while( $start_dt->compare($end_dt) < 1 ) {
        $days-- if $self->is_holiday($start_dt);
        $start_dt->add( days => 1 );
    }
    return DateTime::Duration->new( days => $days );
}

sub hours_between {
    my ($self, $start_date, $end_date) = @_;
    my $start_dt = $start_date->clone()->set_time_zone('floating');
    my $end_dt = $end_date->clone()->set_time_zone('floating');
    my $duration = $end_dt->delta_ms($start_dt);
    $start_dt->truncate( to => 'day' );
    $end_dt->truncate( to => 'day' );
    # NB this is a kludge in that it assumes all days are 24 hours
    # However for hourly loans the logic should be expanded to
    # take into account open/close times then it would be a duration
    # of library open hours
    my $skipped_days = 0;
    for (my $dt = $start_dt->clone();
        $dt <= $end_dt;
        $dt->add(days => 1)
    ) {
        if ($self->is_holiday($dt)) {
            ++$skipped_days;
        }
    }
    if ($skipped_days) {
        $duration->subtract_duration(DateTime::Duration->new( hours => 24 * $skipped_days));
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
  my $dt = DateTime->now();

  # are we open
  $open = $c->is_holiday($dt);
  # when will item be due if loan period = $dur (a DateTime::Duration object)
  $duedate = $c->addDate($dt,$dur,'days');


=head1 DESCRIPTION

  Implements those features of C4::Calendar needed for Staffs Rolling Loans

=head1 METHODS

=head2 new : Create a calendar object

my $calendar = Koha::Calendar->new( branchcode => 'MAIN' );

The option branchcode is required


=head2 addDate

    my $dt = $calendar->addDate($date, $dur, $unit)

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


=head2 addDays

    my $dt = $calendar->addDays($date, $dur)

C<$date> is a DateTime object representing the starting date of the interval.

C<$offset> is a DateTime::Duration to add to it

C<$unit> is a string value 'days' or 'hours' toflag granularity of duration

Currently unit is only used to invoke Staffs return Monday at 10 am rule this
parameter will be removed when issuingrules properly cope with that


=head2 single_holidays

my $rc = $self->single_holidays(  $ymd  );

Passed a $date in Ymd (yyyymmdd) format -  returns 1 if date is a single_holiday, or 0 if not.


=head2 is_holiday

$yesno = $calendar->is_holiday($dt);

passed a DateTime object returns 1 if it is a closed day
0 if not according to the calendar

=head2 days_between

$duration = $calendar->days_between($start_dt, $end_dt);

Passed two dates returns a DateTime::Duration object measuring the length between them
ignoring closed days. Always returns a positive number irrespective of the
relative order of the parameters

=head2 next_open_day

$datetime = $calendar->next_open_day($duedate_dt)

Passed a Datetime returns another Datetime representing the next open day. It is
intended for use to calculate the due date when useDaysMode syspref is set to either
'Datedue' or 'Calendar'.

=head2 prev_open_day

$datetime = $calendar->prev_open_day($duedate_dt)

Passed a Datetime returns another Datetime representing the previous open day. It is
intended for use to calculate the due date when useDaysMode syspref is set to either
'Datedue' or 'Calendar'.

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

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
