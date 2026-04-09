package C4::Calendar;

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

use strict;
use warnings;
use vars qw(@EXPORT);

use Carp       qw( croak );
use Date::Calc qw( Today );
use Koha::Calendar;

use C4::Context;
use Koha::Caches;

use constant ISO_DATE_FORMAT => "%04d-%02d-%02d";

=head1 NAME

C4::Calendar::Calendar - Koha module dealing with holidays.

=head1 SYNOPSIS

    use C4::Calendar::Calendar;

=head1 DESCRIPTION

This package is used to deal with holidays. Through this package, you can set 
all kind of holidays for the library.

=head1 FUNCTIONS

=head2 new

  $calendar = C4::Calendar->new(branchcode => $branchcode);

Each library branch has its own Calendar.  
C<$branchcode> specifies which Calendar you want.

=cut

sub new {
    my $classname = shift @_;
    my %options   = @_;
    my $self      = bless( {}, $classname );
    foreach my $optionName ( keys %options ) {
        $self->{ lc($optionName) } = $options{$optionName};
    }
    defined( $self->{branchcode} )
        or croak "No branchcode argument to new.  Should be C4::Calendar->new(branchcode => \$branchcode)";
    $self->_init( $self->{branchcode} );
    return $self;
}

=head2 _init

Loads calendar data from the database for the given branch.

=cut

sub _init {
    my $self   = shift @_;
    my $branch = shift;
    defined($branch) or die "No branchcode sent to _init";    # must test for defined here and above to allow ""
    my $dbh = C4::Context->dbh();

    my $weekly_sth = $dbh->prepare('SELECT * FROM library_weekly_closures WHERE library_id = ?');
    $weekly_sth->execute($branch);
    my %week_days_holidays;
    while ( my $row = $weekly_sth->fetchrow_hashref ) {
        my $key = $row->{weekday};
        $week_days_holidays{$key}{title}       = $row->{title};
        $week_days_holidays{$key}{description} = $row->{description};
    }
    $self->{'week_days_holidays'} = \%week_days_holidays;

    my $repeating_sth = $dbh->prepare('SELECT * FROM library_repeating_closures WHERE library_id = ?');
    $repeating_sth->execute($branch);
    my %day_month_holidays;
    while ( my $row = $repeating_sth->fetchrow_hashref ) {
        my $key = $row->{month} . "/" . $row->{day};
        $day_month_holidays{$key}{title}       = $row->{title};
        $day_month_holidays{$key}{description} = $row->{description};
        $day_month_holidays{$key}{day}         = sprintf( "%02d", $row->{day} );
        $day_month_holidays{$key}{month}       = sprintf( "%02d", $row->{month} );
    }
    $self->{'day_month_holidays'} = \%day_month_holidays;

    my $exceptions_sth =
        $dbh->prepare('SELECT date, title, description FROM library_closure_exceptions WHERE library_id = ?');
    $exceptions_sth->execute($branch);
    my %exception_holidays;
    while ( my $row = $exceptions_sth->fetchrow_hashref ) {
        my ( $year, $month, $day ) = split( /-/, $row->{date} );
        $exception_holidays{"$year/$month/$day"}{title}       = $row->{title};
        $exception_holidays{"$year/$month/$day"}{description} = $row->{description};
        $exception_holidays{"$year/$month/$day"}{date}        = $row->{date};
    }
    $self->{'exception_holidays'} = \%exception_holidays;

    my $single_sth = $dbh->prepare('SELECT date, title, description FROM library_single_closures WHERE library_id = ?');
    $single_sth->execute($branch);
    my %single_holidays;
    while ( my $row = $single_sth->fetchrow_hashref ) {
        my ( $year, $month, $day ) = split( /-/, $row->{date} );
        $single_holidays{"$year/$month/$day"}{title}       = $row->{title};
        $single_holidays{"$year/$month/$day"}{description} = $row->{description};
        $single_holidays{"$year/$month/$day"}{date}        = $row->{date};
    }
    $self->{'single_holidays'} = \%single_holidays;
    return $self;
}

=head2 get_week_days_holidays

   $week_days_holidays = $calendar->get_week_days_holidays();

Returns a hash reference to week days holidays.

=cut

sub get_week_days_holidays {
    my $self               = shift @_;
    my $week_days_holidays = $self->{'week_days_holidays'};
    return $week_days_holidays;
}

=head2 get_day_month_holidays

   $day_month_holidays = $calendar->get_day_month_holidays();

Returns a hash reference to day month holidays.

=cut

sub get_day_month_holidays {
    my $self               = shift @_;
    my $day_month_holidays = $self->{'day_month_holidays'};
    return $day_month_holidays;
}

=head2 get_exception_holidays

    $exception_holidays = $calendar->exception_holidays();

Returns a hash reference to exception holidays. This kind of days are those
which stands for a holiday, but you wanted to make an exception for this particular
date.

=cut

sub get_exception_holidays {
    my $self               = shift @_;
    my $exception_holidays = $self->{'exception_holidays'};
    return $exception_holidays;
}

=head2 get_single_holidays

    $single_holidays = $calendar->get_single_holidays();

Returns a hash reference to single holidays. This kind of holidays are those which
happened just one time.

=cut

sub get_single_holidays {
    my $self            = shift @_;
    my $single_holidays = $self->{'single_holidays'};
    return $single_holidays;
}

=head2 insert_week_day_holiday

    insert_week_day_holiday(weekday => $weekday,
                            title => $title,
                            description => $description);

Inserts a new week day for $self->{branchcode}.

C<$day> Is the week day to make holiday.

C<$title> Is the title to store for the holiday formed by $year/$month/$day.

C<$description> Is the description to store for the holiday formed by $year/$month/$day.

=cut

sub insert_week_day_holiday {
    my $self    = shift @_;
    my %options = @_;
    Koha::Calendar->new( branchcode => $self->{branchcode} )->add_weekly_closure(
        {
            weekday => $options{weekday}, title => $options{title}, description => $options{description},
        }
    );
    $self->{'week_days_holidays'}->{ $options{weekday} }{title}       = $options{title};
    $self->{'week_days_holidays'}->{ $options{weekday} }{description} = $options{description};
    return $self;
}

=head2 insert_day_month_holiday

    insert_day_month_holiday(day => $day,
                             month => $month,
                             title => $title,
                             description => $description);

Inserts a new day month holiday for $self->{branchcode}.

C<$day> Is the day month to make the date to insert.

C<$month> Is month to make the date to insert.

C<$title> Is the title to store for the holiday formed by $year/$month/$day.

C<$description> Is the description to store for the holiday formed by $year/$month/$day.

=cut

sub insert_day_month_holiday {
    my $self    = shift @_;
    my %options = @_;
    Koha::Calendar->new( branchcode => $self->{branchcode} )->add_repeating_closure(
        {
            day         => $options{day}, month => $options{month}, title => $options{title},
            description => $options{description},
        }
    );
    $self->{'day_month_holidays'}->{"$options{month}/$options{day}"}{title}       = $options{title};
    $self->{'day_month_holidays'}->{"$options{month}/$options{day}"}{description} = $options{description};
    return $self;
}

=head2 insert_single_holiday

    insert_single_holiday(day => $day,
                          month => $month,
                          year => $year,
                          title => $title,
                          description => $description);

Inserts a new single holiday for $self->{branchcode}.

C<$day> Is the day month to make the date to insert.

C<$month> Is month to make the date to insert.

C<$year> Is year to make the date to insert.

C<$title> Is the title to store for the holiday formed by $year/$month/$day.

C<$description> Is the description to store for the holiday formed by $year/$month/$day.

=cut

sub insert_single_holiday {
    my $self    = shift @_;
    my %options = @_;
    my $date    = $options{date};
    unless ($date) {
        $date = sprintf( ISO_DATE_FORMAT, $options{year}, $options{month}, $options{day} );
    }
    Koha::Calendar->new( branchcode => $self->{branchcode} )->add_single_closure(
        {
            date => $date, title => $options{title}, description => $options{description},
        }
    );
    return $self;
}

=head2 insert_exception_holiday

    insert_exception_holiday(day => $day,
                             month => $month,
                             year => $year,
                             title => $title,
                             description => $description);

Inserts a new exception holiday for $self->{branchcode}.

C<$day> Is the day month to make the date to insert.

C<$month> Is month to make the date to insert.

C<$year> Is year to make the date to insert.

C<$title> Is the title to store for the holiday formed by $year/$month/$day.

C<$description> Is the description to store for the holiday formed by $year/$month/$day.

=cut

sub insert_exception_holiday {
    my $self    = shift @_;
    my %options = @_;
    my $date    = $options{date};
    unless ($date) {
        $date = sprintf( ISO_DATE_FORMAT, $options{year}, $options{month}, $options{day} );
    }
    Koha::Calendar->new( branchcode => $self->{branchcode} )->add_exception(
        {
            date => $date, title => $options{title}, description => $options{description},
        }
    );
    return $self;
}

=head2 ModWeekdayholiday

    ModWeekdayholiday(weekday =>$weekday,
                      title => $title,
                      description => $description)

Modifies the title and description of a weekday for $self->{branchcode}.

C<$weekday> Is the title to update for the holiday.

C<$description> Is the description to update for the holiday.

=cut

sub ModWeekdayholiday {
    my $self    = shift @_;
    my %options = @_;
    my $closure =
        Koha::Calendar::WeeklyClosures->search( { library_id => $self->{branchcode}, weekday => $options{weekday} } )
        ->next;
    $closure->title( $options{title} )->description( $options{description} )->store if $closure;
    return $self;
}

=head2 ModDaymonthholiday

    ModDaymonthholiday(day => $day,
                       month => $month,
                       title => $title,
                       description => $description);

Modifies the title and description for a day/month holiday for $self->{branchcode}.

C<$day> The day of the month for the update.

C<$month> The month to be used for the update.

C<$title> The title to be updated for the holiday.

C<$description> The description to be update for the holiday.

=cut

sub ModDaymonthholiday {
    my $self    = shift @_;
    my %options = @_;
    my $closure = Koha::Calendar::RepeatingClosures->search(
        { library_id => $self->{branchcode}, day => $options{day}, month => $options{month} } )->next;
    $closure->title( $options{title} )->description( $options{description} )->store if $closure;
    return $self;
}

=head2 ModSingleholiday

    ModSingleholiday(day => $day,
                     month => $month,
                     year => $year,
                     title => $title,
                     description => $description);

Modifies the title and description for a single holiday for $self->{branchcode}.

C<$day> Is the day of the month to make the update.

C<$month> Is the month to make the update.

C<$year> Is the year to make the update.

C<$title> Is the title to update for the holiday formed by $year/$month/$day.

C<$description> Is the description to update for the holiday formed by $year/$month/$day.

=cut

sub ModSingleholiday {
    my $self    = shift @_;
    my %options = @_;
    my $date    = $options{date} || sprintf( ISO_DATE_FORMAT, $options{year}, $options{month}, $options{day} );
    my $closure = Koha::Calendar::SingleClosures->search( { library_id => $self->{branchcode}, date => $date } )->next;
    if ($closure) {
        $closure->title( $options{title} )->description( $options{description} )->store;
    }
    return $self;
}

=head2 ModExceptionholiday

    ModExceptionholiday(day => $day,
                        month => $month,
                        year => $year,
                        title => $title,
                        description => $description);

Modifies the title and description for an exception holiday for $self->{branchcode}.

C<$day> Is the day of the month for the holiday.

C<$month> Is the month for the holiday.

C<$year> Is the year for the holiday.

C<$title> Is the title to be modified for the holiday formed by $year/$month/$day.

C<$description> Is the description to be modified for the holiday formed by $year/$month/$day.

=cut

sub ModExceptionholiday {
    my $self      = shift @_;
    my %options   = @_;
    my $date      = $options{date} || sprintf( ISO_DATE_FORMAT, $options{year}, $options{month}, $options{day} );
    my $exception = Koha::Calendar::Exceptions->search( { library_id => $self->{branchcode}, date => $date } )->next;
    if ($exception) {
        $exception->title( $options{title} )->description( $options{description} )->store;
    }
    return $self;
}

=head2 delete_holiday

    delete_holiday(weekday => $weekday
                   day => $day,
                   month => $month,
                   year => $year);

Delete a holiday for $self->{branchcode}.

C<$weekday> Is the week day to delete.

C<$day> Is the day month to make the date to delete.

C<$month> Is month to make the date to delete.

C<$year> Is year to make the date to delete.

=cut

sub delete_holiday {
    my $self    = shift @_;
    my %options = @_;
    my $cal     = Koha::Calendar->new( branchcode => $self->{branchcode} );

    if ( $options{day} && $options{month} && $options{year} ) {
        my $date = sprintf( ISO_DATE_FORMAT, $options{year}, $options{month}, $options{day} );

        # Try single closure first
        if ( Koha::Calendar::SingleClosures->search( { library_id => $self->{branchcode}, date => $date } )->count ) {
            $cal->delete_single_closure( { date => $date } );
        }

        # Also remove any exception for this date
        Koha::Calendar::Exceptions->search( { library_id => $self->{branchcode}, date => $date } )->delete;
    }

    if ( defined $options{weekday}
        && Koha::Calendar::WeeklyClosures->search( { library_id => $self->{branchcode}, weekday => $options{weekday} } )
        ->count )
    {
        $cal->delete_weekly_closure( { weekday => $options{weekday} } );
    } elsif (
        $options{day}
        && $options{month}
        && Koha::Calendar::RepeatingClosures->search(
            { library_id => $self->{branchcode}, day => $options{day}, month => $options{month} }
        )->count
        )
    {
        $cal->delete_repeating_closure( { day => $options{day}, month => $options{month} } );
    }

    return $self;
}

=head2 delete_holiday_range

    delete_holiday_range(day => $day,
                   month => $month,
                   year => $year);

Delete a holiday range of dates for $self->{branchcode}.

C<$day> Is the day month to make the date to delete.

C<$month> Is month to make the date to delete.

C<$year> Is year to make the date to delete.

=cut

sub delete_holiday_range {
    my $self    = shift;
    my %options = @_;
    my $date    = $options{date} || sprintf( ISO_DATE_FORMAT, $options{year}, $options{month}, $options{day} );
    Koha::Calendar->new( branchcode => $self->{branchcode} )->delete_single_closure( { date => $date } );
}

=head2 delete_holiday_range_repeatable

    delete_holiday_range_repeatable(day => $day,
                   month => $month);

Delete a holiday for $self->{branchcode}.

C<$day> Is the day month to make the date to delete.

C<$month> Is month to make the date to delete.

=cut

sub delete_holiday_range_repeatable {
    my $self    = shift;
    my %options = @_;
    Koha::Calendar->new( branchcode => $self->{branchcode} )
        ->delete_repeating_closure( { day => $options{day}, month => $options{month} } );
}

=head2 delete_exception_holiday_range

    delete_exception_holiday_range(weekday => $weekday
                   day => $day,
                   month => $month,
                   year => $year);

Delete a holiday for $self->{branchcode}.

C<$day> Is the day month to make the date to delete.

C<$month> Is month to make the date to delete.

C<$year> Is year to make the date to delete.

=cut

sub delete_exception_holiday_range {
    my $self    = shift;
    my %options = @_;
    my $date    = $options{date} || sprintf( ISO_DATE_FORMAT, $options{year}, $options{month}, $options{day} );
    Koha::Calendar->new( branchcode => $self->{branchcode} )->delete_exception( { date => $date } );
}

=head2 isHoliday

    $isHoliday = isHoliday($day, $month $year);

C<$day> Is the day to check whether if is a holiday or not.

C<$month> Is the month to check whether if is a holiday or not.

C<$year> Is the year to check whether if is a holiday or not.

=cut

sub isHoliday {
    my ( $self, $day, $month, $year ) = @_;

    # FIXME - date strings are stored in non-padded metric format. should change to iso.
    $month = $month + 0;
    $year  = $year + 0;
    $day   = $day + 0;
    my $weekday    = &Date::Calc::Day_of_Week( $year, $month, $day ) % 7;
    my $weekDays   = $self->get_week_days_holidays();
    my $dayMonths  = $self->get_day_month_holidays();
    my $exceptions = $self->get_exception_holidays();
    my $singles    = $self->get_single_holidays();

    if ( defined( $exceptions->{"$year/$month/$day"} ) ) {
        return 0;
    } else {
        if (   ( exists( $weekDays->{$weekday} ) )
            || ( exists( $dayMonths->{"$month/$day"} ) )
            || ( exists( $singles->{"$year/$month/$day"} ) ) )
        {
            return 1;
        } else {
            return 0;
        }
    }

}

=head2 copy_to_branch

    $calendar->copy_to_branch($target_branch)

=cut

sub copy_to_branch {
    my ( $self, $target_branch ) = @_;
    return Koha::Calendar->new( branchcode => $self->{branchcode} )->copy_to($target_branch);
}

1;

__END__

=head1 AUTHOR

Koha Physics Library UNLP <matias_veleda@hotmail.com>

=cut

