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

use strict;
use CGI;
use C4::Auth;
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
#	$marc = char_decode($marc);
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

# some special chars in ISO 2709 (ISO 6630 and ISO 646 set)

my $IS3 = '\x1d' ;		# IS3 : record end
my $IS2 = '\x1e' ;		# IS2 : field end
my $IS1 = '\x1f' ;		# IS1 : begin subfield
my $NSB = '\x88' ;		# NSB : begin Non Sorting Block
my $NSE = '\x89' ;		# NSE : Non Sorting Block end

sub char_decode {
	# converts ISO 5426 coded string to ISO 8859-1
	# sloppy code : should be improved in next issue
	my ($string) = @_ ;
	$_ = $string ;
	if(/[\xc1-\xff]/) {
		s/\xe1/Æ/gm ;
		s/\xe2/Ð/gm ;
		s/\xe9/Ø/gm ;
		s/\xec/þ/gm ;
		s/\xf1/æ/gm ;
		s/\xf3/ð/gm ;
		s/\xf9/ø/gm ;
		s/\xfb/ß/gm ;
		s/\xc1\x61/à/gm ;
		s/\xc1\x65/è/gm ;
		s/\xc1\x69/ì/gm ;
		s/\xc1\x6f/ò/gm ;
		s/\xc1\x75/ù/gm ;
		s/\xc1\x41/À/gm ;
		s/\xc1\x45/È/gm ;
		s/\xc1\x49/Ì/gm ;
		s/\xc1\x4f/Ò/gm ;
		s/\xc1\x55/Ù/gm ;
		s/\xc2\x41/Á/gm ;
		s/\xc2\x45/É/gm ;
		s/\xc2\x49/Í/gm ;
		s/\xc2\x4f/Ó/gm ;
		s/\xc2\x55/Ú/gm ;
		s/\xc2\x59/Ý/gm ;
		s/\xc2\x61/á/gm ;
		s/\xc2\x65/é/gm ;
		s/\xc2\x69/í/gm ;
		s/\xc2\x6f/ó/gm ;
		s/\xc2\x75/ú/gm ;
		s/\xc2\x79/ý/gm ;
		s/\xc3\x41/Â/gm ;
		s/\xc3\x45/Ê/gm ;
		s/\xc3\x49/Î/gm ;
		s/\xc3\x4f/Ô/gm ;
		s/\xc3\x55/Û/gm ;
		s/\xc3\x61/â/gm ;
		s/\xc3\x65/ê/gm ;
		s/\xc3\x69/î/gm ;
		s/\xc3\x6f/ô/gm ;
		s/\xc3\x75/û/gm ;
		s/\xc4\x41/Ã/gm ;
		s/\xc4\x4e/Ñ/gm ;
		s/\xc4\x4f/Õ/gm ;
		s/\xc4\x61/ã/gm ;
		s/\xc4\x6e/ñ/gm ;
		s/\xc4\x6f/õ/gm ;
		s/\xc8\x45/Ë/gm ;
		s/\xc8\x49/Ï/gm ;
		s/\xc8\x65/ë/gm ;
		s/\xc8\x69/ï/gm ;
		s/\xc8\x76/ÿ/gm ;
		s/\xc9\x41/Ä/gm ;
		s/\xc9\x4f/Ö/gm ;
		s/\xc9\x55/Ü/gm ;
		s/\xc9\x61/ä/gm ;
		s/\xc9\x6f/ö/gm ;
		s/\xc9\x75/ü/gm ;
		s/\xca\x41/Å/gm ;
		s/\xca\x61/å/gm ;
		s/\xd0\x43/Ç/gm ;
		s/\xd0\x63/ç/gm ;
	}
	# this handles non-sorting blocks (if implementation requires this)
	$string = nsb_clean($_) ;
	return($string) ;
}

sub nsb_clean {
	# handles non sorting blocks
	my ($string) = @_ ;
	$_ = $string ;
	s/$NSB/(/gm ;
	s/[ ]{0,1}$NSE/) /gm ;
	$string = $_ ;
	return($string) ;
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
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui.simple/addbiblio.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

my $tagslib = &MARCgettagslib($dbh,1);
my $record=-1;
$record = MARCgetbiblio($dbh,$bibid) if ($bibid);
#warn "1= ".$record->as_formatted;
$record = MARCfindbreeding($dbh,$isbn) if ($isbn);
my $is_a_modif=0;
my ($oldbiblionumtagfield,$oldbiblionumtagsubfield);
my ($oldbiblioitemnumtagfield,$oldbiblioitemnumtagsubfield,$bibitem,$oldbiblioitemnumber);
if ($bibid) {
	$is_a_modif=1;
	# if it's a modif, retrieve old biblio and bibitem numbers for the future modification of old-DB.
	($oldbiblionumtagfield,$oldbiblionumtagsubfield) = &MARCfind_marc_from_kohafield($dbh,"biblio.biblionumber");
	($oldbiblioitemnumtagfield,$oldbiblioitemnumtagsubfield) = &MARCfind_marc_from_kohafield($dbh,"biblioitems.biblioitemnumber");
	# search biblioitems value
	my $sth=$dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
	$sth->execute($oldbiblionumber);
	($oldbiblioitemnumber) = $sth->fetchrow;
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
		 NEWmodbiblio($dbh,$record,$bibid);
	} else {
		($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbiblio($dbh,$record);
	}
# now, redirect to additem page
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=additem.pl?bibid=$bibid\"></html>";
	exit;
#------------------------------------------------------------------------------------------------------------------------------
} else {
#------------------------------------------------------------------------------------------------------------------------------
	# fill arrays
	my @loop_data =();
	my $tag;
	my $i=0;
	my $authorised_values_sth = $dbh->prepare("select authorised_value,lib from authorised_values where category=? order by authorised_value");
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
					$value=char_decode($value);
					$indicator = $x if $x;
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
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>"; #"
					} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
						my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
						require $plugin;
						my $extended_param = plugin_parameters($dbh,$record,$tagslib,$i,$tabloop);
						my ($function_name,$javascript) = plugin_javascript($dbh,$record,$tagslib,$i,$tabloop);
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  value=\"$value\" size=47 maxlength=255 OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i)\"> <a href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
					} else {
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\" size=50 maxlength=255>";
					}
				# if breeding is empty
				} else {
					my ($x,$value);
					($x,$value) = find_value($tag,$subfield,$record) if ($record ne -1);
					$value=char_decode($value);
					if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
						my @authorised_values;
						my %authorised_lib;
						# builds list, depending on authorised value...
						#---- branch
						if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
							my $sth=$dbh->prepare("select branchcode,branchname from branches order by branchcode");
							$sth->execute;
							push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
							while (my ($branchcode,$branchname) = $sth->fetchrow_array) {
								push @authorised_values, $branchcode;
								$authorised_lib{$branchcode}=$branchname;
							}
						#----- itemtypes
						} elsif ($tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes") {
							my $sth=$dbh->prepare("select itemtype,description from itemtypes order by itemtype");
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
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
					} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
						my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
						require $plugin;
						my $extended_param = plugin_parameters($dbh,$record,$tagslib,$i,$tabloop);
						my ($function_name,$javascript) = plugin_javascript($dbh,$record,$tagslib,$i,$tabloop);
						$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i)\"> <a href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
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
							bibid => $bibid,
							oldbiblionumtagfield => $oldbiblionumtagfield,
							oldbiblionumtagsubfield => $oldbiblionumtagsubfield,
							oldbiblioitemnumtagfield => $oldbiblioitemnumtagfield,
							oldbiblioitemnumtagsubfield => $oldbiblioitemnumtagsubfield,
							oldbiblioitemnumber => $oldbiblioitemnumber);
}
print $input->header(-cookie => $cookie),$template->output;
