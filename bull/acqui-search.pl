#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Catalogue;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "bull/search-supply.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {acquisition => 1},
			     debug => 1,
			     });

# budget
my ($count,@results)=bookfunds;
my $classlist='';
my $total=0;
my $totspent=0;
my $totcomtd=0;
my $totavail=0;
my @loop_budget = ();
for (my $i=0;$i<$count;$i++){
	my ($spent,$comtd)=bookfundbreakdown($results[$i]->{'bookfundid'});
	my $avail=$results[$i]->{'budgetamount'}-($spent+$comtd);
	my %line;
	$line{bookfundname} = $results[$i]->{'bookfundname'};
	$line{budgetamount} = $results[$i]->{'budgetamount'};
	$line{spent} = sprintf  ("%.2f", $spent);
	$line{comtd} = sprintf  ("%.2f",$comtd);
	$line{avail}  = sprintf  ("%.2f",$avail);
	push @loop_budget, \%line;
	$total+=$results[$i]->{'budgetamount'};
	$totspent+=$spent;
	$totcomtd+=$comtd;
	$totavail+=$avail;
}
#currencies
my ($count,$rates)=getcurrencies();
my @loop_currency = ();
for (my $i=0;$i<$count;$i++){
	my %line;
	$line{currency} = $rates->[$i]->{'currency'};
	$line{rate} = $rates->[$i]->{'rate'};
	push @loop_currency, \%line;
}
$template->param(classlist => $classlist,
						type => 'intranet',
						loop_budget => \@loop_budget,
						loop_currency => \@loop_currency,
						total => sprintf("%.2f",$total),
						totspent => sprintf("%.2f",$totspent),
						totcomtd => sprintf("%.2f",$totcomtd),
						totavail => sprintf("%.2f",$totavail));

output_html_with_http_headers $query, $cookie, $template->output;
