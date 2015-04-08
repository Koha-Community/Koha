#!/usr/bin/perl

# Copyright 2007 Liblime Ltd
#
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

use strict;
#use warnings; FIXME - Bug 2505
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
my $base;

if ( C4::Context->config('supportdir') ) {
     $base = C4::Context->config('supportdir');
}
else {
     $base = "/usr/share/koha/bin";
}

my $CONFIG_NAME = $ENV{'KOHA_CONF'};

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/scheduler.tt",
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

    # Retrieving the date according to the dateformat syspref
    my $c4date = C4::Dates->new($input->param('startdate'));

    # Formatting it for Schedule::At
    my $startdate = join('', (split /-/, $c4date->output("iso")));

    my $starttime = $input->param('starttime');
    $starttime =~ s/\://g;
    my $start  = $startdate . $starttime;
    my $report = $input->param('report');
    my $format = $input->param('format');
    my $email  = $input->param('email');
    my $command =
        "export KOHA_CONF=\"$CONFIG_NAME\"; " .
        "$base/cronjobs/runreport.pl $report --format=$format --to=$email";

#FIXME commit ea899bc55933cd74e4665d70b1c48cab82cd1257 added recurring parameter (it is not in template) and call to add_cron_job (undefined)
#    my $recurring = $input->param('recurring');
#    if ($recurring) {
#        my $frequency = $input->param('frequency');
#        add_cron_job( $start, $command );
#    }
#    else {
#        #here was the the unless ( add_at_job
#    }

    unless ( add_at_job( $start, $command ) ) {
        $template->param( job_add_failed => 1 );
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
    debug                    => $debug,
);
output_html_with_http_headers $input, $cookie, $template->output;
