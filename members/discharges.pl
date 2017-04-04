#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2013 BibLibre
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
use C4::Output;
use C4::Context;
use Koha::Patron::Discharge;

my $input = new CGI;
my $op = $input->param('op') // 'list';

my ( $template, $loggedinuser, $cookie, $flags ) = get_template_and_user({
    template_name   => "members/discharges.tt",
    query           => $input,
    type            => "intranet",
    authnotrequired => 0,
    flagsrequired   => { borrowers => 'edit_borrowers' },
});

my $branchcode =
  ( C4::Context->preference("IndependentBranches")
      and not C4::Context->IsSuperLibrarian() )
  ? C4::Context->userenv()->{'branch'}
  : undef;

if( $op eq 'allow' ) {
    my $borrowernumber = $input->param('borrowernumber');
    Koha::Patron::Discharge::discharge({
        borrowernumber => $borrowernumber
    }) if $borrowernumber;
}

my $pending_discharges = Koha::Patron::Discharge::get_pendings({
    branchcode => $branchcode
});

$template->param( pending_discharges => $pending_discharges );

output_html_with_http_headers $input, $cookie, $template->output;
