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
use C4::Auth;
use CGI;
use C4::Context;


sub string_search  {
	my ($searchstring,$authtypecode)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $sth=$dbh->prepare("Select * from auth_subfield_structure where (tagfield like ? and authtypecode=?) order by tagfield");
	$sth->execute("$searchstring%",$authtypecode);
	my $results = $sth->fetchall_arrayref({});
	return (scalar(@$results), $results);
}

sub auth_subfield_structure_exists {
	my ($authtypecode, $tagfield, $tagsubfield) = @_;
	my $dbh  = C4::Context->dbh;
	my $sql  = "select tagfield from auth_subfield_structure where authtypecode = ? and tagfield = ? and tagsubfield = ?";
	my $rows = $dbh->selectall_arrayref($sql, {}, $authtypecode, $tagfield, $tagsubfield);
	return @$rows > 0;
}

my $input        = new CGI;
my $tagfield     = $input->param('tagfield');
my $tagsubfield  = $input->param('tagsubfield');
my $authtypecode = $input->param('authtypecode');
my $offset       = $input->param('offset');
my $op           = $input->param('op') || '';
my $script_name  = "/cgi-bin/koha/admin/auth_subfields_structure.pl";

my ($template, $borrowernumber, $cookie) = get_template_and_user(
    {   template_name   => "admin/auth_subfields_structure.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { parameters => 1 },
        debug           => 1,
    }
);
my $pagesize = 30;
$tagfield =~ s/\,//g;

if ($op) {
$template->param(script_name => $script_name,
						tagfield =>$tagfield,
						authtypecode => $authtypecode,
						$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
						tagfield =>$tagfield,
						authtypecode => $authtypecode,
						else              => 1); # we show only the TMPL_VAR names $op
}

my $dbh = C4::Context->dbh;
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	my $data;
	my $more_subfields = $input->param("more_subfields")+1;
	# builds kohafield tables
	my @kohafields;
	push @kohafields, "";
	my $sth2=$dbh->prepare("SHOW COLUMNS from auth_header");
	$sth2->execute;
	while ((my $field) = $sth2->fetchrow_array) {
		push @kohafields, "auth_header.".$field;
	}
	
	# build authorised value list
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
    $sth2 = $dbh->prepare("select authtypecode from auth_types");
    $sth2->execute;
    my @authtypes;
    push @authtypes, "";
    while ( ( my $authtypecode ) = $sth2->fetchrow_array ) {
        push @authtypes, $authtypecode;
    }

	# build value_builder list
	my @value_builder=('');

	# read value_builder directory.
	# 2 cases here : on CVS install, $cgidir does not need a /cgi-bin
	# on a standard install, /cgi-bin need to be added. 
	# test one, then the other
	my $cgidir = C4::Context->intranetdir ."/cgi-bin";
	unless (opendir(DIR, "$cgidir/cataloguing/value_builder")) {
		$cgidir = C4::Context->intranetdir;
		opendir(DIR, "$cgidir/cataloguing/value_builder") || die "can't opendir $cgidir/value_builder: $!";
	} 
	while (my $line = readdir(DIR)) {
		if ($line =~ /\.pl$/) {
			push (@value_builder,$line);
		}
	}
        @value_builder= sort {$a cmp $b} @value_builder;
	closedir DIR;

	# build values list
	my $sth=$dbh->prepare("select * from auth_subfield_structure where tagfield=? and authtypecode=?"); # and tagsubfield='$tagsubfield'");
	$sth->execute($tagfield,$authtypecode);
	my @loop_data = ();
	my $toggle=1;
	my $i=0;
	while ($data =$sth->fetchrow_hashref) {

		my %row_data;  # get a fresh hash for the row data
		if ($toggle eq 1){
			$toggle=0;
	  	} else {
			$toggle=1;
	  	}
		$row_data{tab} = CGI::scrolling_list(-name=>'tab',
					-id=>"tab$i",
                                        -values =>
                                        [ '-1', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' ],
                                        -labels => {
                                            '-1' => 'ignore',
                                            '0'  => '0',
                                            '1'  => '1',
                                            '2'  => '2',
                                            '3'  => '3',
                                            '4'  => '4',
                                            '5'  => '5',
                                            '6'  => '6',
                                            '7'  => '7',
                                            '8'  => '8',
                                            '9'  => '9',
                                        },
					-default=>$data->{'tab'},
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		$row_data{ohidden} = CGI::scrolling_list(-name=>'ohidden',
					-id=>"ohidden$i",
					-values=>['0','1','2'],
					-labels => {'0'=>'Show','1'=>'Show Collapsed',
									'2' =>'Hide',
									},
					-default=>substr($data->{'hidden'},0,1),
					-size=>1,
					-multiple=>0,
					);
		$row_data{ihidden} = CGI::scrolling_list(-name=>'ihidden',
					-id=>"ihidden$i",
					-values=>['0','1','2'],
					-labels => {'0'=>'Show','1'=>'Show Collapsed',
									'2' =>'Hide',
									},
					-default=>substr($data->{'hidden'},1,1),
					-size=>1,
					-multiple=>0,
					);
		$row_data{ehidden} = CGI::scrolling_list(-name=>'ehidden',
					-id=>"ehidden$i",
					-values=>['0','1','2'],
					-labels => {'0'=>'Show','1'=>'Show Collapsed',
									'2' =>'Hide',
									},
					-default=>substr($data->{'hidden'}."  ",2,1),
					-size=>1,
					-multiple=>0,
					);
		$row_data{tagsubfieldinput} = "<input type=\"hidden\" name=\"tagsubfield\" value=\"".$data->{'tagsubfield'}."\" id=\"tagsubfield\" />";
		$row_data{tagsubfield} = $data->{'tagsubfield'};
		$row_data{liblibrarian} = CGI::escapeHTML($data->{'liblibrarian'});
		$row_data{libopac} = CGI::escapeHTML($data->{'libopac'});
		$row_data{seealso} = CGI::escapeHTML($data->{'seealso'});
		$row_data{kohafield}= CGI::scrolling_list( -name=>"kohafield",
					-id=>"kohafield$i",
					-values=> \@kohafields,
					-default=> "$data->{'kohafield'}",
					-size=>1,
					-multiple=>0,
					);
		$row_data{authorised_value}  = CGI::scrolling_list(-name=>'authorised_value',
					-id=>"authorised_value$i",
					-values=> \@authorised_values,
					-default=>$data->{'authorised_value'},
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		$row_data{frameworkcode}  = CGI::scrolling_list(-name=>'frameworkcode',
					-id=>"frameworkcode$i",
					-values=> \@authtypes,
					-default=>$data->{'frameworkcode'},
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		$row_data{value_builder}  = CGI::scrolling_list(-name=>'value_builder',
					-id=>"value_builder$i",
					-values=> \@value_builder,
					-default=>$data->{'value_builder'},
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		
		$row_data{repeatable} = CGI::checkbox(-name=>"repeatable$i",
	-checked => $data->{'repeatable'}?'checked':'',
	-value => 1,
	-label => '',
	-id => "repeatable$i");
		$row_data{mandatory} = CGI::checkbox(-name => "mandatory$i",
	-checked => $data->{'mandatory'}?'checked':'',
	-value => 1,
	-label => '',
	-id => "mandatory$i");
		$row_data{hidden} = CGI::escapeHTML($data->{hidden}) ;
		$row_data{isurl} = CGI::checkbox( -name => "isurl$i",
			-id => "isurl$i",
			-checked => $data->{'isurl'}?'checked':'',
			-value => 1,
			-label => '');
		$row_data{row} = $i;
		$row_data{toggle} = $toggle;
		push(@loop_data, \%row_data);
		$i++;
	}
	# add more_subfields empty lines for add if needed
	for (my $i=1;$i<=$more_subfields;$i++) {
		my %row_data;  # get a fresh hash for the row data
        $row_data{'new_subfield'} = 1;
		$row_data{tab} = CGI::scrolling_list(-name=>'tab',
					-id => "tab$i",
                                        -values =>
                                        [ '-1', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10' ],
                                        -labels => {
                                            '-1' => 'ignore',
                                            '0'  => '0',
                                            '1'  => '1',
                                            '2'  => '2',
                                            '3'  => '3',
                                            '4'  => '4',
                                            '5'  => '5',
                                            '6'  => '6',
                                            '7'  => '7',
                                            '8'  => '8',
                                            '9'  => '9',
                                        },
					-default=>"",
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		$row_data{ohidden} = CGI::scrolling_list(-name=>'ohidden',
					-id=>"ohidden$i",
					-values=>['0','1','2'],
					-labels => {'0'=>'Show','1'=>'Show Collapsed',
									'2' =>'Hide',
									},
					-default=>"0",
					-size=>1,
					-multiple=>0,
					);

		$row_data{ihidden} = CGI::scrolling_list(-name=>'ihidden',
					-id=>"ihidden$i",
					-values=>['0','1','2'],
					-labels => {'0'=>'Show','1'=>'Show Collapsed',
									'2' =>'Hide',
									},
					-default=>"0",
					-size=>1,
					-multiple=>0,
					);
		$row_data{ehidden} = CGI::scrolling_list(-name=>'ehidden',
					-id=>"ehidden$i",
					-values=>['0','1','2'],
					-labels => {'0'=>'Show','1'=>'Show Collapsed',
									'2' =>'Hide',
									},
					-default=>"0",
					-size=>1,
					-multiple=>0,
					);
		$row_data{tagsubfieldinput} = 
			"<label><input type=\"text\" name=\"tagsubfield\" value=\""
			. $data->{'tagsubfield'}
			. "\" size=\"1\" id=\"tagsubfield\" maxlength=\"1\" /></label>";
		$row_data{tagsubfield} = $data->{'tagsubfield'};
		$row_data{liblibrarian} = "";
		$row_data{libopac} = "";
		$row_data{seealso} = "";
		$row_data{hidden} = "000";
		$row_data{repeatable} = CGI::checkbox( -name=> 'repeatable',
				-id => "repeatable$i",
				-checked => '',
				-value => 1,
				-label => '');
		$row_data{mandatory} = CGI::checkbox( -name=> 'mandatory',
			-id => "mandatory$i",
			-checked => '',
			-value => 1,
			-label => '');
		$row_data{isurl} = CGI::checkbox(-name => 'isurl',
			-id => "isurl$i",
			-checked => '',
			-value => 1,
			-label => '');
		$row_data{kohafield}= CGI::scrolling_list( -name=>'kohafield',
					-id => "kohafield$i",
					-values=> \@kohafields,
					-default=> "",
					-size=>1,
					-multiple=>0,
					);
		$row_data{frameworkcode}  = CGI::scrolling_list(-name=>'frameworkcode',
					-id=>'frameworkcode',
					-values=> \@authtypes,
					-default=>$data->{'frameworkcode'},
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		$row_data{authorised_value}  = CGI::scrolling_list(-name=>'authorised_value',
					-id => 'authorised_value',
					-values=> \@authorised_values,
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		$row_data{value_builder}  = CGI::scrolling_list(-name=>'value_builder',
					-id=>'value_builder',
					-values=> \@value_builder,
					-default=>$data->{'value_builder'},
					-size=>1,
		 			-tabindex=>'',
					-multiple=>0,
					);
		$row_data{toggle} = $toggle;
		$row_data{row} = $i;
		push(@loop_data, \%row_data);
	}
	$template->param('use-heading-flags-p' => 1);
	$template->param('heading-edit-subfields-p' => 1);
	$template->param(action => "Edit subfields",
							tagfield => $tagfield,
							tagfieldinput => "<input type=\"hidden\" name=\"tagfield\" value=\"$tagfield\" />",
							loop => \@loop_data,
							more_subfields => $more_subfields,
							more_tag => $tagfield);

												# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	$template->param(tagfield => "$input->param('tagfield')");
#	my $sth=$dbh->prepare("replace auth_subfield_structure (authtypecode,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,seealso,authorised_value,frameworkcode,value_builder,hidden,isurl)
#									values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	my $sth_insert = $dbh->prepare("insert into auth_subfield_structure (authtypecode,tagfield,tagsubfield,liblibrarian,libopac,repeatable,mandatory,kohafield,tab,seealso,authorised_value,frameworkcode,value_builder,hidden,isurl)
									values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
	my $sth_update = $dbh->prepare("update auth_subfield_structure set authtypecode=?, tagfield=?, tagsubfield=?, liblibrarian=?, libopac=?, repeatable=?, mandatory=?, kohafield=?, tab=?, seealso=?, authorised_value=?, frameworkcode=?, value_builder=?, hidden=?, isurl=?
									where authtypecode=? and tagfield=? and tagsubfield=?");
	my @tagsubfield	= $input->param('tagsubfield');
	my @liblibrarian	= $input->param('liblibrarian');
	my @libopac		= $input->param('libopac');
	my @kohafield		= ''.$input->param('kohafield');
	my @tab				= $input->param('tab');
	my @seealso		= $input->param('seealso');
	my @hidden;
	my @ohidden		= $input->param('ohidden');
	my @ihidden		= $input->param('ihidden');
	my @ehidden		= $input->param('ehidden');
	my @authorised_values	= $input->param('authorised_value');
	my $authtypecode	= $input->param('authtypecode');
	my @frameworkcodes	= $input->param('frameworkcode');
	my @value_builder	=$input->param('value_builder');
	for (my $i=0; $i<= $#tagsubfield ; $i++) {
		my $tagfield			=$input->param('tagfield');
		my $tagsubfield		=$tagsubfield[$i];
		$tagsubfield="@" unless $tagsubfield ne '';
		my $liblibrarian		=$liblibrarian[$i];
		my $libopac			=$libopac[$i];
		my $repeatable		=$input->param("repeatable$i")?1:0;
		my $mandatory		=$input->param("mandatory$i")?1:0;
		my $kohafield		=$kohafield[$i];
		my $tab				=$tab[$i];
		my $seealso				=$seealso[$i];
		my $authorised_value		=$authorised_values[$i];
		my $frameworkcode		=$frameworkcodes[$i];
		my $value_builder=$value_builder[$i];
		my $hidden = $ohidden[$i].$ihidden[$i].$ehidden[$i]; #collate from 3 hiddens;
		my $isurl = $input->param("isurl$i")?1:0;
		if ($liblibrarian) {
			unless (C4::Context->config('demo') eq 1) {
				if (auth_subfield_structure_exists($authtypecode, $tagfield, $tagsubfield)) {
					$sth_update->execute(
						$authtypecode,
						$tagfield,
						$tagsubfield,
						$liblibrarian,
						$libopac,
						$repeatable,
						$mandatory,
						$kohafield,
						$tab,
						$seealso,
						$authorised_value,
						$frameworkcode,
						$value_builder,
						$hidden,
						$isurl,
						(
							$authtypecode,
							$tagfield,
							$tagsubfield
						),
					);
				} else {
					$sth_insert->execute(
						$authtypecode,
						$tagfield,
						$tagsubfield,
						$liblibrarian,
						$libopac,
						$repeatable,
						$mandatory,
						$kohafield,
						$tab,
						$seealso,
						$authorised_value,
						$frameworkcode,
						$value_builder,
						$hidden,
						$isurl,
					);
				}
			}
		}
	}
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=auth_subfields_structure.pl?tagfield=$tagfield&authtypecode=$authtypecode\"></html>";
	exit;

													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $sth=$dbh->prepare("select * from auth_subfield_structure where tagfield=? and tagsubfield=? and authtypecode=?");
	$sth->execute($tagfield,$tagsubfield,$authtypecode);
	my $data=$sth->fetchrow_hashref;
	$template->param(liblibrarian => $data->{'liblibrarian'},
							tagsubfield => $data->{'tagsubfield'},
							delete_link => $script_name,
							tagfield      =>$tagfield,
							tagsubfield => $tagsubfield,
							authtypecode => $authtypecode,
							);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	unless (C4::Context->config('demo') eq 1) {
		my $sth=$dbh->prepare("delete from auth_subfield_structure where tagfield=? and tagsubfield=? and authtypecode=?");
		$sth->execute($tagfield,$tagsubfield,$authtypecode);
	}
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=auth_subfields_structure.pl?tagfield=$tagfield&authtypecode=$authtypecode\"></html>";
	exit;
	$template->param(tagfield => $tagfield);
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	my ($count,$results)=string_search($tagfield,$authtypecode);
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
		$row_data{tagsubfield} = $results->[$i]{'tagsubfield'};
		$row_data{liblibrarian} = $results->[$i]{'liblibrarian'};
		$row_data{kohafield} = $results->[$i]{'kohafield'};
		$row_data{repeatable} = $results->[$i]{'repeatable'};
		$row_data{mandatory} = $results->[$i]{'mandatory'};
		$row_data{tab} = $results->[$i]{'tab'};
		$row_data{seealso} = $results->[$i]{'seealso'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{authtypecode}	= $results->[$i]{'authtypecode'};
		$row_data{value_builder}	= $results->[$i]{'value_builder'};
		$row_data{hidden}	= $results->[$i]{'hidden'} if($results->[$i]{'hidden'} gt "000") ;
		$row_data{isurl}	= $results->[$i]{'isurl'};
		$row_data{delete} = "$script_name?op=delete_confirm&amp;tagfield=$tagfield&amp;tagsubfield=".$results->[$i]{'tagsubfield'}."&amp;authtypecode=$authtypecode";
		$row_data{toggle} = $toggle;
		if ($row_data{tab} eq -1) {
			$row_data{subfield_ignored} = 1;
		}

		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	$template->param(edit_tagfield => $tagfield,
		edit_authtypecode => $authtypecode);
	
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
