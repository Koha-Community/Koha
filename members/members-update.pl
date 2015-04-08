#!/usr/bin/perl

# Parts Copyright Biblibre 2010
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
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Context;
use C4::Members;
use C4::Branch;
use C4::Category;
use Koha::Borrower::Modifications;

my $query = new CGI;

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user(
    {
        template_name   => "members/members-update.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);

my $branch =
  C4::Context->preference("IndependentBranches")
  && !$flags->{'superlibrarian'}
  ? C4::Context->userenv()->{'branch'}
  : undef;

my $pending_modifications =
  Koha::Borrower::Modifications->GetPendingModifications($branch);

my $borrowers;
foreach my $pm (@$pending_modifications) {
    $borrowers->{ $pm->{'borrowernumber'} } =
      GetMember( borrowernumber => $pm->{'borrowernumber'} );

}

$template->param(
    PendingModifications => $pending_modifications,
    borrowers            => $borrowers,
);

output_html_with_http_headers $query, $cookie, $template->output;
