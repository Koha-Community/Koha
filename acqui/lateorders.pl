#!/usr/bin/perl

use strict;
use CGI;
use C4::Acquisition;
use C4::Auth;
use C4::Koha;
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

my $branches = getbranches;
my @branchloop;
foreach my $thisbranch (sort keys %$branches) {
	my %row =(value => $thisbranch,
				branchname => $branches->{$thisbranch}->{'branchname'},
			);
	push @branchloop, \%row;
}

my ($count, @lateorders) = getlateorders($delay,$supplierid,$branch);
my $total;
foreach my $lateorder (@lateorders){
	$total+=$lateorder->{subtotal};
}
$template->param(delay=>$delay) if ($delay);
$template->param(
	branchloop => \@branchloop,
	CGIsupplier => $CGIsupplier,
	lateorders => \@lateorders,
	total=>$total,
	);
output_html_with_http_headers $query, $cookie, $template->output;
