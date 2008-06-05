#!/usr/bin/perl

use strict;
use CGI;

use C4::Auth;
use C4::Output;


use C4::Calendar;

my $input = new CGI;
my $dbh = C4::Context->dbh();

my $branchcode = $input->param('newBranchName');
my $weekday = $input->param('newWeekday');
my $day = $input->param('newDay');
my $month = $input->param('newMonth');
my $year = $input->param('newYear');
my $title = $input->param('newTitle');
my $description = $input->param('newDescription');

$title || ($title = '');
if ($description) {
	$description =~ s/\r/\\r/g;
	$description =~ s/\n/\\n/g;
} else {
	$description = '';
}
my $calendar = C4::Calendar->new(branchcode => $branchcode);

if ($input->param('newOperation') eq 'weekday') {
	unless ( $weekday && ($weekday ne '') ) { 
		# was dow calculated by javascript?  original code implies it was supposed to be.
		# if not, we need it.
		$weekday = &Date::Calc::Day_of_Week($year, $month, $day) % 7 unless($weekday);
	}
	$calendar->insert_week_day_holiday(weekday => $weekday,
							           title => $title,
							           description => $description);
} elsif ($input->param('newOperation') eq 'repeatable') {
	$calendar->insert_day_month_holiday(day => $day,
	                                    month => $month,
							            title => $title,
							            description => $description);
} elsif ($input->param('newOperation') eq 'holiday') {
	$calendar->insert_single_holiday(day => $day,
	                                 month => $month,
						             year => $year,
						             title => $title,
						             description => $description);

}
print $input->redirect("/cgi-bin/koha/tools/holidays.pl?branch=$branchcode");
