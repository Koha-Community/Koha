#!/usr/bin/perl

# Copyright 2008 - 2009 BibLibre SARL
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

acqui-home.pl

=head1 DESCRIPTION

this script is the main page for acqui

=cut

use strict;
use warnings;
use Number::Format;

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
    {   template_name   => 'acqui/acqui-home.tmpl',
        query           => $query,
        type            => 'intranet',
        authnotrequired => 0,
        flagsrequired   => { acquisition => '*' },
        debug           => 1,
    }
);

my $user = GetMember( 'borrowernumber' => $loggedinuser );
my $branchname = GetBranchName($user->{branchcode});


my $num_formatter;

my $cur_format = C4::Context->preference("CurrencyFormat");
if ( $cur_format eq 'FR' ) {
    $num_formatter = Number::Format->new(
        'decimal_fill'      => '2',
        'decimal_point'     => ',',
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ' ',
        'thousands_sep'     => ' ',
        'mon_decimal_point' => ','
    );
} else {    # US by default..
    $num_formatter = Number::Format->new(
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ',',
        'mon_decimal_point' => '.'
    );
}

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

    $budget->{budget_code_indent} =~ s/\ /\&nbsp\;/g;

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

    for my $field (qw( budget_amount budget_spent budget_ordered budget_avail ) ) {
        $budget->{"formatted_$field"} = $num_formatter->format_price( $budget->{$field} );
    }

    push @budget_loop, $budget;
}

$template->param(
    type          => 'intranet',
    loop_budget   => \@budget_loop,
    branchname    => $branchname,
    total         => $num_formatter->format_price($total),
    totspent      => $num_formatter->format_price($totspent),
    totordered    => $num_formatter->format_price($totordered),
    totcomtd      => $num_formatter->format_price($totcomtd),
    totavail      => $num_formatter->format_price($totavail),
    total_active  => $num_formatter->format_price($total_active),
    totspent_active     => $num_formatter->format_price($totspent_active),
    totordered_active   => $num_formatter->format_price($totordered_active),
    totavail_active     => $num_formatter->format_price($totavail_active),
    suggestions_count   => $suggestions_count,
);

output_html_with_http_headers $query, $cookie, $template->output;
