#!/usr/bin/perl

# Copyright 2007 Liblime Ltd
#
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

use strict;
use C4::Context;
use C4::Scheduler;
use C4::Reports::Guided;
use C4::Auth;
use CGI;
use C4::Output;
use C4::Dates;

use vars qw($debug);

BEGIN {
    $debug = $ENV{DEBUG} || 0;
}

my $input = new CGI;

my $base        = C4::Context->config('intranetdir');
my $CONFIG_NAME = $ENV{'KOHA_CONF'};

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/scheduler.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'schedule_tasks' },
        debug           => 1,
    }
);

my $mode = $input->param('mode');
my $id   = $input->param('id');

if ( $mode eq 'job_add' ) {
    my $startdate =
      join( '', ( split m|/|, $input->param('startdate') )[ 2, 0, 1 ] );
    my $starttime = $input->param('starttime');
    my $recurring = $input->param('recurring');
    $starttime =~ s/\://g;
    my $start  = $startdate . $starttime;
    my $report = $input->param('report');
    my $format = $input->param('format');
    my $email  = $input->param('email');
    my $command =
        "EXPORT KOHA_CONF=\"$CONFIG_NAME\"; " . $base
      . "/tools/runreport.pl $report $format $email";

    if ($recurring) {
        my $frequency = $input->param('frequency');
        add_cron_job( $start, $command );
    }
    else {
        unless ( add_at_job( $start, $command ) ) {
            $template->param( job_add_failed => 1 );
        }
    }
}

if ( $mode eq 'job_change' ) {
    my $jobid = $input->param('jobid');
    if ( $input->param('delete') ) {
        remove_at_job($jobid);
    }
}

my $jobs = get_jobs();
my @jobloop;
foreach my $job ( values %$jobs ) {
    push @jobloop, $job;
}

@jobloop = sort { $a->{TIME} cmp $b->{TIME} } @jobloop;

my $reports = get_saved_reports();
if ( defined $id ) {
    foreach my $report (@$reports) {
        $report->{'selected'} = 1 if $report->{'id'} eq $id;
    }
}

$template->param( 'savedreports' => $reports );
$template->param( JOBS           => \@jobloop );
my $time = localtime(time);
$template->param( 'time' => $time );
$template->param(
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    dateformat               => C4::Dates->new()->format(),
    debug                    => $debug,
);
output_html_with_http_headers $input, $cookie, $template->output;
