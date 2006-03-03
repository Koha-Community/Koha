#!/usr/bin/perl

use strict;
use CGI;

use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Calendar;

my $input = new CGI;
my $dbh = C4::Context->dbh();

my $branchcode = $input->param('showBranchName');
my $weekday = $input->param('showWeekday');
my $day = $input->param('showDay');
my $month = $input->param('showMonth');
my $year = $input->param('showYear');
my $title = $input->param('showTitle');
my $description = $input->param('showDescription');

my $calendar = C4::Calendar->new(branchcode => $branchcode);

if ($input->param('showOperation') eq 'exception') {
	$calendar->insert_exception_holiday(day => $day,
										month => $month,
									    year => $year,
						                title => $title,
						                description => $description);
} elsif ($input->param('showOperation') eq 'delete') {
	$calendar->delete_holiday(weekday => $weekday,
	                          day => $day,
  	                          month => $month,
				              year => $year);
}
print $input->redirect("/cgi-bin/koha/tools/holidays.pl?branch=$branchcode");
