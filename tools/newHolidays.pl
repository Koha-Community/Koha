#!/usr/bin/perl

use strict;
use warnings;

use CGI;

use C4::Auth;
use C4::Output;


use C4::Calendar;
use DateTime;

my $input               = new CGI;
my $dbh                 = C4::Context->dbh();

my $branchcode          = $input->param('newBranchName');
my $originalbranchcode  = $branchcode;
my $weekday             = $input->param('newWeekday');
my $day                 = $input->param('newDay');
my $month               = $input->param('newMonth');
my $year                = $input->param('newYear');
my $day1;
my $month1;
my $year1;
my $dateofrange         = $input->param('dateofrange');
my $title               = $input->param('newTitle');
my $description         = $input->param('newDescription');
my $newoperation        = $input->param('newOperation');
my $allbranches         = $input->param('allBranches');

my $calendardate        = sprintf("%04d-%02d-%02d", $year, $month, $day);
my $isodate             = C4::Dates->new($calendardate, 'iso');
$calendardate           = $isodate->output('syspref');

my @dateend = split(/[\/-]/, $dateofrange);
if (C4::Context->preference("dateformat") eq "metric") {
    $day1 = $dateend[0];
    $month1 = $dateend[1];
    $year1 = $dateend[2];
}elsif (C4::Context->preference("dateformat") eq "us") {
    $month1 = $dateend[0];
    $day1 = $dateend[1];
    $year1 = $dateend[2];
} else {
    $year1 = $dateend[0];
    $month1 = $dateend[1];
    $day1 = $dateend[2];
}
$title || ($title = '');
if ($description) {
	$description =~ s/\r/\\r/g;
	$description =~ s/\n/\\n/g;
} else {
	$description = '';
}

# We make an array with holiday's days
my @holiday_list;
if ($year1 && $month1 && $day1){
            my $first_dt = DateTime->new(year => $year, month  => $month,  day => $day);
            my $end_dt   = DateTime->new(year => $year1, month  => $month1,  day => $day1);

            for (my $dt = $first_dt->clone();
                $dt <= $end_dt;
                $dt->add(days => 1) )
                {
                push @holiday_list, $dt->clone();
                }
}

if($allbranches) {
	my $branch;
	my @branchcodes = split(/\|/, $input->param('branchCodes')); 
	foreach $branch (@branchcodes) {
		add_holiday($newoperation, $branch, $weekday, $day, $month, $year, $title, $description);
	}
} else {
	add_holiday($newoperation, $branchcode, $weekday, $day, $month, $year, $title, $description);
}

print $input->redirect("/cgi-bin/koha/tools/holidays.pl?branch=$originalbranchcode&calendardate=$calendardate");

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
}
