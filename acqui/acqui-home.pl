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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

acqui-home.pl

=head1 DESCRIPTION

this script is the main page for acqui

=cut

use Modern::Perl;

use CGI                           qw ( -utf8 );
use C4::Auth                      qw( get_template_and_user );
use C4::Output                    qw( output_html_with_http_headers );
use C4::Budgets                   qw( GetBudgetHierarchy GetBudget CanUserUseBudget );
use C4::Members                   ();
use Koha::Acquisition::Currencies ();
use Koha::Patrons                 ();
use Koha::Suggestions             ();
use Koha::DateUtils               qw( dt_from_string );

my $query = CGI->new;
my ( $template, $loggedinuser, $cookie, $userflags ) = get_template_and_user(
    {
        template_name => 'acqui/acqui-home.tt',
        query         => $query,
        type          => 'intranet',
        flagsrequired => { acquisition => '*' },
    }
);

my $status = $query->param('status') || "ASKED";

# Get current branch count and total viewable count, if they don't match then pass
# both to template
if ( C4::Context->only_my_library ) {
    my $local_pendingsuggestions_count = Koha::Suggestions->search(
        { status => "ASKED", branchcode => C4::Context->userenv()->{'branch'}, archived => 0 } )->count();
    $template->param( suggestions_count => $local_pendingsuggestions_count );
} else {
    my $pendingsuggestions = Koha::Suggestions->search( { status => "ASKED", archived => 0 } );
    my $local_pendingsuggestions_count =
        $pendingsuggestions->search( { 'me.branchcode' => C4::Context->userenv()->{'branch'} } )->count();
    my $pendingsuggestions_count = $pendingsuggestions->count();
    $template->param(
        all_pendingsuggestions => $pendingsuggestions_count != $local_pendingsuggestions_count
        ? $pendingsuggestions_count
        : 0,
        suggestions_count => $local_pendingsuggestions_count
    );
}

my $budget_arr = GetBudgetHierarchy;

my $total      = 0;
my $totspent   = 0;
my $totordered = 0;
my $totcomtd   = 0;
my $totavail   = 0;

my $total_active      = 0;
my $totspent_active   = 0;
my $totordered_active = 0;
my $totavail_active   = 0;

my @budget_loop;
my %patrons        = ( $loggedinuser => Koha::Patrons->find($loggedinuser) );
my $loggedinpatron = $patrons{$loggedinuser}->unblessed;
foreach my $budget ( @{$budget_arr} ) {
    next unless ( CanUserUseBudget( $loggedinpatron, $budget, $userflags ) );

    if ( my $borrowernumber = $budget->{budget_owner_id} ) {
        unless ( exists $patrons{$borrowernumber} ) {
            $patrons{$borrowernumber} = Koha::Patrons->find($borrowernumber);
        }
        $budget->{budget_owner} = $patrons{$borrowernumber};
    }

    if ( !defined $budget->{budget_amount} ) {
        $budget->{budget_amount} = 0;
    }
    if ( !defined $budget->{budget_spent} ) {
        $budget->{budget_spent} = 0;
    }
    if ( !defined $budget->{budget_ordered} ) {
        $budget->{budget_ordered} = 0;
    }
    $budget->{'budget_avail'} =
        $budget->{'budget_amount'} - ( $budget->{'budget_spent'} + $budget->{'budget_ordered'} );
    $budget->{'total_avail'} =
        $budget->{'budget_amount'} - ( $budget->{'total_spent'} + $budget->{'total_ordered'} );

    $total      += $budget->{'budget_amount'};
    $totspent   += $budget->{'budget_spent'};
    $totordered += $budget->{'budget_ordered'};
    $totavail   += $budget->{'budget_avail'};

    if ( $budget->{budget_period_active} ) {
        $total_active      += $budget->{'budget_amount'};
        $totspent_active   += $budget->{'budget_spent'};
        $totordered_active += $budget->{'budget_ordered'};
        $totavail_active   += $budget->{'budget_avail'};
    }

    push @budget_loop, $budget;
}

my $filters;
$filters->{from_placed_on} = my $from_placed_on = dt_from_string;
$filters->{to_placed_on}   = my $to_placed_on   = dt_from_string;
$filters->{from_placed_on}->set_time_zone('floating')->subtract( years => 1 );

my $budgetperiods = C4::Budgets::GetBudgetPeriods;
my $bp_loop       = $budgetperiods;
for my $bp ( @{$budgetperiods} ) {
    my $hierarchy = C4::Budgets::GetBudgetHierarchy( $$bp{budget_period_id}, undef, undef, 1 );
    for my $budget ( @{$hierarchy} ) {
        $$budget{budget_display_name} = sprintf( "%s", ">" x $$budget{budget_level} . $$budget{budget_name} );
    }
    $$bp{hierarchy} = $hierarchy;
}

$template->param(
    type              => 'intranet',
    loop_budget       => \@budget_loop,
    bp_loop           => $bp_loop,
    total             => $total,
    totspent          => $totspent,
    totordered        => $totordered,
    totcomtd          => $totcomtd,
    totavail          => $totavail,
    total_active      => $total_active,
    totspent_active   => $totspent_active,
    totordered_active => $totordered_active,
    totavail_active   => $totavail_active,
    filters           => $filters,
);

my $cur = Koha::Acquisition::Currencies->get_active;
if ($cur) {
    $template->param(
        currency => $cur->currency,
    );
}

output_html_with_http_headers $query, $cookie, $template->output;
