#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Bull;
use C4::Acquisition;
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

my ($nothing,@supplierinfo)=bookseller($supplierid) if $supplierid;

foreach my $supplierid (keys %supplierlist){
        my ($count, @dummy) = GetLateIssues($supplierid);
        my ($count2, @dummy2) = GetMissingIssues($supplierid);
        my $counting = $count+$count2;
        $supplierlist{$supplierid} = $supplierlist{$supplierid}." ($counting)";
	push @select_supplier, $supplierid
}

my ($count, @lateissues) = GetLateIssues($supplierid);
my ($count2, @missingissues) = GetMissingIssues($supplierid);


my $CGIsupplier=CGI::scrolling_list( -name     => 'supplierid',
			-values   => \@select_supplier,
			-default  => $supplierid,
			-labels   => \%supplierlist,
			-size     => 1,
			-multiple => 0 );


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
	lateissues => \@lateissues,
        missingissues => \@missingissues,
        supplierid => $supplierid,
	phone => $supplierinfo[0]->{phone},
	booksellerfax => $supplierinfo[0]->{booksellerfax},
	contemail => $supplierinfo[0]->{contemail},
	intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
	);
output_html_with_http_headers $query, $cookie, $template->output;
