#! /usr/bin/perl

# Copyright 2006 SAN OUEST-PROVENCE et Paul POULAIN
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
    = get_template_and_user({template_name => "admin/cities.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
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
		my $sth=$dbh->prepare("select cityid,city_name,city_zipcode from cities where  cityid=?");
		$sth->execute($cityid);
		$data=$sth->fetchrow_hashref;
	}

	$template->param(	
				city_name       => $data->{'city_name'},
				city_zipcode    => $data->{'city_zipcode'});
# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
 	my $sth;
	
	if ($input->param('cityid') ){
		$sth=$dbh->prepare("UPDATE cities SET city_name=?,city_zipcode=? WHERE cityid=?");
		$sth->execute($input->param('city_name'),$input->param('city_zipcode'),$input->param('cityid'));
	}
	else{	
		$sth=$dbh->prepare("INSERT INTO cities (city_name,city_zipcode) values (?,?)");
		$sth->execute($input->param('city_name'),$input->param('city_zipcode'));
	}
	print $input->redirect($script_name);
	exit;
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$template->param(delete_confirm => 1);
	my $sth=$dbh->prepare("select count(*) as total from borrowers,cities where borrowers.city=cities.city_name and cityid=?");
    # FIXME: this check used to pretend there was a FK "select_city" in borrowers.
	$sth->execute($cityid);
	my $total = $sth->fetchrow_hashref;
	my $sth2=$dbh->prepare("select cityid,city_name,city_zipcode from cities where  cityid=?");
	$sth2->execute($cityid);
	my $data=$sth2->fetchrow_hashref;
    $template->param(
        total        => $total->{'total'},
        city_name    =>	$data->{'city_name'},
        city_zipcode => $data->{'city_zipcode'},
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
