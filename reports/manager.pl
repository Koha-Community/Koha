#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Circulation;


my $input = new CGI;
my $report_name=$input->param("report_name");
my $do_it=$input->param('do_it');
my $fullreportname = "reports/".$report_name.".tt";
my @values = $input->param("value");
my ($template, $borrowernumber, $cookie)
	= get_template_and_user({template_name => $fullreportname,
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {reports => '*'},
				debug => 1,
				});
$template->param(do_it => $do_it,
		report_name => $report_name,
		);
my $cgidir = C4::Context->config('intranetdir')."/cgi-bin/reports/";
unless (-r $cgidir and -d $cgidir) {
	$cgidir = C4::Context->intranetdir."/reports/";
} 
my $plugin = $cgidir.$report_name.".plugin";
require $plugin;
if ($do_it) {
	my $results = calculate(\@values);
	$template->param(mainloop => $results);
} else {
	$template = set_parameters($template);
}
output_html_with_http_headers $input, $cookie, $template->output;
