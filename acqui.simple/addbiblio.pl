#!/usr/bin/perl

# $Id$

#
# TODO
#
# Add info on biblioitems and items already entered as you enter new ones
#


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
use C4::Output;
use C4::Biblio;
use C4::Context;
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

sub MARCfindbreeding {
	my ($dbh,$isbn) = @_;
	my $sth = $dbh->prepare("select file,marc from marc_breeding where isbn=?");
	$sth->execute($isbn);
	my ($file,$marc) = $sth->fetchrow;
	if ($marc) {
		my $record = MARC::File::USMARC::decode($marc);
		if (ref($record) eq undef) {
			warn "not a MARC record : $marc";
			return -1;
		} else {
			return $record;
		}
	}
	return -1;

}
my $input = new CGI;
my $error = $input->param('error');
my $oldbiblionumber=$input->param('bib'); # if bib exists, it's a modif, not a new biblio.
my $isbn = $input->param('isbn');
my $op = $input->param('op');
my $dbh = C4::Context->dbh;
my $bibid;
if ($oldbiblionumber) {;
	$bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$oldbiblionumber)
}else {
	$bibid = $input->param('bibid');
}
my $template;

my $tagslib = &MARCgettagslib($dbh,1);

my $record = MARCgetbiblio($dbh,$bibid) if ($oldbiblionumber);
my $record = MARCfindbreeding($dbh,$isbn) if ($isbn);

#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "addbiblio") {
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
#	warn "record ".$record->as_formatted();
# MARC::Record builded => now, record in DB
	my ($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbiblio($dbh,$record);
	my $authorised_values_sth = $dbh->prepare("select authorised_value from authorised_values where category=?");
# build item screen. There is no item for instance.
	my @loop_data =();
	my $i=0;
	foreach my $tag (keys %{$tagslib}) {
		my $previous_tag = '';
	# loop through each subfield
		foreach my $subfield (keys %{$tagslib->{$tag}}) {
			next if ($subfield eq 'lib');
			next if ($subfield eq 'tab');
			next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "10");
			$i++;
			my %subfield_data;
			$subfield_data{tag}=$tag;
			$subfield_data{subfield}=$subfield;
			$subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
			$subfield_data{marc_mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
			$subfield_data{marc_repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
			if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
				$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});
				my @authorised_values;
				push @authorised_values, "" unless ($subfield_data{mandatory});
				while ((my $value) = $authorised_values_sth->fetchrow_array) {
					push @authorised_values, $value;
				}
				$subfield_data{marc_value}= CGI::scrolling_list(-name=>'field_value',
																			-values=> \@authorised_values,
																			-size=>1,
																			-multiple=>0,
																			);
			} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
				$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
			} else {
				$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\">";
			}
			push(@loop_data, \%subfield_data);
		}
	}
	$template = gettemplate("acqui.simple/addbiblio2.tmpl");
	$template->param(bibid => $bibid,
							item => \@loop_data);
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "additem") {
#------------------------------------------------------------------------------------------------------------------------------
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
#	my @ind_tag = $input->param('ind_tag');
#	my @indicator = $input->param('indicator');
#	my %indicators;
#	for (my $i=0;$i<=$#ind_tag;$i++) {
#		$indicators{$ind_tag[$i]} = $indicator[$i];
#	}
	my %indicators;
	$indicators{995}='  ';
	warn "REs : $tags[0] - $tags[1] - $subfields[0] - $subfields[1] - $values[0] - $values[1]";
	my $record = MARChtml2marc($dbh,\@tags,\@subfields,\@values,%indicators);
	my ($bibid,$oldbibnum,$oldbibitemnum) = NEWnewitem($dbh,$record,$bibid);
	# now, build existiing item list
	my $temp = MARCgetbiblio($dbh,$bibid);
	my @fields = $temp->fields();
	my %witness; #---- stores the list of subfields used at least once, with the "meaning" of the code
	my @big_array;
	foreach my $field (@fields) {
		my @subf=$field->subfields;
		my %this_row;
	# loop through each subfield
		for my $i (0..$#subf) {
			next if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab}  ne 10);
			$witness{$subf[$i][0]} = $tagslib->{$field->tag()}->{$subf[$i][0]}->{lib};
			$this_row{$subf[$i][0]} =$subf[$i][1];
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
		foreach my $subfield_code (keys(%witness)) {
			$items_data .="<td>".$big_array[$i]{$subfield_code}."</td>";
		}
		my %row_data;
		$row_data{item_value} = $items_data;
		push(@item_value_loop,\%row_data);
	}
	foreach my $subfield_code (keys(%witness)) {
		my %header_value;
		$header_value{header_value} = $witness{$subfield_code};
		push(@header_value_loop, \%header_value);
	}

# next item form
	my @loop_data =();
	my $i=0;
	foreach my $tag (keys %{$tagslib}) {
		my $previous_tag = '';
	# loop through each subfield
		foreach my $subfield (keys %{$tagslib->{$tag}}) {
			next if ($subfield eq 'lib');
			next if ($subfield eq 'tab');
			next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "10");
			my %subfield_data;
			$subfield_data{tag}=$tag;
			$subfield_data{subfield}=$subfield;
			$subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
			$subfield_data{marc_mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
			$subfield_data{marc_repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\">";
			push(@loop_data, \%subfield_data);
			$i++
		}
	}
	$template = gettemplate("acqui.simple/addbiblio2.tmpl");
	$template->param(item_loop => \@item_value_loop,
							item_header_loop => \@header_value_loop,
							bibid => $bibid,
							item => \@loop_data);
#------------------------------------------------------------------------------------------------------------------------------
} else {
#------------------------------------------------------------------------------------------------------------------------------
	$template = gettemplate("acqui.simple/addbiblio.tmpl");
	# fill arrays
	my @loop_data =();
	my $tag;
	my $i=0;
	my $authorised_values_sth = $dbh->prepare("select authorised_value from authorised_values where category=?");
# loop through each tab 0 through 9
	for (my $tabloop = 0; $tabloop<=9;$tabloop++) {
	#	my @fields = $record->fields();
		my @loop_data =();
		foreach my $tag (keys %{$tagslib}) {
			my $previous_tag = '';
			my @subfields_data;
			my $indicator;
# loop through each subfield
			foreach my $subfield (keys %{$tagslib->{$tag}}) {
				next if ($subfield eq 'lib'); # skip lib and tabs, which are koha internal
				next if ($subfield eq 'tab');
				next if ($tagslib->{$tag}->{$subfield}->{tab}  ne $tabloop);
				my %subfield_data;
				$subfield_data{tag}=$tag;
				$subfield_data{subfield}=$subfield;
				$subfield_data{marc_lib}="<DIV id=\"error$i\">".$tagslib->{$tag}->{$subfield}->{lib}."</div>";
				$subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
				$subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
				# if breeding is not empty
				if ($record ne -1) {
					my ($x,$value) = find_value($tag,$subfield,$record);
					$indicator = $x if $x;
					if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
						$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});
						my @authorised_values;
						push @authorised_values, "" unless ($subfield_data{mandatory});
						while ((my $value) = $authorised_values_sth->fetchrow_array) {
							push @authorised_values, $value;
						}
						$subfield_data{marc_value}= CGI::scrolling_list(-name=>'field_value',
																					-values=> \@authorised_values,
																					-default=>"$value",
																					-size=>1,
																					-multiple=>0,
																					);
					} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
					} elsif ($tagslib->{$tag}->{$subfield}->{value_builder}) {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" DISABLE READONLY> <a href=\"javascript:Dopop('../value_builder/$tagslib->{$tag}->{$subfield}->{value_builder}?index=$i',$i)\">...</a>";
					} else {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\">";
					}
				# if breeding is empty
				} else {
					if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
						$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});
						my @authorised_values;
						push @authorised_values, "" unless ($subfield_data{mandatory});
						while ((my $value) = $authorised_values_sth->fetchrow_array) {
							push @authorised_values, $value;
						}
						$subfield_data{marc_value}= CGI::scrolling_list(-name=>'field_value',
																					-values=> \@authorised_values,
																					-size=>1,
																					-multiple=>0,
																					);
					} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
					} elsif ($tagslib->{$tag}->{$subfield}->{value_builder}) {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" DISABLE READONLY> <a href=\"javascript:Dopop('../value_builder/$tagslib->{$tag}->{$subfield}->{value_builder}?index=$i',$i)\">...</a>";
					} else {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\">";
					}
				}
				push(@subfields_data, \%subfield_data);
				$i++;
			}
			if ($#subfields_data>=0) {
				my %tag_data;
				$tag_data{tag}=$tag;
				$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
				$tag_data{indicator} = $indicator;
				$tag_data{subfield_loop} = \@subfields_data;
				push (@loop_data, \%tag_data);
			}
		}
		$template->param($tabloop."XX" =>\@loop_data);
	}
	# now, build hidden datas => we store everything, even if we show only requested subfields.
	my @loop_data =();
	my $i=0;
	foreach my $tag (keys %{$tagslib}) {
		my $previous_tag = '';
	# loop through each subfield
		foreach my $subfield (keys %{$tagslib->{$tag}}) {
			next if ($subfield eq 'lib');
			next if ($subfield eq 'tab');
			next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "-1");
			my %subfield_data;
			$subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
			$subfield_data{marc_mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
			$subfield_data{marc_repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
			$subfield_data{marc_value}="<input type=\"hidden\" name=\"field_value[]\">";
			push(@loop_data, \%subfield_data);
			$i++
		}
	}
	$template->param(
							biblionumber => $oldbiblionumber,
							bibid => $bibid);
}
print "Content-Type: text/html\n\n", $template->output;
