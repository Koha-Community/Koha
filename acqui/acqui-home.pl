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
use CGI;
use C4::Auth;
use C4::Output;

use C4::Suggestions;

use C4::Acquisition;
use C4::Bookfund;
use C4::Members;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/acqui-home.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

# budget
my $borrower= GetMember($loggedinuser);
my ( $flags, $homebranch )= ($borrower->{'flags'},$borrower->{'branchcode'});

my @results = GetBookFunds($homebranch);
my $count = scalar @results;

my $classlist   = '';
my $total       = 0;
my $totspent    = 0;
my $totcomtd    = 0;
my $totavail    = 0;
my @loop_budget = ();

for (my $i=0; $i<$count; $i++){
	my ($spent,$comtd)=GetBookFundBreakdown($results[$i]->{'bookfundid'},$results[$i]->{'startdate'},$results[$i]->{'enddate'});
	my $avail=$results[$i]->{'budgetamount'}-($spent+$comtd);
	my %line;
	$line{bookfundname} = $results[$i]->{'bookfundname'};
	$line{budgetamount} = $results[$i]->{'budgetamount'};
	$line{aqbudgetid} = $results[$i]->{'aqbudgetid'};
	$line{bookfundid} = $results[$i]->{'bookfundid'};
	$line{sdate} = $results[$i]->{'startdate'};
	$line{edate} = $results[$i]->{'enddate'};
	$line{spent} = sprintf  ("%.2f", $spent);
	$line{comtd} = sprintf  ("%.2f",$comtd);
	$line{avail}  = sprintf  ("%.2f",$avail);
	push @loop_budget, \%line;
	$total+=$results[$i]->{'budgetamount'};
	$totspent+=$spent;
	$totcomtd+=$comtd;
	$totavail+=$avail;
}

# currencies
my @rates = GetCurrencies();
$count = scalar @rates;

my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currency} = $rates[$i]->{'currency'};
    $line{rate}     = $rates[$i]->{'rate'};
    push @loop_currency, \%line;
}

# suggestions
my $status           = $query->param('status') || "ASKED";
my $suggestion       = CountSuggestion($status);
my $suggestions_loop = &SearchSuggestion( '', '', '', '', $status, '' );

$template->param(
    classlist        => $classlist,
    type             => 'intranet',
    loop_budget      => \@loop_budget,
    loop_currency    => \@loop_currency,
    total            => sprintf( "%.2f", $total ),
    suggestion       => $suggestion,
    suggestions_loop => $suggestions_loop,
    totspent         => sprintf( "%.2f", $totspent ),
    totcomtd         => sprintf( "%.2f", $totcomtd ),
    totavail         => sprintf( "%.2f", $totavail ),
    nobudget         => $#results == -1 ? 1 : 0
);

output_html_with_http_headers $query, $cookie, $template->output;
