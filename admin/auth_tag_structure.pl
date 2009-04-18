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
use C4::Context;


# retrieve parameters
my $input = new CGI;
my $authtypecode = $input->param('authtypecode'); # set to select framework
$authtypecode="" unless $authtypecode;
my $existingauthtypecode = $input->param('existingauthtypecode'); # set when we have to create a new framework (in authtype) by copying an old one (in existingauthtype)
$existingauthtypecode = "" unless $existingauthtypecode;
# my $authtypeinfo = getauthtypeinfo($authtype);
my $searchfield=$input->param('searchfield');
$searchfield=0 unless $searchfield;
$searchfield=~ s/\,//g;

my $offset=$input->param('offset');
my $op = $input->param('op');
my $pagesize=20;

my $script_name="/cgi-bin/koha/admin/auth_tag_structure.pl";

my $dbh = C4::Context->dbh;

# open template
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/auth_tag_structure.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

# get authtype list
my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (keys %$authtypes) {
	my $selected = 1 if $thisauthtype eq $authtypecode;
	my %row =(value => $thisauthtype,
				selected => $selected,
				authtypetext => $authtypes->{$thisauthtype}->{'authtypetext'},
			);
	push @authtypesloop, \%row;
}

my $sth;
# check that authtype framework is defined in auth_tag_structure if we are on a default action
if (!$op or $op eq 'authtype_create_confirm') {
#warn "IN";
	$sth=$dbh->prepare("select count(*) from auth_tag_structure where authtypecode=?");
	$sth->execute($authtypecode);
	my ($authtypeexist) = $sth->fetchrow;
	if ($authtypeexist) {
	} else {
		# if authtype does not exists, then OP must be changed to "create authtype" if we are not on the way to create it
		# (op = authtyp_create_confirm)
		if ($op eq "authtype_create_confirm") {
			duplicate_auth_framework($authtypecode, $existingauthtypecode);
		} else {
			$op = "authtype_create";
		}
	}
}
$template->param(authtypeloop => \@authtypesloop);
if ($op && $op ne 'authtype_create_confirm') {
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
		$sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where tagfield=? and authtypecode=?");
		$sth->execute($searchfield,$authtypecode);
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
	        -id=>'authorised_value',
			-values=> \@authorised_values,
			-size=>1,
 			-tabindex=>'',
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
							repeatable => "".$data->{'repeatable'},
							mandatory => "".$data->{'mandatory'},
							authorised_value => $authorised_value,
							authtypecode => $authtypecode,
							);
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    if ($input->param('modif')) {
        $sth=$dbh->prepare("UPDATE auth_tag_structure SET tagfield=?, liblibrarian=?, libopac=?, repeatable=?, mandatory=?, authorised_value=? WHERE authtypecode=? AND tagfield=?");
        my $tagfield       =$input->param('tagfield');
        my $liblibrarian  = $input->param('liblibrarian');
        my $libopac       =$input->param('libopac');
        my $repeatable =$input->param('repeatable');
        my $mandatory =$input->param('mandatory');
        my $authorised_value =$input->param('authorised_value');
        unless (C4::Context->config('demo') eq 1) {
            $sth->execute(
                            $tagfield,
                            $liblibrarian,
                            $libopac,
                            $repeatable?1:0,
                            $mandatory?1:0,
                            $authorised_value,
                            $authtypecode,
                            $tagfield,
                            );
        }
        $sth->finish;
    } else {
        $sth=$dbh->prepare("INSERT INTO auth_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value,authtypecode) VALUES (?,?,?,?,?,?,?)");
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
                            $authtypecode
                            );
        }
        $sth->finish;
    }
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=auth_tag_structure.pl?searchfield=".$input->param('tagfield')."&authtypecode=$authtypecode\">";
	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where tagfield=?");
	$sth->execute($searchfield);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(liblibrarian => $data->{'liblibrarian'},
							searchfield => $searchfield,
							authtypecode => $authtypecode,
							);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	unless (C4::Context->config('demo') eq 1) {
		$dbh->do("delete from auth_tag_structure where tagfield='$searchfield' and authtypecode='$authtypecode'");
		$dbh->do("delete from auth_subfield_structure where tagfield='$searchfield' and authtypecode='$authtypecode'");
	}
    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=auth_tag_structure.pl?searchfield=".$input->param('tagfield')."&authtypecode=$authtypecode\">";
    exit;
													# END $OP eq DELETE_CONFIRMED
################## ITEMTYPE_CREATE ##################################
# called automatically if an unexisting authtypecode is selected
} elsif ($op eq 'authtype_create') {
	$sth = $dbh->prepare("select count(*),auth_tag_structure.authtypecode,authtypetext from auth_tag_structure,auth_types where auth_types.authtypecode=auth_tag_structure.authtypecode group by auth_tag_structure.authtypecode");
	$sth->execute;
	my @existingauthtypeloop;
	while (my ($tot,$thisauthtype,$authtypetext) = $sth->fetchrow) {
		if ($tot>0) {
			my %line = ( value => $thisauthtype,
						authtypetext => $authtypetext,
					);
			push @existingauthtypeloop,\%line;
		}
	}
	$template->param(existingauthtypeloop => \@existingauthtypeloop,
					authtypecode => $authtypecode,
					);
################## DEFAULT ##################################
} else { # DEFAULT
	# here, $op can be unset or set to "authtype_create_confirm".
#	warn "authtype : $authtypecode";
	if  ($searchfield ne '') {
		 $template->param(searchfield => $searchfield);
	}
	my ($count,$results)=StringSearch($searchfield,$authtypecode);
	my $toggle=1;
	my @loop_data = ();
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 1){
			$toggle=0;
	  	} else {
			$toggle=1;
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{tagfield} = $results->[$i]{'tagfield'};
		$row_data{liblibrarian} = $results->[$i]{'liblibrarian'};
		$row_data{repeatable} = $results->[$i]{'repeatable'};
		$row_data{mandatory} = $results->[$i]{'mandatory'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{subfield_link} ="auth_subfields_structure.pl?tagfield=".$results->[$i]{'tagfield'}."&amp;authtypecode=".$authtypecode;
		$row_data{edit} = "$script_name?op=add_form&amp;searchfield=".$results->[$i]{'tagfield'}."&amp;authtypecode=".$authtypecode;
		$row_data{delete} = "$script_name?op=delete_confirm&amp;searchfield=".$results->[$i]{'tagfield'}."&amp;authtypecode=".$authtypecode;
		$row_data{toggle} = $toggle;
		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data,
					authtypecode => $authtypecode,
	);
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

$template->param(loggeninuser => $loggedinuser,
		);

output_html_with_http_headers $input, $cookie, $template->output;


#
# the sub used for searches
#
sub StringSearch  {
	my ($searchstring,$authtypecode)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where (tagfield >= ? and authtypecode=?) order by tagfield");
	$sth->execute($data[0], $authtypecode);
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
sub duplicate_auth_framework {
	my ($newauthtype,$oldauthtype) = @_;
#	warn "TO $newauthtype FROM $oldauthtype";
	my $sth = $dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from auth_tag_structure where authtypecode=?");
	$sth->execute($oldauthtype);
	my $sth_insert = $dbh->prepare("insert into auth_tag_structure  (tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, authtypecode) values (?,?,?,?,?,?,?)");
	while ( my ($tagfield,$liblibrarian,$libopac,$repeatable,$mandatory,$authorised_value) = $sth->fetchrow) {
		$sth_insert->execute($tagfield,$liblibrarian,$libopac,$repeatable,$mandatory,$authorised_value,$newauthtype);
	}

	$sth = $dbh->prepare("select tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,value_builder,seealso,hidden from auth_subfield_structure where authtypecode=?");
	$sth->execute($oldauthtype);
	$sth_insert = $dbh->prepare("insert into auth_subfield_structure (authtypecode,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,authorised_value,value_builder,seealso,hidden) values (?,?,?,?,?,?,?,?,?,?,?,?,?)");
	while ( my ( $tagfield, $tagsubfield, $liblibrarian, $libopac, $repeatable, $mandatory, $kohafield,$tab, $authorised_value, $thesaurus_category, $seealso,$hidden) = $sth->fetchrow) {
		$sth_insert->execute($newauthtype, $tagfield, $tagsubfield, $liblibrarian, $libopac, $repeatable, $mandatory,$kohafield, $tab, $authorised_value, $thesaurus_category, $seealso,$hidden);
	}
}

