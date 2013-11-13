#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2012 ByWater Solutions
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

use CGI;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Branch;
use C4::Members;
use C4::Suggestions;

my $input = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "members/purchase-suggestions.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);

my $borrowernumber = $input->param('borrowernumber');

# Set informations for the patron
my $borrower = GetMemberDetails( $borrowernumber, 0 );
foreach my $key ( keys %$borrower ) {
    $template->param( $key => $borrower->{$key} );
}
$template->param(
    categoryname => $borrower->{'description'},
    branchname   => GetBranchName( $borrower->{'branchcode'} ),
);

my $suggestions = SearchSuggestion( { suggestedby => $borrowernumber } );

$template->param( suggestions => $suggestions );

output_html_with_http_headers $input, $cookie, $template->output;
