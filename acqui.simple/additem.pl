#!/usr/bin/perl

# $Id$

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

use CGI;
use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use C4::Search;
use HTML::Template;
use MARC::File::USMARC;

sub find_value {
	my ($tagfield,$insubfield,$record) = @_;
	my $result;
	my $indicator;
	foreach my $field ($record->field($tagfield)) {
		my @subfields = $field->subfields();
		foreach my $subfield (@subfields) {
			if (@$subfield[0] eq $insubfield) {
				$result .= @$subfield[1];
				$indicator = $field->indicator(1).$field->indicator(2);
			}
		}
	}
	return($indicator,$result);
}
my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error = $input->param('error');
my $bibid = $input->param('bibid');
my $oldbiblionumber = &MARCfind_oldbiblionumber_from_MARCbibid($dbh,$bibid);

my $op = $input->param('op');
my $itemnum = $input->param('itemnum');

my $tagslib = &MARCgettagslib($dbh,1);
my $record = MARCgetbiblio($dbh,$bibid);
my $itemrecord;
my $nextop="additem";
my @errors; # store errors found while checking data BEFORE saving item.
#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "additem") {
#------------------------------------------------------------------------------------------------------------------------------
	# rebuild
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
	my %indicators;
	for (my $i=0;$i<=$#ind_tag;$i++) {
		$indicators{$ind_tag[$i]} = $indicator[$i];
	}
	my $record = MARChtml2marc($dbh,\@tags,\@subfields,\@values,%indicators);
# check for item barcode # being unique
	my $oldbibid = MARCmarc2koha($dbh,$record);
	my $exists = itemdata($oldbibid->{'barcode'});
	push @errors,"barcode_not_unique" if($exists);
# MARC::Record builded => now, record in DB
	# if barcode exists, don't create, but report The problem.
	my ($oldbiblionumber,$oldbibnum,$oldbibitemnum) = NEWnewitem($dbh,$record,$bibid) unless ($exists);
	if ($exists) {
		$nextop = "additem";
		$itemrecord = $record;
	} else {
		$nextop = "additem";
	}
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "edititem") {
#------------------------------------------------------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
	$itemrecord = MARCgetitem($dbh,$bibid,$itemnum);
	$nextop="saveitem";
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "delitem") {
#------------------------------------------------------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
	&NEWdelitem($dbh,$bibid,$itemnum);
	$nextop="additem";
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "saveitem") {
#------------------------------------------------------------------------------------------------------------------------------
	# rebuild
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
#	my $itemnum = $input->param('itemnum');
	my %indicators;
	for (my $i=0;$i<=$#ind_tag;$i++) {
		$indicators{$ind_tag[$i]} = $indicator[$i];
	}
	my $record = MARChtml2marc($dbh,\@tags,\@subfields,\@values,%indicators);
# MARC::Record builded => now, record in DB
	my ($oldbiblionumber,$oldbibnum,$oldbibitemnum) = NEWmoditem($dbh,$record,$bibid,$itemnum,0);
	$itemnum="";
	$nextop="additem";
}

#
#------------------------------------------------------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#------------------------------------------------------------------------------------------------------------------------------

my %indicators;
$indicators{995}='  ';
# now, build existiing item list
my $temp = MARCgetbiblio($dbh,$bibid);
my @fields = $temp->fields();
my %witness; #---- stores the list of subfields used at least once, with the "meaning" of the code
my @big_array;
#---- finds where items.itemnumber is stored
my ($itemtagfield,$itemtagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.itemnumber");
my @itemnums; # array to store itemnums
foreach my $field (@fields) {
	next if ($field->tag()<10);
	my @subf=$field->subfields;
	my %this_row;
# loop through each subfield
	for my $i (0..$#subf) {
		next if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab}  ne 10 && ($field->tag() ne $itemtagfield && $subf[$i][0] ne $itemtagsubfield));
		$witness{$subf[$i][0]} = $tagslib->{$field->tag()}->{$subf[$i][0]}->{lib} if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab}  eq 10);
		$this_row{$subf[$i][0]} =$subf[$i][1] if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab}  eq 10);
		push @itemnums,$this_row{$subf[$i][0]} =$subf[$i][1] if ($field->tag() eq $itemtagfield && $subf[$i][0] eq $itemtagsubfield);
	}
	if (%this_row) {
		push(@big_array, \%this_row);
	}
}
#fill big_row with missing datas
foreach my $subfield_code  (keys(%witness)) {
	for (my $i=0;$i<=$#big_array;$i++) {
		$big_array[$i]{$subfield_code}="&nbsp;" unless ($big_array[$i]{$subfield_code});
	}
}
# now, construct template !
my @item_value_loop;
my @header_value_loop;
for (my $i=0;$i<=$#big_array; $i++) {
	my $items_data;
	foreach my $subfield_code (sort keys(%witness)) {
		$items_data .="<td>".$big_array[$i]{$subfield_code}."</td>";
	}
	my %row_data;
	$row_data{item_value} = $items_data;
	$row_data{itemnum} = $itemnums[$i];
	push(@item_value_loop,\%row_data);
}
foreach my $subfield_code (sort keys(%witness)) {
	my %header_value;
	$header_value{header_value} = $witness{$subfield_code};
	push(@header_value_loop, \%header_value);
}

# next item form
my @loop_data =();
my $i=0;
my $authorised_values_sth = $dbh->prepare("select authorised_value,lib from authorised_values where category=? order by authorised_value");

foreach my $tag (sort keys %{$tagslib}) {
	my $previous_tag = '';
# loop through each subfield
	foreach my $subfield (sort keys %{$tagslib->{$tag}}) {
		next if subfield_is_koha_internal_p($subfield);
		next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "10");
		my %subfield_data;
		$subfield_data{tag}=$tag;
		$subfield_data{subfield}=$subfield;
#		$subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
		$subfield_data{marc_lib}="<DIV id=\"error$i\">".$tagslib->{$tag}->{$subfield}->{lib}."</div>";
		$subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
		$subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
		my ($x,$value);
		($x,$value) = find_value($tag,$subfield,$itemrecord) if ($itemrecord);
		if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
			my @authorised_values;
			my %authorised_lib;
			# builds list, depending on authorised value...
			#---- branch
			if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
				my $sth=$dbh->prepare("select branchcode,branchname from branches");
				$sth->execute;
				push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
				while (my ($branchcode,$branchname) = $sth->fetchrow_array) {
					push @authorised_values, $branchcode;
					$authorised_lib{$branchcode}=$branchname;
				}
			#----- itemtypes
			} elsif ($tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes") {
				my $sth=$dbh->prepare("select itemtype,description from itemtypes");
				$sth->execute;
				push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
				while (my ($itemtype,$description) = $sth->fetchrow_array) {
					push @authorised_values, $itemtype;
					$authorised_lib{$itemtype}=$description;
				}
			#---- "true" authorised value
			} else {
				$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});
				push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
				while (my ($value,$lib) = $authorised_values_sth->fetchrow_array) {
					push @authorised_values, $value;
					$authorised_lib{$value}=$lib;
				}
			}
			$subfield_data{marc_value}= CGI::scrolling_list(-name=>'field_value',
																		-values=> \@authorised_values,
																		-default=>"$value",
																		-labels => \%authorised_lib,
																		-size=>1,
																		-multiple=>0,
																		);
		} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
		} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
			my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
			require $plugin;
			my $extended_param = plugin_parameters($dbh,$record,$tagslib,$i,0);
			my ($function_name,$javascript) = plugin_javascript($dbh,$record,$tagslib,$i,0);
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i)\"> <a href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
		} else {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\" size=50 maxlength=255>";
		}
#		$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\">";
		push(@loop_data, \%subfield_data);
		$i++
	}
}
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui.simple/additem.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

# what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
$template->param(item_loop => \@item_value_loop,
						item_header_loop => \@header_value_loop,
						bibid => $bibid,
						biblionumber =>$oldbiblionumber,
						item => \@loop_data,
						itemnum => $itemnum,
						itemtagfield => $itemtagfield,
						itemtagsubfield =>$itemtagsubfield,
						op => $nextop,
						opisadd => ($nextop eq "saveitem")?0:1);
foreach my $error (@errors) {
	$template->param($error => 1);
}
output_html_with_http_headers $input, $cookie, $template->output;
