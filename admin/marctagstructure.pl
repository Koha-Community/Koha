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
use C4::Context;
use HTML::Template;

# retrieve parameters
my $input = new CGI;
my $itemtype = $input->param('itemtype'); # set to select framework
$itemtype="" unless $itemtype;
my $existingitemtype = $input->param('existingitemtype'); # set when we have to create a new framework (in itemtype) by copying an old one (in existingitemtype)
$existingitemtype = "" unless $existingitemtype;
my $itemtypeinfo = getitemtypeinfo($itemtype);
my $searchfield=$input->param('searchfield');
$searchfield=0 unless $searchfield;
$searchfield=~ s/\,//g;

my $offset=$input->param('offset');
my $op = $input->param('op');
my $pagesize=20;

my $script_name="/cgi-bin/koha/admin/marctagstructure.pl";

my $dbh = C4::Context->dbh;

# open template
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "parameters/marctagstructure.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

# get itemtype list
my $itemtypes = getitemtypes;
my @itemtypesloop;
foreach my $thisitemtype (keys %$itemtypes) {
	my $selected = 1 if $thisitemtype eq $itemtype;
	my %row =(value => $thisitemtype,
				selected => $selected,
				description => $itemtypes->{$thisitemtype}->{'description'},
			);
	push @itemtypesloop, \%row;
}

# check that itemtype framework is defined in marc_tag_structure
my $sth=$dbh->prepare("select count(*) from marc_tag_structure where itemtype=?");
$sth->execute($itemtype);
my ($itemtypeexist) = $sth->fetchrow;
if ($itemtypeexist) {
} else {
	# if itemtype does not exists, then OP must be changed to "create itemtype" if we are not on the way to create it
	# (op = itemtyp_create_confirm)
	if ($op eq "itemtype_create_confirm") {
		duplicate_framework($itemtype, $existingitemtype);
	} else {
		$op = "itemtype_create";
	}
}
$template->param(itemtypeloop => \@itemtypesloop);
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
		$sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from marc_tag_structure where tagfield=? and itemtype=?");
		$sth->execute($searchfield,$itemtype);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}
	my $sth = $dbh->prepare("select distinct category from authorised_values");
	$sth->execute;
	my @authorised_values;
	push @authorised_values,"";
	while ((my $category) = $sth->fetchrow_array) {
		push @authorised_values, $category;
	}
	my $authorised_value  = CGI::scrolling_list(-name=>'authorised_value',
			-values=> \@authorised_values,
			-size=>1,
			-multiple=>0,
			-default => $data->{'authorised_value'},
			);

	if ($searchfield) {
		$template->param(action => "Modify tag",
								searchfield => "<input type=\"hidden\" name=\"tagfield\" value=\"$searchfield\" />$searchfield");
		$template->param('heading-modify-tag-p' => 1);
	} else {
		$template->param(action => "Add tag",
								searchfield => "<input type=\"text\" name=\"tagfield\" size=\"5\" maxlength=\"3\" />");
		$template->param('heading-add-tag-p' => 1);
	}
	$template->param('use-heading-flags-p' => 1);
	$template->param(liblibrarian => $data->{'liblibrarian'},
							libopac => $data->{'libopac'},
							repeatable => CGI::checkbox('repeatable',$data->{'repeatable'}?'checked':'',1,''),
							mandatory => CGI::checkbox('mandatory',$data->{'mandatory'}?'checked':'',1,''),
							authorised_value => $authorised_value,
							itemtype => $itemtype,
							);
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	$sth=$dbh->prepare("replace marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,itemtype) values (?,?,?,?,?,?,?)");
	my $tagfield       =$input->param('tagfield');
	my $liblibrarian  = $input->param('liblibrarian');
	my $libopac       =$input->param('libopac');
	my $repeatable =$input->param('repeatable');
	my $mandatory =$input->param('mandatory');
	my $authorised_value =$input->param('authorised_value');
	unless (C4::Context->config('demo') eq 1) {
		$sth->execute($tagfield,
							$liblibrarian,
							$libopac,
							$repeatable?1:0,
							$mandatory?1:0,
							$authorised_value,
							$itemtype
							);
	}
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=marctagstructure.pl?tagfield=$tagfield&itemtype=$itemtype\"></html>";
	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from marc_tag_structure where tagfield=?");
	$sth->execute($searchfield);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(liblibrarian => $data->{'liblibrarian'},
							searchfield => $searchfield,
							);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	unless (C4::Context->config('demo') eq 1) {
		$dbh->do("delete from marc_tag_structure where tagfield='$searchfield'");
		$dbh->do("delete from marc_subfield_structure where tagfield='$searchfield'");
	}
													# END $OP eq DELETE_CONFIRMED
################## ITEMTYPE_CREATE ##################################
# called automatically if an unexisting itemtype is selected
} elsif ($op eq 'itemtype_create') {
	$sth = $dbh->prepare("select count(*),marc_tag_structure.itemtype,description from marc_tag_structure,itemtypes where itemtypes.itemtype=marc_tag_structure.itemtype group by marc_tag_structure.itemtype");
	$sth->execute;
	my @existingitemtypeloop;
	while (my ($tot,$thisitemtype,$description) = $sth->fetchrow) {
		if ($tot>0) {
			my %line = ( value => $thisitemtype,
						description => $description,
					);
			push @existingitemtypeloop,\%line;
		}
	}
	$template->param(existingitemtypeloop => \@existingitemtypeloop,
					itemtype => $itemtype,
					ITdescription => $itemtypeinfo->{description},
					);
################## DEFAULT ##################################
} else { # DEFAULT
	# here, $op can be unset or set to "itemtype_create_confirm".
	if  ($searchfield ne '') {
		 $template->param(searchfield => $searchfield);
	}
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,$itemtype);
	my $toggle="white";
	my @loop_data = ();
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 'white'){
			$toggle="#ffffcc";
	  	} else {
			$toggle="white";
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{tagfield} = $results->[$i]{'tagfield'};
		$row_data{liblibrarian} = $results->[$i]{'liblibrarian'};
		$row_data{repeatable} = $results->[$i]{'repeatable'};
		$row_data{mandatory} = $results->[$i]{'mandatory'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{subfield_link} ="marc_subfields_structure.pl?tagfield=".$results->[$i]{'tagfield'}."&itemtype=".$itemtype;
		$row_data{edit} = "$script_name?op=add_form&amp;searchfield=".$results->[$i]{'tagfield'}."&itemtype=".$itemtype;
		$row_data{delete} = "$script_name?op=delete_confirm&amp;searchfield=".$results->[$i]{'tagfield'}."&itemtype=".$itemtype;
		$row_data{bgcolor} = $toggle;
		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(isprevpage => $offset,
						prevpage=> $prevpage,
						searchfield => $searchfield,
						script_name => $script_name,
						itemtype => $itemtype,
		 );
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(nextpage =>$nextpage,
						searchfield => $searchfield,
						script_name => $script_name,
						itemtype => $itemtype,
		);
	}
} #---- END $OP eq DEFAULT

$template->param(loggeninuser => $loggedinuser);
output_html_with_http_headers $input, $cookie, $template->output;


#
# the sub used for searches
#
sub StringSearch  {
	my ($env,$searchstring,$itemtype)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from marc_tag_structure where (tagfield >= ? and itemtype=?) order by tagfield");
	$sth->execute($data[0], $itemtype);
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return (scalar(@results),\@results);
}

#
# the sub used to duplicate a framework from an existing one in MARC parameters tables.
#
sub duplicate_framework {
	my ($newitemtype,$olditemtype) = @_;
	my $sth = $dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from marc_tag_structure where itemtype=?");
	$sth->execute($olditemtype);
	my $sth_insert = $dbh->prepare("insert into marc_tag_structure (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, itemtype) values (?,?,?,?,?,?,?)");
	while ( my ($tagfield,$liblibrarian,$libopac,$repeatable,$mandatory,$authorised_value) = $sth->fetchrow) {
		$sth_insert->execute($tagfield,$liblibrarian,$libopac,$repeatable,$mandatory,$authorised_value,$newitemtype);
	}

	$sth = $dbh->prepare("select itemtype,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,thesaurus_category,value_builder,seealso from marc_subfield_structure where itemtype=?");
	$sth->execute($olditemtype);
	$sth_insert = $dbh->prepare("insert into marc_subfield_structure (itemtype,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,thesaurus_category,value_builder,seealso) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");
	while ( my ($itemtype, $tagfield, $tagsubfield, $liblibrarian, $libopac, $repeatable, $mandatory, $kohafield, $tab, $authorised_value, $thesaurus_category, $value_builder, $seealso) = $sth->fetchrow) {
		$sth_insert->execute($newitemtype, $tagfield, $tagsubfield, $liblibrarian, $libopac, $repeatable, $mandatory, $kohafield, $tab, $authorised_value, $thesaurus_category, $value_builder, $seealso);
	}
}

