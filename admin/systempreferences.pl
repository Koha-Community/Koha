#!/usr/bin/perl

#script to administer the systempref table
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
use C4::Context;


sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $query="Select variable,value,explanation from systempreferences where (variable like \"$data[0]%\") order by variable";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my @results;
	my $cnt=0;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	$cnt ++;
	}
	$sth->finish;
	return ($cnt,\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
my $pkfield="variable";
my $reqsel="select variable,value,explanation from systempreferences where $pkfield='$searchfield'";
my $reqdel="delete from systempreferences where $pkfield='$searchfield'";
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/systempreferences.pl";

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/systempreferences.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

if ($op) {
$template->param(script_name => $script_name,
						$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
						else              => 1); # we show only the TMPL_VAR names $op
}
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($searchfield) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select variable,value,explanation from systempreferences where variable='$searchfield'");
		$sth->execute;
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}
	if ($searchfield) {
		$template->param(modify => 1);
	}

	$template->param(explanation => $data->{'explanation'},
			 value => $data->{'value'},
			 searchfield => $searchfield);

################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $query = "replace systempreferences (variable,value,explanation) values (";
	$query.= $dbh->quote($input->param('variable')).",";
	$query.= $dbh->quote($input->param('value')).",";
	$query.= $dbh->quote($input->param('explanation')).")";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare($reqsel);
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(searchfield => $searchfield,
							Tvalue => $data->{'value'},
							);

													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare($reqdel);
	$sth->execute;
	$sth->finish;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	if  ($searchfield ne '') {
		 $template->param(searchfield => "You Searched for <b>$searchfield<b><p>");
	}
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	my @loop_data = ();
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 'white'){
			$toggle="#ffffcc";
	  	} else {
			$toggle="white";
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{variable} = $results->[$i]{'variable'};
		$row_data{value} = $results->[$i]{'value'};
		$row_data{explanation} = $results->[$i]{'explanation'};
		$row_data{edit} = "$script_name?op=add_form&searchfield=".$results->[$i]{'variable'};
		$row_data{delete} = "$script_name?op=delete_confirm&searchfield=".$results->[$i]{'variable'};
		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param("<a href=$script_name?offset=".$prevpage.'&lt;&lt; Prev</a>');
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param("a href=$script_name?offset=".$nextpage.'Next &gt;&gt;</a>');
	}
} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
