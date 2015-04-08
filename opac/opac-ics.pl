#!/usr/bin/perl

# Copyright 2007 Liblime Ltd

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

# This script builds an ICalendar file (rfc 2445) for use in programs such as Ical

use strict;
use warnings;

use CGI;
use Data::ICal;
use Data::ICal::Entry::Event;
use DateTime;
use DateTime::Format::ICal;
use Date::Calc qw (Parse_Date);
use DateTime;
use DateTime::Event::ICal;

use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Members;
use C4::Dates;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-user.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

# get borrower information ....
my ( $borr ) =  GetMemberDetails( $borrowernumber );

# Create Calendar
my $calendar = Data::ICal->new();

# get issued items ....
my $issues = GetPendingIssues($borrowernumber);

foreach my $issue ( @$issues ) {
    my $vevent = Data::ICal::Entry::Event->new();
    my ($year,$month,$day)=Parse_Date($issue->{'date_due'});
    ($year,$month,$day)=split /-|\/|\.|:/,$issue->{'date_due'} unless ($year && $month);
#    Decode_Date_EU2($string))
    my $datestart = DateTime->new(
        day    => $day,
        month  => $month,
        year   => $year,
        hour   => 9,
        minute => 0,
        second => 0
    );
    my $dateend = DateTime->new(
        day    => $day,
        month  => $month,
        year   => $year,
        hour   => 10,
        minute => 0,
        second => 0
    );
    $vevent->add_properties(
        summary => "$issue->{'title'} Due",
        description =>
"Your copy of $issue->{'title'} barcode $issue->{'barcode'} is due back at the library today",
        dtstart => DateTime::Format::ICal->format_datetime($datestart),
        dtend   => DateTime::Format::ICal->format_datetime($dateend),
    );
    $calendar->add_entry($vevent);
}

print $query->header(
    -type        => 'application/octet-stream',
    -attachment => 'koha.ics'
);


print $calendar->as_string;
