#!/usr/bin/perl

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

use CGI;
use C4::Auth;
use C4::Output;

use C4::Circulation;    # GetBiblioIssues
use C4::Biblio;    # GetBiblio GetBiblioFromItemNumber
use C4::Dates qw/format_date/;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/issuehistory.tmpl",
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
	my (undef,@biblio)=GetBiblio($biblionumber);
	my $total  = scalar @$issues;
	$template->param(
		%{$biblio[0]},
	);
} 
foreach (@$issues){
	$_->{date_due}   = format_date($_->{date_due});
	$_->{issuedate}  = format_date($_->{issuedate});
	$_->{returndate} = format_date($_->{returndate});
}
$template->param(
    total        => scalar @$issues,
    issues       => $issues,
	issuehistoryview => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;
