#!/usr/bin/perl

# Copyright 2007 Liblime Ltd

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

# This script builds an ICalendar file (rfc 2445) for use in programs such as Ical

use strict;
use CGI;
use Data::ICal;
use Data::ICal::Entry::Event;
use Date::ICal;
use Date::Calc qw (Parse_Date);

use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Members;
use C4::Dates;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-user.tmpl",
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
my ($issues) = GetPendingIssues($borrowernumber);

foreach my $issue ( @$issues ) {
    my $vevent = Data::ICal::Entry::Event->new();
    my ($year,$month,$day)=Parse_Date($issue->{'date_due'});
    ($year,$month,$day)=split /-|\/|\.|:/,$issue->{'date_due'} unless ($year && $month);
#    Decode_Date_EU2($string))
    my $datestart = Date::ICal->new( 
	day => $day, 
	month => $month, 
	year => $year,
	hour => 9,
	min => 0,
	sec => 0
    )->ical;
    my $dateend = Date::ICal->new( 
	day => $day, 
	month => $month, 
	year => $year,
	hour => 10,
	min => 0,
	sec => 0
    )->ical;
    $vevent->add_properties(
        summary => "$issue->{'title'} Due",
        description =>
"Your copy of $issue->{'title'} barcode $issue->{'barcode'} is due back at the library today",
        dtstart => $datestart,
	dtend => $dateend,
    );
    $calendar->add_entry($vevent);
}

print $query->header(
    -type        => 'application/octet-stream',
    -attachment => 'koha.ics'
);


print $calendar->as_string;
