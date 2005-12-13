#!/usr/bin/perl

use strict;
use CGI;
use C4::Acquisition;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Context;
use HTML::Template;

my $query = new CGI;
my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "acqui/lateorders.tmpl",
				query => $query,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {acquisition => 1},
				debug => 1,
				});
# my $title = $query->param('title');
# my $ISSN = $query->param('ISSN');
# my @subscriptions = getsubscriptions($title,$ISSN);

my $supplierid = $query->param('supplierid');
my $delay = $query->param('delay');
my $branch = $query->param('branch');

$delay =($delay?$delay:30);

my %supplierlist = getsupplierlistwithlateorders($delay,$branch);
my @select_supplier;
push @select_supplier,"";
foreach my $supplierid (keys %supplierlist){
	push @select_supplier, $supplierid;
}
my $CGIsupplier=CGI::scrolling_list( -name     => 'supplierid',
			-values   => \@select_supplier,
			-default  => $supplierid,
			-labels   => \%supplierlist,
			-size     => 1,
			-multiple => 0 );

$template->param(Supplier=>$supplierlist{$supplierid}) if ($supplierid);

my @select_branches;
my %select_branches;
push @select_branches,"";
$select_branches{""}="";
my ($count, @branches) = branches(); 
#branches is IndependantBranches aware
foreach my $branch (@branches){
	push @select_branches, $branch->{branchcode};
	$select_branches{$branch->{branchcode}}=$branch->{branchname};
}
my $CGIbranch=CGI::scrolling_list( -name     => 'branch',
				-values   => \@select_branches,
				-labels   => \%select_branches,
				-size     => 1,
				-multiple => 0 );

my ($count, @lateorders) = getlateorders($delay,$supplierid,$branch);
my $total;
foreach my $lateorder (@lateorders){
	$total+=$lateorder->{subtotal};
}
$template->param(delay=>$delay) if ($delay);
$template->param(
	CGIbranch => $CGIbranch,
	CGIsupplier => $CGIsupplier,
	lateorders => \@lateorders,
	total=>$total,
	);
output_html_with_http_headers $query, $cookie, $template->output;
