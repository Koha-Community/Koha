#!/usr/bin/perl

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

#####Sets holiday periods for each branch. Datedues will be extended if branch is closed -TG
use strict;
use warnings;

use CGI;

use C4::Auth;
use C4::Output;

use C4::Branch; # GetBranches
use C4::Calendar;

my $input = new CGI;

my $dbh = C4::Context->dbh();
# Get the template to use
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/holidays.tt",
                             type => "intranet",
                             query => $input,
                             authnotrequired => 0,
                             flagsrequired => {tools => 'edit_calendar'},
                             debug => 1,
                           });

# keydate - date passed to calendar.js.  calendar.js does not process dashes within a date.
my $keydate;
# calendardate - date passed in url for human readability (syspref)
my $calendardate;
my $today = C4::Dates->new();
my $calendarinput = C4::Dates->new($input->param('calendardate')) || $today;
# if the url has an invalid date default to 'now.'
unless($calendardate = $calendarinput->output('syspref')) {
  $calendardate = $today->output('syspref');
}
unless($keydate = $calendarinput->output('iso')) {
  $keydate = $today->output('iso');
}
$keydate =~ s/-/\//g;

my $branch= $input->param('branch') || C4::Context->userenv->{'branch'};
# Set all the branches.
my $onlymine =
  (      C4::Context->preference('IndependentBranches')
      && C4::Context->userenv
      && !C4::Context->IsSuperLibrarian()
      && C4::Context->userenv->{branch} ? 1 : 0 );
if ( $onlymine ) { 
    $branch = C4::Context->userenv->{'branch'};
}
my $branchname = GetBranchName($branch);
my $branches   = GetBranches($onlymine);
my @branchloop;
for my $thisbranch (
    sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} }
    keys %{$branches} ) {
    push @branchloop,
      { value      => $thisbranch,
        selected   => $thisbranch eq $branch,
        branchname => $branches->{$thisbranch}->{'branchname'},
      };
}

# branches calculated - put branch codes in a single string so they can be passed in a form
my $branchcodes = join '|', keys %{$branches};

# Get all the holidays

my $calendar = C4::Calendar->new(branchcode => $branch);
my $week_days_holidays = $calendar->get_week_days_holidays();
my @week_days;
foreach my $weekday (keys %$week_days_holidays) {
# warn "WEEK DAY : $weekday";
    my %week_day;
    %week_day = (KEY => $weekday,
                 TITLE => $week_days_holidays->{$weekday}{title},
                 DESCRIPTION => $week_days_holidays->{$weekday}{description});
    push @week_days, \%week_day;
}

my $day_month_holidays = $calendar->get_day_month_holidays();
my @day_month_holidays;
foreach my $monthDay (keys %$day_month_holidays) {
    # Determine date format on month and day.
    my $day_monthdate;
    my $day_monthdate_sort;
    if (C4::Context->preference("dateformat") eq "metric") {
      $day_monthdate_sort = "$day_month_holidays->{$monthDay}{month}-$day_month_holidays->{$monthDay}{day}";
      $day_monthdate = "$day_month_holidays->{$monthDay}{day}/$day_month_holidays->{$monthDay}{month}";
    } elsif (C4::Context->preference("dateformat") eq "us") {
      $day_monthdate = "$day_month_holidays->{$monthDay}{month}/$day_month_holidays->{$monthDay}{day}";
      $day_monthdate_sort = $day_monthdate;
    } else {
      $day_monthdate = "$day_month_holidays->{$monthDay}{month}-$day_month_holidays->{$monthDay}{day}";
      $day_monthdate_sort = $day_monthdate;
    }
    my %day_month;
    %day_month = (KEY => $monthDay,
                  DATE_SORT => $day_monthdate_sort,
                  DATE => $day_monthdate,
                  TITLE => $day_month_holidays->{$monthDay}{title},
                  DESCRIPTION => $day_month_holidays->{$monthDay}{description});
    push @day_month_holidays, \%day_month;
}

my $exception_holidays = $calendar->get_exception_holidays();
my @exception_holidays;
foreach my $yearMonthDay (keys %$exception_holidays) {
    my $exceptiondate = C4::Dates->new($exception_holidays->{$yearMonthDay}{date}, "iso");
    my %exception_holiday;
    %exception_holiday = (KEY => $yearMonthDay,
                          DATE_SORT => $exception_holidays->{$yearMonthDay}{date},
                          DATE => $exceptiondate->output("syspref"),
                          TITLE => $exception_holidays->{$yearMonthDay}{title},
                          DESCRIPTION => $exception_holidays->{$yearMonthDay}{description});
    push @exception_holidays, \%exception_holiday;
}

my $single_holidays = $calendar->get_single_holidays();
my @holidays;
foreach my $yearMonthDay (keys %$single_holidays) {
    my $holidaydate = C4::Dates->new($single_holidays->{$yearMonthDay}{date}, "iso");
    my %holiday;
    %holiday = (KEY => $yearMonthDay,
                DATE_SORT => $single_holidays->{$yearMonthDay}{date},
                DATE => $holidaydate->output("syspref"),
                TITLE => $single_holidays->{$yearMonthDay}{title},
                DESCRIPTION => $single_holidays->{$yearMonthDay}{description});
    push @holidays, \%holiday;
}

$template->param(
    WEEK_DAYS_LOOP           => \@week_days,
    branchloop               => \@branchloop,
    HOLIDAYS_LOOP            => \@holidays,
    EXCEPTION_HOLIDAYS_LOOP  => \@exception_holidays,
    DAY_MONTH_HOLIDAYS_LOOP  => \@day_month_holidays,
    calendardate             => $calendardate,
    keydate                  => $keydate,
    branchcodes              => $branchcodes,
    branch                   => $branch,
    branchname               => $branchname,
    branch                   => $branch,
);

# Shows the template with the real values replaced
output_html_with_http_headers $input, $cookie, $template->output;
