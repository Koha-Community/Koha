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
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Auth;
use CGI;
use C4::Search;
use C4::Context;
use HTML::Template;

sub StringSearch  {
	my ($env,$searchstring,$frameworkcode)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select * from marc_subfield_structure where (tagfield like ? and frameworkcode=?) order by tagfield");
	$sth->execute("$searchstring%",$frameworkcode);
	my @results;
	my $cnt=0;
	while (my $data=$sth->fetchrow_hashref){
		push(@results,$data);
		$cnt ++;
	}
	$sth->finish;
	$dbh->disconnect;
	return ($cnt,\@results);
}

my $input = new CGI;
my $tagfield=$input->param('tagfield');
my $tagsubfield=$input->param('tagsubfield');
my $frameworkcode=$input->param('frameworkcode');
my $pkfield="tagfield";
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/marc_subfields_structure.pl";

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/marc_subfields_structure.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
my $pagesize=30;
my $op = $input->param('op');
$tagfield=~ s/\,//g;

if ($op) {
$template->param(script_name => $script_name,
						tagfield =>$tagfield,
						frameworkcode => $frameworkcode,
						$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
						tagfield =>$tagfield,
						frameworkcode => $frameworkcode,
						else              => 1); # we show only the TMPL_VAR names $op
}

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	my $data;
	my $dbh = C4::Context->dbh;
	my $more_subfields = $input->param("more_subfields")+1;
	# builds kohafield tables
	my @kohafields;
	push @kohafields, "";
	my $sth2=$dbh->prepare("SHOW COLUMNS from biblio");
	$sth2->execute;
	while ((my $field) = $sth2->fetchrow_array) {
		push @kohafields, "biblio.".$field;
	}
	my $sth2=$dbh->prepare("SHOW COLUMNS from biblioitems");
	$sth2->execute;
	while ((my $field) = $sth2->fetchrow_array) {
		if ($field eq 'notes') { $field = 'bnotes'; }
		push @kohafields, "biblioitems.".$field;
	}
	my $sth2=$dbh->prepare("SHOW COLUMNS from items");
	$sth2->execute;
	while ((my $field) = $sth2->fetchrow_array) {
		push @kohafields, "items.".$field;
	}
	
	# other subfields
	push @kohafields, "additionalauthors.author";
	push @kohafields, "bibliosubject.subject";
	push @kohafields, "bibliosubtitle.title";
	# build authorised value list
	$sth2->finish;
	$sth2 = $dbh->prepare("select distinct category from authorised_values");
	$sth2->execute;
	my @authorised_values;
	push @authorised_values,"";
	while ((my $category) = $sth2->fetchrow_array) {
		push @authorised_values, $category;
	}
	push (@authorised_values,"branches");
	push (@authorised_values,"itemtypes");
	# build thesaurus categories list
	$sth2->finish;
	$sth2 = $dbh->prepare("select distinct category from bibliothesaurus");
	$sth2->execute;
	my @thesaurus_category;
	push @thesaurus_category,"";
	while ((my $category) = $sth2->fetchrow_array) {
		push @thesaurus_category, $category;
	}
	# build value_builder list
	my @value_builder=('');
	opendir(DIR, "../value_builder") || die "can't opendir ../value_builder: $!";
	while (my $line = readdir(DIR)) {
		if ($line =~ /\.pl$/) {
			push (@value_builder,$line);
		}
	}
	closedir DIR;

	# build values list
	my $sth=$dbh->prepare("select * from marc_subfield_structure where tagfield=? and frameworkcode=?"); # and tagsubfield='$tagsubfield'");
	$sth->execute($tagfield,$frameworkcode);
	my @loop_data = ();
	my $toggle="white";
	my $i=0;
	while ($data =$sth->fetchrow_hashref) {
		my %row_data;  # get a fresh hash for the row data
		if ($toggle eq 'white'){
			$toggle="#ffffcc";
	  	} else {
			$toggle="white";
	  	}
		$row_data{tab} = CGI::scrolling_list(-name=>'tab',
					-values=>['-1','0','1','2','3','4','5','6','7','8','9','10'],
					-labels => {'-1' =>'ignore','0'=>'0','1'=>'1',
									'2' =>'2','3'=>'3','4'=>'4',
									'5' =>'5','6'=>'6','7'=>'7',
									'8' =>'8','9'=>'9','10'=>'items (10)',
									},
					-default=>$data->{'tab'},
					-size=>1,
					-multiple=>0,
					);
		$row_data{tagsubfield} =$data->{'tagsubfield'}."<input type='hidden' name='tagsubfield' value='".$data->{'tagsubfield'}."'>";
		$row_data{liblibrarian} = CGI::escapeHTML($data->{'liblibrarian'});
		$row_data{libopac} = CGI::escapeHTML($data->{'libopac'});
		$row_data{seealso} = CGI::escapeHTML($data->{'seealso'});
		$row_data{kohafield}= CGI::scrolling_list( -name=>"kohafield",
					-values=> \@kohafields,
					-default=> "$data->{'kohafield'}",
					-size=>1,
					-multiple=>0,
					);
		$row_data{authorised_value}  = CGI::scrolling_list(-name=>'authorised_value',
					-values=> \@authorised_values,
					-default=>$data->{'authorised_value'},
					-size=>1,
					-multiple=>0,
					);
		$row_data{value_builder}  = CGI::scrolling_list(-name=>'value_builder',
					-values=> \@value_builder,
					-default=>$data->{'value_builder'},
					-size=>1,
					-multiple=>0,
					);
		$row_data{thesaurus_category}  = CGI::scrolling_list(-name=>'thesaurus_category',
					-values=> \@thesaurus_category,
					-default=>$data->{'thesaurus_category'},
					-size=>1,
					-multiple=>0,
					);
		$row_data{repeatable} = CGI::checkbox("repeatable$i",$data->{'repeatable'}?'checked':'',1,'');
		$row_data{mandatory} = CGI::checkbox("mandatory$i",$data->{'mandatory'}?'checked':'',1,'');
		$row_data{hidden} = CGI::checkbox("hidden$i",$data->{'hidden'}?'checked':'',1,'');
		$row_data{isurl} = CGI::checkbox("isurl$i",$data->{'isurl'}?'checked':'',1,'');
		$row_data{bgcolor} = $toggle;
		push(@loop_data, \%row_data);
		$i++;
	}
	# add more_subfields empty lines for add if needed
	for (my $i=1;$i<=$more_subfields;$i++) {
		my %row_data;  # get a fresh hash for the row data
		$row_data{tab} = CGI::scrolling_list(-name=>'tab',
					-values=>['-1','0','1','2','3','4','5','6','7','8','9','10'],
					-labels => {'-1' =>'ignore','0'=>'0','1'=>'1',
									'2' =>'2','3'=>'3','4'=>'4',
									'5' =>'5','6'=>'6','7'=>'7',
									'8' =>'8','9'=>'9','10'=>'items (10)',
									},
					-default=>"",
					-size=>1,
					-multiple=>0,
					);
		$row_data{tagsubfield} = "<input type=\"text\" name=\"tagsubfield\" value=\"".$data->{'tagsubfield'}."\" size=\"3\" maxlength=\"1\">";
		$row_data{liblibrarian} = "";
		$row_data{libopac} = "";
		$row_data{seealso} = "";
		$row_data{repeatable} = CGI::checkbox('repeatable','',1,'');
		$row_data{mandatory} = CGI::checkbox('mandatory','',1,'');
		$row_data{hidden} = CGI::checkbox('hidden','',1,'');
		$row_data{isurl} = CGI::checkbox('isurl','',1,'');
		$row_data{kohafield}= CGI::scrolling_list( -name=>'kohafield',
					-values=> \@kohafields,
					-default=> "",
					-size=>1,
					-multiple=>0,
					);
		$row_data{authorised_value}  = CGI::scrolling_list(-name=>'authorised_value',
					-values=> \@authorised_values,
					-size=>1,
					-multiple=>0,
					);
		$row_data{thesaurus_category}  = CGI::scrolling_list(-name=>'thesaurus_category',
					-values=> \@thesaurus_category,
					-size=>1,
					-multiple=>0,
					);
		$row_data{bgcolor} = $toggle;
		push(@loop_data, \%row_data);
	}
	$template->param('use-heading-flags-p' => 1);
	$template->param('heading-edit-subfields-p' => 1);
	$template->param(action => "Edit subfields",
							tagfield => "<input type=\"hidden\" name=\"tagfield\" value=\"$tagfield\">$tagfield",
							loop => \@loop_data,
							more_subfields => $more_subfields,
							more_tag => $tagfield);

												# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	$template->param(tagfield => "$input->param('tagfield')");
	my $sth=$dbh->prepare("replace marc_subfield_structure (tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,seealso,authorised_value,thesaurus_category,value_builder,hidden,isurl,frameworkcode)
									values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	my @tagsubfield	= $input->param('tagsubfield');
	my @liblibrarian	= $input->param('liblibrarian');
	my @libopac		= $input->param('libopac');
	my @kohafield		= $input->param('kohafield');
	my @tab				= $input->param('tab');
	my @seealso		= $input->param('seealso');
	my @authorised_values	= $input->param('authorised_value');
	my @thesaurus_category	= $input->param('thesaurus_category');
	my @value_builder	=$input->param('value_builder');
	for (my $i=0; $i<= $#tagsubfield ; $i++) {
		my $tagfield			=$input->param('tagfield');
		my $tagsubfield		=$tagsubfield[$i];
		$tagsubfield="@" unless $tagsubfield;
		my $liblibrarian		=$liblibrarian[$i];
		my $libopac			=$libopac[$i];
		my $repeatable		=$input->param("repeatable$i")?1:0;
		my $mandatory		=$input->param("mandatory$i")?1:0;
		my $kohafield		=$kohafield[$i];
		my $tab				=$tab[$i];
		my $seealso				=$seealso[$i];
		my $authorised_value		=$authorised_values[$i];
		my $thesaurus_category		=$thesaurus_category[$i];
		my $value_builder=$value_builder[$i];
		my $hidden = $input->param("hidden$i")?1:0;
		my $isurl = $input->param("isurl$i")?1:0;
		if ($liblibrarian) {
			unless (C4::Context->config('demo') eq 1) {
				$sth->execute ($tagfield,
									$tagsubfield,
									$liblibrarian,
									$libopac,
									$repeatable,
									$mandatory,
									$kohafield,
									$tab,
									$seealso,
									$authorised_value,
									$thesaurus_category,
									$value_builder,
									$hidden,
									$isurl,
									$frameworkcode,
									);
			}
		}
	}
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=marc_subfields_structure.pl?tagfield=$tagfield&frameworkcode=$frameworkcode\"></html>";
	exit;

													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select * from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?");
	$sth->execute($tagfield,$tagsubfield);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(liblibrarian => $data->{'liblibrarian'},
							tagsubfield => $data->{'tagsubfield'},
							delete_link => $script_name,
							tagfield      =>$tagfield,
							tagsubfield => $tagsubfield,
							frameworkcode => $frameworkcode,
							);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	unless (C4::Context->config('demo') eq 1) {
		my $sth=$dbh->prepare("delete from marc_subfield_structure where tagfield=? and tagsubfield=? and frameworkcode=?");
		$sth->execute($tagfield,$tagsubfield,$frameworkcode);
		$sth->finish;
	}
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=marc_subfields_structure.pl?tagfield=$tagfield&frameworkcode=$frameworkcode\"></html>";
	exit;
	$template->param(tagfield => $tagfield);
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	my $env;
	my ($count,$results)=StringSearch($env,$tagfield,$frameworkcode);
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
		$row_data{tagsubfield} = $results->[$i]{'tagsubfield'};
		$row_data{liblibrarian} = $results->[$i]{'liblibrarian'};
		$row_data{kohafield} = $results->[$i]{'kohafield'};
		$row_data{repeatable} = $results->[$i]{'repeatable'};
		$row_data{mandatory} = $results->[$i]{'mandatory'};
		$row_data{tab} = $results->[$i]{'tab'};
		$row_data{seealso} = $results->[$i]{'seealso'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{thesaurus_category}	= $results->[$i]{'thesaurus_category'};
		$row_data{value_builder}	= $results->[$i]{'value_builder'};
		$row_data{hidden}	= $results->[$i]{'hidden'};
		$row_data{isurl}	= $results->[$i]{'isurl'};
		$row_data{delete} = "$script_name?op=delete_confirm&amp;tagfield=$tagfield&amp;tagsubfield=".$results->[$i]{'tagsubfield'}."&frameworkcode=$frameworkcode";
		$row_data{bgcolor} = $toggle;
		if ($row_data{tab} eq -1) {
			$row_data{subfield_ignored} = 1;
		}

		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	$template->param(edit => "<a href=\"$script_name?op=add_form&amp;tagfield=$tagfield&frameworkcode=$frameworkcode\">");
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(prev =>"<a href=\"$script_name?offset=$prevpage\">");
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(next => "<a href=\"$script_name?offset=$nextpage\">");
	}
} #---- END $OP eq DEFAULT

output_html_with_http_headers $input, $cookie, $template->output;
