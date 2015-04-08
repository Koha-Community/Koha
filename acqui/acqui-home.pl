#!/usr/bin/perl

# Copyright 2008 - 2009 BibLibre SARL
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

=head1 NAME

acqui-home.pl

=head1 DESCRIPTION

this script is the main page for acqui

=cut

use strict;
use warnings;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Acquisition;
use C4::Budgets;
use C4::Members;
use C4::Branch;
use C4::Debug;
use C4::Suggestions;

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {   template_name   => 'acqui/acqui-home.tt',
        query           => $query,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

my $user = GetMember( 'borrowernumber' => $loggedinuser );
my $branchname = GetBranchName($user->{branchcode});

my $status           = $query->param('status') || "ASKED";
my $suggestions_count       = CountSuggestion($status);

my $budget_arr = GetBudgetHierarchy;

my $total      = 0;
my $totspent   = 0;
my $totordered = 0;
my $totcomtd   = 0;
my $totavail   = 0;

my $total_active        = 0;
my $totspent_active     = 0;
my $totordered_active   = 0;
my $totavail_active     = 0;

my @budget_loop;
foreach my $budget ( @{$budget_arr} ) {
    next unless (CanUserUseBudget($loggedinuser, $budget, $userflags));

    $budget->{'budget_branchname'} =
      GetBranchName( $budget->{'budget_branchcode'} );

    my $member = GetMember( borrowernumber => $budget->{budget_owner_id} );
    if ($member) {
        $budget->{budget_owner_firstname} = $member->{'firstname'};
        $budget->{budget_owner_surname} = $member->{'surname'};
        $budget->{budget_owner_borrowernumber} = $member->{'borrowernumber'};
    }

    if ( !defined $budget->{budget_amount} ) {
        $budget->{budget_amount} = 0;
    }

    $budget->{'budget_ordered'} = GetBudgetOrdered( $budget->{'budget_id'} );
    $budget->{'budget_spent'}   = GetBudgetSpent( $budget->{'budget_id'} );
    if ( !defined $budget->{budget_spent} ) {
        $budget->{budget_spent} = 0;
    }
    if ( !defined $budget->{budget_ordered} ) {
        $budget->{budget_ordered} = 0;
    }
    $budget->{'budget_avail'} =
      $budget->{'budget_amount'} - ( $budget->{'budget_spent'} + $budget->{'budget_ordered'} );

    $total      += $budget->{'budget_amount'};
    $totspent   += $budget->{'budget_spent'};
    $totordered += $budget->{'budget_ordered'};
    $totavail   += $budget->{'budget_avail'};

    if ($budget->{budget_period_active}){
	$total_active      += $budget->{'budget_amount'};
	$totspent_active   += $budget->{'budget_spent'};
	$totordered_active += $budget->{'budget_ordered'};
	$totavail_active   += $budget->{'budget_avail'};    
    }

    push @budget_loop, $budget;
}

$template->param(
    type          => 'intranet',
    loop_budget   => \@budget_loop,
    branchname    => $branchname,
    total         => $total,
    totspent      => $totspent,
    totordered    => $totordered,
    totcomtd      => $totcomtd,
    totavail      => $totavail,
    total_active  => $total_active,
    totspent_active     => $totspent_active,
    totordered_active   => $totordered_active,
    totavail_active     => $totavail_active,
    suggestions_count   => $suggestions_count,
);

output_html_with_http_headers $query, $cookie, $template->output;
