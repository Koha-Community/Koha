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

=head1 NAME

MARCdetail.pl : script to show a biblio in MARC format

=head1 SYNOPSIS


=head1 DESCRIPTION

This script needs a biblionumber in bib parameter (bibnumber from koha style DB. Automaticaly maps to marc biblionumber).
It shows the biblio in a (nice) MARC format depending on MARC parameters tables.
The template is in <templates_dir>/catalogue/MARCdetail.tmpl. this template must be divided in 11 "tabs".
The 10 firsts presents the biblio, the 11th one presents the items attached to the biblio

=head1 FUNCTIONS

=over 2

=cut


use strict;
require Exporter;
use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use C4::Search;
use MARC::Record;
use C4::Biblio;
use C4::Catalogue;
use HTML::Template;

my $query=new CGI;

my $dbh=C4::Context->dbh;

my $biblionumber=$query->param('bib');
my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);

my $tagslib = &MARCgettagslib($dbh,1);

my $record =MARCgetbiblio($dbh,$bibid);
#warn $record->as_formatted();
# open template
my ($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "catalogue/MARCdetail.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

# fill arrays
my @loop_data =();
my $tag;
# loop through each tab 0 through 9
for (my $tabloop = 0; $tabloop<=10;$tabloop++) {
# loop through each tag
	my @fields = $record->fields();
	my @loop_data =();
	foreach my $field (@fields) {
		my @subf=$field->subfields;
		my $previous_tag = '';
		my @subfields_data;
# loop through each subfield
		for my $i (0..$#subf) {
			$previous_tag = $field->tag();
			next if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{tab}  ne $tabloop);
			my %subfield_data;
			$subfield_data{marc_lib}=$tagslib->{$field->tag()}->{$subf[$i][0]}->{lib};
			$subfield_data{marc_value}=$subf[$i][1];
			$subfield_data{marc_tag}=$subf[$i][0];
			push(@subfields_data, \%subfield_data);
		}
		if ($#subfields_data>=0) {
			my %tag_data;
			$tag_data{tag}=$field->tag().' -'. $tagslib->{$field->tag()}->{lib};
			$tag_data{subfield} = \@subfields_data;
			push (@loop_data, \%tag_data);
		}
	}
	$template->param($tabloop."XX" =>\@loop_data);
}
# now, build item tab !
# the main difference is that datas are in lines and not in columns : thus, we build the <th> first, then the values...
# loop through each tag
# warning : we may have differents number of columns in each row. Thus, we first build a hash, complete it if necessary
# then construct template.
my @fields = $record->fields();
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
#		warn "filled : ".$big_array[$i]{$subfield_code};
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
#	warn $items_data;
	my %row_data;
	$row_data{item_value} = $items_data;
	push(@item_value_loop,\%row_data);
}
foreach my $subfield_code (keys(%witness)) {
	my %header_value;
	$header_value{header_value} = $witness{$subfield_code};
	push(@header_value_loop, \%header_value);
}

$template->param(item_loop => \@item_value_loop,
						item_header_loop => \@header_value_loop,
						biblionumber => $biblionumber,
						bibid => $bibid);
print $query->header(-cookie => $cookie),$template->output;

