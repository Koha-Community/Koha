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

# $Id$

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
# my @subscriptions = GetSubscriptions($title,$ISSN);

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
			-tabindex=>'',
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
my $CGIbranch=CGI::scrolling_list( -name     => 'branch',
				-values   => \@select_branches,
				-labels   => \%select_branches,
				-size     => 1,
 				-tabindex=>'',
				-multiple => 0 );

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
	intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
	);
output_html_with_http_headers $query, $cookie, $template->output;
