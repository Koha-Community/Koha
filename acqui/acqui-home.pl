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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA



=head1 NAME

acqui-home.pl

=head1 DESCRIPTION

this script is the main page for acqui/
It presents the budget's dashboard, another table about differents currency with
their rates and the pending suggestions.

=head1 CGI PARAMETERS

=over 4

=item $status
C<$status> is the status a suggestion could has. Default value is 'ASKED'.
thus, it can be REJECTED, ACCEPTED, ORDERED, ASKED, AVAIBLE

=back

=cut

use strict;
use warnings;
use Number::Format;

use CGI;
use C4::Auth;
use C4::Output;
use C4::Suggestions;
use C4::Acquisition;
use C4::Budgets;
use C4::Members;
use C4::Branch;
use C4::Debug;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/acqui-home.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => "*" },
        debug           => 1,
    }
);

# budget
warn("LOGGED=$loggedinuser");
my $borrower= GetMember('borrowernumber' => $loggedinuser);
my ( $flags, $homebranch )= ($borrower->{'flags'},$borrower->{'branchcode'});

my @results = GetBudgets($homebranch);
my $count = scalar @results;
my $branchname = GetBranchName($homebranch);

#my $count = scalar @results;
my $classlist   = '';
my $total       = 0;
my $totspent    = 0;
my $totordered  = 0;
my $totcomtd    = 0;
my $totavail    = 0;
my @loop_budget = ();

# ---------------------------------------------------
# currencies
my $cur;
my @rates = GetCurrencies();
$count = scalar @rates;

my $active_currency = GetCurrency;
my $num;

my $cur_format = C4::Context->preference("CurrencyFormat");
if ( $cur_format eq 'FR' ) {
    $num = new Number::Format(
        'decimal_fill'      => '2',
        'decimal_point'     => ',',
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ' ',
        'thousands_sep'     => ' ',
        'mon_decimal_point' => ','
    );
} else {  # US by default..
    $num = new Number::Format(
        'int_curr_symbol'   => '',
        'mon_thousands_sep' => ',',
        'mon_decimal_point' => '.'
    );
}

my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currency}        = $rates[$i]->{'currency'} ;
    $line{currency_symbol} = $rates[$i]->{'symbol'};
    $line{rate}            = sprintf ( '%.2f',  $rates[$i]->{'rate'} );
    push @loop_currency, \%line;
}

# suggestions
my $status           = $query->param('status') || "ASKED";
my $suggestion       = CountSuggestion($status);
my $suggestions_loop = &SearchSuggestion( {STATUS=> $status} );
# ---------------------------------------------------
# number format
my $period            = GetBudgetPeriod;
my $budget_period_id  = $period->{budget_period_id};
my $budget_branchcode = $period->{budget_branchcode};
my $moo               = GetBudgetHierarchy('',$homebranch, $template->{param_map}->{'USER_INFO'}[0]->{'borrowernumber'} );
@results           = @$moo;
my $period_total      = 0;
my $toggle            = 0;
my @loop;

foreach my $result (@results) {
    # only get top-level budgets for display
    #         warn  $result->{'budget_branchcode'};

    $period_total += $result->{'budget_amount'};

    my $a = $result->{'budget_code_indent'};
    $a =~ s/\ /\&nbsp\;/g;
    $result->{'budget_code_indent'} = $a;

    my $r = GetBranchName( $result->{'budget_owner_id'} );
    $result->{'budget_branchname'} = GetBranchName( $result->{'budget_branchcode'} );

    my $member      = GetMember( borrowernumber => $result->{budget_owner_id} );
    my $member_full = $member->{'firstname'} . ' ' . $member->{'surname'} if $member;

    $result->{'budget_owner'}   = $member_full;
    $result->{'budget_ordered'} = GetBudgetOrdered( $result->{'budget_id'} );
    $result->{'budget_spent'}   = GetBudgetSpent( $result->{'budget_id'} );
    $result->{'budget_avail'}   = $result->{'budget_amount'} - $result->{'budget_spent'} - $result->{'budget_ordered'};

    $total      += $result->{'budget_amount'};
    $totspent   += $result->{'budget_spent'};
    $totordered += $result->{'budget_ordered'};
    $totavail   += $result->{'budget_avail'};

    $result->{'budget_amount'}  = $num->format_price( $result->{'budget_amount'} );
    $result->{'budget_spent'}   = $num->format_price( $result->{'budget_spent'} );
    $result->{'budget_ordered'} = $num->format_price( $result->{'budget_ordered'} );
    $result->{'budget_avail'}   = $num->format_price( $result->{'budget_avail'} );

    #        my $spent_percent = ( $result->{'budget_spent'} / $result->{'budget_amount'} ) * 100;
    #        $result->{'budget_spent_percent'} = sprintf( "%00d", $spent_percent );

    if ($member) {
        $result->{budget_owner_name} = $member->{'firstname'} . ' ' . $member->{'surname'};
    }

    push( @loop_budget, { %{$result}, toggle => $toggle++ % 2, } );
}

$template->param(
    classlist     => $classlist,
    type          => 'intranet',
    loop_budget   => \@loop_budget,
    loop_currency => \@loop_currency,
    active_symbol => $active_currency->{'symbol'},
    branchname    => $branchname,
    budget        => $period->{budget_name},
    total         => $num->format_price(  $total ),
    totspent      => $num->format_price( $totspent ),
    totordered    => $num->format_price( $totordered ),
    totcomtd      => $num->format_price( $totcomtd ),
    totavail      => $num->format_price( $totavail ),
    suggestion    => $suggestion,
);

output_html_with_http_headers $query, $cookie, $template->output;
