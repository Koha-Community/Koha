#!/usr/bin/perl

#written 27/01/2000
#script to display borrowers reading record



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
use C4::Auth;
use C4::Output;
use CGI;
use C4::Search;
use HTML::Template;
my $input=new CGI;


my $bornum=$input->param('bornum');
#get borrower details
my $data=borrdata('',$bornum);
my $order=$input->param('order');
my $order2=$order;
if ($order2 eq ''){
  $order2="date_due desc";
}
my $limit=$input->param('limit');
if ($limit eq 'full'){
  $limit=0;
} else {
  $limit=50;
}
my ($count,$issues)=allissues($bornum,$order2,$limit);

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "members/readingrec.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

my @loop_reading;

for (my $i=0;$i<$count;$i++){
 	my %line;
	$line{title}=$issues->[$i]->{'title'};
	$line{author}=$issues->[$i]->{'author'};
	$line{returndate}=$issues->[$i]->{'returndate'};
	$line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
	push(@loop_reading,\%line);
}
$template->param(title => $data->{'title'},
						initials => $data->{'initials'},
						surname => $data->{'surname'},
						bornum => $bornum,
						limit => $limit,
						loop_reading => \@loop_reading);
print $input->header(-cookie => $cookie),$template->output;



