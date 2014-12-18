#!/usr/bin/perl

# Copyright 2014 Vaara-kirjastot
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use CGI;
use JSON qw(to_json);
use DateTime;

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Context;
use Koha::DateUtils;

my $input = new CGI;

my $op = $input->param('op');
$op = '' unless $op;

my $minutes = $input->param('minutes');
$minutes = 1 unless $minutes;


##Get a new timechunk for the Circulation Visualizer
if ($op eq 'getChunk') {
    binmode STDOUT, ":encoding(UTF-8)";
    getCirculationEventChunk( $input );
    exit;
}
##Initialize the Circulation Visualizer
else {
    initCirculationVisualizer( $input );
    exit;
}

sub initCirculationVisualizer {
    my ($input) = @_;

    my ( $template, $borrowernumber, $cookie ) = C4::Auth::get_template_and_user(
        {
            template_name   => "svc/circvis.tt",
            type            => "opac",
            query           => $input,
            authnotrequired => 1,
            flagsrequired   => {  },
        }
    );

    my $eventsChunk = getEventsChunk(undef, $minutes);

    $template->param(eventsChunk => JSON::to_json($eventsChunk));
    $template->param(serverTime => time);
    C4::Output::output_html_with_http_headers($input, $cookie, $template->output());
}

sub getCirculationEventChunk {
    my ($input) = @_;

    my $clientTime = $input->param('clientTime');

    print $input->header(
        -type => 'application/json',
        -charset => 'UTF-8'
    );
    my $eventsChunk = getEventsChunk($clientTime, $minutes);
    my $data = {
                eventsChunk => $eventsChunk,
                serverTime => time,
                clientTime => $clientTime,
               };
    print JSON::to_json($data);
}

sub getEventsChunk {
    my ($clientTime, $minutes) = @_;

    my $dt;
    if ($clientTime) {
        $dt = DateTime->from_epoch(  epoch => $clientTime/1000, time_zone => C4::Context->tz()  );
    }
    else {
        $dt = DateTime->now(  time_zone => C4::Context->tz()  );
    }

    $dt->truncate( to => 'minute' );

    my $endDateIso =  $dt->iso8601();
    my $startDateIso = $dt->subtract( minutes => $minutes )->iso8601();
    my $dbh = C4::Context->dbh;

    my $sql = qq|SELECT *, UNIX_TIMESTAMP(datetime) AS time FROM statistics WHERE datetime >= ? AND datetime <= ?|;
    my $sth = $dbh->prepare($sql);
    $sth->execute($startDateIso, $endDateIso);
    my $eventsChunk = $sth->fetchall_arrayref({});

    return $eventsChunk;
}