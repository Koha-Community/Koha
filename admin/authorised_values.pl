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
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Charset;
use C4::Search;
use HTML::Template;
use C4::Context;


sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $query="Select id,category,authorised_value,lib from authorised_values where (category like \"$data[0]%\") order by category,authorised_value";
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
$searchfield=~ s/\,//g;
my $id = $input->param('id');
my $reqsel="select category,authorised_value,lib from authorised_values where id='$id'";
my $reqdel="delete from authorised_values where id='$id'";
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/authorised_values.pl";
my $dbh = C4::Context->dbh;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/authorised_values.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
my $pagesize=20;
my $op = $input->param('op');

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
	my $data;
	if ($id) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select id,category,authorised_value,lib from authorised_values where id='$id'");
		$sth->execute;
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	} else {
		$data->{'category'} = $input->param('category');
	}
	if ($searchfield) {
		$template->param(action => "Modify authorised value");
	} else {
		$template->param(action => "Add authorised value");
	}
	$template->param(category => $data->{'category'},
							authorised_value => $data->{'authorised_value'},
							lib => $data->{'lib'},
							id => $data->{'id'}
							);
	if ($data->{'category'}) {
		$template->param(category => "<input type=\"hidden\" name=\"category\" value='$data->{'category'}'>$data->{'category'}");
	} else {
		$template->param(category => "<input type=text name=\"category\" size=8 maxlength=8>");
	}
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("replace authorised_values (id,category,authorised_value,lib) values (?,?,?,?)");
	$sth->execute($input->param('id'), $input->param('category'), $input->param('authorised_value'),$input->param('lib'));
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=".$input->param('category')."\"></html>";
	exit;
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare($reqsel);
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(searchfield => $searchfield,
							Tvalue => $data->{'authorised_value'},
							id =>$id,
							);

													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare($reqdel);
	$sth->execute;
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=$searchfield\"></html>";
	exit;

													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	# build categories list
	my $sth = $dbh->prepare("select distinct category from authorised_values");
	$sth->execute;
	my @category_list;
	while ( my ($category) = $sth->fetchrow_array) {
		push(@category_list,$category);
	}
	# push koha system categories
	my $tab_list = CGI::scrolling_list(-name=>'searchfield',
			-values=> \@category_list,
			-default=>"",
			-size=>1,
			-multiple=>0,
			);
	if (!$searchfield) {
		$searchfield=$category_list[0];
	}
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle="white";
	my @loop_data = ();
	# builds value list
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 'white'){
			$toggle="#ffffcc";
	  	} else {
			$toggle="white";
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{category} = $results->[$i]{'category'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{lib} = $results->[$i]{'lib'};
		$row_data{edit} = "$script_name?op=add_form&id=".$results->[$i]{'id'};
		$row_data{delete} = "$script_name?op=delete_confirm&searchfield=$searchfield&id=".$results->[$i]{'id'};
		push(@loop_data, \%row_data);
	}

	$template->param(loop => \@loop_data,
							tab_list => $tab_list,
							category => $searchfield);
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param("<a href=$script_name?offset=".$prevpage.'&lt;&lt; Prev</a>');
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param("a href=$script_name?offset=".$nextpage.'Next &gt;&gt;</a>');
	}
} #---- END $OP eq DEFAULT

print $input->header(
    -type => guesstype($template->output),
    -cookie => $cookie
), $template->output;
