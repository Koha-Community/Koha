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
require Exporter;
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

my $biblionumber=$query->param('biblionumber');
my $bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$biblionumber);

my $tagslib = &MARCgettagslib($dbh,1);

my $record =MARCgetbiblio($dbh,$bibid);
# open template
my $template = gettemplate("catalogue/MARCdetail.tmpl",0);
# fill arrays
my @loop_data =();
my $tag;
for ($tag=0 ; $tag<=9 ; $tag++) {
# marc array (tags and subfields)
# loop each field having tag = $tag."XX"
	my @fields = $record->field($tag."XX");
		my @loop_data =();
	foreach my $field (@fields) {
		my @subf=$field->subfields;
		my $previous_tag = '';
		my @subfields_data;
# loop through each subfield
		for my $i (0..$#subf) {
# if we not exactly the same tag (XX can varry !), loop for "tag tittle".
			if ($previous_tag ne $field->tag()) {
				my %tag_data;
				$tag_data{tag}=$field->tag().' '. $tagslib->{$field->tag()}->{lib};
				$tag_data{subfield} = \@subfields_data;
				push (@loop_data, \%tag_data);
				$previous_tag = $field->tag();
			}
			$previous_tag = $field->tag();
			my %subfield_data;
			$subfield_data{marc_lib}=$tagslib->{$field->tag()}->{$subf[$i][0]}->{lib};
			$subfield_data{marc_value}=$subf[$i][1];
			$subfield_data{marc_tag}=$field->tag().$subf[$i][0];
			push(@subfields_data, \%subfield_data);
		}
	}
	$template->param($tag."XX" =>\@loop_data);
}

# fill template with arrays
$template->param(biblionumber => $biblionumber);
#$template->param(marc =>\@loop_data);
$template->param(bibid => $bibid);
print "Content-Type: text/html\n\n", $template->output;

