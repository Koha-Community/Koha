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
use C4::Output;
use CGI;
use C4::Search;
use C4::Accounts2;
use C4::Stats;
use HTML::Template;

my $input=new CGI;

#print $input->header;
my $bornum=$input->param('bornum');
if ($bornum eq ''){
	$bornum=$input->param('bornum0');
}
#get borrower details
my $data=borrdata('',$bornum);
my $user=$input->remote_user;

#get account details
my %bor;
$bor{'borrowernumber'}=$bornum;


my @names=$input->param;
my %inp;
my $check=0;
for (my $i=0;$i<@names;$i++){
	my$temp=$input->param($names[$i]);
	if ($temp eq 'wo'){
		$inp{$names[$i]}=$temp;
		$check=1;
	}
	if ($temp eq 'yes'){
		$user=~ s/Levin/C/i;
		$user=~ s/Foxton/F/i;
		$user=~ s/Shannon/S/i;
		my $amount=$input->param($names[$i+4]);
		my $bornum=$input->param($names[$i+5]);
		my $accountno=$input->param($names[$i+6]);
		makepayment($bornum,$accountno,$amount,$user);
		$check=2;
	}
}
my %env;
    $user=~ s/Levin/C/i;
    $user=~ s/Foxton/F/i;
    $user=~ s/Shannon/S/i;

$env{'branchcode'}=$user;
my $total=$input->param('total');
if ($check ==0){
	my($template, $loggedinuser, $cookie)
		= get_template_and_user ({ template_name => "members/pay.tmpl",
					   query => $input,
					   type => "intranet",
					   authnotrequired => 0,
					   flagsrequired => {borrowers => 1},
					   debug => 1,
					 });
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
			$line{amount} = $accts->[$i]{'amount'};
			$line{amountoutstanding} = $accts->[$i]{'amountoutstanding'};
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
							total => $total);
	print "Content-Type: text/html\n\n", $template->output;

} else {
#  my $quety=$input->query_string;
#  print $input->redirect("/cgi-bin/koha/sec/writeoff.pl?$quety");
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
		if ($accounttype eq 'Res'){
			my $accountno=$input->param("accountno$value");
			writeoff($bornum,$accountno,$itemno,$accounttype,$amount);
		} else {
			writeoff($bornum,'',$itemno,$accounttype,$amount);
		}
	}
	$bornum=$input->param('bornum');
	print $input->redirect("/cgi-bin/koha/pay.pl?bornum=$bornum");
}


sub writeoff{
	my ($bornum,$accountnum,$itemnum,$accounttype,$amount)=@_;
	my $user=$input->remote_user;
	$user=~ s/Levin/C/;
	$user=~ s/Foxton/F/;
	$user=~ s/Shannon/S/;
	my $dbh = C4::Context->dbh;
	my $env;
	my $query="Update accountlines set amountoutstanding=0 where ";
	if ($accounttype eq 'Res'){
		$query.="accounttype='Res' and accountno='$accountnum' and borrowernumber='$bornum'";
	} else {
		$query.="accounttype='$accounttype' and itemnumber='$itemnum' and borrowernumber='$bornum'";
	}
	my $sth=$dbh->prepare($query);
	#  print $query;
	$sth->execute;
	$sth->finish;
	$query="select max(accountno) from accountlines";
	$sth=$dbh->prepare($query);
	$sth->execute;
	my $account=$sth->fetchrow_hashref;
	$sth->finish;
	$account->{'max(accountno)'}++;
	$query="insert into accountlines (borrowernumber,accountno,itemnumber,date,amount,description,accounttype)
						values ('$bornum','$account->{'max(accountno)'}','$itemnum',now(),'$amount','Writeoff','W')";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	#  print $query;
	UpdateStats($env,$user,'writeoff',$amount,'','','',$bornum);
}

# Local Variables:
# tab-width: 4
# End:
