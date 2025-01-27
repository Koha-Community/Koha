#!/usr/bin/perl

# Copyright 2020 Aleisha Amohia <aleisha@catalyst.net.nz>
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

use CGI qw ( -utf8 );
use C4::Context;
use C4::Output qw( output_html_with_http_headers );
use C4::Auth   qw( get_template_and_user );
use Koha::ProblemReports;

my $query = CGI->new;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "tools/problem-reports.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { problem_reports => 1 },
    }
);

my $action = $query->param("op") || 'none';

my @report_ids = $query->multi_param('report_ids');

if ( $action eq 'cud-mark_selected-viewed' ) {
    foreach my $report_id (@report_ids) {
        my $report = Koha::ProblemReports->find($report_id);
        $report->set( { status => 'Viewed' } )->store;
    }
} elsif ( $action eq 'cud-mark_selected-closed' ) {
    foreach my $report_id (@report_ids) {
        my $report = Koha::ProblemReports->find($report_id);
        $report->set( { status => 'Closed' } )->store;
    }

} elsif ( $action eq 'cud-mark_selected-new' ) {
    foreach my $report_id (@report_ids) {
        my $report = Koha::ProblemReports->find($report_id);
        $report->set( { status => 'New' } )->store;
    }
}

my $problem_reports = Koha::ProblemReports->search();
$template->param(
    selected_count  => scalar(@report_ids),
    action          => $action,
    problem_reports => $problem_reports,
);

output_html_with_http_headers $query, $cookie, $template->output;
