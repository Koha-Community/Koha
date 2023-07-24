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

use Modern::Perl;
use C4::Context;
use C4::Scheduler qw( add_at_job get_jobs remove_at_job );
use C4::Reports::Guided qw( get_saved_reports );
use C4::Auth qw( get_template_and_user );
use CGI qw ( -utf8 );
use C4::Output qw( output_html_with_http_headers );
use Koha::DateUtils qw( dt_from_string output_pref );;

my $input = CGI->new;
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
        flagsrequired   => { tools => 'schedule_tasks' },
    }
);

my $mode = $input->param('mode');
my $id   = $input->param('id');

if ( $mode eq 'job_add' ) {

    # Retrieving the date according to the dateformat syspref
    my $c4date = output_pref({ dt => dt_from_string( scalar $input->param('startdate') ), dateformat => 'iso', dateonly => 1 });

    # Formatting it for Schedule::At
    my $startdate = join('', (split /-/, $c4date));

    my $starttime = $input->param('starttime');
    $starttime =~ s/\://g;
    my $start  = $startdate . $starttime;
    my $report = $input->param('report');
    if ($report) {
        my $saved_report;
        my $report_id = int($report);
        if ($report_id) {
            $saved_report = Koha::Reports->find($report_id);
        }
        if ( !$saved_report ) {
            $report = undef;
        }
    }
    my $format = $input->param('format');
    if ($format) {
        unless ( $format eq 'text' || $format eq 'csv' || $format eq 'html' ) {
            $format = undef;
        }
    }
    my $email = $input->param('email');
    if ($email) {
        my $is_valid = Koha::Email->is_valid($email);
        if ( !$is_valid ) {
            $email = undef;
        }
    }
    if ( $report && $format && $email ) {

        #NOTE: Escape any single quotes in email since we're wrapping it in single quotes in bash
        $email =~ s/'/'"'"'/g;
        my $command =
              "export KOHA_CONF=\"$CONFIG_NAME\"; "
            . "$base/cronjobs/runreport.pl $report --format=$format --to='$email'";

        unless ( add_at_job( $start, $command ) ) {
            $template->param( job_add_failed => 1 );
        }
    }
    else {
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
output_html_with_http_headers $input, $cookie, $template->output;
