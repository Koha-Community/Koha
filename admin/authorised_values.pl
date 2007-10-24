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

use C4::Context;


sub StringSearch  {
	my ($searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select id,category,authorised_value,lib from authorised_values where (category like ?) order by category,authorised_value");
	$sth->execute("$data[0]%");
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
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/authorised_values.pl";
my $dbh = C4::Context->dbh;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/authorised_values.tmpl",
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
		my $sth=$dbh->prepare("select id,category,authorised_value,lib from authorised_values where id=?");
		$sth->execute($id);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	} else {
		$data->{'category'} = $input->param('category');
	}
	if ($id) {
		$template->param(action_modify => 1);
		$template->param('heading-modify-authorized-value-p' => 1);
	} elsif ( ! $data->{'category'} ) {
		$template->param(action_add_category => 1);
		$template->param('heading-add-new-category-p' => 1);
	} else {
		$template->param(action_add_value => 1);
		$template->param('heading-add-authorized-value-p' => 1);
	}
	$template->param('use-heading-flags-p' => 1);
	$template->param(category => $data->{'category'},
							authorised_value => $data->{'authorised_value'},
							lib => $data->{'lib'},
							id => $data->{'id'}
							);
	if ($data->{'category'}) {
		$template->param(category => "<input type=\"hidden\" name=\"category\" value=\"'$data->{'category'}'\" />$data->{'category'}");
	} else {
		$template->param(category => "<input type=\"text\" name=\"category\" id=\"category\" size=\"8\" maxlength=\"8\" />");
	}
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("replace authorised_values (id,category,authorised_value,lib) values (?,?,?,?)");
	my $lib = $input->param('lib');
	undef $lib if ($lib eq ""); # to insert NULL instead of a blank string
	
	$sth->execute($input->param('id'), $input->param('category'), $input->param('authorised_value'), $lib);
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=authorised_values.pl?searchfield=".$input->param('category')."\"></html>";
	exit;
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select category,authorised_value,lib from authorised_values where id=?");
	$sth->execute($id);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$id = $input->param('id') unless $id;
	$template->param(searchfield => $searchfield,
							Tvalue => $data->{'authorised_value'},
							id =>$id,
							);

													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $id = $input->param('id');
	my $sth=$dbh->prepare("delete from authorised_values where id=?");
	$sth->execute($id);
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
	        -id=>'searchfield',
			-values=> \@category_list,
			-default=>"",
			-size=>1,
 			-tabindex=>'',
			-multiple=>0,
			);
	if (!$searchfield) {
		$searchfield=$category_list[0];
	}
	my ($count,$results)=StringSearch($searchfield,'web');
	my $toggle=1;
	my @loop_data = ();
	# builds value list
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 1){
			$toggle=1;
	  	} else {
			$toggle=0;
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{category} = $results->[$i]{'category'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{lib} = $results->[$i]{'lib'};
		$row_data{edit} = "$script_name?op=add_form&amp;id=".$results->[$i]{'id'};
		$row_data{delete} = "$script_name?op=delete_confirm&amp;searchfield=$searchfield&amp;id=".$results->[$i]{'id'};
		push(@loop_data, \%row_data);
	}

	$template->param(loop => \@loop_data,
							tab_list => $tab_list,
							category => $searchfield);

	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(isprevpage => $offset,
						prevpage=> $prevpage,
						searchfield => $searchfield,
						script_name => $script_name,
		 );
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(nextpage =>$nextpage,
						searchfield => $searchfield,
						script_name => $script_name,
		);
	}
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
