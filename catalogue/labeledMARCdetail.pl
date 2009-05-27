#!/usr/bin/perl

# Copyright 2008-2009 LibLime
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
use warnings;
use CGI; 
use MARC::Record;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Biblio;
use C4::Search;		# enabled_staff_search_views

my $query        = new CGI;
my $dbh          = C4::Context->dbh;
my $biblionumber = $query->param('biblionumber');
my $frameworkcode = $query->param('frameworkcode');
$frameworkcode = GetFrameworkCode( $biblionumber ) unless ($frameworkcode);
my $popup        =
  $query->param('popup')
  ;    # if set to 1, then don't insert links, it's just to show the biblio

my $tagslib = GetMarcStructure(1,$frameworkcode);
my $record = GetMarcBiblio($biblionumber);
my $biblio = GetBiblioData($biblionumber);
# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/labeledMARCdetail.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

$template->param( count => 1, bibliotitle => $biblio->{title} );

#Getting the list of all frameworks
my $queryfwk =
  $dbh->prepare("select frameworktext, frameworkcode from biblio_framework");
$queryfwk->execute;
my %select_fwk;
my @select_fwk;
my $curfwk;
push @select_fwk, "Default";
$select_fwk{"Default"} = "Default";

while ( my ( $description, $fwk ) = $queryfwk->fetchrow ) {
    push @select_fwk, $fwk;
    $select_fwk{$fwk} = $description;
}
$curfwk=$frameworkcode;
my $framework=CGI::scrolling_list( -name     => 'Frameworks',
            -id => 'Frameworks',
            -default => $curfwk,
            -OnChange => 'Changefwk(this);',
            -values   => \@select_fwk,
            -labels   => \%select_fwk,
            -size     => 1,
            -multiple => 0 );
$template->param(framework => $framework);

my @marc_data;
my $prevlabel = '';
for my $field ($record->fields)
{
	my $tag = $field->tag;
	next if ! exists $tagslib->{$tag}->{lib};
	my $label = $tagslib->{$tag}->{lib};
	if ($label eq $prevlabel)
	{
		$label = '';
	}
	else
	{
		$prevlabel = $label;
	}
	my $value = $tag < 10
		? $field->data
		: join ' ', map { $_->[1] } $field->subfields;
	push @marc_data, {
		label => $label,
		value => $value,
	};
}

$template->param (
	marc_data				=> \@marc_data,
    biblionumber            => $biblionumber,
    popup                   => $popup,
	labeledmarcview => 1,
	z3950_search_params		=> C4::Search::z3950_search_args($biblio),
	C4::Search::enabled_staff_search_views,
);

output_html_with_http_headers $query, $cookie, $template->output;
