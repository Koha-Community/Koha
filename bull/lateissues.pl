#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Bull;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
# my $title = $query->param('title');
# my $ISSN = $query->param('ISSN');
# my @subscriptions = getsubscriptions($title,$ISSN);

my $supplierid = $query->param('supplierid');
my %supplierlist = getSupplierListWithLateIssues;
my @select_supplier;
push @select_supplier,"";
foreach my $supplierid (keys %supplierlist){
	push @select_supplier, $supplierid
}
my $CGIsupplier=CGI::scrolling_list( -name     => 'supplierid',
			-values   => \@select_supplier,
			-default  => $supplierid,
			-labels   => \%supplierlist,
			-size     => 1,
			-multiple => 0 );

my @lateissues;
@lateissues = GetLateIssues($supplierid) if $supplierid;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "bull/lateissues.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});

$template->param(
	CGIsupplier => $CGIsupplier,
	lateissues => \@lateissues
	);
output_html_with_http_headers $query, $cookie, $template->output;
