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

use Modern::Perl;

use CGI qw ( -utf8 );
use Data::ICal;
use Data::ICal::Entry::Event;
use DateTime;
use DateTime::Format::ICal;
use DateTime::Event::ICal;
use URI;

use C4::Auth;
use C4::Koha;
use C4::Circulation;
use C4::Members;
use Koha::DateUtils;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-ics.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 0,
        debug           => 1,
    }
);

# Create Calendar
my $calendar = Data::ICal->new();

my $patron = Koha::Patrons->find( $borrowernumber );
my $pending_checkouts = $patron->pending_checkouts;

while ( my $c = $pending_checkouts->next ) {
    my $issue = $c->unblessed_all_relateds;
    my $vevent = Data::ICal::Entry::Event->new();
    my $timestamp = DateTime->now(); # Defaults to UTC
    # Send some values to the template to generate summary and description
    $issue->{overdue} = $c->is_overdue;
    $template->param(
        overdue => $issue->{'overdue'},
        title   => $issue->{'title'},
        barcode => $issue->{'barcode'},
    );
    # Catch the result of the template and split on newline
    my ($summary,$description) = split /\n/, $template->output;
    my $datestart;
    if ($issue->{'overdue'} && $issue->{'overdue'} == 1) {
        # Not much use adding an event in the past for a book that is overdue
        # so we set datestart = now
        $datestart = $timestamp;
    } else {
        $datestart = dt_from_string($issue->{'date_due'});
        $datestart->set_time_zone('UTC');
    }
    # Create a UID that includes the issue number and the domain
    my $domain = '';
    my $baseurl = C4::Context->preference('OPACBaseURL');
    if ( $baseurl ne '' ) {
        my $url = URI->new($baseurl);
        $domain = $url->host;
    } else {
        warn "Make sure the systempreference OPACBaseURL is set!";
    }
    my $uid = 'issue-' . $issue->{'issue_id'} . '@' . $domain;
    # Create the event
    $vevent->add_properties(
        summary     => $summary,
        description => $description,
        dtstamp     => DateTime::Format::ICal->format_datetime($timestamp),
        dtstart     => DateTime::Format::ICal->format_datetime($datestart),
        uid         => $uid,
    );
    # Add it to the calendar
    $calendar->add_entry($vevent);
}

print $query->header(
    -type       => 'application/octet-stream',
    -attachment => 'koha.ics'
);

print $calendar->as_string;
