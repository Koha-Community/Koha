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

use C4::Auth        qw( get_template_and_user );
use Koha::DateUtils qw( dt_from_string );

my $query = CGI->new;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name => "opac-ics.tt",
        query         => $query,
        type          => "opac",
    }
);

# Create Calendar
my $calendar = Data::ICal->new();

my $patron            = Koha::Patrons->find($borrowernumber);
my $pending_checkouts = $patron->pending_checkouts;

my $timestamp = dt_from_string( undef, undef, "UTC" );    #Get current time in UTC

while ( my $c = $pending_checkouts->next ) {
    my $issue  = $c->unblessed_all_relateds;
    my $vevent = Data::ICal::Entry::Event->new();

    # Send some values to the template to generate summary and description
    $issue->{overdue} = $c->is_overdue;
    $template->param(
        overdue => $issue->{'overdue'},
        title   => $issue->{'title'},
        barcode => $issue->{'barcode'},
    );

    # Catch the result of the template and split on newline
    my ( $summary, $description ) = split /\n/, $template->output;
    my ( $datestart, $datestart_local );
    if ( $issue->{'overdue'} && $issue->{'overdue'} == 1 ) {

        # Not much use adding an event in the past for a book that is overdue
        # so we set datestart = now
        $datestart       = $timestamp->clone();
        $datestart_local = $datestart->clone();
    } else {
        $datestart       = dt_from_string( $issue->{'date_due'} );
        $datestart_local = $datestart->clone();
        $datestart->set_time_zone('UTC');
    }

    # Create a UID that includes the issue number and the domain
    my $domain  = '';
    my $baseurl = C4::Context->preference('OPACBaseURL');
    if ( $baseurl ne '' ) {
        my $url = URI->new($baseurl);
        $domain = $url->host;
    } else {
        warn "Make sure the systempreference OPACBaseURL is set!";
    }
    my $uid = 'issue-' . $issue->{'issue_id'} . '@' . $domain;

    # Create the event

    my $dtstart;
    if ( $issue->{'overdue'} && $issue->{'overdue'} == 1 ) {

        # It's already overdue so make it due as an all day event today
        $dtstart = [ $datestart->ymd(q{}), { VALUE => 'DATE' } ];
    } elsif ( $datestart_local->hour eq '23' && $datestart_local->minute eq '59' ) {

        # Checkouts due at 23:59 are "all day events"
        $dtstart = [ $datestart->ymd(q{}), { VALUE => 'DATE' } ];
    } else {    # Checkouts due any other time are instantaneous events at the date and time due
        $dtstart = DateTime::Format::ICal->format_datetime($datestart);
    }

    $vevent->add_properties(
        summary     => $summary,
        description => $description,
        dtstamp     => DateTime::Format::ICal->format_datetime($timestamp),
        dtstart     => $dtstart,
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
