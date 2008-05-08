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

lateorders.pl

=head1 DESCRIPTION

this script shows late orders for a specific supplier, branch and delay
given on input arg.

=head1 CGI PARAMETERS

=over 4

=item supplierid
To know on which supplier this script have to display late order.

=item delay
To know the time boundary. Default value is 30 days.

=item branch
To know on which branch this script have to display late order.

=back

=cut

use strict;
use CGI;
use C4::Bookseller;
use C4::Auth;
use C4::Koha;
use C4::Output;
use C4::Context;
use C4::Acquisition;
use C4::Letters;
use C4::Branch; # GetBranches

my $input = new CGI;
my ($template, $loggedinuser, $cookie)
= get_template_and_user(
                {template_name => "acqui/lateorders.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {acquisition => 1},
				debug => 1,
				});

my $supplierid = $input->param('supplierid');
my $delay = $input->param('delay');
my $branch = $input->param('branch');

#default value for delay
$delay = 30 unless $delay;

my %supplierlist = GetBooksellersWithLateOrders($delay,$branch);
my @select_supplier;
push @select_supplier,"";
foreach my $supplierid (keys %supplierlist){
	push @select_supplier, $supplierid;
}

my $CGIsupplier=CGI::scrolling_list( -name     => 'supplierid',
			-values   => \@select_supplier,
			-default  => $supplierid,
			-id        => 'supplierid',
			-labels   => \%supplierlist,
			-size     => 1,
			-tabindex=>'',
			-multiple => 0 );

$template->param(Supplier=>$supplierlist{$supplierid}) if ($supplierid);

my @lateorders = GetLateOrders($delay,$supplierid,$branch);
my $count = scalar @lateorders;

my $total;
foreach my $lateorder (@lateorders){
	$total+=$lateorder->{subtotal};
}

my @letters;
my $letters=GetLetters("claimacquisition");
foreach (keys %$letters){
 push @letters ,{code=>$_,name=>$letters->{$_}};
}

$template->param(letters=>\@letters) if (@letters);
my $op=$input->param("op");
if ($op eq "send_alert"){
  my @ordernums=$input->param("claim_for");
  SendAlerts('claimacquisition',\@ordernums,$input->param("letter_code"));
}

$template->param(delay=>$delay) if ($delay);
$template->param(
	CGIsupplier => $CGIsupplier,
	lateorders => \@lateorders,
	total=>$total,
	intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
	);
output_html_with_http_headers $input, $cookie, $template->output;
