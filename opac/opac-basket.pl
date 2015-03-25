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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


use strict;
use warnings;
use CGI;
use C4::Koha;
use C4::Biblio;
use C4::Branch;
use C4::Items;
use C4::Circulation;
use C4::Auth;
use C4::Output;

my $query = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user (
    {
        template_name   => "opac-basket.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
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
    next unless $dat;
    my $record           = &GetMarcBiblio($biblionumber);
    next unless $record;
    my $marcnotesarray   = GetMarcNotes( $record, $marcflavour );
    my $marcauthorsarray = GetMarcAuthors( $record, $marcflavour );
    my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );
    my $marcseriesarray  = GetMarcSeries  ($record,$marcflavour);
    my $marcurlsarray    = GetMarcUrls    ($record,$marcflavour);
    my @items            = &GetItemsInfo( $biblionumber );
    my $subtitle         = GetRecordValue('subtitle', $record, GetFrameworkCode($biblionumber));

    my $hasauthors = 0;
    if($dat->{'author'} || @$marcauthorsarray) {
      $hasauthors = 1;
    }
    my $collections =  GetKohaAuthorisedValues('items.ccode',$dat->{'frameworkcode'}, 'opac');
    my $shelflocations =GetKohaAuthorisedValues('items.location',$dat->{'frameworkcode'}, 'opac');

	# COinS format FIXME: for books Only
        my $coins_format;
        my $fmt = substr $record->leader(), 6,2;
        my $fmts;
        $fmts->{'am'} = 'book';
        $dat->{ocoins_format} = $fmts->{$fmt};

    if ( $num % 2 == 1 ) {
        $dat->{'even'} = 1;
    }

my $branches = GetBranches();
    for my $itm (@items) {
        if ($itm->{'location'}){
            $itm->{'location_opac'} = $shelflocations->{$itm->{'location'} };
        }
        my ( $transfertwhen, $transfertfrom, $transfertto ) = GetTransfers($itm->{itemnumber});
        if ( defined( $transfertwhen ) && $transfertwhen ne '' ) {
             $itm->{transfertwhen} = $transfertwhen;
             $itm->{transfertfrom} = $branches->{$transfertfrom}{branchname};
             $itm->{transfertto}   = $branches->{$transfertto}{branchname};
        }
    }
    $num++;
    $dat->{biblionumber} = $biblionumber;
    $dat->{ITEM_RESULTS}   = \@items;
    $dat->{MARCNOTES}      = $marcnotesarray;
    $dat->{MARCSUBJCTS}    = $marcsubjctsarray;
    $dat->{MARCAUTHORS}    = $marcauthorsarray;
    $dat->{MARCSERIES}  = $marcseriesarray;
    $dat->{MARCURLS}    = $marcurlsarray;
    $dat->{HASAUTHORS}  = $hasauthors;
    $dat->{subtitle} = $subtitle;

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
    bib_list => $bib_list,
    BIBLIO_RESULTS => $resultsarray,
);

output_html_with_http_headers $query, $cookie, $template->output;
