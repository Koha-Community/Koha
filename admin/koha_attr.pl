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
use C4::Koha;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Search;


# retrieve parameters
my $input = new CGI;

my $searchfield=$input->param('searchfield');
$searchfield="" unless $searchfield;
my $id=$input->param('id');
my $offset=$input->param('offset');
$offset=0 unless $offset;
my $op = $input->param('op');
my $dspchoice = $input->param('select_display');
my $pagesize=20;
my @results = ();
my $script_name="/cgi-bin/koha/admin/koha_attr.pl";

my $dbh = C4::Context->dbh;
my $sth;
# open template
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/koha_attr.tmpl",
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


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($id) {
		$sth=$dbh->prepare("select id,kohafield,attr,label,sorts,recordtype,tagfield,tagsubfield,opacshow,intrashow from koha_attr where id=? ");
		$sth->execute($id);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}
	my $sth = $dbh->prepare("select authorised_value from authorised_values where category='recordtype'");
	$sth->execute;
	my @authorised_values;
	#push @authorised_values,"";
	while ((my $category) = $sth->fetchrow_array) {
		push @authorised_values, $category;
	}
	my $recordlist  = CGI::scrolling_list(-name=>'recordtype',
			-values=> \@authorised_values,
			-size=>1,
			-multiple=>0,
			-default => $data->{'recordtype'},
			);
	my $sth = $dbh->prepare("select authorised_value from authorised_values where category='mfield' order by lib");
	$sth->execute;
	my @authorised_values;
	#push @authorised_values,"";
	while ((my $category) = $sth->fetchrow_array) {
		push @authorised_values, $category;
	}
	my $taglist  = CGI::scrolling_list(-name=>'tagfield',
			-values=> \@authorised_values,
			-size=>1,
			-multiple=>0,
			-default => $data->{'tagfield'},
			);
	my $sth = $dbh->prepare("select authorised_value from authorised_values where category='subfield' order by lib ");
	$sth->execute;
	my @authorised_values;
	#push @authorised_values,"";
	while ((my $category) = $sth->fetchrow_array) {
		push @authorised_values, $category;
	}
	my $tagsublist  = CGI::scrolling_list(-name=>'tagsubfield',
			-values=> \@authorised_values,
			-size=>1,
			-multiple=>0,
			-default => $data->{'tagsubfield'},
			);
	
	if ($searchfield) {
		$template->param(action => "Modify tag",id=>$id ,searchfield => "<input type=\"hidden\" name=\"kohafield\" value=\"$searchfield\" />$searchfield");
		$template->param('heading-modify-tag-p' => 1);
	} else {
		$template->param(action => "Add tag",
								searchfield => "<input type=\"text\" name=\"kohafield\" size=\"40\" maxlength=\"80\" />");
		$template->param('heading-add-tag-p' => 1);
	}
	$template->param('use-heading-flags-p' => 1);
	$template->param(label => $data->{'label'},
			attr=> $data->{'attr'},
			recordtype=>$recordlist,
			tagfield=>$taglist,
			tagsubfield=>$tagsublist,
			sorts => CGI::checkbox(-name=>'sorts',
					-checked=> $data->{'sorts'}?'checked':'',
						-value=> 1,
						-label => '',
						-id=> 'sorts'),
			opacshow => CGI::checkbox(-name=>'opacshow',
						-checked=> $data->{'opacshow'}?'checked':'',
						-value=> 1,
						-label => '',
						-id=> 'opacshow'),
			intrashow => CGI::checkbox(-name=>'intrashow',
						-checked=> $data->{'intrashow'}?'checked':'',
						-value=> 1,
						-label => '',
						-id=> 'intrashow'),


			);
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
my $id       =$input->param('id');

	$sth=$dbh->prepare("replace koha_attr  set id=?,kohafield=?,attr=?,label=?,sorts=?,recordtype=?,tagfield=?,tagsubfield=? ,opacshow=?,intrashow=? ");

	
	my $kohafield       =$input->param('kohafield');
	my $attr       =$input->param('attr');
	my $label  = $input->param('label');
	my $sorts =$input->param('sorts');
	my $opacshow =$input->param('opacshow');
	my $intrashow =$input->param('intrashow');
	my $recordtype =$input->param('recordtype');
	my $tagfield =$input->param('tagfield');
	my $tagsubfield =$input->param('tagsubfield');
	unless (C4::Context->config('demo') eq 1) {
		$sth->execute( $id,$kohafield,$attr,$label,$sorts?1:0,$recordtype,$tagfield,$tagsubfield,$opacshow?1:0,$intrashow?1:0);
	}
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=koha_attr.pl?searchfield=$kohafield\"></html>";

	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$sth=$dbh->prepare("select id,kohafield,label,recordtype from koha_attr where id=? ");
		$sth->execute($id);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(label => $data->{'label'}."/". $data->{'recordtype'},id=>$data->{'id'},
							searchfield => $searchfield,
							);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {

	unless (C4::Context->config('demo') eq 1) {
		$dbh->do("delete from koha_attr where id=$id ");
	}
													# END $OP eq DELETE_CONFIRMED

################## DEFAULT ##################################
} else { # DEFAULT
	# here, $op can be unset or set 
	if  ($searchfield ne '') {
		 $template->param(searchfield => $searchfield);
	}
	my $cnt=0;
	if ($dspchoice) {
		#here, user only wants used tags/subfields displayed
		my $sth=$dbh->prepare("Select * from koha_attr where tagfield <>'' and kohafield >= ? ");
		#could be ordoned by tab
		$sth->execute($searchfield);

		while (my $data=$sth->fetchrow_hashref){
			push(@results,$data);
			$cnt++;
		}

		$sth->finish;
		
		my $toggle=0;
		my @loop_data = ();
		my $j=1;
		my $i=$offset;
		while ($i < ($offset+$pagesize<$cnt?$offset+$pagesize:$cnt)) {
			if ($toggle eq 0){
				$toggle=1;
			} else {
				$toggle=0;
			}
			my %row_data;  # get a fresh hash for the row data
			$row_data{id} = $results[$i]->{'id'};
			$row_data{kohafield} = $results[$i]->{'kohafield'};
			$row_data{label} = $results[$i]->{'label'};
			$row_data{sorts} = $results[$i]->{'sorts'};
			$row_data{attr} = $results[$i]->{'attr'};
			$row_data{recordtype} = $results[$i]->{'recordtype'};
			$row_data{tagfield} = $results[$i]->{'tagfield'};
			$row_data{tagsubfield} = $results[$i]->{'tagsubfield'};
			$row_data{opacshow} = $results[$i]->{'opacshow'};
			$row_data{intrashow} = $results[$i]->{'intrashow'};
			$row_data{edit} = "$script_name?op=add_form&amp;searchfield=".$results[$i]->{'kohafield'}."&amp;id=".$results[$i]->{'id'};
			$row_data{delete} = "$script_name?op=delete_confirm&amp;searchfield=".$results[$i]->{'kohafield'}."&amp;id=".$results[$i]->{'id'};
			$row_data{toggle} = $toggle;
			push(@loop_data, \%row_data);
			$i++;
		}
		$template->param(select_display => "True",
						loop => \@loop_data);
		$sth->finish;
	} else {
		#here, normal old style : display every tags
		my ($count,@results)=StringSearch($dbh,$searchfield);
		$cnt = $count;
		my $toggle=0;
		my @loop_data = ();
		for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
			if ($toggle eq 0){
				$toggle=1;
			} else {
				$toggle=0;
			}
			my %row_data;  # get a fresh hash for the row data
			$row_data{id} = $results[$i]->{'id'};
			$row_data{kohafield} = $results[$i]->{'kohafield'};
			$row_data{label} = $results[$i]->{'label'};
			$row_data{sorts} = $results[$i]->{'sorts'};
			$row_data{attr} = $results[$i]->{'attr'};
			$row_data{recordtype} = $results[$i]->{'recordtype'};
			$row_data{tagfield} = $results[$i]->{'tagfield'};
			$row_data{tagsubfield} = $results[$i]->{'tagsubfield'};
			$row_data{opacshow} = $results[$i]->{'opacshow'};
			$row_data{intrashow} = $results[$i]->{'intrashow'};
			$row_data{edit} = "$script_name?op=add_form&amp;searchfield=".$results[$i]->{'kohafield'}."&amp;id=".$results[$i]->{'id'};
			$row_data{delete} = "$script_name?op=delete_confirm&amp;searchfield=".$results[$i]->{'kohafield'}."&amp;id=".$results[$i]->{'id'};
			$row_data{toggle} = $toggle;
			push(@loop_data, \%row_data);
		}
		$template->param(loop => \@loop_data);
	}
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(isprevpage => $offset,
						prevpage=> $prevpage,
						searchfield => $searchfield,
						script_name => $script_name,
						
		);
	}
	if ($offset+$pagesize<$cnt) {
		my $nextpage =$offset+$pagesize;
		$template->param(nextpage =>$nextpage,
						searchfield => $searchfield,
						script_name => $script_name,
						
		);
	}
} #---- END $OP eq DEFAULT

$template->param(loggeninuser => $loggedinuser,
		intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
		);
output_html_with_http_headers $input, $cookie, $template->output;


#
# the sub used for searches
#
sub StringSearch  {
	my ($dbh,$searchstring)=@_;
	my $sth=$dbh->prepare("Select * from koha_attr  where kohafield >=?  order by kohafield");
	$sth->execute($searchstring);
	my @dataresults;
	while (my $data=$sth->fetchrow_hashref){
	push(@dataresults,$data);

	}

	$sth->finish;
	return (scalar(@dataresults),@dataresults);
}



