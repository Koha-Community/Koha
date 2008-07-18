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
use warnings;
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
my ($template, $loggedinuser, $cookie) = get_template_and_user({
	template_name => "acqui/lateorders.tmpl",
	query => $input,
	 type => "intranet",
	authnotrequired => 0,
	  flagsrequired => {acquisition => 1},
	debug => 1,
});

my $supplierid = $input->param('supplierid') || undef; # we don't want "" or 0
my $delay      = $input->param('delay');
my $branch     = $input->param('branch');
my $op         = $input->param('op');

my @errors = ();
$delay = 30 unless defined $delay;
unless ($delay =~ /^\d{1,3}$/) {
	push @errors, {delay_digits => 1, bad_delay => $delay};
	$delay = 30;	#default value for delay
}

my %supplierlist = GetBooksellersWithLateOrders($delay,$branch);
my (@sloopy);	# supplier loop
foreach (keys %supplierlist){
	push @sloopy, (($supplierid and $supplierid eq $_ )            ? 
					{id=>$_, name=>$supplierlist{$_}, selected=>1} :
					{id=>$_, name=>$supplierlist{$_}} )            ;
}
$template->param(SUPPLIER_LOOP => \@sloopy);
$template->param(Supplier=>$supplierlist{$supplierid}) if ($supplierid);

my @lateorders = GetLateOrders($delay,$supplierid,$branch);

my $total;
foreach (@lateorders){
	$total += $_->{subtotal};
}

my @letters;
my $letters=GetLetters("claimacquisition");
foreach (keys %$letters){
	push @letters, {code=>$_,name=>$letters->{$_}};
}
$template->param(letters=>\@letters) if (@letters);

if ($op and $op eq "send_alert"){
	my @ordernums = $input->param("claim_for");									# FIXME: Fallback values?
	SendAlerts('claimacquisition',\@ordernums,$input->param("letter_code"));	# FIXME: Fallback value?
}

$template->param(ERROR_LOOP => \@errors) if (@errors);
$template->param(
	lateorders => \@lateorders,
	delay => $delay,
	total => $total,
	intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
);
output_html_with_http_headers $input, $cookie, $template->output;
