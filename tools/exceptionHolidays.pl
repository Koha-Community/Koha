#!/usr/bin/perl

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth qw( checkauth );
use C4::Output;
use DateTime;

use C4::Calendar;
use Koha::DateUtils qw( dt_from_string );

my $input = CGI->new;
my $dbh = C4::Context->dbh();

checkauth($input, 0, {tools=> 'edit_calendar'}, 'intranet');


our $branchcode = $input->param('showBranchName');
my $originalbranchcode  = $branchcode;
our $weekday = $input->param('showWeekday');
our $day = $input->param('showDay');
our $month = $input->param('showMonth');
our $year = $input->param('showYear');
our $title = $input->param('showTitle');
our $description = $input->param('showDescription');
our $holidaytype = $input->param('showHolidayType');
my $datecancelrange_dt = eval { dt_from_string( scalar $input->param('datecancelrange') ) };
my $calendardate = sprintf("%04d-%02d-%02d", $year, $month, $day);
our $showoperation = $input->param('showOperation');
my $allbranches = $input->param('allBranches');

$title || ($title = '');
if ($description) {
    $description =~ s/\r/\\r/g;
    $description =~ s/\n/\\n/g;
} else {
    $description = '';
}   

# We make an array with holiday's days
our @holiday_list;
if ($datecancelrange_dt){
            my $first_dt = DateTime->new(year => $year, month  => $month,  day => $day);

            for (my $dt = $first_dt->clone();
                $dt <= $datecancelrange_dt;
                $dt->add(days => 1) )
                {
                push @holiday_list, $dt->clone();
                }
}

if($allbranches) {
    my $libraries = Koha::Libraries->search;
    while ( my $library = $libraries->next ) {
        edit_holiday($showoperation, $library->branchcode, $weekday, $day, $month, $year, $title, $description, $holidaytype, @holiday_list);
    }
} else {
    edit_holiday($showoperation, $branchcode, $weekday, $day, $month, $year, $title, $description, $holidaytype, @holiday_list);
}

print $input->redirect("/cgi-bin/koha/tools/holidays.pl?branch=$originalbranchcode&calendardate=$calendardate");

sub edit_holiday {
    ($showoperation, $branchcode, $weekday, $day, $month, $year, $title, $description, $holidaytype, @holiday_list) = @_;
    my $calendar = C4::Calendar->new(branchcode => $branchcode);

    if ($showoperation eq 'exception') {
        $calendar->insert_exception_holiday(day => $day,
                                            month => $month,
                                            year => $year,
                                            title => $title,
                                            description => $description);
    } elsif ($showoperation eq 'exceptionrange' ) {
            if (@holiday_list){
                foreach my $date (@holiday_list){
                    $calendar->insert_exception_holiday(
                        day         => $date->{local_c}->{day},
                        month       => $date->{local_c}->{month},
                        year       => $date->{local_c}->{year},
                        title       => $title,
                        description => $description
                        );
                }
            }
    } elsif ($showoperation eq 'edit') {
        if ( $holidaytype eq 'weekday' ) {
            my $isHoliday = $calendar->isHoliday( $day, $month, $year );
            if ($isHoliday) {
                $calendar->ModWeekdayholiday(
                    weekday     => $weekday,
                    title       => $title,
                    description => $description
                );
            }
            else {
                $calendar->insert_week_day_holiday(
                    weekday     => $weekday,
                    title       => $title,
                    description => $description
                );
            }
        }
        elsif ( $holidaytype eq 'daymonth' ) {
            my $isHoliday = $calendar->isHoliday( $day, $month, $year );
            if ($isHoliday) {
                $calendar->ModDaymonthholiday(
                    day         => $day,
                    month       => $month,
                    title       => $title,
                    description => $description
                );
            }
            else {
                $calendar->insert_day_month_holiday(
                    day         => $day,
                    month       => $month,
                    title       => $title,
                    description => $description
                );
            }
        }
        elsif ( $holidaytype eq 'ymd' ) {
            my $isHoliday = $calendar->isHoliday( $day, $month, $year );
            if ($isHoliday) {
                $calendar->ModSingleholiday(
                    day         => $day,
                    month       => $month,
                    year        => $year,
                    title       => $title,
                    description => $description
                );
            }
            else {
                $calendar->insert_single_holiday(
                    day         => $day,
                    month       => $month,
                    year        => $year,
                    title       => $title,
                    description => $description
                );
            }
        }
        elsif ( $holidaytype eq 'exception' ) {
            my $isHoliday = $calendar->isHoliday( $day, $month, $year );
            if ($isHoliday) {
                $calendar->ModExceptionholiday(
                    day         => $day,
                    month       => $month,
                    year        => $year,
                    title       => $title,
                    description => $description
                );
            }
            else {
                $calendar->insert_exception_holiday(
                    day         => $day,
                    month       => $month,
                    year        => $year,
                    title       => $title,
                    description => $description
                );
            }
        }
    } elsif ($showoperation eq 'delete') {
        $calendar->delete_holiday(weekday => $weekday,
                                day => $day,
                                month => $month,
                                year => $year);
    }elsif ($showoperation eq 'deleterange') {
        if (@holiday_list){
            foreach my $date (@holiday_list){
                $calendar->delete_holiday_range(weekday => $weekday,
                                                day => $date->{local_c}->{day},
                                                month => $date->{local_c}->{month},
                                                year => $date->{local_c}->{year});
                }
        }
    }elsif ($showoperation eq 'deleterangerepeat') {
        if (@holiday_list){
            foreach my $date (@holiday_list){
            $calendar->delete_holiday_range_repeatable(weekday => $weekday,
                                            day => $date->{local_c}->{day},
                                            month => $date->{local_c}->{month});
            }
        }
    }elsif ($showoperation eq 'deleterangerepeatexcept') {
        if (@holiday_list){
            foreach my $date (@holiday_list){
            $calendar->delete_exception_holiday_range(weekday => $weekday,
                                            day => $date->{local_c}->{day},
                                            month => $date->{local_c}->{month},
                                            year => $date->{local_c}->{year});
            }
        }
    }
}
