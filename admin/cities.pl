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
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;

sub StringSearch  {
	my ($searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select * from cities where (city_name like ?)");
	$sth->execute("$data[0]%");
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return (scalar(@results),\@results);
}

my $input = new CGI;
my $searchfield=$input->param('city_name');
my $script_name="/cgi-bin/koha/admin/cities.pl";
my $cityid=$input->param('cityid');
my $op = $input->param('op');

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


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	$template->param(add_form => 1);
	
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($cityid) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select cityid,city_name,city_zipcode from cities where  cityid=?");
		$sth->execute($cityid);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}

	$template->param(	
				city_name       => $data->{'city_name'},
				city_zipcode    => $data->{'city_zipcode'});
##############ICI#####################
# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
 	my $sth;
	
	if ($input->param('cityid') ){
		$sth=$dbh->prepare("UPDATE cities SET city_name=?,city_zipcode=? WHERE cityid=?");
		$sth->execute($input->param('city_name'),$input->param('city_zipcode'),$input->param('cityid'));
	
	}
	else{	
		$sth=$dbh->prepare("INSERT INTO cities (city_name,city_zipcode) values (?,?)");
		$sth->execute($input->param('city_name'),$input->param('city_zipcode'));
	}
	$sth->finish;
	print $input->redirect("/cgi-bin/koha/admin/cities.pl");
	exit;
# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$template->param(delete_confirm => 1);

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select count(*) as total from borrowers,cities where borrowers.select_city=cities.cityid and cityid=?");
	$sth->execute($cityid);
	my $total = $sth->fetchrow_hashref;
	$sth->finish;
	$template->param(total => $total->{'total'});	
	my $sth2=$dbh->prepare("select cityid,city_name,city_zipcode from cities where  cityid=?");
	$sth2->execute($cityid);
	my $data=$sth2->fetchrow_hashref;
	$sth2->finish;
	if ($total->{'total'} >0) {
		$template->param(totalgtzero => 1);
	}

        $template->param(	
				city_name       =>	( $data->{'city_name'}),
				city_zipcode    =>       $data->{'city_zipcode'});


													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $categorycode=uc($input->param('cityid'));
	my $sth=$dbh->prepare("delete from cities where cityid=?");
	$sth->execute($cityid);
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=cities.pl\"></html>";
	exit;
													# END $OP eq DELETE_CONFIRMED
} else { # DEFAULT
	$template->param(else => 1);
	my @loop;
	my ($count,$results)=StringSearch($searchfield,'web');
	my $toggle = 0;
	for (my $i=0; $i < $count; $i++){
		my %row = (cityid => $results->[$i]{'cityid'},
				city_name => $results->[$i]{'city_name'},
				city_zipcode => $results->[$i]{'city_zipcode'},
				toggle => $toggle );	
		push @loop, \%row;
		if ( $toggle eq 0 )
		{
			$toggle = 1;
		}
		else
		{
			$toggle = 0;
		}
	}
	$template->param(loop => \@loop);


} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
