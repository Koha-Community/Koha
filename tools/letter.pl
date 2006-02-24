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
	my $sth=$dbh->prepare("Select * from letter where (code like ?) order by module,code");
	$sth->execute("$data[0]%");
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
my $script_name="/cgi-bin/koha/tools/letter.pl";
my $code=$input->param('code');
my $module = $input->param('module');
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;
my $dbh = C4::Context->dbh;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "tools/letter.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {tools => 1},
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
	my $letter;
	if ($code) {
		my $sth=$dbh->prepare("select * from letter where module=? and code=?");
		$sth->execute($module,$code);
		$letter=$sth->fetchrow_hashref;
		$sth->finish;
	}
	# build field list
	my @SQLfieldname;
	my %line = ('value' => "LibrarianFirstname", 'text' => 'LibrarianFirstname');
	push @SQLfieldname, \%line;
	my %line = ('value' => "LibrarianSurname", 'text' => 'LibrarianSurname');
	push @SQLfieldname, \%line;
	my %line = ('value' => "LibrarianEmailaddress", 'text' => 'LibrarianEmailaddress');
	push @SQLfieldname, \%line;
	my $sth2=$dbh->prepare("SHOW COLUMNS from branches");
	$sth2->execute;
	my %line = ('value' => "", 'text' => '---BRANCHES---');
	push @SQLfieldname, \%line;
	while ((my $field) = $sth2->fetchrow_array) {
		my %line = ('value' => "branches.".$field, 'text' => "branches.".$field);
		push @SQLfieldname, \%line;
	}
	my $sth2=$dbh->prepare("SHOW COLUMNS from biblio");
	$sth2->execute;
	my %line = ('value' => "", 'text' => '---BIBLIO---');

	push @SQLfieldname, \%line;
	while ((my $field) = $sth2->fetchrow_array) {
		# note : %line is redefined, otherwise \%line contains the same value for every entry of the list
		my %line = ('value' => "biblio.".$field, 'text' => "biblio.".$field);
		push @SQLfieldname, \%line;
	}
	my $sth2=$dbh->prepare("SHOW COLUMNS from biblioitems");
	$sth2->execute;
	my %line = ('value' => "", 'text' => '---BIBLIOITEMS---');
	push @SQLfieldname, \%line;
	while ((my $field) = $sth2->fetchrow_array) {
		my %line = ('value' => "biblioitems.".$field, 'text' => "biblioitems.".$field);
		push @SQLfieldname, \%line;
	}
	my %line = ('value' => "", 'text' => '---ITEMS---');
	push @SQLfieldname, \%line;
	my %line = ('value' => "items.content", 'text' => 'items.content');
	push @SQLfieldname, \%line;
	
	my $sth2=$dbh->prepare("SHOW COLUMNS from borrowers");
	$sth2->execute;
	my %line = ('value' => "", 'text' => '---BORROWERS---');
	push @SQLfieldname, \%line;
	while ((my $field) = $sth2->fetchrow_array) {
		my %line = ('value' => "borrowers.".$field, 'text' => "borrowers.".$field);
		push @SQLfieldname, \%line;
	}
	if ($code) {
	    $template->param(modify => 1);
	    $template->param(code => $letter->{code});
	} else {
	    $template->param(adding => 1);
	}
	$template->param(name => $letter->{name},title => $letter->{title},
					content => $letter->{content},
					$letter->{module} => 1,
					SQLfieldname => \@SQLfieldname,);
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("replace letter (module,code,name,title,content) values (?,?,?,?,?)");
	$sth->execute($input->param('module'),$input->param('code'),$input->param('name'),$input->param('title'),$input->param('content'));
	$sth->finish;
	 print $input->redirect("letter.pl");
	 exit;
# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select * from letter where code=?");
	$sth->execute($code);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(module => $data->{module});
	$template->param(code => $code);
	$template->param(name => $data->{'name'});
	$template->param(content => $data->{'content'});
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $code=uc($input->param('code'));
	my $module=$input->param('module');
	my $sth=$dbh->prepare("delete from letter where module=? and code=?");
	$sth->execute($module,$code);
	$sth->finish;
	 print $input->redirect("letter.pl");
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
	  	if ($toggle eq 'white'){
	    		$toggle="#ffffcc";
	  	} else {
	    		$toggle="white";
	  	}
	   my %row_data;
	   $row_data{toggle} = $toggle;
	   $row_data{module} = $results->[$i]{'module'};
	   $row_data{code} = $results->[$i]{'code'};
	   $row_data{name} = $results->[$i]{'name'};
	   push(@loop_data, \%row_data);
	}
	$template->param(letter => \@loop_data);
} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;

