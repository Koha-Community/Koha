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
use C4::Date;
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
	my $query="Select aqbudgetid,bookfundid,startdate,enddate,budgetamount from aqbudget where (bookfundid like \"$data[0]%\") order by bookfundid,aqbudgetid";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my @results;
	my $cnt=0;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	$cnt ++;
	}
	#  $sth->execute;
	$sth->finish;
	return ($cnt,\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/aqbudget.pl";
my $bookfundid=$input->param('bookfundid');
my $aqbudgetid=$input->param('aqbudgetid');
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/aqbudget.tmpl",
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
	my $dataaqbudget;
	my $dataaqbookfund;
	if ($aqbudgetid) {
		my $dbh = C4::Context->dbh;
	        my $query="select aqbudgetid,bookfundname,aqbookfund.bookfundid,startdate,enddate,budgetamount from aqbudget,aqbookfund where aqbudgetid='$aqbudgetid' and aqbudget.bookfundid=aqbookfund.bookfundid";
#	        print $query;
		my $sth=$dbh->prepare($query);
		$sth->execute;
		$dataaqbudget=$sth->fetchrow_hashref;
		$sth->finish;
	}
	my $header;
	if ($aqbudgetid) {
		$header = "Modify budget";
	} else {
		$header = "Add budget";
	}
	$template->param(header => $header);
	if ($aqbudgetid) {
	    $template->param(modify => 1);
	    $template->param(bookfundid => $dataaqbudget->{bookfundid});
	    $template->param(bookfundname => $dataaqbudget->{bookfundname});
	} else {
	    $template->param(adding => 1);
	}
	$template->param(dateformat => display_date_format(),
							aqbudgetid => $dataaqbudget->{'aqbudgetid'},
							startdate => format_date($dataaqbudget->{'startdate'}),
							enddate => format_date($dataaqbudget->{'enddate'}),
							budgetamount => $dataaqbudget->{'budgetamount'}
	);
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $query = "replace aqbudget (aqbudgetid,bookfundid,startdate,enddate,budgetamount) values (?,?,?,?,?)";
	my $sth=$dbh->prepare($query);
	$sth->execute($input->param('aqbudgetid'),$input->param('bookfundid'),
						format_date_in_iso($input->param('startdate')),
						format_date_in_iso($input->param('enddate')),
						$input->param('budgetamount')
						);
	$sth->finish;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select aqbudgetid,bookfundid,startdate,enddate,budgetamount from aqbudget where aqbudgetid='$aqbudgetid'");
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(bookfundid => $bookfundid);
	$template->param(aqbudgetid => $data->{'aqbudgetid'});
	$template->param(startdate => format_date($data->{'startdate'}));
	$template->param(enddate => format_date($data->{'enddate'}));
	$template->param(budgetamount => $data->{'budgetamount'});
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $aqbudgetid=uc($input->param('aqbudgetid'));
	my $query = "delete from aqbudget where aqbudgetid='$aqbudgetid'";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	 print $input->redirect("aqbookfund.pl");
	 return;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	if  ($searchfield ne '') {
	        $template->param(search => 1);
		$template->param(searchfield => $searchfield);
	}
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	my @loop_data =();
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
		#find out stats
	#  	my ($od,$issue,$fines)=categdata2($env,$results->[$i]{'borrowernumber'});
	#  	$fines=$fines+0;
	        my $dataaqbookfund;
	        my $dbh = C4::Context->dbh;
	        my $query="select bookfundid,bookfundname from aqbookfund where bookfundid=?";
#	        print $query;
		my $sth=$dbh->prepare($query);
		$sth->execute($results->[$i]{'bookfundid'});
		$dataaqbookfund=$sth->fetchrow_hashref;
		$sth->finish;
	        my @toggle = ();
	        my @bookfundid = ();
		my @bookfundname = ();
	        my @startdate = ();
	        my @enddate = ();
		my @budgetamount = ();
		push(@toggle,$toggle);
		push(@bookfundid,$results->[$i]{'bookfundid'});
		push(@bookfundname,$dataaqbookfund->{'bookfundname'});
		push(@startdate,format_date($results->[$i]{'startdate'}));
		push(@enddate,format_date($results->[$i]{'enddate'}));
		push(@budgetamount,$results->[$i]{'budgetamount'});
	  	if ($toggle eq 'white'){
	    		$toggle="#ffffcc";
	  	} else {
	    		$toggle="white";
	  	}
		while (@toggle and @bookfundid and @bookfundname and @startdate and @enddate and @budgetamount) { 
	   my %row_data;
	   $row_data{toggle} = shift @toggle;
	   $row_data{bookfundid} = shift @bookfundid;
	   $row_data{bookfundname} = shift @bookfundname;
	   $row_data{startdate} = shift @startdate;
	   $row_data{enddate} = shift @enddate;
	   $row_data{budgetamount} = shift @budgetamount;
	   push(@loop_data, \%row_data);
       }
       }
       $template->param(budget => \@loop_data);
} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;

