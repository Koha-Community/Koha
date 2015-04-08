#! /usr/bin/perl

# Copyright 2006 SAN OUEST-PROVENCE et Paul POULAIN
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;

sub StringSearch {
	my $sth = C4::Context->dbh->prepare("SELECT * FROM cities WHERE (city_name LIKE ?)");
	$sth->execute("%" . (shift || '') . "%");
    return $sth->fetchall_arrayref({});
}

my $input = new CGI;
my $script_name = "/cgi-bin/koha/admin/cities.pl";
my $searchfield = $input->param('city_name');
my $cityid      = $input->param('cityid');
my $op          = $input->param('op') || '';

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/cities.tt",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
                 flagsrequired => {parameters => 'parameters_remaining_permissions'},
			     debug => 1,
			     });

$template->param(	script_name => $script_name,
		 	cityid     => $cityid ,
		 	searchfield => $searchfield);

my $dbh = C4::Context->dbh;
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	$template->param(add_form => 1);
	
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($cityid) {
		my $sth=$dbh->prepare("select cityid,city_name,city_state,city_zipcode,city_country from cities where  cityid=?");
		$sth->execute($cityid);
		$data=$sth->fetchrow_hashref;
	}

	$template->param(	
				city_name       => $data->{'city_name'},
				city_state      => $data->{'city_state'},
				city_zipcode    => $data->{'city_zipcode'},
				city_country    => $data->{'city_country'});
# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
 	my $sth;
	
	if ($input->param('cityid') ){
		$sth=$dbh->prepare("UPDATE cities SET city_name=?,city_state=?,city_zipcode=?,city_country=? WHERE cityid=?");
		$sth->execute($input->param('city_name'),$input->param('city_state'),$input->param('city_zipcode'),$input->param('city_country'),$input->param('cityid'));
	}
	else{	
		$sth=$dbh->prepare("INSERT INTO cities (city_name,city_state,city_zipcode,city_country) values (?,?,?,?)");
		$sth->execute($input->param('city_name'),$input->param('city_state'),$input->param('city_zipcode'),$input->param('city_country'));
	}
	print $input->redirect($script_name);
	exit;
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$template->param(delete_confirm => 1);
	my $sth=$dbh->prepare("select cityid,city_name,city_state,city_zipcode,city_country from cities where  cityid=?");
	$sth->execute($cityid);
	my $data=$sth->fetchrow_hashref;
    $template->param(
        city_name    =>	$data->{'city_name'},
        city_state   =>	$data->{'city_state'},
        city_zipcode => $data->{'city_zipcode'},
        city_country => $data->{'city_country'},
    );
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $sth=$dbh->prepare("delete from cities where cityid=?");
	$sth->execute($cityid);
	print $input->redirect($script_name);
	exit;   # FIXME: what's the point of redirecting to this same page?
													# END $OP eq DELETE_CONFIRMED
} else { # DEFAULT
	$template->param(else => 1);
	$template->param(loop => StringSearch($searchfield));

} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
