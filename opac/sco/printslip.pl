#!/usr/bin/perl

# Copyright 2012 ByWater Solutions
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

=head1 printslip.pl

Script to allow SCO patrons to print a receipt for their checkout.

It is called from sco-main.pl

=cut


use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Auth qw/:DEFAULT get_session/;
use C4::Output;
use C4::Members;
use C4::Koha;

my $input = new CGI;
my $sessionID = $input->cookie("CGISESSID");
my $session = get_session($sessionID);

my $print = $input->param('print');
my $error = $input->param('error');

# patrons still need to be able to print receipts
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "/sco/printslip.tt",
        query           => $input,
        type            => "opac",
    }
);

my $borrowernumber = $input->param('borrowernumber');
my $branch=C4::Context->userenv->{'branch'};
my ($slip, $is_html);
if (my $letter = IssueSlip ($session->param('branch') || $branch, $borrowernumber, $print eq "qslip")) {
    $slip = $letter->{content};
    $is_html = $letter->{is_html};
}

$template->{VARS}->{slip} = $slip;
$template->{VARS}->{plain} = !$is_html;
$template->{VARS}->{borrowernumber} = $borrowernumber;
$template->{VARS}->{stylesheet} = C4::Context->preference("SlipCSS");
$template->{VARS}->{error} = $error;

output_html_with_http_headers $input, $cookie, $template->output;
