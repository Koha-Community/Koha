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
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Serials;    #uses getsubscriptionfrom biblionumber
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Dates qw/format_date/;
use C4::XISBN qw(get_xisbns get_biblio_from_xisbn);
use C4::Amazon;
use C4::Review;
use C4::Serials;
use C4::Members;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-detail.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        flagsrequired   => { borrow => 1 },
    }
);

my $biblionumber = $query->param('biblionumber') || $query->param('bib');
$template->param( biblionumber => $biblionumber );

# change back when ive fixed request.pl
my @items = &GetItemsInfo( $biblionumber, 'opac' );
my $dat = &GetBiblioData($biblionumber);

if (!$dat) {
    print $query->redirect("/cgi-bin/koha/koha-tmpl/errors/404.pl");
    exit;
}

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       =
  GetSubscriptions( $dat->{title}, $dat->{issn}, $biblionumber );
my @subs;
$dat->{'serial'}=1 if $subscriptionsnumber;
foreach my $subscription (@subscriptions) {
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};
    $cell{branchcode}        = $subscription->{branchcode};
    #get the three latest serials.
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, 3 );
    push @subs, \%cell;
}

$dat->{'count'} = scalar(@items);

#adding RequestOnOpac filter to allow or not the display of plce reserve button
# FIXME - use me or delete me.
my $RequestOnOpac;
if (C4::Context->preference("RequestOnOpac")) {
    $RequestOnOpac = 1;
}

my $norequests = 1;
foreach my $itm (@items) {
     $norequests = 0 && $norequests
       if ( (not $itm->{'wthdrawn'} )
         || (not $itm->{'itemlost'} )
         || (not $itm->{'itemnotforloan'} )
         || ($itm->{'itemnumber'} ) );
        $itm->{ $itm->{'publictype'} } = 1;

        #get collection code description, too
        $itm->{'ccode'}  = GetAuthorisedValueDesc('','',   $itm->{'ccode'} ,'','','CCODE');
}

$template->param( norequests => $norequests, RequestOnOpac=>$RequestOnOpac );

## get notes and subjects from MARC record
    my $dbh              = C4::Context->dbh;
    my $marcflavour      = C4::Context->preference("marcflavour");
    my $record           = GetMarcBiblio($biblionumber);
    my $marcnotesarray   = GetMarcNotes( $record, $marcflavour );
    my $marcauthorsarray = GetMarcAuthors( $record, $marcflavour );
    my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );
    my $marcseriesarray  = GetMarcSeries($record,$marcflavour);
    my $marcurlsarray   = GetMarcUrls($record,$marcflavour);

    $template->param(
        MARCNOTES   => $marcnotesarray,
        MARCSUBJCTS => $marcsubjctsarray,
        MARCAUTHORS => $marcauthorsarray,
        MARCSERIES  => $marcseriesarray,
        MARCURLS    => $marcurlsarray,
    );

foreach ( keys %{$dat} ) {
    $template->param( "$_" => $dat->{$_} . "" );
}

# COinS format FIXME: for books Only
my $coins_format;
my $fmt = substr $record->leader(), 6,2;
my $fmts;
$fmts->{'am'} = 'book';
$coins_format = $fmts->{$fmt};
$template->param(
	ocoins_format => $coins_format,
);

my $reviews = getreviews( $biblionumber, 1 );
foreach ( @$reviews ) {
    my $borrower_number_review = $_->{borrowernumber};
    my $borrowerData           = GetMember($borrower_number_review,'borrowernumber');
    # setting some borrower info into this hash
    $_->{title}     = $borrowerData->{'title'};
    $_->{surname}   = $borrowerData->{'surname'};
    $_->{firstname} = $borrowerData->{'firstname'};
    $_->{datereviewed} = format_date($_->{datereviewed});
}

$template->param(
    ITEM_RESULTS        => \@items,
    subscriptionsnumber => $subscriptionsnumber,
    biblionumber        => $biblionumber,
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
    reviews             => $reviews
);

# XISBN Stuff
my $xisbn=$dat->{'isbn'};
$xisbn =~ s/(p|-| |:)//g;
$template->param(amazonisbn => $xisbn);
if (C4::Context->preference("OPACFRBRizeEditions")==1) {
    eval {
        $template->param(
            xisbn => $xisbn,
            XISBNS => get_xisbns($xisbn)
        );
    };
    if ($@) { warn "XISBN Failed $@"; }
}
if ( C4::Context->preference("OPACAmazonContent") == 1 ) {
    my $amazon_details = &get_amazon_details( $xisbn );
    foreach my $result ( @{ $amazon_details->{Details} } ) {
        $template->param( item_description => $result->{ProductDescription} );
        $template->param( image            => $result->{ImageUrlMedium} );
        $template->param( list_price       => $result->{ListPrice} );
        $template->param( amazon_url       => $result->{url} );
    }

    my @products;
    my @reviews;
    for my $details ( @{ $amazon_details->{Details} } ) {
        next unless $details->{SimilarProducts};
        for my $product ( @{ $details->{SimilarProducts}->{Product} } ) {
            if (C4::Context->preference("OPACAmazonSimilarItems") ) {
                my $xbiblios;
                my @xisbns;

                if (C4::Context->preference("OPACXISBNAmazonSimilarItems") ) {
                    my $xbiblio = get_biblio_from_xisbn($product);
                    push @xisbns, $xbiblio;
                    $xbiblios = \@xisbns;
                }
                else {
                    $xbiblios = get_xisbns($product);
                }
                push @products, +{ product => $xbiblios };
            }
        }
        next unless $details->{Reviews};
        for my $product ( @{ $details->{Reviews}->{AvgCustomerRating} } ) {
            $template->param( rating => $product * 20 );
        }
        for my $reviews ( @{ $details->{Reviews}->{CustomerReview} } ) {
            push @reviews,
              +{
                summary => $reviews->{Summary},
                comment => $reviews->{Comment},
              };
        }
    }
    $template->param( SIMILAR_PRODUCTS => \@products );
    $template->param( AMAZONREVIEWS    => \@reviews );
}

output_html_with_http_headers $query, $cookie, $template->output;
