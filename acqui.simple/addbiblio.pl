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
use C4::Output;
use C4::Biblio;
use C4::Context;
use HTML::Template;
use MARC::File::USMARC;

sub find_value {
	my ($tagfield,$insubfield,$record) = @_;
#	warn "$tagfield / $insubfield // ";
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
			return -1;
		} else {
			return $record;
		}
	}
	return -1;

}
my $input = new CGI;
my $error = $input->param('error');
my $oldbiblionumber=$input->param('oldbiblionumber'); # if bib exists, it's a modif, not a new biblio.
my $isbn = $input->param('isbn');
my $op = $input->param('op');
my $dbh = C4::Context->dbh;
my $bibid;
if ($oldbiblionumber) {
	$bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$oldbiblionumber);
}else {
	$bibid = $input->param('bibid');
}
my $template;

my $tagslib = &MARCgettagslib($dbh,1);
my $record=-1;
$record = MARCgetbiblio($dbh,$bibid) if ($bibid);
$record = MARCfindbreeding($dbh,$isbn) if ($isbn);
my $is_a_modif=0;
if ($bibid) {
	$is_a_modif=1;
}
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
# MARC::Record builded => now, record in DB
	my $oldbibnum;
	my $oldbibitemnum;
	if ($is_a_modif) {
		($bibid,$oldbibnum,$oldbibitemnum) = NEWmodbiblio($dbh,$record,$bibid);
	} else {
		($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbiblio($dbh,$record);
	}
# now, redirect to additem page
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=additem.pl?bibid=$bibid\"></html>";
	exit;
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
		foreach my $tag (sort(keys (%{$tagslib}))) {
			my $previous_tag = '';
			my @subfields_data;
			my $indicator;
# loop through each subfield
			foreach my $subfield (sort(keys %{$tagslib->{$tag}})) {
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
						my @authorised_values;
						# builds list, depending on authorised value...
						#---- branch
						if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
							my $sth=$dbh->prepare("select branchcode,branchname from branches");
							$sth->execute;
							push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
							while (my ($branchcode,$branchname) = $sth->fetchrow_array) {
								push @authorised_values, $branchcode;
							}
						#----- itemtypes
						} elsif ($tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes") {
							my $sth=$dbh->prepare("select itemtype,description from itemtypes");
							$sth->execute;
							push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
							while (my ($itemtype,$description) = $sth->fetchrow_array) {
								push @authorised_values, $itemtype;
							}
						#---- "true" authorised value
						} else {
							$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});
							push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
							while ((my $value) = $authorised_values_sth->fetchrow_array) {
								push @authorised_values, $value;
							}
						}
						$subfield_data{marc_value}= CGI::scrolling_list(-name=>'field_value',
																					-values=> \@authorised_values,
																					-default=>"$value",
																					-size=>1,
																					-multiple=>0,
																					);
					} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>"; #"
					} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
						my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
						require $plugin;
						my $extended_param = plugin_parameters($dbh,$record,$tagslib,$i,$tabloop);
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../plugin_launcher.pl?plugin_name=$tagslib->{$tag}->{$subfield}->{value_builder}&index=$i$extended_param',$i)\">...</a>";
					} else {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\" size=50 maxlength=255>";
					}
				# if breeding is empty
				} else {
					my ($x,$value);
					($x,$value) = find_value($tag,$subfield,$record) if ($record ne -1);
					if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
						my @authorised_values;
						# builds list, depending on authorised value...
						#---- branch
						if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
							my $sth=$dbh->prepare("select branchcode,branchname from branches");
							$sth->execute;
							push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
							while (my ($branchcode,$branchname) = $sth->fetchrow_array) {
								push @authorised_values, $branchcode;
							}
						#----- itemtypes
						} elsif ($tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes") {
							my $sth=$dbh->prepare("select itemtype,description from itemtypes");
							$sth->execute;
							push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
							while (my ($itemtype,$description) = $sth->fetchrow_array) {
								push @authorised_values, $itemtype;
							}
						#---- "true" authorised value
						} else {
							$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});
							push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
							while ((my $value) = $authorised_values_sth->fetchrow_array) {
								push @authorised_values, $value;
							}
						}
						$subfield_data{marc_value}= CGI::scrolling_list(-name=>'field_value',
																					-values=> \@authorised_values,
																					-default=>"$value",
																					-size=>1,
																					-multiple=>0,
																					);
					} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
					} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
						my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
						require $plugin;
						my $extended_param = plugin_parameters($dbh,$record,$tagslib,$i,$tabloop);
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../plugin_launcher.pl?plugin_name=$tagslib->{$tag}->{$subfield}->{value_builder}&index=$i$extended_param',$i)\">...</a>";
					} else {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" size=50 maxlength=255>";
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
							oldbiblionumber => $oldbiblionumber,
							bibid => $bibid);
}
print "Content-Type: text/html\n\n", $template->output;
