package C4::Calendar;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
require Exporter;
use vars qw($VERSION @EXPORT);

#use Date::Manip;
# use Date::Calc;

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::Calendar::Calendar - Koha module dealing with holidays.

=head1 SYNOPSIS

    use C4::Calendar::Calendar;

=head1 DESCRIPTION

This package is used to deal with holidays. Through this package, you can set all kind of holidays for the library.

=head1 FUNCTIONS

=over 2

=cut

@EXPORT = qw(&new 
             &change_branchcode 
             &get_week_days_holidays
             &get_day_month_holidays
             &get_exception_holidays 
             &get_single_holidays
             &insert_week_day_holiday
             &insert_day_month_holiday
             &insert_single_holiday
             &insert_exception_holiday
             &delete_holiday
             &isHoliday
             &addDate
             &daysBetween);

=item new

    $calendar = C4::Calendar::Calendar->new(branchcode => $branchcode);

C<$branchcode> Is the branch code wich you want to use calendar.

=cut

sub new {
    my $classname = shift @_;
    my %options = @_;

    my %hash;
    my $self = bless(\%hash, $classname);

    foreach my $optionName (keys %options) {
        $self->{lc($optionName)} = $options{$optionName};
    }

    $self->_init;

    return $self;
}

sub _init {
    my $self = shift @_;

    my $dbh = C4::Context->dbh();
    my $week_days_sql = $dbh->prepare("select weekday, title, description from repeatable_holidays where ('$self->{branchcode}' = branchcode) and (NOT(ISNULL(weekday)))");
    $week_days_sql->execute;
    my %week_days_holidays;
    while (my ($weekday, $title, $description) = $week_days_sql->fetchrow) {
        $week_days_holidays{$weekday}{title} = $title;
        $week_days_holidays{$weekday}{description} = $description;
    }
    $week_days_sql->finish;
    $self->{'week_days_holidays'} = \%week_days_holidays;

    my $day_month_sql = $dbh->prepare("select day, month, title, description from repeatable_holidays where ('$self->{branchcode}' = branchcode) and ISNULL(weekday)");
    $day_month_sql->execute;
    my %day_month_holidays;
    while (my ($day, $month, $title, $description) = $day_month_sql->fetchrow) {
        $day_month_holidays{"$month/$day"}{title} = $title;
        $day_month_holidays{"$month/$day"}{description} = $description;
    }
    $day_month_sql->finish;
    $self->{'day_month_holidays'} = \%day_month_holidays;

    my $exception_holidays_sql = $dbh->prepare("select day, month, year, title, description from special_holidays where ('$self->{branchcode}' = branchcode) and (isexception = 1)");
    $exception_holidays_sql->execute;
    my %exception_holidays;
    while (my ($day, $month, $year, $title, $description) = $exception_holidays_sql->fetchrow) {
        $exception_holidays{"$year/$month/$day"}{title} = $title;
        $exception_holidays{"$year/$month/$day"}{description} = $description;
    }
    $exception_holidays_sql->finish;
    $self->{'exception_holidays'} = \%exception_holidays;

    my $holidays_sql = $dbh->prepare("select day, month, year, title, description from special_holidays where ('$self->{branchcode}' = branchcode) and (isexception = 0)");
    $holidays_sql->execute;
    my %single_holidays;
    while (my ($day, $month, $year, $title, $description) = $holidays_sql->fetchrow) {
        $single_holidays{"$year/$month/$day"}{title} = $title;
        $single_holidays{"$year/$month/$day"}{description} = $description;
    }
    $holidays_sql->finish;
    $self->{'single_holidays'} = \%single_holidays;
}

=item change_branchcode

    $calendar->change_branchcode(branchcode => $branchcode)

Change the calendar branch code. This means to change the holidays structure.

C<$branchcode> Is the branch code wich you want to use calendar.

=cut

sub change_branchcode {
    my ($self, $branchcode) = @_;
    my %options = @_;

    foreach my $optionName (keys %options) {
        $self->{lc($optionName)} = $options{$optionName};
    }
    $self->_init;

    return $self;
}

=item get_week_days_holidays

    $week_days_holidays = $calendar->get_week_days_holidays();

Returns a hash reference to week days holidays.

=cut

sub get_week_days_holidays {
    my $self = shift @_;
    my $week_days_holidays = $self->{'week_days_holidays'};
    return $week_days_holidays;
}

=item get_day_month_holidays
    
    $day_month_holidays = $calendar->get_day_month_holidays();

Returns a hash reference to day month holidays.

=cut

sub get_day_month_holidays {
    my $self = shift @_;
    my $day_month_holidays = $self->{'day_month_holidays'};
    return $day_month_holidays;
}

=item get_exception_holidays
    
    $exception_holidays = $calendar->exception_holidays();

Returns a hash reference to exception holidays. This kind of days are those
which stands for a holiday, but you wanted to make an exception for this particular
date.

=cut

sub get_exception_holidays {
    my $self = shift @_;
    my $exception_holidays = $self->{'exception_holidays'};
    return $exception_holidays;
}

=item get_single_holidays
    
    $single_holidays = $calendar->get_single_holidays();

Returns a hash reference to single holidays. This kind of holidays are those which
happend just one time.

=cut

sub get_single_holidays {
    my $self = shift @_;
    my $single_holidays = $self->{'single_holidays'};
    return $single_holidays;
}

=item insert_week_day_holiday

    insert_week_day_holiday(weekday => $weekday,
                            title => $title,
                            description => $description);

Inserts a new week day for $self->{branchcode}.

C<$day> Is the week day to make holiday.

C<$title> Is the title to store for the holiday formed by $year/$month/$day.

C<$description> Is the description to store for the holiday formed by $year/$month/$day.

=cut

sub insert_week_day_holiday {
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $insertHoliday = $dbh->prepare("insert into repeatable_holidays (id,branchcode,weekday,day,month,title,description) values ( '',?,?,NULL,NULL,?,? )"); 
	$insertHoliday->execute( $self->{branchcode}, $options{weekday},$options{title}, $options{description});
    $insertHoliday->finish;

    $self->{'week_days_holidays'}->{$options{weekday}}{title} = $options{title};
    $self->{'week_days_holidays'}->{$options{weekday}}{description} = $options{description};
    return $self;
}

=item insert_day_month_holiday

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
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $insertHoliday = $dbh->prepare("insert into repeatable_holidays (id,branchcode,weekday,day,month,title,description) values ('', ?, NULL, ?, ?, ?,? )");
	$insertHoliday->execute( $self->{branchcode}, $options{day},$options{month},$options{title}, $options{description});
    $insertHoliday->finish;

    $self->{'day_month_holidays'}->{"$options{month}/$options{day}"}{title} = $options{title};
    $self->{'day_month_holidays'}->{"$options{month}/$options{day}"}{description} = $options{description};
    return $self;
}

=item insert_single_holiday

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
    my $self = shift @_;
    my %options = @_;
    
	my $dbh = C4::Context->dbh();
    my $isexception = 0;
    my $insertHoliday = $dbh->prepare("insert into special_holidays (id,branchcode,day,month,year,isexception,title,description) values ('', ?,?,?,?,?,?,?)");
	$insertHoliday->execute( $self->{branchcode}, $options{day},$options{month},$options{year}, $isexception, $options{title}, $options{description});
    $insertHoliday->finish;

    $self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"}{title} = $options{title};
    $self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"}{description} = $options{description};
    return $self;
}

=item insert_exception_holiday

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
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $isexception = 1;
    my $insertException = $dbh->prepare("insert into special_holidays (id,branchcode,day,month,year,isexception,title,description) values ('', ?,?,?,?,?,?,?)");
	$insertException->execute( $self->{branchcode}, $options{day},$options{month},$options{year}, $isexception, $options{title}, $options{description});
    $insertException->finish;

    $self->{'exceptions_holidays'}->{"$options{year}/$options{month}/$options{day}"}{title} = $options{title};
    $self->{'exceptions_holidays'}->{"$options{year}/$options{month}/$options{day}"}{description} = $options{description};
    return $self;
}

=item delete_holiday

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
    my $self = shift @_;
    my %options = @_;

    # Verify what kind of holiday that day is. For example, if it is
    # a repeatable holiday, this should check if there are some exception
	# for that holiday rule. Otherwise, if it is a regular holiday, it´s 
    # ok just deleting it.

    my $dbh = C4::Context->dbh();
    my $isSingleHoliday = $dbh->prepare("select id from special_holidays where (branchcode = '$self->{branchcode}') and (day = $options{day}) and (month = $options{month}) and (year = $options{year})");
    $isSingleHoliday->execute;
    if ($isSingleHoliday->rows) {
        my $id = $isSingleHoliday->fetchrow;
        $isSingleHoliday->finish; # Close the last query

        my $deleteHoliday = $dbh->prepare("delete from special_holidays where (id = $id)");
        $deleteHoliday->execute;
        $deleteHoliday->finish; # Close the last query
        delete($self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"});
    } else {
        $isSingleHoliday->finish; # Close the last query

        my $isWeekdayHoliday = $dbh->prepare("select id from repeatable_holidays where (branchcode = '$self->{branchcode}') and (weekday = $options{weekday})");
        $isWeekdayHoliday->execute;
        if ($isWeekdayHoliday->rows) {
            my $id = $isWeekdayHoliday->fetchrow;
            $isWeekdayHoliday->finish; # Close the last query

            my $updateExceptions = $dbh->prepare("update special_holidays set isexception = 0 where (WEEKDAY(CONCAT(special_holidays.year,'-',special_holidays.month,'-',special_holidays.day)) = $options{weekday}) and (branchcode = '$self->{branchcode}')");
            $updateExceptions->execute;
            $updateExceptions->finish; # Close the last query

            my $deleteHoliday = $dbh->prepare("delete from repeatable_holidays where (id = $id)");
            $deleteHoliday->execute;
            $deleteHoliday->finish;
            delete($self->{'week_days_holidays'}->{$options{weekday}});
        } else {
            $isWeekdayHoliday->finish; # Close the last query

            my $isDayMonthHoliday = $dbh->prepare("select id from repeatable_holidays where (branchcode = '$self->{branchcode}') and (day = '$options{day}') and (month = '$options{month}')");
            $isDayMonthHoliday->execute;
            if ($isDayMonthHoliday->rows) {
                my $id = $isDayMonthHoliday->fetchrow;
                $isDayMonthHoliday->finish;
                my $updateExceptions = $dbh->prepare("update special_holidays set isexception = 0 where (special_holidays.branchcode = '$self->{branchcode}') and (special_holidays.day = '$options{day}') and (special_holidays.month = '$options{month}')");
                $updateExceptions->execute;
                $updateExceptions->finish; # Close the last query

                my $deleteHoliday = $dbh->prepare("delete from repeatable_holidays where (id = '$id')");
                $deleteHoliday->execute;
                $deleteHoliday->finish; # Close the last query
                $isDayMonthHoliday->finish; # Close the last query
                delete($self->{'day_month_holidays'}->{"$options{month}/$options{day}"});
            }
        }
    }
    return $self;
}

=item isHoliday
    
    $isHoliday = isHoliday($day, $month $year);


C<$day> Is the day to check whether if is a holiday or not.

C<$month> Is the month to check whether if is a holiday or not.

C<$year> Is the year to check whether if is a holiday or not.

=cut

sub isHoliday {
    my ($self, $day, $month, $year) = @_;
    my $weekday = &Date::Calc::Day_of_Week($year, $month, $day) % 7; 
    my $weekDays = $self->get_week_days_holidays();
    my $dayMonths = $self->get_day_month_holidays();
    my $exceptions = $self->get_exception_holidays();
    my $singles = $self->get_single_holidays();
    if (defined($exceptions->{"$year/$month/$day"})) {
        return 0;
    } else {
        if ((exists($weekDays->{$weekday})) ||
            (exists($dayMonths->{"$month/$day"})) ||
            (exists($singles->{"$year/$month/$day"}))) {
		 	return 1;
        } else {
            return 0;
        }
    }

}

=item addDate

    my ($day, $month, $year) = $calendar->addDate($date, $offset)

C<$date> is a C4::Dates object representing the starting date of the interval.

C<$offset> Is the number of days that this function has to count from $date.

=cut

sub addDate {
    my ($self, $startdate, $offset) = @_;
    my ($year,$month,$day) = split("-",$startdate->output('iso'));
	if ($offset < 0) { # In case $offset is negative
        $offset = $offset*(-1);
    }
	my $daysMode = C4::Context->preference('useDaysMode');
    if ($daysMode eq 'Datedue') {
        ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, $offset );
        while ($self->isHoliday($day, $month, $year)) {
                ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, 1);
        }
    } elsif($daysMode eq 'Calendar') {
        while ($offset > 0) {
                ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, 1);
            if (!($self->isHoliday($day, $month, $year))) {
                $offset = $offset - 1;
			}
        }
	} else { ## ($daysMode eq 'Days') 
        ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, $offset );
    }
    return(C4::Dates->new( sprintf("%04d-%02d-%02d",$year,$month,$day),'iso'));
}

=item daysBetween

    my $daysBetween = $calendar->daysBetween($startdate, $enddate )

C<$startdate>  and C<$enddate> are C4::Dates objects that define the interval.

Returns the number of non-holiday days in the interval.
useDaysMode syspref has no effect here.
=cut

sub daysBetween {
   # my ($self, $dayFrom, $monthFrom, $yearFrom, $dayTo, $monthTo, $yearTo) = @_;
    my ( $self, $startdate, $enddate ) = @_ ; 
	my ($yearFrom,$monthFrom,$dayFrom) = split("-",$startdate->output('iso'));
	my ($yearTo,$monthTo,$dayTo) = split("-",$enddate->output('iso'));
	if (($yearFrom >= $yearTo) && ($monthFrom >= $monthTo) && ($dayFrom >= $dayTo)) {
		return 0;
		# we don't go backwards  ( FIXME - handle this error better )
	}
    my $count = 0;
    my $continue = 1;
    while ($continue) {
        if (($yearFrom != $yearTo) || ($monthFrom != $monthTo) || ($dayFrom != $dayTo)) {
            if (!($self->isHoliday($dayFrom, $monthFrom, $yearFrom))) {
                $count++;
            }
            ($yearFrom, $monthFrom, $dayFrom) = &Date::Calc::Add_Delta_Days($yearFrom, $monthFrom, $dayFrom, 1);
        } else {
            $continue = 0;
        }
    }
    return($count);
}

1;

__END__

=back

=head1 AUTHOR

Koha Physics Library UNLP <matias_veleda@hotmail.com>

=cut
