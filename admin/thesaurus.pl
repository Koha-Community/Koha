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
use C4::Context;
use C4::Output;
use C4::Search;
use HTML::Template;
use C4::Context;
use C4::Authorities;

my $input = new CGI;
my $search_category=$input->param('search_category');
my $toponly = $input->param('toponly');
my $branch = $input->param('branch');
my $searchstring = $input->param('searchstring');
$searchstring=~ s/\,//g;
my $id = $input->param('id');
my $offset=$input->param('offset');
my $father=$input->param('father');

my $reqsel="select category,stdlib,freelib from authorised_values where id='$id'";
my $reqdel="delete from authorised_values where id='$id'";
my $script_name="/cgi-bin/koha/admin/thesaurus.pl";
my $dbh = C4::Context->dbh;
my $authoritysep = C4::Context->preference("authoritysep");
warn "authority : $authoritysep";

my $template = gettemplate("parameters/thesaurus.tmpl",0);
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
		warn "id => $id";
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select id,category,freelib,stdlib from bibliothesaurus where id='$id'");
		$sth->execute;
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	} else {
		$data->{'category'} = $input->param('category');
		$data->{'stdlib'} = $input->param('stdlib');
	}
	if ($search_category) {
		$template->param(action => "Modify authorised value");
	} else {
		$template->param(action => "Add authorised value");
	}
	$template->param(category => $data->{'category'},
							stdlib => $data->{'stdlib'},
							freelib => $data->{'freelib'},
							id => $data->{'id'},
							branch => $branch,
							toponly => $toponly,
							search_category => $search_category,
							searchstring => $searchstring,
							offset => $offset,
							father => $father,
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
	my $sth=$dbh->prepare("replace bibliothesaurus (id,category,stdlib,freelib,father,hierarchy) values (?,?,?,?,?)");
	$sth->execute($input->param('id'), $input->param('category'), $input->param('stdlib'), $input->param('freelib'),$father);
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=thesaurus.pl?branch=$branch&toponly=$toponly&search_category=$search_category&searchstring=$searchstring&offset=$offset\"></html>";
	exit;
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare($reqsel);
	$sth->execute;
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(search_category => $search_category,
							Tvalue => $data->{'stdlib'},
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
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=thesaurus.pl?search_category=$search_category\"></html>";
	exit;
													# END $OP eq DELETE_CONFIRMED
################## DETAIL_FORM ##################################
} elsif ($op eq 'detail_form') {
	# build categories list
	my $sth = $dbh->prepare("select distinct category from bibliothesaurus");
	$sth->execute;
	my @category_list;
	while ( my ($category) = $sth->fetchrow_array) {
		push(@category_list,$category);
	}
	my $tab_list = CGI::scrolling_list(-name=>'search_category',
			-values=> \@category_list,
			-default=>"$search_category",
			-size=>1,
			-multiple=>0,
			);
	if (!$search_category) {
		$search_category=$category_list[0];
	}
	my $env;
	my $sth = $dbh->prepare("select stdlib,category from bibliothesaurus where id=?");
	$sth->execute($id);
	my ($stdlib,$category) = $sth->fetchrow_array;
	$sth->finish;
	$sth= $dbh->prepare("select id,freelib from bibliothesaurus where stdlib=?");
	$sth->execute($stdlib);
	my $toggle="white";
	# builds value list
	my @loop_data;
	while ( my ($id,$freelib) = $sth->fetchrow_array) {
	  	if ($toggle eq 'white'){
			$toggle="#ffffcc";
	  	} else {
			$toggle="white";
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{freelib} = $freelib;
		$row_data{edit} = "$script_name?op=add_form&id=$id";
		$row_data{delete} = "$script_name?op=delete_confirm&search_category=$search_category&id=$id";
		push(@loop_data, \%row_data);
	}

	$template->param(loop => \@loop_data,
							tab_list => $tab_list,
							category => $search_category,
							toponly => $toponly,
							searchstring => $searchstring,
							stdlib => $stdlib,
							category => $category);
################## DEFAULT ##################################
} else { # DEFAULT
	# build categories list
	my $sth = $dbh->prepare("select distinct category from bibliothesaurus");
	$sth->execute;
	my @category_list;
	while ( my ($category) = $sth->fetchrow_array) {
		push(@category_list,$category);
	}
	my $tab_list = CGI::scrolling_list(-name=>'search_category',
			-values=> \@category_list,
			-default=>"$search_category",
			-size=>1,
			-multiple=>0,
			);
	if (!$search_category) {
		$search_category=$category_list[0];
	}
	my $env;
	my ($count,$results)=searchauthority($env,$search_category,$toponly,$branch,$searchstring);
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
		$row_data{stdlib} = ("&nbsp;&nbsp;&nbsp;&nbsp;" x $results->[$i]{'level'}).$results->[$i]{'stdlib'};
		$row_data{stdlib} = $results->[$i]{'stdlib'};
		$row_data{dig} ="<a href=thesaurus.pl?branch=$results->[$i]{'hierarchy'}".($results->[$i]{'hierarchy'}?"|":"")."$results->[$i]{'id'}&toponly=$toponly&search_category=$search_category>";
		$row_data{related} ="<a href=thesaurus.pl?id=$results->[$i]{'id'}&search_category=$search_category&op=detail_form>";
		$row_data{edit} = "$script_name?op=add_form&branch=$branch&toponly=$toponly&search_category=$search_category&searchstring=$searchstring&offset=$offset&id=".$results->[$i]{'id'};
		$row_data{delete} = "$script_name?op=delete_confirm&search_category=$search_category&id=".$results->[$i]{'id'};
		push(@loop_data, \%row_data);
	}
	# rebuild complete hierarchy
	my  $sth = $dbh->prepare("select stdlib from bibliothesaurus where id=?");
	my @hierarchy = split(/\|/,$branch);
	my @hierarchy_loop;
	my $x;
	my $father;
	for (my $xi=0;$xi<=$#hierarchy;$xi++) {
		my %link;
		$sth->execute($hierarchy[$xi]);
		my ($t) = $sth->fetchrow_array;
		$x.=$hierarchy[$xi];
		$link{'string'}=$t;
		$link{'branch'}=$x;
		push (@hierarchy_loop, \%link);
		$x.='|';
		$father = $t." $authoritysep ";
	}
	$template->param(loop => \@loop_data,
							tab_list => $tab_list,
							category => $search_category,
							toponly => $toponly,
							searchstring => $searchstring,
							hierarchy_loop => \@hierarchy_loop,
							branch => $branch,
							father => $father);
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(previous => "<a href=$script_name?branch=$branch&toponly=$toponly&search_category=$search_category&searchstring=$searchstring&offset=$prevpage>&lt;&lt; Prev</a>");
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(next => "<a href=$script_name?branch=$branch&toponly=$toponly&search_category=$search_category&searchstring=$searchstring&offset=$nextpage>Next &gt;&gt;</a>");
	}
} #---- END $OP eq DEFAULT

print "Content-Type: text/html\n\n", $template->output;
