#!/usr/bin/perl

#script to administer the aqbudget table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

# ALGO :
# this script use an $op to know what to do.
# if $op is empty or none of the above values,
#	- the default screen is build (with all records, or filtered datas).
#	- the   user can clic on add, modify or delete record.
# if $op=add_form
#	- if primkey exists, this is a modification,so we read the $primkey record
#	- builds the add/modify form
# if $op=add_validate
#	- the user has just send datas, so we create/modify the record
# if $op=delete_form
#	- we show the record having primkey=$primkey and ask for deletion validation form
# if $op=delete_confirm
#	- we delete the record having primkey=$primkey


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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Search;
use HTML::Template;

sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("select bookfundid,bookfundname,bookfundgroup from aqbookfund where (bookfundname like ?) order by bookfundid");
	$sth->execute("%$data[0]%");
	my @results;
	while (my $data=$sth->fetchrow_hashref){
		push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return (scalar(@results),\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/aqbookfund.pl";
my $bookfundid=$input->param('bookfundid');
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/aqbookfund.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

if ($op) {
$template->param(script_name => $script_name,
		$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
		else              => 1); # we show only the TMPL_VAR names $op
}
$template->param(action => $script_name);


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	my $header;
	if ($bookfundid) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select bookfundid,bookfundname,bookfundgroup from aqbookfund where bookfundid=?");
		$sth->execute($bookfundid);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	    }
	if ($bookfundid) {
	    $header = "Modify book fund";
	    $template->param('header-is-modify-p' => 1);
	} else {
	    $header = "Add book fund";
	    $template->param('header-is-add-p' => 1);
	}
	$template->param('use-header-flags-p' => 1);
	$template->param(header => $header); # NOTE deprecated
	my $add_or_modify=0;
	if ($bookfundid) {
	    $add_or_modify=1;
	}
	$template->param(add_or_modify => $add_or_modify);
	$template->param(bookfundid =>$bookfundid);
	$template->param(bookfundname =>$data->{'bookfundname'});

													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
        my $dbh = C4::Context->dbh;
	my $bookfundid=uc($input->param('bookfundid'));
	my $sth=$dbh->prepare("delete from aqbookfund where bookfundid =?");
	$sth->execute($bookfundid);
	$sth->finish;
	my $sth=$dbh->prepare("replace aqbookfund (bookfundid,bookfundname) values (?,?)");
	$sth->execute($input->param('bookfundid'),$input->param('bookfundname'));
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=aqbookfund.pl\"></html>";
	exit;
			
										# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select bookfundid,bookfundname,bookfundgroup from aqbookfund where bookfundid=?");
	$sth->execute($bookfundid);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(bookfundid => $bookfundid);
	$template->param(bookfundname => $data->{'bookfundname'});
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $bookfundid=uc($input->param('bookfundid'));
	my $sth=$dbh->prepare("delete from aqbookfund where bookfundid=?");
	$sth->execute($bookfundid);
	$sth->finish;
	$sth=$dbh->prepare("delete from aqbudget where bookfundid=?");
	$sth->execute($bookfundid);
	$sth->finish;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	$template->param(scriptname => $script_name);
	if  ($searchfield ne '') {
		$template->param(search => 1);
		$template->param(searchfield => $searchfield);
	}
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	my @loop_data =();
	my $dbh = C4::Context->dbh;
	my $sth2 = $dbh->prepare("Select aqbudgetid,startdate,enddate,budgetamount from aqbudget where bookfundid = ? order by bookfundid");
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
		my %row_data;
		$row_data{bookfundid} =$results->[$i]{'bookfundid'};
		$row_data{bookfundname} = $results->[$i]{'bookfundname'};
		$sth2->execute($row_data{bookfundid});
		my @budget_loop;
		while (my ($aqbudgetid,$startdate,$enddate,$budgetamount) = $sth2->fetchrow) {
			my %budgetrow_data;
			$budgetrow_data{aqbudgetid} = $aqbudgetid;
			$budgetrow_data{startdate} = $startdate;
			$budgetrow_data{enddate} = $enddate;
			$budgetrow_data{budgetamount} = $budgetamount;
			push @budget_loop,\%budgetrow_data;
		}
		$row_data{budget} = \@budget_loop;
		push @loop_data,\%row_data;
	}
	$template->param(bookfund => \@loop_data);
} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
