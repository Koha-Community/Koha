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
use C4::Context;
use C4::Output;
use C4::Auth;
use C4::Budgets;

=head1 DESCRIPTION

fetches the budget amount fron the DB,
called by aqbudgets.pl and neworderempty.pl

=cut

my $input = new CGI;

my $budget_id     = $input->param('budget_id');
my $new_parent_id = $input->param('new_parent');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "acqui/ajax.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        debug           => 0,
    }
);

my $budget            = GetBudget($budget_id);
my $new_parent_budget = GetBudget($new_parent_id);
my $result            = CheckBudgetParent( $new_parent_budget, $budget );
$template->param( return => $result );

output_html_with_http_headers $input, $cookie, $template->output;
1;
