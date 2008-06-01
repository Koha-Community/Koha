#!/usr/bin/perl

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

#####Sets holiday periods for each branch. Datedues will be extended if branch is closed -TG
use strict;
use CGI;

use C4::Auth;
use C4::Output;

use C4::Branch; # GetBranches
use C4::Calendar;

my $input = new CGI;

my $branch=C4::Context->preference('defaultbranch') || $input->param('branch');



my $dbh = C4::Context->dbh();
# Get the template to use
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "tools/holidays.tmpl",
                             type => "intranet",
                             query => $input,
                             authnotrequired => 0,
                             flagsrequired => {tools => 'edit_calendar'},
                             debug => 1,
                           });

# Set all the branches.
my $onlymine=(C4::Context->preference('IndependantBranches') &&
              C4::Context->userenv &&
              C4::Context->userenv->{flags} !=1  &&
              C4::Context->userenv->{branch}?1:0);
if ( C4::Context->preference("IndependantBranches") ) { 
    $branch = C4::Context->userenv->{'branch'};
}
my $branches = GetBranches($onlymine);
my @branchloop;
for my $thisbranch (sort { $branches->{$a}->{branchname} cmp $branches->{$b}->{branchname} } keys %$branches) {
    my $selected = 1 if $thisbranch eq $branch;
    my %row =(value => $thisbranch,
                selected => $selected,
                branchname => $branches->{$thisbranch}->{'branchname'},
            );
    push @branchloop, \%row;
}


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
    my %day_month;
    %day_month = (KEY => $monthDay,
                  TITLE => $day_month_holidays->{$monthDay}{title},
                  DESCRIPTION => $day_month_holidays->{$monthDay}{description});
    push @day_month_holidays, \%day_month;
}

my $exception_holidays = $calendar->get_exception_holidays();
my @exception_holidays;
foreach my $yearMonthDay (keys %$exception_holidays) {
    my %exception_holiday;
    %exception_holiday = (KEY => $yearMonthDay,
                          TITLE => $exception_holidays->{$yearMonthDay}{title},
                          DESCRIPTION => $exception_holidays->{$yearMonthDay}{description});
    push @exception_holidays, \%exception_holiday;
}

my $single_holidays = $calendar->get_single_holidays();
my @holidays;
foreach my $yearMonthDay (keys %$single_holidays) {
    my %holiday;
    %holiday = (KEY => $yearMonthDay,
                TITLE => $single_holidays->{$yearMonthDay}{title},
                DESCRIPTION => $single_holidays->{$yearMonthDay}{description});
    push @holidays, \%holiday;
}

$template->param(WEEK_DAYS_LOOP => \@week_days,
				branchloop => \@branchloop, 
				HOLIDAYS_LOOP => \@holidays,
				EXCEPTION_HOLIDAYS_LOOP => \@exception_holidays,
				DAY_MONTH_HOLIDAYS_LOOP => \@day_month_holidays,
				branch => $branch
	);

# Shows the template with the real values replaced
output_html_with_http_headers $input, $cookie, $template->output;
