package Koha::Calendar;
use strict;
use warnings;
use 5.010;

use DateTime;
use DateTime::Set;
use C4::Context;
use Carp;
use Readonly;

sub new {
    my ( $classname, %options ) = @_;
    my $self = {};
    for my $o_name ( keys %options ) {
        my $o = lc $o_name;
        $self->{$o} = $options{$o_name};
    }
    if ( !defined $self->{branchcode} ) {
        croak 'No branchcode argument passed to Koha::Calendar->new';
    }
    bless $self, $classname;
    $self->_init();
    return $self;
}

sub _init {
    my $self       = shift;
    my $branch     = $self->{branchcode};
    my $dbh        = C4::Context->dbh();
    my $repeat_sth = $dbh->prepare(
'SELECT * from repeatable_holidays WHERE branchcode = ? AND ISNULL(weekday) = ?'
    );
    $repeat_sth->execute( $branch, 0 );
    $self->{weekly_closed_days} = [];
    Readonly::Scalar my $sunday => 7;
    while ( my $tuple = $repeat_sth->fetchrow_hashref ) {
        my $day = $tuple->{weekday} == 0 ? $sunday : $tuple->{weekday};
        push @{ $self->{weekly_closed_days} }, $day;
    }
    $repeat_sth->execute( $branch, 1 );
    $self->{day_month_closed_days} = [];
    while ( my $tuple = $repeat_sth->fetchrow_hashref ) {
        push @{ $self->{day_month_closed_days} },
          { day => $tuple->{day}, month => $tuple->{month}, };
    }
    my $special = $dbh->prepare(
'SELECT day, month, year, title, description FROM special_holidays WHERE ( branchcode = ? ) AND (isexception = ?)'
    );
    $special->execute( $branch, 1 );
    my $dates = [];
    while ( my ( $day, $month, $year, $title, $description ) =
        $special->fetchrow ) {
        push @{$dates},
          DateTime->new(
            day       => $day,
            month     => $month,
            year      => $year,
            time_zone => C4::Context->tz()
          )->truncate( to => 'day' );
    }
    $self->{exception_holidays} =
      DateTime::Set->from_datetimes( dates => $dates );
    $special->execute( $branch, 1 );
    $dates = [];
    while ( my ( $day, $month, $year, $title, $description ) =
        $special->fetchrow ) {
        push @{$dates},
          DateTime->new(
            day       => $day,
            month     => $month,
            year      => $year,
            time_zone => C4::Context->tz()
          )->truncate( to => 'day' );
    }
    $self->{single_holidays} = DateTime::Set->from_datetimes( dates => $dates );
    return;
}

sub addDate {
    my ( $self, $base_date, $add_duration, $unit ) = @_;
    my $days_mode = C4::Context->preference('useDaysMode');
    Readonly::Scalar my $return_by_hour => 10;
    my $day_dur = DateTime::Duration->new( days => 1);
    if ($add_duration->is_negative()) {
        $day_dur->inverse();
    }
    if ( $days_mode eq 'Datedue' ) {

        my $dt = $base_date + $add_duration;
        while ( $self->is_holiday($dt) ) {

            # TODOP if hours set to 10 am
            $dt->add_duration( $day_dur );
            if ( $unit eq 'hours' ) {
                $dt->set_hour($return_by_hour);    # Staffs specific
            }
        }
        return $dt;
    } elsif ( $days_mode eq 'Calendar' ) {
        if ($unit eq 'hours' ) {
            $base_date->add_duration($add_duration);
            while ($self->is_holiday($base_date)) {
            $base_date->add_duration( $day_dur );

            }

        }
        else {
        my $days = $add_duration->in_units('days');
        while ($days) {
            $base_date->add_duration( $day_dur );
            if ( $self->is_holiday($base_date) ) {
                next;
            } else {
                --$days;
            }
        }
    }
        if ( $unit eq 'hours' ) {
            my $dt = $base_date->clone()->subtract( days => 1 );
            if ( $self->is_holiday($dt) ) {
                $base_date->set_hour($return_by_hour);    # Staffs specific
            }
        }
        return $base_date;
    } else {    # Days
        return $base_date + $add_duration;
    }
}

sub is_holiday {
    my ( $self, $dt ) = @_;
    my $dow = $dt->day_of_week;
    my @matches = grep { $_ == $dow } @{ $self->{weekly_closed_days} };
    if (@matches) {
        return 1;
    }
    $dt->truncate(to => 'days');
    my $day   = $dt->day;
    my $month = $dt->month;
    for my $dm ( @{ $self->{day_month_closed_days} } ) {
        if ( $month == $dm->{month} && $day == $dm->{day} ) {
            return 1;
        }
    }
    if ( $self->{exception_holidays}->contains($dt) ) {
        return 1;
    }
    if ( $self->{single_holidays}->contains($dt) ) {
        return 1;
    }

    # damn have to go to work after all
    return 0;
}

1;
__END__

=head1 NAME

Koha::Calendar - Object containing a branches calendar

=head1 VERSION

This documentation refers to Koha::Calendar version 0.0.1

=head1 SYNOPSIS

  use Koha::Calendat

  my $c = Koha::Calender->new( branchcode => 'MAIN' );
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


=head2 is_holiday

$yesno = $calendar->is_holiday($dt);

passed at DateTime object returns 1 if it is a closed day
0 if not according to the calendar

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
