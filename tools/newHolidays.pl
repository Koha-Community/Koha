#!/usr/bin/perl
#FIXME: perltidy this file

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
# You should have received a copy of the GNU General Public Lic# along with Koha; if not, see <http://www.gnu.org/licenses>.
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth;
use C4::Output;

use Koha::Caches;

use C4::Calendar;
use DateTime;
use Koha::DateUtils;

my $input               = new CGI;
my $dbh                 = C4::Context->dbh();

our $branchcode          = $input->param('newBranchName');
my $originalbranchcode  = $branchcode;
our $weekday             = $input->param('newWeekday');
our $day                 = $input->param('newDay');
our $month               = $input->param('newMonth');
our $year                = $input->param('newYear');
my $dateofrange         = $input->param('dateofrange');
our $title               = $input->param('newTitle');
our $description         = $input->param('newDescription');
our $newoperation        = $input->param('newOperation');
my $allbranches         = $input->param('allBranches');


my $first_dt = DateTime->new(year => $year, month  => $month,  day => $day);
my $end_dt   = eval { dt_from_string( $dateofrange ); };

my $calendardate = output_pref( { dt => $first_dt, dateonly => 1, dateformat => 'iso' } );

$title || ($title = '');
if ($description) {
	$description =~ s/\r/\\r/g;
	$description =~ s/\n/\\n/g;
} else {
	$description = '';
}

# We make an array with holiday's days
our @holiday_list;
if ($end_dt){
    for (my $dt = $first_dt->clone();
    $dt <= $end_dt;
    $dt->add(days => 1) )
    {
        push @holiday_list, $dt->clone();
    }
}

if($allbranches) {
    my $libraries = Koha::Libraries->search;
    while ( my $library = $libraries->next ) {
        add_holiday($newoperation, $library->branchcode, $weekday, $day, $month, $year, $title, $description);
    }
} else {
    add_holiday($newoperation, $branchcode, $weekday, $day, $month, $year, $title, $description);
}

print $input->redirect("/cgi-bin/koha/tools/holidays.pl?branch=$originalbranchcode&calendardate=$calendardate");

#FIXME: move add_holiday() to a better place
sub add_holiday {
	($newoperation, $branchcode, $weekday, $day, $month, $year, $title, $description) = @_;  
	my $calendar = C4::Calendar->new(branchcode => $branchcode);

	if ($newoperation eq 'weekday') {
		unless ( $weekday && ($weekday ne '') ) { 
			# was dow calculated by javascript?  original code implies it was supposed to be.
			# if not, we need it.
			$weekday = &Date::Calc::Day_of_Week($year, $month, $day) % 7 unless($weekday);
		}
		unless($calendar->isHoliday($day, $month, $year)) {
			$calendar->insert_week_day_holiday(weekday => $weekday,
							           title => $title,
							           description => $description);
		}
	} elsif ($newoperation eq 'repeatable') {
		unless($calendar->isHoliday($day, $month, $year)) {
			$calendar->insert_day_month_holiday(day => $day,
	                                    month => $month,
							            title => $title,
							            description => $description);
		}
	} elsif ($newoperation eq 'holiday') {
		unless($calendar->isHoliday($day, $month, $year)) {
			$calendar->insert_single_holiday(day => $day,
	                                 month => $month,
						             year => $year,
						             title => $title,
						             description => $description);
		}

	} elsif ( $newoperation eq 'holidayrange' ) {
        if (@holiday_list){
            foreach my $date (@holiday_list){
                unless ( $calendar->isHoliday( $date->{local_c}->{day}, $date->{local_c}->{month}, $date->{local_c}->{year} ) ) {
                    $calendar->insert_single_holiday(
                        day         => $date->{local_c}->{day},
                        month       => $date->{local_c}->{month},
                        year        => $date->{local_c}->{year},
                        title       => $title,
                        description => $description
                    );
                }
            }
        }
    } elsif ( $newoperation eq 'holidayrangerepeat' ) {
        if (@holiday_list){
            foreach my $date (@holiday_list){
                unless ( $calendar->isHoliday( $date->{local_c}->{day}, $date->{local_c}->{month}, $date->{local_c}->{year} ) ) {
                    $calendar->insert_day_month_holiday(
                        day         => $date->{local_c}->{day},
                        month       => $date->{local_c}->{month},
                        title       => $title,
                        description => $description
                    );
                }
            }
        }
    }
    # we updated the single_holidays table, so wipe its cache
    my $cache = Koha::Caches->get_instance();
    $cache->clear_from_cache( 'single_holidays') ;
}
