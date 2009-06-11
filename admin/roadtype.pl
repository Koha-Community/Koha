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
use C4::Output;
use C4::Auth;


sub StringSearch  {
	my ($searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select * from roadtype where (road_type like ?)");
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
my $searchfield=$input->param('road_type');
my $script_name="/cgi-bin/koha/admin/roadtype.pl";
my $roadtypeid=$input->param('roadtypeid');
my $op = $input->param('op');

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/roadtype.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });


$template->param(	script_name => $script_name,
		 	roadtypeid => $roadtypeid ,
		 	searchfield => $searchfield);


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	$template->param(add_form => 1);
	
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($roadtypeid) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select roadtypeid,road_type from roadtype where roadtypeid=?");
		$sth->execute($roadtypeid);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}

	$template->param(	
				road_type       => $data->{'road_type'},
			);
##############ICI#####################
# END $OP eq ADD_FORM
################## ADD_VALIDATE #################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
 	my $sth;
	
	if ($input->param('roadtypeid') ){
		$sth=$dbh->prepare("UPDATE roadtype SET road_type=? WHERE roadtypeid=?");
		$sth->execute($input->param('road_type'),$input->param('roadtypeid'));
	
	}
	else{	
		$sth=$dbh->prepare("INSERT INTO roadtype (road_type) VALUES (?)");
		$sth->execute($input->param('road_type'));
	}
	$sth->finish;
    print $input->redirect("/cgi-bin/koha/admin/roadtype.pl");
	exit;

# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$template->param(delete_confirm => 1);
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select count(*) as total from borrowers,roadtype where borrowers.streettype=roadtype.road_type and roadtypeid=?");
	$sth->execute($roadtypeid);
	my $total = $sth->fetchrow_hashref;
	$sth->finish;
	$template->param(total => $total->{'total'});	
	my $sth2=$dbh->prepare("select roadtypeid,road_type from roadtype where  roadtypeid=?");
	$sth2->execute($roadtypeid);
	my $data=$sth2->fetchrow_hashref;
	$sth2->finish;
	if ($total->{'total'} >0) {
		$template->param(totalgtzero => 1);
	}

        $template->param(	
				road_type       =>	( $data->{'road_type'}),
				);


													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	my $categorycode=uc($input->param('roadtypeid'));
	my $sth=$dbh->prepare("delete from roadtype where roadtypeid=?");
	$sth->execute($roadtypeid);
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=roadtype.pl\"></html>";
	exit;
													# END $OP eq DELETE_CONFIRMED
} else { # DEFAULT
	$template->param(else => 1);
	my @loop;
	my ($count,$results)=StringSearch($searchfield,'web');
	for (my $i=0; $i < $count; $i++){
		my %row = (roadtypeid => $results->[$i]{'roadtypeid'},
				road_type => $results->[$i]{'road_type'});
		push @loop, \%row;
	}
	$template->param(loop => \@loop);


} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
