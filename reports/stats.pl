#!/usr/bin/perl

# $Id$

#written 14/1/2000
#script to display reports


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
use CGI;
use C4::Output;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use Date::Manip;
use C4::Stats;

my $input=new CGI;
my $time=$input->param('time');
my $date=$input->param('from');
my $date2=$input->param('to');
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "stats.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });



my @payments=TotalPaid($date,$date2);
my $count=@payments;
my $total=0;
my $oldtime;
my $totalw=0;
my @loop;
my %row;
my $i=0;
while ($i<$count){
#	warn " pay : ".$payments[$i]{'timestamp'};
	my $time=$payments[$i]{'datetime'};
	my $payments=$payments[$i]{'value'};
	my $charge=0;
	my @temp=split(/ /,$payments[$i]{'datetime'});
	my $date=$payments[$i]{'date'};

	my @charges=getcharges($payments[$i]{'borrowernumber'},$payments[$i]{'date'});
	my $count2=@charges;
warn "$count2";
	my $temptotalf=0;
	my $temptotalr=0;
	my $temptotalres=0;
	my $temptotalren=0;
	my $temptotalw=0;
	for (my $i2=0;$i2<$count2;$i2++){
		$charge+=$charges[$i2]->{'amount'};
		%row = ( name   => $charges[$i2]->{'description'},
					type   => $charges[$i2]->{'accounttype'},
					time   => $charges[$i2]->{'timestamp'},
					amount => $charges[$i2]->{'amount'},
					branch => $charges[$i2]->{'amountoutstanding'} );
		push(@loop, \%row);
		if ($payments[$i]{'accountytpe'} ne 'W'){
			if ($charges[$i2]->{'accounttype'} eq 'Rent'){
				$temptotalr+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
			}
			if ($charges[$i2]->{'accounttype'} eq 'F' || $charges[$i2]->{'accounttype'} eq 'FU' || $charges[$i2]->{'accounttype'} eq 'FN' ){
				$temptotalf+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
			}
			if ($charges[$i2]->{'accounttype'} eq 'Res'){
				$temptotalres+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
			}
			if ($charges[$i2]->{'accounttype'} eq 'R'){
			$temptotalren+=$charges[$i2]->{'amount'}-$charges[$i2]->{'amountoutstanding'};
			}
		}
	}
	my $hour=substr($payments[$i]{'timestamp'},8,2);
	my  $min=substr($payments[$i]{'timestamp'},10,2);
	my $sec=substr($payments[$i]{'timestamp'},12,2);
	my $time="$hour:$min:$sec";
	my $time2="$payments[$i]{'date'}";
	my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});
	my $bornum=$payments[$i]{'borrowernumber'};
	my $oldtime=$payments[$i]{'timestamp'};
	my $oldtype=$payments[$i]{'accounttype'};
	while ($bornum eq $payments[$i]{'borrowernumber'} && $oldtype == $payments[$i]{'accounttype'}  && $oldtime eq $payments[$i]{'timestamp'}){
		my $hour=substr($payments[$i]{'timestamp'},8,2);
		my  $min=substr($payments[$i]{'timestamp'},10,2);
		my $sec=substr($payments[$i]{'timestamp'},12,2);
		my $time="$hour:$min:$sec";
		my $time2="$payments[$i]{'date'}";
		my $branch=Getpaidbranch($time2,$payments[$i]{'borrowernumber'});
		if ($payments[$i]{'accounttype'} eq 'W'){
			$totalw+=$payments[$i]{'amount'};
		} else {
			$payments[$i]{'amount'}=$payments[$i]{'amount'}*-1;
			$total+=$payments[$i]{'amount'};
		}

		%row = ( name   => "<b>".$payments[$i]{'firstname'}.$payments[$i]{'surname'} . "</b>",
					type   => $payments[$i]{'accounttype'}, time   => $payments[$i]{'date'},
					amount => $payments[$i]{'amount'}, branch => $branch );
		push(@loop, \%row);
		$oldtype=$payments[$i]{'accounttype'};
		$oldtime=$payments[$i]{'timestamp'};
		$bornum=$payments[$i]{'borrowernumber'};
		$i++;
	}

}

$template->param( loop1   => \@loop,
		  totalw => $totalw,
		  total  => $total );

output_html_with_http_headers $input, $cookie, $template->output;


