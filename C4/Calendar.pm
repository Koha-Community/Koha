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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use vars qw($VERSION @EXPORT);

use Carp;
use Date::Calc qw( Date_to_Days Today);

use C4::Context;

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
    my %options = @_;
    my $self = bless({}, $classname);
    foreach my $optionName (keys %options) {
        $self->{lc($optionName)} = $options{$optionName};
    }
    defined($self->{branchcode}) or croak "No branchcode argument to new.  Should be C4::Calendar->new(branchcode => \$branchcode)";
    $self->_init($self->{branchcode});
    return $self;
}

sub _init {
    my $self = shift @_;
    my $branch = shift;
    defined($branch) or die "No branchcode sent to _init";  # must test for defined here and above to allow ""
    my $dbh = C4::Context->dbh();
    my $repeatable = $dbh->prepare( 'SELECT *
                                       FROM repeatable_holidays
                                      WHERE ( branchcode = ? )
                                        AND (ISNULL(weekday) = ?)' );
    $repeatable->execute($branch,0);
    my %week_days_holidays;
    while (my $row = $repeatable->fetchrow_hashref) {
        my $key = $row->{weekday};
        $week_days_holidays{$key}{title}       = $row->{title};
        $week_days_holidays{$key}{description} = $row->{description};
    }
    $self->{'week_days_holidays'} = \%week_days_holidays;

    $repeatable->execute($branch,1);
    my %day_month_holidays;
    while (my $row = $repeatable->fetchrow_hashref) {
        my $key = $row->{month} . "/" . $row->{day};
        $day_month_holidays{$key}{title}       = $row->{title};
        $day_month_holidays{$key}{description} = $row->{description};
        $day_month_holidays{$key}{day} = sprintf("%02d", $row->{day});
        $day_month_holidays{$key}{month} = sprintf("%02d", $row->{month});
    }
    $self->{'day_month_holidays'} = \%day_month_holidays;

    my $special = $dbh->prepare( 'SELECT day, month, year, title, description
                                    FROM special_holidays
                                   WHERE ( branchcode = ? )
                                     AND (isexception = ?)' );
    $special->execute($branch,1);
    my %exception_holidays;
    while (my ($day, $month, $year, $title, $description) = $special->fetchrow) {
        $exception_holidays{"$year/$month/$day"}{title} = $title;
        $exception_holidays{"$year/$month/$day"}{description} = $description;
        $exception_holidays{"$year/$month/$day"}{date} = 
		sprintf(ISO_DATE_FORMAT, $year, $month, $day);
    }
    $self->{'exception_holidays'} = \%exception_holidays;

    $special->execute($branch,0);
    my %single_holidays;
    while (my ($day, $month, $year, $title, $description) = $special->fetchrow) {
        $single_holidays{"$year/$month/$day"}{title} = $title;
        $single_holidays{"$year/$month/$day"}{description} = $description;
        $single_holidays{"$year/$month/$day"}{date} = 
		sprintf(ISO_DATE_FORMAT, $year, $month, $day);
    }
    $self->{'single_holidays'} = \%single_holidays;
    return $self;
}

=head2 get_week_days_holidays

   $week_days_holidays = $calendar->get_week_days_holidays();

Returns a hash reference to week days holidays.

=cut

sub get_week_days_holidays {
    my $self = shift @_;
    my $week_days_holidays = $self->{'week_days_holidays'};
    return $week_days_holidays;
}

=head2 get_day_month_holidays

   $day_month_holidays = $calendar->get_day_month_holidays();

Returns a hash reference to day month holidays.

=cut

sub get_day_month_holidays {
    my $self = shift @_;
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
    my $self = shift @_;
    my $exception_holidays = $self->{'exception_holidays'};
    return $exception_holidays;
}

=head2 get_single_holidays

    $single_holidays = $calendar->get_single_holidays();

Returns a hash reference to single holidays. This kind of holidays are those which
happend just one time.

=cut

sub get_single_holidays {
    my $self = shift @_;
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
    my $self = shift @_;
    my %options = @_;

    my $weekday = $options{weekday};
    croak "Invalid weekday $weekday" unless $weekday =~ m/^[0-6]$/;

    my $dbh = C4::Context->dbh();
    my $insertHoliday = $dbh->prepare("insert into repeatable_holidays (id,branchcode,weekday,day,month,title,description) values ( '',?,?,NULL,NULL,?,? )"); 
	$insertHoliday->execute( $self->{branchcode}, $weekday, $options{title}, $options{description});
    $self->{'week_days_holidays'}->{$weekday}{title} = $options{title};
    $self->{'week_days_holidays'}->{$weekday}{description} = $options{description};
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
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $insertHoliday = $dbh->prepare("insert into repeatable_holidays (id,branchcode,weekday,day,month,title,description) values ('', ?, NULL, ?, ?, ?,? )");
	$insertHoliday->execute( $self->{branchcode}, $options{day},$options{month},$options{title}, $options{description});
    $self->{'day_month_holidays'}->{"$options{month}/$options{day}"}{title} = $options{title};
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
    my $self = shift @_;
    my %options = @_;
    
    @options{qw(year month day)} = ( $options{date} =~ m/(\d+)-(\d+)-(\d+)/o )
      if $options{date} && !$options{day};

	my $dbh = C4::Context->dbh();
    my $isexception = 0;
    my $insertHoliday = $dbh->prepare("insert into special_holidays (id,branchcode,day,month,year,isexception,title,description) values ('', ?,?,?,?,?,?,?)");
	$insertHoliday->execute( $self->{branchcode}, $options{day},$options{month},$options{year}, $isexception, $options{title}, $options{description});
    $self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"}{title} = $options{title};
    $self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"}{description} = $options{description};
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
    my $self = shift @_;
    my %options = @_;

    @options{qw(year month day)} = ( $options{date} =~ m/(\d+)-(\d+)-(\d+)/o )
      if $options{date} && !$options{day};

    my $dbh = C4::Context->dbh();
    my $isexception = 1;
    my $insertException = $dbh->prepare("insert into special_holidays (id,branchcode,day,month,year,isexception,title,description) values ('', ?,?,?,?,?,?,?)");
	$insertException->execute( $self->{branchcode}, $options{day},$options{month},$options{year}, $isexception, $options{title}, $options{description});
    $self->{'exception_holidays'}->{"$options{year}/$options{month}/$options{day}"}{title} = $options{title};
    $self->{'exception_holidays'}->{"$options{year}/$options{month}/$options{day}"}{description} = $options{description};
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
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $updateHoliday = $dbh->prepare("UPDATE repeatable_holidays SET title = ?, description = ? WHERE branchcode = ? AND weekday = ?");
    $updateHoliday->execute( $options{title},$options{description},$self->{branchcode},$options{weekday}); 
    $self->{'week_days_holidays'}->{$options{weekday}}{title} = $options{title};
    $self->{'week_days_holidays'}->{$options{weekday}}{description} = $options{description};
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
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $updateHoliday = $dbh->prepare("UPDATE repeatable_holidays SET title = ?, description = ? WHERE month = ? AND day = ? AND branchcode = ?");
       $updateHoliday->execute( $options{title},$options{description},$options{month},$options{day},$self->{branchcode}); 
    $self->{'day_month_holidays'}->{"$options{month}/$options{day}"}{title} = $options{title};
    $self->{'day_month_holidays'}->{"$options{month}/$options{day}"}{description} = $options{description};
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
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $isexception = 0;
    my $updateHoliday = $dbh->prepare("UPDATE special_holidays SET title = ?, description = ? WHERE day = ? AND month = ? AND year = ? AND branchcode = ? AND isexception = ?");
      $updateHoliday->execute($options{title},$options{description},$options{day},$options{month},$options{year},$self->{branchcode},$isexception);    
    $self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"}{title} = $options{title};
    $self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"}{description} = $options{description};
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
    my $self = shift @_;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $isexception = 1;
    my $updateHoliday = $dbh->prepare("UPDATE special_holidays SET title = ?, description = ? WHERE day = ? AND month = ? AND year = ? AND branchcode = ? AND isexception = ?");
    $updateHoliday->execute($options{title},$options{description},$options{day},$options{month},$options{year},$self->{branchcode},$isexception);    
    $self->{'exception_holidays'}->{"$options{year}/$options{month}/$options{day}"}{title} = $options{title};
    $self->{'exception_holidays'}->{"$options{year}/$options{month}/$options{day}"}{description} = $options{description};
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
    my $self = shift @_;
    my %options = @_;

    # Verify what kind of holiday that day is. For example, if it is
    # a repeatable holiday, this should check if there are some exception
	# for that holiday rule. Otherwise, if it is a regular holiday, it´s 
    # ok just deleting it.

    my $dbh = C4::Context->dbh();
    my $isSingleHoliday = $dbh->prepare("SELECT id FROM special_holidays WHERE (branchcode = ?) AND (day = ?) AND (month = ?) AND (year = ?)");
    $isSingleHoliday->execute($self->{branchcode}, $options{day}, $options{month}, $options{year});
    if ($isSingleHoliday->rows) {
        my $id = $isSingleHoliday->fetchrow;
        $isSingleHoliday->finish; # Close the last query

        my $deleteHoliday = $dbh->prepare("DELETE FROM special_holidays WHERE id = ?");
        $deleteHoliday->execute($id);
        delete($self->{'single_holidays'}->{"$options{year}/$options{month}/$options{day}"});
    } else {
        $isSingleHoliday->finish; # Close the last query

        my $isWeekdayHoliday = $dbh->prepare("SELECT id FROM repeatable_holidays WHERE branchcode = ? AND weekday = ?");
        $isWeekdayHoliday->execute($self->{branchcode}, $options{weekday});
        if ($isWeekdayHoliday->rows) {
            my $id = $isWeekdayHoliday->fetchrow;
            $isWeekdayHoliday->finish; # Close the last query

            my $updateExceptions = $dbh->prepare("UPDATE special_holidays SET isexception = 0 WHERE (WEEKDAY(CONCAT(special_holidays.year,'-',special_holidays.month,'-',special_holidays.day)) = ?) AND (branchcode = ?)");
            $updateExceptions->execute($options{weekday}, $self->{branchcode});
            $updateExceptions->finish; # Close the last query

            my $deleteHoliday = $dbh->prepare("DELETE FROM repeatable_holidays WHERE id = ?");
            $deleteHoliday->execute($id);
            delete($self->{'week_days_holidays'}->{$options{weekday}});
        } else {
            $isWeekdayHoliday->finish; # Close the last query

            my $isDayMonthHoliday = $dbh->prepare("SELECT id FROM repeatable_holidays WHERE (branchcode = ?) AND (day = ?) AND (month = ?)");
            $isDayMonthHoliday->execute($self->{branchcode}, $options{day}, $options{month});
            if ($isDayMonthHoliday->rows) {
                my $id = $isDayMonthHoliday->fetchrow;
                $isDayMonthHoliday->finish;
                my $updateExceptions = $dbh->prepare("UPDATE special_holidays SET isexception = 0 WHERE (special_holidays.branchcode = ?) AND (special_holidays.day = ?) and (special_holidays.month = ?)");
                $updateExceptions->execute($self->{branchcode}, $options{day}, $options{month});
                $updateExceptions->finish; # Close the last query

                my $deleteHoliday = $dbh->prepare("DELETE FROM repeatable_holidays WHERE (id = ?)");
                $deleteHoliday->execute($id);
                delete($self->{'day_month_holidays'}->{"$options{month}/$options{day}"});
            }
        }
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
    my $self = shift;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("DELETE FROM special_holidays WHERE (branchcode = ?) AND (day = ?) AND (month = ?) AND (year = ?)");
    $sth->execute($self->{branchcode}, $options{day}, $options{month}, $options{year});
}

=head2 delete_holiday_range_repeatable

    delete_holiday_range_repeatable(day => $day,
                   month => $month);

Delete a holiday for $self->{branchcode}.

C<$day> Is the day month to make the date to delete.

C<$month> Is month to make the date to delete.

=cut

sub delete_holiday_range_repeatable {
    my $self = shift;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("DELETE FROM repeatable_holidays WHERE (branchcode = ?) AND (day = ?) AND (month = ?)");
    $sth->execute($self->{branchcode}, $options{day}, $options{month});
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
    my $self = shift;
    my %options = @_;

    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("DELETE FROM special_holidays WHERE (branchcode = ?) AND (isexception = 1) AND (day = ?) AND (month = ?) AND (year = ?)");
    $sth->execute($self->{branchcode}, $options{day}, $options{month}, $options{year});
}

=head2 isHoliday

    $isHoliday = isHoliday($day, $month $year);

C<$day> Is the day to check whether if is a holiday or not.

C<$month> Is the month to check whether if is a holiday or not.

C<$year> Is the year to check whether if is a holiday or not.

=cut

sub isHoliday {
    my ($self, $day, $month, $year) = @_;
	# FIXME - date strings are stored in non-padded metric format. should change to iso.
	# FIXME - should change arguments to accept C4::Dates object
	$month=$month+0;
	$year=$year+0;
	$day=$day+0;
    my $weekday = &Date::Calc::Day_of_Week($year, $month, $day) % 7; 
    my $weekDays   = $self->get_week_days_holidays();
    my $dayMonths  = $self->get_day_month_holidays();
    my $exceptions = $self->get_exception_holidays();
    my $singles    = $self->get_single_holidays();
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

=head2 copy_to_branch

    $calendar->copy_to_branch($target_branch)

=cut

sub copy_to_branch {
    my ($self, $target_branch) = @_;

    croak "No target_branch" unless $target_branch;

    my $target_calendar = C4::Calendar->new(branchcode => $target_branch);

    my ($y, $m, $d) = Today();
    my $today = sprintf ISO_DATE_FORMAT, $y,$m,$d;

    my $wdh = $self->get_week_days_holidays;
    $target_calendar->insert_week_day_holiday( weekday => $_, %{ $wdh->{$_} } )
      foreach keys %$wdh;
    $target_calendar->insert_day_month_holiday(%$_)
      foreach values %{ $self->get_day_month_holidays };
    $target_calendar->insert_exception_holiday(%$_)
      foreach grep { $_->{date} gt $today } values %{ $self->get_exception_holidays };
    $target_calendar->insert_single_holiday(%$_)
      foreach grep { $_->{date} gt $today } values %{ $self->get_single_holidays };

    return 1;
}

=head2 addDate

    my ($day, $month, $year) = $calendar->addDate($date, $offset)

C<$date> is a C4::Dates object representing the starting date of the interval.

C<$offset> Is the number of days that this function has to count from $date.

=cut

sub addDate {
    my ($self, $startdate, $offset) = @_;
    my ($year,$month,$day) = split("-",$startdate->output('iso'));
	my $daystep = 1;
	if ($offset < 0) { # In case $offset is negative
       # $offset = $offset*(-1);
		$daystep = -1;
    }
	my $daysMode = C4::Context->preference('useDaysMode');
    if ($daysMode eq 'Datedue') {
        ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, $offset );
	 	while ($self->isHoliday($day, $month, $year)) {
            ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, $daystep);
        }
    } elsif($daysMode eq 'Calendar') {
        while ($offset !=  0) {
            ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, $daystep);
            if (!($self->isHoliday($day, $month, $year))) {
                $offset = $offset - $daystep;
			}
        }
	} else { ## ($daysMode eq 'Days') 
        ($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, $offset );
    }
    return(C4::Dates->new( sprintf(ISO_DATE_FORMAT,$year,$month,$day),'iso'));
}

=head2 daysBetween

    my $daysBetween = $calendar->daysBetween($startdate, $enddate)

C<$startdate> and C<$enddate> are C4::Dates objects that define the interval.

Returns the number of non-holiday days in the interval.
useDaysMode syspref has no effect here.
=cut

sub daysBetween {
    my $self      = shift or return;
    my $startdate = shift or return;
    my $enddate   = shift or return;
    my ($yearFrom,$monthFrom,$dayFrom) = split("-",$startdate->output('iso'));
    my ($yearTo,  $monthTo,  $dayTo  ) = split("-",  $enddate->output('iso'));
    if (Date_to_Days($yearFrom,$monthFrom,$dayFrom) > Date_to_Days($yearTo,$monthTo,$dayTo)) {
        return 0;
        # we don't go backwards  ( FIXME - handle this error better )
    }
    my $count = 0;
    while (1) {
        ($yearFrom != $yearTo or $monthFrom != $monthTo or $dayFrom != $dayTo) or last; # if they all match, it's the last day
        unless ($self->isHoliday($dayFrom, $monthFrom, $yearFrom)) {
            $count++;
        }
        ($yearFrom, $monthFrom, $dayFrom) = &Date::Calc::Add_Delta_Days($yearFrom, $monthFrom, $dayFrom, 1);
    }
    return($count);
}

1;

__END__

=head1 AUTHOR

Koha Physics Library UNLP <matias_veleda@hotmail.com>

=cut
