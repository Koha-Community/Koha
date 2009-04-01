#!/usr/bin/perl

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
use C4::Koha;
use C4::Biblio;
use C4::Items;
use C4::Auth;
use C4::Output;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "opac-basket.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $bib_list     = $query->param('bib_list');
my $print_basket = $query->param('print');
my $verbose      = $query->param('verbose');

if ($verbose)      { $template->param( verbose      => 1 ); }
if ($print_basket) { $template->param( print_basket => 1 ); }

my @bibs = split( /\//, $bib_list );
my @results;

my $num = 1;
my $marcflavour = C4::Context->preference('marcflavour');
if (C4::Context->preference('TagsEnabled')) {
	$template->param(TagsEnabled => 1);
	foreach (qw(TagsShowOnList TagsInputOnList)) {
		C4::Context->preference($_) and $template->param($_ => 1);
	}
}


foreach my $biblionumber ( @bibs ) {
    $template->param( biblionumber => $biblionumber );

    my $dat              = &GetBiblioData($biblionumber);
    my $record           = &GetMarcBiblio($biblionumber);
    my $marcnotesarray   = GetMarcNotes( $record, $marcflavour );
    my $marcauthorsarray = GetMarcAuthors( $record, $marcflavour );
    my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );
    my $marcseriesarray  = GetMarcSeries  ($record,$marcflavour);
    my $marcurlsarray    = GetMarcUrls    ($record,$marcflavour);
    my @items            = &GetItemsInfo( $biblionumber, 'opac' );
	
    my $shelflocations =GetKohaAuthorisedValues('items.location',$dat->{'frameworkcode'});
    my $collections =  GetKohaAuthorisedValues('items.ccode',$dat->{'frameworkcode'} );

	for my $itm (@items) {
	    $itm->{'location_description'} = $shelflocations->{$itm->{'location'} };
	}
	# COinS format FIXME: for books Only
        my $coins_format;
        my $fmt = substr $record->leader(), 6,2;
        my $fmts;
        $fmts->{'am'} = 'book';
        $dat->{ocoins_format} => $fmts->{$fmt};

    if ( $num % 2 == 1 ) {
        $dat->{'even'} = 1;
    }

    $num++;
    $dat->{biblionumber} = $biblionumber;
    $dat->{ITEM_RESULTS}   = \@items;
    $dat->{MARCNOTES}      = $marcnotesarray;
    $dat->{MARCSUBJCTS}    = $marcsubjctsarray;
    $dat->{MARCAUTHORS}    = $marcauthorsarray;
    $dat->{MARCSERIES}  = $marcseriesarray;
    $dat->{MARCURLS}    = $marcurlsarray;

    if ( C4::Context->preference("BiblioDefaultView") eq "normal" ) {
        $dat->{dest} = "opac-detail.pl";
    }
    elsif ( C4::Context->preference("BiblioDefaultView") eq "marc" ) {
        $dat->{dest} = "opac-MARCdetail.pl";
    }
    else {
        $dat->{dest} = "opac-ISBDdetail.pl";
    }
    push( @results, $dat );
}

my $resultsarray = \@results;

# my $itemsarray=\@items;

$template->param(
    BIBLIO_RESULTS => $resultsarray,
);

output_html_with_http_headers $query, $cookie, $template->output;
