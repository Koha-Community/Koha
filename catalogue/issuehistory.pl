#!/usr/bin/perl

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
use C4::Output;

use C4::Circulation;    # GetBiblioIssues
use C4::Biblio;    # GetBiblio GetBiblioFromItemNumber
use C4::Search;		# enabled_staff_search_views

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/issuehistory.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => "circulate_remaining_permissions" },
    }
);

# getting cgi params.
my $params = $query->Vars;

my $biblionumber = $params->{'biblionumber'};
my $itemnumber   = $params->{'itemnumber'};

if (C4::Context->preference("HidePatronName")) {
   $template->param(HidePatronName => 1);
}

my ($issues,$biblio,$barcode);
if ($itemnumber){
	$issues=GetItemIssues($itemnumber);
	$biblio=GetBiblioFromItemNumber($itemnumber);
	$biblionumber=$biblio->{biblionumber};
	$barcode=$issues->[0]->{barcode};
	$template->param(
		%$biblio,
		barcode=> $barcode,
	);
} else {
	$issues = GetBiblioIssues($biblionumber);
        my $biblio = GetBiblio($biblionumber);
	my $total  = scalar @$issues;
	$template->param(
               %{$biblio},
	);
} 

$template->param(
    total        => scalar @$issues,
    issues       => $issues,
	issuehistoryview => 1,
	C4::Search::enabled_staff_search_views,
);

output_html_with_http_headers $query, $cookie, $template->output;
