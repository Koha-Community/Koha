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
use HTML::Template;
require Exporter;	# FIXME - Is this really necessary?
use C4::Context;
use C4::Output;  # contains gettemplate
use CGI;
use C4::Search;
use MARC::Record;
use C4::Biblio;
use C4::Catalogue;
 
my $query=new CGI;
    
my $biblionumber=$query->param('bib');
my $tag=$query->param('tag');
if (! defined $tag) { $tag='2XX';}
#print STDERR "BIB : $biblionumber // TAG : $tag\n";
if (! defined $biblionumber) {
    my $template = gettemplate("MARCdetailbiblioselect.tmpl");
    print "Content-Type: text/html\n\n", $template->output;

} else {
    &showmarcrecord($biblionumber,$tag);
}

sub showmarcrecord {
    my ($biblionumber,$tag) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select liblibrarian from marc_subfield_structure where tagfield=? and tagsubfield=?");
    my $record =MARCgetbiblio($dbh,$biblionumber);
# open template
    my $template = gettemplate("MARCdetail.tmpl");
# fill arrays
    my @loop_data =();
    my @fields = $record->field($tag);
    foreach my $field (@fields) {
	my @subf=$field->subfields;
	for my $i (0..$#subf) {
	    $sth->execute($field->tag(), $subf[$i][0]);
	    my $row=$sth->fetchrow_hashref;
	    my %row_data;
	    $row_data{marc_lib}=$row->{'liblibrarian'};
	    $row_data{marc_value}=$subf[$i][1];
	    $row_data{marc_tag}=$field->tag().$subf[$i][0];
	    push(@loop_data, \%row_data);
#	    print $field->tag(), " ", $field->indicator(1),$field->indicator(2), "subf: ", $subf[$i][0]," =",$subf[$i][1]," <-- \n";
	}
    }
    
# fill template with arrays
    $template->param(biblionumber => $biblionumber);
    $template->param(marc =>\@loop_data);
    print "Content-Type: text/html\n\n", $template->output;
    
}
