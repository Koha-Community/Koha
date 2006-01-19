#!/usr/bin/perl

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
use C4::Date;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Search;
use HTML::Template;

sub StringSearch  {
	my ($searchstring)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select surname,firstname from borrowers where (surname like ?) order by surname");
	$sth->execute("$data[0]%");
	my @results;
	my $cnt=0;
	while (my $data=$sth->fetchrow_hashref){
		push(@results,$data);
		$cnt ++;
	}
	$sth->finish;
	return($cnt,\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
defined $searchfield or $searchfield='';
my $distributedto=$input->param('distributedto');
my $subscriptionid = $input->param('subscriptionid');
$searchfield=~ s/\,//g;
my $SaveList=$input->param('SaveList');
my $dbh = C4::Context->dbh;

unless ($distributedto) {
	# read the previous distributedto
	my $sth = $dbh->prepare('select distributedto from subscription where subscriptionid=?');
	$sth->execute($subscriptionid);
	($distributedto) = $sth->fetchrow;
}

if ($SaveList) {
	my $sth = $dbh->prepare("update subscription set distributedto=? where subscriptionid=?");
	$sth->execute($distributedto,$subscriptionid);
}
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "serials/distributedto.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {cataloguing => 1},
			     debug => 1,
			     });

my $env;
my $count=0;
my $results;
($count,$results)=StringSearch($searchfield) if $searchfield;
my $toggle="0";
my @loop_data =();
for (my $i=0; $i < $count; $i++){
	if ($i % 2){
			$toggle=1;
	} else {
			$toggle=0;
	}
	my %row_data;
	$row_data{toggle} = $toggle;
	$row_data{firstname} = $results->[$i]{'firstname'};
	$row_data{surname} = $results->[$i]{'surname'};
	push(@loop_data, \%row_data);
}
$template->param(borlist => \@loop_data,
				searchfield => $searchfield,
				distributedto => $distributedto,
				SaveList => $SaveList,
				subscriptionid => $subscriptionid,
				);
output_html_with_http_headers $input, $cookie, $template->output;

