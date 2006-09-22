#!/usr/bin/perl
# WARNING: Not enough context to figure out the correct tabstop size
# WARNING: Assume that this file uses 4-character tabs

# $Id$

#written 11/1/2000 by chris@katipo.oc.nz
#part of the koha library system, script to facilitate paying off fines


# Copyright 2000-2002 Katipo Communications
#
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

use strict;
use C4::Context;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use C4::Accounts2;
use C4::Stats;
use C4::Members;

my $input=new CGI;
my ($template, $loggedinuser, $cookie)
		= get_template_and_user ({ template_name => "members/pay.tmpl",
					   query => $input,
					   type => "intranet",
					   authnotrequired => 0,
					   flagsrequired => {borrowers => 1},
					   debug => 1,
					 });

my $bornum=$input->param('bornum');
if ($bornum eq ''){
	$bornum=$input->param('bornum0');
}
#get borrower details
my $data=borrdata('',$bornum);
my $user=C4::Context->preference('defaultBranch');
my $me=borrdata('',$loggedinuser);
my $accountant=$me->{'firstname'}.' '.$me->{'surname'};
#get account details
my %bor;
$bor{'borrowernumber'}=$bornum;

my @names=$input->param;
my %inp;
my $check=0;
my $type;
my $totalamount;
my $totaldesc;
my $totalaccounttype;

for (my $i=0;$i<@names;$i++){
	my$temp=$input->param($names[$i]);
	if ($temp eq 'wo'){
		$type="W";
		$check=2;
	}
if ($temp eq 'yes'){
		$type="Pay";
		$check=2;
	}
	if ($temp eq 'yes' || $temp eq 'wo'){
		
		my $desc=$input->param($names[$i+7]);
		my $accounttype=$input->param($names[$i+2]);
		my $amount=$input->param($names[$i+4]);
		my $bornum=$input->param($names[$i+5]);
		my $accountno=$input->param($names[$i+6]);
		my $amounttopay=$input->param($names[$i+8]);

		makepayment($bornum,$accountno,$amounttopay,$accountant, $type);
		$totalamount=$totalamount+$amounttopay;
		$totaldesc .="<br> ".$desc."-  Fee:".$amounttopay;
		$totalaccounttype .="<br> ".$accounttype;
		$check=2;
	}
}
if ($type eq "Pay" || $type eq "W"){
print $input->redirect("/cgi-bin/koha/members/payprint.pl?bornum=$bornum&accounttype=$totalaccounttype&amount=$totalamount&desc=$totaldesc");
}
my %env;
   

$env{'branchcode'}=C4::Context->preference('defaultBranch');
my $total=$input->param('total');
if ($check ==0){
	
	if ($total ne ''){
		recordpayment(\%env,$bornum,$total);
	}
	my ($numaccts,$accts,$total)=getboracctrecord('',\%bor);

	my @loop_pay;
	for (my $i=0;$i<$numaccts;$i++){
		if ($accts->[$i]{'amountoutstanding'} > 0){
			$accts->[$i]{'amount'}+=0.00;
			$accts->[$i]{'amountoutstanding'}+=0.00;
			my %line;
			$line{i}=$i;
			$line{itemnumber} = $accts->[$i]{'itemnumber'};
			$line{accounttype} = $accts->[$i]{'accounttype'};
			$line{amount} = sprintf("%.2f",$accts->[$i]{'amount'});
			$line{amountoutstanding} = sprintf("%.2f",$accts->[$i]{'amountoutstanding'});
			$line{bornum} = $bornum;
			$line{accountno} = $accts->[$i]{'accountno'};
			$line{description} = $accts->[$i]{'description'};
			$line{title} = $accts->[$i]{'title'};
			push(@loop_pay, \%line);
		}
	}
	$template->param(firstname => $data->{'firstname'},
							surname => $data->{'surname'},
							bornum => $bornum,
							loop_pay => \@loop_pay,
							total => sprintf("%.2f",$total),
							totalamountopay => sprintf("%.2f",$total));
output_html_with_http_headers $input, $cookie, $template->output;

} else {
	my%inp;
	my @name=$input->param;
	for (my $i=0;$i<@name;$i++){
		my $test=$input->param($name[$i]);
		if ($test eq 'wo'){
		my $temp=$name[$i];
		$temp=~ s/payfine//;
		$inp{$name[$i]}=$temp;
		}
	}
	my $bornum;
	while ( my ($key, $value) = each %inp){
		#  print $key,$value;
		my $accounttype=$input->param("accounttype$value");
		$bornum=$input->param("bornum$value");
		my $itemno=$input->param("itemnumber$value");
		my $amount=$input->param("amount$value");
		
	}
	$bornum=$input->param('bornum');
	print $input->redirect("/cgi-bin/koha/members/pay.pl?bornum=$bornum");
}




# Local Variables:
# tab-width: 4
# End:
